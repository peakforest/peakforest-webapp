package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import fr.metabohub.peakforest.dao.metadata.AnalyticalMatrixMetadataDao;
import fr.metabohub.peakforest.model.metadata.AnalyticalMatrix;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.spectralibraries.dumper.SpectrumTemplateXLSMDumper;
import fr.metabohub.spectralibraries.mapper.PeakForestDataMapper;
import fr.metabohub.spectralibraries.utils.JsonTools;
import fr.metabohub.spectralibraries.utils.SpectralIOException;

@Controller
public class TemplateController {

	@RequestMapping(value = "/template", method = RequestMethod.GET)
	public ModelAndView redirectFromTemplate(HttpServletResponse httpServletResponse) {
		// httpServletResponse.setHeader("Location", "home?page=template");
		return new ModelAndView("redirect:" + "home?page=template");
	}

	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/dumpTemplate", method = RequestMethod.POST, headers = { "Content-type=application/json" })
	@ResponseBody
	public Object dumpTemplate(@RequestBody Map<String, Object> jsonData, HttpServletRequest request) throws Exception {

		// init / db connect
		// process flag
		String clientSessionId = ProcessProgressManager.XLSM_DUMP_SPECTRAL_TEMPLATE + request.getSession().getId();
		boolean success = true;
		String error = "";

		// put to 0% the process progression
		ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);

		// get template type;
		boolean isGCMS = false;
		boolean isLCMS = false;
		boolean isLCMSMS = false;
		boolean isNMR = false;
		// boolean isLCNMR = false;
		String dumperKey = "all_";
		String dumperVersion = PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.version") + "_";
		String dumperID = EncodeUtils.getSHA1(jsonData.toString()).substring(0, 8);
		String dumperFileDir = PeakForestUtils.getBundleConfElement("generatedFiles.prefix") + File.separator
				+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + File.separator
				+ PeakForestUtils.getBundleConfElement("generatedXlsmExport.folder");

		// ORIGINE FILE
		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.folder");
		String templateFileName = PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.file");

		// create dir if not exist
		if (!new File(dumperFileDir).exists())
			new File(dumperFileDir).mkdirs();

		if (jsonData.containsKey("analytical_sample") && jsonData.get("analytical_sample").toString() != null) {

			Map<String, Object> jsonDataSample = (Map<String, Object>) jsonData.get("analytical_sample");
			if (jsonDataSample.containsKey("sample_type") && jsonDataSample.get("sample_type") instanceof String) {
				switch (jsonDataSample.get("sample_type").toString()) {
				case "analytical-matrix":
					String filter = jsonDataSample.get("analytical-matrix-filter").toString();
					List<AnalyticalMatrix> listRaw = new ArrayList<>();
					if (filter.equalsIgnoreCase("allPF")) {
						listRaw = AnalyticalMatrixMetadataDao.readAll();
					} else if (filter.equalsIgnoreCase("topPF")) {
						listRaw = AnalyticalMatrixMetadataDao.listFavourtie();
					} else if (filter.equalsIgnoreCase("allOntoFW")) {
						// not scheduled... yet!
					}
					List<LinkedHashMap<String, Object>> listClean = new ArrayList<>();
					for (AnalyticalMatrix matrix : listRaw) {
						LinkedHashMap<String, Object> data = new LinkedHashMap<>();
						// data.put("id", matrix.getId());
						data.put("key", matrix.getKey());
						data.put("naturalLanguage", matrix.getNaturalLanguage());
						// data.put("html", matrix.getHtmlDisplay());
						// data.put("isFav", matrix.isFavourite());
						// data.put("countSpectra", matrix.getSpectraNumber());
						listClean.add(data);
					}

					jsonData.put("matrix", listClean);
					break;
				}
			}
		}
		if (jsonData.containsKey("dumper_type") && jsonData.get("dumper_type") instanceof String) {
			switch (jsonData.get("dumper_type").toString()) {
			case "lc-ms":
				isLCMS = true;
				dumperKey = "LC-MS_";
				break;
			case "nmr":
				isNMR = true;
				dumperKey = "NMR_";
				break;
			case "lc-msms":
				isLCMSMS = true;
				dumperKey = "LC-MSMS_";
				break;
			case "gc-ms":
				isGCMS = true;
				dumperKey = "GC-MS_";
				break;
			// reserved for lc-nmr / fia / ...
			default:
				// not supported
				break;
			}
		}

		// get template file name
		String dumperFileName = "template_" + dumperKey + dumperVersion + dumperID + "." + PeakForestUtils.XLSM_EXT;

		File templateFile = new File(templateFileDir + File.separator + templateFileName);
		File dumperFile = new File(dumperFileDir + File.separator + dumperFileName);

		// test if file exists (if exist : do not create it)
		if (!dumperFile.exists()) {
			// file does NOT exist => create it

			// test if template file exist, if not -> error
			if (templateFile.exists()) {

				// init peak forest data mapper
				PeakForestDataMapper dataMapper = null;
				if (isLCMS)
					dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_LC_MS);
				else if (isLCMSMS)
					dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_LC_MSMS);
				else if (isNMR)
					dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_NMR);
				else if (isGCMS)
					dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_GC_MS);
				else
					dataMapper = new PeakForestDataMapper();

				// fulfill peakforest data mapper from JSON object
				success = JsonTools.jsonToMapper(jsonData, dataMapper);

				// put to 50% the process progression
				ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 50);

				// dump DataMapper into XLSM file
				if (success)
					try {
						SpectrumTemplateXLSMDumper.dumpXLSM(templateFile, dumperFile, dataMapper);
					} catch (IOException | InvalidFormatException | SpectralIOException | NullPointerException e) {
						success = false;
						if (dumperFile.exists())
							dumperFile.delete();
						error = "could_not_create_dumper_file";
						e.printStackTrace();
					} catch (Exception e) {
						success = false;
						if (dumperFile.exists())
							dumperFile.delete();
						error = "could_not_create_dumper_file";
						e.printStackTrace();
					}
				else
					error = "json_format_error";
				// success => create and return URL to download it
				// FAIL => delete created file

			} else {
				success = false;
				error = "template_file_not_found";
			}

		}

		// put to 90% the process progression
		ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 90);

		// handed 9080 or other port
		String port = request.getServerPort() + "";
		if (port.equals("80"))
			port = "";
		else
			port = ":" + port;

		// url
		String xlsmFileUrl = request.getScheme() + "://" + request.getServerName() + port + "/"
				+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + "/"
				+ PeakForestUtils.getBundleConfElement("generatedXlsmExport.folder") + "/" + dumperFileName;

		// object with boolean 'success' and string url
		Map<String, Object> response = new HashMap<String, Object>();
		response.put("success", success);
		if (!success)
			response.put("error", error);
		else {
			response.put("fileName", dumperFile.getName());
			response.put("fileURL", xlsmFileUrl);
		}

		// put to 100% the process progression
		ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 100);

		return response;
	}

	// private String grepOntologyNameByID(long id, File sourceOntologyFile) {
	// String name = null;
	// Pattern regexp = Pattern.compile("^0*" + id + "\\t");
	// Matcher matcher = regexp.matcher("");
	//
	// Path path = Paths.get(sourceOntologyFile.getAbsolutePath());
	// try (BufferedReader reader = Files.newBufferedReader(path,
	// StandardCharsets.UTF_8);
	// LineNumberReader lineReader = new LineNumberReader(reader);) {
	// String line = null;
	// while ((line = lineReader.readLine()) != null) {
	// matcher.reset(line.toLowerCase()); // reset the input
	// if (matcher.find()) {
	// String[] dataLine = line.split("\\t");
	// name = dataLine[1];
	// // results.add(new OntologyMapper(Long.parseLong(dataLine[0]), dataLine[1]));
	// }
	// }
	// } catch (Exception ex) {
	// // ex.printStackTrace();
	// // results.add("s");
	// }
	// return name;
	// }

}
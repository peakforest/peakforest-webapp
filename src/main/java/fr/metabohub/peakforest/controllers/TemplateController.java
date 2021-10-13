package fr.metabohub.peakforest.controllers;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.LineNumberReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.services.metadata.AnalyticalMatrixManagementService;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.Utils;
import fr.metabohub.spectralibraries.dumper.SpectrumTemplateXLSMDumper;
import fr.metabohub.spectralibraries.mapper.PeakForestDataMapper;
import fr.metabohub.spectralibraries.utils.JsonTools;
import fr.metabohub.spectralibraries.utils.SpectralIOException;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class TemplateController {

	/**
	 * @param httpServletResponse
	 */
	@RequestMapping(value = "/template", method = RequestMethod.GET)
	public ModelAndView redirectFromTemplate(HttpServletResponse httpServletResponse) {
		// httpServletResponse.setHeader("Location", "home?page=template");
		return new ModelAndView("redirect:" + "home?page=template");
	}

	/**
	 * @param type
	 * @param id
	 * @param jsonData
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/dumpTemplate", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	@ResponseBody
	public Object dumpTemplate(@RequestBody Map<String, Object> jsonData, HttpServletRequest request)
			throws Exception {

		// init / db connect
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String login = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// process flag
		String clientSessionId = ProcessProgressManager.XLSM_DUMP_SPECTRAL_TEMPLATE
				+ request.getSession().getId();
		boolean success = true;
		String error = "";

		// put to 0% the process progression
		ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);

		// get template type;
		// boolean isGCMS = false;
		boolean isLCMS = false;
		boolean isLCMSMS = false;
		boolean isNMR = false;
		// boolean isLCNMR = false;
		String dumperKey = "all_";
		String dumperVersion = Utils.getBundleConfElement("spectralDataXlsmTemplate.version") + "_";
		String dumperID = EncodeUtils.getSHA1(jsonData.toString()).substring(0, 8);
		String dumperFileDir = Utils.getBundleConfElement("generatedFiles.prefix") + File.separator
				+ Utils.getBundleConfElement("generatedFiles.folder") + File.separator
				+ Utils.getBundleConfElement("generatedXlsmExport.folder");

		// ORIGINE FILE
		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + Utils.getBundleConfElement("spectralDataXlsmTemplate.folder");
		String templateFileName = Utils.getBundleConfElement("spectralDataXlsmTemplate.file");

		// create dir if not exist
		if (!new File(dumperFileDir).exists())
			new File(dumperFileDir).mkdirs();

		if (jsonData.containsKey("analytical_sample")
				&& jsonData.get("analytical_sample").toString() != null) {
			@SuppressWarnings("unchecked")
			Map<String, Object> jsonDataSample = (Map<String, Object>) jsonData.get("analytical_sample");
			if (jsonDataSample.containsKey("sample_type")
					&& jsonDataSample.get("sample_type") instanceof String) {
				switch (jsonDataSample.get("sample_type").toString()) {
				case "analytical-matrix":
					// init: if analytical matrix, add in DB
					String ontologiesFileDir = appRoot + Utils.getBundleConfElement("ontologies.folder");
					// analytical-matrix-source
					if (jsonDataSample.containsKey("analytical-matrix-source")
							&& jsonDataSample.get("analytical-matrix-source").toString() != "") {
						try {
							long sourceId = Long
									.parseLong(jsonDataSample.get("analytical-matrix-source").toString());
							// ORIGINE FILE
							String ontologiesSourceFileName = Utils
									.getBundleConfElement("ontologies.source.file");
							File sourceOntologyFile = new File(
									ontologiesFileDir + File.separator + ontologiesSourceFileName);
							String sourceName = grepOntologyNameByID(sourceId, sourceOntologyFile);
							AnalyticalMatrixManagementService.createSource(sourceId, sourceName, dbName,
									login, password);
						} catch (NumberFormatException e) {
						}
					}
					// analytical-matrix-type
					if (jsonDataSample.containsKey("analytical-matrix-type")
							&& jsonDataSample.get("analytical-matrix-type").toString() != "") {
						try {
							long typeId = Long
									.parseLong(jsonDataSample.get("analytical-matrix-type").toString());
							// ORIGINE FILE
							String ontologiesTypeFileName = Utils
									.getBundleConfElement("ontologies.type.file");
							File sourceOntologyFile = new File(
									ontologiesFileDir + File.separator + ontologiesTypeFileName);
							String typeName = grepOntologyNameByID(typeId, sourceOntologyFile);
							AnalyticalMatrixManagementService.createType(typeId, typeName, dbName, login,
									password);
						} catch (NumberFormatException e) {
						}
					}
					// fetch all analytical matrix / update XLSM template
					List<String> sources = AnalyticalMatrixManagementService.listSources(dbName, login,
							password);
					List<String> types = AnalyticalMatrixManagementService.listTypes(dbName, login, password);
					jsonData.put("sources-list", sources);
					jsonData.put("types-list", types);
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
			// TODO gc-ms / lc-nmr / ...
			default:
				// not supported
				break;
			}
		}

		// get template file name
		String dumperFileName = "template_" + dumperKey + dumperVersion + dumperID + "." + Utils.XLSM_EXT;

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
				else
					dataMapper = new PeakForestDataMapper();

				// fulfill peakforest data mapper from JSON object
				success = JsonTools.jsonToMapper(jsonData, dataMapper);

				// put to 50% the process progression
				ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 50);

				// dump DataMapper into XLSM file
				if (success)
					try {
						SpectrumTemplateXLSMDumper.dumpXLSM(templateFile, dumperFile, dataMapper, true);
					} catch (IOException | InvalidFormatException | SpectralIOException
							| NullPointerException e) {
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
				+ Utils.getBundleConfElement("generatedFiles.folder") + "/"
				+ Utils.getBundleConfElement("generatedXlsmExport.folder") + "/" + dumperFileName;

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

	private String grepOntologyNameByID(long id, File sourceOntologyFile) {
		String name = null;
		Pattern regexp = Pattern.compile("^0*" + id + "\\t");
		Matcher matcher = regexp.matcher("");

		Path path = Paths.get(sourceOntologyFile.getAbsolutePath());
		try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8);
				LineNumberReader lineReader = new LineNumberReader(reader);) {
			String line = null;
			while ((line = lineReader.readLine()) != null) {
				matcher.reset(line.toLowerCase()); // reset the input
				if (matcher.find()) {
					String[] dataLine = line.split("\\t");
					name = dataLine[1];
					// results.add(new OntologyMapper(Long.parseLong(dataLine[0]), dataLine[1]));
				}
			}
		} catch (Exception ex) {
			// ex.printStackTrace();
			// results.add("s");
		}
		return name;
	}

}
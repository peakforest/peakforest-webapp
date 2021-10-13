/**
 * 
 */
package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.spectrum.CompoundSpectrum;
import fr.metabohub.peakforest.model.spectrum.FragmentationICSpectrum;
import fr.metabohub.peakforest.model.spectrum.FragmentationLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanGCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanICSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.spectrum.ExportService;
import fr.metabohub.peakforest.services.spectrum.FragmentationICSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FragmentationLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanGCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanICSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;
import fr.metabohub.peakforest.utils.PeakForestPruneUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;

/**
 * @author Nils Paulhe
 * 
 */

@Controller
public class ExportSpectraController {

	@Autowired
	protected MessageSource messageSource;

	// @Autowired
	// private ErrorMessageManager errorMessageManager;

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/spectrum-xlsm-export"//
	) //
	public @ResponseBody Object spectrumXlsmExport(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final @RequestParam(value = "id") long idSpectrum, //
			@RequestParam(value = "name") String fileName)//
			throws IOException {
		fileName = PeakForestPruneUtils.convertHtmlGreekCharToString(fileName);
		final String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.folder");
		String templateFileName = PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.file");
		final File templateFile = new File(templateFileDir + File.separator + templateFileName);
		try {
			// creation of the directory containing the uploaded files
			String clientSessionId = ProcessProgressManager.XLSM_DUMP_SPECTRAL_FILE + request.getSession().getId();
			// put to 0% the process progression
			ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);
			String folderPath = PeakForestUtils.getBundleConfElement("generatedFiles.prefix") + File.separator
					+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + File.separator
					+ PeakForestUtils.getBundleConfElement("generatedXlsmExport.folder");
			if (!new File(folderPath).exists())
				new File(folderPath).mkdirs();
			// file to create
			String newFileName = fileName.replaceAll(" ", "_").replaceAll(";", "") + System.currentTimeMillis() + "."
					+ PeakForestUtils.XLSM_EXT;
			String newFilePath = folderPath + File.separator + newFileName;
			// handed 9080 or other port
			String port = request.getServerPort() + "";
			if (port.equals("80")) {
				port = "";
			} else {
				port = ":" + port;
			}
			// url
			String xlsmFileUrl = "//" + request.getServerName() + port + "/"
					+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + "/"
					+ PeakForestUtils.getBundleConfElement("generatedXlsmExport.folder") + "/" + newFileName;
			xlsmFileUrl = xlsmFileUrl.replaceAll(";", "%3B");
			// create file
			final Map<String, Object> exportAllData = ExportService.exportSpectrum(idSpectrum,
					templateFile.getAbsolutePath(), newFilePath);
			exportAllData.put("href", xlsmFileUrl);
			// remove the progression for this process
			ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);
			return exportAllData;
		} catch (final Exception e) {
			e.printStackTrace();
			// errorMessageManager.setResponseStatusAsInternalError(response);
			// messageSource.getMessage("chemicalLibXlsErrorExport.genericError", null,
			// locale);
			return "ERROR";
		}
	}

	@RequestMapping(///
			method = RequestMethod.GET, //
			value = "/spectrum-massbank-export/{id}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE) //
	public @ResponseBody String spectrumMassBankExport(//
			final HttpServletResponse response, //
			final @PathVariable long id)//
			throws IOException {
		// init request
		String pfPublicURL = PeakForestUtils.getBundleConfElement("peakforest.url");
		String fileName = "";
		String massBankSheet = "";
		try {
			final FullScanLCSpectrum lcms = FullScanLCSpectrumManagementService.read(id);
			mapCompounds(lcms);
			massBankSheet = lcms.getMassBankSheet(pfPublicURL);
			fileName = lcms.getMassBankName();
		} catch (Exception e) {
			e.printStackTrace();
			throw new IOException("error");
		}

		response.setContentType("application/force-download");
		response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".txt\"");
		return massBankSheet;
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-msms-massbank-export/{id}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE) //
	public @ResponseBody String spectrumMSMSMassBankExport(//
			final HttpServletResponse response, //
			final @PathVariable long id)//
			throws IOException {
		// init request
		String pfPublicURL = PeakForestUtils.getBundleConfElement("peakforest.url");
		String fileName = "";
		String massBankSheet = "";
		try {
			final FragmentationLCSpectrum lcms = FragmentationLCSpectrumManagementService.read(id);
			mapCompounds(lcms);
			massBankSheet = lcms.getMassBankSheet(pfPublicURL);
			fileName = lcms.getMassBankName();
		} catch (final Exception e) {
			e.printStackTrace();
			throw new IOException("error");
		}
		response.setContentType("application/force-download");
		response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".txt\"");
		return massBankSheet;
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-gcms-massbank-export/{id}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String spectrumGCMassBankExport(//
			final HttpServletResponse response, //
			final @PathVariable long id//
	)//
			throws IOException {
		// init request
		String pfPublicURL = PeakForestUtils.getBundleConfElement("peakforest.url");
		String fileName = "";
		String massBankSheet = "";
		try {
			final FullScanGCSpectrum gcms = FullScanGCSpectrumManagementService.read(id);
			mapCompounds(gcms);
			massBankSheet = gcms.getMassBankSheet(pfPublicURL);
			fileName = gcms.getMassBankName();
		} catch (final Exception e) {
			e.printStackTrace();
			throw new IOException("error");
		}
		response.setContentType("application/force-download");
		response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".txt\"");
		return massBankSheet;
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-icms-massbank-export/{id}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String spectrumICMassBankExport(//
			final HttpServletResponse response, //
			final @PathVariable long id//
	) throws IOException {
		// init request
		String pfPublicURL = PeakForestUtils.getBundleConfElement("peakforest.url");
		String fileName = "";
		String massBankSheet = "";
		try {
			final FullScanICSpectrum gcms = FullScanICSpectrumManagementService.read(id);
			mapCompounds(gcms);
			massBankSheet = gcms.getMassBankSheet(pfPublicURL);
			fileName = gcms.getMassBankName();
		} catch (final Exception e) {
			e.printStackTrace();
			throw new IOException("error");
		}
		response.setContentType("application/force-download");
		response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".txt\"");
		return massBankSheet;
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-icmsms-massbank-export/{id}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String spectrumICMSMassBankExport(//
			final HttpServletResponse response, //
			final @PathVariable long id//
	) throws IOException {
		// init request
		String pfPublicURL = PeakForestUtils.getBundleConfElement("peakforest.url");
		String fileName = "";
		String massBankSheet = "";
		try {
			final FragmentationICSpectrum gcms = FragmentationICSpectrumManagementService.read(id);
			mapCompounds(gcms);
			massBankSheet = gcms.getMassBankSheet(pfPublicURL);
			fileName = gcms.getMassBankName();
		} catch (final Exception e) {
			e.printStackTrace();
			throw new IOException("error");
		}
		response.setContentType("application/force-download");
		response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".txt\"");
		return massBankSheet;
	}

	private void mapCompounds(final CompoundSpectrum spectrum) {
		if (spectrum.getLabel() == FullScanLCSpectrum.SPECTRUM_LABEL_REFERENCE
				&& spectrum.getListOfCompounds().size() == 1) {
			final List<Compound> listRCC = new ArrayList<Compound>();
			final GenericCompound gc = GenericCompoundManagementService
					.read(spectrum.getListOfCompounds().get(0).getId());
			if (gc != null) {
				listRCC.add(gc);
			}
			final ChemicalCompound cc = ChemicalCompoundManagementService
					.read(spectrum.getListOfCompounds().get(0).getId());
			if (cc != null) {
				listRCC.add(cc);
			}
			spectrum.setListOfCompounds(listRCC);
		}
	}

}

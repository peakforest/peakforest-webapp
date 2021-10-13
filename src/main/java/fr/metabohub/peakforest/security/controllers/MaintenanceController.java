package fr.metabohub.peakforest.security.controllers;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.services.compound.ExportService;
import fr.metabohub.peakforest.services.maintenance.CleanCurationMessageEntities;
import fr.metabohub.peakforest.services.maintenance.CleanIsolatedEntities;
import fr.metabohub.peakforest.services.maintenance.CleanScoredEntities;
import fr.metabohub.peakforest.utils.IOUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@RequestMapping("/maintenance")
@Secured("ROLE_ADMIN")
public class MaintenanceController {

	@RequestMapping(value = "/get-entity-comoundnames-stats", method = RequestMethod.GET)
	public @ResponseBody Object getCompoundNameEntityStats(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");
		// use API service like a boss
		Map<String, Object> output = new HashMap<String, Object>();
		try {
			output = CleanScoredEntities.getCompoundNamesStats();
			output.put("success", true);
		} catch (Exception e) {
			e.printStackTrace();
			output.put("success", false);
		}
		return output;
	}

	@RequestMapping(value = "/get-entity-metadata-stats", method = RequestMethod.GET)
	public @ResponseBody Object getMetadataEntityStats(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");

		// use API service like a boss
		Map<String, Object> output = new HashMap<String, Object>();
		try {
			output = CleanIsolatedEntities.getMetadataStats();
			output.put("success", true);
		} catch (Exception e) {
			e.printStackTrace();
			output.put("success", false);
		}
		return output;
	}

	@RequestMapping(value = "/get-entity-curation-message-stats", method = RequestMethod.GET)
	public @ResponseBody Object getCurationMessageEntityStats(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");

		// use API service like a boss
		Map<String, Object> output = new HashMap<String, Object>();
		try {
			output = CleanCurationMessageEntities.getCurationMessagesStats();
			output.put("success", true);
		} catch (Exception e) {
			e.printStackTrace();
			output.put("success", false);
		}
		return output;
	}

	@RequestMapping(value = "/clean-entity-comoundnames", method = RequestMethod.POST, params = { "listSizeThreshold",
			"scoreThreshold" })
	public @ResponseBody Object cleanCompoundNameEntity(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam("listSizeThreshold") int listSizeThreshold,
			@RequestParam("scoreThreshold") double scoreThreshold) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");

		// use API service like a boss
		Map<String, Object> output = new HashMap<String, Object>();
		try {
			output = CleanScoredEntities.cleanCompoundNames(listSizeThreshold, scoreThreshold);
			output.put("success", true);
			adminLog("clean entity 'Compound Names' with listSizeThreshold=" + listSizeThreshold
					+ " and scoreThreshold=" + scoreThreshold);
		} catch (Exception e) {
			e.printStackTrace();
			output.put("success", false);
		}

		return output;
	}

	@RequestMapping(value = "/clean-entities-metadata", method = RequestMethod.POST)
	public @ResponseBody Object cleanIsolatedMetadataEntities(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");

		// init request
		// use API service like a boss
		Map<String, Object> output = new HashMap<String, Object>();
		try {
			output = CleanIsolatedEntities.cleanMetadataStats();
			output.put("success", true);
			adminLog("clean entities 'Metadata' isolated");
		} catch (Exception e) {
			e.printStackTrace();
			output.put("success", false);
		}

		return output;
	}

	@RequestMapping(value = "/clean-entities-curation-message", method = RequestMethod.POST, params = { "status",
			"date" })
	public @ResponseBody Object cleanCurationMessageEntities(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam("status") int status, @RequestParam("date") String date) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");

		Map<String, Object> output = new HashMap<String, Object>();
		Date olderThan = null;

		try {
			olderThan = (new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH)).parse(date);
		} catch (ParseException e1) {
			e1.printStackTrace();
			output.put("success", false);
			return output;
		}

		// use API service like a boss
		try {
			output = CleanCurationMessageEntities.cleanCurationMessages(status, olderThan);
			output.put("success", true);
			adminLog("clean entities 'Curation Message' status =" + status + " & date < " + date);
		} catch (Exception e) {
			e.printStackTrace();
			output.put("success", false);
		}

		return output;
	}

	@RequestMapping(value = "/chemical-libary-xls-download", method = RequestMethod.POST)
	public @ResponseBody Object XlsExport(HttpServletRequest request, HttpServletResponse response, Locale locale)
			throws IOException {

		// init request
		try {
			// creation of the directory containing the uploaded files
			String clientSessionId = ProcessProgressManager.XLS_EXPORT_CHEMICAL_LIB_TOTAL_LABEL
					+ request.getSession().getId();

			// put to 0% the process progression
			ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);

			String folderPath = PeakForestUtils.getBundleConfElement("generatedFiles.prefix") + File.separator
					+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + File.separator
					+ PeakForestUtils.getBundleConfElement("generatedXlsExport.folder");
			if (!new File(folderPath).exists())
				new File(folderPath).mkdirs();

			// file to create
			String newFileName = "peakforest-chemical-lib-" + System.currentTimeMillis() + ".xls";
			String newFilePath = folderPath + File.separator + "peakforest-chemical-lib-" + System.currentTimeMillis()
					+ ".xls";

			// handed 9080 or other port
			String port = request.getServerPort() + "";
			if (port.equals("80")) {
				port = "";
			} else {
				port = ":" + port;
			}

			// url
			String xlsFileUrl = "//" + request.getServerName() + port + "/"
					+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + "/"
					+ PeakForestUtils.getBundleConfElement("generatedXlsExport.folder") + "/" + newFileName;

			// // target folder does not exist: fatal error
			// if (!new File(folderPath).exists()) {
			// System.err.println("folder " +
			// Utils.getBundleConfElement("generatedFiles.prefix")
			// + " not found, export is impossible");
			// ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);
			// // errorMessageManager.setResponseStatusAsInternalError(response);
			// return messageSource.getMessage("xlsExport.absentPrefixFolder", null, locale)
			// + " "
			// + folderPath;
			// }

			// create file
			File xlsFile = null;
			try {
				xlsFile = ExportService.exportFullChemicalLibrary(newFilePath, clientSessionId);

			} catch (PeakForestManagerException e) {
				ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);
			}
			// remove the progression for this process
			ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);

			if (xlsFile != null && xlsFile.exists())
				return xlsFileUrl;

		} catch (Exception e) {
			e.printStackTrace();
			// errorMessageManager.setResponseStatusAsInternalError(response);
			return "ERROR";// messageSource.getMessage("chemicalLibXlsErrorExport.genericError", null,
							// locale);
		}

		return null;
	}

	@RequestMapping(value = "/spectral-libary-xlsm-download", method = RequestMethod.POST)
	public @ResponseBody Object XlsmChemFileExport(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {

		// init request

		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.folder");
		String templateFileName = PeakForestUtils.getBundleConfElement("spectralDataXlsmTemplate.file");
		File templateFile = new File(templateFileDir + File.separator + templateFileName);

		try {
			// creation of the directory containing the uploaded files
			String clientSessionId = ProcessProgressManager.ZIP_DUMP_SPECTRAL_BASE + request.getSession().getId();

			// put to 0% the process progression
			ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);

			String folderPath = PeakForestUtils.getBundleConfElement("generatedFiles.prefix") + File.separator
					+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + File.separator
					+ PeakForestUtils.getBundleConfElement("generatedZipExport.folder");
			if (!new File(folderPath).exists())
				new File(folderPath).mkdirs();

			// file to create
			String newFileName = "peakforest-spectral-lib-" + System.currentTimeMillis() + "." + IOUtils.ZIP_EXT;
			String newFilePath = folderPath + File.separator + "peakforest-spectral-lib-" + System.currentTimeMillis()
					+ "." + IOUtils.ZIP_EXT;

			// handed 9080 or other port
			String port = request.getServerPort() + "";
			if (port.equals("80")) {
				port = "";
			} else {
				port = ":" + port;
			}

			// url
			String zipFileUrl = "//" + request.getServerName() + port + "/"
					+ PeakForestUtils.getBundleConfElement("generatedFiles.folder") + "/"
					+ PeakForestUtils.getBundleConfElement("generatedZipExport.folder") + "/" + newFileName;

			// // target folder does not exist: fatal error
			// if (!new File(folderPath).exists()) {
			// System.err.println("folder " +
			// PeakForestUtils.getBundleConfElement("generatedFiles.prefix")
			// + " not found, export is impossible");
			// ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);
			// // errorMessageManager.setResponseStatusAsInternalError(response);
			// return messageSource.getMessage("xlsExport.absentPrefixFolder", null, locale)
			// + " "
			// + folderPath;
			// }

			// create file
			// File xlsFile = null;

			Map<String, Object> exportResults = fr.metabohub.peakforest.services.spectrum.ExportService
					.exportAll(templateFile.getAbsolutePath(), newFilePath, clientSessionId);

			exportResults.put("href", zipFileUrl);

			// remove the progression for this process
			ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);

			// if (exportResults != null && exportResults.exists())
			return exportResults;

		} catch (Exception e) {
			e.printStackTrace();
			// errorMessageManager.setResponseStatusAsInternalError(response);
			return "ERROR";// messageSource.getMessage("chemicalLibXlsErrorExport.genericError", null,
							// locale);
		}

		// return null;
	}

	@RequestMapping(value = "/processProgressionSpectralExportXLSM", method = RequestMethod.POST)
	public @ResponseBody Integer getProcessProgression(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		Integer progression = new Integer(-1);

		String clientSessionId = ProcessProgressManager.ZIP_DUMP_SPECTRAL_BASE + request.getSession().getId();

		// get the percentage progression
		try {
			progression = ProcessProgressManager.getInstance().getProcessProgress(clientSessionId);
		} catch (Exception e) {
			e.printStackTrace();
			progression = new Integer(-1);
		}

		return progression;
	}

	// ////////////////////////////////////////////////////////////////////////
	// log => use it if when clean file

	private void adminLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}
}

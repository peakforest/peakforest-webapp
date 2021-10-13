/**
 * 
 */
package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.services.compound.ExportService;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */

@Controller
public class ExportCompoundsController {

	@Autowired
	protected MessageSource messageSource;

	// @Autowired
	// private ErrorMessageManager errorMessageManager;

	/**
	 * chemical library: exports all lines with errors in a XLS file
	 * 
	 * @param request
	 * @param response
	 * @param locale
	 * @param fileSource
	 *            name of the tmp file uploaded by the user
	 * @param listRowFailed
	 *            list of row with errors
	 * @return the download file URL or an error message
	 * @throws IOException
	 */
	@RequestMapping(value = "/chemical-libary-xls-errors", method = RequestMethod.POST)
	public @ResponseBody Object XlsExport(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam(value = "fileSource") String fileSource,
			@RequestParam(value = "listRowFailed") String listRowFailed) throws IOException {

		// string to list
		List<Integer> clientData = new ArrayList<Integer>();
		listRowFailed = listRowFailed.replaceAll("\\[", "").replaceAll("\\]", "");
		for (String id : listRowFailed.split(", ")) {
			clientData.add(Integer.parseInt(id));
		}

		try {
			// creation of the directory containing the uploaded files
			String clientSessionId = ProcessProgressManager.XLS_EXPORT_CHEMICAL_LIB_FAILED_LABEL
					+ request.getSession().getId();

			// put to 0% the process progression
			ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);

			String folderPath = Utils.getBundleConfElement("generatedFiles.prefix") + File.separator
					+ Utils.getBundleConfElement("generatedFiles.folder") + File.separator
					+ Utils.getBundleConfElement("generatedXlsExport.folder");
			if (!new File(folderPath).exists())
				new File(folderPath).mkdirs();

			// file to create
			String newFileName = fileSource;
			String newFilePath = folderPath + File.separator + fileSource;

			// uploaded file
			String fileSourcePath = Utils.getBundleConfElement("uploadedFiles.folder") + File.separator
					+ fileSource;
			File userUploadedFile = new File(fileSourcePath);

			// handed 9080 or other port
			String port = request.getServerPort() + "";
			if (port.equals("80")) {
				port = "";
			} else {
				port = ":" + port;
			}

			// url
			String xlsFileUrl = request.getScheme() + "://" + request.getServerName() + port + "/"
					+ Utils.getBundleConfElement("generatedFiles.folder") + "/"
					+ Utils.getBundleConfElement("generatedXlsExport.folder") + "/" + newFileName;

			// // target folder does not exist: fatal error
			// if (!new File(folderPath).exists()) {
			// System.err.println("folder " + Utils.getBundleConfElement("generatedFiles.prefix")
			// + " not found, export is impossible");
			// ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);
			// // errorMessageManager.setResponseStatusAsInternalError(response);
			// return messageSource.getMessage("xlsExport.absentPrefixFolder", null, locale) + " "
			// + folderPath;
			// }

			// create file
			File xlsFile = null;
			try {
				xlsFile = ExportService.exportChemicalLibraryErrors(newFilePath, userUploadedFile, clientData,
						clientSessionId);

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

}

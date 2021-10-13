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
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.spectrum.ExportService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;
import fr.metabohub.peakforest.utils.Utils;

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

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param idSpectrum
	 * @param fileName
	 * @return
	 * @throws IOException
	 */
	@RequestMapping(value = "/spectrum-xlsm-export", method = RequestMethod.POST)
	public @ResponseBody Object spectrumXlsmExport(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam(value = "id") long idSpectrum,
			@RequestParam(value = "name") String fileName) throws IOException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// String templateFileName = Utils.getBundleConfElement("spectralDataXlsmTemplate.file");

		fileName = Utils.convertHtmlGreekCharToString(fileName);
		// fileName = fileName;

		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + Utils.getBundleConfElement("spectralDataXlsmTemplate.folder");
		String templateFileName = Utils.getBundleConfElement("spectralDataXlsmTemplate.file");
		File templateFile = new File(templateFileDir + File.separator + templateFileName);

		try {
			// creation of the directory containing the uploaded files
			String clientSessionId = ProcessProgressManager.XLSM_DUMP_SPECTRAL_FILE
					+ request.getSession().getId();

			// put to 0% the process progression
			ProcessProgressManager.getInstance().updateProcessProgress(clientSessionId, 0);

			String folderPath = Utils.getBundleConfElement("generatedFiles.prefix") + File.separator
					+ Utils.getBundleConfElement("generatedFiles.folder") + File.separator
					+ Utils.getBundleConfElement("generatedXlsmExport.folder");
			if (!new File(folderPath).exists())
				new File(folderPath).mkdirs();

			// file to create
			String newFileName = fileName.replaceAll(" ", "_").replaceAll(";", "")
					+ System.currentTimeMillis() + "." + Utils.XLSM_EXT;
			String newFilePath = folderPath + File.separator + newFileName;

			// handed 9080 or other port
			String port = request.getServerPort() + "";
			if (port.equals("80")) {
				port = "";
			} else {
				port = ":" + port;
			}

			// url
			String xlsmFileUrl = request.getScheme() + "://" + request.getServerName() + port + "/"
					+ Utils.getBundleConfElement("generatedFiles.folder") + "/"
					+ Utils.getBundleConfElement("generatedXlsmExport.folder") + "/" + newFileName;
			xlsmFileUrl = xlsmFileUrl.replaceAll(";", "%3B");

			// create file
			// File zipFile = null;

			Map<String, Object> exportAllData = ExportService.exportSpectrum(idSpectrum,
					templateFile.getAbsolutePath(), newFilePath, dbName, username, password);
			exportAllData.put("href", xlsmFileUrl);
			// try {
			// // zipFile = ExportService.exportChemicalLibraryErrors(newFilePath, userUploadedFile,
			// // clientData, clientSessionId);
			//
			// } catch (PeakForestManagerException e) {
			// ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);
			// }
			// remove the progression for this process
			ProcessProgressManager.getInstance().removeProcessProgress(clientSessionId);

			// if (zipFile != null && zipFile.exists())
			return exportAllData;

		} catch (Exception e) {
			e.printStackTrace();
			// errorMessageManager.setResponseStatusAsInternalError(response);
			return "ERROR";// messageSource.getMessage("chemicalLibXlsErrorExport.genericError", null,
							// locale);
		}

		// return null;
	}

	@RequestMapping(value = "/spectrum-massbank-export/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String spectrumMassBankExport(HttpServletResponse response, @PathVariable long id)
			throws IOException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		String pfPublicURL = Utils.getBundleConfElement("peakforest.url");
		String fileName = "";
		String massBankSheet = "";

		try {
			FullScanLCSpectrum lcms = FullScanLCSpectrumManagementService.read(id, dbName, username,
					password);
			//
			if (lcms.getLabel() == FullScanLCSpectrum.SPECTRUM_LABEL_REFERENCE
					&& lcms.getListOfCompounds().size() == 1) {
				List<Compound> listRCC = new ArrayList<Compound>();
				ChemicalCompound cc = ChemicalCompoundManagementService
						.read(lcms.getListOfCompounds().get(0).getId(), dbName, username, password);
				if (cc != null) {
					listRCC.add(cc);
				} else {
					GenericCompound gc = GenericCompoundManagementService
							.read(lcms.getListOfCompounds().get(0).getId(), dbName, username, password);
					if (gc != null) {
						listRCC.add(gc);
					}
				}
				lcms.setListOfCompounds(listRCC);
			}
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

}

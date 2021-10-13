package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.MultipartFile;

import fr.metabohub.mvc.extensions.ajax.AjaxUtils;
import fr.metabohub.peakforest.model.metadata.ASampleMix;
import fr.metabohub.peakforest.model.metadata.GasSampleMix;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.services.spectrum.ImportService;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.IOUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.spectralibraries.mapper.PeakForestDataMapper;

@Controller
@RequestMapping("/upload-gcms-data-file")
public class GCMSRawDataUploadController {

	@ModelAttribute
	public String ajaxAttribute(WebRequest request, Model model) {
		model.addAttribute("ajaxRequest", AjaxUtils.isAjaxRequest(request));
		return "/uploads/upload-gcms-data-file";
	}

	@RequestMapping(method = RequestMethod.GET)
	public String fileUploadForm() {
		return "/uploads/upload-gcms-data-file";
	}

	@RequestMapping(method = RequestMethod.POST)
	@Secured("ROLE_EDITOR")
	public String processUpload(HttpServletRequest request, @RequestParam MultipartFile file,
			@RequestParam(value = "requestID", required = true) String requestID,
			@RequestParam(value = "inchikey") String compoundInChIKey, Model model)
			throws IOException, PeakForestManagerException {

		// 0 - init
		File upLoadedfile = null;
		String originalFilename = file.getOriginalFilename();
		if (originalFilename.equals("")) {
			model.addAttribute("success", false);
			model.addAttribute("error", "no_file_selected");
			return "/uploads/upload-gcms-data-file";
		}
		String tmpName = EncodeUtils.getMD5(System.currentTimeMillis() + originalFilename)
				+ originalFilename.substring(originalFilename.lastIndexOf("."), originalFilename.length());
		String clientID = ProcessProgressManager.GCMS_RAW_DATA_IMPORT_LABEL + requestID;

		// create upload dir if empty
		File uploadDir = new File(PeakForestUtils.getBundleConfElement("uploadedFiles.folder"));
		if (!uploadDir.exists())
			uploadDir.mkdirs();

		// I - copy file
		if (file.getSize() > 0) { // writing file to a directory
			upLoadedfile = new File(
					PeakForestUtils.getBundleConfElement("uploadedFiles.folder") + File.separator + tmpName);
			upLoadedfile.createNewFile();
			FileOutputStream fos = new FileOutputStream(upLoadedfile);
			fos.write(file.getBytes());
			fos.close(); // setting the value of fileUploaded variable
		}
		if (upLoadedfile != null)
			model.addAttribute("tmpFileName", upLoadedfile.getName());
		else
			model.addAttribute("tmpFileName", null);
		
		//TODO parameters for creating these variables:
		Short sampleType = PeakForestDataMapper.SAMPLE_TYPE_CHEMICAL_COMPOUND_LIBRARY;
		GasSampleMix sampleMix = new GasSampleMix();
		sampleMix.setGcmsSolvent(GasSampleMix.GC_MS_SOLVENT__HEPTANE);
		sampleMix.setDerivationMethod(GasSampleMix.DERIVATION_METHOD__OXIMATION_SYLILATION);

		//TODO getting default method from user, to complete missing data
		Map<String, Object> jsonMethodData = null;
		
		// II - import file
		importZipFile(model, upLoadedfile, compoundInChIKey, sampleType, sampleMix, jsonMethodData, clientID);

		// return "block/upload-compound-file";
		return "/uploads/upload-gcms-data-file";
	}

	/**
	 * 
	 * @param model
	 * @param upLoadedZIPFile
	 * @param compoundInChIKey
	 * @param sampleType
	 * @param sampleMixMetadata
	 * @param jsonMethodData
	 * @param clientID
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private boolean importZipFile(Model model, final File upLoadedZIPFile, final String compoundInChIKey,
			final Short sampleType, final ASampleMix sampleMixMetadata, Map<String,Object> jsonMethodData, 
			final String clientID) {

		// 0 - init
		if (upLoadedZIPFile == null)
			return false;
		// Map<String, Object> data = new HashMap<String, Object>();
		boolean allSuccess = true;
		String allErrors = "";
		String allIOerrors = "";
		String allInChIkeys = "";
		int spectraSuccess = 0;
		int spectraFail = 0;
		int spectraTotal = 0;
		List<String> spectraGCMSfail = new ArrayList<String>();
		List<Long> spectraGCMSsuccess = new ArrayList<Long>();

		// I - unzip file
		String filesDir = upLoadedZIPFile.getAbsolutePath().substring(0, upLoadedZIPFile.getAbsolutePath().lastIndexOf("."));
		File directoryOfFiles = new File(filesDir);
		if (!IOUtils.unZip(upLoadedZIPFile.getAbsolutePath(), directoryOfFiles.getAbsolutePath()))
			return false;

		try {
			ProcessProgressManager.getInstance().updateProcessProgress(clientID, 5);
		} catch (Exception e) {
			e.printStackTrace();
		}

		int filesReaded = 0;
		int filesToRead = 0;
		for (String cefFile : directoryOfFiles.list())
			if (cefFile.toUpperCase().endsWith("CEF"))
				filesToRead++;

		// II - process each file
		for (String cefFile : directoryOfFiles.list()) {
			if (cefFile.toUpperCase().endsWith("CEF")) {
				File tmpCEFFile = new File(filesDir + File.separator + cefFile);
				String tmpFolderPath = filesDir + File.separator + cefFile.replace(".cef", ".D");
				
				Map<String, Object> dataTmp = importOneFile(model, tmpFolderPath, tmpCEFFile.getAbsolutePath(), 
						compoundInChIKey, sampleType, sampleMixMetadata, jsonMethodData, "-1");
				if (dataTmp == null) {
					allSuccess = false;
				} else {

					if (dataTmp.containsKey("success") && dataTmp.get("success") instanceof Boolean) {
						if ((boolean) dataTmp.get("success")) {
							spectraSuccess += ((List<Object>) dataTmp.get("spectra-gcms-success")).size();
							spectraFail += ((List<Object>) dataTmp.get("spectra-gcms-fail")).size();

							if (!((List<String>) dataTmp.get("spectra-gcms-fail")).isEmpty())
								for (String name : (List<String>) dataTmp.get("spectra-gcms-fail"))
									spectraGCMSfail.add(cefFile + "#" + name);
							
							// ids spectrum GC-MS for "view" btn
							if (!((List<Long>) dataTmp.get("spectra-gcms-success")).isEmpty())
								spectraGCMSsuccess.addAll((List<Long>) dataTmp.get("spectra-gcms-success"));

						} else
							allSuccess = false;
					} else {
						allSuccess = false;
					}
					if (dataTmp.containsKey("error") && dataTmp.get("error") instanceof String) {
						allErrors += dataTmp.get("error");
						allSuccess = false;
					}
					if (dataTmp.containsKey("inchikey") && dataTmp.get("inchikey") instanceof String) {
						if (allInChIkeys != "")
							allInChIkeys += ",%20";
						allInChIkeys += dataTmp.get("inchikey");
					}

				}

				// update progress
				filesReaded++;
				if (filesReaded % 10 == 0)
					try {
						ProcessProgressManager.getInstance().updateProcessProgress(clientID,
								(int) (5 + (((double) filesReaded / (double) filesToRead) * (90))));
					} catch (Exception e) {
						e.printStackTrace();
					}

			}
		}

		try {
			ProcessProgressManager.getInstance().updateProcessProgress(clientID, 100);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// III - return to client
		model.addAttribute("success", allSuccess);
		if (!allIOerrors.trim().equalsIgnoreCase(""))
			model.addAttribute("spectralIOerror", "" + allIOerrors + "");
		if (!allErrors.trim().equalsIgnoreCase(""))
			model.addAttribute("error", "" + allErrors + "");
		if (!allInChIkeys.trim().equalsIgnoreCase(""))
			model.addAttribute("inchikey", "" + allInChIkeys + "");

		spectraTotal += (spectraSuccess + spectraFail);

		// nb spectrum success
		model.addAttribute("newSpectra", spectraSuccess);
		if (spectraSuccess > 0)
			model.addAttribute("newSpectraPerCent", getPerCentage(spectraSuccess, spectraTotal));
		else
			model.addAttribute("newSpectraPerCent", 0);

		// nb spectrum fail
		model.addAttribute("errorSpectra", spectraFail);
		if (spectraFail > 0)
			model.addAttribute("errorSpectraPerCent", getPerCentage(spectraFail, spectraTotal));
		else
			model.addAttribute("errorSpectraPerCent", 0);

		// errors
		if (!spectraGCMSfail.isEmpty())
			model.addAttribute("errorNames", spectraGCMSfail);

		// ids spectrum GC-MS for "view" btn
		if (!spectraGCMSsuccess.isEmpty())
			model.addAttribute("idsGCMSspectra", spectraGCMSsuccess);

		return true;
	}

	/**
	 * 
	 * @param model
	 * @param upLoadedGCMSDirPath
	 * @param upLoadedCEFFilePath
	 * @param compoundInChIKey
	 * @param sampleType
	 * @param sampleMixMetadata
	 * @param jsonMethodData
	 * @param clientID
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private Map<String, Object> importOneFile(Model model, //
			final String upLoadedGCMSDirPath, final String upLoadedCEFFilePath, //
			final String compoundInChIKey, final Short sampleType, //
			final ASampleMix sampleMixMetadata, final Map<String, Object> jsonMethodData, //
			final String clientID) {
		Map<String, Object> data = null;
		try {
			// model.addAttribute("success", true);
			data = ImportService.importGCMSData(upLoadedGCMSDirPath, upLoadedCEFFilePath,
					compoundInChIKey, sampleType, sampleMixMetadata, jsonMethodData, clientID);

			model.addAttribute("data", data);

			if (data.containsKey("success") && data.get("success") instanceof Boolean) {
				boolean isParserSuccess = (Boolean) data.get("success");
				if (!isParserSuccess) {
					model.addAttribute("success", false);
					if (data.containsKey("error") && data.get("error") instanceof String)
						model.addAttribute("error", "" + data.get("error") + "");
				} else {
					model.addAttribute("success", true);

					// nb spectrum success / fail / total
					int spectraSuccess = ((List<Object>) data.get("spectra-gcms-success")).size();
					int spectraFail = ((List<Object>) data.get("spectra-gcms-fail")).size();
					int spectraTotal = spectraSuccess + spectraFail;

					// nb spectrum success
					model.addAttribute("newSpectra", spectraSuccess);
					if (spectraSuccess > 0)
						model.addAttribute("newSpectraPerCent", getPerCentage(spectraSuccess, spectraTotal));
					else
						model.addAttribute("newSpectraPerCent", 0);

					// nb spectrum fail
					model.addAttribute("errorSpectra", spectraFail);
					if (spectraFail > 0)
						model.addAttribute("errorSpectraPerCent", getPerCentage(spectraFail, spectraTotal));
					else
						model.addAttribute("errorSpectraPerCent", 0);

					// errors
					if (!((List<String>) data.get("spectra-gcms-fail")).isEmpty())
						model.addAttribute("errorNames", (List<String>) data.get("spectra-gcms-fail"));

					// ids spectrum GC-MS for "view" btn
					model.addAttribute("idsGCMSspectra", (List<Long>) data.get("spectra-gcms-success"));

				}
			} else {
				model.addAttribute("success", false);
				if (data.containsKey("error") && data.get("error") instanceof String)
					model.addAttribute("error", "" + data.get("error") + "");
				// if (data.containsKey("compound-inchikey") && data.get("compound-inchikey")
				// instanceof
				// String)
				// model.addAttribute("inchikey", "" + data.get("compound-inchikey") + "");
			}

		} catch (Exception e) {
			// e.printStackTrace();
			model.addAttribute("success", false);
			model.addAttribute("error", "" + e.getMessage() + "");
			if (e instanceof PeakForestManagerException) {
				String message = e.getMessage();
				if (message != null)
					if (message.startsWith(PeakForestManagerException.COMPOUND_NOT_IN_DATABASE)) {
						model.addAttribute("error", "" + PeakForestManagerException.COMPOUND_NOT_IN_DATABASE + "");
						// if (data.containsKey("compound-inchikey") && data.get("compound-inchikey")
						// instanceof
						// String)
						try {
							String[] tab = message.split("___");
							model.addAttribute("inchikey", "" + tab[1] + "");
							data.put("inchikey", tab[1]);
						} catch (Exception e2) {
						}
					}
			}

		}
		spectrumLibraryLog("upload spectrum library file '" + new File(upLoadedCEFFilePath).getName() + "'");
		return data;
	}

	/**
	 * Get a percentage
	 * 
	 * @param a number
	 * @param b total
	 * @return
	 */
	private static String getPerCentage(int a, int b) {
		double c = new Double(b);
		double resultat = a / c;
		double resultatFinal = resultat * 100;
		DecimalFormat df = new DecimalFormat("###.##");
		return df.format(resultatFinal);
	}

	/**
	 * @param logMessage
	 */
	private void spectrumLibraryLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

}

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
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.ProcessProgressManager;
import fr.metabohub.peakforest.services.spectrum.ImportService;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.IOUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

@Controller
@RequestMapping("/upload-spectra-file")
public class SpectrumLibraryUploadController {

	@ModelAttribute
	public String ajaxAttribute(//
			final WebRequest request, //
			final Model model) {
		model.addAttribute("ajaxRequest", AjaxUtils.isAjaxRequest(request));
		return "/uploads/upload-spectra-file";
	}

	@RequestMapping(method = RequestMethod.GET)
	public String fileUploadForm() {
		return "/uploads/upload-spectra-file";
	}

	@RequestMapping(method = RequestMethod.POST)
	@Secured("ROLE_EDITOR")
	public String processUpload(//
			final HttpServletRequest request, //
			final @RequestParam MultipartFile file, //
			final @RequestParam(value = "requestID", required = true) String requestID, //
			final Model model//
	) throws IOException, PeakForestManagerException {
		// 0 - init
		File upLoadedfile = null;
		String originalFilename = file.getOriginalFilename();
		if (originalFilename.equals("")) {
			model.addAttribute("success", false);
			model.addAttribute("error", "no_file_selected");
			return "/uploads/upload-spectra-file";
		}
		String tmpName = EncodeUtils.getMD5(System.currentTimeMillis() + originalFilename)
				+ originalFilename.substring(originalFilename.lastIndexOf("."), originalFilename.length());
		String clientID = ProcessProgressManager.XLSX_IMPORT_CHEMICAL_LIB_LABEL + requestID;
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
		if (upLoadedfile != null) {
			model.addAttribute("tmpFileName", upLoadedfile.getName());
		} else {
			model.addAttribute("tmpFileName", null);
		}
		// II - import file
		if (upLoadedfile.getName().toUpperCase().endsWith("ZIP")) {
			// II.A - zip file
			importZipFile(model, upLoadedfile, clientID);
		} else {
			// II.B - xlsm file
			importOneFile(model, upLoadedfile, clientID);
		}
		// return "block/upload-compound-file";
		return "/uploads/upload-spectra-file";
	}

	@SuppressWarnings("unchecked")
	private boolean importZipFile(//
			final Model model, //
			final File upLoadedfile, //
			final String clientID) {
		// 0 - init
		if (upLoadedfile == null) {
			return Boolean.FALSE;
		}
		boolean allSuccess = true;
		String allErrors = "";
		String allIOerrors = "";
		String allInChIkeys = "";
		int spectraSuccess = 0;
		int spectraFail = 0;
		int spectraTotal = 0;
		List<String> spectraLCMSfail = new ArrayList<String>();
		List<String> spectraNMRfail = new ArrayList<String>();
		List<String> spectraLCMSMSfail = new ArrayList<String>();
		List<String> spectraGCMSfail = new ArrayList<String>();
		List<Long> spectraLCMSsuccess = new ArrayList<Long>();
		List<Long> spectraNMRsuccess = new ArrayList<Long>();
		List<Long> spectraLCMSMSsuccess = new ArrayList<Long>();
		List<Long> spectraGCMSsuccess = new ArrayList<Long>();
		// new 2.3
		List<String> spectraICMSfail = new ArrayList<String>();
		List<String> spectraICMSMSfail = new ArrayList<String>();
		List<Long> spectraICMSsuccess = new ArrayList<Long>();
		List<Long> spectraICMSMSsuccess = new ArrayList<Long>();
		// I - unzip file
		String filesDir = upLoadedfile.getAbsolutePath().substring(0, upLoadedfile.getAbsolutePath().lastIndexOf("."));
		File directoryOfFiles = new File(filesDir);
		if (!IOUtils.unZip(upLoadedfile.getAbsolutePath(), directoryOfFiles.getAbsolutePath())) {
			return Boolean.FALSE;
		}
		try {
			ProcessProgressManager.getInstance().updateProcessProgress(clientID, 5);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		int filesReaded = 0;
		int filesToRead = 0;
		for (final String xlsmFile : directoryOfFiles.list()) {
			if (xlsmFile.toUpperCase().endsWith("XLSM")) {
				filesToRead++;
			}
		}
		// II - process each file
		for (final String xlsmFile : directoryOfFiles.list()) {
			if (xlsmFile.toUpperCase().endsWith("XLSM")) {
				final File tmpXLSMfile = new File(filesDir + File.separator + xlsmFile);
				final Map<String, Object> dataTmp = importOneFile(model, tmpXLSMfile, "-1");
				if (dataTmp == null) {
					allSuccess = Boolean.FALSE;
				} else {
					if (dataTmp.containsKey("success") && dataTmp.get("success") instanceof Boolean) {
						if ((boolean) dataTmp.get("success")) {
							spectraSuccess += (((List<Object>) dataTmp.get("spectra-lcms-success")).size()
									+ ((List<Object>) dataTmp.get("spectra-nmr-success")).size()//
									+ ((List<Object>) dataTmp.get("spectra-lc-msms-success")).size()//
									+ ((List<Object>) dataTmp.get("spectra-gcms-success")).size()//
									+ ((List<Object>) dataTmp.get("spectra-icms-success")).size()//
									+ ((List<Object>) dataTmp.get("spectra-ic-msms-success")).size()//
							);
							spectraFail += (((List<Object>) dataTmp.get("spectra-lcms-fail")).size()//
									+ ((List<Object>) dataTmp.get("spectra-nmr-fail")).size()//
									+ ((List<Object>) dataTmp.get("spectra-lc-msms-fail")).size()//
									+ ((List<Object>) dataTmp.get("spectra-gcms-fail")).size()//
									+ ((List<Object>) dataTmp.get("spectra-icms-fail")).size()//
									+ ((List<Object>) dataTmp.get("spectra-ic-msms-fail")).size()//
							);
							//
							extractSpectraInError(dataTmp, "spectra-lcms-fail", spectraLCMSfail, xlsmFile);
							extractSpectraInError(dataTmp, "spectra-nmr-fail", spectraNMRfail, xlsmFile);
							extractSpectraInError(dataTmp, "spectra-lc-msms-fail", spectraLCMSMSfail, xlsmFile);
							extractSpectraInError(dataTmp, "spectra-gcms-fail", spectraGCMSfail, xlsmFile);
							// new 2.3
							extractSpectraInError(dataTmp, "spectra-icms-fail", spectraICMSfail, xlsmFile);
							extractSpectraInError(dataTmp, "spectra-ic-msms-fail", spectraICMSMSfail, xlsmFile);
							// ids spectrum for "view" btn
							extractSpectraInSuccess(spectraLCMSsuccess, "spectra-lcms-success", dataTmp);
							extractSpectraInSuccess(spectraLCMSMSsuccess, "spectra-lc-msms-success", dataTmp);
							extractSpectraInSuccess(spectraNMRsuccess, "spectra-nmr-success", dataTmp);
							extractSpectraInSuccess(spectraGCMSsuccess, "spectra-gcms-success", dataTmp);
							// new 2.3
							extractSpectraInSuccess(spectraICMSsuccess, "spectra-icms-success", dataTmp);
							extractSpectraInSuccess(spectraICMSMSsuccess, "spectra-ic-msms-success", dataTmp);
						} else {
							allSuccess = Boolean.FALSE;
						}
					} else {
						allSuccess = Boolean.FALSE;
					}
					if (dataTmp.containsKey("parser-exception") && dataTmp.get("parser-exception") instanceof String) {
						allIOerrors += dataTmp.get("parser-exception");
						allSuccess = false;
					}
					if (dataTmp.containsKey("error") && dataTmp.get("error") instanceof String) {
						allErrors += dataTmp.get("error");
						allSuccess = false;
					}
					if (dataTmp.containsKey("inchikey") && dataTmp.get("inchikey") instanceof String) {
						if (allInChIkeys != "") {
							allInChIkeys += ",%20";
						}
						allInChIkeys += dataTmp.get("inchikey");
					}
				}
				// update progress
				filesReaded++;
				if (filesReaded % 10 == 0) {
					try {
						ProcessProgressManager.getInstance().updateProcessProgress(clientID,
								(int) (5 + (((double) filesReaded / (double) filesToRead) * (90))));
					} catch (final Exception e) {
						e.printStackTrace();
					}
				}
			}
		}
		try {
			ProcessProgressManager.getInstance().updateProcessProgress(clientID, 100);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		// III - return to client
		model.addAttribute("success", allSuccess);
		if (!allIOerrors.trim().equalsIgnoreCase("")) {
			model.addAttribute("spectralIOerror", "" + allIOerrors + "");
		}
		if (!allErrors.trim().equalsIgnoreCase("")) {
			model.addAttribute("error", "" + allErrors + "");
		}
		if (!allInChIkeys.trim().equalsIgnoreCase("")) {
			model.addAttribute("inchikey", "" + allInChIkeys + "");
		}
		// nb spectra total
		spectraTotal += (spectraSuccess + spectraFail);
		// nb spectra success
		model.addAttribute("newSpectra", spectraSuccess);
		if (spectraSuccess > 0) {
			model.addAttribute("newSpectraPerCent", getPerCentage(spectraSuccess, spectraTotal));
		} else {
			model.addAttribute("newSpectraPerCent", 0);
		}
		// nb spectrum fail
		model.addAttribute("errorSpectra", spectraFail);
		if (spectraFail > 0) {
			model.addAttribute("errorSpectraPerCent", getPerCentage(spectraFail, spectraTotal));
		} else {
			model.addAttribute("errorSpectraPerCent", 0);
		}
		// errors
		if (!spectraNMRfail.isEmpty())
			model.addAttribute("errorNames", spectraNMRfail);
		if (!spectraLCMSfail.isEmpty())
			model.addAttribute("errorNames", spectraLCMSfail);
		if (!spectraLCMSMSfail.isEmpty())
			model.addAttribute("errorNames", spectraLCMSMSfail);
		if (!spectraGCMSfail.isEmpty())
			model.addAttribute("errorNames", spectraGCMSfail);
		// new 2.3
		if (!spectraICMSfail.isEmpty()) {
			model.addAttribute("errorNames", spectraICMSfail);
		}
		if (!spectraICMSMSfail.isEmpty()) {
			model.addAttribute("errorNames", spectraICMSMSfail);
		}
		// ids spectrum LC-MS for "view" btn
		if (!spectraLCMSsuccess.isEmpty())
			model.addAttribute("idsLCMSspectra", spectraLCMSsuccess);
		// ids spectrum LC-MSMS for "view" btn
		if (!spectraLCMSMSsuccess.isEmpty())
			model.addAttribute("idsLCMSMSspectra", spectraLCMSMSsuccess);
		// ids spectrum NMR for "view" btn
		if (!spectraNMRsuccess.isEmpty())
			model.addAttribute("idsNMRspectra", spectraNMRsuccess);
		// ids spectrum GC-MS for "view" btn
		if (!spectraGCMSsuccess.isEmpty())
			model.addAttribute("idsGCMSspectra", spectraGCMSsuccess);
		// new 2.3
		if (!spectraICMSsuccess.isEmpty())
			model.addAttribute("idsICMSspectra", spectraICMSsuccess);
		if (!spectraICMSMSsuccess.isEmpty())
			model.addAttribute("idsICMSMSspectra", spectraICMSMSsuccess);
		//
		final List<Long> idsALLspectra = new ArrayList<Long>();
		idsALLspectra.addAll(spectraLCMSsuccess);
		idsALLspectra.addAll(spectraLCMSMSsuccess);
		idsALLspectra.addAll(spectraNMRsuccess);
		idsALLspectra.addAll(spectraGCMSsuccess);
		// new 2.3
		idsALLspectra.addAll(spectraICMSsuccess);
		idsALLspectra.addAll(spectraICMSMSsuccess);
		model.addAttribute("idsALLspectra",
				idsALLspectra.toString().replaceAll("\\[", "").replaceAll("\\]", "").replaceAll(", ", "-"));
		// return
		return Boolean.TRUE;
	}

	@SuppressWarnings("unchecked")
	private void extractSpectraInSuccess(//
			final List<Long> spectraSuccess, //
			final String key, //
			final Map<String, Object> dataTmp) {
		if (!((List<Long>) dataTmp.get(key)).isEmpty())
			spectraSuccess.addAll((List<Long>) dataTmp.get(key));
	}

	@SuppressWarnings("unchecked")
	private void extractSpectraInError(//
			final Map<String, Object> dataTmp, //
			final String key, //
			final List<String> spectraFail, //
			final String xlsmFile) {
		if (!((List<String>) dataTmp.get(key)).isEmpty()) {
			for (final String name : (List<String>) dataTmp.get(key)) {
				spectraFail.add(xlsmFile + "#" + name);
			}
		}
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> importOneFile(Model model, File upLoadedfile, String clientID) {
		Map<String, Object> data = null;
		try {
			// model.addAttribute("success", true);
			data = ImportService.importSpectraDataFile(upLoadedfile.getAbsolutePath(), clientID);
			model.addAttribute("data", data);
			if (data.containsKey("success") && data.get("success") instanceof Boolean) {
				boolean isParserSuccess = (Boolean) data.get("success");
				if (!isParserSuccess) {
					model.addAttribute("success", false);
					if (data.containsKey("parser-exception") && data.get("parser-exception") instanceof String) {
						model.addAttribute("spectralIOerror", "" + data.get("parser-exception") + "");
					}
					if (data.containsKey("error") && data.get("error") instanceof String) {
						model.addAttribute("error", "" + data.get("error") + "");
					}
				} else {
					model.addAttribute("success", Boolean.TRUE);
					// nb spectrum success / fail / total
					final int spectraSuccess = ((List<Object>) data.get("spectra-lcms-success")).size()//
							+ ((List<Object>) data.get("spectra-nmr-success")).size()//
							+ ((List<Object>) data.get("spectra-lc-msms-success")).size()//
							+ ((List<Object>) data.get("spectra-gcms-success")).size()//
							+ ((List<Object>) data.get("spectra-icms-success")).size()//
							+ ((List<Object>) data.get("spectra-ic-msms-success")).size()//
					;
					final int spectraFail = ((List<Object>) data.get("spectra-lcms-fail")).size()//
							+ ((List<Object>) data.get("spectra-nmr-fail")).size()//
							+ ((List<Object>) data.get("spectra-lc-msms-fail")).size()//
							+ ((List<Object>) data.get("spectra-gcms-fail")).size()//
							+ ((List<Object>) data.get("spectra-icms-fail")).size()//
							+ ((List<Object>) data.get("spectra-ic-msms-fail")).size()//
					;
					final int spectraTotal = spectraSuccess + spectraFail;
					// nb spectrum success
					model.addAttribute("newSpectra", spectraSuccess);
					if (spectraSuccess > 0) {
						model.addAttribute("newSpectraPerCent", getPerCentage(spectraSuccess, spectraTotal));
					} else {
						model.addAttribute("newSpectraPerCent", 0);
					}
					// nb spectrum fail
					model.addAttribute("errorSpectra", spectraFail);
					if (spectraFail > 0) {
						model.addAttribute("errorSpectraPerCent", getPerCentage(spectraFail, spectraTotal));
					} else {
						model.addAttribute("errorSpectraPerCent", 0);
					}
					// errors
					if (!((List<String>) data.get("spectra-nmr-fail")).isEmpty())
						model.addAttribute("errorNames", (List<String>) data.get("spectra-nmr-fail"));
					if (!((List<String>) data.get("spectra-lcms-fail")).isEmpty())
						model.addAttribute("errorNames", (List<String>) data.get("spectra-lcms-fail"));
					if (!((List<String>) data.get("spectra-lc-msms-fail")).isEmpty())
						model.addAttribute("errorNames", (List<String>) data.get("spectra-lc-msms-fail"));
					if (!((List<String>) data.get("spectra-gcms-fail")).isEmpty())
						model.addAttribute("errorNames", (List<String>) data.get("spectra-gcms-fail"));
					// new 2.3
					if (!((List<String>) data.get("spectra-icms-fail")).isEmpty()) {
						model.addAttribute("errorNames", (List<String>) data.get("spectra-icms-fail"));
					}
					if (!((List<String>) data.get("spectra-ic-msms-fail")).isEmpty()) {
						model.addAttribute("errorNames", (List<String>) data.get("spectra-icmsms-fail"));
					}
					// ids spectrum LC-MS for "view" btn
					model.addAttribute("idsLCMSspectra", (List<Long>) data.get("spectra-lcms-success"));
					// ids spectrum LC-MSMS for "view" btn
					model.addAttribute("idsLCMSMSspectra", (List<Long>) data.get("spectra-lc-msms-success"));
					// ids spectrum NMR for "view" btn
					// if (!((List<Long>) data.get("spectra-nmr-success")).isEmpty())
					model.addAttribute("idsNMRspectra", (List<Long>) data.get("spectra-nmr-success"));
					// ids spectrum GC-MS for "view" btn
					model.addAttribute("idsGCMSspectra", (List<Long>) data.get("spectra-gcms-success"));
					// new 2.3
					model.addAttribute("idsICMSspectra", (List<Long>) data.get("spectra-icms-success"));
					model.addAttribute("idsICMSMSspectra", (List<Long>) data.get("spectra-ic-msms-success"));
					// list
					final List<Long> idsALLspectra = new ArrayList<Long>();
					idsALLspectra.addAll((List<Long>) data.get("spectra-lcms-success"));
					idsALLspectra.addAll((List<Long>) data.get("spectra-nmr-success"));
					idsALLspectra.addAll((List<Long>) data.get("spectra-lc-msms-success"));
					idsALLspectra.addAll((List<Long>) data.get("spectra-gcms-success"));
					// new 2.3
					idsALLspectra.addAll((List<Long>) data.get("spectra-icms-success"));
					idsALLspectra.addAll((List<Long>) data.get("spectra-ic-msms-success"));
					model.addAttribute("idsALLspectra",
							idsALLspectra.toString().replaceAll("\\[", "").replaceAll("\\]", "").replaceAll(", ", "-"));
				}
			} else {
				model.addAttribute("success", Boolean.FALSE);
				if (data.containsKey("error") && data.get("error") instanceof String) {
					model.addAttribute("error", "" + data.get("error") + "");
				}
			}
		} catch (final Exception e) {
			// e.printStackTrace();
			model.addAttribute("success", false);
			model.addAttribute("error", "" + e.getMessage() + "");
			if (e instanceof PeakForestManagerException) {
				final String message = e.getMessage();
				if (message != null) {
					if (message.startsWith(PeakForestManagerException.COMPOUND_NOT_IN_DATABASE)) {
						model.addAttribute("error", "" + PeakForestManagerException.COMPOUND_NOT_IN_DATABASE + "");
						try {
							final String[] tab = message.split("___");
							model.addAttribute("inchikey", "" + tab[1] + "");
							data.put("inchikey", tab[1]);
						} catch (final Exception e2) {
						}
					}
				}
			}
		}
		spectrumLibraryLog("upload spectrum library file '" + upLoadedfile.getName() + "'");
		return data;
	}

	/**
	 * Get a percentage
	 * 
	 * @param a number
	 * @param b total
	 * @return
	 */
	private static String getPerCentage(final int a, final int b) {
		double c = new Double(b);
		double resultat = a / c;
		double resultatFinal = resultat * 100;
		final DecimalFormat df = new DecimalFormat("###.##");
		return df.format(resultatFinal);
	}

	private void spectrumLibraryLog(final String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			final User user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

}

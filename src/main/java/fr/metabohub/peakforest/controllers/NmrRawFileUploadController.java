package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.io.FileUtils;
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

import fr.metabohub.externaltools.nmr.FileConverter;
import fr.metabohub.externaltools.nmr.ImageGenerator;
import fr.metabohub.mvc.extensions.ajax.AjaxUtils;
import fr.metabohub.peakforest.model.spectrum.NMR1DSpectrum;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.spectrum.NMR1DSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.NMR2DSpectrumManagementService;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.IOUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;

@Controller
@RequestMapping("/upload-nmr-raw-file")
public class NmrRawFileUploadController {

	@ModelAttribute
	public String ajaxAttribute(WebRequest request, Model model) {
		model.addAttribute("ajaxRequest", AjaxUtils.isAjaxRequest(request));
		model.addAttribute("success", false);
		return "/uploads/upload-nmr-raw-file";
	}

	@RequestMapping(method = RequestMethod.GET)
	public String fileUploadForm(Model model) {
		model.addAttribute("success", false);
		return "/uploads/upload-nmr-raw-file";
	}

	@RequestMapping(method = RequestMethod.POST)
	@Secured("ROLE_EDITOR")
	public String processUpload(HttpServletRequest request, @RequestParam MultipartFile file,
			@RequestParam(value = "spectrum_id", required = true) long spectrumID, Model model,
			@RequestParam(value = "aq_file", required = false) String aqFile,
			@RequestParam(value = "proc_file", required = false) String procFile)
			throws IOException, Exception, PeakForestManagerException {

		// // -1 - check server OK
		// if (!ProcessProgressManager.isThreadSvgMolFilesGenerationFree()) {
		// model.addAttribute("success", false);
		// model.addAttribute("error", "server_too_busy");
		// return "/uploads/upload-nmr-raw-file";
		// }

		// 0 - init
		File upLoadedfile = null;
		String originalFilename = file.getOriginalFilename();
		if (originalFilename.equals("")) {
			model.addAttribute("success", false);
			model.addAttribute("error", "no_file_selected");
			return "/uploads/upload-nmr-raw-file";
		}

		String tmpName = EncodeUtils.getMD5(System.currentTimeMillis() + originalFilename)
				+ originalFilename.substring(originalFilename.lastIndexOf("."), originalFilename.length());
		// String clientID = ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL + requestID;
		String keyRawFile = System.currentTimeMillis() + "_";
		if (spectrumID != -1)
			keyRawFile += spectrumID;
		else
			keyRawFile += "NEW";

		// create upload dir if empty
		File uploadDir = new File(Utils.getBundleConfElement("uploadedFiles.folder"));
		if (!uploadDir.exists())
			uploadDir.mkdirs();

		// get NMR raw file path
		String uploadedNmrRawFilePath = Utils.getBundleConfElement("rawFile.nmr.folder");
		if (!(new File(uploadedNmrRawFilePath)).exists()) {
			(new File(uploadedNmrRawFilePath)).mkdirs();
			if (!(new File(uploadedNmrRawFilePath)).exists())
				throw new PeakForestManagerException(
						PeakForestManagerException.MISSING_REPOSITORY + uploadedNmrRawFilePath);
		}

		// I - copy file
		if (file.getSize() > 0) { // writing file to a directory
			upLoadedfile = new File(
					Utils.getBundleConfElement("uploadedFiles.folder") + File.separator + tmpName);
			upLoadedfile.createNewFile();
			FileOutputStream fos = new FileOutputStream(upLoadedfile);
			fos.write(file.getBytes());
			fos.close(); // setting the value of fileUploaded variable
		}
		if (upLoadedfile != null)
			model.addAttribute("tmpFileName", upLoadedfile.getName());
		else
			model.addAttribute("tmpFileName", null);

		String uploadedFileCheckExt = upLoadedfile.getName().toLowerCase();
		// String ext = uploadedFileCheckExt.substring(uploadedFileCheckExt.lastIndexOf(".") + 1,
		// uploadedFileCheckExt.length());
		if (uploadedFileCheckExt.endsWith("zip")) {
			File uploadedDir = new File(
					Utils.getBundleConfElement("uploadedFiles.folder") + File.separator + keyRawFile);

			// unzip in upload dir
			IOUtils.unZip(upLoadedfile.getAbsolutePath(), uploadedDir.getAbsolutePath());

			// check and process
			return processRawNmrFile(uploadedDir, model, spectrumID, keyRawFile, aqFile, procFile);
		} else {
			model.addAttribute("success", false);
			model.addAttribute("error", "wrong_ext");
			return "/uploads/upload-nmr-raw-file";
		}

	}

	/**
	 * @param uploadedFile
	 * @param model
	 * @param idSpectrum
	 * @param keyRawFile
	 * @return
	 * @throws Exception
	 */
	private String processRawNmrFile(File uploadedFile, Model model, long idSpectrum, String keyRawFile,
			String aqFile, String procFile) throws Exception {
		// check this dir
		String[] files = uploadedFile.list();
		if (files.length == 0) {
			// error
			model.addAttribute("success", false);
			model.addAttribute("error", "empty_file");
			return "/uploads/upload-nmr-raw-file";
		} else if (files.length == 1) {
			// check if subfile ok
			File targetFile = new File(uploadedFile.getAbsolutePath() + File.separator + files[0]);
			return processRawNmrFile(targetFile, model, idSpectrum, keyRawFile, aqFile, procFile);
		} else if (files.length > 1) {
			if (aqFile != null)
				for (String s : files) {
					if (s.equalsIgnoreCase(aqFile)) {
						File targetFile = new File(uploadedFile.getAbsolutePath() + File.separator + aqFile);
						return processRawNmrFile(targetFile, model, idSpectrum, keyRawFile, aqFile, procFile);
					}
				}

			boolean hasRequiredFiles1 = false;
			boolean hasRequiredFiles2 = false;
			for (String f : files) {
				if (f.equals("pdata"))
					hasRequiredFiles1 = true;
				else if (f.equals("acqu"))
					hasRequiredFiles2 = true;
			}
			if (hasRequiredFiles1 && hasRequiredFiles2) {
				// copy to /pf/data dir
				File rawSpectraFilesDir = new File(
						Utils.getBundleConfElement("rawFile.nmr.folder") + File.separator + keyRawFile);
				FileUtils.copyDirectory(uploadedFile, rawSpectraFilesDir);
				// Files.copy(uploadedFile.toPath(), rawSpectraFilesDir.toPath(),
				// StandardCopyOption.REPLACE_EXISTING);

				// check if only one folder in pdata
				File pdataFolder = new File(Utils.getBundleConfElement("rawFile.nmr.folder") + File.separator
						+ keyRawFile + File.separator + "pdata");
				String[] procFiles = pdataFolder.list();
				if (procFiles.length == 0) {
					// error
					model.addAttribute("success", false);
					model.addAttribute("error", "empty_file");
					return "/uploads/upload-nmr-raw-file";
				} else if (procFiles.length == 1) {
					// if name different -> rename
					if (!procFiles[0].equalsIgnoreCase("1")) {
						FileUtils.copyDirectory(
								(new File(pdataFolder.getAbsolutePath() + File.separator + procFiles[0])),
								(new File(pdataFolder.getAbsolutePath() + File.separator + "1")));
					}
				} else if (procFile != null) {
					for (String s : procFiles) {
						if (s.equalsIgnoreCase(procFile)) {
							// delete 1 if exists
							if ((new File(pdataFolder.getAbsolutePath() + File.separator + "1")).exists()) {
								FileUtils.copyDirectory(
										(new File(pdataFolder.getAbsolutePath() + File.separator + "1")),
										(new File(pdataFolder.getAbsolutePath() + File.separator + "1_OLD")));
							}
							FileUtils.copyDirectory(
									(new File(pdataFolder.getAbsolutePath() + File.separator + procFiles[0])),
									(new File(pdataFolder.getAbsolutePath() + File.separator + "1")));
						}
					}
				} else {
					model.addAttribute("success", true);
					model.addAttribute("reload", false);
					// retrun LIST of FILES files
					model.addAttribute("procFiles", procFiles);
					return "/uploads/upload-nmr-raw-file";
				}
				// process data
				String basDir = Utils.getBundleConfElement("rawFile.nmr.folder") + keyRawFile;
				FileConverter.convertFile(basDir + File.separator + "pdata" + File.separator + "1",
						basDir + File.separator + "_pdata_out.txt",
						basDir + File.separator + "_pdata_param.txt");

				// generate image
				String toolURL = Utils.getBundleConfElement("nmrspectrum.getpng.service.url");
				String spectraImgDirectory = Utils.getBundleConfElement("imageFile.nmr.folder");
				ImageGenerator.getSpectrumPNGimage(toolURL, keyRawFile, spectraImgDirectory);

				// update spectrum in DB
				if (idSpectrum == -1) {
					model.addAttribute("new_raw_file_name", keyRawFile);
				} else {
					String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
					String username = Utils.getBundleConfElement("hibernate.connection.database.username");
					String password = Utils.getBundleConfElement("hibernate.connection.database.password");

					NMR1DSpectrum s = NMR1DSpectrumManagementService.read(idSpectrum, dbName, username,
							password);
					if (s != null) {
						NMR1DSpectrumManagementService.updateRawFileName(idSpectrum, keyRawFile, dbName,
								username, password);
					} else {
						NMR2DSpectrumManagementService.updateRawFileName(idSpectrum, keyRawFile, dbName,
								username, password);
					}
				}
				// return success
				model.addAttribute("success", true);
				model.addAttribute("reload", true);
				uploadRawLog("add raw spectrum data file for spectrum: " + idSpectrum);
				return "/uploads/upload-nmr-raw-file";
			} else {
				model.addAttribute("success", true);
				model.addAttribute("reload", false);
				// retrun LIST of FILES files
				model.addAttribute("files", files);
				return "/uploads/upload-nmr-raw-file";
			}
		}
		model.addAttribute("success", false);
		return "/uploads/upload-nmr-raw-file";
	}

	/**
	 * @param logMessage
	 */
	private void uploadRawLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

}

package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;

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
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.PeakForestUtils;

@Controller
@RequestMapping("/upload-compound-image-file")
public class ChemicalImageFileUploadController {

	@ModelAttribute
	public String ajaxAttribute(WebRequest request, Model model) {
		model.addAttribute("ajaxRequest", AjaxUtils.isAjaxRequest(request));
		return "/uploads/upload-compound-image-file";
	}

	@RequestMapping(method = RequestMethod.GET)
	public String fileUploadForm() {
		return "/uploads/upload-compound-image-file";
	}

	@RequestMapping(method = RequestMethod.POST)
	@Secured("ROLE_EDITOR")
	public String processUpload(HttpServletRequest request, @RequestParam MultipartFile file,
			@RequestParam(value = "inchikey", required = true) String inchikey, Model model)
			throws IOException, PeakForestManagerException {
		// 0 - init
		File upLoadedfile = null;
		String originalFilename = file.getOriginalFilename();
		if (originalFilename.equals("")) {
			model.addAttribute("success", false);
			model.addAttribute("error", "no_file_selected");
			return "/uploads/upload-compound-image-file";
		}
		String tmpName = EncodeUtils.getMD5(System.currentTimeMillis() + originalFilename)
				+ originalFilename.substring(originalFilename.lastIndexOf("."), originalFilename.length());
		// String clientID = ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL +
		// requestID;
		// create upload dir if empty
		File uploadDir = new File(PeakForestUtils.getBundleConfElement("uploadedFiles.folder"));
		if (!uploadDir.exists()) {
			uploadDir.mkdirs();
		}
		// get images path
		String uploadedImagesPath = null;
		// check ext
		if (originalFilename.trim().toLowerCase().endsWith(".svg")
				|| originalFilename.trim().toLowerCase().endsWith(".png")) {
			uploadedImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesSVG.folder");
		} else if (originalFilename.trim().toLowerCase().endsWith(".mol")) {
			uploadedImagesPath = PeakForestUtils.getBundleConfElement("compoundMolFiles.folder");
		} else {
			model.addAttribute("success", false);
			model.addAttribute("error", "wrong_ext");
			return "/uploads/upload-compound-image-file";
		}
		// check name
		if (!(originalFilename.trim().equals(inchikey + ".mol") || originalFilename.trim().equals(inchikey + ".svg")
				|| originalFilename.trim().equals(inchikey + ".png"))) {
			model.addAttribute("success", false);
			model.addAttribute("error", "wrong_name");
			return "/uploads/upload-compound-image-file";
		}
		// check repo
		if (!(new File(uploadedImagesPath)).exists()) {
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + uploadedImagesPath);
		}
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
		final String uploadedFileCheckExt = upLoadedfile.getName().toLowerCase();
		final String ext = uploadedFileCheckExt.substring(uploadedFileCheckExt.lastIndexOf(".") + 1,
				uploadedFileCheckExt.length());
		if (uploadedFileCheckExt.endsWith("mol") || uploadedFileCheckExt.endsWith("svg")
				|| uploadedFileCheckExt.endsWith("png")) {
			// get name
			File imgPath = new File(uploadedImagesPath + File.separator + inchikey + "." + ext);
			// avoid overwrite
			if (imgPath.exists()) {
				File newFileName2 = new File(
						uploadedImagesPath + File.separator + inchikey + "_" + System.currentTimeMillis() + "." + ext);
				imgPath.renameTo(newFileName2);
				chemicalLibraryLog(
						"rename chemical file from '" + imgPath.getName() + "' to '" + newFileName2.getName() + "'");
			}
			// copy file
			Files.copy(upLoadedfile.toPath(), imgPath.toPath());
			chemicalLibraryLog("upload chemical file '" + upLoadedfile.getName() + "' for " + inchikey);
			// success!
			model.addAttribute("success", true);
			return "/uploads/upload-compound-image-file";
		} else {
			model.addAttribute("success", false);
			model.addAttribute("error", "wrong_ext");
			return "/uploads/upload-compound-image-file";
		}

	}

	/**
	 * @param logMessage
	 */
	private void chemicalLibraryLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

}

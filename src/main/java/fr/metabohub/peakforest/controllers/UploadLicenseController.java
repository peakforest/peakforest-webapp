package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

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
import fr.metabohub.peakforest.services.LicenseManager;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;

@Controller
@RequestMapping("/upload-license-file")
public class UploadLicenseController {
	@ModelAttribute
	public String ajaxAttribute(WebRequest request, Model model) {
		model.addAttribute("ajaxRequest", AjaxUtils.isAjaxRequest(request));
		return "/uploads/upload-license-file";
	}

	@RequestMapping(method = RequestMethod.GET)
	public String fileUploadForm() {
		return "/uploads/upload-license-file";
	}

	@RequestMapping(method = RequestMethod.POST)
	@Secured("ROLE_ADMIN")
	public String processUpload(HttpServletRequest request, @RequestParam MultipartFile file, Model model)
			throws IOException, Exception, PeakForestManagerException {

		// // -1 - check server OK
		// if (!ProcessProgressManager.isThreadSvgMolFilesGenerationFree()) {
		// model.addAttribute("success", false);
		// model.addAttribute("error", "server_too_busy");
		// return "/uploads/upload-license-file";
		// }

		// 0 - init
		File upLoadedfile = null;
		String originalFilename = file.getOriginalFilename();
		if (originalFilename.equals("")) {
			model.addAttribute("success", false);
			model.addAttribute("error", "no_file_selected");
			return "/uploads/upload-license-file";
		}

		String tmpName = EncodeUtils.getMD5(System.currentTimeMillis() + originalFilename)
				+ originalFilename.substring(originalFilename.lastIndexOf("."), originalFilename.length());
				// String clientID = ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL + requestID;

		// create upload dir if empty
		File uploadDir = new File(Utils.getBundleConfElement("uploadedFiles.folder"));
		if (!uploadDir.exists())
			uploadDir.mkdirs();

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
		if (uploadedFileCheckExt.endsWith("license")) {

			// check and process
			LicenseManager.updateLicenseData(upLoadedfile);

			uploadRawLog("license file updated");

			model.addAttribute("success", true);
			return "/uploads/upload-license-file";
		} else {
			model.addAttribute("success", false);
			model.addAttribute("error", "wrong_ext");
			return "/uploads/upload-license-file";
		}

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

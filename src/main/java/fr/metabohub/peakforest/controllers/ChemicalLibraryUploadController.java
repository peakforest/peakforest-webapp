package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
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
import fr.metabohub.peakforest.services.compound.ImportService;
import fr.metabohub.peakforest.utils.EncodeUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

@Controller
@RequestMapping("/upload-compound-file")
public class ChemicalLibraryUploadController {

	@ModelAttribute
	public String ajaxAttribute(WebRequest request, Model model) {
		model.addAttribute("ajaxRequest", AjaxUtils.isAjaxRequest(request));
		return "/uploads/upload-compound-file";
	}

	@RequestMapping(method = RequestMethod.GET)
	public String fileUploadForm() {
		return "/uploads/upload-compound-file";
	}

	@SuppressWarnings("unchecked")
	@RequestMapping(method = RequestMethod.POST)
	@Secured("ROLE_EDITOR")
	public String processUpload(HttpServletRequest request, @RequestParam MultipartFile file,
			@RequestParam(value = "requestID", required = true) String requestID, Model model)
			throws IOException, PeakForestManagerException {
		// -1 - check server OK
		if (!ProcessProgressManager.isThreadSvgMolFilesGenerationFree()) {
			model.addAttribute("success", false);
			model.addAttribute("error", "server_too_busy");
			return "/uploads/upload-compound-file";
		}
		// 0 - init
		File upLoadedfile = null;
		String originalFilename = file.getOriginalFilename();
		if (originalFilename.equals("")) {
			model.addAttribute("success", false);
			model.addAttribute("error", "no_file_selected");
			return "/uploads/upload-compound-file";
		}
		String tmpName = EncodeUtils.getMD5(System.currentTimeMillis() + originalFilename)
				+ originalFilename.substring(originalFilename.lastIndexOf("."), originalFilename.length());
		String clientID = ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL + requestID;
		// create upload dir if empty
		File uploadDir = new File(PeakForestUtils.getBundleConfElement("uploadedFiles.folder"));
		if (!uploadDir.exists())
			uploadDir.mkdirs();
		// get images path
		String svgImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);
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
		// get current user
		User user = null;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
		}

		// II - import file
		try {
			model.addAttribute("success", true);
			Map<String, Object> data = ImportService.importChemiothequeFile(upLoadedfile.getAbsolutePath(),
					PeakForestUtils.XLS_EXT, true, clientID, svgImagesPath, null, user.getId());
			model.addAttribute("data", data);

			int totalCompounds = (Integer) data.get("numberOfCompounds");

			int newCompNb = ((List<Object>) data.get("newCompounds")).size();
			model.addAttribute("newCompounds", newCompNb);
			model.addAttribute("newCompoundsPerCent", getPerCentage(newCompNb, totalCompounds));

			int mergeCompNb = ((List<Object>) data.get("mergedCompounds")).size();
			model.addAttribute("mergedCompounds", mergeCompNb);
			model.addAttribute("mergedCompoundsPerCent", getPerCentage(mergeCompNb, totalCompounds));

			// model.addAttribute("warningCompounds", ((List<Object>)
			// data.get("warningCompounds")).size());

			int errorCompNb = ((List<Object>) data.get("errorCompounds")).size();
			model.addAttribute("errorCompounds", errorCompNb);
			model.addAttribute("errorCompoundsPerCent", getPerCentage(errorCompNb, totalCompounds));

			model.addAttribute("lineNew", data.get("lineNew"));
			model.addAttribute("lineMerge", data.get("lineMerge"));
			model.addAttribute("lineError", data.get("lineError"));
			model.addAttribute("lineTotal", data.get("lineTotal"));

			model.addAttribute("errorRows", ((List<Integer>) data.get("errorRows")));
		} catch (Exception e) {
			// e.printStackTrace();
			model.addAttribute("success", false);
			model.addAttribute("error", "" + e.getMessage() + "");
		}

		chemicalLibraryLog("upload chemical library file '" + upLoadedfile.getName() + "'");
		// return "block/upload-compound-file";
		return "/uploads/upload-compound-file";
	}

	private static String getPerCentage(int a, int b) {
		double c = new Double(b);
		double resultat = a / c;
		double resultatFinal = resultat * 100;
		DecimalFormat df = new DecimalFormat("###.##");
		return df.format(resultatFinal);
	}

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

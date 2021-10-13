package fr.metabohub.peakforest.security.controllers;

import java.io.File;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.lang.management.OperatingSystemMXBean;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.utils.SimpleFileReader;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@RequestMapping("/server")
@Secured("ROLE_ADMIN")
public class ServerController {

	// @Autowired
	// private EmailManager emailManager;

	// update profile
	// update password

	private final OperatingSystemMXBean operatingSystemMxBean = ManagementFactory.getOperatingSystemMXBean();

	@RequestMapping(value = "/get-server-stats", method = RequestMethod.POST)
	public @ResponseBody Object getServerLoad(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");
		MemoryMXBean memoryMXBean = ManagementFactory.getMemoryMXBean();
		MemoryUsage memHeap = memoryMXBean.getHeapMemoryUsage();

		Map<String, Object> output = new HashMap<String, Object>();
		output.put("cpu_load", (double) operatingSystemMxBean.getSystemLoadAverage()
				/ Runtime.getRuntime().availableProcessors());
		output.put("memory_load", ((float) memHeap.getUsed()) / ((float) memHeap.getMax()));
		return output;
	}

	@RequestMapping(value = "/call-gc", method = RequestMethod.POST)
	public @ResponseBody Object callGC(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		// Thomas B. aka "the garbage collector" function
		ManagementFactory.getMemoryMXBean().gc();
		return true;
	}

	@RequestMapping(value = "/get-disk-usage", method = RequestMethod.POST)
	public @ResponseBody Object getDiskUsage(HttpServletRequest request, HttpServletResponse response,
			Locale locale) throws IOException {
		response.setHeader("Cache-Control", "max-age=0");

		// ROOT
		File file = new File("/");
		long totalSpace = file.getTotalSpace(); // total disk space in bytes. => 100
		long usableSpace = file.getUsableSpace(); // /unallocated / free disk space in bytes.
		long freeSpace = file.getFreeSpace(); // unallocated / free disk space in bytes

		// NOT ROOT DIR
		File pf = new File("/peakforest");
		long totalSpacePF = FileUtils.sizeOfDirectory(pf);
		File generated = new File(Utils.getBundleConfElement("generatedFiles.prefix") + File.separator
				+ Utils.getBundleConfElement("generatedFiles.folder"));
		long totalSpaceGenerated = FileUtils.sizeOfDirectory(generated);
		File uploaded = new File(Utils.getBundleConfElement("uploadedFiles.folder"));
		long totalSpaceUploaded = FileUtils.sizeOfDirectory(uploaded);

		// compute
		// % not usable
		float locked = (freeSpace - usableSpace) / totalSpace;
		// % free space
		float free = (freeSpace - locked) / totalSpace;
		// % used by PF files
		float pfUsed = totalSpacePF / totalSpace;
		// % used by uploaded files
		float uploadUsed = totalSpaceUploaded / totalSpace;
		// % used by generated files
		float generateUsed = totalSpaceGenerated / totalSpace;

		// % other space
		float used = (totalSpace - (freeSpace + pfUsed + uploadUsed + generateUsed)) / totalSpace;

		Map<String, Object> output = new HashMap<String, Object>();
		// basic (abs) abs
		output.put("total_size", totalSpace);
		// stats (percent)
		output.put("locked", locked);
		output.put("free", free);
		output.put("used", used);
		output.put("pf_files", pfUsed);
		output.put("generated_files", generateUsed);
		output.put("uploaded_files", uploadUsed);
		// meuh
		return output;
	}

	@RequestMapping(value = "/clean-generated-files", method = RequestMethod.POST)
	public @ResponseBody Object cleanGeneratedFiles(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		File generated = new File(Utils.getBundleConfElement("generatedFiles.prefix") + File.separator
				+ Utils.getBundleConfElement("generatedFiles.folder"));
		for (File file : generated.listFiles()) {
			if (file.isDirectory())
				deleteFileContent(file);
			else
				file.delete();
		}
		adminLog("called 'clean generated files' function ");
		return true;
	}

	@RequestMapping(value = "/clean-uploaded-files", method = RequestMethod.POST)
	public @ResponseBody Object cleanUploadedFiles(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		File uploaded = new File(Utils.getBundleConfElement("uploadedFiles.folder"));
		for (File file : uploaded.listFiles()) {
			if (file.isDirectory())
				deleteFileContent(file);
			else
				file.delete();
		}
		adminLog("called 'clean uploaded files' function ");
		return true;
	}

	// @RequestMapping(value = "/show-log", method = RequestMethod.POST)
	@RequestMapping(value = "/show-log")
	public @ResponseBody String getLogFile(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		// adminLog("called 'clean uploaded files' function ");

		String fileName = Utils.getBundleConfElement("log.filename");
		File logFile = new File(fileName + ".log");
		try {
			return SimpleFileReader.readFile(logFile.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (IOException e) {
			// e.printStackTrace();
			return "unable to display log file content \n" + e.getMessage();
		}
	}

	@RequestMapping(value = "/log-rotation", method = RequestMethod.POST)
	public @ResponseBody Object resetLogFile(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		adminLog("called 'log rotation' function [this is the old file]");
		SpectralDatabaseLogger.resetLog();
		adminLog("called 'log rotation' function [this is the new file]");
		return true;
	}

	/**
	 * @param source
	 */
	private void deleteFileContent(File source) {
		for (File file : source.listFiles()) {
			if (file.isDirectory()) {
				deleteFileContent(file);
				file.delete();
			} else
				file.delete();
		}
	}

	// ////////////////////////////////////////////////////////////////////////
	// log => use it if when clean file
	/**
	 * @param logMessage
	 */
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

package fr.metabohub.peakforest.security.controllers;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.io.IOUtils;
import org.springframework.http.MediaType;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.session.SessionRegistryImpl;
import org.springframework.security.crypto.password.StandardPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.dao.metadata.AnalyticalMatrixMetadataDao;
import fr.metabohub.peakforest.dao.metadata.LiquidChromatographyMetadataDao;
import fr.metabohub.peakforest.dao.metadata.StandardizedMatrixMetadataDao;
import fr.metabohub.peakforest.model.metadata.AnalyticalMatrix;
import fr.metabohub.peakforest.model.metadata.StandardizedMatrix;
import fr.metabohub.peakforest.security.dao.UserDao;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;
import fr.metabohub.peakforest.services.LicenseManager;
import fr.metabohub.peakforest.services.metadata.AnalyticalMatrixManagementService;
import fr.metabohub.peakforest.services.metadata.StandardizedMatrixManagementService;
import fr.metabohub.peakforest.utils.MetExploreRequestJob;
import fr.metabohub.peakforest.utils.PeakForestApiHibernateUtils;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.ProcessBioSMvalues;
import fr.metabohub.peakforest.utils.ProcessStructuralCuration;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.UpdateMassVsLogPStats;
import fr.metabohub.peakforest.utils.UpdateSplash;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@RequestMapping("/admin")
@Secured("ROLE_ADMIN")
public class AdminController {

	@Resource(name = "sessionRegistry")
	private SessionRegistryImpl sessionRegistry;

	private static boolean structuralChecking = false;

	// ////////////////////////////////////////////////////////////////////////
	// user mgmt

	@RequestMapping(value = "/backoffice-users-access-view", method = RequestMethod.GET)
	public String showUsersAccess(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model) {
		List<User> users = new ArrayList<User>();
		try {
			users = UserDao.readAll();
		} catch (Exception e) {
			e.printStackTrace();
		}
		for (User u : users)
			u.setPassword(null);
		model.addAttribute("users", users);
		// RETURN
		return "views/backoffice-users-access-view";
	}

	@RequestMapping(value = "/listUsers", method = RequestMethod.POST)
	public @ResponseBody Object listUsers() {
		List<User> users = new ArrayList<User>();
		try {
			users = UserDao.readAll();
		} catch (Exception e) {
			e.printStackTrace();
		}
		for (User u : users)
			if (!u.getPassword().equals("ldap"))
				u.setPassword(null);

		// RETURN
		return users;
	}

	@RequestMapping(value = "/update-user", method = RequestMethod.POST, params = { "id", "right" })
	@ResponseBody
	public boolean updateUser(@RequestParam("id") long userId, @RequestParam("right") int userRight) {
		try {
			UserManagementService.changeRight(userRight, userId);
			// log
			adminLog("change user @id=" + userId + " @right=" + userRight);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/delete-user", method = RequestMethod.POST, params = { "id" })
	@ResponseBody
	public boolean deleteUser(@RequestParam("id") long userId) {
		try {
			UserManagementService.delete(userId);
			// log
			adminLog("delete user @id=" + userId + " ");
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/activate-user", method = RequestMethod.POST, params = { "id", "confirmed" })
	@ResponseBody
	public boolean activateUser(@RequestParam("id") long userId, @RequestParam("confirmed") boolean confirmed) {
		try {
			if (confirmed)
				UserManagementService.activate(userId);
			else
				UserManagementService.desactivate(userId);
			// log
			adminLog("set user @id=" + userId + " @confirmed=" + confirmed);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/activate-all-users", method = RequestMethod.POST)
	@ResponseBody
	public boolean activateAllUsers() {
		try {
			UserManagementService.activateAll();
			// log
			adminLog("activate all users");
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/activate-users", method = RequestMethod.POST, params = { "ids" })
	@ResponseBody
	public boolean activateUsers(@RequestParam("ids") List<Long> ids) {
		try {
			UserManagementService.activate(ids);
			// log
			adminLog("confirme users @ids=" + ids + " ");
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/backoffice-add-users-view", method = RequestMethod.GET)
	public String addUsersView(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) {
		List<User> users = new ArrayList<User>();
		try {
			users = UserDao.readAll();
		} catch (Exception e) {
			e.printStackTrace();
		}
		for (User u : users)
			u.setPassword(null);
		model.addAttribute("users", users);

		// RETURN
		return "views/backoffice-add-users-view";
	}

	@RequestMapping(value = "/add-new-user", method = RequestMethod.POST, params = { "email", "password" })
	@ResponseBody
	public boolean addNewUser(@RequestParam("email") String email, @RequestParam("password") String password) {
		if (!email.contains("@")) {
			return false;
		}
		try {
			if (UserManagementService.exists(email)) {
				return false;
			}
		} catch (Exception e1) {
			e1.printStackTrace();
			return false;
		}
		try {
			User newUser = new User();
			newUser.setEmail(email);
			newUser.setLogin(email);
			newUser.setConfirmed(true);
			StandardPasswordEncoder encoder = new StandardPasswordEncoder();
			newUser.setPassword(encoder.encode(password));
			UserManagementService.create(newUser);
			// log
			adminLog("add new user @email=" + email + " ");
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	// ////////////////////////////////////////////////////////////////////////
	// tools

	@RequestMapping(value = "/update-metexplore-data", method = RequestMethod.POST)
	@ResponseBody
	public boolean updateMetexploreData() {
		try {
			MetExploreRequestJob.updateMappingData();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/update-mass-vs-logp-data"//
	)

	public @ResponseBody boolean updateMassVsLogP() {
		try {
			UpdateMassVsLogPStats.updateMassVsLogPstats();
			return Boolean.TRUE;
		} catch (final Exception e) {
			SpectralDatabaseLogger.log("failed to launch admin routine 'compute Mass vs LogP', " + e.getMessage(),
					SpectralDatabaseLogger.LOG_WARNING);
			return Boolean.FALSE;
		}
	}

	@RequestMapping(value = "/process-biosm", method = RequestMethod.POST)
	@ResponseBody
	public boolean updateBioSM() {
		try {
			ProcessBioSMvalues.fetchMoreValues();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/update-splash", method = RequestMethod.POST)
	@ResponseBody
	public boolean updateSplash(@RequestParam("force") boolean force) {
		try {
			UpdateSplash.updateStats(force);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/update-chromatography-codes", method = RequestMethod.POST)
	@ResponseBody
	public boolean updateChromatographyCodes() {
		try {
			LiquidChromatographyMetadataDao.recomputeColumnsCodes();
			return Boolean.TRUE;
		} catch (final Exception e) {
			e.printStackTrace();
			return Boolean.FALSE;
		}
	}

	@RequestMapping(value = "/process-structural-curation", method = RequestMethod.POST)
	@ResponseBody
	public boolean structuralDataCuration() {
		if (structuralChecking)
			return false;
		structuralChecking = true;
		try {
			ProcessStructuralCuration.fetchMoreStructures();
			structuralChecking = false;
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			structuralChecking = false;
			return false;
		}
	}

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/flush-sessions"//
	)
	public @ResponseBody boolean fushSessionFactories() {
		try {
			PeakForestApiHibernateUtils.restart();
			return Boolean.TRUE;
		} catch (final Exception e) {
			e.printStackTrace();
			return Boolean.FALSE;
		}
	}

	// ////////////////////////////////////////////////////////////////////////
	// views

	@RequestMapping(value = "/backoffice-tools", method = RequestMethod.GET)
	public String adminToolsView(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) {
		// RETURN
		return "views/backoffice-tools";
	}

	@RequestMapping(value = "/backoffice-license", method = RequestMethod.GET)
	public String adminLicenseView(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model) {
		// RETURN
		return "views/backoffice-license";
	}

	@RequestMapping(value = "/backoffice-server-status", method = RequestMethod.GET)
	public String adminServerStatusView(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model) {
		// RETURN
		return "views/backoffice-server-status";
	}

	@RequestMapping(value = "/backoffice-users-stats", method = RequestMethod.GET)
	public String showUsersStats(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) {
		List<User> users = new ArrayList<User>();
		try {
			users = UserDao.readAll();
		} catch (Exception e) {
			e.printStackTrace();
		}
		int usersNotVal = 0;
		int usersVal = 0;
		int usersCurators = 0;
		int usersAdmin = 0;

		for (User u : users)
			if (u.isAdmin())
				usersAdmin++;
			else if (u.isCurator())
				usersCurators++;
			else if (u.isConfirmed())
				usersVal++;
			else
				usersNotVal++;

		int usersConnectAnnonymous = 0;
		int usersConnectNotVal = 0;
		int usersConnectVal = 0;
		int usersConnectCurators = 0;
		int usersConnectAdmin = 0;

		for (Object username : sessionRegistry.getAllPrincipals()) {
			if (username instanceof User) {
				if (((User) username).isAdmin())
					usersConnectAdmin++;
				else if (((User) username).isCurator())
					usersConnectCurators++;
				else if (((User) username).isConfirmed())
					usersConnectVal++;
				else
					usersConnectNotVal++;
			} else
				usersConnectAnnonymous++;
		}

		model.addAttribute("nb_users", usersVal);
		model.addAttribute("nb_users_not_val", usersNotVal);
		model.addAttribute("nb_users_curator", usersCurators);
		model.addAttribute("nb_users_admin", usersAdmin);

		model.addAttribute("nb_users_tot", usersVal + usersNotVal + usersCurators + usersAdmin);

		model.addAttribute("nb_connect_annonymous", usersConnectAnnonymous);
		model.addAttribute("nb_connect_users", usersConnectVal);
		model.addAttribute("nb_connect_users_not_val", usersConnectNotVal);
		model.addAttribute("nb_connect_users_curator", usersConnectCurators);
		model.addAttribute("nb_connect_users_admin", usersConnectAdmin);

		model.addAttribute("nb_connect_users_tot",
				usersConnectVal + usersConnectNotVal + usersConnectCurators + usersConnectAdmin);

		// RETURN
		return "views/backoffice-users-stats";
	}

	// ////////////////////////////////////////////////////////////////////////
	// license

	@RequestMapping(value = "/getLicenseData", method = RequestMethod.POST)
	public @ResponseBody Object getLicenseData() {
		Map<String, String> licenseData = new HashMap<String, String>();

		licenseData = LicenseManager.getLicenseData();

		// RETURN
		return licenseData;
	}

	@RequestMapping(value = "/set-license-email", method = RequestMethod.POST, params = { "email" })
	@ResponseBody
	public boolean setLicenseEmail(@RequestParam("email") String email) {
		if (!email.contains("@")) {
			return false;
		}
		try {
			if (!UserManagementService.exists(email)) {
				return false;
			}
		} catch (Exception e1) {
			e1.printStackTrace();
			return false;
		}
		try {
			String licenseCode = LicenseManager.getLicenseCode();
			if (licenseCode == null)
				licenseCode = "";
			LicenseManager.updateLicenseData(email, licenseCode, LicenseManager.getLicenseAuthorizations());
			// log
			adminLog("set license email @email=" + email + " ");
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/get-license-file", method = RequestMethod.GET, produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String getLicenseFile(HttpServletResponse response) throws PeakForestManagerException {
		File licenseFilePath = LicenseManager.getLicenseFile();
		try {
			response.setContentType("application/force-download");
			response.setHeader("Content-disposition", "attachment; filename=peakforest.license");
			FileReader fr = new FileReader(licenseFilePath);
			return IOUtils.toString(fr);
		} catch (IOException ex) {
			throw new RuntimeException("IOError writing file to output stream");
		}

	}

	@RequestMapping(value = "/backoffice-analytics", method = RequestMethod.GET)
	public String adminAnalyticsView(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model) {
		// load current analytics code
		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String filePath = PeakForestUtils.getBundleConfElement("analyticsFile.fullPathName");
		File f = new File(appRoot + File.separator + filePath);
		try {
			FileReader fr = new FileReader(f);
			model.addAttribute("analyticsCode", IOUtils.toString(fr));
		} catch (IOException ex) {
			model.addAttribute("analyticsCode", "ERROR - could not read file");
		}
		// RETURN
		return "views/backoffice-analytics";
	}

	@RequestMapping(value = "/set-analytics", method = RequestMethod.POST, params = { "code" })
	@ResponseBody
	public boolean setAnalyticsCode(@RequestParam("code") String code, HttpServletRequest request) {
		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String filePath = PeakForestUtils.getBundleConfElement("analyticsFile.fullPathName");
		File f = new File(appRoot + File.separator + filePath);
		try {
			PrintWriter out = new PrintWriter(f.getAbsolutePath());
			out.println(code);
			out.close();
			// log
			adminLog("set new alanytics code ");
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	// ////////////////////////////////////////////////////////////////////////
	// ontologies

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/list-ontologies", //
			produces = MediaType.APPLICATION_JSON_VALUE//
	)
	public @ResponseBody List<HashMap<String, Object>> getListOntologies() throws Exception {
		List<HashMap<String, Object>> listClean = new ArrayList<>();
		for (final AnalyticalMatrix matrix : AnalyticalMatrixMetadataDao.readAll()) {
			final HashMap<String, Object> data = new HashMap<>();
			data.put("id", matrix.getId());
			data.put("key", matrix.getKey());
			data.put("text", matrix.getNaturalLanguage());
			data.put("html", matrix.getHtmlDisplay());
			data.put("isFav", matrix.isFavourite());
			data.put("countSpectra", matrix.getSpectraNumber());
			listClean.add(data);
		}
		return listClean;
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/list-std-matrix", //
			produces = MediaType.APPLICATION_JSON_VALUE//
	)
	public @ResponseBody List<HashMap<String, Object>> getListStdMatrix() throws Exception {
		final List<HashMap<String, Object>> listClean = new ArrayList<HashMap<String, Object>>();
		for (final StandardizedMatrix matrix : StandardizedMatrixMetadataDao.readAll()) {
			final HashMap<String, Object> data = new HashMap<>();
			data.put("id", matrix.getId());
			data.put("text", matrix.getNaturalLanguage());
			data.put("html", matrix.getHtmlDisplay());
			data.put("isFav", matrix.isFavourite());
			data.put("countSpectra", matrix.getSpectraNumber());
			listClean.add(data);
		}
		return listClean;
	}

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/add-analytical-matrix", //
//			produces = MediaType.APPLICATION_JSON_VALUE// , //
			params = { "key" }//
	)
	public @ResponseBody boolean addAnalyticalMatrix(//
			final @RequestParam("key") String key, //
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final HttpSession session//
	) throws Exception {
		// log
		adminLog("add analytical matrix: " + key);
		return AnalyticalMatrixManagementService.setFavourite(key, true) > 0;
	}

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/add-std-matrix", //
//			produces = MediaType.APPLICATION_JSON_VALUE// , //
			params = { "text" }//
	)
	public @ResponseBody boolean addStdMatrix(//
			final @RequestParam("text") String text, //
			final @RequestParam("html") String html, //
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final HttpSession session//
	) throws Exception {
		// log
		// <a href="http://srm1950.nist.gov/" target="_blank">NIST plasma</a>
		adminLog("add std matrix: " + text);
		return StandardizedMatrixManagementService.setFavourite(text, html, true) > 0;
	}

	@RequestMapping(value = "/set-ontology-favourite", method = RequestMethod.POST, params = { "key", "favourite" })
	@ResponseBody
	public boolean setOntologyFavourite(@RequestParam("key") String key, @RequestParam("favourite") boolean favourite,
			HttpServletRequest request) throws Exception {
		adminLog("set ontology favourite: " + key + " " + favourite);
		return AnalyticalMatrixManagementService.setFavourite(key, favourite) > 0;
	}

	@RequestMapping(value = "/set-stdMatrix-favourite", method = RequestMethod.POST, params = { "naturalLanguage",
			"favourite" })
	@ResponseBody
	public boolean setStdMatrixFavourite(@RequestParam("naturalLanguage") String naturalLanguage,
			@RequestParam("htmlDisplay") String htmlDisplay, @RequestParam("favourite") boolean favourite,
			HttpServletRequest request) throws Exception {
		adminLog("set std matrix favourite: " + naturalLanguage + " " + favourite);
		return StandardizedMatrixManagementService.setFavourite(naturalLanguage, htmlDisplay, favourite) > 0;
	}

	// ////////////////////////////////////////////////////////////////////////
	// log

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

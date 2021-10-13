package fr.metabohub.peakforest.controllers;

import java.text.SimpleDateFormat;
//import java.io.IOException;
import java.util.Locale;

//import javax.mail.MessagingException;
//import javax.mail.internet.AddressException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
//import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class ModalController {

	@Autowired
	protected MessageSource messageSource;

	// @Autowired
	// private ErrorMessageManager errorMessageManager;
	//
	// @Autowired
	// private EmailManager emailManager;

	/**
	 * Register: add a new user (not admin, not confirmed)
	 * 
	 * @param request
	 * @param response
	 * @param locale
	 * @param email
	 * @param password
	 * @return
	 */
	@RequestMapping(value = "/login-modal", method = RequestMethod.GET)
	public String loginOrRegisterModal(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		return "modal/login-modal";
	}

	@RequestMapping(value = "/about-peakforest", method = RequestMethod.GET)
	public String aboutPF(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model) {

		//
		String buildVersion = Utils.getBundleConfElement("build.version");
		String buildTimestamp = Utils.getBundleConfElement("build.timestamp");
		String buildSHA1 = Utils.getBundleConfElement("build.sha1");

		String date = "" + buildTimestamp;
		try {
			Long timeStamp = Long.parseLong(buildTimestamp);
			java.util.Date time = new java.util.Date((long) timeStamp);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd - HH:mm");
			date = dateFormat.format(time);
		} catch (Exception e) {
		}
		if (buildSHA1 != null && buildSHA1.length() > 7)
			buildSHA1 = buildSHA1.substring(0, 8);

		model.addAttribute("buildVersion", buildVersion);
		model.addAttribute("buildTimestamp", date);
		model.addAttribute("buildSHA1", buildSHA1);

		// if (locale.truc == FR) return FR
		return "modal/aboutPF.en";
	}

	@RequestMapping(value = "/aboutPF", method = RequestMethod.GET)
	public String aboutPFCrossREf(HttpServletRequest request, HttpServletResponse response, Locale locale,
			ModelMap model) {
		request.setAttribute("showModal", true);
		request.setAttribute("showModalID", "about-peakforest");
		return "home";
	}

	@RequestMapping(value = "/my-peakforest", method = RequestMethod.GET)
	public String myPF(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) {

		// if (locale.truc == FR) return FR
		return "modal/myPF.en";
	}

	@RequestMapping(value = "/myPeakforest", method = RequestMethod.GET)
	public String myPFCrossREf(HttpServletRequest request, HttpServletResponse response, Locale locale,
			ModelMap model) {
		request.setAttribute("showModal", true);
		request.setAttribute("showModalID", "my-peakforest");
		return "home";
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/settings-modal", method = RequestMethod.GET)
	public String settingsModal(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model) {
		User user = null;
		boolean isLDAP = false;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			if (!user.getLogin().contains("@"))
				isLDAP = true;
			user.setPassword(null);
		}
		model.addAttribute("user", user);
		model.addAttribute("mainTechnology", "lcms");
			switch (user.getMainTechnology()) {
			case  User.PREF_GCMS:
				model.addAttribute("mainTechnology", "gcms");
				break;
			case  User.PREF_LCMSMS:
				model.addAttribute("mainTechnology", "lcmsms");
				break;
			case  User.PREF_NMR:
				model.addAttribute("mainTechnology", "nmr");
				break;
			case  User.PREF_LCMS:
			default:
				model.addAttribute("mainTechnology", "lcms");
				break;
			}
		model.addAttribute("token", user.getToken());
		model.addAttribute("ldap", isLDAP);
		return "modal/settings-modal";
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @return
	 */
	@RequestMapping(value = "/search-advanced-modal", method = RequestMethod.GET)
	public String advancedSearchModal(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		return "modal/search-advanced-modal";
	}

	@RequestMapping(value = "/peakmatching-nmr-query-modal", method = RequestMethod.GET)
	public String peakMatchingNMRquertModal(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		response.setHeader("Cache-Control", "max-age=0");
		return "modal/peakmatching-nmr-query-modal";
	}

	@RequestMapping(value = "/peakmatching-lcms-query-modal", method = RequestMethod.GET)
	public String peakMatchingLCMSquertModal(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		response.setHeader("Cache-Control", "max-age=0");
		return "modal/peakmatching-lcms-query-modal";
	}
}

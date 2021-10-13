package fr.metabohub.peakforest.security.controllers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.mail.MessagingException;
import javax.mail.internet.AddressException;
//import javax.mail.MessagingException;
//import javax.mail.internet.AddressException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
//import org.springframework.web.bind.annotation.RequestParam;
//import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.StandardPasswordEncoder;
//import org.springframework.security.crypto.password.StandardPasswordEncoder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.view.RedirectView;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;
import fr.metabohub.peakforest.utils.EmailManager;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

@Controller
public class LoginController {

	@Autowired
	protected MessageSource messageSource;

	// @Autowired
	// private ErrorMessageManager errorMessageManager;
	//
	@Autowired
	private EmailManager emailManager;

	@RequestMapping(value = "/register", method = RequestMethod.POST, params = { "email", "password", "birthday" })
	public @ResponseBody RedirectView registerBot(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam("email") String email, @RequestParam("password") String password,
			@RequestParam("birthday") String birthday) {

		SpectralDatabaseLogger.log("bot try to request an account", SpectralDatabaseLogger.LOG_WARNING);
		return new RedirectView("registerfailed");
	}

	@RequestMapping(value = "/register", method = RequestMethod.POST, params = { "email", "password" })
	public @ResponseBody RedirectView register(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@RequestParam("email") String email, @RequestParam("password") String password) {

		// init
		if (!email.contains("@")) {
			// String errorCause =
			// messageSource.getMessage("loginRegister.error.userAlreadyExists", null,
			// locale);
			// errorCause += ": " + email;
			String errorCause = "ERROR_EMAIL_NEEDED"; // TODO
			request.getSession().setAttribute("registerError", "true");
			request.getSession().setAttribute("registerErrorCause", errorCause);
			return new RedirectView("registerfailed");
		}
		try {
			if (!UserManagementService.exists(email)) {
				emailManager.sendAccountCreationEmail(locale, email);
				User newUser = new User();
				newUser.setEmail(email);
				newUser.setLogin(email);// TODO change
				StandardPasswordEncoder encoder = new StandardPasswordEncoder();
				newUser.setPassword(encoder.encode(password));
				UserManagementService.create(newUser);
				List<GrantedAuthority> grantedAuthorities = new ArrayList<GrantedAuthority>();
				grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_USER"));
				// after successful registration, log the user
				newUser.setPassword(null);
				Authentication auth = new UsernamePasswordAuthenticationToken(newUser, null, grantedAuthorities);
				SecurityContextHolder.getContext().setAuthentication(auth);

				return new RedirectView("home");
			} else {
				// String errorCause =
				// messageSource.getMessage("loginRegister.error.userAlreadyExists", null,
				// locale);
				// errorCause += ": " + email;
				String errorCause = "ERROR_USER_EXIST"; // TODO
				request.getSession().setAttribute("registerError", "true");
				request.getSession().setAttribute("registerErrorCause", errorCause);
				return new RedirectView("registerfailed");
				// return new RedirectView("../home");
			}
		} catch (Exception e) {
			e.printStackTrace();
			// errorMessageManager.setResponseStatusAsInternalError(response);
		}
		SpectralDatabaseLogger.log("user '" + email + "' failed to request an account",
				SpectralDatabaseLogger.LOG_WARNING);
		return new RedirectView("registerfailed");
		// return new RedirectView("../home");
	}

	@RequestMapping(value = { "/login" }, method = RequestMethod.GET)
	public String login(HttpServletRequest request, HttpServletResponse response) {
		request.setAttribute("loginError", true);
		request.setAttribute("loginErrorCause", "");
		return "home";
		// return "login";
	}

	@RequestMapping(value = "/loginfailed", method = RequestMethod.GET)
	public String loginerror(HttpServletRequest request, HttpServletResponse response, Locale locale, ModelMap model) {
		// model.addAttribute("error", true);
		// model.addAttribute("errorType", "LOGIN_ERROR");
		Object lastSecurityException = request.getSession().getAttribute("SPRING_SECURITY_LAST_EXCEPTION");
		String errorCause = "";

		if (lastSecurityException != null && lastSecurityException instanceof BadCredentialsException) {
			// errorCause = messageSource.getMessage("loginRegister.error.badCredentials",
			// null, locale);
			errorCause = "TODO_SET_ERROR_MESSAGE"; // TODO
		} else if (lastSecurityException != null && lastSecurityException instanceof UsernameNotFoundException) {
			// errorCause = messageSource.getMessage("loginRegister.error.unkownUser", null,
			// locale);
			errorCause = "TODO_SET_ERROR_MESSAGE"; // TODO
			errorCause += ": " + ((Throwable) lastSecurityException).getMessage();
		}
		// model.addAttribute("errorCause", errorCause);
		request.setAttribute("loginError", true);
		request.setAttribute("loginErrorCause", errorCause);
		return "home";
	}

	@RequestMapping(value = "/logout", method = RequestMethod.GET)
	public String logout(HttpServletRequest request, HttpServletResponse response) {
		// if a user is connected, log him/her out programmaticaly
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		if (auth != null) {
			new SecurityContextLogoutHandler().logout(request, response, auth);
		}
		return "home";
	}

	@RequestMapping(value = { "/registerfailed", "/registerfailed/" }, method = RequestMethod.GET)
	public String registerfailed(HttpServletRequest request, HttpServletResponse response) {
		if (request.getSession().getAttribute("registerErrorCause") != null) {
			String registerErrorCause = request.getSession().getAttribute("registerErrorCause").toString();
			if (registerErrorCause.trim().length() > 0) {
				request.setAttribute("registerError", true);
				request.setAttribute("registerErrorCause", registerErrorCause);
			}
		}
		return "home";
	}

	@RequestMapping(value = "/reset-password", method = RequestMethod.POST)
	public @ResponseBody boolean changePasswordByUser(HttpServletRequest request, HttpServletResponse response,
			@RequestParam(value = "email") String email, Locale locale) throws IOException {

		String newPassword = (int) (Math.random() * 10000000) + "";
		StandardPasswordEncoder encoder = new StandardPasswordEncoder();
		String encodedNewPassword = encoder.encode(newPassword);
		// Try to reset password with a new
		User user = null;
		try {
			if (!email.contains("@") || !UserManagementService.exists(email)) {
				// errorMessageManager.setResponseStatusAsInternalError(response);
				return false;
			} else {
				user = UserManagementService.read(email);
				UserManagementService.resetPassword(user.getId(), encodedNewPassword);
			}
		} catch (Exception e) {
			return false;
		}
		// Send Email with the new password
		try {
			if (user != null)
				emailManager.sendPasswordResetEmail(locale, email, newPassword);
		} catch (AddressException e) {
			return false;
		} catch (MessagingException e) {
			return false;
		}
		SpectralDatabaseLogger.log("user '" + email + "' request a new password", SpectralDatabaseLogger.LOG_WARNING);
		return true;
	}

}

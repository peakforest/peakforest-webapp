package fr.metabohub.peakforest.security.controllers;

import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@RequestMapping("/user")
@Secured("ROLE_USER")
public class UserController {

	@RequestMapping(value = "/update-settings", method = RequestMethod.POST, params = { "password" })
	@ResponseBody
	public boolean updateSettings(@RequestParam("password") String userPassword,
			@RequestParam("mainTechnology") char userMainTechnology) {
		try {
			User user = null;
			if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
				user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
				user.setPassword(null);
			}
			if (!user.getLogin().contains("@"))
				userPassword = null;
			// database
			UserManagementService.update(user.getId(), user.getLogin(), user.getEmail(), userPassword,
					userMainTechnology);
			// update gui
			((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal())
					.setMainTechnology(userMainTechnology);

			// log
			SpectralDatabaseLogger.log("user '" + user.getLogin() + "'changed his settings",
					SpectralDatabaseLogger.LOG_WARNING);

			// update pref
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@RequestMapping(value = "/renew-token", method = RequestMethod.POST)
	@ResponseBody
	public String renewToken() {
		try {
			User user = null;
			if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
				user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
				user.setPassword(null);
			}
			// database
			String token = UserManagementService.renewToken(user.getId());
			// update gui
			((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal()).setToken(token);
			// log
			SpectralDatabaseLogger.log("user '" + user.getLogin() + "'changed his token",
					SpectralDatabaseLogger.LOG_INFO);
			// update pref
			return token;
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}

}

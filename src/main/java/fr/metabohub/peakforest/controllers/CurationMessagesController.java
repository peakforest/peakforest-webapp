package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.dao.CurationMessageDao;
import fr.metabohub.peakforest.model.CurationMessage;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.spectrum.Spectrum;
import fr.metabohub.peakforest.security.dao.UserDao;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.CurationMessageManagementService;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestPruneUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@Secured("ROLE_CURATOR")
public class CurationMessagesController {

	@RequestMapping(value = "/list-curation-messages/{filter}/{limit}", method = RequestMethod.GET)
	public @ResponseBody Object curationMessageList(@PathVariable String filter, @PathVariable int limit)
			throws PeakForestManagerException {
		return curationMessageList(filter, limit, null);
	}

	@RequestMapping(value = "/list-curation-messages/{filter}/{limit}/{query}", method = RequestMethod.GET)
	public @ResponseBody Object curationMessageList(@PathVariable String filter, @PathVariable int limit,
			@PathVariable String query) throws PeakForestManagerException {
		// init data
		List<CurationMessage> data = null;

		// load data
		try {
			if (filter.equalsIgnoreCase("compound")) {
				data = CurationMessageDao.list(query, Compound.class, limit);
			} else if (filter.equalsIgnoreCase("spectrum")) {
				data = CurationMessageDao.list(query, Spectrum.class, limit);
			} else {
				data = CurationMessageDao.list(query, null, limit);
			}
		} catch (final Exception e) {
			e.printStackTrace();
		}
		data = PeakForestPruneUtils.pruneCM(data);

		return data;
	}

	@RequestMapping(value = "/update-curation-message", method = RequestMethod.POST, params = { "id", "status" })
	public @ResponseBody boolean updateCurationMessage(@RequestParam("id") long id, @RequestParam("status") int status)
			throws PeakForestManagerException {
		// delete
		try {
			CurationMessageManagementService.updateStatus(id, status);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// log
		citationLog("update curation message @id=" + id + "; @status=" + status);

		return true;
	}

	@RequestMapping(value = "/delete-curation-message", method = RequestMethod.POST, params = { "id" })
	public @ResponseBody boolean deleteCurationMessage(@RequestParam("id") long id) throws PeakForestManagerException {
		// delete
		try {
			List<Long> listOfCurationMessageIds = new ArrayList<Long>();
			listOfCurationMessageIds.add(id);
			CurationMessageManagementService.delete(listOfCurationMessageIds);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// log
		citationLog("delete curation message @id=" + id + ";");

		return true;
	}

	@RequestMapping(value = "/list-all-users", method = RequestMethod.POST)
	public @ResponseBody Map<String, String> listUsers() {
		List<User> users = new ArrayList<User>();
		Map<String, String> usersMap = new HashMap<String, String>();
		try {
			users = UserDao.readAll();
		} catch (Exception e) {
			e.printStackTrace();
		}
		for (User u : users)
			usersMap.put(u.getId() + "", u.getLogin());

		// RETURN
		return usersMap;
	}

	private void citationLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}
}

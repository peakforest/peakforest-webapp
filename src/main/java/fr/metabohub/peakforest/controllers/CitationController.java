package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.model.AbstractDatasetObject;
import fr.metabohub.peakforest.model.compound.Citation;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.CitationManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@Secured("ROLE_CURATOR")
public class CitationController {

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param id
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/list-citations/{limit}", method = RequestMethod.GET)
	public @ResponseBody Object citationList(@PathVariable int limit) throws PeakForestManagerException {
		return citationList(limit, null);
	}

	@RequestMapping(value = "/list-citations/{limit}/{query}", method = RequestMethod.GET)
	public @ResponseBody Object citationList(@PathVariable int limit, @PathVariable String query)
			throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// init data
		List<Citation> data = null;

		// load data

		try {
			data = CitationManagementService.list(query, limit, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		data = Utils.pruneCitation(data);

		return data;
	}

	@RequestMapping(value = "/update-citation", method = RequestMethod.POST, params = { "id", "status" })
	public @ResponseBody boolean updateCitation(@RequestParam("id") long id,
			@RequestParam("status") int status) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// delete
		try {
			CitationManagementService.updateStatus(id, status, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		citationLog("update citation @id=" + id + " @status=" + status);
		return true;
	}

	@RequestMapping(value = "/delete-citation", method = RequestMethod.POST, params = { "id" })
	public @ResponseBody boolean deleteCitation(@RequestParam("id") long id)
			throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// delete
		try {
			List<Long> listOfCitationIds = new ArrayList<Long>();
			listOfCitationIds.add(id);
			CitationManagementService.delete(listOfCitationIds, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		citationLog("delete citation @id=" + id + "");
		return true;
	}

	// /**
	// * List all users in the database
	// *
	// * @return
	// */
	// @RequestMapping(value = "/list-all-users", method = RequestMethod.POST)
	// public @ResponseBody
	// Map<String, String> listUsers() {
	// List<User> users = new ArrayList<User>();
	// Map<String, String> usersMap = new HashMap<String, String>();
	// try {
	// users = UserManagementService.readAll();
	// } catch (Exception e) {
	// e.printStackTrace();
	// }
	// for (User u : users)
	// usersMap.put(u.getId() + "", u.getLogin());
	//
	// // RETURN
	// return usersMap;
	// }

	///////////////////////////////////////////////////////////////////////////

	@RequestMapping(value = "/list-cpd-names-to-convert/{limit}", method = RequestMethod.GET)
	public @ResponseBody Object compoundsNameToConvertList(@PathVariable int limit)
			throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// init data
		List<ReferenceChemicalCompound> dataRawCC = new ArrayList<>();
		List<Long> listCpdIdCC = new ArrayList<>();
		List<ReferenceChemicalCompound> dataRawGC = new ArrayList<>();
		List<Long> listCpdIdGC = new ArrayList<>();

		List<AbstractDatasetObject> data = new ArrayList<>();

		// load data

		try {
			dataRawGC.addAll(GenericCompoundManagementService.readAllWithNames(dbName, username, password));
			dataRawCC.addAll(ChemicalCompoundManagementService.readAllWithNames(dbName, username, password));
		} catch (Exception e) {
			e.printStackTrace();
		}

		// filter
		int count = 0;
		for (ReferenceChemicalCompound rcc : dataRawCC) {
			if (rcc.containPotentialCasInCommonNames() || rcc.containPotentialIupacInCommonNames()) {
				listCpdIdCC.add(rcc.getId());
				count++;
				if (count >= limit)
					break;
			}
		}
		if (count < limit)
			for (ReferenceChemicalCompound rcc : dataRawGC) {
				if (rcc.containPotentialCasInCommonNames() || rcc.containPotentialIupacInCommonNames()) {
					listCpdIdGC.add(rcc.getId());
					count++;
					if (count >= limit)
						break;
				}
			}

		// load from DB
		try {
			if (!listCpdIdGC.isEmpty())
				data.addAll(GenericCompoundManagementService.read(listCpdIdGC, dbName, username, password));
			if (!listCpdIdCC.isEmpty())
				data.addAll(ChemicalCompoundManagementService.read(listCpdIdCC, dbName, username, password));
		} catch (Exception e) {
			e.printStackTrace();
		}

		// prune
		data = Utils.prune(data);

		return data;
	}

	///////////////////////////////////////////////////////////////////////////

	/**
	 * @param logMessage
	 */
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

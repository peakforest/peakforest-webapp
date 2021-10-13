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

import fr.metabohub.peakforest.dao.compound.CitationDao;
import fr.metabohub.peakforest.model.AbstractDatasetObject;
import fr.metabohub.peakforest.model.compound.Citation;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.CitationManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestPruneUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
@Secured("ROLE_CURATOR")
public class CitationController {

	@RequestMapping(value = "/list-citations/{limit}", method = RequestMethod.GET)
	public @ResponseBody Object citationList(@PathVariable int limit) throws PeakForestManagerException {
		return citationList(limit, null);
	}

	@RequestMapping(value = "/list-citations/{limit}/{query}", method = RequestMethod.GET)
	public @ResponseBody Object citationList(@PathVariable int limit, @PathVariable String query)
			throws PeakForestManagerException {
		// init data
		List<Citation> data = null;

		// load data

		try {
			data = CitationDao.list(query, limit);
		} catch (Exception e) {
			e.printStackTrace();
		}

		data = PeakForestPruneUtils.pruneCitation(data);

		return data;
	}

	@RequestMapping(value = "/update-citation", method = RequestMethod.POST, params = { "id", "status" })
	public @ResponseBody boolean updateCitation(@RequestParam("id") long id, @RequestParam("status") int status)
			throws PeakForestManagerException {
		// delete
		try {
			CitationManagementService.updateStatus(id, status);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		citationLog("update citation @id=" + id + " @status=" + status);
		return true;
	}

	@RequestMapping(value = "/delete-citation", method = RequestMethod.POST, params = { "id" })
	public @ResponseBody boolean deleteCitation(@RequestParam("id") long id) throws PeakForestManagerException {
		// delete
		try {
			List<Long> listOfCitationIds = new ArrayList<Long>();
			listOfCitationIds.add(id);
			CitationManagementService.delete(listOfCitationIds);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		citationLog("delete citation @id=" + id + "");
		return true;
	}

	@RequestMapping(value = "/list-cpd-names-to-convert/{limit}", method = RequestMethod.GET)
	public @ResponseBody Object compoundsNameToConvertList(@PathVariable int limit) throws PeakForestManagerException {
		// init data
		List<ReferenceChemicalCompound> dataRawCC = new ArrayList<>();
		List<Long> listCpdIdCC = new ArrayList<>();
		List<ReferenceChemicalCompound> dataRawGC = new ArrayList<>();
		List<Long> listCpdIdGC = new ArrayList<>();
		List<AbstractDatasetObject> data = new ArrayList<>();
		// load data
		try {
			dataRawGC.addAll(GenericCompoundManagementService.readAllWithNames());
			dataRawCC.addAll(ChemicalCompoundManagementService.readAllWithNames());
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
		if (count < limit) {
			for (ReferenceChemicalCompound rcc : dataRawGC) {
				if (rcc.containPotentialCasInCommonNames() || rcc.containPotentialIupacInCommonNames()) {
					listCpdIdGC.add(rcc.getId());
					count++;
					if (count >= limit)
						break;
				}
			}
		}
		// load from DB
		try {
			if (!listCpdIdGC.isEmpty())
				data.addAll(GenericCompoundManagementService.read(listCpdIdGC));
			if (!listCpdIdCC.isEmpty())
				data.addAll(ChemicalCompoundManagementService.read(listCpdIdCC));
		} catch (Exception e) {
			e.printStackTrace();
		}
		// prune
		data = PeakForestPruneUtils.prune(data);
		// reurn
		return data;
	}

	///////////////////////////////////////////////////////////////////////////

	private void citationLog(final String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}
}

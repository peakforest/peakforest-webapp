package fr.metabohub.peakforest.controllers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jsoup.Jsoup;
import org.jsoup.safety.Whitelist;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import fr.metabohub.chemicallibraries.mapper.ChemicalCompoundMapper;
import fr.metabohub.externalbanks.rest.EbiPubClient;
import fr.metabohub.peakforest.model.CurationMessage;
import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.Citation;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.CompoundName;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.CurationMessageManagementService;
import fr.metabohub.peakforest.services.SearchService;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.CitationManagementService;
import fr.metabohub.peakforest.services.compound.CompoundNameManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.compound.StructuralCompoundManagementService;
import fr.metabohub.peakforest.services.threads.CompoundsImagesAndMolFilesGeneratorThread;
import fr.metabohub.peakforest.utils.CompoundNameComparator;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
// @Configuration
// @EnableWebSecurity
// @EnableGlobalMethodSecurity(securedEnabled = true)
// @EnableGlobalMethodSecurity(prePostEnabled = true)
public class CompoundsController {

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param id
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/print-compound-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundPrint(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// init var

		// load data in model
		loadCompoundData(type, model, refCompound, request);

		// RETURN
		return "modal/print-compound-modal";
	}

	/**
	 * @param type
	 * @param model
	 * @param refCompound
	 * @throws PeakForestManagerException
	 */
	private void loadCompoundData(String type, Model model, StructureChemicalCompound refCompound,
			HttpServletRequest request) throws PeakForestManagerException {
		String formula = refCompound.getFormula();
		Pattern pattern = Pattern.compile("(\\d)");
		Matcher tagmatch = pattern.matcher(formula);
		List<String> listOfNumber = new ArrayList<String>();
		while (tagmatch.find())
			if (!listOfNumber.contains(tagmatch.group()))
				listOfNumber.add(tagmatch.group());

		for (String num : listOfNumber)
			formula = formula.replaceAll(num, "<sub>" + num + "</sub>");
		formula = formula.replaceAll("</sub><sub>", "");

		// sort names
		// Sorting
		List<CompoundName> listOfNames = refCompound.getListOfCompoundNames();
		Collections.sort(listOfNames, new CompoundNameComparator());

		// prevent XSS
		for (CompoundName cn : listOfNames) {
			cn.setName(Jsoup.clean(cn.getName(), Whitelist.basic()));
			cn.setName(cn.getName().replaceAll("α", "&alpha;").replaceAll("β", "&beta;")
					.replaceAll("γ", "&gamma;").replaceAll("ω", "&omega;"));
		}

		for (CompoundName cn : listOfNames)
			cn.setScore(Utils.round(cn.getScore(), 1));

		// BUILD MODEL

		model.addAttribute("id", refCompound.getId());

		model.addAttribute("compoundNames", listOfNames);

		model.addAttribute("type", type);
		model.addAttribute("inchikey", refCompound.getInChIKey());
		model.addAttribute("logP", refCompound.getLogP());
		if (refCompound.getIsBioactive() != null) {
			model.addAttribute("isBioactive", true);
			model.addAttribute("isBioactiveV", refCompound.getIsBioactive());
		}
		if (refCompound instanceof ChemicalCompound)
			model.addAttribute("inchi", ((ChemicalCompound) refCompound).getInChI());
		model.addAttribute("exactMass", Utils.round(refCompound.getExactMass(), 7));
		model.addAttribute("molWeight", Utils.round(refCompound.getMolWeight(), 7));
		model.addAttribute("formula", formula);
		model.addAttribute("pfID", refCompound.getPeakForestID());
		model.addAttribute("smiles", refCompound.getCanSmiles());
		// model.addAttribute("mol", refCompound.getMolFile());

		// MOL
		String inchikey = refCompound.getInChIKey();
		// get mol path
		String molFileRepPath = Utils.getBundleConfElement("compoundMolFiles.folder");
		if (!(new File(molFileRepPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);

		// check exists
		File molFilePath = new File(molFileRepPath + File.separator + inchikey + ".mol");
		// model.addAttribute("mol_ready", false);
		if (!molFilePath.exists()) {
			// display not yet available
			model.addAttribute("mol_ready", false);
			// create
			ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
			compoundsList.add(refCompound);
			CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(
					compoundsList, null, molFileRepPath, true);
			ExecutorService executor = Executors.newCachedThreadPool();
			executor.submit(ci);
		} else {
			// set as available
			model.addAttribute("mol_ready", true);
			// read
			String mol = "";
			BufferedReader in;
			try {
				in = new BufferedReader(new FileReader(molFilePath));
				String line;
				while ((line = in.readLine()) != null) {
					mol += line + "\n";
				}
				in.close();
			} catch (Exception e) {
			}
			// display
			model.addAttribute("mol", mol);
		}

		// NUMBERED FILES
		loadCompoundNumberedData(model, refCompound, inchikey);

		// ids
		String pubchemID = null;
		if (refCompound.getPubChemID() != null && !refCompound.getPubChemID().equals("")) {
			pubchemID = refCompound.getPubChemID();// .replaceAll("CID", "").replaceAll(" ", "");
			model.addAttribute("pubchem", Jsoup.clean(pubchemID, Whitelist.basic()));
		}

		String chebiID = null;
		if (refCompound.getChEBIID() != null && !refCompound.getChEBIID().equals("")) {
			chebiID = refCompound.getChEBIID();// .replaceAll("CHEBI:", "").replaceAll(" ", "");
			model.addAttribute("chebi", Jsoup.clean(chebiID, Whitelist.basic()));
		}

		String hmdbID = null;
		if (refCompound.getHmdbID() != null && !refCompound.getHmdbID().equals("")) {
			hmdbID = refCompound.getHmdbID();// .replaceAll("HMDB", "").replaceAll(" ", "");
			model.addAttribute("hmdb", Jsoup.clean(hmdbID, Whitelist.basic()));
		}

		List<String> keggs = null;
		if (refCompound.getKeggID() != null && !refCompound.getKeggID().isEmpty()) {
			// for (String keggid: refCompound.getKeggID())
			// keggs.add(keggid);
			keggs = refCompound.getKeggID();
			List<String> keggIDs = new ArrayList<>();
			for (String rawKegg : keggs)
				keggIDs.add(Jsoup.clean(rawKegg, Whitelist.basic()));
			model.addAttribute("keggs", keggIDs);
		}

		// return also user mode (user / anonymous )
		User user = null;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
		}

		long userId = -1;
		if (user != null && user.isConfirmed()) {
			model.addAttribute("editor", true);
			userId = user.getId();
		} else
			model.addAttribute("editor", false);

		List<Citation> acceptedCitations = new ArrayList<Citation>();
		List<Citation> waitingCitations = new ArrayList<Citation>();
		List<Citation> rejectedCitations = new ArrayList<Citation>();
		List<Citation> waitingCitationsUser = new ArrayList<Citation>();
		for (Citation c : refCompound.getCitations())
			switch (c.getStatus()) {
			case Citation.STATUS_ACCEPTED:
				acceptedCitations.add(c);
				break;
			case Citation.STATUS_WAITING:
				waitingCitations.add(c);
				if (userId == c.getUserID())
					waitingCitationsUser.add(c);
				break;
			case Citation.STATUS_REJECTED:
				rejectedCitations.add(c);
				break;
			default:
				break;
			}

		model.addAttribute("acceptedCitations", acceptedCitations);
		model.addAttribute("waitingCitationsUser", waitingCitationsUser);

		if (user != null && user.isCurator()) {
			model.addAttribute("curator", true);
			model.addAttribute("curationMessages", refCompound.getCurationMessages());
			model.addAttribute("waitingCitations", waitingCitations);
			model.addAttribute("rejectedCitations", rejectedCitations);
		} else
			model.addAttribute("curator", false);

		List<CurationMessage> waitingCurationMessageUser = new ArrayList<CurationMessage>();
		for (CurationMessage cm : refCompound.getCurationMessages())
			if (cm.getStatus() == CurationMessage.STATUS_WAITING && cm.getUserID() == userId) {
				cm.setMessage(Jsoup.clean(cm.getMessage(), Whitelist.basic()));
				waitingCurationMessageUser.add(cm);
			}
		model.addAttribute("waitingCurationMessageUser", waitingCurationMessageUser);

		// SPECTRUM
		if (refCompound.getListOfSpectra().isEmpty())
			model.addAttribute("contains_spectrum", false);
		else {
			model.addAttribute("contains_spectrum", true);
			// List<Long> idFSLCSp = new ArrayList<>();
			// for (Spectrum s : refCompound.getListOfSpectra()) {
			// if (s instanceof FullScanLCSpectrum)
			// idFSLCSp.add(s.getId());
			// else if (s instanceof FullScanGCSpectrum) {
			// // other (NMR / uv)
			// }
			// }
			// // model bind
			// model.addAttribute("spectrum_mass_fullscan_lc", idFSLCSp);
		}

		// TODO PARENT / CHILDREN
		model.addAttribute("contains_alt_structure", false);
		if (refCompound instanceof GenericCompound) {
			model.addAttribute("alt_structure_isGeneric", true);
			if (!((GenericCompound) refCompound).getChildren().isEmpty()) {
				model.addAttribute("contains_alt_structure", true);
				model.addAttribute("alt_structure_children", ((GenericCompound) refCompound).getChildren());
				model.addAttribute("alt_structure_parent", ((GenericCompound) refCompound));
			}
		} else if (refCompound instanceof ChemicalCompound) {
			model.addAttribute("alt_structure_isGeneric", false);
			if (((ChemicalCompound) refCompound).getParent() != null) {
				model.addAttribute("contains_alt_structure", true);
				model.addAttribute("alt_structure_parent",
						((GenericCompound) ((ChemicalCompound) refCompound).getParent()));
				// load children?
			}
		}

		// TODO sub structures

		// END
	}

	private void loadCompoundMeta(String type, Model model, StructureChemicalCompound refCompound,
			HttpServletRequest request) throws PeakForestManagerException {
		String formula = refCompound.getFormula();
		Pattern pattern = Pattern.compile("(\\d)");
		Matcher tagmatch = pattern.matcher(formula);
		List<String> listOfNumber = new ArrayList<String>();
		while (tagmatch.find())
			if (!listOfNumber.contains(tagmatch.group()))
				listOfNumber.add(tagmatch.group());

		// sort names
		List<CompoundName> listOfNames = refCompound.getListOfCompoundNames();
		Collections.sort(listOfNames, new CompoundNameComparator());

		// prevent XSS
		for (CompoundName cn : listOfNames) {
			cn.setName(Jsoup.clean(cn.getName(), Whitelist.basic()));
		}

		// ranking
		model.addAttribute("ranking_data", true);
		model.addAttribute("page_title", listOfNames.get(0).getName());
		model.addAttribute("page_keyworks",
				listOfNames.get(0) + ", " + refCompound.getInChIKey() + ", chemical compound");
		model.addAttribute("page_description", "chemical compound " + listOfNames.get(0).getName()
				+ " identified as " + refCompound.getInChIKey());

		// END
	}

	protected static void loadCompoundNumberedData(Model model, StructureChemicalCompound refCompound,
			String inchikey) {
		if (refCompound == null)
			return;
		model.addAttribute("mol_nb_3D_exists", false);
		model.addAttribute("mol_nb_2D_exists", false);
		model.addAttribute("mol_nb_3D_script", "");
		model.addAttribute("mol_nb_2D_ext", "");
		model.addAttribute("mol_nb_clean_name",
				Utils.convertHtmlGreekCharToString(refCompound.getMainName()));
		// model.addAttribute("mol_nb_upload", true);
		String numberedFileRepPath = Utils.getBundleConfElement("compoundNumberedFiles.folder");
		File molNumberedFilePath = new File(numberedFileRepPath + File.separator + inchikey + ".mol");
		File svgNumberedFilePath = new File(numberedFileRepPath + File.separator + inchikey + ".svg");
		File pngNumberedFilePath = new File(numberedFileRepPath + File.separator + inchikey + ".png");
		File jpegNumberedFilePath = new File(numberedFileRepPath + File.separator + inchikey + ".jpeg");

		// tada
		boolean d3First = true;
		boolean d2First = true;
		boolean dUFirst = true;

		// 3D
		if (molNumberedFilePath.exists()) {
			d2First = false;
			dUFirst = false;
			model.addAttribute("mol_nb_3D_exists", true);
			// read
			// String script = "";
			List<String> scripts = new ArrayList<String>();
			BufferedReader in;
			try {
				in = new BufferedReader(new FileReader(molNumberedFilePath));
				String line;
				while ((line = in.readLine()) != null) {
					// String[] split = line.split("ACDNUM=");
					// if (split.length == 2) {
					// if (script != "")
					// script += ", ";
					// script += "atomno = '" + split[1] + "'";
					// }
					// M V30 4 C 16.6972 -7.4112 0 0 ACDNUM=3
					Matcher m = Pattern.compile("M  V30 (\\d+).* ACDNUM=(.+)").matcher(line);
					if (m.find()) {
						// script += "atomno = '" + + "'";
						scripts.add("select atomno = " + m.group(1)
								+ "; color labels black; font labels 18; label \\\"" + m.group(2) + "\\\";");
					}
				}
				in.close();
			} catch (Exception e) {
			}
			// if (script != "")
			model.addAttribute("mol_nb_3D_scripts", scripts);
			// else
			// model.addAttribute("mol_nb_3D_script", "all");
		} else
			d3First = false;
		// 2D
		if (svgNumberedFilePath.exists()) {
			model.addAttribute("mol_nb_2D_exists", true);
			model.addAttribute("mol_nb_2D_ext", "svg");
			dUFirst = false;
		} else if (pngNumberedFilePath.exists()) {
			model.addAttribute("mol_nb_2D_exists", true);
			model.addAttribute("mol_nb_2D_ext", "png");
			dUFirst = false;
		} else if (jpegNumberedFilePath.exists()) {
			model.addAttribute("mol_nb_2D_exists", true);
			model.addAttribute("mol_nb_2D_ext", "jpeg");
			dUFirst = false;
		} else {
			d2First = false;
		}

		model.addAttribute("mol_nb_3D_exists_class", "");
		model.addAttribute("mol_nb_2D_exists_class", "");
		model.addAttribute("mol_nb_upload_exists_class", "");

		model.addAttribute("mol_nb_3D_exists_fad", "");
		model.addAttribute("mol_nb_2D_exists_fad", "");
		model.addAttribute("mol_nb_upload_exists_fad", "");
		if (d3First) {
			model.addAttribute("mol_nb_3D_exists_class", "active");
			model.addAttribute("mol_nb_3D_exists_fad", "active in");
		} else if (d2First) {
			model.addAttribute("mol_nb_2D_exists_class", "active");
			model.addAttribute("mol_nb_2D_exists_fad", "active in");
		} else if (dUFirst) {
			model.addAttribute("mol_nb_upload_exists_class", "active");
			model.addAttribute("mol_nb_upload_exists_fad", "active in");
		}
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param type
	 * @param id
	 * @param model
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/show-compound-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundShow(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// load data in model
		loadCompoundData(type, model, refCompound, request);

		// RETURN
		return "modal/show-compound-modal";
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param type
	 * @param id
	 * @param model
	 * @return
	 * @throws PeakForestManagerException
	 */
	@Secured("ROLE_CURATOR")
	@RequestMapping(value = "/edit-compound-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundEdit(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// init var

		// load data in model
		loadCompoundData(type, model, refCompound, request);

		// RETURN
		return "modal/edit-compound-modal";
	}

	@Secured("ROLE_EDITOR")
	// @PreAuthorize("isAuthenticated()")
	// @PreAuthorize("hasRole('ROLE_USER')")
	@RequestMapping(value = "/update-compound/{type}/{id}", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	@SuppressWarnings("unchecked")
	@ResponseBody
	public boolean updateCompound(@PathVariable String type, @PathVariable long id,
			@RequestBody Map<String, Object> data, HttpServletRequest request) {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// update score
		Map<String, Integer> updateScores = (Map<String, Integer>) data.get("updateScores");
		List<Long> listOfId = new ArrayList<Long>();
		List<Integer> listOfScore = new ArrayList<Integer>();
		for (Entry<String, Integer> entry : updateScores.entrySet()) {
			listOfId.add(Long.parseLong(entry.getKey()));
			listOfScore.add(entry.getValue());
		}
		try {
			if (!listOfId.isEmpty())
				CompoundNameManagementService.updateScore(listOfId, listOfScore, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// get compound
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}

		// add names
		Map<String, String> newNames = (Map<String, String>) data.get("newNames");
		List<String> listOfNewNames = new ArrayList<String>();
		for (Entry<String, String> entry : newNames.entrySet()) {
			listOfNewNames.add(entry.getValue());
		}
		if (!listOfNewNames.isEmpty())
			try {
				CompoundNameManagementService.create(listOfNewNames, refCompound, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}

		User user = null;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
		}

		// add curation messages
		List<String> curationMessages = (List<String>) data.get("curationMessages");
		if (!curationMessages.isEmpty())
			try {
				CurationMessageManagementService.create(curationMessages, user.getId(), refCompound, dbName,
						username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}

		List<Map<String, Object>> newCitations = (List<Map<String, Object>>) data.get("newCitations");
		if (!newCitations.isEmpty()) {
			try {
				List<Citation> listOfNewCitations = new ArrayList<Citation>();
				for (Map<String, Object> citationRawData : newCitations) {
					Long pmid = null;
					String doi = null;
					if (citationRawData.containsKey("doi") && citationRawData.get("doi") != null)
						doi = citationRawData.get("doi").toString();
					try {
						if (citationRawData.containsKey("pmid") && citationRawData.get("pmid") != null)
							pmid = Long.parseLong(citationRawData.get("pmid").toString());
					} catch (NumberFormatException nfe) {
					}
					if (!citationRawData.containsKey("id"))
						listOfNewCitations.add(new Citation(citationRawData.get("apa").toString(), pmid, doi,
								user.getId(), refCompound));
				}
				// add new citations
				CitationManagementService.create(listOfNewCitations, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}

		// log
		compoundLog("update compound @id=" + id + "; @inchikey=" + refCompound.getInChIKey());

		return true;
	}

	@Secured("ROLE_EDITOR")
	// @PreAuthorize("isAuthenticated()")
	// @PreAuthorize("hasRole('ROLE_USER')")
	@RequestMapping(value = "/edit-compound/{type}/{id}", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	@SuppressWarnings("unchecked")
	@ResponseBody
	public boolean editCompound(@PathVariable String type, @PathVariable long id,
			@RequestBody Map<String, Object> data) {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// update names and score
		Map<String, String> editNames = (Map<String, String>) data.get("editNames");
		Map<String, String> editScores = (Map<String, String>) data.get("editScores");
		List<Long> listOfId = new ArrayList<Long>();
		List<String> listOfNames = new ArrayList<String>();
		List<Double> listOfScores = new ArrayList<Double>();
		for (Entry<String, String> entry : editScores.entrySet()) {
			listOfId.add(Long.parseLong(entry.getKey()));
			listOfScores.add(Double.parseDouble(entry.getValue()));
			listOfNames.add(editNames.get(entry.getKey()));
		}
		try {
			if (!listOfId.isEmpty())
				CompoundNameManagementService.editNames(listOfId, listOfNames, listOfScores, dbName, username,
						password);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// get compound
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other types

		// add names
		Map<String, String> newNames = (Map<String, String>) data.get("newNames");
		Map<String, String> newScores = (Map<String, String>) data.get("newScores");
		HashMap<String, Double> mapOfNewNamesAndScores = new HashMap<String, Double>();
		for (Entry<String, String> entry : newNames.entrySet()) {
			mapOfNewNamesAndScores.put(entry.getValue(), Double.parseDouble(newScores.get(entry.getKey())));
		}
		if (!mapOfNewNamesAndScores.isEmpty())
			try {
				CompoundNameManagementService.create(mapOfNewNamesAndScores, refCompound, dbName, username,
						password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}

		// delete names
		List<Integer> deletedNames = (List<Integer>) data.get("deletedNames");
		List<Long> namesToDelete = new ArrayList<Long>();
		for (int nameId : deletedNames)
			namesToDelete.add(Long.parseLong(nameId + ""));
		if (!deletedNames.isEmpty())
			try {
				CompoundNameManagementService.delete(namesToDelete, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}

		// update IDs
		String pubchemID = null;
		String chebiID = null;
		String hmdbID = null;
		Map<String, String> newExtID = (Map<String, String>) data.get("newExtID");
		if (newExtID.containsKey("pubchem"))
			pubchemID = newExtID.get("pubchem");
		if (newExtID.containsKey("chebi"))
			chebiID = newExtID.get("chebi");
		if (newExtID.containsKey("hmdb"))
			hmdbID = newExtID.get("hmdb");

		List<String> keggIDsToAdd = (List<String>) data.get("newKeggIDs");
		List<String> keggIDsToRemove = (List<String>) data.get("deleteKeggIDs");
		if (type.equalsIgnoreCase("chemical"))
			try {
				ChemicalCompoundManagementService.updateExternalIDs(id, pubchemID, chebiID, hmdbID,
						keggIDsToAdd, keggIDsToRemove, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				GenericCompoundManagementService.updateExternalIDs(id, pubchemID, chebiID, hmdbID,
						keggIDsToAdd, keggIDsToRemove, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}

		// remove / update curation messages: get data from client
		Map<Long, Object> newCurationMessages = (Map<Long, Object>) data.get("newCurationMessages");
		List<Long> listOfCurationMessageToDeleletIds = new ArrayList<Long>();
		List<Long> listOfCurationMessageToAcceptIds = new ArrayList<Long>();
		List<Long> listOfCurationMessageToRejectIds = new ArrayList<Long>();
		for (Entry<Long, Object> entry : newCurationMessages.entrySet()) {
			Object raw = entry.getValue();
			if (raw instanceof Map<?, ?>) {
				Map<String, Object> dataCM = (Map<String, Object>) raw;
				long idCM = Long.parseLong(dataCM.get("id").toString());
				if (dataCM.get("update").toString().equalsIgnoreCase("deleted")) {
					listOfCurationMessageToDeleletIds.add(idCM);
				} else if (dataCM.get("update").toString().equalsIgnoreCase("rejected")) {
					listOfCurationMessageToRejectIds.add(idCM);
				} else if (dataCM.get("update").toString().equalsIgnoreCase("validated")) {
					listOfCurationMessageToAcceptIds.add(idCM);
				}
			}
		}
		// delete / update curation messages in database
		try {
			CurationMessageManagementService.delete(listOfCurationMessageToDeleletIds, dbName, username,
					password);
			CurationMessageManagementService.updateStatus(listOfCurationMessageToAcceptIds,
					CurationMessage.STATUS_ACCEPTED, dbName, username, password);
			CurationMessageManagementService.updateStatus(listOfCurationMessageToRejectIds,
					CurationMessage.STATUS_REJECTED, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// remove / update biblio stuff: read client request
		Map<Long, Object> updateCitations = (Map<Long, Object>) data.get("updateCitations");
		List<Long> listOfCitationToRemove = new ArrayList<Long>();
		List<Long> listOfCitationToAccept = new ArrayList<Long>();
		List<Long> listOfCitationToReject = new ArrayList<Long>();
		for (Entry<Long, Object> entry : updateCitations.entrySet()) {
			Object raw = entry.getValue();
			if (raw instanceof Map<?, ?>) {
				Map<String, Object> dataCM = (Map<String, Object>) raw;
				long idCitation = Long.parseLong(dataCM.get("id").toString());
				if (dataCM.get("update").toString().equalsIgnoreCase("deleted")) {
					listOfCitationToRemove.add(idCitation);
				} else if (dataCM.get("update").toString().equalsIgnoreCase("rejected")) {
					listOfCitationToReject.add(idCitation);
				} else if (dataCM.get("update").toString().equalsIgnoreCase("validated")) {
					listOfCitationToAccept.add(idCitation);
				}
			}
		}
		// remove / update biblio stuff: database part
		try {
			CitationManagementService.delete(listOfCitationToRemove, dbName, username, password);
			CitationManagementService.updateStatus(listOfCitationToAccept, Citation.STATUS_ACCEPTED, dbName,
					username, password);
			CitationManagementService.updateStatus(listOfCitationToReject, Citation.STATUS_REJECTED, dbName,
					username, password);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		User user = null;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
		}
		// new citations
		List<Map<String, Object>> newCitations = (List<Map<String, Object>>) data.get("newCitations");
		if (!newCitations.isEmpty()) {
			try {
				List<Citation> listOfNewCitations = new ArrayList<Citation>();
				for (Map<String, Object> citationRawData : newCitations)
					if (!citationRawData.containsKey("id")) {
						Citation c = new Citation(citationRawData.get("apa").toString(),
								Long.parseLong(citationRawData.get("pmid").toString()),
								citationRawData.get("doi").toString(), user.getId(), refCompound);
						c.setStatus(Citation.STATUS_ACCEPTED);
						listOfNewCitations.add(c);
					}
				// add new citations
				CitationManagementService.create(listOfNewCitations, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}

		// log
		compoundLog("edit compound @id=" + id + "; @inchikey=" + refCompound.getInChIKey());

		return true;
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/add-one-compound-search", method = RequestMethod.POST, params = { "query",
			"filter" })
	public String addCompoundViewSearchCompound(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, @RequestParam("query") String query,
			@RequestParam("filter") int filter) {

		List<ReferenceChemicalCompound> results = null;
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// search
		try {
			results = SearchService.searchCompound(query, filter, 10, dbName, username, password);
			model.addAttribute("compounds", results);
		} catch (PeakForestManagerException e) {
			e.printStackTrace();
			model.addAttribute("success", false);
			model.addAttribute("error", e.getMessage());
			return "block/add-one-compound-search";
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (results == null || results.isEmpty()) {
			model.addAttribute("success", false);
			model.addAttribute("error", PeakForestManagerException.NO_RESULTS_MATCHED_THE_QUERY);
		} else {
			model.addAttribute("success", true);
		}
		return "ajax/add-one-compound-search";
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/add-one-compound-load", method = RequestMethod.POST, params = { "id", "type" })
	public String addCompoundViewLoadCompound(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, @RequestParam("id") long id, @RequestParam("type") int type)
			throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		String typeS = null;
		if (type == Compound.CHEMICAL_TYPE)
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
				typeS = "chemical";
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type == Compound.GENERIC_TYPE)
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
				typeS = "generic";
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// init var

		// load data in model
		loadCompoundData(typeS, model, refCompound, request);

		return "ajax/add-one-compound-load";
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/add-one-compound-search-ext-db", method = RequestMethod.POST, params = {
			"query", "filter" })
	public @ResponseBody List<ReferenceChemicalCompound> deepSearch(@RequestParam("query") String query,
			@RequestParam("filter") int filter) throws Exception {
		// get images path
		String svgImagesPath = Utils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);

		List<ReferenceChemicalCompound> data = null;
		data = SearchService.searchCompoundInExternalBank(query, filter, 20, svgImagesPath, null);
		// Utils.prune(data);
		for (ReferenceChemicalCompound rcc : data)
			for (CompoundName cn : rcc.getListOfCompoundNames())
				cn.setReferenceChemicalCompound(null);
		// compoundLog("search chemical compound in ext. db; @query='" + query + "'; @filter=" + filter);
		return data;
	}

	@SuppressWarnings("unchecked")
	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/add-one-compound-from-ext-db", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	public @ResponseBody Map<String, Object> addCompoundFromExternalDatabase(
			@RequestBody Map<String, Object> data) throws Exception {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		String inChI = (String) data.get("inChI");
		String inChIKey = (String) data.get("inChIKey");
		// String canSmiles = (String) data.get("canSmiles");
		String chEBIID = (String) data.get("chEBIID");
		String hmdbID = (String) data.get("hmdbID");
		String pubChemID = (String) data.get("pubChemID");
		List<String> keggID = (List<String>) data.get("keggID");
		List<String> names = (List<String>) data.get("namesL");

		// names: [Ethanol]

		// check exist AS chemical compound OR generic compound
		StructureChemicalCompound sccInBase = StructuralCompoundManagementService.readByInChIKey(inChIKey,
				dbName, username, password);
		if (sccInBase != null) {
			Map<String, Object> results = new HashMap<String, Object>();
			results.put("id", sccInBase.getId());
			results.put("type", sccInBase.getType());
			return results;
		}

		// ADD NEW COMPOUND
		ChemicalCompoundMapper mapper = new ChemicalCompoundMapper(names, inChIKey);
		mapper.setInChI(inChI);
		mapper.setChEBIId(chEBIID);
		mapper.setHmdbId(hmdbID);
		if (keggID != null && !keggID.isEmpty())
			mapper.setKeggId(keggID.get(0));
		mapper.setPubChemId(pubChemID);
		StructureChemicalCompound compound = StructuralCompoundManagementService.addOrUpdateCompound(mapper,
				dbName, username, password);

		if (compound == null)
			throw new PeakForestManagerException(PeakForestManagerException.COULD_NOT_ADD_COMPOUND);
		else {
			// log
			compoundLog("add new compound @id=" + compound.getId() + "; @inchikey=" + compound.getInChIKey());
			Map<String, Object> results = new HashMap<String, Object>();
			results.put("id", compound.getId());
			results.put("type", compound.getType());
			return results;

		}
	}

	/**
	 * @param query
	 * @return
	 * @throws PeakForestManagerException
	 */
	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/get-citation-data", method = RequestMethod.POST, params = { "query" })
	public @ResponseBody Object loadCitationData(@RequestParam("query") String query)
			throws PeakForestManagerException {

		query = query.trim();
		// rexep
		Pattern patternURL = Pattern.compile("^(https?)://dx.doi.org/(.*)$");
		Matcher matcherURL = patternURL.matcher(query);

		Pattern patternURLBad = Pattern.compile("^dx.doi.org/(.*)$");
		Matcher matcherURLBad = patternURLBad.matcher(query);

		Pattern patternDOI = Pattern.compile("^doi:(.*)$");
		Matcher matcherDOI = patternDOI.matcher(query);

		// 10.1093/bioinformatics/btu813
		if (matcherURL.find()) {
			query = matcherURL.group(2);
		} else if (matcherURLBad.find()) {
			query = matcherURLBad.group(1);
		} else if (matcherDOI.find()) {
			query = matcherDOI.group(1);
		}
		if (query.contains("/"))
			query = "" + query;

		Map<String, Object> data = new HashMap<String, Object>();
		boolean success = false;
		EbiPubClient newRefClient = new EbiPubClient(query, true);
		success = newRefClient.extractData();
		if (success) {
			data.put("doi", newRefClient.getDoi());
			data.put("pmid", newRefClient.getPmid());
			data.put("apa", newRefClient.getApa());
		}
		data.put("success", success);
		// compoundLog("loaded citation @doi='" + newRefClient.getDoi() + "' @apa='" + newRefClient.getApa()
		// + "'");
		return data;
	}

	@RequestMapping(value = "/get-cpd-data", method = RequestMethod.GET, params = { "inchikey" })
	public @ResponseBody Object loadCompoundData(@RequestParam("inchikey") String inchikey)
			throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		Map<String, Object> data = new HashMap<String, Object>();
		boolean success = false;

		// load data

		StructureChemicalCompound refCompound = null;
		try {
			refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey, dbName, username,
					password);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (refCompound == null)
			try {
				refCompound = GenericCompoundManagementService.readByInChIKey(inchikey, dbName, username,
						password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		if (refCompound != null) {
			success = true;
			data.put("name", refCompound.getMainName());
			data.put("type", refCompound.getTypeString());
			data.put("inchi", refCompound.getInChI());
			data.put("inchikey", refCompound.getInChIKey());
		}
		data.put("success", success);

		return data;
	}

	@RequestMapping(value = "/sheet-compound/{type}/{id}", method = RequestMethod.GET)
	public String showCompoundSheet(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("id") long id, @PathVariable("type") String type)
			throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// init var

		// load data in model
		loadCompoundData(type, model, refCompound, request);
		return "pages/sheet-compound";
	}

	@RequestMapping(value = "/sheet-compound/{id}", method = RequestMethod.GET)
	public String showCompoundSheet(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("id") String id) throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		String type = "";
		try {
			long idL = Long.parseLong(id);
			try {
				refCompound = ChemicalCompoundManagementService.read(idL, dbName, username, password);
				type = "chemical";
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (refCompound == null)
				try {
					refCompound = GenericCompoundManagementService.read(idL, dbName, username, password);
					type = "generic";
				} catch (Exception e) {
					e.printStackTrace();
				}
		} catch (NumberFormatException e) {
			try {
				refCompound = StructuralCompoundManagementService.readByInChIKey(id, dbName, username,
						password);
				type = refCompound.getTypeString();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		// TODO other

		// init var

		// load data in model
		loadCompoundData(type, model, refCompound, request);
		return "pages/sheet-compound";
	}

	@RequestMapping(value = "/data-ranking-compound/{id}", method = RequestMethod.GET)
	public String showCompoundMeta(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("id") String id) throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		String type = "";
		try {
			long idL = Long.parseLong(id);
			try {
				refCompound = ChemicalCompoundManagementService.read(idL, dbName, username, password);
				type = "chemical";
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (refCompound == null)
				try {
					refCompound = GenericCompoundManagementService.read(idL, dbName, username, password);
					type = "generic";
				} catch (Exception e) {
					e.printStackTrace();
				}
		} catch (NumberFormatException e) {
			try {
				refCompound = StructuralCompoundManagementService.readByInChIKey(id, dbName, username,
						password);
				type = refCompound.getTypeString();
			} catch (Exception e1) {
				e1.printStackTrace();
			}
		}
		// TODO other

		// init var

		// load data in model
		loadCompoundMeta(type, model, refCompound, request);
		return "block/meta";
	}

	/**
	 * @param parentId
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/load-children-chemical-compounds-names", method = RequestMethod.POST, params = {
			"parentId" })
	public @ResponseBody Object loadChildrenChemicalCompoundsData(@RequestParam("parentId") long parentId)
			throws PeakForestManagerException {

		Map<String, Object> data = new HashMap<String, Object>();
		boolean isSuccess = false;

		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		GenericCompound parentCompound = null;
		try {
			parentCompound = GenericCompoundManagementService.read(parentId, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (parentCompound != null) {
			List<Long> idChildrens = new ArrayList<Long>();
			for (ChemicalCompound cc : parentCompound.getChildren())
				idChildrens.add(cc.getId());
			try {
				// childs
				List<ChemicalCompound> children = ChemicalCompoundManagementService.read(idChildrens, dbName,
						username, password);
				for (ChemicalCompound cc : children) {
					cc = (ChemicalCompound) Utils.prune(cc);
					List<CompoundName> names = cc.getListOfCompoundNames();
					Collections.sort(names, new CompoundNameComparator());
					cc.setListOfCompoundNames(names);
				}
				data.put("chemicalCompounds", children);
				// parent
				List<CompoundName> names = parentCompound.getListOfCompoundNames();
				Collections.sort(names, new CompoundNameComparator());
				data.put("parentName", names.get(0).getName());
				// success
				isSuccess = true;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		data.put("success", isSuccess);
		return data;
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/pick-one-compound-search", method = RequestMethod.POST, params = { "query",
			"filter" })
	public String pickCompoundViewSearchCompound(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, @RequestParam("query") String query,
			@RequestParam("filter") int filter) {

		List<ReferenceChemicalCompound> resultsRaw = null;
		List<ReferenceChemicalCompound> resultsClean = new ArrayList<ReferenceChemicalCompound>();
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// search
		try {
			resultsRaw = SearchService.searchCompound(query, filter, 10, dbName, username, password);
			if (resultsRaw == null || resultsRaw.isEmpty()) {
				resultsRaw = SearchService.searchCompound(query, Utils.SEARCH_COMPOUND_INCHIKEY, 10, dbName,
						username, password);
			}
			// keep unic
			List<Long> listOfUnicIds = new ArrayList<Long>();

			if (resultsRaw != null) {
				for (ReferenceChemicalCompound ref : resultsRaw)
					if (!listOfUnicIds.contains(ref.getId())) {
						listOfUnicIds.add(ref.getId());
						resultsClean.add(ref);
					}
			}
			model.addAttribute("compounds", resultsClean);
		} catch (PeakForestManagerException e) {
			e.printStackTrace();
			model.addAttribute("success", false);
			model.addAttribute("error", e.getMessage());
			return "block/add-one-compound-search";
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (resultsClean.isEmpty()) {
			model.addAttribute("success", false);
			model.addAttribute("error", PeakForestManagerException.NO_RESULTS_MATCHED_THE_QUERY);
		} else {
			model.addAttribute("success", true);
		}
		return "ajax/pick-one-compound-search";
	}

	@RequestMapping(value = "/cpd:{query}", method = RequestMethod.GET)
	public ModelAndView method(HttpServletResponse httpServletResponse, @PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?cpd=" + query);
	}

	@RequestMapping(value = "/PFc{query}", method = RequestMethod.GET)
	public ModelAndView methodPFc(HttpServletResponse httpServletResponse,
			@PathVariable("query") String query) {
		// try {
		// return new ModelAndView("redirect:" + "/home?cpd=" + Integer.parseInt(query));
		// } catch (NumberFormatException e) {
		return new ModelAndView("redirect:" + "/home?PFc=" + query);
		// }

	}

	@RequestMapping(value = "/js_cpd_sandbox/{inchikey}", method = RequestMethod.GET)
	public String showJSMolInCompoundSheet(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, @PathVariable("inchikey") String inchikey)
			throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		StructureChemicalCompound refCompound = null;
		// if (type.equalsIgnoreCase("chemical"))
		try {
			refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey, dbName, username,
					password);
			if (refCompound == null)
				refCompound = GenericCompoundManagementService.readByInChIKey(inchikey, dbName, username,
						password);
		} catch (Exception e) {
			e.printStackTrace();
		}
		// NUMBERED FILES
		loadCompoundNumberedData(model, refCompound, inchikey);

		// RETURN
		return "module/jsmol_cpd_sandbox";
	}

	// @RequestMapping(value = "/cpd/{query}", method = RequestMethod.GET)
	// public void method(HttpServletResponse httpServletResponse, @PathVariable("query") int id) {
	// httpServletResponse.setHeader("Location", "home?cpd=" + id);
	// }

	/**
	 * @param logMessage
	 */
	private void compoundLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

	@RequestMapping(value = "/pf-compound-ext-div/{source}/{inchikey}", method = RequestMethod.GET)
	public String compoundExternalShow(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String source, @PathVariable String inchikey, Model model)
			throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// load data
		StructureChemicalCompound refCompound = null;

		try {
			refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey, dbName, username,
					password);

		} catch (Exception e) {
			e.printStackTrace();
		}
		if (refCompound == null)
			try {
				refCompound = GenericCompoundManagementService.readByInChIKey(inchikey, dbName, username,
						password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// load data in model
		if (refCompound == null)
			return "module/pf-compound-not-found-ext-div";

		loadCompoundData(refCompound.getTypeString(), model, refCompound, request);

		// RETURN
		return "module/pf-compound-ext-div";
	}

}

package fr.metabohub.peakforest.controllers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
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
import fr.metabohub.externalbanks.mapper.ebipub.EbiPubResult;
import fr.metabohub.externalbanks.mapper.ebipub.EbiPubResults;
import fr.metabohub.externalbanks.rest.EbiPubClient;
import fr.metabohub.peakforest.dao.CurationMessageDao;
import fr.metabohub.peakforest.dao.compound.CitationDao;
import fr.metabohub.peakforest.dao.compound.GCDerivedCompoundDao;
import fr.metabohub.peakforest.model.CurationMessage;
import fr.metabohub.peakforest.model.compound.CAS;
import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.Citation;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.CompoundName;
import fr.metabohub.peakforest.model.compound.ExternalId;
import fr.metabohub.peakforest.model.compound.GCDerivedCompound;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.model.metadata.GCDerivedCompoundMetadata;
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
import fr.metabohub.peakforest.utils.PeakForestPruneUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;

@Controller
// @Configuration
// @EnableWebSecurity
// @EnableGlobalMethodSecurity(securedEnabled = true)
// @EnableGlobalMethodSecurity(prePostEnabled = true)
public class CompoundsController {

	@RequestMapping(value = "/print-compound-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundPrint(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO_LTS other
		// init var
		// load data in model
		loadCompoundData(type, model, refCompound, request);
		// RETURN
		return "modal/print-compound-modal";
	}

	private void loadCompoundData(//
			final String type, //
			final Model model, //
			final StructureChemicalCompound refCompound, //
			final HttpServletRequest request) throws PeakForestManagerException {
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
		// new 2.0: debug empty names
		if (listOfNames.isEmpty())
			listOfNames.add(new CompoundName("?", refCompound));
		// prevent XSS
		for (CompoundName cn : listOfNames) {
			cn.setName(Jsoup.clean(cn.getName(), Whitelist.basic()));
			cn.setName(cn.getName().replaceAll("α", "&alpha;").replaceAll("β", "&beta;").replaceAll("γ", "&gamma;")
					.replaceAll("ω", "&omega;"));
		}
		for (CompoundName cn : listOfNames)
			cn.setScore(PeakForestPruneUtils.round(cn.getScore(), 1));
		// BUILD MODEL
		model.addAttribute("id", refCompound.getId());
		model.addAttribute("compoundNames", listOfNames);
		// new 2.0 IUPAC / CAS
		model.addAttribute("cpdFullData", refCompound);
		if (refCompound.getIupacName() != null)
			model.addAttribute("iupacName", Jsoup.clean(refCompound.getIupacName(), Whitelist.basic()));
		List<CAS> listOfCAS = refCompound.getListOfCAS();
		for (CAS cn : listOfCAS) {
			cn.setCasNumber(Jsoup.clean(cn.getCasNumber(), Whitelist.basic()));
			if (cn.getCasProviderOther() != null)
				cn.setCasProviderOther(Jsoup.clean(cn.getCasProviderOther(), Whitelist.basic()));
			cn.setCasReferencer(Jsoup.clean(cn.getCasReferencer(), Whitelist.basic()));
		}
		if (!listOfCAS.isEmpty())
			model.addAttribute("cas", listOfCAS);

		// new 2.0: stars curation
		model.addAttribute("nbStarCuration", refCompound.getCurationAsStars());
		model.addAttribute("hasBeenStructuralChecked", refCompound.hasBeenStructuralChecked());
		model.addAttribute("hasBeenManualChecked", refCompound.hasBeenManualChecked());

		model.addAttribute("type", type);
		model.addAttribute("inchikey", refCompound.getInChIKey());
		model.addAttribute("logP", refCompound.getLogP());
		if (refCompound.getIsBioactive() != null) {
			model.addAttribute("isBioactive", true);
			model.addAttribute("isBioactiveV", refCompound.getIsBioactive());
		}
		if (refCompound instanceof StructureChemicalCompound)
			model.addAttribute("inchi", refCompound.getInChI());
		model.addAttribute("exactMass", PeakForestPruneUtils.round(refCompound.getExactMass(), 7));
		model.addAttribute("molWeight", PeakForestPruneUtils.round(refCompound.getMolWeight(), 7));
		model.addAttribute("formula", formula);
		model.addAttribute("pfID", refCompound.getPeakForestID());
		model.addAttribute("smiles", refCompound.getCanSmiles());
		// model.addAttribute("mol", refCompound.getMolFile());

		// MOL
		String inchikey = refCompound.getInChIKey();
		// get mol path
		String molFileRepPath = PeakForestUtils.getBundleConfElement("compoundMolFiles.folder");
		if (!(new File(molFileRepPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);

		// check exists
		File molFilePath = new File(molFileRepPath + File.separator + inchikey + ".mol");
		// model.addAttribute("mol_ready", false);
		if (!molFilePath.exists()) {
			// display not yet available
			model.addAttribute("mol_ready", false);
			// create
			ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
			compoundsList.add(refCompound);
			CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(compoundsList,
					null, molFileRepPath, true);
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

		// new 2.2.1
		if (refCompound.getExternalIds() != null && !refCompound.getExternalIds().isEmpty()) {
			model.addAttribute("externalIds", refCompound.getExternalIds());
		}

		List<String> networks = null;
		if (refCompound.getNetworksIDs() != null && !refCompound.getNetworksIDs().isEmpty()) {
			networks = refCompound.getNetworksIDs();
			List<String> networkIDs = new ArrayList<>();
			for (String rawNetwork : networks)
				networkIDs.add(Jsoup.clean(rawNetwork, Whitelist.basic()));
			model.addAttribute("networks", networkIDs);
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
				model.addAttribute("alt_structure_parent", (refCompound));
			}
		} else if (refCompound instanceof ChemicalCompound) {
			model.addAttribute("alt_structure_isGeneric", false);
			if (((ChemicalCompound) refCompound).getParent() != null) {
				model.addAttribute("contains_alt_structure", true);
				model.addAttribute("alt_structure_parent", (((ChemicalCompound) refCompound).getParent()));
				// load children?
			}
		}

		// TODO sub structures

		// GC-derived compounds
		model.addAttribute("contains_gc_derivatives", false);
		for (GCDerivedCompoundMetadata derivativeMetadata : refCompound.getListOfGCDerivedCompoundMetadata()) {
			if (derivativeMetadata.getStructureDerivedCompound() != null)
				model.addAttribute("contains_gc_derivatives", true);
		}

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
		if (listOfNames.isEmpty()) {
			model.addAttribute("page_title", "?");
			model.addAttribute("page_keyworks", refCompound.getInChIKey() + ", chemical compound");
			model.addAttribute("page_description",
					"chemical compound " + " identified as " + refCompound.getInChIKey());
		} else {
			model.addAttribute("page_title", listOfNames.get(0).getName());
			model.addAttribute("page_keyworks",
					listOfNames.get(0).getName() + ", " + refCompound.getInChIKey() + ", chemical compound");
			model.addAttribute("page_description", "chemical compound " + listOfNames.get(0).getName()
					+ " identified as " + refCompound.getInChIKey());
		}
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
				PeakForestPruneUtils.convertHtmlGreekCharToString(refCompound.getMainName()));
		// model.addAttribute("mol_nb_upload", true);
		String numberedFileRepPath = PeakForestUtils.getBundleConfElement("compoundNumberedFiles.folder");
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
						scripts.add("select atomno = " + m.group(1) + "; color labels black; font labels 18; label \\\""
								+ m.group(2) + "\\\";");
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

	@RequestMapping(value = "/show-compound-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundShow(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		// TODO other

		// load data in model
		loadCompoundData(type, model, refCompound, request);

		// RETURN
		return "modal/show-compound-modal";
	}

	@Secured("ROLE_CURATOR")
	@RequestMapping(value = "/edit-compound-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundEdit(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id);
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
				CompoundNameManagementService.updateScore(listOfId, listOfScore);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// get compound
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id);
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
				CompoundNameManagementService.create(listOfNewNames, refCompound);
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
				CurationMessageManagementService.create(curationMessages, user.getId(), refCompound);
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
				CitationDao.create(listOfNewCitations);
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
				CompoundNameManagementService.editNames(listOfId, listOfNames, listOfScores);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// get compound
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id);
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
				CompoundNameManagementService.create(mapOfNewNamesAndScores, refCompound);
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
				CompoundNameManagementService.delete(namesToDelete);
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
		List<String> networkIDsToAdd = (List<String>) data.get("newNetworksIDs");
		List<String> networkIDsToRemove = (List<String>) data.get("deleteNetworksIDs");
		if (type.equalsIgnoreCase("chemical"))
			try {
				ChemicalCompoundManagementService.updateExternalIDs(id, pubchemID, chebiID, hmdbID, keggIDsToAdd,
						keggIDsToRemove, networkIDsToAdd, networkIDsToRemove);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				GenericCompoundManagementService.updateExternalIDs(id, pubchemID, chebiID, hmdbID, keggIDsToAdd,
						keggIDsToRemove, networkIDsToAdd, networkIDsToRemove);
			} catch (Exception e) {
				e.printStackTrace();
			}

		// new 2.0: IUPAC and CAS from common names
		List<Long> nameSwitchedToCAS = new ArrayList<>();
		List<Integer> nameSwitchedToCASraw = (List<Integer>) data.get("nameSwitchedToCAS");
		for (int i : nameSwitchedToCASraw)
			nameSwitchedToCAS.add(Long.parseLong(i + ""));
		String nameSwitchedToIUPACraw = null;
		if (data.get("nameSwitchedToIUPAC") != null)
			nameSwitchedToIUPACraw = data.get("nameSwitchedToIUPAC").toString();
		Long nameSwitchedToIUPAC = null;
		if (nameSwitchedToIUPACraw != null) {
			try {
				nameSwitchedToIUPAC = Long.parseLong(nameSwitchedToIUPACraw);
			} catch (NumberFormatException e) {
			}
		}
		if (nameSwitchedToIUPAC != null || !nameSwitchedToCAS.isEmpty()) {
			if (type.equalsIgnoreCase("chemical"))
				try {
					ChemicalCompoundManagementService.switchNames(id, nameSwitchedToIUPAC, nameSwitchedToCAS);
				} catch (Exception e) {
					e.printStackTrace();
					return false;
				}
			else if (type.equalsIgnoreCase("generic"))
				try {
					GenericCompoundManagementService.switchNames(id, nameSwitchedToIUPAC, nameSwitchedToCAS);
				} catch (Exception e) {
					e.printStackTrace();
				}
		}

		// new 2.0: update IUPAC
		if (data.get("newIupacName") != null) {
			String newIupacName = data.get("newIupacName").toString();
			if (type.equalsIgnoreCase("chemical")) {
				try {
					ChemicalCompoundManagementService.updateIUPAC(id, newIupacName);
				} catch (Exception e) {
					e.printStackTrace();
					return false;
				}
			} else if (type.equalsIgnoreCase("generic")) {
				try {
					GenericCompoundManagementService.updateIUPAC(id, newIupacName);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

		// new 2.0: add / remove CAS
		List<CAS> newCasObjs = new ArrayList<>();
		List<Long> removeCasIds = new ArrayList<>();
		// newCASs
		for (Object rawEntry : ((ArrayList<Object>) data.get("newCASs"))) {
			if (rawEntry instanceof LinkedHashMap<?, ?>) {
				LinkedHashMap<String, String> entry = (LinkedHashMap<String, String>) rawEntry;
				CAS newCas = new CAS();
				newCas.setCasNumber(entry.get("number"));
				newCas.setCasProviderFromString(entry.get("provider"));
				newCas.setCasReferencer(entry.get("reference"));
				newCasObjs.add(newCas);
			}
		}
		// deleteCASs
		for (int i : (List<Integer>) data.get("deleteCASs")) {
			removeCasIds.add(Long.parseLong(i + ""));
		}

		if (!newCasObjs.isEmpty() || !removeCasIds.isEmpty()) {
			if (type.equalsIgnoreCase("chemical"))
				try {
					ChemicalCompoundManagementService.addRemoveCas(id, newCasObjs, removeCasIds);
				} catch (Exception e) {
					e.printStackTrace();
					return false;
				}
			else if (type.equalsIgnoreCase("generic"))
				try {
					GenericCompoundManagementService.addRemoveCas(id, newCasObjs, removeCasIds);
				} catch (Exception e) {
					e.printStackTrace();
				}
		}

		// new 2.2 add / remove External IDs
		final List<ExternalId> newExternalIdsObjs = new ArrayList<>();
		final List<Long> removeExternalIds = new ArrayList<>();
		// newExternalIds
		for (final Object rawEntry : ((ArrayList<Object>) data.get("newExternalIds"))) {
			if (rawEntry instanceof LinkedHashMap<?, ?>) {
				final LinkedHashMap<String, String> entry = (LinkedHashMap<String, String>) rawEntry;
				final String url = entry.get("url");
				final String label = entry.get("label");
				final String value = entry.get("value");
				final ExternalId newExtId = new ExternalId(label, value, url, refCompound);
				newExternalIdsObjs.add(newExtId);
			}
		}
		// deleteExternalIds
		for (int i : (List<Integer>) data.get("deleteExternalIds")) {
			removeExternalIds.add(Long.parseLong(i + ""));
		}
		// call DAO
		if (!newExternalIdsObjs.isEmpty() || !removeExternalIds.isEmpty()) {
			try {
				if (type.equalsIgnoreCase("chemical")) {
					ChemicalCompoundManagementService.addRemoveExternalIds(id, newExternalIdsObjs, removeExternalIds);
				} else if (type.equalsIgnoreCase("generic")) {
					GenericCompoundManagementService.addRemoveExternalIds(id, newExternalIdsObjs, removeExternalIds);
				}
			} catch (final Exception e) {
				e.printStackTrace();
			}
		}

		// new 2.0: set curation flag / do curation action
		boolean flagAsManudalCurated = false;
		boolean doStructureCheck = false;
		for (String curationAction : (List<String>) data.get("curationUpdate")) {
			if (curationAction.equalsIgnoreCase("manual")) {
				flagAsManudalCurated = true;
			} else if (curationAction.equalsIgnoreCase("structure")) {
				doStructureCheck = true;
			}
		}

		if (flagAsManudalCurated) {
			if (type.equalsIgnoreCase("chemical"))
				try {
					ChemicalCompoundManagementService.setCurationToManual(id);
				} catch (Exception e) {
					e.printStackTrace();
					return false;
				}
			else if (type.equalsIgnoreCase("generic"))
				try {
					GenericCompoundManagementService.setCurationToManual(id);
				} catch (Exception e) {
					e.printStackTrace();
				}
		}

		if (doStructureCheck) {
			if (type.equalsIgnoreCase("chemical"))
				try {
					ChemicalCompoundManagementService.doStructuralCuration(id);
				} catch (Exception e) {
					e.printStackTrace();
					return false;
				}
			else if (type.equalsIgnoreCase("generic"))
				try {
					GenericCompoundManagementService.doStructuralCuration(id);
				} catch (Exception e) {
					e.printStackTrace();
				}
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
			CurationMessageManagementService.delete(listOfCurationMessageToDeleletIds);
			CurationMessageDao.update(listOfCurationMessageToAcceptIds, CurationMessage.STATUS_ACCEPTED);
			CurationMessageDao.update(listOfCurationMessageToRejectIds, CurationMessage.STATUS_REJECTED);
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
			CitationManagementService.delete(listOfCitationToRemove);
			CurationMessageDao.update(listOfCitationToAccept, Citation.STATUS_ACCEPTED);
			CurationMessageDao.update(listOfCitationToReject, Citation.STATUS_REJECTED);
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
				CitationDao.create(listOfNewCitations);
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
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/add-one-compound-search", //
			params = { "query", "filter" }//
	)
	public String addCompoundViewSearchCompound(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final @RequestParam("query") String query, //
			final @RequestParam("filter") int filter) {
		// init request
		final List<ReferenceChemicalCompound> results = new ArrayList<ReferenceChemicalCompound>();
		// search
		try {
			results.addAll(SearchService.searchCompound(query, filter, SearchService.MAX_CPD_NAME_PER_CPD));
			model.addAttribute("compounds", results);
		} catch (final Exception e) {
			SpectralDatabaseLogger.log(//
					"error in POST '/add-one-compound-search' " + e.getMessage(), //
					SpectralDatabaseLogger.LOG_WARNING//
			);
		}
		// associate to model
		if (results.isEmpty()) {
			model.addAttribute("success", Boolean.FALSE);
			model.addAttribute("error", PeakForestManagerException.NO_RESULTS_MATCHED_THE_QUERY);
		} else {
			model.addAttribute("success", Boolean.TRUE);
		}
		return "ajax/add-one-compound-search";
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/add-one-compound-load", //
			params = { "id", "type" }//
	)
	public String addCompoundViewLoadCompound(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final @RequestParam("id") long id, //
			final @RequestParam("type") int type)//
			throws PeakForestManagerException {
		// load data
		StructureChemicalCompound refCompound = null;
		String typeS = null;
		try {
			if (type == Compound.CHEMICAL_TYPE) {
				refCompound = ChemicalCompoundManagementService.read(id);
				typeS = "chemical";
			} else if (type == Compound.GENERIC_TYPE) {
				refCompound = GenericCompoundManagementService.read(id);
				typeS = "generic";
			}
			// TODO other and init view
		} catch (final Exception e) {
			SpectralDatabaseLogger.log(//
					"error in POST '/add-one-compound-load' " + e.getMessage(), //
					SpectralDatabaseLogger.LOG_WARNING//
			);
		}
		// load data in model
		loadCompoundData(typeS, model, refCompound, request);
		// retrun view
		return "ajax/add-one-compound-load";
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/add-one-compound-search-ext-db", //
			params = { "query", "filter" })
	public @ResponseBody List<ReferenceChemicalCompound> deepSearch(//
			final @RequestParam("query") String query, //
			final @RequestParam("filter") int filter//
	) throws Exception {
		// get images path
		final String svgImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists()) {
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);
		}
		// search in third par webservice
		final List<ReferenceChemicalCompound> data = SearchService.searchCompoundInExternalBank(//
				query, filter, 20, svgImagesPath, null);
		// prune
		for (final ReferenceChemicalCompound rcc : data) {
			for (final CompoundName cn : rcc.getListOfCompoundNames()) {
				cn.setReferenceChemicalCompound(null);
			}
		}
		// return
		return data;
	}

	@SuppressWarnings("unchecked")
	@Secured("ROLE_EDITOR")
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/add-one-compound-from-ext-db", //
			headers = { "Content-type=application/json" }//
	)
	public @ResponseBody Map<String, Object> addCompoundFromExternalDatabase(//
			final @RequestBody Map<String, Object> data)//
			throws Exception {
		// init request
		final String inChI = (String) data.get("inChI");
		final String inChIKey = (String) data.get("inChIKey");
		// String canSmiles = (String) data.get("canSmiles");
		final String chEBIID = (String) data.get("chEBIID");
		final String hmdbID = (String) data.get("hmdbID");
		String pubChemID = (String) data.get("pubChemID");
		final List<String> keggID = (List<String>) data.get("keggID");
		final List<String> names = (List<String>) data.get("namesL");
		// names: [Ethanol]
		// check exist AS chemical compound OR generic compound
		final StructureChemicalCompound sccInBase = StructuralCompoundManagementService.readByInChIKey(inChIKey);
		if (sccInBase != null) {
			final Map<String, Object> results = new HashMap<String, Object>();
			results.put("id", sccInBase.getId());
			results.put("type", sccInBase.getType());
			return results;
		}
		// ADD NEW COMPOUND
		final ChemicalCompoundMapper mapper = new ChemicalCompoundMapper(names, inChIKey);
		mapper.setInChI(inChI);
		mapper.setChEBIId(chEBIID);
		mapper.setHmdbId(hmdbID);
		if (keggID != null && !keggID.isEmpty()) {
			mapper.setKeggId(keggID.get(0));
		}
		mapper.setPubChemId(pubChemID);
		final StructureChemicalCompound compound = StructuralCompoundManagementService.addOrUpdateCompound(mapper);
		if (compound == null) {
			throw new PeakForestManagerException(PeakForestManagerException.COULD_NOT_ADD_COMPOUND);
		} else {
			// log
			compoundLog("add new compound @id=" + compound.getId() + "; @inchikey=" + compound.getInChIKey());
			final Map<String, Object> results = new HashMap<String, Object>();
			results.put("id", compound.getId());
			results.put("type", compound.getType());
			return results;
		}
	}

//	@Secured("ROLE_EDITOR")
	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/get-citation-data", //
//			headers = { "Content-type=application/json" }, //
//			produces = MediaType.APPLICATION_JSON_VALUE, //
			params = { "query" }//
	)
	public @ResponseBody Object loadCitationData(//
			final @RequestParam("query") String query //
	)//
	{
		// init
		String queryClean = query.trim();
		// rexep
		final Pattern patternURL = Pattern.compile("^(https?)://dx.doi.org/(.*)$");
		final Matcher matcherURL = patternURL.matcher(queryClean);
		final Pattern patternURLBad = Pattern.compile("^dx.doi.org/(.*)$");
		final Matcher matcherURLBad = patternURLBad.matcher(queryClean);
		final Pattern patternDOI = Pattern.compile("^doi:(.*)$");
		final Matcher matcherDOI = patternDOI.matcher(queryClean);
		// 10.1093/bioinformatics/btu813
		if (matcherURL.find()) {
			queryClean = matcherURL.group(2);
		} else if (matcherURLBad.find()) {
			queryClean = matcherURLBad.group(1);
		} else if (matcherDOI.find()) {
			queryClean = matcherDOI.group(1);
		}
		if (queryClean.contains("/")) {
			queryClean = "" + queryClean;
		}
		final Map<String, Object> data = new HashMap<String, Object>();
		data.put("success", Boolean.FALSE);
		try {
			final EbiPubResults epubDataMapper = EbiPubClient.search(queryClean);
			if (epubDataMapper != null && //
					epubDataMapper.getResult() != null) {
				final EbiPubResult pubData = epubDataMapper.getResult();
				data.put("doi", pubData.getDoi());
				data.put("pmid", pubData.getPmid());
				data.put("apa", pubData.getApa());
				data.put("success", Boolean.TRUE);
			}
		} catch (final Exception e) {
			e.printStackTrace();
		}
		return data;
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/get-cpd-data", //
			params = { "inchikey" }//
	)
	public @ResponseBody Object loadCompoundData(//
			@RequestParam("inchikey") String inchikey//
	)//
			throws PeakForestManagerException {

		// init request
		Map<String, Object> data = new HashMap<String, Object>();
		boolean success = false;

		// load data

		StructureChemicalCompound refCompound = null;
		try {
			refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (refCompound == null)
			try {
				refCompound = GenericCompoundManagementService.readByInChIKey(inchikey);
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

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical"))
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		else if (type.equalsIgnoreCase("generic"))
			try {
				refCompound = GenericCompoundManagementService.read(id);
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

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		String type = "";
		try {
			long idL = Long.parseLong(id);
			try {
				refCompound = ChemicalCompoundManagementService.read(idL);
				type = "chemical";
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (refCompound == null)
				try {
					refCompound = GenericCompoundManagementService.read(idL);
					type = "generic";
				} catch (Exception e) {
					e.printStackTrace();
				}
		} catch (NumberFormatException e) {
			try {
				refCompound = StructuralCompoundManagementService.readByInChIKey(id);
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
	public String showCompoundMeta(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model,
			@PathVariable("id") String id) throws PeakForestManagerException {

		// load
		// load data
		StructureChemicalCompound refCompound = null;
		String type = "";
		try {
			long idL = Long.parseLong(id);
			try {
				refCompound = ChemicalCompoundManagementService.read(idL);
				type = "chemical";
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (refCompound == null)
				try {
					refCompound = GenericCompoundManagementService.read(idL);
					type = "generic";
				} catch (Exception e) {
					e.printStackTrace();
				}
		} catch (NumberFormatException e) {
			try {
				refCompound = StructuralCompoundManagementService.readByInChIKey(id);
				type = refCompound.getTypeString();
			} catch (Exception e1) {
				e1.printStackTrace();
			}
		}
		// TODO other

		// init var

		// load data in model
		if (refCompound != null)
			loadCompoundMeta(type, model, refCompound, request);
		return "block/meta";
	}

	@RequestMapping(value = "/load-children-chemical-compounds-names", method = RequestMethod.POST, params = {
			"parentId" })
	public @ResponseBody Object loadChildrenChemicalCompoundsData(@RequestParam("parentId") long parentId)
			throws PeakForestManagerException {

		Map<String, Object> data = new HashMap<String, Object>();
		boolean isSuccess = false;

		GenericCompound parentCompound = null;
		try {
			parentCompound = GenericCompoundManagementService.read(parentId);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (parentCompound != null) {
			List<Long> idChildrens = new ArrayList<Long>();
			for (ChemicalCompound cc : parentCompound.getChildren())
				idChildrens.add(cc.getId());
			try {
				// childs
				List<ChemicalCompound> children = ChemicalCompoundManagementService.read(idChildrens);
				for (ChemicalCompound cc : children) {
					cc = (ChemicalCompound) PeakForestPruneUtils.prune(cc);
					List<CompoundName> names = cc.getListOfCompoundNames();
					Collections.sort(names, new CompoundNameComparator());
					cc.setListOfCompoundNames(names);
				}
				data.put("chemicalCompounds", children);
				// parent
				List<CompoundName> names = parentCompound.getListOfCompoundNames();
				Collections.sort(names, new CompoundNameComparator());
				if (names.isEmpty())
					data.put("parentName", "");
				else
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

	@RequestMapping(value = "/load-gc-derivatives-names", method = RequestMethod.POST, params = { "parentId" })
	public @ResponseBody Object loadGCDerivativesData(@RequestParam("parentId") long parentId)
			throws PeakForestManagerException {

		Map<String, Object> data = new HashMap<String, Object>();
		boolean isSuccess = false;

		ReferenceChemicalCompound parentCompound = null;
		try {
			parentCompound = GenericCompoundManagementService.read(parentId);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (parentCompound == null) {
			try {
				parentCompound = ChemicalCompoundManagementService.read(parentId);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		if (parentCompound != null) {
			try {
				List<GCDerivedCompound> derivatives = new ArrayList<GCDerivedCompound>();
				for (GCDerivedCompoundMetadata derivativeMetadata : parentCompound
						.getListOfGCDerivedCompoundMetadata()) {
					Long idDerivative = null;
					GCDerivedCompound derivative;
					if (derivativeMetadata.getStructureDerivedCompound() != null) {
						idDerivative = derivativeMetadata.getStructureDerivedCompound().getId();

						// build name from parent (+ derivative types, like : "Citrulline 2-TMS")
						String constructedName = parentCompound.getMainName();
						if (derivativeMetadata.getDerivativeTypes() != null
								&& !derivativeMetadata.getDerivativeTypes().isEmpty()) {
							constructedName += " ";
							for (Short derivativeType : derivativeMetadata.getDerivativeTypes())
								constructedName += GCDerivedCompoundMetadata.getStringDerivativeType(derivativeType)
										+ ", ";
							constructedName = constructedName.substring(0, constructedName.lastIndexOf(", "));
						}

						derivative = GCDerivedCompoundDao.read(idDerivative, true, true, true, true, true, true);
						CompoundName derivativeName = new CompoundName(constructedName, null);
						derivativeName.setScore(3.5); // default score of built name from parent

						derivative = (GCDerivedCompound) PeakForestPruneUtils.prune(derivative);
						// TODO delete following line when prune for GCDerivedCompound is ready?
						derivative.setListOfCompoundMetadata(new ArrayList<GCDerivedCompoundMetadata>());
						List<CompoundName> names = derivative.getListOfCompoundNames();
						names.add(derivativeName);
						Collections.sort(names, new CompoundNameComparator());
						derivative.setListOfCompoundNames(names);

						derivatives.add(derivative);
					}
				}
				data.put("gcDerivedCompounds", derivatives);
				// parent
				List<CompoundName> names = parentCompound.getListOfCompoundNames();
				Collections.sort(names, new CompoundNameComparator());
				if (names.isEmpty())
					data.put("parentName", "");
				else
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
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/pick-one-compound-search", //
			params = { "query", "filter" }//
	)
	public String pickCompoundViewSearchCompound(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final @RequestParam("query") String query, //
			final @RequestParam("filter") int filter) {
		// init request
		final List<ReferenceChemicalCompound> resultsRaw = new ArrayList<ReferenceChemicalCompound>();
		final List<ReferenceChemicalCompound> resultsClean = new ArrayList<ReferenceChemicalCompound>();
		// search
		try {
			resultsRaw.addAll(SearchService.searchCompound(query, filter, SearchService.MAX_CPD_NAME_PER_CPD));
			if (resultsRaw.isEmpty()) {
				resultsRaw.addAll(SearchService.searchCompound(query, PeakForestUtils.SEARCH_COMPOUND_INCHIKEY,
						SearchService.MAX_CPD_NAME_PER_CPD));
			}
			// keep unic
			final List<Long> listOfUnicIds = new ArrayList<Long>();
			if (!resultsRaw.isEmpty()) {
				for (final ReferenceChemicalCompound ref : resultsRaw) {
					if (!listOfUnicIds.contains(ref.getId())) {
						listOfUnicIds.add(ref.getId());
						resultsClean.add(ref);
					}
				}
			}
			model.addAttribute("compounds", resultsClean);
		} catch (final PeakForestManagerException e) {
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
	public ModelAndView methodPFc(HttpServletResponse httpServletResponse, @PathVariable("query") String query) {
		// try {
		// return new ModelAndView("redirect:" + "/home?cpd=" +
		// Integer.parseInt(query));
		// } catch (NumberFormatException e) {
		return new ModelAndView("redirect:" + "/home?PFc=" + query);
		// }

	}

	@RequestMapping(value = "/js_cpd_sandbox/{inchikey}", method = RequestMethod.GET)
	public String showJSMolInCompoundSheet(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("inchikey") String inchikey) throws PeakForestManagerException {

		// init request
		StructureChemicalCompound refCompound = null;
		// if (type.equalsIgnoreCase("chemical"))
		try {
			refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey);
			if (refCompound == null)
				refCompound = GenericCompoundManagementService.readByInChIKey(inchikey);
		} catch (Exception e) {
			e.printStackTrace();
		}
		// NUMBERED FILES
		loadCompoundNumberedData(model, refCompound, inchikey);

		// RETURN
		return "module/jsmol_cpd_sandbox";
	}

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
	public String compoundExternalShow(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String source, @PathVariable String inchikey, Model model) throws PeakForestManagerException {
		// load data
		StructureChemicalCompound refCompound = null;

		try {
			refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey);

		} catch (Exception e) {
			e.printStackTrace();
		}
		if (refCompound == null)
			try {
				refCompound = GenericCompoundManagementService.readByInChIKey(inchikey);
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

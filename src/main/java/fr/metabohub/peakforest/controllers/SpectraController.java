package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jsoup.Jsoup;
import org.jsoup.safety.Whitelist;
import org.springframework.http.MediaType;
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
import org.springframework.web.servlet.view.RedirectView;

import fr.metabohub.externaltools.nmr.ViewerProcessing;
import fr.metabohub.peakforest.model.CurationMessage;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.model.metadata.AnalyticalMatrix;
import fr.metabohub.peakforest.model.metadata.AnalyzerMassIonization;
import fr.metabohub.peakforest.model.metadata.AnalyzerMassSpectrometerDevice;
import fr.metabohub.peakforest.model.metadata.AnalyzerNMRSpectrometerDevice;
import fr.metabohub.peakforest.model.metadata.LiquidChromatography;
import fr.metabohub.peakforest.model.metadata.OtherMetadata;
import fr.metabohub.peakforest.model.metadata.SampleMix;
import fr.metabohub.peakforest.model.metadata.SampleNMRTubeConditions;
import fr.metabohub.peakforest.model.spectrum.CompoundSpectrum;
import fr.metabohub.peakforest.model.spectrum.FragmentationLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanGCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.ILCSpectrum;
import fr.metabohub.peakforest.model.spectrum.MassPeak;
import fr.metabohub.peakforest.model.spectrum.MassSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMR1DPeak;
import fr.metabohub.peakforest.model.spectrum.NMR1DSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMR2DSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMRSpectrum;
import fr.metabohub.peakforest.model.spectrum.Peak;
import fr.metabohub.peakforest.model.spectrum.PeakPattern;
import fr.metabohub.peakforest.model.spectrum.Spectrum;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.services.CurationMessageManagementService;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.compound.StructuralCompoundManagementService;
import fr.metabohub.peakforest.services.metadata.AnalyzerMassIonizationMetadataManagementService;
import fr.metabohub.peakforest.services.metadata.AnalyzerMassSpectrometerDeviceMetadataManagementService;
import fr.metabohub.peakforest.services.metadata.AnalyzerNMRSpectrometerDeviceManagementService;
import fr.metabohub.peakforest.services.metadata.LiquidChromatographyMetadataManagementService;
import fr.metabohub.peakforest.services.metadata.OtherMetadataManagementService;
import fr.metabohub.peakforest.services.metadata.SampleMixMetadataManagementService;
import fr.metabohub.peakforest.services.metadata.SampleNMRTubeConditionsManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.ImportService;
import fr.metabohub.peakforest.services.spectrum.NMR1DSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.NMR2DSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.PeakPatternManagementService;
import fr.metabohub.peakforest.services.spectrum.SpectrumManagementService;
import fr.metabohub.peakforest.utils.ChromatoUtils;
import fr.metabohub.peakforest.utils.PeakComparator;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.SimpleFileReader;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;
import fr.metabohub.spectralibraries.mapper.PeakForestDataMapper;
import fr.metabohub.spectralibraries.utils.JsonTools;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
// @Configuration
// @EnableWebSecurity
// @EnableGlobalMethodSecurity(securedEnabled = true)
// @EnableGlobalMethodSecurity(prePostEnabled = true)
public class SpectraController {

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param id
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/compound-spectra-module/{type}/{id}", method = RequestMethod.GET)
	public String showSpectraInCompoundSheet(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String type, @PathVariable int id, Model model)
			throws PeakForestManagerException {
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
		if (refCompound != null)
			loadSpectraData(type, model, refCompound, request);

		// RETURN
		return "module/compound-spectra-module";
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
	@RequestMapping(value = "/compound-spectra-carrousel-light-module/{type}/{id}", method = RequestMethod.GET)
	public String showSpectraInCompoundModal(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String type, @PathVariable int id, Model model,
			@RequestParam("isExt") Boolean isExt) throws PeakForestManagerException {
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
		model.addAttribute("spectrum_load_legend", false); // full (case 03)
		model.addAttribute("spectrum_load_complementary_data", true); // light (case 01)
		model.addAttribute("spectrum_load_details_modalbox", false); // cpt-sheet (case 02)

		// load data in model
		if (refCompound != null)
			loadSpectraData(type, model, refCompound, request);

		model.addAttribute("set_width", "");

		if (isExt != null && isExt) {
			model.addAttribute("isExt", true);
		} else {
			model.addAttribute("isExt", false);
		}

		// RETURN
		return "module/compound-spectra-carrousel-module";
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
	@RequestMapping(value = "/compound-spectra-carrousel-full-module/{type}/{id}/{techFilter}", method = RequestMethod.GET)
	public String showSpectraInCompoundSheetByTech(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String type, @PathVariable long id, @PathVariable String techFilter,
			Model model, @RequestParam("isExt") Boolean isExt) throws PeakForestManagerException {
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
		model.addAttribute("spectrum_load_legend", false); // full (case 03)
		model.addAttribute("spectrum_load_complementary_data", true); // light (case 01)
		model.addAttribute("spectrum_load_details_modalbox", false); // cpt-sheet (case 02)

		// load data in model
		if (refCompound != null)
			loadSpectraData(type, model, refCompound, request);

		switch (techFilter) {
		case "all":
		default:
			break;
		case "lcms":
		case "lcmsms":
			// model.addAttribute("spectrum_mass_fullscan_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fullscan_gc", new ArrayList<Spectrum>());
			// model.addAttribute("spectrum_mass_fragmt_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_nmr", new ArrayList<Spectrum>());
			break;
		case "nmr":
			model.addAttribute("spectrum_mass_fullscan_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fullscan_gc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fragmt_lc", new ArrayList<Spectrum>());
			// model.addAttribute("spectrum_nmr", new ArrayList<Spectrum>());
			break;
		case "gcms":
			model.addAttribute("spectrum_mass_fullscan_lc", new ArrayList<Spectrum>());
			// model.addAttribute("spectrum_mass_fullscan_gc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fragmt_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_nmr", new ArrayList<Spectrum>());
			break;
		}

		model.addAttribute("set_width", "width:1000px; max-width:80%;");

		if (isExt != null && isExt) {
			model.addAttribute("isExt", true);
		} else {
			model.addAttribute("isExt", false);
		}

		// RETURN
		return "module/compound-spectra-carrousel-module";
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param fullscan
	 * @param frag
	 * @param model
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/load-lc-spetra", method = RequestMethod.POST, params = { "fullscan", "frag",
			"name", "mode", "id" })
	public String loadScriptLC(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@RequestParam("fullscan") List<Long> fullscan, @RequestParam("frag") List<Long> frag,
			@RequestParam("name") String name, @RequestParam("mode") String mode,
			@RequestParam("id") String id, Model model) throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		if (mode.equalsIgnoreCase("light")) {
			model.addAttribute("mode_light", true);
			model.addAttribute("spectrum_div_id", id);
			model.addAttribute("spectrum_load_legend", false);
		} else if (mode.equalsIgnoreCase("single")) {
			model.addAttribute("mode_light", false);
			model.addAttribute("spectrum_div_id", id);
			model.addAttribute("spectrum_load_legend", false);
		} else {
			model.addAttribute("mode_light", false);
			model.addAttribute("spectrum_div_id", "");
			model.addAttribute("spectrum_load_legend", true);
		}

		// basic
		model.addAttribute("spectrum_name", name.replaceAll("&amp;", "&"));

		// load spectrums data from DB
		List<FullScanLCSpectrum> listFullScanLcSpectra = new ArrayList<>();
		List<FullScanLCSpectrum> listFragLcSpectra = new ArrayList<>();
		try {
			listFullScanLcSpectra = FullScanLCSpectrumManagementService.read(fullscan, dbName, username,
					password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// TODO load frag. spectrum

		// I - load series
		int seriesCount = listFullScanLcSpectra.size() + listFragLcSpectra.size();
		// HashMap<String, String>[] seriesShow = new HashMap<String, String>[seriesCount];

		// I.A - series data (m/z vs RI)
		Object[] seriesShowData = new Object[seriesCount];
		Object[] seriesHideData = new Object[seriesCount];

		// I.B - series superdata (adducts / composition)
		Object[] seriesAdducts = new Object[seriesCount];
		Object[] seriesComposition = new Object[seriesCount];
		Object[] seriesNames = new Object[seriesCount];

		// I.C - load spectrum basic data
		Double minMass = 1000.0;
		Double maxMass = 10.0;

		// I.D - load metadata
		Object[] seriesSpectrumMetadata = new Object[seriesCount];

		// II.A - load series
		int cpt = 0;
		Double peakDelta = 0.0000001;
		Double peakHideRI = -100.0;
		for (FullScanLCSpectrum spectrum : listFullScanLcSpectra) {
			// basic data
			Double currentMassMin = spectrum.getRangeMassFrom();
			Double currentMassMax = spectrum.getRangeMassTo();
			if (currentMassMin != null && currentMassMin < minMass)
				minMass = currentMassMin;
			if (currentMassMax != null && currentMassMax > maxMass)
				maxMass = currentMassMax;
			HashMap<Double, Double> peakList = new HashMap<>();
			HashMap<Double, Double> peakListH = new HashMap<>();
			HashMap<Double, String> peakListAdducts = new HashMap<>();
			HashMap<Double, String> peakListComposition = new HashMap<>();
			// sort peaks
			List<Peak> peaklist = spectrum.getPeaks();
			Collections.sort(peaklist, new PeakComparator());
			for (Peak p : peaklist) {
				MassPeak mp = (MassPeak) p;
				// show
				peakList.put(mp.getMassToChargeRatio(), mp.getRelativeIntensity());
				// hide
				peakListH.put(mp.getMassToChargeRatio() - peakDelta, peakHideRI);
				peakListH.put(mp.getMassToChargeRatio(), mp.getRelativeIntensity());
				peakListH.put(mp.getMassToChargeRatio() + peakDelta, peakHideRI);
				// super data
				peakListAdducts.put(mp.getMassToChargeRatio(),
						Jsoup.clean(mp.getAttributionAsString(), Whitelist.basic()));
				peakListComposition.put(mp.getMassToChargeRatio(),
						Jsoup.clean(mp.getComposition(), Whitelist.basic()));
				// ...
				if (minMass.equals(mp.getMassToChargeRatio()))
					minMass -= (minMass * 0.1);
				if (maxMass.equals(mp.getMassToChargeRatio()))
					maxMass += (maxMass * 0.1);

			}
			seriesShowData[cpt] = peakList;
			seriesHideData[cpt] = peakListH;
			seriesAdducts[cpt] = peakListAdducts;
			seriesComposition[cpt] = peakListComposition;
			// used for name: load cpd
			List<Compound> listCC = new ArrayList<Compound>();
			if (spectrum instanceof CompoundSpectrum) {
				for (Compound c : spectrum.getListOfCompounds()) {
					if (c instanceof StructureChemicalCompound)
						try {
							listCC.add(StructuralCompoundManagementService.readByInChIKey(
									((StructureChemicalCompound) c).getInChIKey(), dbName, username,
									password));
						} catch (Exception e) {
							e.printStackTrace();
						}
					else
						listCC.add(c);
				}
				spectrum.setListOfCompounds(listCC);
			}
			// name
			String spectrumName = spectrum.getMassBankName();
			// if (spectrum.getPolarity() == MassSpectrum.MASS_SPECTRUM_POLARITY_POSITIVE)
			// spectrumName += "MS-POS";
			// else if (spectrum.getPolarity() == MassSpectrum.MASS_SPECTRUM_POLARITY_NEGATIVE)
			// spectrumName += "MS-NEG";
			String ionization = "";
			if (spectrum.getAnalyzerMassIonization() == null)
				ionization = spectrum.getAnalyzerMassIonization().getIonizationAsString();
			seriesNames[cpt] = spectrumName + " (" + (cpt + 1) + ")";
			// metadata
			HashMap<String, String> metadata = new HashMap<>();
			metadata.put("code", spectrumName);
			// metadata basic
			metadata.put("name", spectrum.getName());
			metadata.put("RT",
					"[" + spectrum.getRangeRetentionTimeFrom() + " - " + spectrum.getRangeMassTo() + "]");
			switch (spectrum.getPolarity()) {
			case MassSpectrum.MASS_SPECTRUM_POLARITY_POSITIVE:
				metadata.put("polarity", "POS");
				break;
			case MassSpectrum.MASS_SPECTRUM_POLARITY_NEGATIVE:
				metadata.put("polarity", "NEG");
				break;
			default:
				metadata.put("polarity", spectrum.getPolarity() + "");
				break;
			}
			metadata.put("ionization", ionization);
			// switch (spectrum.getIonization()) {
			// case MassSpectrum.MASS_SPECTRUM_IONIZATION_ESI:
			// metadata.put("ionization", "ESI");
			// break;
			// default:
			// metadata.put("ionization", spectrum.getIonization() + "");
			// break;
			// }
			// metadata raw
			metadata.put("label", spectrum.getLabel() + "");
			// metadata.put("date", spectrum.getOtherMetadata().getDate() + "");
			// metadata legal
			metadata.put("authors", spectrum.getOtherMetadata().getAuthors() + "");
			metadata.put("owners", spectrum.getOtherMetadata().getAuthors() + "");
			metadata.put("license", spectrum.getOtherMetadata().getLicense() + "");
			metadata.put("licenseOther", spectrum.getOtherMetadata().getLicenseOther() + "");
			seriesSpectrumMetadata[cpt] = metadata;
			cpt++;
		}

		// spectrum basic data
		model.addAttribute("spectrum_min_mass", minMass);
		model.addAttribute("spectrum_max_mass", maxMass);

		// spectrum series
		model.addAttribute("spectrum_series_show", seriesShowData);
		model.addAttribute("spectrum_series_hide", seriesHideData);
		model.addAttribute("spectrum_series_name", seriesNames);

		model.addAttribute("spectrum_series_composition", seriesComposition);
		model.addAttribute("spectrum_series_adducts", seriesAdducts);

		// metadata
		model.addAttribute("spectrum_series_metadata", seriesSpectrumMetadata);

		// LOAD SPECTRUMS
		return "module/load-lc-spectra-script";
	}

	/**
	 * @param type
	 * @param model
	 * @param refCompound
	 * @throws PeakForestManagerException
	 */
	private void loadSpectraData(String type, Model model, StructureChemicalCompound refCompound,
			HttpServletRequest request) throws PeakForestManagerException {

		// COMPOUND
		// sort names
		// List<CompoundName> listOfNames = refCompound.getListOfCompoundNames();
		// Collections.sort(listOfNames, new CompoundNameComparator());
		// for (CompoundName cn : listOfNames)
		// cn.setScore(Utils.round(cn.getScore(), 1));
		String cpdName = Jsoup.clean(refCompound.getMainName(), Whitelist.basic());
		cpdName = Utils.convertGreekCharToHTML(cpdName);
		model.addAttribute("compound_main_name", cpdName);
		model.addAttribute("compound_type", refCompound.getTypeString());
		model.addAttribute("compound_id", refCompound.getId());
		model.addAttribute("compound_inchikey", refCompound.getInChIKey());
		model.addAttribute("compound_pfID", refCompound.getPeakForestID());

		// SPECTRUM
		if (refCompound.getListOfSpectra().isEmpty())
			model.addAttribute("contains_spectrum", false);
		else {
			model.addAttribute("contains_spectrum", true);
			List<FullScanLCSpectrum> fullscanLcMsSpectrumList = new ArrayList<>();
			List<FullScanGCSpectrum> fullscanGcMsSpectrumList = new ArrayList<>();
			List<FragmentationLCSpectrum> fragLcMsSpectrumList = new ArrayList<>();
			List<NMRSpectrum> nmrSpectrumList = new ArrayList<>();
			for (Spectrum s : refCompound.getListOfSpectra()) {
				if (s instanceof FullScanLCSpectrum)
					fullscanLcMsSpectrumList.add((FullScanLCSpectrum) s);
				else if (s instanceof FullScanGCSpectrum)
					fullscanGcMsSpectrumList.add((FullScanGCSpectrum) s);
				else if (s instanceof FragmentationLCSpectrum)
					fragLcMsSpectrumList.add((FragmentationLCSpectrum) s);
				else if (s instanceof NMR1DSpectrum)
					nmrSpectrumList.add((NMR1DSpectrum) s);
				else if (s instanceof NMR2DSpectrum)
					nmrSpectrumList.add((NMR2DSpectrum) s);
				else {
					// other (NMR / uv)
				}
				if (s instanceof CompoundSpectrum) {
					List<Compound> cptList = new ArrayList<Compound>();
					cptList.add(refCompound);
					((CompoundSpectrum) s).setListOfCompounds(cptList);
				}
			}
			// model bind
			model.addAttribute("spectrum_mass_fullscan_lc", fullscanLcMsSpectrumList);
			model.addAttribute("spectrum_mass_fullscan_gc", fullscanGcMsSpectrumList);
			model.addAttribute("spectrum_mass_fragmt_lc", fragLcMsSpectrumList);
			model.addAttribute("spectrum_nmr", nmrSpectrumList);

			// first tab:
			if (!(fullscanLcMsSpectrumList.isEmpty() && fragLcMsSpectrumList.isEmpty()))
				model.addAttribute("first_tab_open", "lc-ms");
			else if (!nmrSpectrumList.isEmpty())
				model.addAttribute("first_tab_open", "nmr");
			else if (!fullscanGcMsSpectrumList.isEmpty())
				model.addAttribute("first_tab_open", "gc-ms");

			// ...
		}

		// END
	}

	// /**
	// * @param logMessage
	// */
	// private void spectrumLog(String logMessage) {
	// String username = "?";
	// if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
	// User user = null;
	// user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
	// username = user.getLogin();
	// }
	// SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	// }

	@RequestMapping(value = "/show-compound-spectra-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundspectraModalShow(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String type, @PathVariable int id, Model model)
			throws PeakForestManagerException {

		// model.addAttribute("id", id);
		// model.addAttribute("type", type);

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
		if (refCompound != null)
			loadSpectraData(type, model, refCompound, request);

		// RETURN
		return "modal/show-compound-spectra-modal";
	}

	@RequestMapping(value = "/show-spectra-modal/{ids}", method = RequestMethod.GET)
	public String spectraModalShow(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String ids, Model model) throws PeakForestManagerException {

		// load data
		model.addAttribute("ids", ids);

		// RETURN
		return "modal/show-spectra-modal";
	}

	@RequestMapping(value = "/spectra-light-module/{ids}", method = RequestMethod.GET)
	public String showSpectraInModal(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String ids, Model model) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// string to longs
		List<Long> spectrumIDs = new ArrayList<Long>();
		// String rawList = ids.replaceAll("\\[", "").replaceAll("\\]", "");
		String[] rawTab = ids.split("-");
		for (String s : rawTab)
			try {
				spectrumIDs.add(Long.parseLong(s));
			} catch (NumberFormatException e) {
			}

		// load data
		List<Spectrum> listOfAllSpectrum = new ArrayList<Spectrum>();
		try {
			listOfAllSpectrum = SpectrumManagementService.read(spectrumIDs, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var

		// load data in model
		loadSpectraData(model, listOfAllSpectrum, request);

		// RETURN
		return "module/spectra-light-module";
	}

	/**
	 * @param model
	 * @param spectrumIDs
	 * @param request
	 * @throws Exception
	 */
	private void loadSpectraData(Model model, List<Spectrum> spectra, HttpServletRequest request) {

		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// SPECTRUM
		if (spectra.isEmpty())
			model.addAttribute("contains_spectrum", false);
		else {
			model.addAttribute("contains_spectrum", true);
			List<FullScanLCSpectrum> fullscanLcMsSpectrumList = new ArrayList<>();
			List<FullScanGCSpectrum> fullscanGcMsSpectrumList = new ArrayList<>();
			List<FragmentationLCSpectrum> fragLcMsSpectrumList = new ArrayList<>();
			List<NMRSpectrum> nmrSpectrumList = new ArrayList<>();
			for (Spectrum s : spectra) {
				if (s instanceof FullScanLCSpectrum)
					fullscanLcMsSpectrumList.add((FullScanLCSpectrum) s);
				else if (s instanceof FullScanGCSpectrum)
					fullscanGcMsSpectrumList.add((FullScanGCSpectrum) s);
				else if (s instanceof FragmentationLCSpectrum)
					fragLcMsSpectrumList.add((FragmentationLCSpectrum) s);
				else if (s instanceof NMR1DSpectrum)
					nmrSpectrumList.add((NMR1DSpectrum) s);
				else if (s instanceof NMR2DSpectrum)
					nmrSpectrumList.add((NMR2DSpectrum) s);
				else {
					// other (NMR / uv)
				}
				// cpd name
				if (s instanceof CompoundSpectrum
						&& s.getSample() == Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND) {
					CompoundSpectrum cs = (CompoundSpectrum) s;
					if (cs.getListOfCompounds().size() == 1) {
						Compound c = cs.getListOfCompounds().get(0);
						if (c instanceof StructureChemicalCompound) {
							try {
								c = StructuralCompoundManagementService.readByInChIKey(
										((StructureChemicalCompound) c).getInChIKey(), dbName, username,
										password);
								List<Compound> listC = new ArrayList<Compound>();
								listC.add(c);
								cs.setListOfCompounds(listC);
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					}
				}
			}
			// model bind
			model.addAttribute("spectrum_mass_fullscan_lc", fullscanLcMsSpectrumList);
			model.addAttribute("spectrum_mass_fullscan_gc", fullscanGcMsSpectrumList);
			model.addAttribute("spectrum_mass_fragmt_lc", fragLcMsSpectrumList);
			model.addAttribute("spectrum_nmr", nmrSpectrumList);

			// first tab:
			if (!(fullscanLcMsSpectrumList.isEmpty() && fragLcMsSpectrumList.isEmpty()))
				model.addAttribute("first_tab_open", "lc-ms");
			else if (!nmrSpectrumList.isEmpty())
				model.addAttribute("first_tab_open", "nmr");
			else if (!fullscanGcMsSpectrumList.isEmpty())
				model.addAttribute("first_tab_open", "gc-ms");
			// ...
		}

		// END
	}

	// ///////////////////////
	// NMR

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param nmr
	 * @param name
	 * @param mode
	 *            light or full
	 * @param id
	 * @param model
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/load-nmr-1d-spectra", method = RequestMethod.POST, params = { "nmr", "name",
			"mode", "id" })
	public String loadScriptNMR1D(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@RequestParam("nmr") List<Long> nmr, @RequestParam("name") String name,
			@RequestParam("mode") String mode, @RequestParam("id") String id, Model model)
			throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		if (mode.equalsIgnoreCase("light")) {
			model.addAttribute("mode_light", true);
			model.addAttribute("spectrum_div_id", id);
			model.addAttribute("spectrum_load_legend", false);
		} else if (mode.equalsIgnoreCase("single")) {
			model.addAttribute("mode_light", false);
			model.addAttribute("spectrum_div_id", id);
			model.addAttribute("spectrum_load_legend", false);
		} else {
			model.addAttribute("mode_light", false);
			model.addAttribute("spectrum_div_id", "");
			model.addAttribute("spectrum_load_legend", true);
		}

		// basic
		model.addAttribute("spectrum_name", name.replaceAll("&amp;", "&"));

		// load spectrums data from DB
		List<NMR1DSpectrum> listNMRSpectra = new ArrayList<>();
		// List<FullScanLCSpectrum> listFragLcSpectra = new ArrayList<>();
		try {
			listNMRSpectra = NMR1DSpectrumManagementService.read(nmr, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// I - load series
		int seriesCount = listNMRSpectra.size();
		// HashMap<String, String>[] seriesShow = new HashMap<String, String>[seriesCount];

		// I.A - series data (m/z vs RI)
		Object[] seriesShowData = new Object[seriesCount];
		// Object[] seriesHideData = new Object[seriesCount];

		// I.B - series superdata (adducts / composition)
		Object[] seriesComposition = new Object[seriesCount];
		Object[] seriesNames = new Object[seriesCount];

		// I.C - load spectrum basic data
		Double minChemicalShift = 10000.0;
		Double maxChemicalShift = 1.0;

		// I.D - load metadata
		Object[] seriesSpectrumMetadata = new Object[seriesCount];

		// II.A - load series
		int cpt = 0;
		Double peakDelta = 0.0000001;
		Double peakHideRI = -100.0;
		for (NMR1DSpectrum spectrum : listNMRSpectra) {
			// basic data
			Double currentChemicalShiftMin = null;
			Double currentChemicalShiftMax = null;
			HashMap<Double, Double> peakList = new HashMap<>();
			// HashMap<Double, Double> peakListH = new HashMap<>();
			// HashMap<Double, Short> peakListAdducts = new HashMap<>();
			HashMap<Double, String> peakListAnnotation = new HashMap<>();
			// sort peaks
			List<Peak> peaklist = spectrum.getPeaks();
			Collections.sort(peaklist, new PeakComparator());

			for (Peak p : peaklist) {
				NMR1DPeak mp = (NMR1DPeak) p;
				// show
				// Double halfWidthChemShift = 0.0;
				Double chemicalShift = mp.getChemicalShift() * -1;

				peakList.put(chemicalShift, mp.getRelativeIntensity());
				// hide
				peakList.put(chemicalShift - peakDelta, peakHideRI);
				peakList.put(chemicalShift + peakDelta, peakHideRI);

				if (mp.getHalfWidth() != null) {
					if (currentChemicalShiftMin == null)
						currentChemicalShiftMin = mp.getChemicalShift() - mp.getHalfWidth();
					if (currentChemicalShiftMax == null)
						currentChemicalShiftMax = mp.getChemicalShift() + mp.getHalfWidth();
					if ((mp.getChemicalShift() - mp.getHalfWidth()) < currentChemicalShiftMin)
						currentChemicalShiftMin = (mp.getChemicalShift() - mp.getHalfWidth());
					if ((mp.getChemicalShift() + mp.getHalfWidth()) > currentChemicalShiftMax)
						currentChemicalShiftMax = (mp.getChemicalShift() + mp.getHalfWidth());
				} else {
					if (currentChemicalShiftMin == null)
						currentChemicalShiftMin = mp.getChemicalShift();
					if (currentChemicalShiftMax == null)
						currentChemicalShiftMax = mp.getChemicalShift();
					if ((mp.getChemicalShift()) < currentChemicalShiftMin)
						currentChemicalShiftMin = (mp.getChemicalShift());
					if ((mp.getChemicalShift()) > currentChemicalShiftMax)
						currentChemicalShiftMax = (mp.getChemicalShift());
				}
				// // hide
				// peakListH.put(chemicalShift - peakDelta, peakHideRI);
				// peakListH.put(chemicalShift, mp.getRelativeIntensity());
				// peakListH.put(chemicalShift + peakDelta, peakHideRI);
				// super data
				// peakListAdducts.put(chemicalShift, mp.getAttribution());
				if (mp.getAnnotation() != null)
					peakListAnnotation.put(chemicalShift, mp.getAnnotation().replaceAll("\"", "\\\""));
				else
					peakListAnnotation.put(chemicalShift, "?");

				peakListAnnotation.put(chemicalShift - peakDelta, "");
				peakListAnnotation.put(chemicalShift + peakDelta, "");
				// ...
			}

			if (currentChemicalShiftMin != null && currentChemicalShiftMin < minChemicalShift)
				minChemicalShift = currentChemicalShiftMin;
			if (currentChemicalShiftMax != null && currentChemicalShiftMax > maxChemicalShift)
				maxChemicalShift = currentChemicalShiftMax;

			minChemicalShift -= (minChemicalShift * 0.05);
			maxChemicalShift += (maxChemicalShift * 0.05);

			seriesShowData[cpt] = peakList;
			// seriesHideData[cpt] = peakListH;
			seriesComposition[cpt] = peakListAnnotation;
			// used for name: load cpd
			List<Compound> listCC = new ArrayList<Compound>();
			if (spectrum instanceof CompoundSpectrum) {
				for (Compound c : spectrum.getListOfCompounds()) {
					if (c instanceof StructureChemicalCompound)
						try {
							listCC.add(StructuralCompoundManagementService.readByInChIKey(
									((StructureChemicalCompound) c).getInChIKey(), dbName, username,
									password));
						} catch (Exception e) {
							e.printStackTrace();
						}
					else
						listCC.add(c);
				}
				spectrum.setListOfCompounds(listCC);
			}
			// name
			String spectrumName = "" + spectrum.getMassBankLikeName();
			// spectrumName += "[" + spectrum.getPulseSequence() + "]";
			seriesNames[cpt] = spectrumName + " (" + (cpt + 1) + ")";
			// metadata
			HashMap<String, String> metadata = new HashMap<>();
			metadata.put("code", spectrumName);
			// metadata basic
			metadata.put("name", spectrum.getName());

			// switch (spectrum.getIonization()) {
			// case MassSpectrum.MASS_SPECTRUM_IONIZATION_ESI:
			// metadata.put("ionization", "ESI");
			// break;
			// default:
			// metadata.put("ionization", spectrum.getIonization() + "");
			// break;
			// }
			// metadata raw
			metadata.put("label", spectrum.getLabel() + "");
			// metadata.put("date", spectrum.getOtherMetadata().getDate() + "");
			// metadata legal
			metadata.put("authors", spectrum.getOtherMetadata().getAuthors() + "");
			metadata.put("owners", spectrum.getOtherMetadata().getAuthors() + "");
			metadata.put("license", spectrum.getOtherMetadata().getLicense() + "");
			metadata.put("licenseOther", spectrum.getOtherMetadata().getLicenseOther() + "");
			seriesSpectrumMetadata[cpt] = metadata;
			cpt++;
		}

		// spectrum basic data
		model.addAttribute("spectrum_min_x", (-1.0 * maxChemicalShift));
		model.addAttribute("spectrum_max_x", (-1.0 * minChemicalShift));

		// spectrum series
		model.addAttribute("spectrum_series_show", seriesShowData);
		// model.addAttribute("spectrum_series_hide", seriesHideData);
		model.addAttribute("spectrum_series_name", seriesNames);

		model.addAttribute("spectrum_series_composition", seriesComposition);

		// metadata
		model.addAttribute("spectrum_series_metadata", seriesSpectrumMetadata);

		// LOAD SPECTRUMS
		return "module/load-nmr-spectra-script";
	}

	// ////////////////////////////////////////////////////////////////////////
	// add spectrum
	@Secured("ROLE_EDITOR")
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/addOneSpectrum", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	@ResponseBody
	public Object addOneSpectrum(@RequestBody Map<String, Object> jsonData, HttpServletRequest request)
			throws Exception {

		// get template type;
		// boolean isGCMS = false;
		boolean isLCMS = false;
		// boolean isLCMSMS = false;
		boolean isNMR = false;
		// boolean isLCNMR = false;

		boolean success = true;
		String error = "";

		if (jsonData.containsKey("dumper_type") && jsonData.get("dumper_type") instanceof String) {
			switch (jsonData.get("dumper_type").toString()) {
			case "lc-ms":
				isLCMS = true;
				break;
			case "nmr":
				isNMR = true;
				break;
			// TODO lc-msms / gc-ms / lc-nmr / ...
			default:
				// not supported
				break;
			}
		}

		// init peak forest data mapper
		PeakForestDataMapper dataMapper = null;
		if (isLCMS)
			dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_LC_MS);
		else if (isNMR)
			dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_NMR);
		else
			dataMapper = new PeakForestDataMapper();

		// fulfill peakforest data mapper from JSON object
		success = JsonTools.jsonToMapper(jsonData, dataMapper);

		Map<String, Object> idMetadata = new HashMap<String, Object>();
		if (jsonData.containsKey("metadata_map") && jsonData.get("metadata_map") != null
				&& jsonData.get("metadata_map") instanceof LinkedHashMap<?, ?>)
			idMetadata = (Map<String, Object>) jsonData.get("metadata_map");

		if (success) {
			// call API function from API and return the object itself
			Map<String, Object> response = ImportService.importSpectraDataMapper(dataMapper, idMetadata,
					Utils.getBundleConfElement("hibernate.connection.database.dbName"),
					Utils.getBundleConfElement("hibernate.connection.database.username"),
					Utils.getBundleConfElement("hibernate.connection.database.password"));
			// response.put("success", success);
			return response;
		} else {
			error = "could_not_read_json";
			Map<String, Object> response = new HashMap<String, Object>();
			response.put("success", success);
			response.put("error", error);
			return response;
		}

	}

	@RequestMapping(value = "/addOneSpectrum", method = RequestMethod.POST)
	public @ResponseBody RedirectView redirectHome(HttpServletRequest request, HttpServletResponse response,
			Locale locale) {
		return new RedirectView("home");
	}

	// @RequestMapping(value = "/pf:{query}", method = RequestMethod.GET)
	// public ModelAndView method(HttpServletResponse httpServletResponse, @PathVariable("query") String
	// query) {
	// return new ModelAndView("redirect:" + "/home?pf=" + query);
	// }

	@RequestMapping(value = "/PFs{query}", method = RequestMethod.GET)
	public ModelAndView methodPFs(HttpServletResponse httpServletResponse,
			@PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?PFs=" + query);
	}

	/**
	 * Keep a support of old URI
	 * 
	 * @param httpServletResponse
	 * @param query
	 * @return
	 */
	@RequestMapping(value = "/pf:{query}", method = RequestMethod.GET)
	public ModelAndView methodPF(HttpServletResponse httpServletResponse,
			@PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?PFs=" + query);
	}

	@RequestMapping(value = "/pf={query}", method = RequestMethod.GET)
	public ModelAndView methodPF2(HttpServletResponse httpServletResponse,
			@PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?PFs=" + query);
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @param id
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/sheet-spectrum/{id}", method = RequestMethod.GET)
	public String showSpectraSheet(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("id") long id) throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load spectra data
		// List<Long> spectrumIDs = new ArrayList<Long>();
		// spectrumIDs.add(Long.parseLong(id));
		// spectrumIDs.add(id);
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService.readByInChIKey(
								((StructureChemicalCompound) c).getInChIKey(), dbName, username, password));
					} catch (Exception e) {
						e.printStackTrace();
					}
				else
					listCC.add(c);
			}
			((CompoundSpectrum) spectrum).setListOfCompounds(listCC);
		}

		// load data in model
		if (spectrum != null) {
			try {
				loadSpectraMetadata(model, spectrum, request, dbName, username, password);
				model.addAttribute("contains_spectrum", true);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} else
			model.addAttribute("contains_spectrum", false);

		User user = null;
		long userId = -1;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			userId = user.getId();
		}

		if (user != null && user.isConfirmed()) {
			model.addAttribute("editor", true);
			List<CurationMessage> waitingCurationMessageUser = new ArrayList<CurationMessage>();
			for (CurationMessage cm : spectrum.getCurationMessages())
				if (cm.getStatus() == CurationMessage.STATUS_WAITING && cm.getUserID() == userId) {
					cm.setMessage(Jsoup.clean(cm.getMessage(), Whitelist.basic()));
					waitingCurationMessageUser.add(cm);
				}
			model.addAttribute("waitingCurationMessageUser", waitingCurationMessageUser);
		} else
			model.addAttribute("editor", false);

		if (user != null && user.isCurator()) {
			model.addAttribute("curator", true);
			model.addAttribute("curationMessages", spectrum.getCurationMessages());
		} else
			model.addAttribute("curator", false);

		return "module/sheet-spectrum-module";
	}

	@RequestMapping(value = "/data-ranking-spectrum/{id}", method = RequestMethod.GET)
	public String showSpectraMeta(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("id") long id) throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load spectra data
		// List<Long> spectrumIDs = new ArrayList<Long>();
		// spectrumIDs.add(Long.parseLong(id));
		// spectrumIDs.add(id);
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService.readByInChIKey(
								((StructureChemicalCompound) c).getInChIKey(), dbName, username, password));
					} catch (Exception e) {
						e.printStackTrace();
					}
				else
					listCC.add(c);
			}
			((CompoundSpectrum) spectrum).setListOfCompounds(listCC);
		}

		// load data in model
		if (spectrum != null) {
			try {
				loadSpectraMeta(model, spectrum, request, dbName, username, password);
				model.addAttribute("contains_spectrum", true);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} else
			model.addAttribute("contains_spectrum", false);

		return "block/meta";
	}

	/**
	 * @param model
	 * @param spectrum
	 * @param request
	 * @throws Exception
	 */
	private void loadSpectraMetadata(Model model, Spectrum spectrum, HttpServletRequest request,
			String dbName, String username, String password) throws Exception {

		// BASIC DATA
		model.addAttribute("spectrum_id", spectrum.getId());
		model.addAttribute("spectrum_name", Utils.convertGreekCharToHTML(spectrum.getName()));
		model.addAttribute("spectrum_pfID", spectrum.getPeakForestID());
		model.addAttribute("spectrum_splash", spectrum.getSplash());

		// SAMPLE DATA
		// boolean displaySampleMix = false;
		SampleMix sampleMixData = null;
		switch (spectrum.getSample()) {
		case Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND:
			model.addAttribute("spectrum_sample_type", "single-cpd");
			StructureChemicalCompound rcc = null;
			if (((CompoundSpectrum) spectrum).getListOfCompounds().size() == 1) {
				rcc = (StructureChemicalCompound) ((CompoundSpectrum) spectrum).getListOfCompounds().get(0);
				// rcc = StructuralCompoundManagementService.readByInChIKey(rcc.getInChIKey(), dbName,
				// username,
				// password);
				model.addAttribute("spectrum_sample_compound_id", rcc.getId());
				model.addAttribute("spectrum_sample_compound_type", rcc.getTypeString());
				model.addAttribute("spectrum_sample_compound_name", rcc.getMainName());
				model.addAttribute("spectrum_sample_compound_inchikey", rcc.getInChIKey());
				model.addAttribute("spectrum_sample_compound_inchi", rcc.getInChI());
				model.addAttribute("spectrum_sample_compound_formula", rcc.getFormula());
				model.addAttribute("spectrum_sample_compound_exact_mass", rcc.getExactMass());
				model.addAttribute("spectrum_sample_compound_mol_weight", rcc.getMolWeight());
				model.addAttribute("spectrum_sample_compound_pfID", rcc.getPeakForestID());

				if (spectrum instanceof NMRSpectrum) {
					// get mol path
					String molFileRepPath = Utils.getBundleConfElement("compoundMolFiles.folder");
					if (!(new File(molFileRepPath)).exists())
						throw new PeakForestManagerException(
								PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);
					// set if has numbered compoudn
					CompoundsController.loadCompoundNumberedData(model, rcc, rcc.getInChIKey());
					model.addAttribute("spectrum_sample_compound_display_numbered_mol", true);
					// set if has raw data
					model.addAttribute("spectrum_has_raw_data", ((NMRSpectrum) spectrum).hasRawData());
				} else {
					model.addAttribute("spectrum_sample_compound_display_numbered_mol", false);
					model.addAttribute("spectrum_has_raw_data", false);
				}

			}
			model.addAttribute("spectrum_sample_compound_has_concentration", false);
			if (spectrum.getSampleMixMetadata() != null) {
				SampleMix mixData = SampleMixMetadataManagementService
						.read(spectrum.getSampleMixMetadata().getId(), dbName, username, password);
				if (mixData.getCompoundConcentration(rcc.getInChIKey()) != null) {
					model.addAttribute("spectrum_sample_compound_has_concentration", true);
					model.addAttribute("spectrum_sample_compound_concentration",
							mixData.getCompoundConcentration(rcc.getInChIKey()));
				}
				model.addAttribute("spectrum_sample_compound_mass_solvent", mixData.getMsSolventAsString());
			}
			break;
		case Spectrum.SPECTRUM_SAMPLE_MIX_CHEMICAL_COMPOUND:
			model.addAttribute("spectrum_sample_type", "mix-cpd");
			if (spectrum.getSampleMixMetadata() != null) {
				sampleMixData = SampleMixMetadataManagementService
						.read(spectrum.getSampleMixMetadata().getId(), dbName, username, password);
				// if (mixData.getCompoundConcentration(rcc.getInChIKey()) != null) {
				// model.addAttribute("spectrum_sample_compound_has_concentration", true);
				// model.addAttribute("spectrum_sample_compound_concentration",
				// mixData.getCompoundConcentration(rcc.getInChIKey()));
				// }
				model.addAttribute("spectrum_sample_compound_mass_solvent",
						sampleMixData.getMssolventMixAsString());
			}
			break;
		case Spectrum.SPECTRUM_SAMPLE_STANDARDIZED_MATRIX:
			model.addAttribute("spectrum_sample_type", "std-matrix");
			if (spectrum.getSampleMixMetadata() != null)
				sampleMixData = SampleMixMetadataManagementService
						.read(spectrum.getSampleMixMetadata().getId(), dbName, username, password);
			AnalyticalMatrix analyticalMatrix = spectrum.getAnalyticalMatrixMetadata();
			if (analyticalMatrix != null) {
				model.addAttribute("spectrum_matrix_name", analyticalMatrix.getMatrixTypeAsString());
				model.addAttribute("spectrum_matrix_link", analyticalMatrix.getMatrixTypeOntology());
			}
			break;
		case Spectrum.SPECTRUM_SAMPLE_ANALYTICAL_MATRIX:
			model.addAttribute("spectrum_sample_type", "analytical-matrix");
			// TODO
			break;
		default:
			break;
		}

		if (sampleMixData != null) {
			List<StructureChemicalCompound> listCpdMix = new ArrayList<StructureChemicalCompound>();
			List<Long> idCpdToRead = new ArrayList<Long>();
			for (StructureChemicalCompound scc : sampleMixData.getCompound2ConcentrationMap().keySet())
				idCpdToRead.add(scc.getId());
			listCpdMix
					.addAll(ChemicalCompoundManagementService.read(idCpdToRead, dbName, username, password));
			listCpdMix.addAll(GenericCompoundManagementService.read(idCpdToRead, dbName, username, password));
			model.addAttribute("spectrum_sample_mix_tab", listCpdMix);
			model.addAttribute("spectrum_sample_mix_data", sampleMixData);
			if (!listCpdMix.isEmpty())
				model.addAttribute("spectrum_sample_mix_display", true);
			else
				model.addAttribute("spectrum_sample_mix_display", false);
		} else
			model.addAttribute("spectrum_sample_mix_display", false);

		model.addAttribute("spectrum_has_main_compound", false);
		if (spectrum instanceof CompoundSpectrum) {
			if (((CompoundSpectrum) spectrum).getListOfCompounds().size() == 1) {
				Compound mainCompound = ((CompoundSpectrum) spectrum).getListOfCompounds().get(0);
				if (mainCompound instanceof StructureChemicalCompound) {
					model.addAttribute("spectrum_has_main_compound", true);
					model.addAttribute("spectrum_main_compound", mainCompound);
				}
			}
		}

		if (spectrum instanceof NMRSpectrum) {
			NMRSpectrum abstractSpec = (NMRSpectrum) spectrum;

			// BASIC
			model.addAttribute("spectrum_type", "nmr");
			model.addAttribute("spectrum_chromatography", "none");

			// SAMPLE NMR DATA
			model.addAttribute("spectrum_nmr_tube_prep", (abstractSpec).getSampleNMRTubeConditionsMetadata());

			if (spectrum instanceof NMR1DSpectrum) {
				// name display
				model.addAttribute("spectrum_name",
						Utils.convertGreekCharToHTML(((NMR1DSpectrum) spectrum).getMassBankLikeName()));
				// Acquisition
				if (((NMR1DSpectrum) spectrum).getAcquisition() != null)
					model.addAttribute("spectrum_nmr_analyzer_data_acquisition",
							((NMR1DSpectrum) spectrum).getAcquisitionAsString());

				// NMR ANALYZER + PEAKLIST TAB + PATTERN LIST TAB
				model.addAttribute("spectrum_nmr_analyzer",
						(abstractSpec).getAnalyzerNMRSpectrometerDevice());
				NMR1DSpectrum nmrSpectrum = NMR1DSpectrumManagementService.read((abstractSpec).getId(),
						dbName, username, password);
				model.addAttribute("spectrum_nmr_analyzer_data", nmrSpectrum);
				List<PeakPattern> peakpatterns = new ArrayList<PeakPattern>();
				for (PeakPattern pp : nmrSpectrum.getListOfpeakPattern()) {
					peakpatterns
							.add(PeakPatternManagementService.read(pp.getId(), dbName, username, password));
				}
				model.addAttribute("spectrum_nmr_peakpatterns", peakpatterns);
			} else if (spectrum instanceof NMR2DSpectrum) {
				// name display
				model.addAttribute("spectrum_name",
						Utils.convertGreekCharToHTML(((NMR2DSpectrum) spectrum).getMassBankLikeName()));
				// Acquisition
				if (((NMR2DSpectrum) spectrum).getAcquisition() != null)
					model.addAttribute("spectrum_nmr_analyzer_data_acquisition",
							((NMR2DSpectrum) spectrum).getAcquisitionAsString());
				// NMR ANALYZER + PEAKLIST TAB + PATTERN LIST TAB
				model.addAttribute("spectrum_nmr_analyzer",
						(abstractSpec).getAnalyzerNMRSpectrometerDevice());
				NMR2DSpectrum nmrSpectrum = NMR2DSpectrumManagementService.read((abstractSpec).getId(),
						dbName, username, password);
				model.addAttribute("spectrum_nmr_analyzer_data", nmrSpectrum);
			}

			// use this field if system able to display "real" spectrum (lorentzienne)
			model.addAttribute("display_real_spectrum", abstractSpec.hasRawData());
			model.addAttribute("real_spectrum_code", abstractSpec.getRawDataFolder());

		} else if (spectrum instanceof FullScanLCSpectrum) {
			// BASIC
			model.addAttribute("spectrum_name",
					Utils.convertGreekCharToHTML(((FullScanLCSpectrum) spectrum).getMassBankName()));
			model.addAttribute("spectrum_type", "lc-fullscan");
			// LC DATA
			model.addAttribute("spectrum_chromatography", "lc");
			LiquidChromatography lcData = LiquidChromatographyMetadataManagementService.read(
					((FullScanLCSpectrum) spectrum).getLiquidChromatography().getId(), dbName, username,
					password);
			model.addAttribute("spectrum_chromatography_method", lcData.getMethodProtocolAsString());
			model.addAttribute("spectrum_chromatography_col_constructor",
					lcData.getColumnConstructorAString());
			model.addAttribute("spectrum_chromatography_col_name", lcData.getColumnName());
			model.addAttribute("spectrum_chromatography_col_length", lcData.getColumnLength());
			model.addAttribute("spectrum_chromatography_col_diameter", lcData.getColumnDiameter());
			model.addAttribute("spectrum_chromatography_col_particule_size", lcData.getParticuleSize());
			model.addAttribute("spectrum_chromatography_col_temperature", lcData.getColumnTemperature());
			model.addAttribute("spectrum_chromatography_mode_lc", lcData.getLCModeAsString());
			model.addAttribute("spectrum_chromatography_solventA", lcData.getSolventAAsString());
			model.addAttribute("spectrum_chromatography_solventB", lcData.getSolventBAsString());
			model.addAttribute("spectrum_chromatography_solventApH", lcData.getpHSolventA());
			model.addAttribute("spectrum_chromatography_solventBpH", lcData.getpHSolventB());
			model.addAttribute("spectrum_chromatography_separation_flow_rate",
					lcData.getSeparationFlowRate());
			// ..
			// Separation flow grad
			List<Double> sortedKeys = new ArrayList<Double>(lcData.getSeparationFlowGradient().keySet());
			Collections.sort(sortedKeys);
			Double[] time = new Double[sortedKeys.size()];
			int i = 0;
			for (Double k : sortedKeys) {
				time[i] = k;
				i++;
			}
			model.addAttribute("spectrum_chromatography_sfg_time", time);
			model.addAttribute("spectrum_chromatography_sfg", lcData.getSeparationFlowGradient());
			// IONIZATION
			model.addAttribute("spectrum_ms_ionization",
					((MassSpectrum) spectrum).getAnalyzerMassIonization());

			// MS ANALYZER
			model.addAttribute("spectrum_ms_analyzer",
					((MassSpectrum) spectrum).getAnalyzerMassSpectrometerDevice());

			// PEAKLIST DATA
			model.addAttribute("spectrum_ms_polarity", "");
			if (((MassSpectrum) spectrum).getPolarity() != null) {
				switch (((MassSpectrum) spectrum).getPolarity()) {
				case MassSpectrum.MASS_SPECTRUM_POLARITY_POSITIVE:
					model.addAttribute("spectrum_ms_polarity", "POS");
					break;
				case MassSpectrum.MASS_SPECTRUM_POLARITY_NEGATIVE:
					model.addAttribute("spectrum_ms_polarity", "NEG");
					break;
				default:
					break;
				}
			}
			model.addAttribute("spectrum_ms_resolution", "");
			if (((MassSpectrum) spectrum).getResolution() != null) {
				switch (((MassSpectrum) spectrum).getResolution()) {
				case MassSpectrum.MASS_SPECTRUM_RESOLUTION_HIGH:
					model.addAttribute("spectrum_ms_resolution", "high");
					break;
				case MassSpectrum.MASS_SPECTRUM_RESOLUTION_LOW:
					model.addAttribute("spectrum_ms_resolution", "low");
					break;
				default:
					break;
				}
			}
			model.addAttribute("spectrum_ms_resolution_FWHM",
					((MassSpectrum) spectrum).getInstrumentResolutionFWHM());
			model.addAttribute("spectrum_ms_scan_type", "MS (fullscan)");
			model.addAttribute("spectrum_ms_range_from", ((MassSpectrum) spectrum).getRangeMassFrom());
			model.addAttribute("spectrum_ms_range_to", ((MassSpectrum) spectrum).getRangeMassTo());
			model.addAttribute("spectrum_rt_min_from",
					shortifyText(((FullScanLCSpectrum) spectrum).getRangeRetentionTimeFrom()));
			model.addAttribute("spectrum_rt_min_to",
					shortifyText(((FullScanLCSpectrum) spectrum).getRangeRetentionTimeTo()));
			model.addAttribute("spectrum_rt_meoh_from", shortifyText(
					((FullScanLCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentFrom()));
			model.addAttribute("spectrum_rt_meoh_to",
					shortifyText(((FullScanLCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentTo()));
			//
			try {
				model.addAttribute("spectrum_rt_acn_from",
						shortifyText(
								(((FullScanLCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentFrom())
										* ChromatoUtils.MEOH_TO_ACN_RATIO));
			} catch (NullPointerException npe) {
			}
			try {
				model.addAttribute("spectrum_rt_acn_to",
						shortifyText(
								(((FullScanLCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentTo())
										* ChromatoUtils.MEOH_TO_ACN_RATIO));
			} catch (NullPointerException npe) {
			}
			//
			// PEAKLIST TAB
			model.addAttribute("spectrum_ms_peaks", spectrum.getPeaks());

		}

		// METADATA OTHER
		OtherMetadata otherMetadata = spectrum.getOtherMetadata();
		otherMetadata = OtherMetadataManagementService.read(otherMetadata.getId(), dbName, username,
				password);
		model.addAttribute("spectrum_othermetadata", otherMetadata);

		// RELATED SPECTRA (same other metadata)
		List<Spectrum> relatedSpectra = new ArrayList<Spectrum>();
		for (Spectrum s : otherMetadata.getListOfSpectrum()) {
			if (s instanceof CompoundSpectrum) {
				//
				if (s.getSample() == Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND) {
					((CompoundSpectrum) s)
							.setListOfCompounds(((CompoundSpectrum) spectrum).getListOfCompounds());
				}
			}
			s.setMetadata(spectrum.getMetadata());
			if (s.getId() != spectrum.getId())
				relatedSpectra.add(s);
		}
		if (relatedSpectra.isEmpty())
			model.addAttribute("spectrum_has_related_spectra", false);
		else
			model.addAttribute("spectrum_has_related_spectra", true);
		model.addAttribute("spectrum_related_spectra", relatedSpectra);

		// END
	}

	private void loadSpectraMeta(Model model, Spectrum spectrum, HttpServletRequest request, String dbName,
			String username, String password) throws Exception {

		// BASIC DATA
		String spectrumName = Utils.convertGreekCharToHTML(spectrum.getName());
		String spectrumTechnique = "";
		String spectrumOther = "";

		model.addAttribute("spectrum_id", spectrum.getId());
		model.addAttribute("spectrum_name", spectrumName);
		model.addAttribute("spectrum_pfID", spectrum.getPeakForestID());
		model.addAttribute("spectrum_splash", spectrum.getSplash());

		// SAMPLE DATA
		// boolean displaySampleMix = false;
		switch (spectrum.getSample()) {
		case Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND:
			StructureChemicalCompound rcc = null;
			if (((CompoundSpectrum) spectrum).getListOfCompounds().size() == 1) {
				rcc = (StructureChemicalCompound) ((CompoundSpectrum) spectrum).getListOfCompounds().get(0);
				spectrumOther += ", " + rcc.getMainName() + "";
			}
			break;
		case Spectrum.SPECTRUM_SAMPLE_MIX_CHEMICAL_COMPOUND:
			break;
		case Spectrum.SPECTRUM_SAMPLE_STANDARDIZED_MATRIX:
			break;
		case Spectrum.SPECTRUM_SAMPLE_ANALYTICAL_MATRIX:
			// TODO
			break;
		default:
			break;
		}

		if (spectrum instanceof NMR1DSpectrum) {
			spectrumName = Utils.convertGreekCharToHTML(((NMR1DSpectrum) spectrum).getMassBankLikeName());
			spectrumTechnique += ", NMR";
			// BASIC
			model.addAttribute("spectrum_name",
					Utils.convertGreekCharToHTML(((NMR1DSpectrum) spectrum).getMassBankLikeName()));
			// Acquisition
			if (((NMR1DSpectrum) spectrum).getAcquisition() != null)
				spectrumTechnique += ", " + ((NMR1DSpectrum) spectrum).getAcquisitionAsString();
		} else if (spectrum instanceof NMR2DSpectrum) {
			spectrumName = Utils.convertGreekCharToHTML(((NMR2DSpectrum) spectrum).getMassBankLikeName());
			spectrumTechnique += ", NMR";
			// BASIC
			model.addAttribute("spectrum_name",
					Utils.convertGreekCharToHTML(((NMR2DSpectrum) spectrum).getMassBankLikeName()));
			// Acquisition
			if (((NMR2DSpectrum) spectrum).getAcquisition() != null)
				spectrumTechnique += ", " + ((NMR2DSpectrum) spectrum).getAcquisitionAsString();
		} else if (spectrum instanceof FullScanLCSpectrum) {
			spectrumName = Utils.convertGreekCharToHTML(((FullScanLCSpectrum) spectrum).getMassBankName());
			spectrumTechnique += ", LCMS";
		}

		// ranking
		model.addAttribute("ranking_data", true);
		model.addAttribute("page_title", spectrumName);
		model.addAttribute("page_keyworks", spectrumName + spectrumTechnique + spectrumOther);
		model.addAttribute("page_description",
				"spectrum " + spectrumName + " identified as pf:" + spectrum.getId());

		// END
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/update-spectrum/{id}", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	@SuppressWarnings("unchecked")
	@ResponseBody
	public boolean updateSpectrum(@PathVariable long id, @RequestBody Map<String, Object> data,
			HttpServletRequest request) {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		Spectrum spectrum;
		try {
			spectrum = SpectrumManagementService.read(id, dbName, username, password);
		} catch (Exception e1) {
			e1.printStackTrace();
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
				CurationMessageManagementService.create(curationMessages, user.getId(), spectrum, dbName,
						username, password);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}

		// log
		spectrumLog("update spectrum @id=" + id + "; ");

		return true;
	}

	@Secured("ROLE_CURATOR")
	@RequestMapping(value = "/edit-spectrum-modal/{id}", method = RequestMethod.GET)
	public String spectrumEdit(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable int id, Model model) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// load data

		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService.readByInChIKey(
								((StructureChemicalCompound) c).getInChIKey(), dbName, username, password));
					} catch (Exception e) {
						e.printStackTrace();
					}
				else
					listCC.add(c);
			}
			((CompoundSpectrum) spectrum).setListOfCompounds(listCC);
		}

		// load data in model
		if (spectrum != null) {
			try {
				loadSpectraMetadata(model, spectrum, request, dbName, username, password);
				model.addAttribute("contains_spectrum", true);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} else
			model.addAttribute("contains_spectrum", false);

		User user = null;
		// long userId = -1;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			// userId = user.getId();
		}

		if (user != null && user.isCurator()) {
			model.addAttribute("curator", true);
			model.addAttribute("curationMessages", spectrum.getCurationMessages());
		} else
			model.addAttribute("curator", false);

		// RETURN
		return "modal/edit-spectrum-modal";
	}

	// @RequestMapping(value = "/spectra-full-module/{ids}", method = RequestMethod.GET)
	// public String showSpectraInSheet(HttpServletRequest request, HttpServletResponse response, Locale
	// locale,
	// @PathVariable String ids, Model model) throws PeakForestManagerException {
	// // init request
	// String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
	// String username = Utils.getBundleConfElement("hibernate.connection.database.username");
	// String password = Utils.getBundleConfElement("hibernate.connection.database.password");
	//
	// // string to longs
	// List<Long> spectrumIDs = new ArrayList<Long>();
	// // String rawList = ids.replaceAll("\\[", "").replaceAll("\\]", "");
	// String[] rawTab = ids.split("-");
	// for (String s : rawTab)
	// try {
	// spectrumIDs.add(Long.parseLong(s));
	// } catch (NumberFormatException e) {
	// }
	//
	// // load data
	// List<Spectrum> listOfAllSpectrum = new ArrayList<Spectrum>();
	// try {
	// listOfAllSpectrum = SpectrumManagementService.read(spectrumIDs, dbName, username, password);
	// } catch (Exception e) {
	// e.printStackTrace();
	// }
	//
	// // init var
	//
	// // load data in model
	// loadSpectraData(model, listOfAllSpectrum, request);
	//
	// // RETURN
	// return "module/spectra-full-module";
	// }

	@Secured("ROLE_CURATOR")
	@RequestMapping(value = "/delete-spectrum/{type}/{id}", method = RequestMethod.POST)
	@ResponseBody
	public Object spectrumDelete(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable long id, @PathVariable String type, Model model) throws PeakForestManagerException {
		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load data
		try {
			// return SpectrumManagementService.delete(id, dbName, username, password);
			// FullScanLCSpectrumManagementService.d
			switch (type) {
			case "lc-fullscan":
				return FullScanLCSpectrumManagementService.delete(id, dbName, username, password);
			case "nmr":
				return NMR1DSpectrumManagementService.delete(id, dbName, username, password);
			case "nmr-2d":
				return NMR2DSpectrumManagementService.delete(id, dbName, username, password);
			default:
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	/**
	 * @param id
	 * @param data
	 * @return
	 */
	@Secured("ROLE_EDITOR")
	@RequestMapping(value = "/edit-spectrum/{id}", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	@ResponseBody
	@SuppressWarnings("unchecked")
	public boolean editSpectrum(@PathVariable long id, @RequestBody Map<String, Object> data) {

		// TODO remove @Secured annotation and begin this function with check if user either a curator of the
		// owner of this spectrum

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		try {
			// 0 - init
			// fetch spectrum in db;
			Spectrum spectrum = SpectrumManagementService.read(id, dbName, username, password);
			// ready to read json
			Map<String, Object> spectrumDataToUpdate = (Map<String, Object>) data.get("newSpectrumData");

			// I - update SAMPLE data
			boolean updateSampleMetadata = false;
			boolean updateSampleMixRCCMap = false;

			// I.A - fetch metadata in db
			SampleMix sampleMixData = null;
			Map<StructureChemicalCompound, Double> newMap = new HashMap<>();
			switch (spectrum.getSample()) {
			case Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND:
				// TODO keep it in case of user can edit RCC related to a cpd
				StructureChemicalCompound rcc = null;
				if (((CompoundSpectrum) spectrum).getListOfCompounds().size() == 1) {
					rcc = (StructureChemicalCompound) ((CompoundSpectrum) spectrum).getListOfCompounds()
							.get(0);
					// model.addAttribute("spectrum_sample_compound_id", rcc.getId());
				}
				if (spectrum.getSampleMixMetadata() != null) {
					sampleMixData = SampleMixMetadataManagementService
							.read(spectrum.getSampleMixMetadata().getId(), dbName, username, password);
					// update Ref CC concentration
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_concentration")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_concentration") != null) {
						Double newConcentration = null;
						try {
							newConcentration = Double.parseDouble(spectrumDataToUpdate
									.get("spectrum_sample_compound_concentration").toString());
							updateSampleMetadata = true;
							updateSampleMixRCCMap = true;
						} catch (NumberFormatException nfe) {
						}
						if (newConcentration != null) {
							sampleMixData.addCompound(rcc, newConcentration);
							newMap.put(rcc, newConcentration);
						} else
							sampleMixData.removeCompound(rcc);
					}

					// sample solvent
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_mass_solvent")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_mass_solvent") != null) {
						sampleMixData.setMSsolvent(SampleMix.getStandardizedMSsolvent(
								(String) spectrumDataToUpdate.get("spectrum_sample_compound_mass_solvent")));
						updateSampleMetadata = true;
					}
				}
				break;
			case Spectrum.SPECTRUM_SAMPLE_MIX_CHEMICAL_COMPOUND:
				if (spectrum.getSampleMixMetadata() != null) {
					sampleMixData = SampleMixMetadataManagementService
							.read(spectrum.getSampleMixMetadata().getId(), dbName, username, password);

					// sample mix solvent
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_mass_solvent_mix")
							&& spectrumDataToUpdate
									.get("spectrum_sample_compound_mass_solvent_mix") != null) {
						sampleMixData.setMSsolvent(
								SampleMix.getStandardizedMSsolventMix((String) spectrumDataToUpdate
										.get("spectrum_sample_compound_mass_solvent_mix")));
						updateSampleMetadata = true;
					}
				}
				break;
			case Spectrum.SPECTRUM_SAMPLE_STANDARDIZED_MATRIX:
				if (spectrum.getSampleMixMetadata() != null)
					sampleMixData = SampleMixMetadataManagementService
							.read(spectrum.getSampleMixMetadata().getId(), dbName, username, password);
				AnalyticalMatrix analyticalMatrix = spectrum.getAnalyticalMatrixMetadata();
				if (analyticalMatrix != null) {
					// model.addAttribute("spectrum_matrix_name", analyticalMatrix.getMatrixTypeAsString());
					// model.addAttribute("spectrum_matrix_link", analyticalMatrix.getStdMatrixLink());
				}
				break;
			case Spectrum.SPECTRUM_SAMPLE_ANALYTICAL_MATRIX:
				// TODO
				break;
			default:
				break;
			}

			// if key update sample mix not null
			if (spectrumDataToUpdate.containsKey("spectrum_sample_mix_tab")
					&& spectrumDataToUpdate.get("spectrum_sample_mix_tab") != null) {
				if (spectrumDataToUpdate.get("spectrum_sample_mix_tab") instanceof ArrayList<?>) {
					updateSampleMetadata = true;
					updateSampleMixRCCMap = true;
					newMap = new HashMap<>();
					ArrayList<Map<String, Object>> rawCpdMixList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
							.get("spectrum_sample_mix_tab");
					for (Map<String, Object> rawCpdMixData : rawCpdMixList) {
						if (rawCpdMixData.containsKey("inchikey") && rawCpdMixData.get("inchikey") != null
								&& rawCpdMixData.containsKey("concentration")
								&& rawCpdMixData.get("concentration") != null) {
							String inChIKey = rawCpdMixData.get("inchikey").toString();
							double coucentration = 0.0;
							StructureChemicalCompound scc = StructuralCompoundManagementService
									.readByInChIKey(inChIKey, dbName, username, password);
							try {
								coucentration = Double
										.parseDouble(rawCpdMixData.get("concentration").toString());
							} catch (NumberFormatException nef) {
							}
							newMap.put(scc, coucentration);
						}
					}
				}
			}

			// I.B - update metadata in db
			if (updateSampleMetadata) {
				// sampleMixData.setCompound2ConcentrationMap(newMap);
				if (!updateSampleMixRCCMap)
					newMap = sampleMixData.getCompound2ConcentrationMap();
				if (!SampleMixMetadataManagementService.update(sampleMixData.getId(),
						sampleMixData.getMSsolvent(), newMap, dbName, username, password))
					return false;
			}

			// I.C - update NMR sample tube metadata
			if (spectrum instanceof NMR1DSpectrum) {
				boolean updateSampleNMRtube = false;
				SampleNMRTubeConditions nmrTubeMetadata = SampleNMRTubeConditionsManagementService.read(
						((NMR1DSpectrum) spectrum).getSampleNMRTubeConditionsMetadata().getId(), dbName,
						username, password);

				// spectrum_nmr_tube_prep_solvent
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_solvent")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_solvent") != null) {
					nmrTubeMetadata.setSolventNMR(SampleNMRTubeConditions.getStandardizedNMRsolvent(
							(String) spectrumDataToUpdate.get("spectrum_nmr_tube_prep_solvent")));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_poentiaHydrogenii
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_poentiaHydrogenii")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_poentiaHydrogenii") != null) {
					try {
						nmrTubeMetadata
								.setPotentiaHydrogenii(Double.parseDouble(((String) spectrumDataToUpdate
										.get("spectrum_nmr_tube_prep_poentiaHydrogenii"))));
						updateSampleNMRtube = true;
					} catch (NumberFormatException nfe) {
					}
				}

				// spectrum_nmr_tube_prep_ref_chemical_shift_indocator
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_ref_chemical_shift_indocator")
						&& spectrumDataToUpdate
								.get("spectrum_nmr_tube_prep_ref_chemical_shift_indocator") != null) {
					nmrTubeMetadata.setReferenceChemicalShifIndicator(SampleNMRTubeConditions
							.getStandardizedNMRreferenceChemicalShifIndicator((String) spectrumDataToUpdate
									.get("spectrum_nmr_tube_prep_ref_chemical_shift_indocator")));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other
				if (spectrumDataToUpdate
						.containsKey("spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other")
						&& spectrumDataToUpdate
								.get("spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other") != null) {
					nmrTubeMetadata.setReferenceChemicalShifIndicatorOther((String) spectrumDataToUpdate
							.get("spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other"));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_ref_concentration
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_ref_concentration")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_ref_concentration") != null) {
					try {
						nmrTubeMetadata
								.setReferenceConcentration(Double.parseDouble(((String) spectrumDataToUpdate
										.get("spectrum_nmr_tube_prep_ref_concentration"))));
						updateSampleNMRtube = true;
					} catch (NumberFormatException nfe) {
					}
				}

				// spectrum_nmr_tube_prep_lock_substance
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_lock_substance")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_lock_substance") != null) {
					nmrTubeMetadata.setLockSubstance(SampleNMRTubeConditions.getStandardizedNMRlockSubstance(
							(String) spectrumDataToUpdate.get("spectrum_nmr_tube_prep_lock_substance")));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_lock_substance_vol_concentration
				if (spectrumDataToUpdate
						.containsKey("spectrum_nmr_tube_prep_lock_substance_vol_concentration")
						&& spectrumDataToUpdate
								.get("spectrum_nmr_tube_prep_lock_substance_vol_concentration") != null) {
					try {
						nmrTubeMetadata.setLockSubstanceVolumicConcentration(
								Double.parseDouble(((String) spectrumDataToUpdate
										.get("spectrum_nmr_tube_prep_lock_substance_vol_concentration"))));
						updateSampleNMRtube = true;
					} catch (NumberFormatException nfe) {
					}
				}

				// spectrum_nmr_tube_prep_buffer_solution
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_lock_substance")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_lock_substance") != null) {
					nmrTubeMetadata.setBufferSolution(SampleNMRTubeConditions
							.getStandardizedNMRbufferSolution((String) spectrumDataToUpdate
									.get("spectrum_nmr_tube_prep_lock_substance")));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_buffer_solution_concentration
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_buffer_solution_concentration")
						&& spectrumDataToUpdate
								.get("spectrum_nmr_tube_prep_buffer_solution_concentration") != null) {
					try {
						nmrTubeMetadata.setBufferSolutionConcentration(
								Double.parseDouble(((String) spectrumDataToUpdate
										.get("spectrum_nmr_tube_prep_buffer_solution_concentration"))));
						updateSampleNMRtube = true;
					} catch (NumberFormatException nfe) {
					}
				}

				// spectrum_nmr_tube_prep_iso_D_labelling
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_iso_D_labelling")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_iso_D_labelling") != null) {
					if (spectrumDataToUpdate.get("spectrum_nmr_tube_prep_iso_D_labelling").toString()
							.equalsIgnoreCase("yes")) {
						nmrTubeMetadata.setDeuteriumIsotopicLabelling(true);
					} else {
						nmrTubeMetadata.setDeuteriumIsotopicLabelling(false);
					}
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_iso_C_labelling
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_iso_C_labelling")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_iso_C_labelling") != null) {
					if (spectrumDataToUpdate.get("spectrum_nmr_tube_prep_iso_C_labelling").toString()
							.equalsIgnoreCase("yes")) {
						nmrTubeMetadata.setCarbon13IsotopicLabelling(true);
					} else {
						nmrTubeMetadata.setCarbon13IsotopicLabelling(false);
					}
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_iso_N_labelling
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_iso_N_labelling")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_iso_N_labelling") != null) {
					if (spectrumDataToUpdate.get("spectrum_nmr_tube_prep_iso_N_labelling").toString()
							.equalsIgnoreCase("yes")) {
						nmrTubeMetadata.setNitrogenIsotopicLabelling(true);
					} else {
						nmrTubeMetadata.setNitrogenIsotopicLabelling(false);
					}
					updateSampleNMRtube = true;
				}

				// mop mop
				if (updateSampleNMRtube) {
					if (!SampleNMRTubeConditionsManagementService.update(nmrTubeMetadata.getId(),
							nmrTubeMetadata, dbName, username, password))
						return false;
				}
			}

			// II - update LC chromato data
			if (spectrum instanceof ILCSpectrum) {
				// II.A - init var
				boolean updateLCchromatoData = false;
				LiquidChromatography lcMetadata = LiquidChromatographyMetadataManagementService.read(
						((ILCSpectrum) spectrum).getLiquidChromatography().getId(), dbName, username,
						password);

				// II.B - update object
				// spectrum_chromatography_col_constructor: "Thermo"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_constructor")) {
					updateLCchromatoData = true;
					lcMetadata.setColumnConstructor(LiquidChromatography.getStandardizedColumnConstructor(
							spectrumDataToUpdate.get("spectrum_chromatography_col_constructor").toString()));
				}

				// spectrum_chromatography_col_constructor_other
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_constructor_other")) {
					updateLCchromatoData = true;
					lcMetadata.setColumnOther(spectrumDataToUpdate
							.get("spectrum_chromatography_col_constructor_other").toString());
				}

				// spectrum_chromatography_col_diameter: "2.1"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_diameter")) {
					updateLCchromatoData = true;
					Double colDiam = null;
					try {
						colDiam = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_col_diameter").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setColumnDiameter(colDiam);
				}

				// spectrum_chromatography_col_length: "100.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_length")) {
					updateLCchromatoData = true;
					Double collength = null;
					try {
						collength = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_col_length").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setColumnLength(collength);
				}

				// spectrum_chromatography_col_name: "Hypersil Gold C18"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_name")) {
					updateLCchromatoData = true;
					lcMetadata.setColumnName(
							spectrumDataToUpdate.get("spectrum_chromatography_col_name").toString());
				}

				// spectrum_chromatography_col_particule_size: "1.9"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_particule_size")) {
					updateLCchromatoData = true;
					Double colPartiSize = null;
					try {
						colPartiSize = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_chromatography_col_particule_size").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setParticuleSize(colPartiSize);
				}

				// spectrum_chromatography_col_temperature: "40.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_temperature")) {
					updateLCchromatoData = true;
					Double colTemp = null;
					try {
						colTemp = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_chromatography_col_temperature").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setColumnTemperature(colTemp);
				}

				// spectrum_chromatography_method: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_method")) {
					updateLCchromatoData = true;
					lcMetadata.setMethodProtocol(LiquidChromatography.getStandardizedMethodProtocol(
							spectrumDataToUpdate.get("spectrum_chromatography_method").toString()));
				}

				// spectrum_chromatography_mode_lc: "Isocratique"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_mode_lc")) {
					updateLCchromatoData = true;
					lcMetadata.setLcMode(LiquidChromatography.getStandardizedLCMode(
							spectrumDataToUpdate.get("spectrum_chromatography_mode_lc").toString()));
				}

				// spectrum_chromatography_separation_flow_rate: "300.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_separation_flow_rate")) {
					updateLCchromatoData = true;
					Double sfgRate = null;
					try {
						sfgRate = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_chromatography_separation_flow_rate").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setSeparationFlowRate(sfgRate);
				}

				// spectrum_chromatography_solventA: "H2O / CH3OH / CH3CO2H (95/5/0.1)"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_solventA")) {
					updateLCchromatoData = true;
					lcMetadata.setSeparationSolventA(LiquidChromatography.getStandardizedSolventName(
							spectrumDataToUpdate.get("spectrum_chromatography_solventA").toString()));
				}

				// spectrum_chromatography_solventApH: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_solventApH")) {
					updateLCchromatoData = true;
					Double pH = null;
					try {
						pH = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_solventApH").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setpHSolventA(pH);
				}

				// spectrum_chromatography_solventB: "Methanol / CH3CO2H (100/0.1)"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_solventB")) {
					updateLCchromatoData = true;
					lcMetadata.setSeparationSolventB(LiquidChromatography.getStandardizedSolventName(
							spectrumDataToUpdate.get("spectrum_chromatography_solventB").toString()));
				}

				// spectrum_chromatography_solventBpH: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_solventBpH")) {
					updateLCchromatoData = true;
					Double pH = null;
					try {
						pH = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_solventBpH").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setpHSolventB(pH);
				}

				// spectrum_chromatography_sfg_time
				Map<Double, Double[]> newSFG = lcMetadata.getSeparationFlowGradient();
				if (spectrumDataToUpdate.containsKey("spectrum_chromatography_sfg_time")
						&& spectrumDataToUpdate.get("spectrum_chromatography_sfg_time") != null) {
					if (spectrumDataToUpdate
							.get("spectrum_chromatography_sfg_time") instanceof ArrayList<?>) {
						newSFG = new HashMap<>();
						updateLCchromatoData = true;
						ArrayList<Map<String, Object>> rawSFG = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_chromatography_sfg_time");
						for (Map<String, Object> rawCpdMixData : rawSFG) {
							if (rawCpdMixData.containsKey("time") && rawCpdMixData.get("time") != null
									&& rawCpdMixData.containsKey("a") && rawCpdMixData.get("a") != null
									&& rawCpdMixData.containsKey("b") && rawCpdMixData.get("b") != null) {
								String timeS = rawCpdMixData.get("time").toString();
								String aS = rawCpdMixData.get("a").toString();
								String bS = rawCpdMixData.get("b").toString();
								try {
									double time = Double.parseDouble(timeS);
									double a = Double.parseDouble(aS);
									double b = Double.parseDouble(bS);
									Double[] tabSFG = new Double[2];
									tabSFG[0] = a;
									tabSFG[1] = b;
									newSFG.put(time, tabSFG);
								} catch (NumberFormatException nfe) {
								}

							}
						}
					}
				}

				// II.C - save object (if needed)
				if (updateLCchromatoData) {
					LiquidChromatographyMetadataManagementService.update(lcMetadata.getId(), lcMetadata,
							newSFG, dbName, username, password);
				}
			}

			// III - update MASS analyzer data.
			// III.A - init var
			boolean updateMSanalyzer = false;
			boolean updateMSionization = false;
			boolean updateMSranges = false;

			Double msRangeMassFrom = null;
			Double msRangeMassTo = null;
			Double msRangeRTminFrom = null;
			Double msRangeRTminTo = null;
			Double msRangeRTmeohFrom = null;
			Double msRangeRTmeohTo = null;

			Integer msResolutionFWHMresolution = null;
			Integer msResolutionFWHMmass = null;

			AnalyzerMassSpectrometerDevice msAnalyzerMetatada = null;
			AnalyzerMassIonization msIonizationMetatada = null;

			if (spectrum instanceof MassSpectrum) {
				msAnalyzerMetatada = ((MassSpectrum) spectrum).getAnalyzerMassSpectrometerDevice();
				msIonizationMetatada = ((MassSpectrum) spectrum).getAnalyzerMassIonization();

				// III.A.1 - analyzer

				// spectrum_ms_analyzer_instrument_model: "XL"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_instrument_model")) {
					updateMSanalyzer = true;
					msAnalyzerMetatada.setInstrumentModel(
							spectrumDataToUpdate.get("spectrum_ms_analyzer_instrument_model").toString());
				}
				// spectrum_ms_analyzer_instrument_name: "LTQ Orbitap"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_instrument_name")) {
					updateMSanalyzer = true;
					msAnalyzerMetatada.setInstrumentName(
							spectrumDataToUpdate.get("spectrum_ms_analyzer_instrument_name").toString());
				}
				// spectrum_ms_analyzer_ion_analyzer_type: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_ion_analyzer_type")) {
					updateMSanalyzer = true;
					msAnalyzerMetatada.setIonAnalyzerType(
							spectrumDataToUpdate.get("spectrum_ms_analyzer_ion_analyzer_type").toString());
				}
				// spectrum_ms_analyzer_resolution_fwhm: "30000@"
				// if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_resolution_fwhm")) {
				// updateMSanalyzer = true;
				// String[] tabData = spectrumDataToUpdate.get("spectrum_ms_analyzer_resolution_fwhm")
				// .toString().split("@");
				// Integer instrumentResolutionFWHMresolution = null;
				// Integer instrumentResolutionFWHMmass = null;
				// try {
				// if (tabData.length == 0) {
				//
				// } else if (tabData.length == 1) {
				//
				// instrumentResolutionFWHMresolution = Integer.parseInt(tabData[0]);
				// } else if (tabData.length == 2) {
				// instrumentResolutionFWHMresolution = Integer.parseInt(tabData[0]);
				// instrumentResolutionFWHMmass = Integer.parseInt(tabData[1]);
				// }
				// } catch (NumberFormatException nfe) {
				// }
				// msAnalyzerMetatada
				// .setInstrumentResolutionFWHMresolution(instrumentResolutionFWHMresolution);
				// msAnalyzerMetatada.setInstrumentResolutionFWHMmass(instrumentResolutionFWHMmass);
				// }

				// III.A.2 - ionization

				// spectrum_ms_ionization_ion_transfer_temperature: "300.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ion_transfer_temperature")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_ms_ionization_ion_transfer_temperature").toString());
					} catch (NumberFormatException nfe) {
					}
					msIonizationMetatada.setIonTransferTemperature(newVal);
				}

				// spectrum_ms_ionization_ionization_method: "ESI"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ionization_method")) {
					updateMSionization = true;
					msIonizationMetatada.setIonization(AnalyzerMassIonization.getStandardizedIonization(
							spectrumDataToUpdate.get("spectrum_ms_ionization_ionization_method").toString()));
				}

				// spectrum_ms_ionization_ionization_voltage: "4.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ionization_voltage")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_ms_ionization_ionization_voltage").toString());
					} catch (NumberFormatException nfe) {
					}
					msIonizationMetatada.setIonizationVoltage(newVal);
				}

				// spectrum_ms_ionization_source_gaz_flow: "0.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_source_gaz_flow")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_ms_ionization_source_gaz_flow").toString());
					} catch (NumberFormatException nfe) {
					}
					msIonizationMetatada.setSourceGazFlow(newVal);
				}

				// spectrum_ms_ionization_spray_gaz_flow: "55.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_spray_gaz_flow")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_ionization_spray_gaz_flow").toString());
					} catch (NumberFormatException nfe) {
					}
					msIonizationMetatada.setSprayGazFlow(newVal);
				}

				// spectrum_ms_ionization_vaporizer_gaz_flow: "10.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_vaporizer_gaz_flow")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_ms_ionization_vaporizer_gaz_flow").toString());
					} catch (NumberFormatException nfe) {
					}
					msIonizationMetatada.setVaporizerGazFlow(newVal);
				}

				// spectrum_ms_ionization_vaporizer_tempertature: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_vaporizer_tempertature")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_ms_ionization_vaporizer_tempertature").toString());
					} catch (NumberFormatException nfe) {
					}
					msIonizationMetatada.setVaporizerTemperature(newVal);
				}

				// get original data
				msRangeMassFrom = ((MassSpectrum) spectrum).getRangeMassFrom();
				msRangeMassTo = ((MassSpectrum) spectrum).getRangeMassTo();
				msRangeRTminFrom = ((MassSpectrum) spectrum).getRangeRetentionTimeFrom();
				msRangeRTminTo = ((MassSpectrum) spectrum).getRangeRetentionTimeTo();
				msResolutionFWHMresolution = ((MassSpectrum) spectrum)
						.getInstrumentResolutionFWHMresolution();
				msResolutionFWHMmass = ((MassSpectrum) spectrum).getInstrumentResolutionFWHMmass();

				// get updated data

				// spectrum_ms_range_mass_from: "80.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_range_mass_from")) {
					updateMSranges = true;
					try {
						msRangeMassFrom = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_range_mass_from").toString());
					} catch (NumberFormatException e) {
					}
				}

				// spectrum_ms_range_mass_to: "800.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_range_mass_to")) {
					updateMSranges = true;
					try {
						msRangeMassTo = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_range_mass_to").toString());
					} catch (NumberFormatException e) {
					}
				}

				// spectrum_ms_rt_min_from: "10.55"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_min_from")) {
					updateMSranges = true;
					try {
						msRangeRTminFrom = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_min_from").toString());
					} catch (NumberFormatException e) {
					}
				}

				// spectrum_ms_rt_min_to: "10.75"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_min_to")) {
					updateMSranges = true;
					try {
						msRangeRTminTo = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_min_to").toString());
					} catch (NumberFormatException e) {
					}
				}

				// // spectrum_ms_analyzer_resolution_fwhm: "30000@"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_resolution_fwhm")) {
					updateMSanalyzer = true;
					String[] tabData = spectrumDataToUpdate.get("spectrum_ms_analyzer_resolution_fwhm")
							.toString().split("@");
					try {
						if (tabData.length == 0) {
						} else if (tabData.length == 1) {
							msResolutionFWHMresolution = Integer.parseInt(tabData[0]);
							updateMSranges = true;
						} else if (tabData.length == 2) {
							msResolutionFWHMresolution = Integer.parseInt(tabData[0]);
							msResolutionFWHMmass = Integer.parseInt(tabData[1]);
							updateMSranges = true;
						}
					} catch (NumberFormatException nfe) {
					}
				}
			}

			if (spectrum instanceof ILCSpectrum) {
				// get original data
				msRangeRTmeohFrom = ((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentFrom();
				msRangeRTmeohTo = ((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentTo();

				// get updated data
				// spectrum_ms_rt_meoh_from: "40.16"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_meoh_from")) {
					updateMSranges = true;
					try {
						msRangeRTmeohFrom = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_meoh_from").toString());
					} catch (NumberFormatException e) {
					}
				}

				// spectrum_ms_rt_meoh_to: "40.83"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_meoh_to")) {
					updateMSranges = true;
					try {
						msRangeRTmeohTo = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_meoh_to").toString());
					} catch (NumberFormatException e) {
					}
				}
			}

			// III.B - update object
			// II.C - save object (if needed)
			if (updateMSanalyzer) {
				AnalyzerMassSpectrometerDeviceMetadataManagementService.update(msAnalyzerMetatada.getId(),
						msAnalyzerMetatada, dbName, username, password);
			}
			if (updateMSionization) {
				AnalyzerMassIonizationMetadataManagementService.update(msIonizationMetatada.getId(),
						msIonizationMetatada, dbName, username, password);

			}
			if (updateMSranges) {
				if (spectrum instanceof FullScanLCSpectrum) {
					FullScanLCSpectrumManagementService.update(spectrum.getId(), msRangeMassFrom,
							msRangeMassTo, msRangeRTminFrom, msRangeRTminTo, msRangeRTmeohFrom,
							msRangeRTmeohTo, msResolutionFWHMresolution, msResolutionFWHMmass, dbName,
							username, password);
				} // else if instance of FragLC / GC / ...
			}

			// IV - update NMR analyzer data

			if (spectrum instanceof NMR1DSpectrum) {

				// IV.A - init var
				boolean updateNMRspectrumData = false;
				boolean updateNMRanalyzerData = false;

				AnalyzerNMRSpectrometerDevice analyzerNMRdevice = ((NMR1DSpectrum) spectrum)
						.getAnalyzerNMRSpectrometerDevice();

				// IV.B - update object

				// spectrum_nmr_analyzer_name
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_name")) {
					updateNMRanalyzerData = true;
					analyzerNMRdevice
							.setInstrumentName(AnalyzerNMRSpectrometerDevice.getStandardizedNMRinstrumentName(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_name").toString()));
				}

				// spectrum_nmr_analyzer_magneticFieldStrength
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_magneticFieldStrength")) {
					updateNMRanalyzerData = true;
					analyzerNMRdevice.setMagneticFieldStrenght(AnalyzerNMRSpectrometerDevice
							.getStandardizedNMRmagneticFieldStength(spectrumDataToUpdate
									.get("spectrum_nmr_analyzer_magneticFieldStrength").toString(), null));
				}

				// spectrum_nmr_analyzer_software
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_software")) {
					updateNMRanalyzerData = true;
					analyzerNMRdevice
							.setSoftware(AnalyzerNMRSpectrometerDevice.getStandardizedNMRsoftwareVersion(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_software").toString()));
				}

				// spectrum_nmr_analyzer_probe
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_probe")) {
					updateNMRanalyzerData = true;
					analyzerNMRdevice.setProbe(AnalyzerNMRSpectrometerDevice.getStandardizedNMRprobe(
							spectrumDataToUpdate.get("spectrum_nmr_analyzer_probe").toString()));
				}

				// spectrum_nmr_analyzer_tube
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_tube")) {
					updateNMRanalyzerData = true;
					analyzerNMRdevice
							.setNMRtubeDiameter(AnalyzerNMRSpectrometerDevice.getStandardizedNMRtubeDiameter(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_tube").toString(), null));
				}

				// spectrum_nmr_analyzer_flow_cell_vol
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_flow_cell_vol")) {
					updateNMRanalyzerData = true;
					Double newCellVol = null;
					try {
						newCellVol = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_flow_cell_vol").toString());
					} catch (NumberFormatException nfe) {
					}
					analyzerNMRdevice.setFlowCellVolume(newCellVol);
				}

				String pulseSeq = ((NMR1DSpectrum) spectrum).getPulseSequence();
				Double pulseAngle = ((NMR1DSpectrum) spectrum).getPulseAngle();
				Integer nbOfPoints = ((NMR1DSpectrum) spectrum).getNumberOfPoints();
				Integer nbOfScans = ((NMR1DSpectrum) spectrum).getNumberOfScans();
				Double temperature = ((NMR1DSpectrum) spectrum).getTemperature();
				Double relaxationDelayD1 = ((NMR1DSpectrum) spectrum).getRelaxationDelayD1();
				Double sw = ((NMR1DSpectrum) spectrum).getSw();
				Double mixingTime = ((NMR1DSpectrum) spectrum).getMixingTime();
				Double spinEchoDelay = ((NMR1DSpectrum) spectrum).getSpinEchoDelay();
				Integer numberOfLoops = ((NMR1DSpectrum) spectrum).getNumberOfLoops();
				String decouplingType = ((NMR1DSpectrum) spectrum).getDecouplingType();

				Boolean fourierTransform = ((NMR1DSpectrum) spectrum).getFourierTransform();
				String si = ((NMR1DSpectrum) spectrum).getSiAsString();
				// Double lb = ((NMR1DSpectrum) spectrum).getLb();
				Double lineBroadening = ((NMR1DSpectrum) spectrum).getLineBroadening();

				// spectrum_nmr_analyzer_pulse_seq
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_pulse_seq")) {
					updateNMRspectrumData = true;
					pulseSeq = spectrumDataToUpdate.get("spectrum_nmr_analyzer_pulse_seq").toString();
				}

				// spectrum_nmr_analyzer_pulse_angle
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_pulse_angle")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_pulse_angle").toString());
					} catch (NumberFormatException nfe) {
					}
					pulseAngle = newVal;
				}

				// spectrum_nmr_analyzer_number_of_points
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_number_of_points")) {
					updateNMRspectrumData = true;
					Integer newVal = null;
					try {
						newVal = Integer.parseInt(spectrumDataToUpdate
								.get("spectrum_nmr_analyzer_number_of_points").toString());
					} catch (NumberFormatException nfe) {
					}
					nbOfPoints = newVal;
				}

				// spectrum_nmr_analyzer_number_of_scans
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_number_of_scans")) {
					updateNMRspectrumData = true;
					Integer newVal = null;
					try {
						newVal = Integer.parseInt(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_number_of_scans").toString());
					} catch (NumberFormatException nfe) {
					}
					nbOfScans = newVal;
				}

				// spectrum_nmr_analyzer_temperature
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_temperature")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_temperature").toString());
					} catch (NumberFormatException nfe) {
					}
					temperature = newVal;
				}

				// spectrum_nmr_analyzer_relaxationDelayD1
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_relaxationDelayD1")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate
								.get("spectrum_nmr_analyzer_relaxationDelayD1").toString());
					} catch (NumberFormatException nfe) {
					}
					relaxationDelayD1 = newVal;
				}

				// spectrum_nmr_analyzer_sw
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_sw")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_sw").toString());
					} catch (NumberFormatException nfe) {
					}
					sw = newVal;
				}

				// spectrum_nmr_analyzer_mixingTime
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_mixingTime")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_mixingTime").toString());
					} catch (NumberFormatException nfe) {
					}
					mixingTime = newVal;
				}

				// spectrum_nmr_analyzer_spinEchoDelay
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_spinEchoDelay")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_spinEchoDelay").toString());
					} catch (NumberFormatException nfe) {
					}
					spinEchoDelay = newVal;
				}

				// spectrum_nmr_analyzer_numberOfLoops
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_numberOfLoops")) {
					updateNMRspectrumData = true;
					Integer newVal = null;
					try {
						newVal = Integer.parseInt(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_numberOfLoops").toString());
					} catch (NumberFormatException nfe) {
					}
					numberOfLoops = newVal;
				}

				// spectrum_nmr_analyzer_decouplingType
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_decouplingType")) {
					updateNMRspectrumData = true;
					decouplingType = spectrumDataToUpdate.get("spectrum_nmr_analyzer_decouplingType")
							.toString();
				}

				// spectrum_nmr_analyzer_data_fourier_transform: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_fourier_transform")) {
					updateNMRspectrumData = true;
					Boolean newVal = null;
					try {
						newVal = Boolean.parseBoolean(spectrumDataToUpdate
								.get("spectrum_nmr_analyzer_data_fourier_transform").toString());
					} catch (Exception e) {
					}
					fourierTransform = newVal;
				}

				// spectrum_nmr_analyzer_data_si: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_si")) {
					updateNMRspectrumData = true;
					String newVal = null;
					try {
						newVal = spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_si").toString();
					} catch (Exception e) {
					}
					si = newVal;
				}

				// // spectrum_nmr_analyzer_lb: undefined
				// if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_lb")) {
				// updateNMRspectrumData = true;
				// Double newVal = null;
				// try {
				// newVal = Double
				// .parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_lb").toString());
				// } catch (Exception e) {
				// }
				// lb = newVal;
				// }

				// spectrum_nmr_analyzer_line_broadening: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_line_broadening")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_line_broadening").toString());
					} catch (Exception e) {
					}
					lineBroadening = newVal;
				}

				// IV.C - save object (if needed)
				if (updateNMRspectrumData) {
					NMR1DSpectrumManagementService.updateBasicAttributes(spectrum.getId(), pulseSeq,
							pulseAngle, nbOfPoints, nbOfScans, temperature, relaxationDelayD1, sw, mixingTime,
							spinEchoDelay, numberOfLoops, decouplingType, fourierTransform, si,
							lineBroadening, dbName, username, password);
				}
				if (updateNMRanalyzerData) {
					AnalyzerNMRSpectrometerDeviceManagementService.update(analyzerNMRdevice.getId(),
							analyzerNMRdevice, dbName, username, password);
				}
			}
			// V - update MASS PEAK LIST data

			if (spectrum instanceof MassSpectrum) {

				// V.A - init var
				boolean updatePeakList = false;
				List<MassPeak> newPeakList = new ArrayList<MassPeak>();

				// attribution: "[M+H]+"
				// composition: "C10H19N2O3"
				// deltaMass: -0.088
				// mz: 215.1385
				// ri: 100
				// theoricalMass: 215.139

				// V.B - update object
				if (spectrumDataToUpdate.containsKey("spectrum_ms_peaks")
						&& spectrumDataToUpdate.get("spectrum_ms_peaks") != null) {
					if (spectrumDataToUpdate.get("spectrum_ms_peaks") instanceof ArrayList<?>) {
						// newPeakList = new HashMap<>();
						updatePeakList = true;
						ArrayList<Map<String, Object>> rawPeakList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_ms_peaks");
						for (Map<String, Object> rawPeak : rawPeakList) {
							if (rawPeak.containsKey("mz") && rawPeak.get("mz") != null
									&& rawPeak.containsKey("ri") && rawPeak.get("ri") != null) {
								// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
								// composition=C10H17N2O3, attribution=[M-H]-}
								Double mz = null;
								Double ri = null;
								Double theoricalMass = null;
								Double deltaMass = null;
								try {
									mz = Double.parseDouble(rawPeak.get("mz").toString());
									ri = Double.parseDouble(rawPeak.get("ri").toString());
									theoricalMass = Double
											.parseDouble(rawPeak.get("theoricalMass").toString());
									deltaMass = Double.parseDouble(rawPeak.get("deltaMass").toString());
								} catch (NumberFormatException nfe) {
								}
								String composition = rawPeak.get("composition").toString();
								String attribution = rawPeak.get("attribution").toString();

								MassPeak mp = new MassPeak((MassSpectrum) spectrum, mz, ri, theoricalMass,
										deltaMass);
								mp.setComposition(composition);
								mp.setAttribution(attribution);
								if (ri != 0.0 && mz != 0.0)
									newPeakList.add(mp);
							}
						}
					}
				}

				// V.C - save object (if needed)
				// set newPeakList for spectrum
				if (updatePeakList) {
					if (spectrum instanceof FullScanLCSpectrum) {
						FullScanLCSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList,
								dbName, username, password);
					} // GCMS //MSMS
				}
			}

			// VI - update NMR PEAK LIST data

			if (spectrum instanceof NMR1DSpectrum) {

				// VI.A - init var
				boolean updatePeakList = false;
				List<NMR1DPeak> newPeakList = new ArrayList<NMR1DPeak>();

				// annotation: "2"
				// chemicalShift: 3.6163
				// halfWidth: 0.001527993310974196
				// halfWidthHz: 0
				// index: 1
				// relativeIntensity: 33.27

				// VI.B - update object
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_peaks")
						&& spectrumDataToUpdate.get("spectrum_nmr_peaks") != null) {
					if (spectrumDataToUpdate.get("spectrum_nmr_peaks") instanceof ArrayList<?>) {
						// newPeakList = new HashMap<>();
						updatePeakList = true;
						ArrayList<Map<String, Object>> rawPeakList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_nmr_peaks");
						for (Map<String, Object> rawPeak : rawPeakList) {
							if (rawPeak.containsKey("chemicalShift") && rawPeak.get("chemicalShift") != null
									&& rawPeak.containsKey("relativeIntensity")
									&& rawPeak.get("relativeIntensity") != null) {
								// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
								// composition=C10H17N2O3, attribution=[M-H]-}
								Double chemicalShift = null;
								Double relativeIntensity = null;
								Double halfWidth = null;
								Double halfWidthHz = null;
								try {
									chemicalShift = Double
											.parseDouble(rawPeak.get("chemicalShift").toString());
									relativeIntensity = Double
											.parseDouble(rawPeak.get("relativeIntensity").toString());
									halfWidth = Double.parseDouble(rawPeak.get("halfWidth").toString());
									halfWidthHz = Double.parseDouble(rawPeak.get("halfWidthHz").toString());
								} catch (NumberFormatException nfe) {
								}
								String annotation = rawPeak.get("annotation").toString();

								NMR1DPeak nmrP = new NMR1DPeak((NMR1DSpectrum) spectrum, chemicalShift,
										relativeIntensity);
								nmrP.setHalfWidth(halfWidth);
								nmrP.setHalfWidthHz(halfWidthHz);
								nmrP.setAnnotation(annotation);
								if (relativeIntensity != 0.0 && chemicalShift != 0.0)
									newPeakList.add(nmrP);
							}
						}
					}
				}

				// VI.C - save object (if needed)
				// set newPeakList for spectrum
				if (updatePeakList) {
					NMR1DSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList, dbName,
							username, password);
				}

				// VII - update NMR PEAK PATTERN LIST data
				// VII.A - init var
				boolean updatePeakPatternList = false;
				List<PeakPattern> newPeakPatternList = new ArrayList<PeakPattern>();

				// VII.B - update object

				// chemicalShift: 3.616539413714251
				// couplageConstant: undefined
				// pattern: "s"
				// rangeFrom: "3.61"
				// rangeTo: "3.623"
				// atom: ""

				if (spectrumDataToUpdate.containsKey("spectrum_nmr_peak_patterns")
						&& spectrumDataToUpdate.get("spectrum_nmr_peak_patterns") != null) {
					if (spectrumDataToUpdate.get("spectrum_nmr_peak_patterns") instanceof ArrayList<?>) {
						// newPeakList = new HashMap<>();
						updatePeakPatternList = true;
						ArrayList<Map<String, Object>> rawPeakList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_nmr_peak_patterns");
						for (Map<String, Object> rawPeak : rawPeakList) {
							if (rawPeak.containsKey("chemicalShift")
									&& rawPeak.get("chemicalShift") != null) {
								// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
								// composition=C10H17N2O3, attribution=[M-H]-}
								Double chemicalShift = null;
								Integer hORc = null;

								// Double relativeIntensity = null;
								Double rangeFrom = null;
								Double rangeTo = null;
								try {
									chemicalShift = Double
											.parseDouble(rawPeak.get("chemicalShift").toString());
									rangeFrom = Double.parseDouble(rawPeak.get("rangeFrom").toString());
									rangeTo = Double.parseDouble(rawPeak.get("rangeTo").toString());
									hORc = Integer.parseInt(rawPeak.get("H_or_C").toString());
								} catch (NumberFormatException nfe) {
								}
								String couplageConstant = rawPeak.get("couplageConstant").toString();
								String pattern = rawPeak.get("pattern").toString();
								String annotation = rawPeak.get("atom").toString();

								PeakPattern nmrP = new PeakPattern();
								nmrP.setChemicalShift(chemicalShift);
								nmrP.setAtomsAttributions(hORc);
								nmrP.setPatternType(pattern);
								nmrP.setRangeFrom(rangeFrom);
								nmrP.setRangeTo(rangeTo);
								nmrP.gatherCouplageConstants(couplageConstant);
								nmrP.setAtom(annotation);

								if (chemicalShift != 0.0)
									newPeakPatternList.add(nmrP);
							}
						}
					}
				}

				// VII.C - save object (if needed)
				if (updatePeakPatternList) {
					NMR1DSpectrumManagementService.updatePeakPatternList(spectrum.getId(), newPeakPatternList,
							dbName, username, password);
				}

			}

			// VIII - update OTHER data

			// VIII.A - init var
			boolean updateOtherMetadata = false;
			OtherMetadata otherMetadata = OtherMetadataManagementService
					.read((spectrum).getOtherMetadata().getId(), dbName, username, password);

			// VIII.B - update object
			// spectrum_othermetadata_aquisition_date: "2015-10-08"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_aquisition_date")) {
				updateOtherMetadata = true;
				otherMetadata.setAcquisitionDate(
						spectrumDataToUpdate.get("spectrum_othermetadata_aquisition_date").toString());
			}

			// spectrum_othermetadata_authors: "AXIOM/ MetaToul"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_authors")) {
				updateOtherMetadata = true;
				otherMetadata
						.setAuthors(spectrumDataToUpdate.get("spectrum_othermetadata_authors").toString());
			}

			// spectrum_othermetadata_ownership: "AXIOM/ MetaToul"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_ownership")) {
				updateOtherMetadata = true;
				otherMetadata.setOwnership(
						spectrumDataToUpdate.get("spectrum_othermetadata_ownership").toString());
			}

			// spectrum_othermetadata_raw_file_name: "w"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_raw_file_name")) {
				updateOtherMetadata = true;
				otherMetadata.setRawFileName(
						spectrumDataToUpdate.get("spectrum_othermetadata_raw_file_name").toString());
			}

			// spectrum_othermetadata_raw_file_size: "10"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_raw_file_size")) {
				updateOtherMetadata = true;
				Double newFileSize = null;
				try {
					newFileSize = Double.parseDouble(
							spectrumDataToUpdate.get("spectrum_othermetadata_raw_file_size").toString());
				} catch (NumberFormatException e) {
				}
				otherMetadata.setRawFileSize(newFileSize);
			}

			// spectrum_othermetadata_validator: "E. Jamin"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_validator")) {
				updateOtherMetadata = true;
				otherMetadata.setValidator(
						spectrumDataToUpdate.get("spectrum_othermetadata_validator").toString());
			}

			// VIII.C - save object (if needed)
			if (updateOtherMetadata) {
				OtherMetadataManagementService.update(otherMetadata.getId(), otherMetadata, dbName, username,
						password);
			}

		} catch (Exception e1) {
			e1.printStackTrace();
			return false;
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

		// log
		spectrumLog("edit spectrum @id=" + id + ";");

		return true;
	}

	private boolean constainKey(Map<String, Object> spectrumDataToUpdate, String string) {
		return spectrumDataToUpdate.containsKey(string) && spectrumDataToUpdate.get(string) != null;
	}

	/**
	 * @param time
	 * @return
	 */
	private String shortifyText(Double time) {
		if (time == null)
			return "";
		else {
			String rt = time + "";
			if (rt.length() > rt.lastIndexOf(".") + 3)
				return rt.substring(0, rt.lastIndexOf(".") + 3);
			else
				return rt;
		}
	}

	/**
	 * @param data
	 * @return
	 */
	@RequestMapping(value = "/nmr-viewer-converter", headers = {
			"Content-type=application/json" }, method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody Object getNMRspectrumJsonData(@RequestBody Map<String, Object> data) {

		// {"type":"single","id":"test","sample":1,"pdata":1}
		String rawFolder = Utils.getBundleConfElement("rawFile.nmr.folder");
		if (!rawFolder.endsWith(File.separator))
			rawFolder += File.separator;
		String id = rawFolder + (String) data.get("id");
		int sample = (int) data.get("sample");
		String type = (String) data.get("type");
		int pdata = (int) data.get("pdata");

		return ViewerProcessing.getJsonData(id, sample, type, pdata);
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param keyRawFile
	 * @return
	 */
	@RequestMapping(value = "/show-raw-file-processing/{keyRawFile}")
	public @ResponseBody String getRawFileProcessing(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable("keyRawFile") String keyRawFile) {

		String rawFileName = Utils.getBundleConfElement("rawFile.nmr.folder") + keyRawFile + File.separator
				+ "_pdata_param.txt";
		File logFile = new File(rawFileName);
		try {
			return SimpleFileReader.readFile(logFile.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (IOException e) {
			return "unable to display raw file content \n" + e.getMessage();
		}
	}

	@RequestMapping(value = "/js_sandbox/{id}", method = RequestMethod.GET)
	public String showJSMolInCompoundSheet(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, @PathVariable("id") long id) throws PeakForestManagerException {

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// load spectra data
		// List<Long> spectrumIDs = new ArrayList<Long>();
		// spectrumIDs.add(Long.parseLong(id));
		// spectrumIDs.add(id);
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService.readByInChIKey(
								((StructureChemicalCompound) c).getInChIKey(), dbName, username, password));
					} catch (Exception e) {
						e.printStackTrace();
					}
				else
					listCC.add(c);
			}
			((CompoundSpectrum) spectrum).setListOfCompounds(listCC);
		}

		// load data in model
		if (spectrum != null) {
			try {
				loadSpectraMetadata(model, spectrum, request, dbName, username, password);
				model.addAttribute("contains_spectrum", true);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} else
			model.addAttribute("contains_spectrum", false);

		// RETURN
		return "module/jsmol_sandbox";
	}

	/**
	 * @param logMessage
	 */
	private void spectrumLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

}

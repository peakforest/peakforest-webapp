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

import fr.metabohub.peakforest.dao.CurationMessageDao;
import fr.metabohub.peakforest.dao.metadata.ASampleMixMetadataDao;
import fr.metabohub.peakforest.dao.metadata.AnalyzerMassIonizationMetadataDao;
import fr.metabohub.peakforest.dao.metadata.AnalyzerMassSpectrometerDeviceMetadataDao;
import fr.metabohub.peakforest.dao.metadata.AnalyzerNMRSpectrometerDeviceMetadataDao;
import fr.metabohub.peakforest.dao.metadata.GazChromatographyMetadataDao;
import fr.metabohub.peakforest.dao.metadata.IonChromatographyMetadataDao;
import fr.metabohub.peakforest.dao.metadata.LiquidChromatographyMetadataDao;
import fr.metabohub.peakforest.dao.metadata.OtherMetadataDao;
import fr.metabohub.peakforest.dao.metadata.SampleNMRTubeConditionsDao;
import fr.metabohub.peakforest.dao.spectrum.FragmentationICSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.FragmentationLCSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.FullScanGCSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.FullScanICSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.FullScanLCSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.NMR1DSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.NMR2DSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.PeakPatternDao;
import fr.metabohub.peakforest.model.CurationMessage;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.GCDerivedCompound;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.model.metadata.ASampleMix;
import fr.metabohub.peakforest.model.metadata.AnalyticalMatrix;
import fr.metabohub.peakforest.model.metadata.AnalyzerGasMassIonization;
import fr.metabohub.peakforest.model.metadata.AnalyzerLiquidMassIonization;
import fr.metabohub.peakforest.model.metadata.AnalyzerMassIonBeamMetadata;
import fr.metabohub.peakforest.model.metadata.AnalyzerMassIonTrapMetadata;
import fr.metabohub.peakforest.model.metadata.AnalyzerMassIonization;
import fr.metabohub.peakforest.model.metadata.AnalyzerMassSpectrometerDevice;
import fr.metabohub.peakforest.model.metadata.AnalyzerNMRSpectrometerDevice;
import fr.metabohub.peakforest.model.metadata.GCDerivedCompoundMetadata;
import fr.metabohub.peakforest.model.metadata.GasSampleMix;
import fr.metabohub.peakforest.model.metadata.GazChromatography;
import fr.metabohub.peakforest.model.metadata.IonChromatography;
import fr.metabohub.peakforest.model.metadata.LiquidChromatography;
import fr.metabohub.peakforest.model.metadata.LiquidSampleMix;
import fr.metabohub.peakforest.model.metadata.OtherMetadata;
import fr.metabohub.peakforest.model.metadata.SampleNMRTubeConditions;
import fr.metabohub.peakforest.model.metadata.StandardizedMatrix;
import fr.metabohub.peakforest.model.spectrum.CompoundSpectrum;
import fr.metabohub.peakforest.model.spectrum.FragmentationICSpectrum;
import fr.metabohub.peakforest.model.spectrum.FragmentationLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanGCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanICSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.IFragmentationSpectrum;
import fr.metabohub.peakforest.model.spectrum.IGCSpectrum;
import fr.metabohub.peakforest.model.spectrum.IICSpectrum;
import fr.metabohub.peakforest.model.spectrum.ILCSpectrum;
import fr.metabohub.peakforest.model.spectrum.ISampleSpectrum;
import fr.metabohub.peakforest.model.spectrum.MassPeak;
import fr.metabohub.peakforest.model.spectrum.MassSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMR1DPeak;
import fr.metabohub.peakforest.model.spectrum.NMR1DSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMR2DJRESPeak;
import fr.metabohub.peakforest.model.spectrum.NMR2DPeak;
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
import fr.metabohub.peakforest.services.spectrum.FragmentationICSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FragmentationLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanGCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanICSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.ImportService;
import fr.metabohub.peakforest.services.spectrum.NMR1DSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.NMR2DSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.SpectrumManagementService;
import fr.metabohub.peakforest.utils.ChromatoUtils;
import fr.metabohub.peakforest.utils.PeakComparator;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestPruneUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SimpleFileReader;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
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

	@RequestMapping(value = "/compound-spectra-module/{type}/{id}", method = RequestMethod.GET)
	public String showSpectraInCompoundSheet(HttpServletRequest request, HttpServletResponse response, Locale locale,
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
		if (refCompound != null)
			loadSpectraData(type, model, refCompound, request);

		// RETURN
		return "module/compound-spectra-module";
	}

	@RequestMapping(value = "/compound-spectra-carrousel-light-module/{type}/{id}", method = RequestMethod.GET)
	public String showSpectraInCompoundModal(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model, @RequestParam("isExt") Boolean isExt)
			throws PeakForestManagerException {
		// load data
		StructureChemicalCompound refCompound = null;
		if (type.equalsIgnoreCase("chemical")) {
			try {
				refCompound = ChemicalCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else if (type.equalsIgnoreCase("generic")) {
			try {
				refCompound = GenericCompoundManagementService.read(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		// TODO other

		// init var
		model.addAttribute("spectrum_load_legend", false); // full (case 03)
		model.addAttribute("spectrum_load_complementary_data", true); // light (case 01)
		model.addAttribute("spectrum_load_details_modalbox", false); // cpt-sheet (case 02)

		// load data in model
		if (refCompound != null) {
			loadSpectraData(type, model, refCompound, request);
		}

		model.addAttribute("set_width", "");

		if (isExt != null && isExt) {
			model.addAttribute("isExt", true);
		} else {
			model.addAttribute("isExt", false);
		}

		// RETURN
		return "module/compound-spectra-carrousel-module";
	}

	@RequestMapping(value = "/compound-spectra-carrousel-full-module/{type}/{id}/{techFilter}", method = RequestMethod.GET)
	public String showSpectraInCompoundSheetByTech(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String type, @PathVariable long id, @PathVariable String techFilter,
			Model model, @RequestParam("isExt") Boolean isExt) throws PeakForestManagerException {
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
		model.addAttribute("spectrum_load_legend", false); // full (case 03)
		model.addAttribute("spectrum_load_complementary_data", true); // light (case 01)
		model.addAttribute("spectrum_load_details_modalbox", false); // cpt-sheet (case 02)

		// load data in model
		if (refCompound != null) {
			loadSpectraData(type, model, refCompound, request);
		}

		switch (techFilter) {
		case "all":
		default:
			break;
		case "lcms":
			// model.addAttribute("spectrum_mass_fullscan_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fullscan_gc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fragmt_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_nmr", new ArrayList<Spectrum>());
			break;
		case "lcmsms":
			model.addAttribute("spectrum_mass_fullscan_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_mass_fullscan_gc", new ArrayList<Spectrum>());
			// model.addAttribute("spectrum_mass_fragmt_lc", new ArrayList<Spectrum>());
			model.addAttribute("spectrum_nmr", new ArrayList<Spectrum>());
			break;
		case "nmr":
		case "nmr-1d":
		case "nmr-2d":
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

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/load-ms-spectra", //
			params = { //
					"fullscan-lc", //
					"frag-lc", //
					"fullscan-gc", //
					"fullscan-ic", //
					"frag-ic", //
					"name", //
					"mode", //
					"id" //
			}//
	)
	public String loadScriptMS(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final @RequestParam("fullscan-lc") List<Long> fullscanLC, //
			final @RequestParam("frag-lc") List<Long> fragmentationLC, //
			final @RequestParam("fullscan-gc") List<Long> fullscanGC, //
			final @RequestParam("fullscan-ic") List<Long> fullscanIC, //
			final @RequestParam("frag-ic") List<Long> fragmentationIC, //
			final @RequestParam("name") String name, //
			final @RequestParam("mode") String mode, //
			final @RequestParam("id") String id, //
			final Model model) throws PeakForestManagerException {

		// init request
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

		// load FullScan and Frag. spectra data from DB
		List<FullScanLCSpectrum> listFullScanLcSpectra = new ArrayList<>();
		try {
			listFullScanLcSpectra = FullScanLCSpectrumManagementService.read(fullscanLC);
		} catch (Exception e) {
			e.printStackTrace();
		}

		List<FragmentationLCSpectrum> listFragLcSpectra = new ArrayList<>();
		try {
			listFragLcSpectra = FragmentationLCSpectrumManagementService.read(fragmentationLC);
		} catch (Exception e) {
			e.printStackTrace();
		}

		List<FullScanGCSpectrum> listFullScanGcSpectra = new ArrayList<>();
		try {
			listFullScanGcSpectra = FullScanGCSpectrumManagementService.read(fullscanGC);
		} catch (Exception e) {
			e.printStackTrace();
		}

		final List<FullScanICSpectrum> listFullScanIcSpectra = new ArrayList<>();
		try {
			listFullScanIcSpectra.addAll(FullScanICSpectrumManagementService.read(fullscanIC));
		} catch (final Exception e) {
			e.printStackTrace();
		}

		final List<FragmentationICSpectrum> listFragmentationIcSpectra = new ArrayList<>();
		try {
			listFragmentationIcSpectra.addAll(FragmentationICSpectrumManagementService.read(fragmentationIC));
		} catch (final Exception e) {
			e.printStackTrace();
		}

		// I - load series
		int seriesCount = listFullScanLcSpectra.size() + listFragLcSpectra.size() + listFullScanGcSpectra.size()//
				+ listFullScanIcSpectra.size() + listFragmentationIcSpectra.size() //
		;
		// HashMap<String, String>[] seriesShow = new HashMap<String,
		// String>[seriesCount];

		// I.A - series data (m/z vs RI)
		Object[] seriesShowData = new Object[seriesCount];
		Object[] seriesHideData = new Object[seriesCount];

		// I.B - series superdata (adducts / composition)
		Object[] seriesAdducts = new Object[seriesCount];
		Object[] seriesComposition = new Object[seriesCount];
		Object[] seriesNames = new Object[seriesCount];

		// I.C - load spectrum basic data
		Double minMass = 1000.0, minMassPeak = 1000.0;
		Double maxMass = 10.0, maxMassPeak = 10.0;

		// I.D - load metadata
		final Object[] seriesSpectrumMetadata = new Object[seriesCount];

		// I.E - spectrum custom visualization
		final Boolean[] spectrumShowCompoAdducts = new Boolean[seriesCount];
		final Boolean[] spectrumLoadTopPeaksLabel = new Boolean[seriesCount];
		final Integer[] spectrumLoadTopPeaksCount = new Integer[seriesCount];
		final Boolean[] spectrumShowTinySymbols = new Boolean[seriesCount];

		final List<MassSpectrum> listMassSpectra = new ArrayList<>();
		listMassSpectra.addAll(listFullScanLcSpectra);
		listMassSpectra.addAll(listFragLcSpectra);
		listMassSpectra.addAll(listFullScanGcSpectra);
		listMassSpectra.addAll(listFullScanIcSpectra);
		listMassSpectra.addAll(listFragmentationIcSpectra);

		final boolean hasGCSpectra = !listFullScanGcSpectra.isEmpty();

		// II.A - load series
		int cpt = 0;
		Double peakDelta = 0.0000001;
		Double peakHideRI = -100.0;
		for (final MassSpectrum spectrum : listMassSpectra) {
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
				if (mp.getAttributionAsString() != null)
					peakListAdducts.put(mp.getMassToChargeRatio(),
							Jsoup.clean(mp.getAttributionAsString(), Whitelist.basic()));
				if (mp.getComposition() != null)
					peakListComposition.put(mp.getMassToChargeRatio(),
							Jsoup.clean(mp.getComposition(), Whitelist.basic()));
				// ...
				if (minMass.equals(mp.getMassToChargeRatio()))
					minMass -= (minMass * 0.1);
				if (maxMass.equals(mp.getMassToChargeRatio()))
					maxMass += (maxMass * 0.1);
				// ...
				if (minMassPeak > mp.getMassToChargeRatio())
					minMassPeak = mp.getMassToChargeRatio();
				if (maxMassPeak < mp.getMassToChargeRatio())
					maxMassPeak = mp.getMassToChargeRatio();
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
							listCC.add(StructuralCompoundManagementService
									.readByInChIKey(((StructureChemicalCompound) c).getInChIKey()));
						} catch (Exception e) {
							e.printStackTrace();
						}
					else
						listCC.add(c);
				}
				spectrum.setListOfCompounds(listCC);
			}
			// name
			String spectrumName = spectrum.getMassBankName().replaceAll("'", "\\'");
			String spectrumPFEMName = spectrum.getMassBankNameViaPfemHTML().replaceAll("'", "\\'");
			String spectrumPForestId = spectrum.getPeakForestID();
			// if (spectrum.getPolarity() == MassSpectrum.MASS_SPECTRUM_POLARITY_POSITIVE)
			// spectrumName += "MS-POS";
			// else if (spectrum.getPolarity() ==
			// MassSpectrum.MASS_SPECTRUM_POLARITY_NEGATIVE)
			// spectrumName += "MS-NEG";
			String ionization = "";
			if (spectrum.getAnalyzerMassIonization() == null)
				ionization = spectrum.getAnalyzerMassIonization().getIonizationAsString();
			seriesNames[cpt] = spectrumName + " (" + (cpt + 1) + ")";
			// metadata
			HashMap<String, String> metadata = new HashMap<>();
			metadata.put("code", spectrumName);
			// metadata basic
			metadata.put("name", spectrumName);
			metadata.put("pfem_name", spectrumPFEMName);
			metadata.put("pforest_id", spectrumPForestId);
			metadata.put("RT", "[" + spectrum.getRangeRetentionTimeFrom() + " - " + spectrum.getRangeMassTo() + "]");
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
			metadata.put("authors", spectrum.getOtherMetadata().getAuthors().replaceAll("'", "\\'") + "");
			metadata.put("owners", spectrum.getOtherMetadata().getAuthors().replaceAll("'", "\\'") + "");
			metadata.put("license", spectrum.getOtherMetadata().getLicense() + "");
			metadata.put("licenseOther", "");
			if (spectrum.getOtherMetadata().getLicenseOther() != null) {
				metadata.put("licenseOther", spectrum.getOtherMetadata().getLicenseOther().replaceAll("'", "\\'") + "");
			}
			seriesSpectrumMetadata[cpt] = metadata;

			// GC-related customization
			final boolean isGCSpectrum = spectrum instanceof FullScanGCSpectrum;
			spectrumShowCompoAdducts[cpt] = !isGCSpectrum;
			spectrumLoadTopPeaksLabel[cpt] = Boolean.TRUE;//
			spectrumLoadTopPeaksCount[cpt] = isGCSpectrum ? 10 : 3;
			spectrumShowTinySymbols[cpt] = Boolean.TRUE;
			cpt++;

			// only for light
			model.addAttribute("spectrum_pf_id", spectrum.getPeakForestID());
		}

		// spectrum basic data
		model.addAttribute("spectrum_min_mass", minMass);
		model.addAttribute("spectrum_max_mass", maxMass);
		if (hasGCSpectra) {
			// the closest lower hundred
			model.addAttribute("spectrum_min_mass", Math.max(minMass, Math.floor(minMassPeak / 100d) * 100d));
			// the closest higher hundred
			model.addAttribute("spectrum_max_mass", Math.min(maxMass, Math.ceil(maxMassPeak / 100d) * 100d));
		}

		// spectrum series
		model.addAttribute("spectrum_series_show", seriesShowData);
		model.addAttribute("spectrum_series_hide", seriesHideData);
		model.addAttribute("spectrum_series_name", seriesNames);

		model.addAttribute("spectrum_series_composition", seriesComposition);
		model.addAttribute("spectrum_series_adducts", seriesAdducts);

		// metadata
		model.addAttribute("spectrum_series_metadata", seriesSpectrumMetadata);

		// visualization customization
		model.addAttribute("spectrum_show_compo_adducts", spectrumShowCompoAdducts);
		model.addAttribute("spectrum_load_top_peaks_label", spectrumLoadTopPeaksLabel);
		model.addAttribute("spectrum_load_top_peaks_count", spectrumLoadTopPeaksCount);
		model.addAttribute("spectrum_show_tiny_symbols", spectrumShowTinySymbols);

		// LOAD SPECTRUMS
		return "module/load-ms-spectra-script";
	}

	private void loadSpectraData(//
			final String type, //
			final Model model, //
			final StructureChemicalCompound refCompound, //
			final HttpServletRequest request) throws PeakForestManagerException {

		// COMPOUND
		final String cpdNameClean = Jsoup.clean(refCompound.getMainName(), Whitelist.basic());
		final String cpdName = PeakForestPruneUtils.convertGreekCharToHTML(cpdNameClean);
		model.addAttribute("compound_main_name", cpdName);
		model.addAttribute("compound_type", refCompound.getTypeString());
		model.addAttribute("compound_id", refCompound.getId());
		model.addAttribute("compound_inchikey", refCompound.getInChIKey());
		model.addAttribute("compound_pfID", refCompound.getPeakForestID());

		// SPECTRUM
		if (refCompound.getListOfSpectra().isEmpty()) {
			model.addAttribute("contains_spectrum", false);
		} else {
			model.addAttribute("contains_spectrum", true);
			final List<FullScanLCSpectrum> fullscanLcMsSpectrumList = new ArrayList<>();
			final List<FullScanGCSpectrum> fullscanGcMsSpectrumList = new ArrayList<>();
			final List<FragmentationLCSpectrum> fragLcMsSpectrumList = new ArrayList<>();
			final List<NMRSpectrum> nmrSpectrumList = new ArrayList<>();
			// new 2.3
			final List<FullScanICSpectrum> fullscanIcMsSpectrumList = new ArrayList<>();
			final List<FragmentationICSpectrum> fragIcMsSpectrumList = new ArrayList<>();

			for (Spectrum s : refCompound.getListOfSpectra()) {
				if (s instanceof FullScanLCSpectrum) {
					s = FullScanLCSpectrumManagementService.read(s.getId());
					fullscanLcMsSpectrumList.add((FullScanLCSpectrum) s);
				} else if (s instanceof FullScanGCSpectrum) {
					s = FullScanGCSpectrumManagementService.read(s.getId());
					fullscanGcMsSpectrumList.add((FullScanGCSpectrum) s);
				} else if (s instanceof FragmentationLCSpectrum) {
					s = FragmentationLCSpectrumManagementService.read(s.getId());
					fragLcMsSpectrumList.add((FragmentationLCSpectrum) s);
				} else if (s instanceof NMR1DSpectrum) {
					s = NMR1DSpectrumManagementService.read(s.getId());
					nmrSpectrumList.add((NMR1DSpectrum) s);
				} else if (s instanceof NMR2DSpectrum) {
					s = NMR2DSpectrumManagementService.read(s.getId());
					nmrSpectrumList.add((NMR2DSpectrum) s);
				}
				// new 2.3
				else if (s instanceof FullScanICSpectrum) {
					s = FullScanICSpectrumManagementService.read(s.getId());
					fullscanIcMsSpectrumList.add((FullScanICSpectrum) s);
				} else if (s instanceof FragmentationICSpectrum) {
					s = FragmentationICSpectrumManagementService.read(s.getId());
					fragIcMsSpectrumList.add((FragmentationICSpectrum) s);
				} else {
					// other (NMR / uv)
				}
				if (s instanceof CompoundSpectrum) {
					final List<Compound> cptList = new ArrayList<Compound>();
					cptList.add(refCompound);
					((CompoundSpectrum) s).setListOfCompounds(cptList);
				}
			}
			// model bind
			model.addAttribute("spectrum_mass_fullscan_lc", fullscanLcMsSpectrumList);
			model.addAttribute("spectrum_mass_fullscan_gc", fullscanGcMsSpectrumList);
			model.addAttribute("spectrum_mass_fragmt_lc", fragLcMsSpectrumList);
			model.addAttribute("spectrum_nmr", nmrSpectrumList);

			model.addAttribute("spectrum_mass_fullscan_ic", fullscanIcMsSpectrumList);
			model.addAttribute("spectrum_mass_fragmt_ic", fragIcMsSpectrumList);

			// first tab:
			if (!fullscanLcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "lc-ms");
			} else if (!fragLcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "lc-msms");
			} else if (!nmrSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "nmr");
			} else if (!fullscanGcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "gc-ms");
			}
			// new 2.3
			else if (!fullscanIcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "ic-ms");
			} else if (!fragIcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "ic-msms");
			}

			// ...
		}

		// END
	}

	// /**
	// * @param logMessage
	// */
	// private void spectrumLog(String logMessage) {
	// String username = "?";
	// if (SecurityContextHolder.getContext().getAuthentication().getPrincipal()
	// instanceof User) {
	// User user = null;
	// user = ((User)
	// SecurityContextHolder.getContext().getAuthentication().getPrincipal());
	// username = user.getLogin();
	// }
	// SpectralDatabaseLogger.log(username, logMessage,
	// SpectralDatabaseLogger.LOG_INFO);
	// }

	@RequestMapping(value = "/show-compound-spectra-modal/{type}/{id}", method = RequestMethod.GET)
	public String compoundspectraModalShow(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String type, @PathVariable int id, Model model) throws PeakForestManagerException {

		// model.addAttribute("id", id);
		// model.addAttribute("type", type);

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
			listOfAllSpectrum = SpectrumManagementService.read(spectrumIDs);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var

		// load data in model
		loadSpectraData(model, listOfAllSpectrum, request);

		// RETURN
		return "module/spectra-light-module";
	}

	private void loadSpectraData(final Model model, final List<Spectrum> spectra, final HttpServletRequest request) {

		// SPECTRUM
		if (spectra.isEmpty()) {
			model.addAttribute("contains_spectrum", false);
		} else {
			model.addAttribute("contains_spectrum", true);
			final List<FullScanLCSpectrum> fullscanLcMsSpectrumList = new ArrayList<>();
			final List<FullScanGCSpectrum> fullscanGcMsSpectrumList = new ArrayList<>();
			final List<FragmentationLCSpectrum> fragLcMsSpectrumList = new ArrayList<>();
			final List<NMRSpectrum> nmrSpectrumList = new ArrayList<>();
			// new 2.3
			final List<FullScanICSpectrum> fullscanIcMsSpectrumList = new ArrayList<>();
			final List<FragmentationICSpectrum> fragIcMsSpectrumList = new ArrayList<>();
			for (Spectrum s : spectra) {
				if (s instanceof FullScanLCSpectrum) {
					s = FullScanLCSpectrumManagementService.read(s.getId());
					fullscanLcMsSpectrumList.add((FullScanLCSpectrum) s);
				} else if (s instanceof FullScanGCSpectrum) {
					s = FullScanGCSpectrumManagementService.read(s.getId());
					fullscanGcMsSpectrumList.add((FullScanGCSpectrum) s);
				} else if (s instanceof FragmentationLCSpectrum) {
					s = FragmentationLCSpectrumManagementService.read(s.getId());
					fragLcMsSpectrumList.add((FragmentationLCSpectrum) s);
				} else if (s instanceof NMR1DSpectrum) {
					s = NMR1DSpectrumManagementService.read(s.getId());
					nmrSpectrumList.add((NMR1DSpectrum) s);
				} else if (s instanceof NMR2DSpectrum) {
					s = NMR2DSpectrumManagementService.read(s.getId());
					nmrSpectrumList.add((NMR2DSpectrum) s);

				}
				// new 2.3
				else if (s instanceof FullScanICSpectrum) {
					s = FullScanICSpectrumManagementService.read(s.getId());
					fullscanIcMsSpectrumList.add((FullScanICSpectrum) s);
				} else if (s instanceof FragmentationICSpectrum) {
					s = FragmentationICSpectrumManagementService.read(s.getId());
					fragIcMsSpectrumList.add((FragmentationICSpectrum) s);
				} else {
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
								c = StructuralCompoundManagementService
										.readByInChIKey(((StructureChemicalCompound) c).getInChIKey());
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
			// new 2.3
			model.addAttribute("spectrum_mass_fullscan_ic", fullscanIcMsSpectrumList);
			model.addAttribute("spectrum_mass_fragmt_ic", fragIcMsSpectrumList);

			// first tab:
			if (!(fullscanLcMsSpectrumList.isEmpty() && fragLcMsSpectrumList.isEmpty())) {
				model.addAttribute("first_tab_open", "lc-ms");
			} else if (!nmrSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "nmr");
			} else if (!fullscanGcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "gc-ms");
			}
			// new 2.3
			else if (!fullscanIcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "ic-ms");
			} else if (!fragIcMsSpectrumList.isEmpty()) {
				model.addAttribute("first_tab_open", "ic-msms");
			}
			// ...
		}

		// END
	}

	// ///////////////////////
	// NMR

	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/load-nmr-1d-spectra", //
			params = { "nmr", "name", "mode", "id" })
	public String loadScriptNMR1D(//
			HttpServletRequest request, //
			HttpServletResponse response, //
			Locale locale, //
			@RequestParam("nmr") List<Long> nmr, //
			@RequestParam("name") String name, //
			@RequestParam("mode") String mode, //
			@RequestParam("id") String id, //
			Model model) throws PeakForestManagerException {

		// init request
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
			listNMRSpectra = NMR1DSpectrumManagementService.read(nmr);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// I - load series
		int seriesCount = listNMRSpectra.size();
		// HashMap<String, String>[] seriesShow = new HashMap<String,
		// String>[seriesCount];

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
							listCC.add(StructuralCompoundManagementService
									.readByInChIKey(((StructureChemicalCompound) c).getInChIKey()));
						} catch (Exception e) {
							e.printStackTrace();
						}
					else
						listCC.add(c);
				}
				spectrum.setListOfCompounds(listCC);
			}
			// name
			String spectrumName = "" + spectrum.getMassBankLikeName().replaceAll("'", "\\'");
			String spectrumPFEMName = spectrum.getMassBankNameHTML().replaceAll("'", "\\'");
			String spectrumPForestId = spectrum.getPeakForestID();
			// spectrumName += "[" + spectrum.getPulseSequence() + "]";
			seriesNames[cpt] = spectrumName + " (" + (cpt + 1) + ")";
			// metadata
			HashMap<String, String> metadata = new HashMap<>();
			metadata.put("code", spectrumName);
			// metadata basic
			metadata.put("name", spectrumName);
			metadata.put("pfem_name", spectrumPFEMName);
			metadata.put("pforest_id", spectrumPForestId);
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
			metadata.put("licenseOther", "");
			if (spectrum.getOtherMetadata().getLicenseOther() != null)
				metadata.put("licenseOther", spectrum.getOtherMetadata().getLicenseOther().replaceAll("'", "\\'") + "");
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
		boolean isGCMS = false;
		boolean isLCMS = false;
		boolean isLCMSMS = false;
		boolean isNMR = false;
		// boolean isLCNMR = false;

		boolean success = true;
		String error = "";

		if (jsonData.containsKey("dumper_type") && jsonData.get("dumper_type") instanceof String) {
			switch (jsonData.get("dumper_type").toString()) {
			case "lc-ms":
				isLCMS = true;
				break;
			case "lc-msms":
				isLCMSMS = true;
				break;
			case "nmr":
			case "nmr-1d":
			case "nmr-2d":
				isNMR = true;
				break;
			case "gc-ms":
				isGCMS = true;
				break;

			// TODO / lc-nmr / ...
			default:
				// not supported
				break;
			}
		}

		// init peak forest data mapper
		PeakForestDataMapper dataMapper = null;
		if (isLCMS)
			dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_LC_MS);
		else if (isLCMSMS)
			dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_LC_MSMS);
		else if (isNMR)
			dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_NMR);
		else if (isGCMS)
			dataMapper = new PeakForestDataMapper(PeakForestDataMapper.DATA_TYPE_GC_MS);
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
			Map<String, Object> response = ImportService.importSpectraDataMapper(dataMapper, idMetadata);
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
	// public ModelAndView method(HttpServletResponse httpServletResponse,
	// @PathVariable("query") String
	// query) {
	// return new ModelAndView("redirect:" + "/home?pf=" + query);
	// }

	@RequestMapping(value = "/PFs{query}", method = RequestMethod.GET)
	public ModelAndView methodPFs(HttpServletResponse httpServletResponse, @PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?PFs=" + query);
	}

	@RequestMapping(value = "/pf:{query}", method = RequestMethod.GET)
	public ModelAndView methodPF(HttpServletResponse httpServletResponse, @PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?PFs=" + query);
	}

	@RequestMapping(value = "/pf={query}", method = RequestMethod.GET)
	public ModelAndView methodPF2(HttpServletResponse httpServletResponse, @PathVariable("query") String query) {
		return new ModelAndView("redirect:" + "/home?PFs=" + query);
	}

	@RequestMapping(value = "/sheet-spectrum/{id}", method = RequestMethod.GET)
	public String showSpectraSheet(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model,
			@PathVariable("id") long id) throws PeakForestManagerException {

		// load spectra data
		// List<Long> spectrumIDs = new ArrayList<Long>();
		// spectrumIDs.add(Long.parseLong(id));
		// spectrumIDs.add(id);
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService
								.readByInChIKey(((StructureChemicalCompound) c).getInChIKey()));
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
				loadSpectraMetadata(model, spectrum, request);
				model.addAttribute("contains_spectrum", true);
			} catch (final Exception e) {
				e.printStackTrace();
			}
			attachUserData(model, spectrum);
		} else {
			model.addAttribute("contains_spectrum", false);
		}

		return "module/sheet-spectrum-module";
	}

	/**
	 * @param model
	 * @param spectrum
	 */
	private void attachUserData(//
			final Model model, //
			final Spectrum spectrum) {
		User user = null;
		long userId = -1;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			userId = user.getId();
		}

		if (user != null && user.isConfirmed()) {
			model.addAttribute("editor", true);
			final List<CurationMessage> waitingCurationMessageUser = new ArrayList<CurationMessage>();
			for (final CurationMessage cm : spectrum.getCurationMessages())
				if (cm.getStatus() == CurationMessage.STATUS_WAITING && cm.getUserID() == userId) {
					cm.setMessage(Jsoup.clean(cm.getMessage(), Whitelist.basic()));
					waitingCurationMessageUser.add(cm);
				}
			model.addAttribute("waitingCurationMessageUser", waitingCurationMessageUser);
		} else {
			model.addAttribute("editor", false);
		}

		if (user != null && user.isCurator()) {
			model.addAttribute("curator", true);
			model.addAttribute("curationMessages", spectrum.getCurationMessages());
		} else {
			model.addAttribute("curator", false);
		}
	}

	@RequestMapping(value = "/data-ranking-spectrum/{id}", method = RequestMethod.GET)
	public String showSpectraMeta(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model,
			@PathVariable("id") long id) throws PeakForestManagerException {

		// load spectra data
		// List<Long> spectrumIDs = new ArrayList<Long>();
		// spectrumIDs.add(Long.parseLong(id));
		// spectrumIDs.add(id);
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService
								.readByInChIKey(((StructureChemicalCompound) c).getInChIKey()));
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
				loadSpectraMeta(model, spectrum, request);
				model.addAttribute("contains_spectrum", true);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} else
			model.addAttribute("contains_spectrum", false);

		return "block/meta";
	}

	private void loadSpectraMetadata(Model model, Spectrum spectrum, HttpServletRequest request) throws Exception {

		// BASIC DATA
		model.addAttribute("spectrum_id", spectrum.getId());
		model.addAttribute("spectrum_name", PeakForestPruneUtils.convertGreekCharToHTML(spectrum.getName()));
		model.addAttribute("spectrum_pfID", spectrum.getPeakForestID());
		model.addAttribute("spectrum_splash", spectrum.getSplash());

		// SPECIFIC GC-DERIVATIVE DATA
		if (spectrum instanceof FullScanGCSpectrum) {
			GCDerivedCompoundMetadata gcMetadata = ((FullScanGCSpectrum) spectrum).getDerivedCompoundMetadata();
			if (gcMetadata != null) {
				String derivativeTypes = "";
				if (gcMetadata.getDerivativeTypes() != null && !gcMetadata.getDerivativeTypes().isEmpty()) {
					for (Short derivativeType : gcMetadata.getDerivativeTypes())
						derivativeTypes += GCDerivedCompoundMetadata.getStringDerivativeType(derivativeType) + " ; ";
					// remove last comma:
					derivativeTypes = derivativeTypes.substring(0, derivativeTypes.length() - " ; ".length());
				}
				model.addAttribute("spectrum_derivatization_types", derivativeTypes);

				ReferenceChemicalCompound parentCompound = null;
				try {
					parentCompound = GenericCompoundManagementService.read(gcMetadata.getParentCompound().getId());
				} catch (Exception e) {
					e.printStackTrace();
				}
				if (parentCompound == null) {
					try {
						parentCompound = ChemicalCompoundManagementService.read(gcMetadata.getParentCompound().getId());
					} catch (Exception e) {
						e.printStackTrace();
					}
				}

				// TODO: add built name with score 3.5 to derivative names, and take main name
				// (higher score)!
				model.addAttribute("spectrum_derivative_name",
						parentCompound.getMainName() + " (" + derivativeTypes + ")");

				final GCDerivedCompound derivative = gcMetadata.getStructureDerivedCompound();
				if (derivative != null) {
					model.addAttribute("spectrum_derivative_inchikey", derivative.getInChIKey());
					model.addAttribute("spectrum_derivative_inchi", derivative.getInChI());
					model.addAttribute("spectrum_derivative_type", derivative.getTypeString());
					String pubchemID = null;
					if (derivative.getPubChemID() != null && !derivative.getPubChemID().equals("")) {
						pubchemID = derivative.getPubChemID();
						model.addAttribute("spectrum_derivative_pubchem", Jsoup.clean(pubchemID, Whitelist.basic()));
					}
				}

			}
		}

		// SAMPLE DATA
		// boolean displaySampleMix = false;
		ASampleMix sampleMixData = null, spectrumSampleMix = null;
		boolean isSampleMixLiquid;
		switch (spectrum.getSample()) {
		case Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND:
			model.addAttribute("spectrum_sample_type", "single-cpd");
			StructureChemicalCompound rcc = null;
			if (((CompoundSpectrum) spectrum).getListOfCompounds().size() == 1) {
				rcc = (StructureChemicalCompound) ((CompoundSpectrum) spectrum).getListOfCompounds().get(0);
				// rcc = StructuralCompoundManagementService.readByInChIKey(rcc.getInChIKey(),
				// dbName,
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
					String molFileRepPath = PeakForestUtils.getBundleConfElement("compoundMolFiles.folder");
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
			spectrumSampleMix = spectrum.getSampleMixMetadata(LiquidSampleMix.class);
			isSampleMixLiquid = true;
			if (spectrumSampleMix == null) {
				spectrumSampleMix = spectrum.getSampleMixMetadata(GasSampleMix.class);
				isSampleMixLiquid = false;
			}
			if (spectrumSampleMix != null) {
				ASampleMix mixData = ASampleMixMetadataDao.read(spectrumSampleMix.getId());
				if (mixData.getCompoundConcentration(rcc.getInChIKey()) != null) {
					model.addAttribute("spectrum_sample_compound_has_concentration", true);
					model.addAttribute("spectrum_sample_compound_concentration",
							mixData.getCompoundConcentration(rcc.getInChIKey()));
				}
				if (isSampleMixLiquid) {
					model.addAttribute("spectrum_sample_compound_liquid_solvent",
							((LiquidSampleMix) mixData).getLiquidSolventAsString());
				} else {
					model.addAttribute("spectrum_sample_compound_gas_solvent",
							((GasSampleMix) mixData).getGcmsSolventAsString());
					model.addAttribute("spectrum_sample_compound_derivation_method",
							((GasSampleMix) mixData).getDerivationMethodAsString());
				}
			}
			break;
		case Spectrum.SPECTRUM_SAMPLE_MIX_CHEMICAL_COMPOUND:
			model.addAttribute("spectrum_sample_type", "mix-cpd");
			spectrumSampleMix = spectrum.getSampleMixMetadata(LiquidSampleMix.class);
			isSampleMixLiquid = true;
			if (spectrumSampleMix == null) {
				spectrumSampleMix = spectrum.getSampleMixMetadata(GasSampleMix.class);
				isSampleMixLiquid = false;
			}
			if (spectrumSampleMix != null) {
				sampleMixData = ASampleMixMetadataDao.read(spectrumSampleMix.getId());
				// if (mixData.getCompoundConcentration(rcc.getInChIKey()) != null) {
				// model.addAttribute("spectrum_sample_compound_has_concentration", true);
				// model.addAttribute("spectrum_sample_compound_concentration",
				// mixData.getCompoundConcentration(rcc.getInChIKey()));
				// }
				if (isSampleMixLiquid) {
					model.addAttribute("spectrum_sample_compound_liquid_solvent",
							((LiquidSampleMix) sampleMixData).getLiquidSolventMixAsString());
				} else {
					model.addAttribute("spectrum_sample_compound_gas_solvent",
							((GasSampleMix) sampleMixData).getGcmsSolventAsString());
					model.addAttribute("spectrum_sample_compound_derivation_method",
							((GasSampleMix) sampleMixData).getDerivationMethodAsString());
				}
			}
			break;
		case Spectrum.SPECTRUM_SAMPLE_STANDARDIZED_MATRIX:
			model.addAttribute("spectrum_sample_type", "std-matrix");
			// if (spectrum.getSampleMixMetadata() != null)
			// sampleMixData = SampleMixMetadataManagementService
			// .read(spectrum.getSampleMixMetadata().getId());
			// AnalyticalMatrix analyticalMatrix = spectrum.getAnalyticalMatrixMetadata();
			// if (analyticalMatrix != null) {
			// model.addAttribute("spectrum_matrix_name",
			// analyticalMatrix.getMatrixTypeAsString());
			// model.addAttribute("spectrum_matrix_link",
			// analyticalMatrix.getMatrixTypeOntology());
			// }
			StandardizedMatrix standardizedMatrix = ((ISampleSpectrum) spectrum).getStandardizedMatrixMetadata();
			model.addAttribute("standardized_matrix", standardizedMatrix);
			break;
		case Spectrum.SPECTRUM_SAMPLE_ANALYTICAL_MATRIX:
			model.addAttribute("spectrum_sample_type", "analytical-matrix");
			AnalyticalMatrix analyticalMatrix = ((ISampleSpectrum) spectrum).getAnalyticalMatrixMetadata();
			model.addAttribute("analytical_matrix", analyticalMatrix);
			break;
		default:
			break;
		}

		if (sampleMixData != null) {
			List<StructureChemicalCompound> listCpdMix = new ArrayList<StructureChemicalCompound>();
			List<Long> idCpdToRead = new ArrayList<Long>();
			for (StructureChemicalCompound scc : sampleMixData.getStructuralChemicalCompounds().keySet())
				idCpdToRead.add(scc.getId());
			listCpdMix.addAll(ChemicalCompoundManagementService.read(idCpdToRead));
			listCpdMix.addAll(GenericCompoundManagementService.read(idCpdToRead));
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
				model.addAttribute("spectrum_type", "nmr-1d");
				// name display
				model.addAttribute("spectrum_name",
						PeakForestPruneUtils.convertGreekCharToHTML(((NMR1DSpectrum) spectrum).getMassBankLikeName()));
				// Acquisition
				if (((NMR1DSpectrum) spectrum).getAcquisition() != null)
					model.addAttribute("spectrum_nmr_analyzer_data_acquisition",
							((NMR1DSpectrum) spectrum).getAcquisitionAsString());

				// NMR ANALYZER + PEAKLIST TAB + PATTERN LIST TAB
				model.addAttribute("spectrum_nmr_analyzer", (abstractSpec).getAnalyzerNMRSpectrometerDevice());
				NMR1DSpectrum nmrSpectrum = NMR1DSpectrumManagementService.read((abstractSpec).getId());
				model.addAttribute("spectrum_nmr_analyzer_data", nmrSpectrum);
				List<PeakPattern> peakpatterns = new ArrayList<PeakPattern>();
				for (PeakPattern pp : nmrSpectrum.getListOfpeakPattern()) {
					peakpatterns.add(PeakPatternDao.read(pp.getId()));
				}
				model.addAttribute("spectrum_nmr_peakpatterns", peakpatterns);
			} else if (spectrum instanceof NMR2DSpectrum) {
				model.addAttribute("spectrum_type", "nmr-2d");
				// name display
				model.addAttribute("spectrum_name",
						PeakForestPruneUtils.convertGreekCharToHTML(((NMR2DSpectrum) spectrum).getMassBankLikeName()));
				// Acquisition
				if (((NMR2DSpectrum) spectrum).getAcquisition() != null)
					model.addAttribute("spectrum_nmr_analyzer_data_acquisition",
							((NMR2DSpectrum) spectrum).getAcquisitionAsString());
				// NMR ANALYZER + PEAKLIST TAB + PATTERN LIST TAB
				model.addAttribute("spectrum_nmr_analyzer", (abstractSpec).getAnalyzerNMRSpectrometerDevice());
				NMR2DSpectrum nmrSpectrum = NMR2DSpectrumManagementService.read((abstractSpec).getId());
				model.addAttribute("spectrum_nmr_analyzer_data", nmrSpectrum);
			}

			// use this field if system able to display "real" spectrum (lorentzienne)
			model.addAttribute("display_real_spectrum", abstractSpec.hasRawData());
			model.addAttribute("real_spectrum_code", abstractSpec.getRawDataFolder());

		} else if (//
		spectrum instanceof FullScanLCSpectrum || //
				spectrum instanceof FragmentationLCSpectrum || //
				spectrum instanceof FullScanGCSpectrum
				// new 2.3
				|| spectrum instanceof FullScanICSpectrum//
				|| spectrum instanceof FragmentationICSpectrum//
		) {
			// BASIC
			model.addAttribute("spectrum_name",
					PeakForestPruneUtils.convertGreekCharToHTML(((MassSpectrum) spectrum).getMassBankName()));

			if (spectrum instanceof FullScanLCSpectrum)
				model.addAttribute("spectrum_type", "lc-fullscan");
			else if (spectrum instanceof FragmentationLCSpectrum)
				model.addAttribute("spectrum_type", "lc-fragmentation");
			else if (spectrum instanceof FullScanGCSpectrum)
				model.addAttribute("spectrum_type", "gc-fullscan");
			// new 2.3
			else if (spectrum instanceof FullScanICSpectrum) {
				model.addAttribute("spectrum_type", "ic-fullscan");
			} else if (spectrum instanceof FragmentationICSpectrum) {
				model.addAttribute("spectrum_type", "ic-fragmentation");
			}

			if (spectrum instanceof FullScanLCSpectrum || spectrum instanceof FragmentationLCSpectrum) {
				// LC DATA
				model.addAttribute("spectrum_chromatography", "lc");
				LiquidChromatography lcData = LiquidChromatographyMetadataDao
						.read(((ILCSpectrum) spectrum).getLiquidChromatography().getId());
				model.addAttribute("spectrum_chromatography_method", lcData.getMethodProtocolAsString());
				model.addAttribute("spectrum_chromatography_col_constructor", lcData.getColumnConstructorAString());
				model.addAttribute("spectrum_chromatography_col_name", lcData.getColumnName());
				model.addAttribute("spectrum_chromatography_col_length", lcData.getColumnLength());
				model.addAttribute("spectrum_chromatography_col_diameter", lcData.getColumnDiameter());
				model.addAttribute("spectrum_chromatography_col_particule_size", lcData.getParticuleSize());
				model.addAttribute("spectrum_chromatography_col_temperature", lcData.getColumnTemperature());
				model.addAttribute("spectrum_chromatography_mode_lc", lcData.getLCModeAsString());
				model.addAttribute("spectrum_chromatography_solventA", lcData.getSolventAAsString());
				model.addAttribute("spectrum_chromatography_solventB", lcData.getSolventBAsString());
				model.addAttribute("spectrum_chromatography_solventApH", lcData.getPHSolventA());
				model.addAttribute("spectrum_chromatography_solventBpH", lcData.getPHSolventB());
				model.addAttribute("spectrum_chromatography_separation_flow_rate", lcData.getSeparationFlowRate());
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
			} else if (spectrum instanceof FullScanGCSpectrum) {
				// generic
				model.addAttribute("spectrum_name",
						PeakForestPruneUtils.convertGreekCharToHTML(((MassSpectrum) spectrum).getMassBankName()));
				// GC DATA
				model.addAttribute("spectrum_chromatography", "gc");
				GazChromatography gcData = GazChromatographyMetadataDao
						.read(((IGCSpectrum) spectrum).getGazChromatography().getId());
				model.addAttribute("spectrum_chromatography_method",
						GazChromatography.getStringMethodProtocol(gcData.getMethodProtocol()));
				model.addAttribute("spectrum_chromatography_col_constructor",
						GazChromatography.getStringColumnConstructor(gcData.getColumnConstructor()));
				model.addAttribute("spectrum_chromatography_col_name", gcData.getColumnName());
				model.addAttribute("spectrum_chromatography_col_length", gcData.getColumnLength());
				model.addAttribute("spectrum_chromatography_col_diameter", gcData.getColumnDiameter());
				model.addAttribute("spectrum_chromatography_col_particule_size", gcData.getParticuleSize());
				model.addAttribute("spectrum_chromatography_injection_volume", gcData.getInjectionVolume());
				model.addAttribute("spectrum_chromatography_injection_mode_string", gcData.getInjectionModeAsString());
				model.addAttribute("spectrum_chromatography_injection_mode", gcData.getInjectionMode());
				model.addAttribute("spectrum_chromatography_split_ratio", gcData.getSplitRatio());
				model.addAttribute("spectrum_chromatography_carrier_gas",
						GazChromatography.getStringCarrierGas(gcData.getCarrierGas()));
				model.addAttribute("spectrum_chromatography_gas_flow", gcData.getGasFlow());
				model.addAttribute("spectrum_chromatography_gas_opt",
						GazChromatography.getStringGasOpt(gcData.getGasOpt()));
				model.addAttribute("spectrum_chromatography_gas_pressure", gcData.getGasPressure());
				model.addAttribute("spectrum_chromatography_mode_gc", gcData.getGCModeAsString());
				model.addAttribute("spectrum_chromatography_liner_manufacturer",
						GazChromatography.getStringLinerManufacturer(gcData.getLinerManufacturer()));
				model.addAttribute("spectrum_chromatography_liner_type",
						GazChromatography.getStringLinerType(gcData.getLinerType()));
				// ..
				// Separation temperature programme
				List<Double> sortedKeys = new ArrayList<Double>(gcData.getSeparationTemperatureProgram().keySet());
				Collections.sort(sortedKeys);
				final Double[] temperature = new Double[sortedKeys.size()];
				int i = 0;
				for (final Double k : sortedKeys) {
					temperature[i] = k;
					i++;
				}
				model.addAttribute("spectrum_chromatography_stp_temperature", temperature);
				model.addAttribute("spectrum_chromatography_stp", gcData.getSeparationTemperatureProgram());
			}
			// new 2.3
			else if (spectrum instanceof IICSpectrum) {
				// LC DATA
				model.addAttribute("spectrum_chromatography", "ic");
				IonChromatography icData = IonChromatographyMetadataDao
						.read(((IICSpectrum) spectrum).getIonChromatography().getId());
				model.addAttribute("spectrum_chromatography_method", icData.getMethodProtocolAsString());
				model.addAttribute("spectrum_chromatography_col_constructor", icData.getColumnConstructorAString());
				model.addAttribute("spectrum_chromatography_col_name", icData.getColumnName());
				model.addAttribute("spectrum_chromatography_col_ionic_config", icData.getColumnIonicConfigAsString());
				model.addAttribute("spectrum_chromatography_col_suppressor_constructor",
						icData.getColumnSuppressorConstructorAsString());
				model.addAttribute("spectrum_chromatography_col_suppressor_name",
						icData.getColumnSuppressorNameAsString());
				model.addAttribute("spectrum_chromatography_col_is_makeup",
						icData.getColumnMakeup() != IonChromatography.IC_MAKEUP__NA);
				model.addAttribute("spectrum_chromatography_col_makeup", icData.getColumnMakeupAsString());
				model.addAttribute("spectrum_chromatography_col_makeup_flow_rate", icData.getColumnMakeupFlowRate());
				model.addAttribute("spectrum_chromatography_col_length", icData.getColumnLength());
				model.addAttribute("spectrum_chromatography_col_diameter", icData.getColumnDiameter());
				model.addAttribute("spectrum_chromatography_col_particule_size", icData.getParticuleSize());
				model.addAttribute("spectrum_chromatography_col_temperature", icData.getColumnTemperature());
				model.addAttribute("spectrum_chromatography_mode_ic", icData.getICModeAsString());
				model.addAttribute("spectrum_chromatography_solvent", icData.getSolventAsString());
				model.addAttribute("spectrum_chromatography_separation_flow_rate", icData.getSeparationFlowRate());
				// ..
				// Separation flow grad
				final List<Double> sortedKeys = new ArrayList<Double>(icData.getSeparationFlowGradient().keySet());
				Collections.sort(sortedKeys);
				Double[] time = new Double[sortedKeys.size()];
				int i = 0;
				for (final Double k : sortedKeys) {
					time[i] = k;
					i++;
				}
				model.addAttribute("spectrum_chromatography_sfg_time", time);
				model.addAttribute("spectrum_chromatography_sfg", icData.getSeparationFlowGradient());
			}

			// IONIZATION
			model.addAttribute("spectrum_ms_ionization", ((MassSpectrum) spectrum).getAnalyzerMassIonization());

			// MS ANALYZER
			model.addAttribute("spectrum_ms_analyzer", ((MassSpectrum) spectrum).getAnalyzerMassSpectrometerDevice());

			// MSMS
			if (spectrum instanceof IFragmentationSpectrum) {
				// MSMS ion beam
				if (((IFragmentationSpectrum) spectrum).getAnalyzerMassIon() instanceof AnalyzerMassIonBeamMetadata) {
					model.addAttribute("spectrum_msms_ionbeam",
							((IFragmentationSpectrum) spectrum).getAnalyzerMassIon());
				}
				// MSMS ion storage
				else if (((IFragmentationSpectrum) spectrum)
						.getAnalyzerMassIon() instanceof AnalyzerMassIonTrapMetadata) {
					model.addAttribute("spectrum_msms_iontrap",
							((IFragmentationSpectrum) spectrum).getAnalyzerMassIon());
				}
			}

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
			model.addAttribute("spectrum_ms_resolution_FWHM", ((MassSpectrum) spectrum).getInstrumentResolutionFWHM());

			if (spectrum instanceof FullScanLCSpectrum || spectrum instanceof FullScanGCSpectrum//
					|| spectrum instanceof FullScanICSpectrum//
			)
				model.addAttribute("spectrum_ms_scan_type", "MS (fullscan)");
			else if (spectrum instanceof FragmentationLCSpectrum) {
				model.addAttribute("spectrum_ms_scan_type",
						((FragmentationLCSpectrum) spectrum).getFragmentationLevelString());
				// new 2.0
				model.addAttribute("isolation_mode", ((FragmentationLCSpectrum) spectrum).getModeAsString());
				model.addAttribute("qz_isolation", ((FragmentationLCSpectrum) spectrum).getQzIsolationActivation());
				model.addAttribute("activation_time", ((FragmentationLCSpectrum) spectrum).getActivationTime());
				model.addAttribute("isolation_window", ((FragmentationLCSpectrum) spectrum).getIsolationWindow());
				model.addAttribute("center_isolation_window",
						((FragmentationLCSpectrum) spectrum).getCenterIsolationWindow());
				model.addAttribute("frag_energy", ((FragmentationLCSpectrum) spectrum).getFragEnery());
			}
			// new 2.3
			else if (spectrum instanceof FragmentationICSpectrum) {
				model.addAttribute("spectrum_ms_scan_type",
						((FragmentationICSpectrum) spectrum).getFragmentationLevelString());
				// new 2.0
				model.addAttribute("isolation_mode", ((FragmentationICSpectrum) spectrum).getModeAsString());
				model.addAttribute("qz_isolation", ((FragmentationICSpectrum) spectrum).getQzIsolationActivation());
				model.addAttribute("activation_time", ((FragmentationICSpectrum) spectrum).getActivationTime());
				model.addAttribute("isolation_window", ((FragmentationICSpectrum) spectrum).getIsolationWindow());
				model.addAttribute("center_isolation_window",
						((FragmentationICSpectrum) spectrum).getCenterIsolationWindow());
				model.addAttribute("frag_energy", ((FragmentationICSpectrum) spectrum).getFragEnery());
			}
			model.addAttribute("spectrum_ms_range_from", ((MassSpectrum) spectrum).getRangeMassFrom());
			model.addAttribute("spectrum_ms_range_to", ((MassSpectrum) spectrum).getRangeMassTo());
			model.addAttribute("spectrum_rt_min_from",
					shortifyText(((MassSpectrum) spectrum).getRangeRetentionTimeFrom()));
			model.addAttribute("spectrum_rt_min_to", shortifyText(((MassSpectrum) spectrum).getRangeRetentionTimeTo()));

			if (spectrum instanceof ILCSpectrum) {
				model.addAttribute("spectrum_rt_meoh_from",
						shortifyText(((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentFrom()));
				model.addAttribute("spectrum_rt_meoh_to",
						shortifyText(((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentTo()));
				//
				try {
					model.addAttribute("spectrum_rt_acn_from",
							shortifyText((((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentFrom())
									* ChromatoUtils.MEOH_TO_ACN_RATIO));
				} catch (NullPointerException npe) {
				}
				try {
					model.addAttribute("spectrum_rt_acn_to",
							shortifyText((((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentTo())
									* ChromatoUtils.MEOH_TO_ACN_RATIO));
				} catch (NullPointerException npe) {
				}
			} else if (spectrum instanceof IGCSpectrum) {
				model.addAttribute("spectrum_ri_alkane_from",
						shortifyText(((IGCSpectrum) spectrum).getRangeRetentionIndexAlkaneFrom()));
				model.addAttribute("spectrum_ri_alkane_to",
						shortifyText(((IGCSpectrum) spectrum).getRangeRetentionIndexAlkaneTo()));
			}
			// new 2.3
			else if (spectrum instanceof IICSpectrum) {
				model.addAttribute("spectrum_rt_koh_from",
						shortifyText(((IICSpectrum) spectrum).getRangeRetentionTimeEqPotassiumHydroxidePercentFrom()));
				model.addAttribute("spectrum_rt_koh_to",
						shortifyText(((IICSpectrum) spectrum).getRangeRetentionTimeEqPotassiumHydroxidePercentTo()));
			}

			// OTHER MSMS
			if (spectrum instanceof FragmentationLCSpectrum) {
				// is MSMS child
				model.addAttribute("spectrum_msms_isMSMS",
						((FragmentationLCSpectrum) spectrum).getMsLevel() > FragmentationLCSpectrum.FRAGMENTATION_MS);

				model.addAttribute("spectrum_msms_parentIonMZ", ((FragmentationLCSpectrum) spectrum).getParentIonMZ());

				// model.addAttribute("spectrum_msms_parentIonMZ",
				// ((FragmentationLCSpectrum) spectrum).getParentIonMZ());
				// model.addAttribute("spectrum_msms_parentSpectrum",
				// ((FragmentationLCSpectrum) spectrum).getParentSpectrum());
				// is MSMS parent
				// model.addAttribute("spectrum_msms_hasChild", !((FragmentationLCSpectrum)
				// spectrum).getChildrenSpectra().isEmpty());
			}
			if (spectrum instanceof FragmentationICSpectrum) {
				// is MSMS child
				model.addAttribute("spectrum_msms_isMSMS",
						((FragmentationICSpectrum) spectrum).getMsLevel() > FragmentationICSpectrum.FRAGMENTATION_MS);
				model.addAttribute("spectrum_msms_parentIonMZ", ((FragmentationICSpectrum) spectrum).getParentIonMZ());
			}

			//
			// PEAKLIST TAB
			model.addAttribute("spectrum_ms_peaks", spectrum.getPeaks());

			// peaklist curation lvl
			model.addAttribute("spectrum_ms_peaks_curation_lvl", ((MassSpectrum) spectrum).getCurationLevelAsString());
		}

		// METADATA OTHER
		final OtherMetadata otherMetadata = OtherMetadataDao.read(spectrum.getOtherMetadata().getId());
		model.addAttribute("spectrum_othermetadata", otherMetadata);

		// RELATED SPECTRA (same other metadata)
		final List<Spectrum> relatedSpectra = new ArrayList<Spectrum>();
		final List<Spectrum> spectraChildren = new ArrayList<>();
		MassSpectrum parent = null;

		for (Spectrum s : otherMetadata.getSpectra()) {
			if (s instanceof CompoundSpectrum) {
				//
				if (s.getSample() == Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND) {
					((CompoundSpectrum) s).setListOfCompounds(((CompoundSpectrum) spectrum).getListOfCompounds());
				}
			}
			s.setMetadata(spectrum.getMetadata());
			if (s.getId() != spectrum.getId()) {
				relatedSpectra.add(s);
			}
			// parent / child
			if (s instanceof FragmentationLCSpectrum) {
				if (((FragmentationLCSpectrum) spectrum).getParentSpectrum() != null
						&& s.getId() == ((FragmentationLCSpectrum) spectrum).getParentSpectrum().getId()) {
					parent = (FragmentationLCSpectrum) s;
				} else if (((FragmentationLCSpectrum) s).getParentSpectrum() != null
						&& spectrum.getId() == ((FragmentationLCSpectrum) s).getParentSpectrum().getId()) {
					spectraChildren.add(s);
				}
			}
			// new 2.3 parent -- child
			if (s instanceof FragmentationICSpectrum) {
				if (((FragmentationICSpectrum) spectrum).getParentSpectrum() != null
						&& s.getId() == ((FragmentationICSpectrum) spectrum).getParentSpectrum().getId()) {
					parent = (FragmentationICSpectrum) s;
				} else if (((FragmentationICSpectrum) s).getParentSpectrum() != null
						&& spectrum.getId() == ((FragmentationICSpectrum) s).getParentSpectrum().getId()) {
					spectraChildren.add(s);
				}
			}
		}
		if (relatedSpectra.isEmpty()) {
			model.addAttribute("spectrum_has_related_spectra", false);
		} else {
			model.addAttribute("spectrum_has_related_spectra", true);
		}
		model.addAttribute("spectrum_related_spectra", relatedSpectra);

		// children
		if (!spectraChildren.isEmpty()) {
			model.addAttribute("spectrum_msms_hasChild", true);
			model.addAttribute("spectrum_msms_children", spectraChildren);
		} else {
			model.addAttribute("spectrum_msms_hasChild", false);
		}

		// parent
		if (parent != null) {
			model.addAttribute("spectrum_msms_parentSpectrum", parent);
		}

		// END
	}

	private void loadSpectraMeta(//
			final Model model, //
			final Spectrum spectrum, //
			final HttpServletRequest request) throws Exception {

		// BASIC DATA
		String spectrumName = PeakForestPruneUtils.convertGreekCharToHTML(spectrum.getName());
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
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((NMR1DSpectrum) spectrum).getMassBankLikeName());
			spectrumTechnique += ", NMR";
			// BASIC
			model.addAttribute("spectrum_name",
					PeakForestPruneUtils.convertGreekCharToHTML(((NMR1DSpectrum) spectrum).getMassBankLikeName()));
			// Acquisition
			if (((NMR1DSpectrum) spectrum).getAcquisition() != null)
				spectrumTechnique += ", " + ((NMR1DSpectrum) spectrum).getAcquisitionAsString();
		} else if (spectrum instanceof NMR2DSpectrum) {
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((NMR2DSpectrum) spectrum).getMassBankLikeName());
			spectrumTechnique += ", NMR";
			// BASIC
			model.addAttribute("spectrum_name",
					PeakForestPruneUtils.convertGreekCharToHTML(((NMR2DSpectrum) spectrum).getMassBankLikeName()));
			// Acquisition
			if (((NMR2DSpectrum) spectrum).getAcquisition() != null)
				spectrumTechnique += ", " + ((NMR2DSpectrum) spectrum).getAcquisitionAsString();
		} else if (spectrum instanceof FullScanLCSpectrum) {
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((FullScanLCSpectrum) spectrum).getMassBankName());
			spectrumTechnique += ", LCMS";
		} else if (spectrum instanceof FragmentationLCSpectrum) {
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((FragmentationLCSpectrum) spectrum).getMassBankName());
			spectrumTechnique += ", LCMSMS";
		} else if (spectrum instanceof FullScanGCSpectrum) {
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((FullScanGCSpectrum) spectrum).getMassBankName());
			spectrumTechnique += ", GCMS";
		}
		// new 2.3
		else if (spectrum instanceof FullScanICSpectrum) {
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((FullScanICSpectrum) spectrum).getMassBankName());
			spectrumTechnique += ", ICMS";
		} else if (spectrum instanceof FragmentationICSpectrum) {
			spectrumName = PeakForestPruneUtils
					.convertGreekCharToHTML(((FragmentationICSpectrum) spectrum).getMassBankName());
			spectrumTechnique += ", ICMSMS";
		}

		// ranking
		model.addAttribute("ranking_data", true);
		model.addAttribute("page_title", spectrumName);
		model.addAttribute("page_keywords", spectrumName + spectrumTechnique + spectrumOther);
		model.addAttribute("page_description",
				"spectrum " + spectrumName + " identified as " + spectrum.getPeakForestID());

		// END
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/update-spectrum/{id}", //
			headers = { //
					"Content-type=application/json"//
			}//
	)
	@SuppressWarnings("unchecked")
	@ResponseBody
	public boolean updateSpectrum(//
			final @PathVariable long id, //
			final @RequestBody Map<String, Object> data, //
			final HttpServletRequest request) {
		Spectrum spectrum;
		try {
			spectrum = SpectrumManagementService.read(id);
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
		if (!curationMessages.isEmpty()) {
			try {
				CurationMessageManagementService.create(curationMessages, user.getId(), spectrum);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}

		// log
		spectrumLog("update spectrum @id=" + id + "; ");

		return true;
	}

	@Secured("ROLE_CURATOR")
	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/edit-spectrum-modal/{id}"//
	)
	public String spectrumEdit(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final @PathVariable int id, //
			final Model model) throws PeakForestManagerException {
		// load data
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		// init var
		final List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (final Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound) {
					try {
						listCC.add(StructuralCompoundManagementService
								.readByInChIKey(((StructureChemicalCompound) c).getInChIKey()));
					} catch (final Exception e) {
						e.printStackTrace();
					}
				} else {
					listCC.add(c);
				}
			}
			((CompoundSpectrum) spectrum).setListOfCompounds(listCC);
		}
		// load data in model
		if (spectrum != null) {
			try {
				loadSpectraMetadata(model, spectrum, request);
				model.addAttribute("contains_spectrum", true);
			} catch (final Exception e) {
				e.printStackTrace();
			}
		} else {
			model.addAttribute("contains_spectrum", false);
		}
		User user = null;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
		}
		if (user != null && user.isCurator()) {
			model.addAttribute("curator", true);
			model.addAttribute("curationMessages", spectrum.getCurationMessages());
		} else {
			model.addAttribute("curator", false);
		}
		// RETURN
		return "modal/edit-spectrum-modal";
	}

	@Secured("ROLE_CURATOR")
	@RequestMapping(//
			value = "/delete-spectrum/{type}/{id}", //
			method = RequestMethod.POST//
	)
	@ResponseBody
	public Object spectrumDelete(//
			// REST
			final Model model, //
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			// PATH
			final @PathVariable long id, //
			final @PathVariable String type //

	) throws PeakForestManagerException {
		try {
			// delete action
			switch (type) {
			case "lc-fullscan":
				return FullScanLCSpectrumManagementService.delete(id);
			case "lc-fragmentation":
				return FragmentationLCSpectrumManagementService.delete(id);
			case "nmr-1d":
				return NMR1DSpectrumManagementService.delete(id);
			case "nmr-2d":
				return NMR2DSpectrumManagementService.delete(id);
			// new 2.1
			case "gc-fullscan":
				return FullScanGCSpectrumManagementService.delete(id);
			// new 2.3
			case "ic-fullscan":
				return FullScanICSpectrumManagementService.delete(id);
			case "ic-fragmentation":
				return FragmentationICSpectrumManagementService.delete(id);
			default:
				return Boolean.FALSE;
			}
		} catch (final Exception e) {
			e.printStackTrace();
			return Boolean.FALSE;
		}
	}

	@Secured("ROLE_EDITOR")
	@RequestMapping(//
			method = RequestMethod.POST, //
			value = "/edit-spectrum/{id}", //
			headers = { //
					"Content-type=application/json"//
			}//
	)
	@ResponseBody
	@SuppressWarnings("unchecked")
	public boolean editSpectrum(//
			final @PathVariable long id, //
			final @RequestBody Map<String, Object> data) {

		// TODO remove @Secured annotation and begin this function with check if user
		// either a curator of the
		// owner of this spectrum

		// init request
		try {
			// 0 - init
			// fetch spectrum in db;
			final Spectrum spectrum = SpectrumManagementService.read(id);
			// ready to read json
			final Map<String, Object> spectrumDataToUpdate = (Map<String, Object>) data.get("newSpectrumData");

			// I - update SAMPLE data
			boolean updateSampleMetadata = false;
			boolean updateSampleMixRCCMap = false;

			// I.A - fetch metadata in db
			ASampleMix sampleMixData = null, spectrumSampleMix = null;
			Map<StructureChemicalCompound, Double> newMap = new HashMap<>();
			switch (spectrum.getSample()) {
			case Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND:
				// TODO keep it in case of user can edit RCC related to a cpd
				StructureChemicalCompound rcc = null;
				if (((CompoundSpectrum) spectrum).getListOfCompounds().size() == 1) {
					rcc = (StructureChemicalCompound) ((CompoundSpectrum) spectrum).getListOfCompounds().get(0);
					// model.addAttribute("spectrum_sample_compound_id", rcc.getId());
				}

				spectrumSampleMix = spectrum.getSampleMixMetadata(LiquidSampleMix.class);
				if (spectrumSampleMix == null)
					spectrumSampleMix = spectrum.getSampleMixMetadata(GasSampleMix.class);
				if (spectrumSampleMix != null) {
					sampleMixData = ASampleMixMetadataDao.read(spectrumSampleMix.getId());
					// update Ref CC concentration
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_concentration")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_concentration") != null) {
						Double newConcentration = null;
						try {
							newConcentration = Double.parseDouble(
									spectrumDataToUpdate.get("spectrum_sample_compound_concentration").toString());
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
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_liquid_solvent")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_liquid_solvent") != null) {
						((LiquidSampleMix) sampleMixData).setLiquidSolvent(LiquidSampleMix.getStandardizedLiquidSolvent(
								(String) spectrumDataToUpdate.get("spectrum_sample_compound_liquid_solvent")));
						updateSampleMetadata = true;
					}
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_gas_solvent")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_gas_solvent") != null) {
						((GasSampleMix) sampleMixData).setGcmsSolvent(GasSampleMix.getStandardizedGCMSsolvent(
								(String) spectrumDataToUpdate.get("spectrum_sample_compound_gas_solvent")));
						updateSampleMetadata = true;
					}
					// derivation method
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_derivation_method")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_derivation_method") != null) {
						((GasSampleMix) sampleMixData).setDerivationMethod(GasSampleMix.getStandardizedDerivationMethod(
								(String) spectrumDataToUpdate.get("spectrum_sample_compound_derivation_method")));
						updateSampleMetadata = true;
					}
				}
				break;
			case Spectrum.SPECTRUM_SAMPLE_MIX_CHEMICAL_COMPOUND:
				spectrumSampleMix = spectrum.getSampleMixMetadata(LiquidSampleMix.class);
				if (spectrumSampleMix == null)
					spectrumSampleMix = spectrum.getSampleMixMetadata(GasSampleMix.class);
				if (spectrumSampleMix != null) {
					sampleMixData = ASampleMixMetadataDao.read(spectrumSampleMix.getId());

					// sample mix solvent
					if (spectrumDataToUpdate.containsKey("spectrum_sample_compound_liquid_solvent_mix")
							&& spectrumDataToUpdate.get("spectrum_sample_compound_liquid_solvent_mix") != null) {
						((LiquidSampleMix) sampleMixData).setLiquidSolvent(
								LiquidSampleMix.getStandardizedLiquidSolventMix((String) spectrumDataToUpdate
										.get("spectrum_sample_compound_liquid_solvent_mix")));
						updateSampleMetadata = true;
					}
				}
				break;
			case Spectrum.SPECTRUM_SAMPLE_STANDARDIZED_MATRIX:
				spectrumSampleMix = spectrum.getSampleMixMetadata(LiquidSampleMix.class);
				if (spectrumSampleMix == null)
					spectrumSampleMix = spectrum.getSampleMixMetadata(GasSampleMix.class);
				if (spectrumSampleMix != null)
					sampleMixData = ASampleMixMetadataDao.read(spectrumSampleMix.getId());
				AnalyticalMatrix analyticalMatrix = spectrum.getAnalyticalMatrixMetadata();
				if (analyticalMatrix != null) {
					// model.addAttribute("spectrum_matrix_name",
					// analyticalMatrix.getMatrixTypeAsString());
					// model.addAttribute("spectrum_matrix_link",
					// analyticalMatrix.getStdMatrixLink());
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
									.readByInChIKey(inChIKey);
							try {
								coucentration = Double.parseDouble(rawCpdMixData.get("concentration").toString());
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
				if (updateSampleMixRCCMap) {
					sampleMixData.setStructuralChemicalCompounds(newMap);
				}
				ASampleMixMetadataDao.update(sampleMixData.getId(), sampleMixData);
			}

			// I.C - update NMR sample tube metadata
			if (spectrum instanceof NMRSpectrum) {
				boolean updateSampleNMRtube = false;
				SampleNMRTubeConditions nmrTubeMetadata = SampleNMRTubeConditionsDao
						.read(((NMRSpectrum) spectrum).getSampleNMRTubeConditionsMetadata().getId());

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
						nmrTubeMetadata.setPotentiaHydrogenii(Double.parseDouble(
								((String) spectrumDataToUpdate.get("spectrum_nmr_tube_prep_poentiaHydrogenii"))));
						updateSampleNMRtube = true;
					} catch (NumberFormatException nfe) {
					}
				}

				// spectrum_nmr_tube_prep_ref_chemical_shift_indocator
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_ref_chemical_shift_indocator")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_ref_chemical_shift_indocator") != null) {
					nmrTubeMetadata.setReferenceChemicalShifIndicator(SampleNMRTubeConditions
							.getStandardizedNMRreferenceChemicalShifIndicator((String) spectrumDataToUpdate
									.get("spectrum_nmr_tube_prep_ref_chemical_shift_indocator")));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other")
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
						nmrTubeMetadata.setReferenceConcentration(Double.parseDouble(
								((String) spectrumDataToUpdate.get("spectrum_nmr_tube_prep_ref_concentration"))));
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
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_lock_substance_vol_concentration")
						&& spectrumDataToUpdate
								.get("spectrum_nmr_tube_prep_lock_substance_vol_concentration") != null) {
					try {
						nmrTubeMetadata
								.setLockSubstanceVolumicConcentration(Double.parseDouble(((String) spectrumDataToUpdate
										.get("spectrum_nmr_tube_prep_lock_substance_vol_concentration"))));
						updateSampleNMRtube = true;
					} catch (NumberFormatException nfe) {
					}
				}

				// spectrum_nmr_tube_prep_buffer_solution
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_lock_substance")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_lock_substance") != null) {
					nmrTubeMetadata.setBufferSolution(SampleNMRTubeConditions.getStandardizedNMRbufferSolution(
							(String) spectrumDataToUpdate.get("spectrum_nmr_tube_prep_lock_substance")));
					updateSampleNMRtube = true;
				}

				// spectrum_nmr_tube_prep_buffer_solution_concentration
				if (spectrumDataToUpdate.containsKey("spectrum_nmr_tube_prep_buffer_solution_concentration")
						&& spectrumDataToUpdate.get("spectrum_nmr_tube_prep_buffer_solution_concentration") != null) {
					try {
						nmrTubeMetadata.setBufferSolutionConcentration(Double.parseDouble(((String) spectrumDataToUpdate
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
					SampleNMRTubeConditionsDao.update(nmrTubeMetadata.getId(), nmrTubeMetadata);
				}
			}

			// II - update LC chromato data
			if (spectrum instanceof ILCSpectrum) {
				// II.A - init var
				boolean updateLCchromatoData = false;
				LiquidChromatography lcMetadata = LiquidChromatographyMetadataDao
						.read(((ILCSpectrum) spectrum).getLiquidChromatography().getId());

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
					lcMetadata.setColumnOther(
							spectrumDataToUpdate.get("spectrum_chromatography_col_constructor_other").toString());
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
						collength = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_chromatography_col_length").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setColumnLength(collength);
				}

				// spectrum_chromatography_col_name: "Hypersil Gold C18"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_name")) {
					updateLCchromatoData = true;
					lcMetadata.setColumnName(spectrumDataToUpdate.get("spectrum_chromatography_col_name").toString());
				}

				// spectrum_chromatography_col_particule_size: "1.9"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_particule_size")) {
					updateLCchromatoData = true;
					Double colPartiSize = null;
					try {
						colPartiSize = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_col_particule_size").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setParticuleSize(colPartiSize);
				}

				// spectrum_chromatography_col_temperature: "40.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_temperature")) {
					updateLCchromatoData = true;
					Double colTemp = null;
					try {
						colTemp = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_col_temperature").toString());
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

				// spectrum_chromatography_mode_lc: "Isocratic"
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
						sfgRate = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_separation_flow_rate").toString());
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
						pH = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_chromatography_solventApH").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setPHSolventA(pH);
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
						pH = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_chromatography_solventBpH").toString());
					} catch (NumberFormatException e) {
					}
					lcMetadata.setPHSolventB(pH);
				}
				// spectrum_chromatography_sfg_time
				Map<Double, Double[]> newSFG = lcMetadata.getSeparationFlowGradient();
				if (spectrumDataToUpdate.containsKey("spectrum_chromatography_sfg_time")
						&& spectrumDataToUpdate.get("spectrum_chromatography_sfg_time") != null) {
					if (spectrumDataToUpdate.get("spectrum_chromatography_sfg_time") instanceof ArrayList<?>) {
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
					LiquidChromatographyMetadataDao.update(lcMetadata.getId(), lcMetadata, newSFG);
				}
			}
			// GC data
			else if (spectrum instanceof IGCSpectrum) {
				// II.A - init var
				boolean updateGCchromatoData = false;
				GazChromatography gcMetadata = GazChromatographyMetadataDao
						.read(((IGCSpectrum) spectrum).getGazChromatography().getId());
				// II.B - update object
				// spectrum_gas_chromatography_method: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_gas_chromatography_method")) {
					updateGCchromatoData = Boolean.TRUE;
					gcMetadata.setMethodProtocol(GazChromatography.getStandardizedMethodProtocol(
							spectrumDataToUpdate.get("spectrum_gas_chromatography_method").toString()));
				}
				// spectrum_chromatography_col_constructor: "Thermo"
				if (constainKey(spectrumDataToUpdate, "spectrum_gas_chromatography_col_constructor")) {
					updateGCchromatoData = Boolean.TRUE;
					gcMetadata.setColumnConstructor(GazChromatography.getStandardizedColumnConstructor(
							spectrumDataToUpdate.get("spectrum_gas_chromatography_col_constructor").toString()));
				}
//				// spectrum_chromatography_col_constructor_other
//				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_constructor_other")) {
//					updateGCchromatoData = Boolean.TRUE;
//					gcMetadata.setColumnOther(
//							spectrumDataToUpdate.get("spectrum_chromatography_col_constructor_other").toString());
//				}
				// spectrum_chromatography_col_diameter: "2.1"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_diameter")) {
					updateGCchromatoData = true;
					Double colDiam = null;
					try {
						colDiam = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_col_diameter").toString());
					} catch (NumberFormatException e) {
					}
					gcMetadata.setColumnDiameter(colDiam);
				}
				// spectrum_chromatography_col_length: "100.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_length")) {
					updateGCchromatoData = true;
					Double collength = null;
					try {
						collength = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_chromatography_col_length").toString());
					} catch (NumberFormatException e) {
					}
					gcMetadata.setColumnLength(collength);
				}
				// spectrum_chromatography_col_name: "Hypersil Gold C18"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_name")) {
					updateGCchromatoData = Boolean.TRUE;
					gcMetadata.setColumnName(spectrumDataToUpdate.get("spectrum_chromatography_col_name").toString());
				}
				// spectrum_chromatography_col_particule_size: "1.9"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_particule_size")) {
					updateGCchromatoData = Boolean.TRUE;
					Double colPartiSize = null;
					try {
						colPartiSize = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_col_particule_size").toString());
					} catch (NumberFormatException e) {
					}
					gcMetadata.setParticuleSize(colPartiSize);
				}
				// spectrum_chromatography_injection_volume
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_injection_volume")) {
					updateGCchromatoData = Boolean.TRUE;
					Double injectionVol = null;
					try {
						injectionVol = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_injection_volume").toString());
					} catch (final NumberFormatException e) {
					}
					gcMetadata.setInjectionVolume(injectionVol);
				}
				// Injection mode
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_injection_mode")) {
					updateGCchromatoData = Boolean.TRUE;
					gcMetadata.setInjectionMode(GazChromatography.getStandardizedInjectionMode(//
							spectrumDataToUpdate.get("spectrum_chromatography_injection_mode").toString()));
				}
				// Split ratio
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_split_ratio")) {
					updateGCchromatoData = Boolean.TRUE;
					Integer splitRatio = null;
					try {
						splitRatio = Integer
								.parseInt(spectrumDataToUpdate.get("spectrum_chromatography_split_ratio").toString());
					} catch (final NumberFormatException e) {
					}
					gcMetadata.setSplitRatio(splitRatio);
				}
				// carrier gas
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_carrier_gas")) {
					updateGCchromatoData = Boolean.TRUE;
					gcMetadata.setCarrierGas(//
							GazChromatography.getStandardizedCarrierGas(//
									spectrumDataToUpdate.get("spectrum_chromatography_carrier_gas").toString()));
				}
				// gas flow
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_gas_flow")) {
					updateGCchromatoData = Boolean.TRUE;
					Double gasFlow = null;
					try {
						gasFlow = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_chromatography_gas_flow").toString());
					} catch (final NumberFormatException e) {
					}
					gcMetadata.setGasFlow(//
							gasFlow);
				}
				// spectrum_chromatography_gas_opt
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_gas_opt")) {
					updateGCchromatoData = Boolean.TRUE;
					gcMetadata.setGasOpt(//
							GazChromatography.getStandardizedGasOpt(//
									spectrumDataToUpdate.get("spectrum_chromatography_gas_opt").toString()));
				}
				// spectrum_chromatography_gas_pressure
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_gas_pressure")) {
					updateGCchromatoData = Boolean.TRUE;
					Double gasPressur = null;
					try {
						gasPressur = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_chromatography_gas_pressure").toString());
					} catch (final NumberFormatException e) {
					}
					gcMetadata.setGasPressure(//
							gasPressur);
				}
				// spectrum_chromatography_mode_gc: "Isocratic"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_mode_gc")) {
					updateGCchromatoData = true;
					gcMetadata.setGcMode(GazChromatography.getStandardizedGCMode(
							spectrumDataToUpdate.get("spectrum_chromatography_mode_gc").toString()));
				}
				// spectrum_chromatography_liner_manufacturer
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_liner_manufacturer")) {
					updateGCchromatoData = true;
					gcMetadata.setLinerManufacturer(//
							GazChromatography.getStandardizedLinerManufacturer(//
									spectrumDataToUpdate.get("spectrum_chromatography_liner_manufacturer").toString()));
				}
				// spectrum_chromatography_liner_type
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_liner_type")) {
					updateGCchromatoData = true;
					gcMetadata.setLinerType(//
							GazChromatography.getStandardizedLinerType(
									spectrumDataToUpdate.get("spectrum_chromatography_liner_type").toString()));
				}
				// spectrum_chromatography_sfg_time
				final Map<Double, Double[]> newSFG = gcMetadata.getSeparationTemperatureProgram();
				if (spectrumDataToUpdate.containsKey("spectrum_chromatography_stp_temperature")
						&& spectrumDataToUpdate.get("spectrum_chromatography_stp_temperature") != null) {
					if (spectrumDataToUpdate.get("spectrum_chromatography_stp_temperature") instanceof ArrayList<?>) {
						newSFG.clear();
						updateGCchromatoData = Boolean.TRUE;
						final ArrayList<Map<String, Object>> rawSFG = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_chromatography_stp_temperature");
						for (final Map<String, Object> rawCpdMixData : rawSFG) {
							if (rawCpdMixData.containsKey("temp") && rawCpdMixData.get("temp") != null
									&& rawCpdMixData.containsKey("r") && rawCpdMixData.get("r") != null
									&& rawCpdMixData.containsKey("t") && rawCpdMixData.get("t") != null) {
								final String timeS = rawCpdMixData.get("temp").toString();
								final String aS = rawCpdMixData.get("r").toString();
								final String bS = rawCpdMixData.get("t").toString();
								try {
									final double time = Double.parseDouble(timeS);
									final double a = Double.parseDouble(aS);
									final double b = Double.parseDouble(bS);
									final Double[] tabSFG = new Double[2];
									tabSFG[0] = a;
									tabSFG[1] = b;
									newSFG.put(time, tabSFG);
								} catch (final NumberFormatException nfe) {
								}
							}
						}
					}
				}
				// II.C - save object (if needed)
				if (updateGCchromatoData) {
					GazChromatographyMetadataDao.update(gcMetadata.getId(), gcMetadata, newSFG);
				}
			}
			// IC data
			else if (spectrum instanceof IICSpectrum) {
				// II.A - init var
				boolean updateICchromatoData = Boolean.FALSE;
				IonChromatography icMetadata = IonChromatographyMetadataDao
						.read(((IICSpectrum) spectrum).getIonChromatography().getId());
				// II.B - update object
				// spectrum_ion_chromatography_method: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_ion_chromatography_method")) {
					updateICchromatoData = true;
					icMetadata.setMethodProtocol(IonChromatography.getStandardizedMethodProtocol(
							spectrumDataToUpdate.get("spectrum_ion_chromatography_method").toString()));
				}
				// spectrum_chromatography_col_constructor: "Thermo"
				if (constainKey(spectrumDataToUpdate, "spectrum_ion_chromatography_col_constructor")) {
					updateICchromatoData = true;
					icMetadata.setColumnConstructor(IonChromatography.getStandardizedColumnConstructor(
							spectrumDataToUpdate.get("spectrum_ion_chromatography_col_constructor").toString()));
				}
				// spectrum_chromatography_col_constructor_other
				if (constainKey(spectrumDataToUpdate, "spectrum_ion_chromatography_col_constructor_other")) {
					updateICchromatoData = true;
					icMetadata.setColumnOther(
							spectrumDataToUpdate.get("spectrum_ion_chromatography_col_constructor_other").toString());
				}
				// spectrum_chromatography_col_name: "Hypersil Gold C18"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_name")) {
					updateICchromatoData = true;
					icMetadata.setColumnName(spectrumDataToUpdate.get("spectrum_chromatography_col_name").toString());
				}
				// spectrum_chromatography_col_ionic_config
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_ionic_config")) {
					updateICchromatoData = true;
					icMetadata.setColumnIonicConfig(//
							IonChromatography.getStdColumnIonicConfig(//
									spectrumDataToUpdate.get("spectrum_chromatography_col_ionic_config").toString()//
							));
				}
				// spectrum_chromatography_col_suppressor_constructor
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_suppressor_constructor")) {
					updateICchromatoData = true;
					icMetadata.setColumnSuppressorConstructor(//
							IonChromatography.getStdColumnSuppressorConstructor(//
									spectrumDataToUpdate.get("spectrum_chromatography_col_suppressor_constructor")
											.toString()//
							));
				}
				// spectrum_chromatography_col_suppressor_name
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_suppressor_name")) {
					updateICchromatoData = true;
					icMetadata.setColumnSuppressorName(//
							IonChromatography.getStdColumnSuppressorName(//
									spectrumDataToUpdate.get("spectrum_chromatography_col_suppressor_name").toString()//
							));
				}
				// spectrum_chromatography_col_makeup
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_makeup")) {
					updateICchromatoData = true;
					icMetadata.setColumnMakeup(//
							IonChromatography.getStdColumnMakeup(//
									spectrumDataToUpdate.get("spectrum_chromatography_col_makeup").toString()//
							));
				}
				// spectrum_chromatography_col_makeup_flow_rate
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_makeup_flow_rate")) {
					updateICchromatoData = true;
					icMetadata.setColumnMakeupFlowRate(//
							getDoubleVal(spectrumDataToUpdate, "spectrum_chromatography_col_makeup_flow_rate")//
					);

				}
				// spectrum_chromatography_col_length: "100.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_length")) {
					updateICchromatoData = Boolean.TRUE;
					final Double collength = getDoubleVal(spectrumDataToUpdate, "spectrum_chromatography_col_length");
					icMetadata.setColumnLength(collength);
				}
				// spectrum_chromatography_col_diameter: "2.1"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_diameter")) {
					updateICchromatoData = Boolean.TRUE;
					final Double colDiam = getDoubleVal(spectrumDataToUpdate, "spectrum_chromatography_col_diameter");
					icMetadata.setColumnDiameter(colDiam);
				}

				// spectrum_chromatography_col_particule_size: "1.9"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_particule_size")) {
					updateICchromatoData = Boolean.TRUE;
					final Double colPartiSize = getDoubleVal(spectrumDataToUpdate,
							"spectrum_chromatography_col_particule_size");
					icMetadata.setParticuleSize(colPartiSize);
				}
				// spectrum_chromatography_col_temperature: "40.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_col_temperature")) {
					updateICchromatoData = Boolean.TRUE;
					final Double colTemp = getDoubleVal(spectrumDataToUpdate,
							"spectrum_chromatography_col_temperature");
					icMetadata.setColumnTemperature(colTemp);
				}
				// spectrum_chromatography_mode_ic: "Isocratic"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_mode_ic")) {
					updateICchromatoData = Boolean.TRUE;
					icMetadata.setIcMode(IonChromatography.getStandardizedICMode(
							spectrumDataToUpdate.get("spectrum_chromatography_mode_ic").toString()));
				}
				// spectrum_chromatography_separation_flow_rate: "300.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_separation_flow_rate")) {
					updateICchromatoData = Boolean.TRUE;
					final Double sfgRate = getDoubleVal(spectrumDataToUpdate,
							"spectrum_chromatography_separation_flow_rate");
					icMetadata.setSeparationFlowRate(sfgRate);
				}
				// spectrum_chromatography_solventA: "H2O / CH3OH / CH3CO2H (95/5/0.1)"
				if (constainKey(spectrumDataToUpdate, "spectrum_chromatography_solvent")) {
					updateICchromatoData = Boolean.TRUE;
					icMetadata.setSeparationSolvent(IonChromatography.getStandardizedSolventName(
							spectrumDataToUpdate.get("spectrum_chromatography_solvent").toString()));
				}
				// spectrum_chromatography_sfg_time_ic
				final Map<Double, Double> newSFG = icMetadata.getSeparationFlowGradient();
				if (spectrumDataToUpdate.containsKey("spectrum_chromatography_sfg_time_ic")
						&& spectrumDataToUpdate.get("spectrum_chromatography_sfg_time_ic") != null) {
					if (spectrumDataToUpdate.get("spectrum_chromatography_sfg_time_ic") instanceof ArrayList<?>) {
						newSFG.clear();
						updateICchromatoData = Boolean.TRUE;
						ArrayList<Map<String, Object>> rawSFG = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_chromatography_sfg_time_ic");
						for (final Map<String, Object> rawCpdMixData : rawSFG) {
							if (rawCpdMixData.containsKey("time") && rawCpdMixData.get("time") != null
									&& rawCpdMixData.containsKey("s") && rawCpdMixData.get("s") != null) {
								final String timeS = rawCpdMixData.get("time").toString();
								final String cS = rawCpdMixData.get("s").toString();
								try {
									final double time = Double.parseDouble(timeS);
									final double c = Double.parseDouble(cS);
									newSFG.put(time, c);
								} catch (final NumberFormatException nfe) {
								}
							}
						}
					}
				}

				// II.C - save object (if needed)
				if (updateICchromatoData) {
					IonChromatographyMetadataDao.update(icMetadata.getId(), icMetadata, newSFG);
				}
			}

			// III - update MASS analyzer data.
			// III.A - init var
			boolean updateMSanalyzer = false;
			boolean updateMSionization = false;
			boolean updateMSranges = false;
			boolean updateMSMSdata = Boolean.FALSE;

			Double msRangeMassFrom = null;
			Double msRangeMassTo = null;
			Double msRangeRTminFrom = null;
			Double msRangeRTminTo = null;
			Double msRangeRTmeSFrom = null;
			Double msRangeRTmeSTo = null;

			Integer msResolutionFWHMresolution = null;
			Integer msResolutionFWHMmass = null;
			Integer msCurationLvl = null;

			Double msmsFragEnery = null;

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
				// GCMS - BRAND
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_instrument_brand")) {
					updateMSanalyzer = Boolean.TRUE;
					msAnalyzerMetatada.setInstrumentBrand(//
							spectrumDataToUpdate.get("spectrum_ms_analyzer_instrument_brand").toString());
				}

				// III.A.2 - ionization
				// spectrum_ms_ionization_ion_transfer_temperature: "300.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ion_transfer_temperature")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_ionization_ion_transfer_temperature").toString());
					} catch (NumberFormatException nfe) {
					}
					((AnalyzerLiquidMassIonization) msIonizationMetatada).setIonTransferTemperature(newVal);
				}
				// spectrum_ms_ionization_ionization_method: "ESI"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ionization_method")) {
					updateMSionization = true;
					if (msIonizationMetatada instanceof AnalyzerLiquidMassIonization)
						((AnalyzerLiquidMassIonization) msIonizationMetatada).setIonization(
								AnalyzerLiquidMassIonization.getStandardizedIonization(spectrumDataToUpdate
										.get("spectrum_ms_ionization_ionization_method").toString()));
					else
						((AnalyzerGasMassIonization) msIonizationMetatada).setIonizationMethod(
								AnalyzerGasMassIonization.getStandardizedGCIonization(spectrumDataToUpdate
										.get("spectrum_ms_ionization_ionization_method").toString()));
				}
				// spectrum_ms_ionization_ionization_voltage: "4.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ionization_voltage")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_ionization_ionization_voltage").toString());
					} catch (NumberFormatException nfe) {
					}
					((AnalyzerLiquidMassIonization) msIonizationMetatada).setIonizationVoltage(newVal);
				}
				// spectrum_ms_ionization_source_gaz_flow: "0.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_source_gaz_flow")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_ionization_source_gaz_flow").toString());
					} catch (NumberFormatException nfe) {
					}
					((AnalyzerLiquidMassIonization) msIonizationMetatada).setSourceGazFlow(newVal);
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
					((AnalyzerLiquidMassIonization) msIonizationMetatada).setSprayGazFlow(newVal);
				}
				// spectrum_ms_ionization_vaporizer_gaz_flow: "10.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_vaporizer_gaz_flow")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_ionization_vaporizer_gaz_flow").toString());
					} catch (NumberFormatException nfe) {
					}
					((AnalyzerLiquidMassIonization) msIonizationMetatada).setVaporizerGazFlow(newVal);
				}
				// spectrum_ms_ionization_vaporizer_tempertature: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_vaporizer_tempertature")) {
					updateMSionization = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_ms_ionization_vaporizer_tempertature").toString());
					} catch (NumberFormatException nfe) {
					}
					((AnalyzerLiquidMassIonization) msIonizationMetatada).setVaporizerTemperature(newVal);
				}
				// GCMS IONIZATION
				// spectrum_gcms_ionization_ionization_method: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_gcms_ionization_ionization_method")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setIonizationMethod(//
								AnalyzerGasMassIonization.getStandardizedGCIonization(//
										spectrumDataToUpdate.get("spectrum_gcms_ionization_ionization_method")
												.toString()));
					}
				}
				// spectrum_ms_ionization_emission_current: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_electron_energy")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setElectronEnergy(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_electron_energy"));
					}
				}
				// spectrum_ms_ionization_emission_current: ""
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_emission_current")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setEmissionCurrent(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_emission_current"));
					}
				}
				// spectrum_ms_ionization_source_temperature
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_source_temperature")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setSourceTemperature(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_source_temperature"));
					}
				}
				// spectrum_ms_ionization_ionization_gas
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ionization_gas")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setIonizationGas(//
								AnalyzerGasMassIonization.getStandardizedIonizationGas(//
										spectrumDataToUpdate.get("spectrum_ms_ionization_ionization_gas").toString()));
					}
				}
				// spectrum_ms_ionization_gas_flow
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_gas_flow")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setIonizationGasFlow(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_gas_flow"));
					}
				}
				// spectrum_ms_ionization_interface_temperature
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_interface_temperature")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setInterfaceTemperature(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_interface_temperature"));
					}
				}
				// spectrum_ms_ionization_repeller
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_repeller")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setRepeller(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_repeller"));
					}
				}
				// spectrum_ms_ionization_extractor
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_extractor")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setExtractor(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_extractor"));
					}
				}
				// spectrum_ms_ionization_ion_focus
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ionization_ion_focus")) {
					updateMSionization = Boolean.TRUE;
					if (msIonizationMetatada instanceof AnalyzerGasMassIonization) {
						((AnalyzerGasMassIonization) msIonizationMetatada).setIonFocus(//
								getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ionization_ion_focus"));
					}
				}
				// TODO GCMS gas

				// get original data
				msRangeMassFrom = ((MassSpectrum) spectrum).getRangeMassFrom();
				msRangeMassTo = ((MassSpectrum) spectrum).getRangeMassTo();
				msRangeRTminFrom = ((MassSpectrum) spectrum).getRangeRetentionTimeFrom();
				msRangeRTminTo = ((MassSpectrum) spectrum).getRangeRetentionTimeTo();
				msResolutionFWHMresolution = ((MassSpectrum) spectrum).getInstrumentResolutionFWHMresolution();
				msResolutionFWHMmass = ((MassSpectrum) spectrum).getInstrumentResolutionFWHMmass();
				// new 2.0
				msCurationLvl = ((MassSpectrum) spectrum).getCurationLevel();

				// get updated data

				// spectrum_ms_range_mass_from: "80.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_range_mass_from")) {
					updateMSranges = true;
					try {
						msRangeMassFrom = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_range_mass_from").toString());
					} catch (NumberFormatException e) {
					}
				}

				// spectrum_ms_range_mass_to: "800.0"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_range_mass_to")) {
					updateMSranges = true;
					try {
						msRangeMassTo = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_range_mass_to").toString());
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

				// spectrum_ms_analyzer_resolution_fwhm: "30000@"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_resolution_fwhm")) {
					updateMSanalyzer = true;
					final String[] tabData = spectrumDataToUpdate.get("spectrum_ms_analyzer_resolution_fwhm").toString()
							.split("@");
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

				// new 2.0
				// spectrum_ms_curation_lvl
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_curation_lvl")) {
					updateMSranges = true;
					msCurationLvl = MassSpectrum.getStandardizedCurationLevel(
							spectrumDataToUpdate.get("spectrum_ms_curation_lvl").toString());
				}
			}

			// if instance of FRAG spectra update specific fields
			if (spectrum instanceof FragmentationLCSpectrum) {
				// init
				msmsFragEnery = ((FragmentationLCSpectrum) spectrum).getFragEnery();

				// bug 348
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_frag_energy")) {
					updateMSMSdata = true;
					try {
						msmsFragEnery = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_analyzer_frag_energy").toString());
					} catch (final NumberFormatException e) {
					}
				}
			}
			// new 2.3
			if (spectrum instanceof FragmentationICSpectrum) {
				// init
				msmsFragEnery = ((FragmentationICSpectrum) spectrum).getFragEnery();
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_analyzer_frag_energy")) {
					updateMSMSdata = true;
					try {
						msmsFragEnery = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_analyzer_frag_energy").toString());
					} catch (final NumberFormatException e) {
					}
				}
			}

			if (spectrum instanceof ILCSpectrum) {
				// get original data
				msRangeRTmeSFrom = ((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentFrom();
				msRangeRTmeSTo = ((ILCSpectrum) spectrum).getRangeRetentionTimeEqMethanolPercentTo();
				// get updated data
				// spectrum_ms_rt_meoh_from: "40.16"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_meoh_from")) {
					updateMSranges = true;
					try {
						msRangeRTmeSFrom = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_meoh_from").toString());
					} catch (NumberFormatException e) {
					}
				}
				// spectrum_ms_rt_meoh_to: "40.83"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_meoh_to")) {
					updateMSranges = true;
					try {
						msRangeRTmeSTo = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_meoh_to").toString());
					} catch (NumberFormatException e) {
					}
				}
			}
			// bugfix 2.3.1 - #378
			else if (spectrum instanceof IGCSpectrum) {
				// get original data
				msRangeRTmeSFrom = ((IGCSpectrum) spectrum).getRangeRetentionIndexAlkaneFrom();
				msRangeRTmeSTo = ((IGCSpectrum) spectrum).getRangeRetentionIndexAlkaneTo();
				// get updated data
				// spectrum_ms_rt_alkane_from: "40.16"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ri_alkane_from")) {
					updateMSranges = Boolean.TRUE;
					msRangeRTmeSFrom = getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ri_alkane_from");
				}
				// spectrum_ms_rt_meoh_to: "40.83"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_ri_alkane_to")) {
					updateMSranges = Boolean.TRUE;
					msRangeRTmeSTo = getDoubleVal(spectrumDataToUpdate, "spectrum_ms_ri_alkane_to");
				}
			}
			// new 2.3
			else if (spectrum instanceof IICSpectrum) {
				// get original data
				msRangeRTmeSFrom = ((IICSpectrum) spectrum).getRangeRetentionTimeEqPotassiumHydroxidePercentFrom();
				msRangeRTmeSTo = ((IICSpectrum) spectrum).getRangeRetentionTimeEqPotassiumHydroxidePercentTo();
				// get updated data
				// spectrum_ms_rt_meoh_from: "40.16"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_koh_from")) {
					updateMSranges = true;
					try {
						msRangeRTmeSFrom = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_koh_from").toString());
					} catch (NumberFormatException e) {
					}
				}
				// spectrum_ms_rt_meoh_to: "40.83"
				if (constainKey(spectrumDataToUpdate, "spectrum_ms_rt_koh_to")) {
					updateMSranges = true;
					try {
						msRangeRTmeSTo = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_ms_rt_koh_to").toString());
					} catch (NumberFormatException e) {
					}
				}
			}

			// III.B - update object
			// II.C - save object (if needed)
			if (updateMSanalyzer) {
				AnalyzerMassSpectrometerDeviceMetadataDao.update(msAnalyzerMetatada.getId(), msAnalyzerMetatada);
			}
			if (updateMSionization) {
				AnalyzerMassIonizationMetadataDao.update(msIonizationMetatada.getId(), msIonizationMetatada);
			}
			if (updateMSranges) {
				if (spectrum instanceof FullScanLCSpectrum) {
					FullScanLCSpectrumDao.update(spectrum.getId(), msRangeMassFrom, msRangeMassTo, msRangeRTminFrom,
							msRangeRTminTo, msRangeRTmeSFrom, msRangeRTmeSTo, msResolutionFWHMresolution,
							msResolutionFWHMmass, msCurationLvl);
				} else if (spectrum instanceof FragmentationLCSpectrum) {
					FragmentationLCSpectrumDao.update(spectrum.getId(), msRangeMassFrom, msRangeMassTo,
							msRangeRTminFrom, msRangeRTminTo, msRangeRTmeSFrom, msRangeRTmeSTo,
							msResolutionFWHMresolution, msResolutionFWHMmass, msCurationLvl);
				} else if (spectrum instanceof FullScanGCSpectrum) {
					FullScanGCSpectrumDao.update(
							// final long id, //
							spectrum.getId(),
							// final Double rangeMassFrom, final Double rangeMassTo, //
							msRangeMassFrom, msRangeMassTo,
							// final Double rangeRTminFrom, final Double rangeRTminTo, //
							msRangeRTminFrom, msRangeRTminTo,
							// final Double rangeRIalkaneFrom, final Double rangeRIalkaneTo, //
							msRangeRTmeSFrom, msRangeRTmeSTo,
							// final Integer curationLvl
							msCurationLvl);
				}
				// new 2.3
				else if (spectrum instanceof FullScanICSpectrum) {
					FullScanICSpectrumDao.update(spectrum.getId(), msRangeMassFrom, msRangeMassTo, msRangeRTminFrom,
							msRangeRTminTo, msRangeRTmeSFrom, msRangeRTmeSTo, msResolutionFWHMresolution,
							msResolutionFWHMmass, msCurationLvl);
				} else if (spectrum instanceof FragmentationICSpectrum) {
					FragmentationICSpectrumDao.update(spectrum.getId(), msRangeMassFrom, msRangeMassTo,
							msRangeRTminFrom, msRangeRTminTo, msRangeRTmeSFrom, msRangeRTmeSTo,
							msResolutionFWHMresolution, msResolutionFWHMmass, msCurationLvl);
				}
			}
			// update other MSMS specific fields
			if (updateMSMSdata) {
				FragmentationLCSpectrumDao.updateMS2Data(spectrum.getId(), msmsFragEnery);
			}

			// IV - update NMR analyzer data
			if (spectrum instanceof NMR1DSpectrum) {
				// IV.A - init var
				boolean updateNMRspectrumData = false;
				boolean updateNMRanalyzerData = false;
				AnalyzerNMRSpectrometerDevice analyzerNMRdevice = ((NMR1DSpectrum) spectrum)
						.getAnalyzerNMRSpectrometerDevice();
				// IV.B - update object
				updateNMRanalyzerData = extractUpdatableAnalyzer(spectrumDataToUpdate, updateNMRanalyzerData,
						analyzerNMRdevice);

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
						newVal = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_pulse_angle").toString());
					} catch (NumberFormatException nfe) {
					}
					pulseAngle = newVal;
				}

				// spectrum_nmr_analyzer_number_of_points
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_number_of_points")) {
					updateNMRspectrumData = true;
					Integer newVal = null;
					try {
						newVal = Integer.parseInt(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_number_of_points").toString());
					} catch (NumberFormatException nfe) {
					}
					nbOfPoints = newVal;
				}

				// spectrum_nmr_analyzer_number_of_scans
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_number_of_scans")) {
					updateNMRspectrumData = true;
					Integer newVal = null;
					try {
						newVal = Integer
								.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_number_of_scans").toString());
					} catch (NumberFormatException nfe) {
					}
					nbOfScans = newVal;
				}

				// spectrum_nmr_analyzer_temperature
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_temperature")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_temperature").toString());
					} catch (NumberFormatException nfe) {
					}
					temperature = newVal;
				}

				// spectrum_nmr_analyzer_relaxationDelayD1
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_relaxationDelayD1")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_relaxationDelayD1").toString());
					} catch (NumberFormatException nfe) {
					}
					relaxationDelayD1 = newVal;
				}

				// spectrum_nmr_analyzer_sw
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_sw")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_sw").toString());
					} catch (NumberFormatException nfe) {
					}
					sw = newVal;
				}

				// spectrum_nmr_analyzer_mixingTime
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_mixingTime")) {
					updateNMRspectrumData = true;
					Double newVal = null;
					try {
						newVal = Double
								.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_mixingTime").toString());
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
						newVal = Integer
								.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_numberOfLoops").toString());
					} catch (NumberFormatException nfe) {
					}
					numberOfLoops = newVal;
				}

				// spectrum_nmr_analyzer_decouplingType
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_decouplingType")) {
					updateNMRspectrumData = true;
					decouplingType = spectrumDataToUpdate.get("spectrum_nmr_analyzer_decouplingType").toString();
				}

				// spectrum_nmr_analyzer_data_fourier_transform: undefined
				if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_fourier_transform")) {
					updateNMRspectrumData = true;
					Boolean newVal = null;
					try {
						newVal = Boolean.parseBoolean(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_fourier_transform").toString());
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
					NMR1DSpectrumDao.updateBasicAttributes(spectrum.getId(), pulseSeq, pulseAngle, nbOfPoints,
							nbOfScans, temperature, relaxationDelayD1, sw, mixingTime, spinEchoDelay, numberOfLoops,
							decouplingType, fourierTransform, si, lineBroadening);
				}
				if (updateNMRanalyzerData) {
					AnalyzerNMRSpectrometerDeviceMetadataDao.update(analyzerNMRdevice.getId(), analyzerNMRdevice);
				}
			} else if (spectrum instanceof NMR2DSpectrum) {

				if (((NMR2DSpectrum) spectrum).getAcquisition() == NMR2DSpectrum.ACQUISITION_2D_JRES) {

					// JRES

					// IV.A - init var
					boolean updateNMRspectrumData = false;
					boolean updateNMRanalyzerData = false;
					boolean updateNMRprocessingData = false;

					AnalyzerNMRSpectrometerDevice analyzerNMRdevice = ((NMR2DSpectrum) spectrum)
							.getAnalyzerNMRSpectrometerDevice();

					// IV.B - update object

					updateNMRanalyzerData = extractUpdatableAnalyzer(spectrumDataToUpdate, updateNMRanalyzerData,
							analyzerNMRdevice);

					String pulseSequence = ((NMR2DSpectrum) spectrum).getPulseSequence();
					// Double pulseAngle = ((NMR2DSpectrum) spectrum).getPulseAngle();
					Integer sizeOfFIDF1 = ((NMR2DSpectrum) spectrum).getSizeOfFIDF1();// sp
					Integer sizeOfFIDF2 = ((NMR2DSpectrum) spectrum).getSizeOfFIDF2();// sp
					Integer numberOfScansF2 = ((NMR2DSpectrum) spectrum).getNumberOfScansF2();// sp
					String acquisitionModeFor2DF1 = ((NMR2DSpectrum) spectrum).getAcquisitionModeFor2DF1();// sp
					// Double mixingTime = ((NMR2DSpectrum) spectrum).getMixingTime();
					Double temperature = ((NMR2DSpectrum) spectrum).getTemperature();
					Double relaxationDelayD1 = ((NMR2DSpectrum) spectrum).getRelaxationDelayD1();
					Double sw1d = ((NMR2DSpectrum) spectrum).getSwF1();// sp
					Double sw13c = ((NMR2DSpectrum) spectrum).getSwF2();// sp
					// Double jxh = ((NMR2DSpectrum) spectrum).getJxh();// sp
					// Boolean nus = ((NMR2DSpectrum) spectrum).getNus();// sp
					// Double nusAmount = ((NMR2DSpectrum) spectrum).getNusAmount();// sp
					// Integer nusPoints = ((NMR2DSpectrum) spectrum).getNusPoints();// sp

					// PROCESSING
					Boolean fourierTransform = ((NMR2DSpectrum) spectrum).getFourierTransform();
					Boolean tilt = ((NMR2DSpectrum) spectrum).getTilt();
					Integer siF1 = ((NMR2DSpectrum) spectrum).getSiF1();
					Integer siF2 = ((NMR2DSpectrum) spectrum).getSiF2();
					Short windowFunctionF1 = ((NMR2DSpectrum) spectrum).getWindowFunctionF1();
					Short windowFunctionF2 = ((NMR2DSpectrum) spectrum).getWindowFunctionF2();
					Double lbF1 = ((NMR2DSpectrum) spectrum).getLbF1();
					Double lbF2 = ((NMR2DSpectrum) spectrum).getLbF2();
					Double ssbF1 = ((NMR2DSpectrum) spectrum).getSsbF1();
					Double ssbF2 = ((NMR2DSpectrum) spectrum).getSsbF2();
					String gbF1 = ((NMR2DSpectrum) spectrum).getGbF1();
					String gbF2 = ((NMR2DSpectrum) spectrum).getGbF2();
					char peakPicking = ((NMR2DSpectrum) spectrum).getPeakPicking();
					Boolean symmetrize = ((NMR2DSpectrum) spectrum).getSymmetrize();
					// String nusProcessingParameter = ((NMR2DSpectrum)
					// spectrum).getNusProcessingParameter();

					// spectrum_nmr_analyzer_pulse_seq
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_pulse_seq")) {
						updateNMRspectrumData = true;
						pulseSequence = spectrumDataToUpdate.get("spectrum_nmr_analyzer_pulse_seq").toString();
					}

					// spectrum_nmr_analyzer_size_of_fid_f1
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_size_of_fid_f1")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer.parseInt(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_size_of_fid_f1").toString());
						} catch (NumberFormatException nfe) {
						}
						sizeOfFIDF1 = newVal;
					}

					// spectrum_nmr_analyzer_size_of_fid_f2
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_size_of_fid_f2")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer.parseInt(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_size_of_fid_f2").toString());
						} catch (NumberFormatException nfe) {
						}
						sizeOfFIDF2 = newVal;
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
						numberOfScansF2 = newVal;
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
							newVal = Double.parseDouble(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_relaxationDelayD1").toString());
						} catch (NumberFormatException nfe) {
						}
						relaxationDelayD1 = newVal;
					}

					// spectrum_nmr_analyzer_swF1
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_swF1")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_swF1").toString());
						} catch (NumberFormatException nfe) {
						}
						sw1d = newVal;
					}

					// spectrum_nmr_analyzer_swF2
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_swF2")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_swF2").toString());
						} catch (NumberFormatException nfe) {
						}
						sw13c = newVal;
					}

					// spectrum_nmr_analyzer_acquisition_mode_for_2d
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_acquisition_mode_for_2d")) {
						updateNMRspectrumData = true;
						acquisitionModeFor2DF1 = spectrumDataToUpdate
								.get("spectrum_nmr_analyzer_acquisition_mode_for_2d").toString();
					}

					/// ----- PROCESSING GATHERING

					// spectrum_nmr_analyzer_data_fourier_transform: undefined
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_fourier_transform")) {
						updateNMRprocessingData = true;
						Boolean newVal = null;
						try {
							newVal = Boolean.parseBoolean(spectrumDataToUpdate
									.get("spectrum_nmr_analyzer_data_fourier_transform").toString());
						} catch (Exception e) {
						}
						fourierTransform = newVal;
					}

					// spectrum_nmr_analyzer_tilt string
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_tilt")) {
						updateNMRspectrumData = true;
						tilt = getStandardizedTrueFalse(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_tilt").toString());
					}

					// spectrum_nmr_analyzer_data_siF1 int
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_siF1")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer
									.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_siF1").toString());
						} catch (NumberFormatException nfe) {
						}
						siF1 = newVal;
					}

					// spectrum_nmr_analyzer_data_siF2 int
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_siF2")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer
									.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_siF2").toString());
						} catch (NumberFormatException nfe) {
						}
						siF2 = newVal;
					}

					// spectrum_nmr_analyzer_data_windowFunctionF1 char
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_windowFunctionF1")) {
						updateNMRspectrumData = true;
						windowFunctionF1 = NMR2DSpectrum.getStandardizedWindowFunction(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_windowFunctionF1").toString());
					}

					// spectrum_nmr_analyzer_data_windowFunctionF2 char
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_windowFunctionF2")) {
						updateNMRspectrumData = true;
						windowFunctionF2 = NMR2DSpectrum.getStandardizedWindowFunction(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_windowFunctionF2").toString());
					}

					// spectrum_nmr_analyzer_lbF1 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_lbF1")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_lbF1").toString());
						} catch (NumberFormatException nfe) {
						}
						lbF1 = newVal;
					}

					// spectrum_nmr_analyzer_lbF2 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_lbF2")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_lbF2").toString());
						} catch (NumberFormatException nfe) {
						}
						lbF2 = newVal;
					}

					// spectrum_nmr_analyzer_ssbF1 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_ssbF1")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_ssbF1").toString());
						} catch (NumberFormatException nfe) {
						}
						ssbF1 = newVal;
					}

					// spectrum_nmr_analyzer_ssbF2 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_ssbF2")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_ssbF2").toString());
						} catch (NumberFormatException nfe) {
						}
						ssbF2 = newVal;
					}

					// spectrum_nmr_analyzer_gbF1
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_gbF1")) {
						updateNMRspectrumData = true;
						gbF1 = spectrumDataToUpdate.get("spectrum_nmr_analyzer_gbF1").toString();
					}

					// spectrum_nmr_analyzer_gbF2
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_gbF2")) {
						updateNMRspectrumData = true;
						gbF2 = spectrumDataToUpdate.get("spectrum_nmr_analyzer_gbF2").toString();
					}

					// spectrum_nmr_analyzer_data_peak_peaking manu/auto/none
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_peak_peaking")) {
						updateNMRspectrumData = true;
						peakPicking = NMR2DSpectrum.getStandardizedPeakPeaking(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_peak_peaking").toString());
					}

					// spectrum_nmr_analyzer_symmetrize string
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_symmetrize")) {
						updateNMRspectrumData = true;
						symmetrize = getStandardizedTrueFalse(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_symmetrize").toString());
					}

					// IV.C - save object (if needed)
					if (updateNMRspectrumData || updateNMRprocessingData) {
						NMR2DSpectrumDao.updateBasicAttributes(spectrum.getId(), pulseSequence, sizeOfFIDF1,
								sizeOfFIDF2, numberOfScansF2, acquisitionModeFor2DF1, temperature, relaxationDelayD1,
								sw1d, sw13c, fourierTransform, tilt, siF1, siF2, windowFunctionF1, windowFunctionF2,
								lbF1, lbF2, ssbF1, ssbF2, gbF1, gbF2, peakPicking, symmetrize);
					}
					if (updateNMRanalyzerData) {
						AnalyzerNMRSpectrometerDeviceMetadataDao.update(analyzerNMRdevice.getId(), analyzerNMRdevice);
					}

				} else {
					// ALL CLASSIC 2D

					// IV.A - init var
					boolean updateNMRspectrumData = false;
					boolean updateNMRanalyzerData = false;
					boolean updateNMRprocessingData = false;

					AnalyzerNMRSpectrometerDevice analyzerNMRdevice = ((NMR2DSpectrum) spectrum)
							.getAnalyzerNMRSpectrometerDevice();

					// IV.B - update object

					updateNMRanalyzerData = extractUpdatableAnalyzer(spectrumDataToUpdate, updateNMRanalyzerData,
							analyzerNMRdevice);

					String pulseSequence = ((NMR2DSpectrum) spectrum).getPulseSequence();
					Double pulseAngle = ((NMR2DSpectrum) spectrum).getPulseAngle();
					Integer sizeOfFIDF1 = ((NMR2DSpectrum) spectrum).getSizeOfFIDF1();// sp
					Integer sizeOfFIDF2 = ((NMR2DSpectrum) spectrum).getSizeOfFIDF2();// sp
					Integer numberOfScansF2 = ((NMR2DSpectrum) spectrum).getNumberOfScansF2();// sp
					String acquisitionModeFor2DF1 = ((NMR2DSpectrum) spectrum).getAcquisitionModeFor2DF1();// sp
					Double mixingTime = ((NMR2DSpectrum) spectrum).getMixingTime();
					Double temperature = ((NMR2DSpectrum) spectrum).getTemperature();
					Double relaxationDelayD1 = ((NMR2DSpectrum) spectrum).getRelaxationDelayD1();
					Double sw1d = ((NMR2DSpectrum) spectrum).getSwF1();// sp
					Double sw13c = ((NMR2DSpectrum) spectrum).getSwF2();// sp
					Double jxh = ((NMR2DSpectrum) spectrum).getJxh();// sp
					Boolean nus = ((NMR2DSpectrum) spectrum).getNus();// sp
					Double nusAmount = ((NMR2DSpectrum) spectrum).getNusAmount();// sp
					Integer nusPoints = ((NMR2DSpectrum) spectrum).getNusPoints();// sp

					// PROCESSING
					Boolean fourierTransform = ((NMR2DSpectrum) spectrum).getFourierTransform();
					Integer siF1 = ((NMR2DSpectrum) spectrum).getSiF1();
					Integer siF2 = ((NMR2DSpectrum) spectrum).getSiF2();
					Short windowFunctionF1 = ((NMR2DSpectrum) spectrum).getWindowFunctionF1();
					Short windowFunctionF2 = ((NMR2DSpectrum) spectrum).getWindowFunctionF2();
					Double lbF1 = ((NMR2DSpectrum) spectrum).getLbF1();
					Double lbF2 = ((NMR2DSpectrum) spectrum).getLbF2();
					Double ssbF1 = ((NMR2DSpectrum) spectrum).getSsbF1();
					Double ssbF2 = ((NMR2DSpectrum) spectrum).getSsbF2();
					String gbF1 = ((NMR2DSpectrum) spectrum).getGbF1();
					String gbF2 = ((NMR2DSpectrum) spectrum).getGbF2();
					char peakPicking = ((NMR2DSpectrum) spectrum).getPeakPicking();
					String nusProcessingParameter = ((NMR2DSpectrum) spectrum).getNusProcessingParameter();

					// spectrum_nmr_analyzer_pulse_seq
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_pulse_seq")) {
						updateNMRspectrumData = true;
						pulseSequence = spectrumDataToUpdate.get("spectrum_nmr_analyzer_pulse_seq").toString();
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

					// spectrum_nmr_analyzer_size_of_fid_f1
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_size_of_fid_f1")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer.parseInt(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_size_of_fid_f1").toString());
						} catch (NumberFormatException nfe) {
						}
						sizeOfFIDF1 = newVal;
					}

					// spectrum_nmr_analyzer_size_of_fid_f2
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_size_of_fid_f2")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer.parseInt(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_size_of_fid_f2").toString());
						} catch (NumberFormatException nfe) {
						}
						sizeOfFIDF2 = newVal;
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
						numberOfScansF2 = newVal;
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
							newVal = Double.parseDouble(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_relaxationDelayD1").toString());
						} catch (NumberFormatException nfe) {
						}
						relaxationDelayD1 = newVal;
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

					// spectrum_nmr_analyzer_swF1
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_swF1")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_swF1").toString());
						} catch (NumberFormatException nfe) {
						}
						sw1d = newVal;
					}

					// spectrum_nmr_analyzer_swF2
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_swF2")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_swF2").toString());
						} catch (NumberFormatException nfe) {
						}
						sw13c = newVal;
					}

					// spectrum_nmr_analyzer_jxh
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_jxh")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_jxh").toString());
						} catch (NumberFormatException nfe) {
						}
						jxh = newVal;
					}

					// spectrum_nmr_analyzer_acquisition_mode_for_2d
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_acquisition_mode_for_2d")) {
						updateNMRspectrumData = true;
						acquisitionModeFor2DF1 = spectrumDataToUpdate
								.get("spectrum_nmr_analyzer_acquisition_mode_for_2d").toString();
					}

					// spectrum_nmr_analyzer_jxh
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_jxh")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_jxh").toString());
						} catch (NumberFormatException nfe) {
						}
						jxh = newVal;
					}

					// spectrum_nmr_analyzer_nus: undefined
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_nus")) {
						updateNMRspectrumData = true;
						Boolean newVal = null;
						try {
							newVal = Boolean
									.parseBoolean(spectrumDataToUpdate.get("spectrum_nmr_analyzer_nus").toString());
						} catch (Exception e) {
						}
						nus = newVal;
					}

					// spectrum_nmr_analyzer_nus_amount
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_nus_amount")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double.parseDouble(
									spectrumDataToUpdate.get("spectrum_nmr_analyzer_nus_amount").toString());
						} catch (NumberFormatException nfe) {
						}
						nusAmount = newVal;
					}

					// spectrum_nmr_analyzer_nus_points
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_nus_points")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer
									.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_nus_points").toString());
						} catch (NumberFormatException nfe) {
						}
						nusPoints = newVal;
					}

					/// ----- PROCESSING GATHERING

					// spectrum_nmr_analyzer_data_fourier_transform: undefined
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_fourier_transform")) {
						updateNMRprocessingData = true;
						Boolean newVal = null;
						try {
							newVal = Boolean.parseBoolean(spectrumDataToUpdate
									.get("spectrum_nmr_analyzer_data_fourier_transform").toString());
						} catch (Exception e) {
						}
						fourierTransform = newVal;
					}

					// spectrum_nmr_analyzer_data_siF1 int
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_siF1")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer
									.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_siF1").toString());
						} catch (NumberFormatException nfe) {
						}
						siF1 = newVal;
					}

					// spectrum_nmr_analyzer_data_siF2 int
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_siF2")) {
						updateNMRspectrumData = true;
						Integer newVal = null;
						try {
							newVal = Integer
									.parseInt(spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_siF2").toString());
						} catch (NumberFormatException nfe) {
						}
						siF2 = newVal;
					}

					// spectrum_nmr_analyzer_data_windowFunctionF1 char
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_windowFunctionF1")) {
						updateNMRspectrumData = true;
						windowFunctionF1 = NMR2DSpectrum.getStandardizedWindowFunction(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_windowFunctionF1").toString());
					}

					// spectrum_nmr_analyzer_data_windowFunctionF2 char
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_windowFunctionF2")) {
						updateNMRspectrumData = true;
						windowFunctionF2 = NMR2DSpectrum.getStandardizedWindowFunction(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_windowFunctionF2").toString());
					}

					// spectrum_nmr_analyzer_lbF1 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_lbF1")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_lbF1").toString());
						} catch (NumberFormatException nfe) {
						}
						lbF1 = newVal;
					}

					// spectrum_nmr_analyzer_lbF2 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_lbF2")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_lbF2").toString());
						} catch (NumberFormatException nfe) {
						}
						lbF2 = newVal;
					}

					// spectrum_nmr_analyzer_ssbF1 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_ssbF1")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_ssbF1").toString());
						} catch (NumberFormatException nfe) {
						}
						ssbF1 = newVal;
					}

					// spectrum_nmr_analyzer_ssbF2 double
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_ssbF2")) {
						updateNMRspectrumData = true;
						Double newVal = null;
						try {
							newVal = Double
									.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_ssbF2").toString());
						} catch (NumberFormatException nfe) {
						}
						ssbF2 = newVal;
					}

					// spectrum_nmr_analyzer_gbF1
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_gbF1")) {
						updateNMRspectrumData = true;
						gbF1 = spectrumDataToUpdate.get("spectrum_nmr_analyzer_gbF1").toString();
					}

					// spectrum_nmr_analyzer_gbF2
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_gbF2")) {
						updateNMRspectrumData = true;
						gbF2 = spectrumDataToUpdate.get("spectrum_nmr_analyzer_gbF2").toString();
					}

					// spectrum_nmr_analyzer_data_peak_peaking manu/auto/none
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_data_peak_peaking")) {
						updateNMRspectrumData = true;
						peakPicking = NMR2DSpectrum.getStandardizedPeakPeaking(
								spectrumDataToUpdate.get("spectrum_nmr_analyzer_data_peak_peaking").toString());
					}

					// spectrum_nmr_analyzer_nusProcessingParameter string
					if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_nusProcessingParameter")) {
						updateNMRspectrumData = true;
						nusProcessingParameter = spectrumDataToUpdate
								.get("spectrum_nmr_analyzer_nusProcessingParameter").toString();
					}

					// IV.C - save object (if needed)
					if (updateNMRspectrumData || updateNMRprocessingData) {
						NMR2DSpectrumDao.updateBasicAttributes(spectrum.getId(), pulseSequence, pulseAngle, sizeOfFIDF1,
								sizeOfFIDF2, numberOfScansF2, acquisitionModeFor2DF1, temperature, relaxationDelayD1,
								sw1d, sw13c, mixingTime, jxh, nus, nusAmount, nusPoints, fourierTransform, siF1, siF2,
								windowFunctionF1, windowFunctionF2, lbF1, lbF2, ssbF1, ssbF2, gbF1, gbF2, peakPicking,
								nusProcessingParameter);
					}
					if (updateNMRanalyzerData) {
						AnalyzerNMRSpectrometerDeviceMetadataDao.update(analyzerNMRdevice.getId(), analyzerNMRdevice);
					}
					// if (updateNMRprocessingData) {
					// NMR2DSpectrumManagementService.updateProcessingAttributes(spectrum.getId(),
					// //
					// fourierTransform, siF1, siF2, windowFunctionF1, windowFunctionF2, lbF1, lbF2,
					// ssbF1, ssbF2, gbF1, gbF2, peakPicking, nusProcessingParameter,
					// //
					// null, null, null);
					// }

				} // all 2D NMR
			} // 2D NMR spectra

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
						final ArrayList<Map<String, Object>> rawPeakList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
								.get("spectrum_ms_peaks");
						for (final Map<String, Object> rawPeak : rawPeakList) {
							if (rawPeak.containsKey("mz") && rawPeak.get("mz") != null && rawPeak.containsKey("ri")
									&& rawPeak.get("ri") != null) {
								// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
								// composition=C10H17N2O3, attribution=[M-H]-}
								Double mz = null;
								Double ri = null;
								Double theoricalMass = null;
								Double deltaMass = null;
								try {
									mz = Double.parseDouble(rawPeak.get("mz").toString());
									ri = Double.parseDouble(rawPeak.get("ri").toString());
									theoricalMass = Double.parseDouble(rawPeak.get("theoricalMass").toString());
									deltaMass = Double.parseDouble(rawPeak.get("deltaMass").toString());
								} catch (final NumberFormatException nfe) {
								}
								final String composition = rawPeak.containsKey("composition")
										? rawPeak.get("composition").toString()
										: null;
								final String attribution = rawPeak.containsKey("attribution")
										? rawPeak.get("attribution").toString()
										: null;
								final MassPeak mp = new MassPeak((MassSpectrum) spectrum, mz, ri, theoricalMass,
										deltaMass);
								mp.setComposition(composition);
								mp.setAttribution(attribution);
								if (ri != 0.0 && mz != 0.0) {
									newPeakList.add(mp);
								}
							}
						}
					}
				}

				// V.C - save object (if needed)
				// set newPeakList for spectrum
				if (updatePeakList) {
					if (spectrum instanceof FullScanLCSpectrum) {
						FullScanLCSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
					} else if (spectrum instanceof FragmentationLCSpectrum) {
						FragmentationLCSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
					}
					// #378
					else if (spectrum instanceof FullScanGCSpectrum) {
						FullScanGCSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
					}
					// #379
					else if (spectrum instanceof FullScanICSpectrum) {
						FullScanICSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
					} else if (spectrum instanceof FragmentationICSpectrum) {
						FragmentationICSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
					}
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
									chemicalShift = Double.parseDouble(rawPeak.get("chemicalShift").toString());
									relativeIntensity = Double.parseDouble(rawPeak.get("relativeIntensity").toString());
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
					NMR1DSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
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
							if (rawPeak.containsKey("chemicalShift") && rawPeak.get("chemicalShift") != null) {
								// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
								// composition=C10H17N2O3, attribution=[M-H]-}
								Double chemicalShift = null;
								Integer hORc = null;

								// Double relativeIntensity = null;
								Double rangeFrom = null;
								Double rangeTo = null;
								try {
									chemicalShift = Double.parseDouble(rawPeak.get("chemicalShift").toString());
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
					NMR1DSpectrumManagementService.updatePeakPatternList(spectrum.getId(), newPeakPatternList);
				}

			} else if (spectrum instanceof NMR2DSpectrum) {

				if (((NMR2DSpectrum) spectrum).getAcquisition() == NMR2DSpectrum.ACQUISITION_2D_JRES) {

					// JRES
					// VI.A - init var
					boolean updatePeakList = false;
					List<NMR2DJRESPeak> newPeakList = new ArrayList<NMR2DJRESPeak>();

					// annotation: "2"
					// chemicalShift: 3.6163
					// halfWidth: 0.001527993310974196
					// halfWidthHz: 0
					// index: 1
					// relativeIntensity: 33.27

					// VI.B - update object
					if (spectrumDataToUpdate.containsKey("spectrum_nmr_jres_peaks")
							&& spectrumDataToUpdate.get("spectrum_nmr_jres_peaks") != null) {
						if (spectrumDataToUpdate.get("spectrum_nmr_jres_peaks") instanceof ArrayList<?>) {
							// newPeakList = new HashMap<>();
							updatePeakList = true;
							ArrayList<Map<String, Object>> rawPeakList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
									.get("spectrum_nmr_jres_peaks");
							for (Map<String, Object> rawPeak : rawPeakList) {
								if (rawPeak.containsKey("chemicalShiftF1") && rawPeak.get("chemicalShiftF1") != null
										&& rawPeak.containsKey("chemicalShiftF2")
										&& rawPeak.get("chemicalShiftF2") != null) {
									// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
									// composition=C10H17N2O3, attribution=[M-H]-}
									Double chemicalShiftF1 = null;
									Double chemicalShiftF2 = null;
									Double intensity = null;
									try {
										chemicalShiftF1 = Double.parseDouble(rawPeak.get("chemicalShiftF1").toString());
										chemicalShiftF2 = Double.parseDouble(rawPeak.get("chemicalShiftF2").toString());
									} catch (NumberFormatException nfe) {
									}
									if (rawPeak.get("intensity") != null)
										try {
											intensity = Double.parseDouble(rawPeak.get("intensity").toString());
										} catch (NumberFormatException nfe) {
										}

									String multiplicity = rawPeak.get("multiplicity").toString();
									String j = rawPeak.get("j").toString();
									String annotation = rawPeak.get("annotation").toString();

									NMR2DJRESPeak nmrP = new NMR2DJRESPeak((NMR2DSpectrum) spectrum);
									nmrP.setChemicalShiftF1(chemicalShiftF1);
									nmrP.setChemicalShiftF2(chemicalShiftF2);
									nmrP.setIntensity(intensity);
									try {
										nmrP.addCouplageConstant(Double.parseDouble(j));
									} catch (NumberFormatException e) {
										nmrP.gatherCouplingConstants(j);
									}
									nmrP.setMultiplicity(PeakPattern.getStandardizedPatternType(multiplicity));
									nmrP.setAnnotation(annotation);
									// if (relativeIntensity != 0.0 && chemicalShift != 0.0)
									newPeakList.add(nmrP);
								}
							}
						}
					}

					// VI.C - save object (if needed)
					// set newPeakList for spectrum
					if (updatePeakList) {
						NMR2DSpectrumManagementService.updatePeakListJRES(spectrum.getId(), newPeakList);
					}

				} else {
					// ALL CLASSIC 2D
					// VI.A - init var
					boolean updatePeakList = false;
					List<NMR2DPeak> newPeakList = new ArrayList<NMR2DPeak>();

					// annotation: "2"
					// chemicalShift: 3.6163
					// halfWidth: 0.001527993310974196
					// halfWidthHz: 0
					// index: 1
					// relativeIntensity: 33.27

					// VI.B - update object
					if (spectrumDataToUpdate.containsKey("spectrum_nmr_2dpeaks")
							&& spectrumDataToUpdate.get("spectrum_nmr_2dpeaks") != null) {
						if (spectrumDataToUpdate.get("spectrum_nmr_2dpeaks") instanceof ArrayList<?>) {
							// newPeakList = new HashMap<>();
							updatePeakList = true;
							ArrayList<Map<String, Object>> rawPeakList = (ArrayList<Map<String, Object>>) spectrumDataToUpdate
									.get("spectrum_nmr_2dpeaks");
							for (Map<String, Object> rawPeak : rawPeakList) {
								if (rawPeak.containsKey("chemicalShiftF1") && rawPeak.get("chemicalShiftF1") != null
										&& rawPeak.containsKey("chemicalShiftF2")
										&& rawPeak.get("chemicalShiftF2") != null) {
									// {mz=213.1241, ri=100, theoricalMass=213.1245, deltaMass=0.161,
									// composition=C10H17N2O3, attribution=[M-H]-}
									Double chemicalShiftF1 = null;
									Double chemicalShiftF2 = null;
									Double intensity = null;
									try {
										chemicalShiftF1 = Double.parseDouble(rawPeak.get("chemicalShiftF1").toString());
										chemicalShiftF2 = Double.parseDouble(rawPeak.get("chemicalShiftF2").toString());
									} catch (NumberFormatException nfe) {
									}
									if (rawPeak.get("intensity") != null)
										try {
											intensity = Double.parseDouble(rawPeak.get("intensity").toString());
										} catch (NumberFormatException nfe) {
										}
									String annotation = rawPeak.get("annotation").toString();

									NMR2DPeak nmrP = new NMR2DPeak((NMR2DSpectrum) spectrum);
									nmrP.setChemicalShiftF1(chemicalShiftF1);
									nmrP.setChemicalShiftF2(chemicalShiftF2);
									nmrP.setIntensity(intensity);
									nmrP.setAnnotation(annotation);
									// if (relativeIntensity != 0.0 && chemicalShift != 0.0)
									newPeakList.add(nmrP);
								}
							}
						}
					}

					// VI.C - save object (if needed)
					// set newPeakList for spectrum
					if (updatePeakList) {
						NMR2DSpectrumManagementService.updatePeakList(spectrum.getId(), newPeakList);
					}

				} // else all kind of 2D
			} // if 2D NMR spectra

			// VIII - update OTHER data

			// VIII.A - init var
			boolean updateOtherMetadata = false;
			OtherMetadata otherMetadata = OtherMetadataDao.read((spectrum).getOtherMetadata().getId());

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
				otherMetadata.setAuthors(spectrumDataToUpdate.get("spectrum_othermetadata_authors").toString());
			}

			// spectrum_othermetadata_ownership: "AXIOM/ MetaToul"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_ownership")) {
				updateOtherMetadata = true;
				otherMetadata.setOwnership(spectrumDataToUpdate.get("spectrum_othermetadata_ownership").toString());
			}

			// spectrum_othermetadata_raw_file_name: "w"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_raw_file_name")) {
				updateOtherMetadata = true;
				otherMetadata
						.setRawFileName(spectrumDataToUpdate.get("spectrum_othermetadata_raw_file_name").toString());
			}

			// spectrum_othermetadata_raw_file_size: "10"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_raw_file_size")) {
				updateOtherMetadata = true;
				Double newFileSize = null;
				try {
					newFileSize = Double
							.parseDouble(spectrumDataToUpdate.get("spectrum_othermetadata_raw_file_size").toString());
				} catch (NumberFormatException e) {
				}
				otherMetadata.setRawFileSize(newFileSize);
			}

			// spectrum_othermetadata_validator: "E. Jamin"
			if (constainKey(spectrumDataToUpdate, "spectrum_othermetadata_validator")) {
				updateOtherMetadata = true;
				otherMetadata.setValidator(spectrumDataToUpdate.get("spectrum_othermetadata_validator").toString());
			}

			// VIII.C - save object (if needed)
			if (updateOtherMetadata) {
				OtherMetadataDao.update(otherMetadata.getId(), otherMetadata);
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
			CurationMessageManagementService.delete(listOfCurationMessageToDeleletIds);
			CurationMessageDao.update(listOfCurationMessageToAcceptIds, CurationMessage.STATUS_ACCEPTED);
			CurationMessageDao.update(listOfCurationMessageToRejectIds, CurationMessage.STATUS_REJECTED);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		// log
		spectrumLog("edit spectrum @id=" + id + ";");

		return true;
	}

	private boolean extractUpdatableAnalyzer(Map<String, Object> spectrumDataToUpdate, boolean updateNMRanalyzerData,
			AnalyzerNMRSpectrometerDevice analyzerNMRdevice) {
		// spectrum_nmr_analyzer_name
		if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_name")) {
			updateNMRanalyzerData = true;
			analyzerNMRdevice.setInstrumentName(AnalyzerNMRSpectrometerDevice.getStandardizedNMRinstrumentName(
					spectrumDataToUpdate.get("spectrum_nmr_analyzer_name").toString()));
		}

		// spectrum_nmr_analyzer_magneticFieldStrength
		if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_magneticFieldStrength")) {
			updateNMRanalyzerData = true;
			analyzerNMRdevice
					.setMagneticFieldStrenght(AnalyzerNMRSpectrometerDevice.getStandardizedNMRmagneticFieldStength(
							spectrumDataToUpdate.get("spectrum_nmr_analyzer_magneticFieldStrength").toString(), null));
		}

		// spectrum_nmr_analyzer_software
		if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_software")) {
			updateNMRanalyzerData = true;
			analyzerNMRdevice.setSoftware(AnalyzerNMRSpectrometerDevice.getStandardizedNMRsoftwareVersion(
					spectrumDataToUpdate.get("spectrum_nmr_analyzer_software").toString()));
		}

		// spectrum_nmr_analyzer_probe
		if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_probe")) {
			updateNMRanalyzerData = true;
			analyzerNMRdevice.setProbe(AnalyzerNMRSpectrometerDevice
					.getStandardizedNMRprobe(spectrumDataToUpdate.get("spectrum_nmr_analyzer_probe").toString()));
		}

		// spectrum_nmr_analyzer_tube
		if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_tube")) {
			updateNMRanalyzerData = true;
			analyzerNMRdevice.setNMRtubeDiameter(AnalyzerNMRSpectrometerDevice.getStandardizedNMRtubeDiameter(
					spectrumDataToUpdate.get("spectrum_nmr_analyzer_tube").toString(), null));
		}

		// spectrum_nmr_analyzer_flow_cell_vol
		if (constainKey(spectrumDataToUpdate, "spectrum_nmr_analyzer_flow_cell_vol")) {
			updateNMRanalyzerData = true;
			Double newCellVol = null;
			try {
				newCellVol = Double
						.parseDouble(spectrumDataToUpdate.get("spectrum_nmr_analyzer_flow_cell_vol").toString());
			} catch (NumberFormatException nfe) {
			}
			analyzerNMRdevice.setFlowCellVolume(newCellVol);
		}
		return updateNMRanalyzerData;
	}

	private boolean constainKey(Map<String, Object> spectrumDataToUpdate, String string) {
		return spectrumDataToUpdate.containsKey(string) && spectrumDataToUpdate.get(string) != null;
	}

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

	// /**
	// * @param data
	// * @return
	// */
	// @RequestMapping(value = "/nmr-viewer-converter", headers = {
	// "Content-type=application/json" }, method = RequestMethod.POST, produces =
	// MediaType.APPLICATION_JSON_VALUE)
	// public @ResponseBody Object getNMRspectrumJsonData(@RequestBody Map<String,
	// Object> data) {
	//
	// // {"type":"single","id":"test","sample":1,"pdata":1}
	// String rawFolder = Utils.getBundleConfElement("rawFile.nmr.folder");
	// if (!rawFolder.endsWith(File.separator))
	// rawFolder += File.separator;
	// String id = rawFolder + (String) data.get("id");
	// int sample = (int) data.get("sample");
	// String type = (String) data.get("type");
	// int pdata = (int) data.get("pdata");
	//
	// return ViewerProcessing.getJsonData(id, sample, type, pdata);
	// }

	@RequestMapping(value = "/show-raw-file-processing/{keyRawFile}")
	public @ResponseBody String getRawFileProcessing(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable("keyRawFile") String keyRawFile) {

		String rawFileName = PeakForestUtils.getBundleConfElement("rawFile.nmr.folder") + keyRawFile + File.separator
				+ "_pdata_param.txt";
		File logFile = new File(rawFileName);
		try {
			return SimpleFileReader.readFile(logFile.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (IOException e) {
			return "unable to display raw file content \n" + e.getMessage();
		}
	}

	@RequestMapping(value = "/js_sandbox/{id}", method = RequestMethod.GET)
	public String showJSMolInCompoundSheet(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, @PathVariable("id") long id) throws PeakForestManagerException {

		// init request

		// load spectra data
		// List<Long> spectrumIDs = new ArrayList<Long>();
		// spectrumIDs.add(Long.parseLong(id));
		// spectrumIDs.add(id);
		Spectrum spectrum = null;
		try {
			spectrum = SpectrumManagementService.read(id);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// init var
		List<Compound> listCC = new ArrayList<Compound>();
		if (spectrum instanceof CompoundSpectrum) {
			for (Compound c : ((CompoundSpectrum) spectrum).getListOfCompounds()) {
				if (c instanceof StructureChemicalCompound)
					try {
						listCC.add(StructuralCompoundManagementService
								.readByInChIKey(((StructureChemicalCompound) c).getInChIKey()));
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
				loadSpectraMetadata(model, spectrum, request);
				model.addAttribute("contains_spectrum", true);
			} catch (Exception e) {
				e.printStackTrace();
			}

		} else
			model.addAttribute("contains_spectrum", false);

		// RETURN
		return "module/jsmol_sandbox";
	}

	public static Boolean getStandardizedTrueFalse(String booleanTF) {
		if (booleanTF != null)
			switch (booleanTF.trim().toLowerCase()) {
			case "yes":
			case "y":
			case "true":
			case "t":
				return true;
			case "false":
			case "f":
			case "no":
			case "n":
				return false;
			default:
				return null;
			}
		else
			return null;
	}

	private void spectrumLog(String logMessage) {
		String username = "?";
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			User user = null;
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
			username = user.getLogin();
		}
		SpectralDatabaseLogger.log(username, logMessage, SpectralDatabaseLogger.LOG_INFO);
	}

	private Double getDoubleVal(//
			final Map<String, Object> map, //
			final String key) {
		Double newVal = null;
		try {
			newVal = Double.parseDouble(map.get(key).toString());
		} catch (final NumberFormatException nfe) {
		}
		return newVal;
	}

}

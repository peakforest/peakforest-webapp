package fr.metabohub.peakforest.controllers;

import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import fr.metabohub.externaltools.nmr.ImageGenerator;
import fr.metabohub.externaltools.proxy.NMRpro;
import fr.metabohub.peakforest.dao.compound.GCDerivedCompoundDao;
import fr.metabohub.peakforest.dao.compound.IReferenceCompoundDao;
import fr.metabohub.peakforest.dao.metadata.LiquidChromatographyMetadataDao;
import fr.metabohub.peakforest.model.AbstractDatasetObject;
import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.GCDerivedCompound;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.model.spectrum.FragmentationLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.MassSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMR1DSpectrum;
import fr.metabohub.peakforest.services.SearchService;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenerateSdfFileService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.peakmatching.LCMSMSPeakMatchingService;
import fr.metabohub.peakforest.services.peakmatching.LCMSPeakMatchingService;
import fr.metabohub.peakforest.services.peakmatching.NMR1DPeakMatchingService;
import fr.metabohub.peakforest.services.threads.CompoundsImagesAndMolFilesGeneratorThread;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.PeakForestPruneUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.peakforest.utils.SimpleFileReader;
import fr.metabohub.peakmatching.nmr.mapper.NMRCandidate;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class ToolsController {

	// maximum number of results returned by a quick search
	private static final int SEARCH_QUICK_RESULTS_SIZE_LIMIT = 10;

	// maximum number of results returned by a normal search
	private static final int SEARCH_NORMAL_RESULTS_SIZE_LIMIT = 50;

	@RequestMapping(value = "/404", method = RequestMethod.GET)
	public ModelAndView redirectFrom404(HttpServletResponse httpServletResponse, HttpServletRequest request) {
		// httpServletResponse.setHeader("Location", "home?page=template");
		if (!request.getHeader("Referer").endsWith("try=1")) {
			if (request.getHeader("Referer").contains("?"))
				return new ModelAndView("redirect:" + request.getHeader("Referer") + "&try=1");
			else
				return new ModelAndView("redirect:" + request.getHeader("Referer") + "?try=1");
		}
		return new ModelAndView("redirect:" + "home?page=404");
	}

	@RequestMapping(value = "/500", method = RequestMethod.GET)
	public ModelAndView redirectFrom500(HttpServletResponse httpServletResponse) {
		// httpServletResponse.setHeader("Location", "home?page=template");
		return new ModelAndView("redirect:" + "home?page=500");
	}

	@RequestMapping(value = "/ME", method = RequestMethod.GET)
	public ModelAndView redirectFromME(HttpServletResponse httpServletResponse) {
		// httpServletResponse.setHeader("Location", "home?page=template");
		return new ModelAndView("redirect:" + "home?page=stats#stats-metexplore");
	}

	/**
	 * Get the "pforest-webapp.war" query and avoid to return the resource itself
	 * 
	 * @param httpServletResponse the response to the client
	 * @return the 500 error view
	 */
	@RequestMapping(value = "/.war", method = RequestMethod.GET)
	public ModelAndView redirectWar(final HttpServletResponse httpServletResponse) {
		return new ModelAndView("redirect:" + "home?page=500");
	}

	/**
	 * Run a search query
	 * 
	 * @param query the query to process
	 * @return a json response
	 */
	@RequestMapping(//
			value = "/search", //
			method = RequestMethod.POST, //
			produces = MediaType.APPLICATION_JSON_VALUE, //
			params = "query")
	public @ResponseBody Object search(//
			final @RequestParam("query") String query//
	) {
		return searchOpt(query, Boolean.FALSE);
	}

	@SuppressWarnings("unchecked")
	@RequestMapping(//
			value = "/search", //
			method = RequestMethod.POST, //
			produces = MediaType.APPLICATION_JSON_VALUE, //
			params = { "query", "quick" }//
	)
	public @ResponseBody Object searchOpt(//
			final @RequestParam("query") String query, //
			final @RequestParam("quick") boolean quick) {
		// init
		final Map<String, Object> searchResults = new HashMap<String, Object>();
		final int maxResults = (quick ? SEARCH_QUICK_RESULTS_SIZE_LIMIT : SEARCH_NORMAL_RESULTS_SIZE_LIMIT);
		// search local
		try {
			searchResults.putAll(SearchService.search(query, quick, maxResults));
			// prune
			searchResults.put("compounds",
					PeakForestPruneUtils.prune((List<AbstractDatasetObject>) searchResults.get("compounds")));
			searchResults.put("compoundNames",
					PeakForestPruneUtils.prune((List<AbstractDatasetObject>) searchResults.get("compoundNames")));
			if (searchResults.containsKey("lcmsSpectra")) {
				List<AbstractDatasetObject> dataJson = PeakForestPruneUtils
						.prune((List<AbstractDatasetObject>) searchResults.get("lcmsSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("lcmsSpectra", dataJson);
			}
			if (searchResults.containsKey("lcmsmsSpectra")) {
				List<AbstractDatasetObject> dataJson = PeakForestPruneUtils
						.prune((List<AbstractDatasetObject>) searchResults.get("lcmsmsSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("lcmsmsSpectra", dataJson);
			}
			if (searchResults.containsKey("nmrSpectra")) {
				List<AbstractDatasetObject> dataJson = PeakForestPruneUtils
						.prune((List<AbstractDatasetObject>) searchResults.get("nmrSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("nmrSpectra", dataJson);
			}
			if (searchResults.containsKey("gcmsSpectra")) {
				List<AbstractDatasetObject> dataJson = PeakForestPruneUtils
						.prune((List<AbstractDatasetObject>) searchResults.get("gcmsSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("gcmsSpectra", dataJson);
			}
			// new 2.3
			if (searchResults.containsKey("icmsSpectra")) {
				List<AbstractDatasetObject> dataJson = PeakForestPruneUtils
						.prune((List<AbstractDatasetObject>) searchResults.get("icmsSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("icmsSpectra", dataJson);
			}
			if (searchResults.containsKey("icmsmsSpectra")) {
				List<AbstractDatasetObject> dataJson = PeakForestPruneUtils
						.prune((List<AbstractDatasetObject>) searchResults.get("icmsmsSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("icmsmsSpectra", dataJson);
			}
			// success
			searchResults.put("success", Boolean.TRUE);
		} catch (final Exception e) {
			e.printStackTrace();
			searchResults.put("success", Boolean.FALSE);
			searchResults.put("error", "exception");
			searchResults.put("exceptionMessage", e.getMessage());
		}
		// return data
		return searchResults;
	}

	@RequestMapping(//
			value = "/search-count", //
			method = RequestMethod.POST, //
			produces = MediaType.APPLICATION_JSON_VALUE, //
			params = { "query" }//
	)
	public @ResponseBody Long searchCount(@RequestParam("query") String query) {
		// init
		Long nbResults = null;
		// search
		try {
			nbResults = SearchService.countMaxSearchResults(query);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		// return
		return nbResults;
	}

	@RequestMapping(//
			value = "/search", //
			method = RequestMethod.POST, //
			produces = MediaType.APPLICATION_JSON_VALUE, //
			params = { "query", "filterEntity", "filerType", "filterVal", "filterVal2" }//
	)
	@SuppressWarnings("unchecked")
	public @ResponseBody Object searchAdvanced(//
			@RequestParam("query") String query, //
			@RequestParam("filterEntity") String entity, //
			@RequestParam("filerType") int type, //
			@RequestParam("filterVal") String value, //
			@RequestParam("filterVal2") String value2, //
			@RequestParam("filterVal3") String value3) {
		// init
		Map<String, Object> searchResults = new HashMap<String, Object>();
		// search local
		try {
			if (entity.equalsIgnoreCase("compounds")) {
				final List<AbstractDatasetObject> primitiveData = new ArrayList<AbstractDatasetObject>();
				for (final ReferenceChemicalCompound rcc : SearchService.searchCompound(query, type, value, value2,
						value3, SEARCH_NORMAL_RESULTS_SIZE_LIMIT)) {
					primitiveData.add(rcc);
				}
				// prune
				searchResults.put("compounds", PeakForestPruneUtils.prune(primitiveData));
				searchResults.put("compoundNames", new ArrayList<AbstractDatasetObject>());
				searchResults.put("success", true);
			} else if (entity.equalsIgnoreCase("nmr-spectra")) {
				final List<Double> listOfChemicalShift = new ArrayList<Double>();
				for (final String rawDouble : query.split(","))
					try {
						listOfChemicalShift.add(Double.parseDouble(rawDouble));
					} catch (final NumberFormatException e) {
					}
				Double tolerance = 0.02;
				try {
					tolerance = (Double.parseDouble(value));
				} catch (NumberFormatException e) {
				}
				short matchingMethod = NMR1DPeakMatchingService.MATCHING_METHOD_ALL;
				String[] dataTab = value2.split("-");
				Double pH = null;
				if (dataTab.length == 2) {
					if (dataTab[0].equalsIgnoreCase("ONE")) {
						matchingMethod = NMR1DPeakMatchingService.MATCHING_METHOD_ONE;
					}
					try {
						pH = Double.parseDouble(dataTab[1]);
					} catch (NumberFormatException nfe) {
					}
				}
				searchResults.put("compounds", new ArrayList<AbstractDatasetObject>());
				searchResults.put("compoundNames", new ArrayList<AbstractDatasetObject>());
				// search spectra
				// QUERY DEMO
				// query:1.287,1.306,1.321
				// filerType:-1
				// filterVal:0.5
				// filterVal2:one
				// == search candidates
				final Map<String, Object> rawNMRsearch = NMR1DPeakMatchingService.runPeakMatching(//
						listOfChemicalShift, tolerance, matchingMethod, pH);
				// if candidats => clean
				if (rawNMRsearch.containsKey("candidates")) {
					final List<NMRCandidate> rawWSresults = (List<NMRCandidate>) rawNMRsearch.get("candidates");
					for (final NMRCandidate candidate : rawWSresults) {
						candidate.setDistance(new ArrayList<Double>());
						candidate.setIntensity(null);
					}
					searchResults.put("nmrCandidates", rawWSresults);
					searchResults.put("success", true);
				} // candidats
				if (rawNMRsearch.containsKey("naiveSearch")) {
					final List<NMR1DSpectrum> rawSpectra = (List<NMR1DSpectrum>) rawNMRsearch.get("naiveSearch");
					// prune
					rawSpectra.addAll(PeakForestPruneUtils.pruneNMR1Dspectra(rawSpectra));
					// to map
					final Map<String, Object> nmrMap = new HashMap<String, Object>();
					for (final NMR1DSpectrum nmrS : rawSpectra) {
						nmrMap.put("pf:" + nmrS.getId(), nmrS);
					}
					searchResults.put("nmrSpectra", rawSpectra);
					searchResults.put("success", true);
				} // naiveSearch
			} else if (entity.equalsIgnoreCase("lcms-spectra")) {
				// 0 - init
				String mode = null;
				String resolution = null;
				String algo = null;
				Double deltaMass = null;
				Double deltaRT = null;
				Double[] queryMass = null;
				Double[] queryRT = null;
				List<String> filterColumns = null;
				Map<String, Object> results = new HashMap<String, Object>();
				// I - recover query param
				// I.A - mode / res / algo
				String[] tabFilterVal = value.split(";");
				// filterVal:pos;h;BiH
				mode = tabFilterVal[0];
				resolution = tabFilterVal[1];
				algo = tabFilterVal[2];

				// I.B - tolerances
				String[] tabFilterVal2 = value2.split(";");
				// filterVal2:0.05;null
				try {
					deltaMass = Double.parseDouble(tabFilterVal2[0]);
				} catch (NumberFormatException e) {
				}
				try {
					deltaRT = Double.parseDouble(tabFilterVal2[1]);
				} catch (NumberFormatException e) {
				}

				// I.C - peaklists
				// query:123.45,124.567,124.96;;
				String[] tabFilterVal3 = query.split(";");
				if (tabFilterVal3[0] != null) {
					String[] rawQueryMass = tabFilterVal3[0].split(",");
					queryMass = new Double[rawQueryMass.length];
					for (int i = 0; i < rawQueryMass.length; i++)
						try {
							queryMass[i] = Double.parseDouble(rawQueryMass[i]);
						} catch (NumberFormatException e) {
							queryMass[i] = -1.0;
						}
				}
				if (tabFilterVal3.length > 1 && tabFilterVal3[1] != null) {
					String[] rawQueryRT = tabFilterVal3[1].split(",");
					queryRT = new Double[rawQueryRT.length];
					for (int i = 0; i < rawQueryRT.length; i++)
						try {
							queryRT[i] = Double.parseDouble(rawQueryRT[i]);
						} catch (NumberFormatException e) {
							queryRT[i] = -1.0;
						}
				}
				if (tabFilterVal3.length > 2 && tabFilterVal3[2] != null) {
					String[] rawQueryCol = tabFilterVal3[2].split(",");
					filterColumns = Arrays.asList(rawQueryCol);
				}

				// II - run algo peakmatching
				// II.A - standardiz values
				Short modeN = null;
				if (mode != null)
					switch (mode.toUpperCase()) {
					case "POS":
					case "POSITIVE":
						modeN = MassSpectrum.MASS_SPECTRUM_POLARITY_POSITIVE;
						break;
					case "NEG":
					case "NEGATIVE":
						modeN = MassSpectrum.MASS_SPECTRUM_POLARITY_NEGATIVE;
						break;
					case "NEU":
					case "NEUTRAL":
					default:
						modeN = null;
						break;
					}
				char resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_HIGH;
				if (resolution != null)
					switch (resolution.toUpperCase()) {
					case "H L":
						resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_ALL;
						break;
					case "L":
						resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_LOW;
						break;
					case "H":
					default:
						resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_HIGH;
						break;
					}

				// II.B - Chuck Testa ~> NOPE!
				if (queryMass == null) {
					searchResults.put("error", "empty_mz_peaklist");
					searchResults.put("success", false);
					return searchResults;
				}

				// II.C - RUN B***, RUN!!!
				if (algo != null)
					switch (algo.toUpperCase()) {
					case "BIH":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, null, null, deltaMass, null,
								LCMSPeakMatchingService.PM_ALGO_BIH_MASS,
								LCMSPeakMatchingService.PM_ALGO_BIH_SCORING_MATCH_SPECTRA, modeN, resolutionN);
						break;
					case "BIHRT":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, queryRT, filterColumns, deltaMass,
								deltaRT, LCMSPeakMatchingService.PM_ALGO_BIH_MASS_RT,
								LCMSPeakMatchingService.PM_ALGO_BIH_SCORING_MATCH_SPECTRA, modeN, resolutionN);
						break;
					case "LCMSMATCHING":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, null, null, deltaMass, null,
								LCMSPeakMatchingService.PM_ALGO_SACLAY_MASS,
								LCMSPeakMatchingService.PM_ALGO_SACLAY_SCORING_MATCH_SPECTRA, modeN, resolutionN);
						break;
					case "LCMSMATCHINGRT":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, queryRT, filterColumns, deltaMass,
								deltaRT, LCMSPeakMatchingService.PM_ALGO_SACLAY_MASS_RT,
								LCMSPeakMatchingService.PM_ALGO_SACLAY_SCORING_MATCH_SPECTRA, modeN, resolutionN);
						break;
					default:
						break;
					}

				// III - fetch/prune results

				if (results.containsKey("success") && results.get("success") instanceof Boolean) {
					boolean algoSuccess = (boolean) results.get("success");
					if (!algoSuccess) {
						searchResults.put("error", results.get("error"));
						searchResults.put("success", false);
					} else {

						// success
						searchResults.put("success", true);

						// get
						List<FullScanLCSpectrum> listOfSpectra = (List<FullScanLCSpectrum>) results.get("results");
						// prune
						listOfSpectra = PeakForestPruneUtils.pruneFullScanLCMSspectra(listOfSpectra);
						// map
						searchResults.put("lcmsSpectra", listOfSpectra);
					}
				}

			} else if (entity.equalsIgnoreCase("lcmsms-spectra")) {

				// 0 - init
				String mode = null;
				String resolution = null;

				Double precursorMZ = null;
				Double precursorMZdelta = null;
				Double peaklistDeltaPPM = null;

				List<Double> queryMZ = new ArrayList<>();
				List<Double> queryRI = new ArrayList<>();

				Map<String, Object> results = new HashMap<String, Object>();

				// I - recover query param
				// I.A - mode / res
				String[] tabFilterVal = value.split(";");
				// filterVal:neg;h;
				mode = tabFilterVal[0];
				resolution = tabFilterVal[1];

				// I.B - tolerances
				String[] tabFilterVal2 = value2.split(";");
				// filterVal2: 254.0;0.1;5
				try {
					precursorMZ = Double.parseDouble(tabFilterVal2[0]);
				} catch (NumberFormatException e) {
				}
				try {
					precursorMZdelta = Double.parseDouble(tabFilterVal2[1]);
				} catch (NumberFormatException e) {
				}
				try {
					peaklistDeltaPPM = Double.parseDouble(tabFilterVal2[2]);
				} catch (NumberFormatException e) {
				}

				// I.C - peaklists
				// query:123.45,124.567,124.96;;
				String tabMZvRI = query;
				if (tabMZvRI != null) {
					tabMZvRI = tabMZvRI.substring(1, tabMZvRI.length() - 1);
					for (String kv : tabMZvRI.split("\\],\\[")) {
						String cleanKV = kv.replaceAll("\"", "").replaceAll("\\[", "").replaceAll("\\]", "");
						String[] dataKV = cleanKV.split(",");
						try {
							queryMZ.add(Double.parseDouble(dataKV[0]));
							queryRI.add(Double.parseDouble(dataKV[1]));
						} catch (NumberFormatException e) {
						}
					}
				}

				// II - run algo peakmatching
				// II.A - standardiz values
				Short modeN = null;
				if (mode != null)
					switch (mode.toUpperCase()) {
					case "POS":
					case "POSITIVE":
						modeN = MassSpectrum.MASS_SPECTRUM_POLARITY_POSITIVE;
						break;
					case "NEG":
					case "NEGATIVE":
						modeN = MassSpectrum.MASS_SPECTRUM_POLARITY_NEGATIVE;
						break;
					// case "NEU":
					// case "NEUTRAL":
					// default:
					// modeN = null;
					// break;
					}
				char resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_HIGH;
				if (resolution != null)
					switch (resolution.toUpperCase()) {
					case "H L":
						resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_ALL;
						break;
					case "L":
						resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_LOW;
						break;
					case "H":
					default:
						resolutionN = LCMSPeakMatchingService.PM_RESOLUTION_HIGH;
						break;
					}

				// II.B - Chuck Testa ~> NOPE!
				if (queryMZ.isEmpty()) {
					searchResults.put("error", "empty_mz_peaklist");
					searchResults.put("success", false);
					return searchResults;
				}

				// II.C - RUN B***, RUN!!!
				results = LCMSMSPeakMatchingService.runPeakMatching(queryMZ, queryRI, precursorMZ, precursorMZdelta,
						peaklistDeltaPPM, modeN, resolutionN, null, null, null);

				// III - fetch/prune results

				if (results.containsKey("success") && results.get("success") instanceof Boolean) {
					boolean algoSuccess = (boolean) results.get("success");
					if (!algoSuccess) {
						// error feedback
						searchResults.put("error", results.get("error"));
						searchResults.put("success", false);
					} else {
						// success
						searchResults.put("success", true);
						// get
						List<FragmentationLCSpectrum> listOfSpectra = (List<FragmentationLCSpectrum>) results
								.get("results");
						// prune
						listOfSpectra = PeakForestPruneUtils.pruneFragmentationLCMSspectra(listOfSpectra);
						// map
						searchResults.put("lcmsmsSpectra", listOfSpectra);
					}
				}

			}

		} catch (Exception e) {
			e.printStackTrace();
			searchResults.put("success", false);
			searchResults.put("error", "exception");
			searchResults.put("exceptionMessage", e.getMessage());
		}
		// TODO search via WS on other instance of spectral databases
		// return

		return searchResults;
	}

	@RequestMapping(value = "/image/{type}/{inchikey}")
	public @ResponseBody void showImage(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final @PathVariable String type, //
			final @PathVariable String inchikey)//
			throws PeakForestManagerException, IOException {

		// get images path
		final String svgImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists()) {
			(new File(svgImagesPath)).mkdirs();
		}
		final String pngImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesPNG.folder");
		if (!(new File(pngImagesPath)).exists()) {
			(new File(pngImagesPath)).mkdirs();
		}

		// case 1 - return PNG image
		final File imgPNGPath = new File(pngImagesPath + File.separator + inchikey + ".png");
		if (imgPNGPath.exists()) {
			displayImage(imgPNGPath, "png", response);
			return;
		}

		// case 2 - return SVG image
		final File imgSVGPath = new File(svgImagesPath + File.separator + inchikey + ".svg");

		if (!imgSVGPath.exists()) {
			// case 3 - image does not exists (yet!) -> create SVG image via open babel
			try {
				if (type.equalsIgnoreCase("chemical")) {
					ChemicalCompound c = ChemicalCompoundManagementService.readByInChIKey(inchikey);
					if (c != null) {
						ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
						compoundsList.add(c);
						CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(
								compoundsList, svgImagesPath, null);
						ExecutorService executor = Executors.newCachedThreadPool();
						executor.submit(ci);
					} else {
						displayErrorSvgImage(response);
						return;
					}
				} else if (type.equalsIgnoreCase("generic")) {
					GenericCompound c = GenericCompoundManagementService.readByInChIKey(inchikey);
					if (c != null) {
						ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
						compoundsList.add(c);
						CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(
								compoundsList, svgImagesPath, null);
						ExecutorService executor = Executors.newCachedThreadPool();
						executor.submit(ci);
					} else {
						displayErrorSvgImage(response);
						return;
					}
				} else if (type.equalsIgnoreCase("gc-derived")) {
					final GCDerivedCompound c = GCDerivedCompoundDao.read(inchikey, false, false, false, false, false,
							false);
					if (c != null) {
						final ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
						compoundsList.add(c);
						CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(
								compoundsList, svgImagesPath, null);
						ExecutorService executor = Executors.newCachedThreadPool();
						executor.submit(ci);
					} else {
						displayErrorSvgImage(response);
						return;
					}
				} else {
					// elsif other ref
					displayErrorSvgImage(response);
					return;
				}
			} catch (Exception e) {
				e.printStackTrace();
				displayErrorSvgImage(response);
				return;
			}
		}

		try {
			displayImage(imgSVGPath, "svg", response);
			return;
		} catch (final Exception e) {
			e.printStackTrace();
			displayErrorSvgImage(response);
			return;
		}

	}

	@RequestMapping(value = "/image/{inchikey}")
	public @ResponseBody void showImageQuick_noext(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final @PathVariable String inchikey)//
			throws PeakForestManagerException, IOException {
		showImageQuick(request, response, locale, inchikey);
	}

	@RequestMapping(value = "/image/{inchikey}.svg")
	public @ResponseBody void showImageQuick(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final @PathVariable String inchikey)//
			throws PeakForestManagerException, IOException {

		// get images path
		final String svgImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists()) {
			(new File(svgImagesPath)).mkdirs();
		}
		final String pngImagesPath = PeakForestUtils.getBundleConfElement("compoundImagesPNG.folder");
		if (!(new File(pngImagesPath)).exists()) {
			(new File(pngImagesPath)).mkdirs();
		}

		// set images files
		final File imgPNGPath = new File(pngImagesPath + File.separator + inchikey + ".png");
		final File imgSvgPath = new File(svgImagesPath + File.separator + inchikey + ".svg");

		// display if exists
		if (imgPNGPath.exists()) {
			displayImage(imgPNGPath, "png", response);
			return;
		} else if (imgSvgPath.exists()) {
			displayImage(imgPNGPath, "svg", response);
			return;
		}
		// if do not exist create it
		else {
			displayErrorSvgImage(response);
			return;
		}
	}

	private String svgImageError(final String imgPath) {
		try {
			return SimpleFileReader.readFile(//
					new File(getClass().getClassLoader().getResource(//
							PeakForestUtils.getBundleConfElement("compoundImagesSVG.notFound"))//
							.getFile())//
									.getAbsolutePath(),
					StandardCharsets.UTF_8);
		} catch (final IOException e) {
			e.printStackTrace();
		}
		return "";
	}

	private void displayErrorSvgImage(final HttpServletResponse response)
			throws IOException, PeakForestManagerException {
		final File fileToDisplay = new File(getClass().getClassLoader()
				.getResource(PeakForestUtils.getBundleConfElement("compoundImagesSVG.notFound")).getFile());
		final String ext = "svg";
		displayImage(fileToDisplay, ext, response);
	}

	private void displayImage(File fileToDisplay, String ext, HttpServletResponse response)
			throws IOException, PeakForestManagerException {
		if (ext.equalsIgnoreCase("png") || ext.equalsIgnoreCase("jpg") || ext.equalsIgnoreCase("jpeg")) {
			// get images path
			BufferedImage bufferedImage = ImageIO.read(fileToDisplay);
			response.setContentType("image/" + ext);
			response.setHeader("Cache-control", "no-cache");
			response.setHeader("Content-Disposition", "inline; filename=" + fileToDisplay.getName());
			// response.setContentLength((int) bufferedImage.length());
			ImageIO.write(bufferedImage, ext, response.getOutputStream());
			response.getOutputStream().flush();
			response.getOutputStream().close();
		} else if (ext.equalsIgnoreCase("svg")) {
			response.setContentType("image/svg+xml");
			response.setHeader("Cache-control", "no-cache");
			response.setHeader("Content-Disposition", "inline; filename=" + fileToDisplay.getName());
			// get images path
			InputStream inputStream = new BufferedInputStream(new FileInputStream(fileToDisplay));
			FileCopyUtils.copy(inputStream, response.getOutputStream());
		}
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/mol/{inchikey}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String getMolFile(//
			final HttpServletResponse response, //
			final @PathVariable String inchikey) throws PeakForestManagerException {
		// get mol path
		String molFileRepPath = PeakForestUtils.getBundleConfElement("compoundMolFiles.folder");
		if (!(new File(molFileRepPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);
		// response.setContentType("text/plain");
		final File molFilePath = new File(molFileRepPath + File.separator + inchikey + ".mol");
		if (!molFilePath.exists()) {
			throw new PeakForestManagerException("missing_mol_file");
		} else {
			try {
				response.setContentType("application/force-download");
				final FileReader fr = new FileReader(molFilePath);
				return IOUtils.toString(fr).replaceAll("OpenBabel\\d*D", "" + inchikey);
			} catch (final IOException ex) {
				throw new RuntimeException("IOError writing file to output stream");
			}
		}
	}

	@RequestMapping(value = "/json/{fileName}.json")
	public @ResponseBody String showJson(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String fileName) throws PeakForestManagerException {

		// set response header
		response.setContentType("application/json");

		String jsonFileName = fileName + ".json";
		// String jsonMassVsLogP = Utils.getBundleConfElement("json.massVsLogP");
		// String jsonPeakForestStats =
		// Utils.getBundleConfElement("json.peakforestStats");

		// get images path
		String jsonFilesPath = PeakForestUtils.getBundleConfElement("json.folder");
		if (!(new File(jsonFilesPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + jsonFilesPath);

		File jsonFile = new File(jsonFilesPath + File.separator + jsonFileName);
		try {
			return SimpleFileReader.readFile(jsonFile.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@RequestMapping(value = "/numbered/{inchikey}.mol", method = RequestMethod.GET, produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String getMolNumberedFile(HttpServletResponse response, @PathVariable String inchikey)
			throws PeakForestManagerException {

		// get mol path
		String molFileRepPath = PeakForestUtils.getBundleConfElement("compoundNumberedFiles.folder");
		if (!(new File(molFileRepPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);

		// response.setContentType("text/plain");

		File molFilePath = new File(molFileRepPath + File.separator + inchikey + ".mol");
		if (!molFilePath.exists()) {
			throw new PeakForestManagerException("missing_mol_file");
		} else {
			try {
				response.setContentType("application/force-download");
				FileReader fr = new FileReader(molFilePath);
				return IOUtils.toString(fr).replaceAll("OpenBabel\\d*D", "" + inchikey);
				// // get your file as InputStream
				// InputStream is = new FileInputStream(molFilePath);
				// // copy it to response's OutputStream
				// org.apache.commons.io.IOUtils.copy(is, response.getOutputStream());
				// response.flushBuffer();
			} catch (IOException ex) {
				// log.info("Error writing file to output stream. Filename was '{}'", fileName,
				// ex);
				throw new RuntimeException("IOError writing file to output stream");
			}
		}
	}

	@RequestMapping(value = "/numbered/{inchikey}.svg")
	public @ResponseBody String showImageHumbSVG(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String inchikey) throws PeakForestManagerException {

		// set response header
		response.setContentType("image/svg+xml");

		// get images path
		String svgImagesPath = PeakForestUtils.getBundleConfElement("compoundNumberedFiles.folder");
		if (!(new File(svgImagesPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);

		File imgPath = new File(svgImagesPath + File.separator + inchikey + ".svg");
		try {
			return SimpleFileReader.readFile(imgPath.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (Exception e) {
			e.printStackTrace();
			return svgImageError(svgImagesPath);
		}
	}

	@RequestMapping(value = "/numbered/{inchikey}.png", method = RequestMethod.GET, produces = MediaType.IMAGE_PNG_VALUE)
	public @ResponseBody void showImageHumbPNG(HttpServletRequest request, HttpServletResponse response,
			@PathVariable("inchikey") String inchikey) throws IOException, PeakForestManagerException {
		magicNils(inchikey, "png", response);
	}

	@RequestMapping(value = "/numbered/{inchikey}.jpeg", method = RequestMethod.GET, produces = MediaType.IMAGE_JPEG_VALUE)
	public @ResponseBody void showImageHumbJPEG(HttpServletRequest request, HttpServletResponse response,
			@PathVariable("inchikey") String inchikey) throws IOException, PeakForestManagerException {
		magicNils(inchikey, "jpeg", response);
	}

	private void magicNils(String inchikey, String ext, HttpServletResponse response)
			throws IOException, PeakForestManagerException {
		// get images path
		String uploadImagesPath = PeakForestUtils.getBundleConfElement("compoundNumberedFiles.folder");
		if (!(new File(uploadImagesPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + uploadImagesPath);
		File imgPath = new File(uploadImagesPath + File.separator + inchikey + "." + ext);
		BufferedImage bufferedImage = ImageIO.read(imgPath);
		response.setContentType("image/" + ext);
		response.setHeader("Cache-control", "no-cache");
		response.setHeader("Content-Disposition", "inline; filename=" + imgPath.getName());
		// response.setContentLength((int) bufferedImage.length());
		ImageIO.write(bufferedImage, ext, response.getOutputStream());
		response.getOutputStream().flush();
		response.getOutputStream().close();
	}

	@RequestMapping(value = "/metadata/lcms/list-code-columns", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody Object getListLCcolumnsCode() {

		// run
		try {
			// search
			Map<String, Object> results = LiquidChromatographyMetadataDao.getDistinctColumn();
			return results;
		} catch (Exception e) {
			Map<String, Object> error = new HashMap<String, Object>();
			return error;
		}
		// return null;
	}

	///////////////////////////////////////////////////////////////////////////

	@RequestMapping(value = "/spectra_img/{id}.png", method = RequestMethod.GET, produces = MediaType.IMAGE_PNG_VALUE)
	public @ResponseBody void showImageSpectraPNG(HttpServletRequest request, HttpServletResponse response,
			@PathVariable("id") String id) throws IOException, PeakForestManagerException {
		// get images path
		String spectraImagesPath = PeakForestUtils.getBundleConfElement("imageFile.nmr.folder");
		if (!(new File(spectraImagesPath)).exists())
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + spectraImagesPath);
		File imgPath = new File(spectraImagesPath + File.separator + id + ".png");
		if (!imgPath.exists()) {
			String toolURL = PeakForestUtils.getBundleConfElement("nmrspectrum.getpng.service.url");
			String spectraImgDirectory = PeakForestUtils.getBundleConfElement("imageFile.nmr.folder");
			ImageGenerator.getSpectrumPNGimage(toolURL, id, spectraImgDirectory);
		}
		BufferedImage bufferedImage = ImageIO.read(imgPath);
		response.setContentType("image/png");
		response.setHeader("Cache-control", "no-cache");
		response.setHeader("Content-Disposition", "inline; filename=" + imgPath.getName());
		// response.setContentLength((int) bufferedImage.length());
		ImageIO.write(bufferedImage, "png", response.getOutputStream());
		response.getOutputStream().flush();
		response.getOutputStream().close();
	}

	@RequestMapping(value = "/nmrpro-light/{id}", method = RequestMethod.GET)
	public String nmrProLigh(HttpServletRequest request, HttpServletResponse response, Locale locale,
			@PathVariable String id, Model model) throws PeakForestManagerException {

		model.addAttribute("id", id);
		// RETURN
		return "module/nmrpro-light";
	}

	@RequestMapping(value = "/spectrum-json/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE, params = {
			"label", })
	public @ResponseBody Object getNMRspectrumJsonData4NMRpro(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam("label") String label, @PathVariable String id, Model model) {
		return NMRpro.getFile(id, label);
	}

	///////////////////////////////////////////////////////////////////////////

	// new 2.3.1 issue 363 - export SDF

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/sdf/{inchikey}", //
			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String getSdfFile(//
			final HttpServletResponse response, //
			final @PathVariable String inchikey)//
			throws PeakForestManagerException {
		// get mol path
		String molFileRepPath = PeakForestUtils.getBundleConfElement("compoundMolFiles.folder");
		if (!(new File(molFileRepPath)).exists()) {
			throw new PeakForestManagerException(PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);
		}
		final File molFile = new File(molFileRepPath + File.separator + inchikey + ".mol");
		if (!molFile.exists()) {
			throw new PeakForestManagerException("missing_mol_file");
		}
		final StructureChemicalCompound compound = IReferenceCompoundDao.read(//
				inchikey, StructureChemicalCompound.class, //
				Boolean.TRUE, Boolean.FALSE, Boolean.TRUE, //
				Boolean.FALSE, Boolean.FALSE, Boolean.TRUE, //
				Boolean.TRUE, Boolean.FALSE, Boolean.TRUE);
		final String pforestInstanceUrl = PeakForestUtils.getBundleConfElement("peakforest.webapp.url");
		try {
			response.setContentType("application/force-download");
			return GenerateSdfFileService.generateSdfFile(molFile, compound, pforestInstanceUrl);
		} catch (final IOException ex) {
			throw new RuntimeException("IOError writing file to output stream");
		}
	}
}

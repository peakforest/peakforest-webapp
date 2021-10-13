package fr.metabohub.peakforest.controllers;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import fr.metabohub.externaltools.nmr.ImageGenerator;
import fr.metabohub.externaltools.proxy.NMRpro;
import fr.metabohub.peakforest.model.AbstractDatasetObject;
import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.MassSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMR1DSpectrum;
import fr.metabohub.peakforest.services.SearchService;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.metadata.LiquidChromatographyMetadataManagementService;
import fr.metabohub.peakforest.services.peakmatching.LCMSPeakMatchingService;
import fr.metabohub.peakforest.services.peakmatching.NMR1DPeakMatchingService;
import fr.metabohub.peakforest.services.threads.CompoundsImagesAndMolFilesGeneratorThread;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.SimpleFileReader;
import fr.metabohub.peakforest.utils.Utils;
import fr.metabohub.peakmatching.mapper.NMRCandidate;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class ToolsController {

	@RequestMapping(value = "/404", method = RequestMethod.GET)
	public ModelAndView redirectFrom404(HttpServletResponse httpServletResponse) {
		// httpServletResponse.setHeader("Location", "home?page=template");
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

	@RequestMapping(value = "/.war", method = RequestMethod.GET)
	public ModelAndView redirectWar(HttpServletResponse httpServletResponse) {
		// httpServletResponse.setHeader("Location", "home?page=template");
		return new ModelAndView("redirect:" + "home?page=500");
	}

	// @SuppressWarnings("unchecked")
	/**
	 * @param query
	 * @return
	 */
	@RequestMapping(value = "/search", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, params = "query")
	public @ResponseBody Object search(@RequestParam("query") String query) {
		// // init
		// Map<String, Object> searchResults = new HashMap<String, Object>();
		// String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		// String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		// String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// // search local
		// try {
		// searchResults = SearchService.search(query, 50, dbName, username, password);
		// // prune
		// searchResults.put("compounds",
		// Utils.prune((List<AbstractDatasetObject>) searchResults.get("compounds")));
		// searchResults.put("compoundNames",
		// Utils.prune((List<AbstractDatasetObject>) searchResults.get("compoundNames")));
		// // success
		// searchResults.put("success", true);
		// } catch (Exception e) {
		// e.printStackTrace();
		// searchResults.put("success", false);
		// searchResults.put("error", "exception");
		// searchResults.put("exceptionMessage", e.getMessage());
		// }
		// // TODO search via WS on other instance of spectral databases
		// // return

		return searchOpt(query, false);
	}

	/**
	 * Classic search (support natural language)
	 * 
	 * @param query
	 * @param quick
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/search", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, params = {
			"query", "quick" })
	public @ResponseBody Object searchOpt(@RequestParam("query") String query,
			@RequestParam("quick") boolean quick) {
		// init
		Map<String, Object> searchResults = new HashMap<String, Object>();
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// search local
		try {
			searchResults = SearchService.search(query, quick, 50, dbName, username, password);
			// prune
			searchResults.put("compounds",
					Utils.prune((List<AbstractDatasetObject>) searchResults.get("compounds")));
			searchResults.put("compoundNames",
					Utils.prune((List<AbstractDatasetObject>) searchResults.get("compoundNames")));
			if (searchResults.containsKey("lcmsSpectra")) {
				List<AbstractDatasetObject> dataJson = Utils
						.prune((List<AbstractDatasetObject>) searchResults.get("lcmsSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("lcmsSpectra", dataJson);
			}
			if (searchResults.containsKey("nmrSpectra")) {
				List<AbstractDatasetObject> dataJson = Utils
						.prune((List<AbstractDatasetObject>) searchResults.get("nmrSpectra"));
				if (dataJson.size() > 30)
					dataJson = dataJson.subList(0, 30);
				searchResults.put("nmrSpectra", dataJson);
			}
			// success
			searchResults.put("success", true);
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

	// searchRequest = "query=" + $.trim(cleanQuery) + "&filterEntity="+ qFilterEntity + "&filerType="+
	// qFilerType + "&filterVal=" + qFilterVal + "&filterVal2=" + qFilterVal2;
	/**
	 * LCMS / NMR peakmatching
	 * 
	 * @param query
	 * @param entity
	 * @param type
	 * @param value
	 * @param value2
	 * @return
	 */
	@RequestMapping(value = "/search", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, params = {
			"query", "filterEntity", "filerType", "filterVal", "filterVal2" })
	public @ResponseBody Object searchAdvanced(@RequestParam("query") String query,
			@RequestParam("filterEntity") String entity, @RequestParam("filerType") int type,
			@RequestParam("filterVal") String value, @RequestParam("filterVal2") String value2,
			@RequestParam("filterVal3") String value3) {
		// init
		Map<String, Object> searchResults = new HashMap<String, Object>();
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// search local

		try {
			if (entity.equalsIgnoreCase("compounds")) {
				List<AbstractDatasetObject> primitiveData = new ArrayList<AbstractDatasetObject>();
				for (ReferenceChemicalCompound rcc : SearchService.searchCompound(query, type, value, value2,
						value3, 50, dbName, username, password)) {
					primitiveData.add(rcc);
				}
				// prune
				searchResults.put("compounds", Utils.prune(primitiveData));
				searchResults.put("compoundNames", new ArrayList<AbstractDatasetObject>());
			} else if (entity.equalsIgnoreCase("nmr-spectra")) {
				// List<AbstractDatasetObject> primitiveData = new ArrayList<AbstractDatasetObject>();

				List<Double> listOfChemicalShift = new ArrayList<Double>();
				for (String rawDouble : query.split(","))
					try {
						listOfChemicalShift.add(Double.parseDouble(rawDouble));
					} catch (NumberFormatException e) {
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

				// query:1.287,1.306,1.321
				// filerType:-1
				// filterVal:0.5
				// filterVal2:one
				Map<String, Object> rawNMRsearch = NMR1DPeakMatchingService.runPeakMatching(
						listOfChemicalShift, tolerance, matchingMethod, pH, dbName, username, password);

				if (rawNMRsearch.containsKey("candidates")) {
					@SuppressWarnings("unchecked")
					List<NMRCandidate> rawWSresults = (List<NMRCandidate>) rawNMRsearch.get("candidates");
					for (NMRCandidate candidate : rawWSresults) {
						candidate.setDistance(new ArrayList<Double>());
						// DEBUG
						candidate.setIntensity(null);
					}
					searchResults.put("nmrCandidates", rawWSresults);
				} // candidats
				if (rawNMRsearch.containsKey("naiveSearch")) {
					@SuppressWarnings("unchecked")
					List<NMR1DSpectrum> rawSpectra = (List<NMR1DSpectrum>) rawNMRsearch.get("naiveSearch");
					// prune
					rawSpectra = Utils.pruneNMR1Dspectra(rawSpectra);
					// to map
					Map<String, Object> nmrMap = new HashMap<String, Object>();
					for (NMR1DSpectrum nmrS : rawSpectra) {
						nmrMap.put("pf:" + nmrS.getId(), nmrS);
					}
					searchResults.put("nmrSpectra", rawSpectra);
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
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, null, null, deltaMass,
								null, LCMSPeakMatchingService.PM_ALGO_BIH_MASS,
								LCMSPeakMatchingService.PM_ALGO_BIH_SCORING_MATCH_SPECTRA, modeN, resolutionN,
								dbName, username, password);
						break;
					case "BIHRT":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, queryRT, filterColumns,
								deltaMass, deltaRT, LCMSPeakMatchingService.PM_ALGO_BIH_MASS_RT,
								LCMSPeakMatchingService.PM_ALGO_BIH_SCORING_MATCH_SPECTRA, modeN, resolutionN,
								dbName, username, password);
						break;
					case "LCMSMATCHING":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, null, null, deltaMass,
								null, LCMSPeakMatchingService.PM_ALGO_SACLAY_MASS,
								LCMSPeakMatchingService.PM_ALGO_SACLAY_SCORING_MATCH_SPECTRA, modeN,
								resolutionN, dbName, username, password);
						break;
					case "LCMSMATCHINGRT":
						results = LCMSPeakMatchingService.runPeakMatching(queryMass, queryRT, filterColumns,
								deltaMass, deltaRT, LCMSPeakMatchingService.PM_ALGO_SACLAY_MASS_RT,
								LCMSPeakMatchingService.PM_ALGO_SACLAY_SCORING_MATCH_SPECTRA, modeN,
								resolutionN, dbName, username, password);
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
						// get
						@SuppressWarnings("unchecked")
						List<FullScanLCSpectrum> listOfSpectra = (List<FullScanLCSpectrum>) results
								.get("results");
						// prune
						listOfSpectra = Utils.pruneFullScanLCMSspectra(listOfSpectra);
						// map
						searchResults.put("lcmsSpectra", listOfSpectra);
					}
				}

			}
			// success
			searchResults.put("success", true);
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
	public @ResponseBody String showImage(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String type, @PathVariable String inchikey)
			throws PeakForestManagerException {

		// set response header
		response.setContentType("image/svg+xml");

		// get images path
		String svgImagesPath = Utils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);

		// init db
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// get obabel bin

		File imgPath = new File(svgImagesPath + File.separator + inchikey + ".svg");
		if (!imgPath.exists()) {
			// create id!
			try {
				if (type.equalsIgnoreCase("chemical")) {
					ChemicalCompound c = ChemicalCompoundManagementService.readByInChIKey(inchikey, dbName,
							username, password);
					if (c != null) {
						// OBabelTower.convertFormat(c.getInChI(), OBabelTower.FORMAT_INCHI,
						// OBabelTower.FORMAT_INCHIKEY);
						// OBabelTower.writeFile(c.getInChI(), imgPath, OBabelTower.FORMAT_INCHI,
						// OBabelTower.FORMAT_SVG, "");
						ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
						compoundsList.add(c);
						CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(
								compoundsList, svgImagesPath, null);
						ExecutorService executor = Executors.newCachedThreadPool();
						executor.submit(ci);
					} else
						return svgImageError(svgImagesPath);
				} else if (type.equalsIgnoreCase("generic")) {
					GenericCompound c = GenericCompoundManagementService.readByInChIKey(inchikey, dbName,
							username, password);
					if (c != null) {
						// OBabelTower.convertFormat(c.getInChI(), OBabelTower.FORMAT_INCHI,
						// OBabelTower.FORMAT_INCHIKEY);
						// OBabelTower.writeFile(c.getInChI(), imgPath, OBabelTower.FORMAT_INCHI,
						// OBabelTower.FORMAT_SVG, "");
						ArrayList<StructureChemicalCompound> compoundsList = new ArrayList<>();
						compoundsList.add(c);
						CompoundsImagesAndMolFilesGeneratorThread ci = new CompoundsImagesAndMolFilesGeneratorThread(
								compoundsList, svgImagesPath, null);
						ExecutorService executor = Executors.newCachedThreadPool();
						executor.submit(ci);
					} else
						return svgImageError(svgImagesPath);
				} else {
					// TODO elsif other ref
					return svgImageError(svgImagesPath);
				}
			} catch (Exception e) {
				e.printStackTrace();
				return svgImageError(svgImagesPath);
			}
		}

		try {
			return SimpleFileReader.readFile(imgPath.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (Exception e) {
			e.printStackTrace();
			return svgImageError(svgImagesPath);
		}
	}

	@RequestMapping(value = "/image/{inchikey}.svg")
	public @ResponseBody String showImageQuick(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String inchikey) throws PeakForestManagerException {

		// set response header
		response.setContentType("image/svg+xml");

		// get images path
		String svgImagesPath = Utils.getBundleConfElement("compoundImagesSVG.folder");
		if (!(new File(svgImagesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);

		File imgPath = new File(svgImagesPath + File.separator + inchikey + ".svg");
		// TODO if do not exist create it
		try {
			return SimpleFileReader.readFile(imgPath.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (Exception e) {
			e.printStackTrace();
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return svgImageError(svgImagesPath);
		}
	}

	/**
	 * @param imgPath
	 * @return
	 * @throws IOException
	 */
	private String svgImageError(String imgPath) {
		try {
			return SimpleFileReader.readFile(new File(getClass().getClassLoader()
					.getResource(Utils.getBundleConfElement("compoundImagesSVG.notFound")).getFile())
							.getAbsolutePath(),
					StandardCharsets.UTF_8);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return "";
	}

	@RequestMapping(value = "/mol/{inchikey}", method = RequestMethod.GET, produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String getMolFile(HttpServletResponse response, @PathVariable String inchikey)
			throws PeakForestManagerException {

		// get mol path
		String molFileRepPath = Utils.getBundleConfElement("compoundMolFiles.folder");
		if (!(new File(molFileRepPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);

		// response.setContentType("text/plain");

		File molFilePath = new File(molFileRepPath + File.separator + inchikey + ".mol");
		if (!molFilePath.exists()) {
			throw new PeakForestManagerException("missing_mol_file"); // TODO set as error
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
				// log.info("Error writing file to output stream. Filename was '{}'", fileName, ex);
				throw new RuntimeException("IOError writing file to output stream");
			}
		}

	}

	@RequestMapping(value = "/json/{fileName}.json")
	public @ResponseBody String showJson(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable String fileName) throws PeakForestManagerException {

		// set response header
		response.setContentType("application/json");

		String jsonFileName = fileName + ".json";
		// String jsonMassVsLogP = Utils.getBundleConfElement("json.massVsLogP");
		// String jsonPeakForestStats = Utils.getBundleConfElement("json.peakforestStats");

		// get images path
		String jsonFilesPath = Utils.getBundleConfElement("json.folder");
		if (!(new File(jsonFilesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + jsonFilesPath);

		File jsonFile = new File(jsonFilesPath + File.separator + jsonFileName);
		try {
			return SimpleFileReader.readFile(jsonFile.getAbsolutePath(), StandardCharsets.UTF_8);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@RequestMapping(value = "/numbered/{inchikey}.mol", method = RequestMethod.GET, produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public @ResponseBody String getMolNumberedFile(HttpServletResponse response,
			@PathVariable String inchikey) throws PeakForestManagerException {

		// get mol path
		String molFileRepPath = Utils.getBundleConfElement("compoundNumberedFiles.folder");
		if (!(new File(molFileRepPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + molFileRepPath);

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
				// log.info("Error writing file to output stream. Filename was '{}'", fileName, ex);
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
		String svgImagesPath = Utils.getBundleConfElement("compoundNumberedFiles.folder");
		if (!(new File(svgImagesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + svgImagesPath);

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
		String uploadImagesPath = Utils.getBundleConfElement("compoundNumberedFiles.folder");
		if (!(new File(uploadImagesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + uploadImagesPath);
		File imgPath = new File(uploadImagesPath + File.separator + inchikey + "." + ext);
		BufferedImage bufferedImage = ImageIO.read(imgPath);
		response.setContentType("image/" + ext);
		response.setHeader("Cache-control", "no-cache");
		response.setHeader("Content-Disposition", "inline; filename=" + imgPath.getName());
		// response.setContentLength((int) bufferedImage.length());
		ImageIO.write(bufferedImage, "png", response.getOutputStream());
		response.getOutputStream().flush();
		response.getOutputStream().close();
	}

	@RequestMapping(value = "/metadata/lcms/list-code-columns", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody Object getListLCcolumnsCode() {

		// init
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String login = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// run
		try {
			// search
			Map<String, Object> results = LiquidChromatographyMetadataManagementService
					.readDistinctColumnByCode(dbName, login, password);
			return results;
		} catch (Exception e) {
			Map<String, Object> error = new HashMap<String, Object>();
			return error;
		}
		// return null;
	}

	///////////////////////////////////////////////////////////////////////////
	/**
	 * @param request
	 * @param response
	 * @param id
	 * @throws IOException
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/spectra_img/{id}.png", method = RequestMethod.GET, produces = MediaType.IMAGE_PNG_VALUE)
	public @ResponseBody void showImageSpectraPNG(HttpServletRequest request, HttpServletResponse response,
			@PathVariable("id") String id) throws IOException, PeakForestManagerException {
		// get images path
		String spectraImagesPath = Utils.getBundleConfElement("imageFile.nmr.folder");
		if (!(new File(spectraImagesPath)).exists())
			throw new PeakForestManagerException(
					PeakForestManagerException.MISSING_REPOSITORY + spectraImagesPath);
		File imgPath = new File(spectraImagesPath + File.separator + id + ".png");
		if (!imgPath.exists()) {
			String toolURL = Utils.getBundleConfElement("nmrspectrum.getpng.service.url");
			String spectraImgDirectory = Utils.getBundleConfElement("imageFile.nmr.folder");
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

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param label
	 * @param id
	 * @param model
	 * @return
	 */
	@RequestMapping(value = "/spectrum-json/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE, params = {
			"label", })
	public @ResponseBody Object getNMRspectrumJsonData4NMRpro(HttpServletRequest request,
			HttpServletResponse response, Locale locale, @RequestParam("label") String label,
			@PathVariable String id, Model model) {
		return NMRpro.getFile(id, label);
	}

	///////////////////////////////////////////////////////////////////////////
}

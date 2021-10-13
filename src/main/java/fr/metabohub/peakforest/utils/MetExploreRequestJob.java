package fr.metabohub.peakforest.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.externalbanks.mapper.MetExploreMapping;
import fr.metabohub.externalbanks.rest.MetExploreClient;
import fr.metabohub.peakforest.model.maps.MapEntity;
import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.services.maps.MapManagerManagementService;

@Component
public class MetExploreRequestJob {

	// private static final SimpleDateFormat dateFormat = new SimpleDateFormat("YYYY-MM-DD HH:mm:ss");
	private static boolean isMappingJobRuning = false;

	private static boolean launchUpdateMappingRuning = false;
	private static boolean fetchMappingRuning = false;

	/**
	 * @throws Exception
	 */
	public static void updateMappingData() throws Exception {

		if (isMappingJobRuning)
			return;
		isMappingJobRuning = true;

		// update mapping
		launchUpdateMappingData();

		// wait mapping computing end: 60 seconds
		try {
			Thread.sleep(60000);
		} catch (Exception e) {
		}

		// fetch new mapping data
		fetchMappingData();

		isMappingJobRuning = false;
	}

	// each first day of month at 3 AM
	// @Scheduled(cron = "0 0 3 1 * ?")
	public static void launchUpdateMappingData() throws Exception {

		if (launchUpdateMappingRuning)
			return;
		launchUpdateMappingRuning = true;

		boolean useMEWebService = Boolean.parseBoolean(Utils.getBundleConfElement("metexplore.ws.use"));
		if (!useMEWebService)
			return;

		// System.out.println("[MetExplore] - start update mapping - " + dateFormat.format(new Date()));
		SpectralDatabaseLogger.log("cron", "start launch update mapping [metexplore-chemical-lib-mapping-ws]",
				SpectralDatabaseLogger.LOG_INFO);

		// I - call WS
		// I.A - init ws data
		String token = Utils.getBundleConfElement("metexplore.ws.token");
		String urlInChI = Utils.getBundleConfElement("metexplore.ws.pfURL");
		String contact = Utils.getBundleConfElement("metexplore.ws.email");

		// I.B - call ws and wait responce
		MetExploreClient client = new MetExploreClient(token, urlInChI, contact, false);
		while (!(client.getStatus() != MetExploreClient.FAILURE
				|| client.getStatus() != MetExploreClient.SUCCESS))
			try {
				Thread.sleep(250);
			} catch (Exception e) {
			}

		SpectralDatabaseLogger.log("cron", "end launch update mapping [metexplore-chemical-lib-mapping-ws]",
				SpectralDatabaseLogger.LOG_INFO);

		launchUpdateMappingRuning = false;
	}

	// each first day of month at 4 AM
	// @Scheduled(cron = "0 0 4 1 * ?")
	public static void fetchMappingData() throws Exception {

		if (fetchMappingRuning)
			return;

		fetchMappingRuning = true;

		boolean useMEWebService = Boolean.parseBoolean(Utils.getBundleConfElement("metexplore.ws.use"));
		if (!useMEWebService)
			return;

		SpectralDatabaseLogger.log("cron", "start fetch mapping [metexplore-chemical-lib-mapping-ws]",
				SpectralDatabaseLogger.LOG_INFO);

		String jsonFile = Utils.getBundleConfElement("metexplore.data.jsonFile");
		String token = Utils.getBundleConfElement("metexplore.ws.token");
		String defaultStrategy = Utils.getBundleConfElement("metexplore.data.defaultStrategy");

		// read json data - get path
		String filePrefix = "";
		if (!jsonFile.startsWith("src/main/resources/")) {
			File file = new File(
					MetExploreRequestJob.class.getProtectionDomain().getCodeSource().getLocation().getFile());
			String[] dataPath = file.getAbsolutePath().split("WEB-INF/classes");
			filePrefix = dataPath[0] + "/WEB-INF/classes/";
		}

		// get json data - action
		ArrayList<Object> rawMetExploreParams = SimpleFileReader.readJson(filePrefix + jsonFile);

		MetExploreClient client = new MetExploreClient(token);
		while (!(client.getStatus() != MetExploreClient.FAILURE
				|| client.getStatus() != MetExploreClient.SUCCESS))
			try {
				Thread.sleep(250);
			} catch (Exception e) {
			}

		// I.C - get results
		ArrayList<MetExploreMapping> wsResults = client.getListOfMapping();
		if (wsResults != null && !wsResults.isEmpty()) {
			// decompile reults
			HashMap<String, List<MetExploreMapping>> mapData = new HashMap<String, List<MetExploreMapping>>();
			for (MetExploreMapping map : wsResults) {
				if (!mapData.containsKey(map.getOrgaName()))
					mapData.put(map.getOrgaName(), new ArrayList<MetExploreMapping>());
				List<MetExploreMapping> tmpList = mapData.get(map.getOrgaName());
				tmpList.add(map);
				mapData.put(map.getOrgaName(), tmpList);
			}

			// II - init data to keep in database
			MapManager metExploreNewMap = new MapManager(MapManager.MAP_METEXPLORE);

			// init - show
			for (Object rawMetExploreParam : rawMetExploreParams) {
				if (rawMetExploreParam instanceof LinkedHashMap<?, ?>) {
					@SuppressWarnings("unchecked")
					LinkedHashMap<String, Object> metExploreOrga = (LinkedHashMap<String, Object>) rawMetExploreParam;

					String orgaName = "";
					String source = "";
					boolean defaultDisplay = false;
					String strategy = "";

					if (metExploreOrga.containsKey("orgaName") && metExploreOrga.get("orgaName") != null)
						orgaName = metExploreOrga.get("orgaName").toString();

					if (metExploreOrga.containsKey("source") && metExploreOrga.get("source") != null)
						source = metExploreOrga.get("source").toString();

					if (metExploreOrga.containsKey("defaultDisplay")
							&& metExploreOrga.get("defaultDisplay") != null)
						defaultDisplay = Boolean
								.parseBoolean(metExploreOrga.get("defaultDisplay").toString());

					if (metExploreOrga.containsKey("strategy") && metExploreOrga.get("strategy") != null)
						strategy = (metExploreOrga.get("strategy").toString());

					if (strategy == "")
						strategy = defaultStrategy;

					if (mapData.containsKey(orgaName))
						switch (strategy) {
						case "max":
							MetExploreMapping map2keepM = null;
							double maxHit = -1.0;
							for (MetExploreMapping tmpData : mapData.get(orgaName)) {
								double tmpHit = tmpData.getMappedInChI() / tmpData.getTotalNumInchi();
								if (tmpHit > maxHit) {
									maxHit = tmpHit;
									map2keepM = tmpData;
								}
							}
							if (map2keepM != null)
								metExploreNewMap.addMapEntities(
										getMapEntity(map2keepM, metExploreNewMap, defaultDisplay, null));
							break;
						case "source":
							MetExploreMapping map2keepS = null;
							for (MetExploreMapping tmpData : mapData.get(orgaName)) {
								if (tmpData.getSource().equalsIgnoreCase(source))
									map2keepS = tmpData;
							}
							if (map2keepS != null)
								metExploreNewMap.addMapEntities(
										getMapEntity(map2keepS, metExploreNewMap, defaultDisplay, source));
							break;
						case "first":
							MetExploreMapping map2keepF = null;
							for (MetExploreMapping tmpData : mapData.get(orgaName)) {
								if (map2keepF == null)
									map2keepF = tmpData;
							}
							if (map2keepF != null)
								metExploreNewMap.addMapEntities(
										getMapEntity(map2keepF, metExploreNewMap, defaultDisplay, null));
							break;
						default:
							break;
						}
					else
						SpectralDatabaseLogger.log("cron", "orga '" + orgaName + "' not found",
								SpectralDatabaseLogger.LOG_INFO);
					//

				} // if (rawMetExploreParam instanceof LinkedHashMap
			} // for (Object rawMetExploreParam

			// Delete from DB
			// testSessionFactory
			if (MapManagerManagementService.exists(MapManager.MAP_METEXPLORE))
				MapManagerManagementService.delete(MapManager.MAP_METEXPLORE);

			// add to DB
			MapManagerManagementService.create(metExploreNewMap);

		} else {
			SpectralDatabaseLogger.log("cron",
					"unable to contact WEBSERVICE [metexplore-chemical-lib-mapping-ws]",
					SpectralDatabaseLogger.LOG_INFO);
			// System.err.println("[MetExplore] - unable to contact WEBSERVICE - "
			// + dateFormat.format(new Date()));
		}
		SpectralDatabaseLogger.log("cron", "end fetch mapping [metexplore-chemical-lib-mapping-ws]",
				SpectralDatabaseLogger.LOG_INFO);
		// System.out.println("[MetExplore] - - " + dateFormat.format(new Date()));

		fetchMappingRuning = false;

	}

	/**
	 * @param rawMap
	 * @param mapManagerSource
	 * @param displayDefault
	 * @param source
	 * @return
	 */
	private static MapEntity getMapEntity(MetExploreMapping rawMap, MapManager mapManagerSource,
			boolean displayDefault, String source) {
		MapEntity mapEntity = new MapEntity(mapManagerSource);
		// display
		mapEntity.setDisplayDefault(displayDefault);
		// all data
		mapEntity.setOrga(rawMap.getOrgaName());
		if (source != null)
			mapEntity.setSource(source);
		mapEntity.setNumberInChIMatch(rawMap.getMappedInChI());
		mapEntity.setNumberInChITotal(rawMap.getTotalNumInchi());
		mapEntity.setExtMappingID(rawMap.getMetexploreIdMapping());
		return mapEntity;
	}

	// each weeks
	@Scheduled(fixedRate = 604800000)
	public static void updateMetExoloreBiosourcesList() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update metexplore-networks-list ",
				SpectralDatabaseLogger.LOG_INFO);

		// init request
		String fileNameAndPath = Utils.getBundleConfElement("json.metExploreBiosourcesList");
		String filePrefix = Utils.getBundleConfElement("json.folder");
		String filePathAndName = filePrefix + File.separator + fileNameAndPath;

		// I - call WS
		MetExploreClient client = new MetExploreClient(MetExploreClient.METEXPLORE_GET_LIST_BIOSOURCES);
		// for (MetExploreBiosource source : client.getListOfBiosources())
		// System.out.println(source);

		// II - update json
		// boolean success = false;
		ObjectMapper mapper = new ObjectMapper();
		String ret = mapper.writeValueAsString(client.getListOfBiosources());
		FileWriter file = new FileWriter(filePathAndName);
		try {
			file.write(ret);
			// success = true;
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			file.flush();
			file.close();
		}

		SpectralDatabaseLogger.log("cron", "end update metexplore-networks-list ",
				SpectralDatabaseLogger.LOG_INFO);
		// return success;
	}
}
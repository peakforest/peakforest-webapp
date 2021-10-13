package fr.metabohub.peakforest.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.externalbanks.mapper.metexplore.MetExBiosource;
import fr.metabohub.externalbanks.mapper.metexplore.MetExStatsPForest;
import fr.metabohub.externalbanks.rest.MetExploreClient;
import fr.metabohub.externalbanks.services.MetExploreCoverageStatMapper;
import fr.metabohub.peakforest.model.maps.MapEntity;
import fr.metabohub.peakforest.model.maps.MapManager;
import fr.metabohub.peakforest.services.maps.MapManagerManagementService;

@Component
public class MetExploreRequestJob {

//	{ "orgaName": "Arabidopsis thaliana", "strategy": "max", "defaultDisplay": true },
//	{ "orgaName": "Escherichia coli", "strategy": "max", "defaultDisplay": true },
//	{ "orgaName": "Homo sapiens", "strategy": "source", "source": "Recon2", "defaultDisplay": true },
//	{ "orgaName": "Homo sapiens", "strategy": "source", "source": "Kegg", "defaultDisplay": false },
//	{ "orgaName": "Homo sapiens", "strategy": "source", "source": "BioCyc", "defaultDisplay": false },
//	{ "orgaName": "Mus musculus", "strategy": "max", "defaultDisplay": true },
//	{ "orgaName": "PlantCyc", "strategy": "max", "defaultDisplay": false },
//	{ "orgaName": "Rattus Norvegicus", "strategy": "max", "defaultDisplay": false },
//	{ "orgaName": "Saccharomyces cerevisiae", "strategy": "max", "defaultDisplay": false }

	public static final Map<String, Boolean> biosources_to_process_and_display = new HashMap<String, Boolean>() {
		private static final long serialVersionUID = 1L;
		{
			// biosourceID, displayByDefault
			put("2981", Boolean.TRUE);// Arabidopsis thaliana
			// put("", Boolean.TRUE);// Escherichia coli
			put("4324", Boolean.TRUE);// Homo sapiens (Recon 2.4)
			put("2903", Boolean.FALSE);// Homo sapiens (Kegg)
			// put("", Boolean.FALSE);// Homo sapiens (BioCyc)
			put("2904", Boolean.TRUE);// Mus musculus
			// put("", Boolean.FALSE);// PlantCyc
			put("2929", Boolean.FALSE);// Rattus Norvegicus
			// put("", Boolean.FALSE);// Saccharomyces cerevisiae
		}
	};

	private static boolean isMappingJobRuning = Boolean.FALSE;

	/**
	 * Update the PeakForest chemical library mapping on MetExplore's biosources to
	 * get a coverage. Launch {@link #launchUpdateMappingData} method that init
	 * coverage computing then get and map results.
	 * 
	 * @throws Exception random webservice exception
	 */
	// run each 7 day / sleep between
	@Scheduled(fixedDelay = 604800000)
	public static void updateMappingData() throws Exception {
		// check if process already locked
		if (isMappingJobRuning) {
			return;
		}
		// lock the process
		isMappingJobRuning = Boolean.TRUE;
		// update mapping
		launchUpdateMappingData();
		// unlock the process
		isMappingJobRuning = Boolean.FALSE;
	}

	/**
	 * Launch a peakforest mapping
	 * 
	 * @throws Exception
	 */
	public static void launchUpdateMappingData() throws Exception {
		// check if the option is activated
		final boolean useMEWebService = Boolean.parseBoolean(PeakForestUtils.getBundleConfElement("metexplore.ws.use"));
		if (!useMEWebService) {
			return;
		}
		// LOG
		SpectralDatabaseLogger.log("cron", "start launch update mapping [metexplore-chemical-lib-mapping-ws]",
				SpectralDatabaseLogger.LOG_INFO);
		// I - call WS
		// I.A - init ws data
		final String token = PeakForestUtils.getBundleConfElement("metexplore.ws.token");
		final String pforestRestV2url = PeakForestUtils.getBundleConfElement("metexplore.ws.pfURL");
		// I.B - call ws and wait responce
		final List<MetExStatsPForest> listCoverageMapping = MetExploreCoverageStatMapper
				.computeCustomCoverage(pforestRestV2url, token);
		// II - map results in database
		final MapManager newMetExploreCoverageMapping = new MapManager(MapManager.MAP_METEXPLORE);
		for (final MetExStatsPForest coverageMapping : listCoverageMapping) {
			// check if process
			final String biosourceId = coverageMapping.getIdBioSource();
			if (biosources_to_process_and_display.containsKey(biosourceId)) {
				// next
				newMetExploreCoverageMapping.addMapEntities(//
						getMapEntity(//
								coverageMapping, //
								newMetExploreCoverageMapping, //
								biosources_to_process_and_display.get(biosourceId)//
						)//
				);
			}
		}
		// III - update database
		// III.A - remove
		if (MapManagerManagementService.exists(MapManager.MAP_METEXPLORE)) {
			MapManagerManagementService.delete(MapManager.MAP_METEXPLORE);
		}
		// add to DB
		// III.B - add
		MapManagerManagementService.create(newMetExploreCoverageMapping);
		// end
		SpectralDatabaseLogger.log("cron", "end launch update mapping [metexplore-chemical-lib-mapping-ws]",
				SpectralDatabaseLogger.LOG_INFO);
	}

	/**
	 * Create and return a {@link MapEntity} object with the data send in
	 * parametersF
	 * 
	 * @param coverage         the coverage object to map
	 * @param mapManagerSource the parent mapper manager
	 * @param displayDefault   true to display this entity by default, false
	 *                         otherwise
	 * @return the mapped entity
	 */
	private static MapEntity getMapEntity(//
			final MetExStatsPForest coverage, //
			final MapManager mapManagerSource, //
			final boolean displayDefault//
	) {
		final MapEntity mapEntity = new MapEntity(mapManagerSource);
		// display
		mapEntity.setDisplayDefault(displayDefault);
		// all data
		try {
			mapEntity.setOrganism(coverage.getNameOrganism());
			mapEntity.setBiosource(coverage.getNameBioSource());
			mapEntity.setBiosourceId(coverage.getIdBioSource());
			mapEntity.setNbMetabolitesMappedFromPForestInBiosource(Long.parseLong(coverage.getNbMapped()));
			mapEntity.setNbMetabolitesWithInchikeyInBiosource(Long.parseLong(coverage.getNbMetaboliteWithInchikey()));
			mapEntity.setNbMetabolitesInBiosource(Long.parseLong(coverage.getNbMetabolite()));
			mapEntity.setCoverage(Double.parseDouble(coverage.getCover()));
		} catch (final NumberFormatException e) {
		}
		return mapEntity;
	}

	/**
	 * Get all MetExplore biosources with pathways inchikeys. Store this list so it
	 * can be used later by MetExploreViz tools.
	 * 
	 * @throws Exception random generic exception
	 */
	// each 1 and 15 of each months
	@Scheduled(cron = "0 0 0 1,15 * *")
	public static void updateMetExoloreBiosourcesList() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update metexplore-networks-list ", SpectralDatabaseLogger.LOG_INFO);
		// init request
		final String fileNameAndPath = PeakForestUtils.getBundleConfElement("json.metExploreBiosourcesList");
		final String filePrefix = PeakForestUtils.getBundleConfElement("json.folder");
		final String filePathAndName = filePrefix + File.separator + fileNameAndPath;
		// I - call WS
		final MetExploreClient client = new MetExploreClient();
		final List<MetExBiosource> biosources = client.getBiosources(Boolean.TRUE, Boolean.TRUE);
		final ObjectMapper mapper = new ObjectMapper();
		final String ret = mapper.writeValueAsString(biosources);
		final FileWriter file = new FileWriter(filePathAndName);
		try {
			file.write(ret);
		} catch (final IOException e) {
			e.printStackTrace();
		} finally {
			file.flush();
			file.close();
		}
		SpectralDatabaseLogger.log("cron", "end update metexplore-networks-list ", SpectralDatabaseLogger.LOG_INFO);
	}
}
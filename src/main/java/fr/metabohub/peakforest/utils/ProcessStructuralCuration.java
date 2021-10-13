package fr.metabohub.peakforest.utils;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.compound.CompoundDataCurationManagmentService;

/**
 * @author Nils Paulhe
 *
 */
@Component
public class ProcessStructuralCuration {

	// private static final SimpleDateFormat dateFormat = new SimpleDateFormat("YYYY-MM-DD HH:mm:ss");

	// each Saturdays 8 AM
	/**
	 * Check X structures using Cactus webservice and OpenBabel
	 * 
	 * @throws Exception
	 */
	@Scheduled(cron = "0 0 8 ? * SAT")
	public static void fetchMoreStructures() throws Exception {
		SpectralDatabaseLogger.log("cron", "start check compound structures ",
				SpectralDatabaseLogger.LOG_INFO);

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		int maxCactusService = Integer.parseInt(Utils.getBundleConfElement("cactus.maxCactusQuery"));

		CompoundDataCurationManagmentService.curateStructure(maxCactusService, dbName, username, password);

		SpectralDatabaseLogger.log("cron", "end check compound structures ", SpectralDatabaseLogger.LOG_INFO);
	}

}
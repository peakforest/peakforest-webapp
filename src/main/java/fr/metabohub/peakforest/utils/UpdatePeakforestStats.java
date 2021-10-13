package fr.metabohub.peakforest.utils;

import java.io.File;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.StatisticsService;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;

@Component
public class UpdatePeakforestStats {

	// private static final SimpleDateFormat dateFormat = new SimpleDateFormat("YYYY-MM-DD HH:mm:ss");

	// each Mondays 3 AM
	@Scheduled(fixedRate = 3600000)
	public static void updateStats() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update peakforest stats ", SpectralDatabaseLogger.LOG_INFO);

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		String filePrefix = Utils.getBundleConfElement("json.folder");
		String fileNameAndPath = Utils.getBundleConfElement("json.peakForestStatistics");

		// update json
		StatisticsService.generateJson(filePrefix + File.separator + fileNameAndPath, dbName, username,
				password);

		SpectralDatabaseLogger.log("cron", "end update peakforest stats ", SpectralDatabaseLogger.LOG_INFO);
	}

}
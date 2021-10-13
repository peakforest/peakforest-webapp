package fr.metabohub.peakforest.utils;

import java.io.File;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.StatisticsService;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.PeakForestUtils;

@Component
public class UpdatePeakforestStats {

	// private static final SimpleDateFormat dateFormat = new
	// SimpleDateFormat("YYYY-MM-DD HH:mm:ss");

	// each Mondays 3 AM
	@Scheduled(fixedRate = 3600000)
	public static void updateStats() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update peakforest stats ", SpectralDatabaseLogger.LOG_INFO);

		String filePrefix = PeakForestUtils.getBundleConfElement("json.folder");
		String fileNameAndPath = PeakForestUtils.getBundleConfElement("json.peakForestStatistics");

		// update json
		StatisticsService.generateJson(filePrefix + File.separator + fileNameAndPath);

		SpectralDatabaseLogger.log("cron", "end update peakforest stats ", SpectralDatabaseLogger.LOG_INFO);
	}

}
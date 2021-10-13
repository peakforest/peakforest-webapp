package fr.metabohub.peakforest.utils;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.compound.ComputeCompoundsBioSmValueService;

@Component
public class ProcessBioSMvalues {

	// private static final SimpleDateFormat dateFormat = new
	// SimpleDateFormat("YYYY-MM-DD HH:mm:ss");

	// each Saturdays 5 AM
	@Scheduled(cron = "0 0 5 ? * SAT")
	public static void fetchMoreValues() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update bioSM ", SpectralDatabaseLogger.LOG_INFO);
		// init request
		final int maxBioSMservice = Integer.parseInt(PeakForestUtils.getBundleConfElement("bioSM.maxBioSMservice"));
		ComputeCompoundsBioSmValueService.fetchBioSM(maxBioSMservice);
		SpectralDatabaseLogger.log("cron", "end update bioSM ", SpectralDatabaseLogger.LOG_INFO);
	}

}
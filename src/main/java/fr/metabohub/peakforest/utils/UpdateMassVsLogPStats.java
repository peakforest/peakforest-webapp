package fr.metabohub.peakforest.utils;

import java.io.File;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.compound.LogPRetriever;
import fr.metabohub.peakforest.services.compound.LogPWebServiceCaller;
import fr.metabohub.peakforest.services.compound.MassVsLogPJsonGeneratorService;

@Component
public class UpdateMassVsLogPStats {

	// private static final SimpleDateFormat dateFormat = new
	// SimpleDateFormat("YYYY-MM-DD HH:mm:ss");

	// each Saturdays 3 AM
	@Scheduled(cron = "0 0 3 ? * SAT")
	public static void updateMassVsLogPstats() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update mass-vs-logp ", SpectralDatabaseLogger.LOG_INFO);
		// init request
		final String fileNameAndPath = PeakForestUtils.getBundleConfElement("json.massVsLogP");
		final boolean useAlogPSWebServices = Boolean
				.parseBoolean(PeakForestUtils.getBundleConfElement("useAlogPSWebService"));
		final int maxDataSubmitToALogPS = Integer.parseInt(PeakForestUtils.getBundleConfElement("maxAlogPSWebService"));
		final int maxDataSubmitToOBabel = Integer
				.parseInt(PeakForestUtils.getBundleConfElement("maxObabelLogPCompute"));
		// I - call WS
		if (useAlogPSWebServices) {
			LogPWebServiceCaller.fetchLogP(maxDataSubmitToALogPS);
		} else {
			LogPRetriever.fetchLogP(maxDataSubmitToOBabel, null, null, null);
		}
		// II - update json
		// read json data - get path
		final String filePrefix = PeakForestUtils.getBundleConfElement("json.folder");
		MassVsLogPJsonGeneratorService.generateJson(filePrefix + File.separator + fileNameAndPath, null, null, null);
		SpectralDatabaseLogger.log("cron", "end update mass-vs-logp ", SpectralDatabaseLogger.LOG_INFO);
	}

}
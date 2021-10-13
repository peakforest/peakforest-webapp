package fr.metabohub.peakforest.utils;

import java.io.File;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.compound.LogPRetriever;
import fr.metabohub.peakforest.services.compound.LogPWebServiceCaller;
import fr.metabohub.peakforest.services.compound.MassVsLogPJsonGeneratorService;

@Component
public class UpdateMassVsLogPStats {

	// private static final SimpleDateFormat dateFormat = new SimpleDateFormat("YYYY-MM-DD HH:mm:ss");

	// each Saturdays 3 AM
	@Scheduled(cron = "0 0 3 ? * SAT")
	public static void updateMassVsLogPstats() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update mass-vs-logp ", SpectralDatabaseLogger.LOG_INFO);

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		String fileNameAndPath = Utils.getBundleConfElement("json.massVsLogP");
		boolean useAlogPSWebServices = Boolean
				.parseBoolean(Utils.getBundleConfElement("useAlogPSWebService"));
		int maxDataSubmitToALogPS = Integer.parseInt(Utils.getBundleConfElement("maxAlogPSWebService"));
		int maxDataSubmitToOBabel = Integer.parseInt(Utils.getBundleConfElement("maxObabelLogPCompute"));

		// I - call WS
		// useAlogPSWebService
		if (useAlogPSWebServices)
			LogPWebServiceCaller.fetchLogP(maxDataSubmitToALogPS, dbName, username, password);
		else
			LogPRetriever.fetchLogP(maxDataSubmitToOBabel, dbName, username, password);

		// II - update json
		// read json data - get path
		String filePrefix = Utils.getBundleConfElement("json.folder");

		MassVsLogPJsonGeneratorService.generateJson(filePrefix + File.separator + fileNameAndPath, dbName,
				username, password);

		SpectralDatabaseLogger.log("cron", "end update mass-vs-logp ", SpectralDatabaseLogger.LOG_INFO);
	}

}
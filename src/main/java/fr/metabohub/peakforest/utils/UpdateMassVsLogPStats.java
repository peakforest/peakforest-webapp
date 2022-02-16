package fr.metabohub.peakforest.utils;

import java.io.File;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import fr.metabohub.peakforest.services.compound.LogPComputingService;
import fr.metabohub.peakforest.services.compound.LogPComputingService.ComputingTool;
import fr.metabohub.peakforest.services.compound.MassVsLogPJsonGeneratorService;

@Component
public class UpdateMassVsLogPStats {

	// each Saturdays 3 AM
	@Scheduled(cron = "0 0 3 ? * SAT")
	public static void updateMassVsLogPstats() throws Exception {
		SpectralDatabaseLogger.log("cron", "start update mass-vs-logp ", SpectralDatabaseLogger.LOG_INFO);
		// read properties
		final String toolRawStr = PeakForestUtils.getBundleConfElement("config.logp.computingTool");
		final ComputingTool toolStd = ComputingTool.fromValue(toolRawStr);
		final int maxToLaunch = Integer.parseInt(PeakForestUtils.getBundleConfElement("config.logp.maxLaunch"));
		// run computing
		LogPComputingService.runComputingBatch(toolStd, maxToLaunch);
		// note: if all LogP computing methods are disabled, we not not launch a batch
		// of computing requests
		// update json
		final String fileNameAndPath = PeakForestUtils.getBundleConfElement("json.massVsLogP");
		final String filePrefix = PeakForestUtils.getBundleConfElement("json.folder");
		MassVsLogPJsonGeneratorService.generateJson(filePrefix + File.separator + fileNameAndPath);
		SpectralDatabaseLogger.log("cron", "end update mass-vs-logp ", SpectralDatabaseLogger.LOG_INFO);
	}

}
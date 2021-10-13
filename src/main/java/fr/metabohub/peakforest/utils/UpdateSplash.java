package fr.metabohub.peakforest.utils;

import java.util.ArrayList;
import java.util.List;

import fr.metabohub.peakforest.model.spectrum.FragmentationLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.services.spectrum.FragmentationLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;

public class UpdateSplash {

	public static void updateStats(boolean force) throws Exception {
		SpectralDatabaseLogger.log("backoffice", "start update splash, opt force=" + force,
				SpectralDatabaseLogger.LOG_INFO);

		// init request
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		List<Long> idFullScanLCMS = new ArrayList<>();
		List<Long> idFragmentationLCMS = new ArrayList<>();

		if (force) {
			// LCMS fullscan
			for (FullScanLCSpectrum s : FullScanLCSpectrumManagementService.readAll(dbName, username,
					password)) {
				idFullScanLCMS.add(s.getId());
			}
			// LCMS frag.
			for (FragmentationLCSpectrum s : FragmentationLCSpectrumManagementService.readAll(dbName,
					username, password)) {
				idFullScanLCMS.add(s.getId());
			}
			// TODO NMR 1D
			// TODO NMR 2D
			// TODO gcms
			// ...
		} else {
			idFullScanLCMS = FullScanLCSpectrumManagementService.getIDs(null, dbName, username, password);
			idFragmentationLCMS = FragmentationLCSpectrumManagementService.getIDs(null, dbName, username,
					password);
		}

		// compute
		FullScanLCSpectrumManagementService.computeSplash(idFullScanLCMS, force, dbName, username, password);
		FragmentationLCSpectrumManagementService.computeSplash(idFragmentationLCMS, force, dbName, username,
				password);

		SpectralDatabaseLogger.log("backoffice", "end update splash", SpectralDatabaseLogger.LOG_INFO);
	}

}
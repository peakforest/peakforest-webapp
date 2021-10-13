package fr.metabohub.peakforest.utils;

import java.util.ArrayList;
import java.util.List;

import fr.metabohub.peakforest.dao.spectrum.FragmentationLCSpectrumDao;
import fr.metabohub.peakforest.dao.spectrum.FullScanLCSpectrumDao;
import fr.metabohub.peakforest.model.spectrum.FragmentationLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.services.spectrum.FragmentationLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;

public class UpdateSplash {

	public static void updateStats(boolean force) throws Exception {
		SpectralDatabaseLogger.log("backoffice", "start update splash, opt force=" + force,
				SpectralDatabaseLogger.LOG_INFO);
		// init request
		List<Long> idFullScanLCMS = new ArrayList<>();
		List<Long> idFragmentationLCMS = new ArrayList<>();
		if (force) {
			// LCMS fullscan
			for (FullScanLCSpectrum s : FullScanLCSpectrumManagementService.readAll()) {
				idFullScanLCMS.add(s.getId());
			}
			// LCMS frag.
			for (FragmentationLCSpectrum s : FragmentationLCSpectrumManagementService.readAll()) {
				idFullScanLCMS.add(s.getId());
			}
			// TODO NMR 1D
			// TODO NMR 2D
			// TODO gcms
			// ...
		} else {
			idFullScanLCMS = FullScanLCSpectrumDao.getIDs(null);
			idFragmentationLCMS = FragmentationLCSpectrumDao.getIDs(null);
		}
		// compute
		FullScanLCSpectrumDao.computeSplash(idFullScanLCMS, force);
		FragmentationLCSpectrumDao.computeSplash(idFragmentationLCMS, force);

		SpectralDatabaseLogger.log("backoffice", "end update splash", SpectralDatabaseLogger.LOG_INFO);
	}

}
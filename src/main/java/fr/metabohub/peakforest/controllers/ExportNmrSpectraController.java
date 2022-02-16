/**
 * 
 */
package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.spectrum.CompoundSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.NMRSpectrum;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.spectrum.NMR1DSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.NMR2DSpectrumManagementService;
import fr.metabohub.peakforest.utils.IOUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.spectralibraries.export.NmrMlExport;

@Controller
public class ExportNmrSpectraController {

	@Autowired
	protected MessageSource messageSource;

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-nmrml-export/{type}/{id}"// , //
//			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE
	)
	public @ResponseBody String spectrumICMSMassBankExport(//
			final HttpServletResponse response, //
			final @PathVariable String type, //
			final @PathVariable long id//
	) throws IOException {
		// init request
		String fileName = "";
		String fileContent = "";
		boolean success = Boolean.FALSE;
		try {
			// get spectrum from database
			NMRSpectrum spectrum = null;
			if ("nmr-1d".equalsIgnoreCase(type)) {
				spectrum = NMR1DSpectrumManagementService.read(id);
			} else if ("nmr-2d".equalsIgnoreCase(type)) {
				spectrum = NMR2DSpectrumManagementService.read(id);
			}
			// map cpds
			mapCompounds(spectrum);
			// file final name
			fileName = spectrum.getMassBankName();
			// init export data
			final String rawDataFolder = PeakForestUtils.getBundleConfElement("rawFile.nmr.folder") + //
					File.separator + //
					spectrum.getRawDataFolder();
			final File intputFile = new File(rawDataFolder);
			final File outFile = File.createTempFile("tmp_nmrml_", ".nmrML");
			outFile.delete();
			// call export
			success = NmrMlExport.export(intputFile, spectrum, outFile);
			if (success) {
				fileContent = IOUtils.readFile(outFile);
				outFile.delete();
			}
		} catch (final Exception e) {
			e.printStackTrace();
			throw new IOException("error");
		}
		// return
		if (success) {
			response.setContentType("application/force-download");
			response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".nmrML\"");
			return fileContent;
		} else {
			response.setContentType("application/text");
			return "[error] could not convert NMR raw file into nmrML format";
		}
	}

	private void mapCompounds(final CompoundSpectrum spectrum) {
		if (spectrum.getLabel() == FullScanLCSpectrum.SPECTRUM_LABEL_REFERENCE
				&& spectrum.getListOfCompounds().size() == 1) {
			final List<Compound> listRCC = new ArrayList<Compound>();
			final GenericCompound gc = GenericCompoundManagementService
					.read(spectrum.getListOfCompounds().get(0).getId());
			if (gc != null) {
				listRCC.add(gc);
			}
			final ChemicalCompound cc = ChemicalCompoundManagementService
					.read(spectrum.getListOfCompounds().get(0).getId());
			if (cc != null) {
				listRCC.add(cc);
			}
			spectrum.setListOfCompounds(listRCC);
		}
	}

}

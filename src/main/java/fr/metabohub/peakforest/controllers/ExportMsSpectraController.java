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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.model.compound.ChemicalCompound;
import fr.metabohub.peakforest.model.compound.Compound;
import fr.metabohub.peakforest.model.compound.GenericCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.model.spectrum.CompoundSpectrum;
import fr.metabohub.peakforest.model.spectrum.FullScanLCSpectrum;
import fr.metabohub.peakforest.model.spectrum.MassSpectrum;
import fr.metabohub.peakforest.model.spectrum.Spectrum;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.services.spectrum.FragmentationICSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FragmentationLCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanGCSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanICSpectrumManagementService;
import fr.metabohub.peakforest.services.spectrum.FullScanLCSpectrumManagementService;
import fr.metabohub.peakforest.utils.IOUtils;
import fr.metabohub.peakforest.utils.PeakForestUtils;
import fr.metabohub.spectralibraries.export.MgfExport;
import fr.metabohub.spectralibraries.export.MspExport;
import fr.metabohub.spectralibraries.export.MzMlExport;

@Controller
public class ExportMsSpectraController {

	@Autowired
	protected MessageSource messageSource;

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-mgf-export/{type}/{id}"// , //
//			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE
	)
	public @ResponseBody String spectrumMgfExport(//
			final HttpServletResponse response, //
			final @PathVariable String type, //
			final @PathVariable long id //
	) throws IOException {
		// init request
		String fileName = "";
		String fileContent = "";
		boolean success = Boolean.FALSE;
		try {
			// get spectrum from database
			MassSpectrum spectrum = null;
			// LCMS
			if ("lc-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanLCSpectrumManagementService.read(id);
			} else if ("lc-fragmentation".equalsIgnoreCase(type)) {
				spectrum = FragmentationLCSpectrumManagementService.read(id);
			}
			// GCMS
			else if ("gc-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanGCSpectrumManagementService.read(id);
			}
			// ICMS
			else if ("ic-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanICSpectrumManagementService.read(id);
			} else if ("ic-fragmentation".equalsIgnoreCase(type)) {
				spectrum = FragmentationICSpectrumManagementService.read(id);
			}
			// map cpds
			mapCompounds(spectrum);
			// file final name
			fileName = spectrum.getMassBankName();
			// pforest instance webapp url
			final String pforestInstanceUrl = PeakForestUtils.getBundleConfElement("peakforest.webapp.url");
			// init final file
			final File outFile = File.createTempFile("tmp_file_", ".mgf");
			outFile.delete();
			// call export
			success = MgfExport.export(pforestInstanceUrl, spectrum, outFile);
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
			response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".mgf\"");
			return fileContent;
		} else {
			response.setContentType("application/text");
			return "[error] could not convert/export Mass Spectrum into MGF format";
		}
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-msp-export/{type}/{id}"// , //
//			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE
	)
	public @ResponseBody String spectrumMspExport(//
			final HttpServletResponse response, //
			final @PathVariable String type, //
			final @PathVariable long id, //
			final @RequestParam("mode") String mode//
	) throws IOException {
		// init request
		String fileName = "";
		String fileContent = "";
		boolean success = Boolean.FALSE;
		final boolean isFull = "full".equalsIgnoreCase(mode);
		try {
			// get spectrum from database
			MassSpectrum spectrum = null;

			// LCMS
			if ("lc-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanLCSpectrumManagementService.read(id);
			} else if ("lc-fragmentation".equalsIgnoreCase(type)) {
				spectrum = FragmentationLCSpectrumManagementService.read(id);
			}
			// GCMS
			else if ("gc-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanGCSpectrumManagementService.read(id);
			}
			// ICMS
			else if ("ic-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanICSpectrumManagementService.read(id);
			} else if ("ic-fragmentation".equalsIgnoreCase(type)) {
				spectrum = FragmentationICSpectrumManagementService.read(id);
			}
			// map cpds
			mapCompounds(spectrum);
			// file final name
			fileName = spectrum.getMassBankName();
			// pforest instance webapp url
			final String pforestInstanceUrl = PeakForestUtils.getBundleConfElement("peakforest.webapp.url");
			// mol file content
			String molContent = null;
			boolean withAttributions = isFull ? Boolean.TRUE : Boolean.FALSE;
			if (isFull && //
					spectrum.getSample() == Spectrum.SPECTRUM_SAMPLE_SINGLE_CHEMICAL_COMPOUND//
					&& spectrum.getListOfCompounds().size() == 1 //
					&& spectrum.getListOfCompounds().get(0) instanceof StructureChemicalCompound//
			) {
				final String inchikey = ((StructureChemicalCompound) spectrum.getListOfCompounds().get(0))
						.getInChIKey();
				final String molFileRepPath = PeakForestUtils.getBundleConfElement("compoundMolFiles.folder");
				final File molFilePath = new File(molFileRepPath + File.separator + inchikey + ".mol");
				if (molFilePath.exists()) {
					molContent = IOUtils.readFile(molFilePath);
				}
			}
			// init final file
			final File outFile = File.createTempFile("tmp_file_", ".msp");
			outFile.delete();
			// call export
			success = MspExport.export(pforestInstanceUrl, spectrum, molContent, withAttributions, outFile);
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
			response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".msp\"");
			return fileContent;
		} else {
			response.setContentType("application/text");
			return "[error] could not convert/export Mass Spectrum into MSP format";
		}
	}

	@RequestMapping(//
			method = RequestMethod.GET, //
			value = "/spectrum-mzml-export/{type}/{id}"// , //
//			produces = MediaType.APPLICATION_OCTET_STREAM_VALUE
	)
	public @ResponseBody String spectrumMzMlExport(//
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
			MassSpectrum spectrum = null;

			// LCMS
			if ("lc-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanLCSpectrumManagementService.read(id);
			} else if ("lc-fragmentation".equalsIgnoreCase(type)) {
				spectrum = FragmentationLCSpectrumManagementService.read(id);
			}
			// GCMS
			else if ("gc-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanGCSpectrumManagementService.read(id);
			}
			// ICMS
			else if ("ic-fullscan".equalsIgnoreCase(type)) {
				spectrum = FullScanICSpectrumManagementService.read(id);
			} else if ("ic-fragmentation".equalsIgnoreCase(type)) {
				spectrum = FragmentationICSpectrumManagementService.read(id);
			}
			// map cpds
			mapCompounds(spectrum);
			// file final name
			fileName = spectrum.getMassBankName();
			// pforest instance webapp url
			final String pforestInstanceUrl = PeakForestUtils.getBundleConfElement("peakforest.webapp.url");
			// init final file
			final File outFile = File.createTempFile("tmp_file_", ".mzml");
			outFile.delete();
			// get pforest version
			final String buildVersion = PeakForestUtils.getBundleConfElement("build.version");
			// call export
			success = MzMlExport.export(pforestInstanceUrl, buildVersion, spectrum, outFile);
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
			response.setHeader("Content-disposition", "attachment; filename=\"" + fileName + ".mzml\"");
			return fileContent;
		} else {
			response.setContentType("application/text");
			return "[error] could not convert/export Mass Spectrum into mzML format";
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

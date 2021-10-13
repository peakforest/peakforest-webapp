package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.dao.metadata.AnalyticalMatrixMetadataDao;
import fr.metabohub.peakforest.dao.metadata.StandardizedMatrixMetadataDao;
import fr.metabohub.peakforest.model.metadata.AnalyticalMatrix;
import fr.metabohub.peakforest.model.metadata.StandardizedMatrix;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class OntologiesController {

	// ////////////////////////////////////////////////////////////////////////
	// ontologies

	@RequestMapping(value = "/list-ontologies", method = RequestMethod.GET)
	@ResponseBody
	public List<HashMap<String, Object>> getListOntologies() throws Exception {
		final List<HashMap<String, Object>> listClean = new ArrayList<>();
		for (final AnalyticalMatrix matrix : AnalyticalMatrixMetadataDao.readAll()) {
			final HashMap<String, Object> data = new HashMap<>();
			data.put("id", matrix.getId());
			data.put("key", matrix.getKey());
			data.put("text", matrix.getNaturalLanguage());
			data.put("html", matrix.getHtmlDisplay());
			data.put("isFav", matrix.isFavourite());
			data.put("countSpectra", matrix.getSpectraNumber());
			listClean.add(data);
		}
		return listClean;
	}

	@RequestMapping(value = "/list-std-matrix", method = RequestMethod.GET)
	@ResponseBody
	public List<HashMap<String, Object>> getListStdMatrix() throws Exception {
		final List<HashMap<String, Object>> listClean = new ArrayList<>();
		for (final StandardizedMatrix matrix : StandardizedMatrixMetadataDao.readAll()) {
			final HashMap<String, Object> data = new HashMap<>();
			data.put("id", matrix.getId());
			data.put("text", matrix.getNaturalLanguage());
			data.put("html", matrix.getHtmlDisplay());
			data.put("isFav", matrix.isFavourite());
			data.put("countSpectra", matrix.getSpectraNumber());
			listClean.add(data);
		}
		return listClean;
	}
}

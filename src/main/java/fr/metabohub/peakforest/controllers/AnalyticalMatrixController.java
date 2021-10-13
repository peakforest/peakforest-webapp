package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.model.metadata.AnalyticalMatrix;
import fr.metabohub.peakforest.services.metadata.AnalyticalMatrixManagementService;
import fr.metabohub.peakforest.utils.AnalyticalMatrixComparator;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
// @Configuration
// @EnableWebSecurity
// @EnableGlobalMethodSecurity(securedEnabled = true)
// @EnableGlobalMethodSecurity(prePostEnabled = true)
public class AnalyticalMatrixController {

	@RequestMapping(value = "/list-peakforest-ontologies", method = RequestMethod.GET)
	@ResponseBody
	public List<HashMap<String, Object>> getListOntologies(@RequestParam("filter") String filter)
			throws Exception {
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		List<AnalyticalMatrix> listRaw = new ArrayList<>();

		if (filter != null && filter.equalsIgnoreCase("top")) {
			listRaw = AnalyticalMatrixManagementService.listFavourtie(dbName, username, password);
		} else
			listRaw = AnalyticalMatrixManagementService.readAll(dbName, username, password);

		// sort
		Collections.sort(listRaw, new AnalyticalMatrixComparator());

		List<HashMap<String, Object>> listClean = new ArrayList<>();
		for (AnalyticalMatrix matrix : listRaw) {
			HashMap<String, Object> data = new HashMap<>();
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

}

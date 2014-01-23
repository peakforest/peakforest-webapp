package fr.metabohub.spectralDatabase.controllers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.spectralDatabaseAPI.model.AbstractDatasetObject;
import fr.metabohub.spectralDatabaseAPI.services.SearchService;
import fr.metabohub.spectralDatabaseAPI.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class ToolsController {

	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/search", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, params = "query")
	public @ResponseBody
	Object search(@RequestParam("query") String query) {
		// init
		Map<String, Object> searchResults = new HashMap<String, Object>();
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		// search local
		try {
			searchResults = SearchService.search(query, dbName, username, password);
			// prune
			searchResults.put("compounds",
					Utils.prune((List<AbstractDatasetObject>) searchResults.get("compounds")));
			// success
			searchResults.put("success", true);
		} catch (Exception e) {
			e.printStackTrace();
			searchResults.put("success", false);
			searchResults.put("error", "exception");
			searchResults.put("exceptionMessage", e.getMessage());
		}
		// TODO search via WS on other instance of spectral databases
		// return

		return searchResults;
	}

}

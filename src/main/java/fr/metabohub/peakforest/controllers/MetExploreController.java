package fr.metabohub.peakforest.controllers;

import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.externalbanks.rest.MetExploreClient;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class MetExploreController {

	/**
	 * Webservice forwarding
	 * 
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @param session
	 * @param biosourceID
	 * @return
	 */
	@RequestMapping(value = "/get-pathways", method = RequestMethod.GET)
	public @ResponseBody Object getPathways(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, HttpSession session, @RequestParam("biosource") Integer biosourceID,
			@RequestParam("inchikeys") List<String> inchikeys) {
		// check testa
		if (inchikeys != null && !inchikeys.isEmpty()) {
			MetExploreClient me = new MetExploreClient(
					MetExploreClient.METEXPLORE_GET_PATHWAYS_FROM_BIOSOURCE_AND_INCHIKEYS, biosourceID, null,
					inchikeys, false);
			return me.getPathways(true);
		} else {
			MetExploreClient me = new MetExploreClient(
					MetExploreClient.METEXPLORE_GET_PATHWAYS_FROM_BIOSOURCE, biosourceID, null, false);
			return me.getPathways(false);
		}
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @param session
	 * @param id
	 * @param pathways
	 * @return
	 */
	@RequestMapping(value = "/get-graph/{id}", method = RequestMethod.GET)
	public @ResponseBody Object getGraph(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, HttpSession session, @PathVariable int id,
			@RequestParam("pathways") List<Integer> pathways,
			@RequestParam("inchikeys") List<String> inchikeys) {
		if (inchikeys != null && !inchikeys.isEmpty()) {
			MetExploreClient me = new MetExploreClient(
					MetExploreClient.METEXPLORE_GET_GRAPH_FROM_BIOSOURCE_AND_PATHWAYS_AND_INCHIKEYS, id,
					pathways, inchikeys, false);
			return me.getGraph(true);
		} else {
			MetExploreClient me = new MetExploreClient(
					MetExploreClient.METEXPLORE_GET_GRAPH_FROM_BIOSOURCE_AND_PATHWAYS, id, pathways, false);
			return me.getGraph(false);
		}
	}
}

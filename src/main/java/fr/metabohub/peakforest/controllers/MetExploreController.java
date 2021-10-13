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

import fr.metabohub.externalbanks.mapper.metexplore.MetExGraph;
import fr.metabohub.externalbanks.mapper.metexplore.MetExPathway;
import fr.metabohub.externalbanks.rest.MetExploreClient;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class MetExploreController {

	/**
	 * Webservice forwarding fo MetExplore: list pathways
	 * 
	 * @param request     the request
	 * @param response    the response
	 * @param locale      the local
	 * @param model       the model
	 * @param session     the session
	 * @param biosourceID the biosource ID
	 * @param inchikeys   a list of InChIKeys
	 * @return a logical {@link MetExPathway} object
	 */
	@RequestMapping(value = "/get-pathways", method = RequestMethod.GET)
	public @ResponseBody Object getPathways(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, HttpSession session, @RequestParam("biosource") Integer biosourceID,
			@RequestParam("inchikeys") List<String> inchikeys) {
		// init
		if (inchikeys != null && !inchikeys.isEmpty()) {
			// TODO missing method right now
			///////////////////////
			// temporary return all pathways
			// init
			final MetExploreClient client = new MetExploreClient();
			// run
			final List<MetExPathway> pathways = client.listBiosourcePathways(biosourceID);
			// return pathways
			return pathways;
			///////////////////////
		} else {
			// init
			final MetExploreClient client = new MetExploreClient();
			// run
			final List<MetExPathway> pathways = client.listBiosourcePathways(biosourceID);
			// return pathways
			return pathways;
		}
	}

	/**
	 * Webservice forwarding fo MetExplore: get pathway fraph
	 * 
	 * @param request   the request
	 * @param response  the response
	 * @param locale    the local
	 * @param model     the model
	 * @param session   the session
	 * @param id        the biosource id
	 * @param pathways  a list of pathways
	 * @param inchikeys a list of InChIKeys
	 * @return a logical {@link MetExGraph} object
	 */
	@RequestMapping(value = "/get-graph/{id}", method = RequestMethod.GET)
	public @ResponseBody Object getGraph(HttpServletRequest request, HttpServletResponse response, Locale locale,
			Model model, HttpSession session, @PathVariable int id, @RequestParam("pathways") List<Integer> pathways,
			@RequestParam("inchikeys") List<String> inchikeys) {
		if (inchikeys != null && !inchikeys.isEmpty()) {
			// init
			final MetExploreClient client = new MetExploreClient();
			final MetExGraph graph = client.getGraphFromFromBiosourceAndPathwaysAndInChIKeys(id, inchikeys, pathways,
					Boolean.TRUE);
			// overwrite
			graph.setMappingName("PeakForest_MappingInChIKey");
			graph.setMappingTagetLabel("inchikey");
			// return
			return graph;
		} else {
			// init
			final MetExploreClient client = new MetExploreClient();
			final MetExGraph graph = client.getGraphFromFromBiosourceAndPathways(id, pathways);
			// return
			return graph;
		}
	}
}

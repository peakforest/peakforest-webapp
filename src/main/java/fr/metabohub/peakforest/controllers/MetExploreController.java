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

import fr.metabohub.externalbanks.mapper.metexplore.MetExBioData;
import fr.metabohub.externalbanks.mapper.metexplore.MetExViz;
import fr.metabohub.externalbanks.rest.MetExploreClient;
import fr.metabohub.externalbanks.rest.MetExploreClient.MetExploreBioData;

@Controller
public class MetExploreController {

	/**
	 * Webservice forwarding for MetExplore: list pathways
	 * 
	 * @param request     the request
	 * @param response    the response
	 * @param locale      the local
	 * @param model       the model
	 * @param session     the session
	 * @param biosourceID the biosource ID
	 * @param inchikeys   a list of InChIKeys
	 * @return a list of {@link MetExBioData} objects
	 */
	@RequestMapping(value = "/get-pathways", method = RequestMethod.GET)
	public @ResponseBody Object getPathways(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final HttpSession session, //
			final @RequestParam("biosource") Long biosourceID, //
			final @RequestParam("inchikeys") List<String> inchikeys) {
		// init
		final MetExploreClient client = new MetExploreClient();
		// get pathways
		if (inchikeys != null && !inchikeys.isEmpty()) {
			// TODO missing method right now; temporary return all pathways
			// run
			final List<MetExBioData> pathways = client.getBiosourceData(biosourceID, MetExploreBioData.PATHWAY);
			// return pathways
			return pathways;
			///////////////////////
		} else {
			// run
			final List<MetExBioData> pathways = client.getBiosourceData(biosourceID, MetExploreBioData.PATHWAY);
			// return pathways
			return pathways;
		}
	}

	/**
	 * Webservice forwarding fo MetExplore: get pathway fraph
	 * 
	 * @param request      the request
	 * @param response     the response
	 * @param locale       the local
	 * @param model        the model
	 * @param session      the session
	 * @param idBiousource the biosource id
	 * @param idsPathways  a list of pathways ids
	 * @param inchikeys    a list of InChIKeys
	 * @return a logical {@link MetExViz} object
	 */
	@RequestMapping(value = "/get-graph/{id}", method = RequestMethod.GET)
	public @ResponseBody Object getGraph(//
			final HttpServletRequest request, //
			final HttpServletResponse response, //
			final Locale locale, //
			final Model model, //
			final HttpSession session, //
			final @PathVariable("id") Long idBiousource, //
			final @RequestParam("pathways") List<Long> idsPathways, //
			final @RequestParam("inchikeys") List<String> inchikeys) {
		if (inchikeys != null && !inchikeys.isEmpty()) {
			// init
			final MetExploreClient client = new MetExploreClient();
			final MetExViz graph = client.getVizBiosourcePathways(//
					idBiousource, //
					idsPathways.toArray(new Long[idsPathways.size()])//
			);
			// overwrite
//			graph.setMappingName("PeakForest_MappingInChIKey");
//			graph.setMappingTagetLabel("inchikey");
			// return
			return graph;
		} else {
			// init
			final MetExploreClient client = new MetExploreClient();
			final MetExViz graph = client.getVizBiosourcePathways(//
					idBiousource, //
					idsPathways.toArray(new Long[idsPathways.size()])//
			);
			// return
			return graph;
		}
	}
}

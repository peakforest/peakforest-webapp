package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.model.maps.MapEntity;
import fr.metabohub.peakforest.services.maps.MapManagerManagementService;
import fr.metabohub.peakforest.utils.PeakForestManagerException;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class MapController {

	/**
	 * @param idSource
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/get-map/{idSource}", method = RequestMethod.GET)
	public @ResponseBody Object mapList(@PathVariable short idSource) throws PeakForestManagerException {

		// init data
		List<MapEntity> data = null;

		// load data
		try {
			// short mapID = Short.parseShort("" + idSource);
			data = MapManagerManagementService.read(idSource).getMapEntities();
		} catch (Exception e) {
			e.printStackTrace();
			return new ArrayList<MapEntity>();
		}

		// prune
		for (MapEntity map : data)
			map.setMapManagerSource(null);

		return data;
	}

}

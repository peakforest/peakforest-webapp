package fr.metabohub.peakforest.controllers;

import org.hibernate.HibernateException;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.services.StatisticsService;

@Controller
public class JsonController {

	/**
	 * Get / compute peakforest chemical statistics and return results on-the-fly
	 * 
	 * @return a json response
	 * @throws HibernateException database exception
	 */
	@RequestMapping(//
			value = "/json/pforest-statistics.json", //
			method = RequestMethod.GET, //
			produces = MediaType.APPLICATION_JSON_VALUE //
	)
	public @ResponseBody Object getPeakForestStats(//
	) throws HibernateException {
		return StatisticsService.getPeakForestStatsAsJson();
	}

}

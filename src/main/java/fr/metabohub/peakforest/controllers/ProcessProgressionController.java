package fr.metabohub.peakforest.controllers;

import java.io.IOException;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.services.ProcessProgressManager;

@Controller
public class ProcessProgressionController {

	@Autowired
	protected MessageSource messageSource;

	@RequestMapping(value = "/processProgression", method = RequestMethod.POST)
	public @ResponseBody Integer getProcessProgression(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @RequestParam(value = "requestID", required = true) String requestID,
			@RequestParam(value = "requestLabel", required = true) String requestLabel) throws IOException {
		Integer progression = new Integer(-1);

		String currentSessionId = requestID;// request.getSession().getId();
		// if the process is a XLS import (chemiotheque)
		if (requestLabel.equals(ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL)) {
			currentSessionId = ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL + currentSessionId;
		} else if (requestLabel.equals(ProcessProgressManager.XLSM_DUMP_SPECTRAL_TEMPLATE)) {
			currentSessionId = ProcessProgressManager.XLSM_DUMP_SPECTRAL_TEMPLATE + currentSessionId;
		} else if (requestLabel.equals(ProcessProgressManager.XLSX_IMPORT_CHEMICAL_LIB_LABEL)) {
			currentSessionId = ProcessProgressManager.XLSX_IMPORT_CHEMICAL_LIB_LABEL + currentSessionId;
		}
		// else if
		// (processProgressLabel.equals(ProcessProgressManager.XLSX_IMPORT_LABEL)) {
		// currentSessionId = ProcessProgressManager.XLSX_IMPORT_LABEL +
		// currentSessionId;
		// }

		// get the percentage progression
		try {
			progression = ProcessProgressManager.getInstance().getProcessProgress(currentSessionId);
		} catch (Exception e) {
			e.printStackTrace();
			progression = new Integer(-1);
		}

		return progression;
	}

}
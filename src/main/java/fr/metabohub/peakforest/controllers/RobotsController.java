package fr.metabohub.peakforest.controllers;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.utils.SimpleFileReader;

@Controller
public class RobotsController {

	@RequestMapping(value = "/robots.txt", method = RequestMethod.GET)
	@ResponseBody
	public String getRobots(HttpServletRequest request) throws IOException {
		// get file dir
		ClassLoader classLoader = getClass().getClassLoader();
		File file = new File(classLoader.getResource("server/robots.txt").getFile());
		// return file
		return SimpleFileReader.readFile(file.getAbsolutePath(), StandardCharsets.UTF_8);
	}

	@RequestMapping(value = "/humans.txt", method = RequestMethod.GET)
	@ResponseBody
	public String getHumans(HttpServletRequest request) throws IOException {
		// get file dir
		ClassLoader classLoader = getClass().getClassLoader();
		File file = new File(classLoader.getResource("server/humans.txt").getFile());
		// return file
		return SimpleFileReader.readFile(file.getAbsolutePath(), StandardCharsets.UTF_8);
	}
}
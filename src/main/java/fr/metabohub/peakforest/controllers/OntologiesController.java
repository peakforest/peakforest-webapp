package fr.metabohub.peakforest.controllers;

import java.io.BufferedReader;
import java.io.File;
import java.io.LineNumberReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
public class OntologiesController {

	/**
	 * @param query
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/ontologies-sources", method = RequestMethod.GET)
	public @ResponseBody Object sourcesOntologyList(@RequestParam("q") String query,
			HttpServletRequest request) {// throws PeakForestManagerException, IOException

		// ORIGINE FILE
		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + Utils.getBundleConfElement("ontologies.folder");
		String templateFileName = Utils.getBundleConfElement("ontologies.source.file");

		File sourceOntologyFile = new File(templateFileDir + File.separator + templateFileName);

		List<OntologyMapper> results = grepOntology(query, sourceOntologyFile);

		return results;
	}

	/**
	 * @param query
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/ontologies-types", method = RequestMethod.GET)
	public @ResponseBody Object typesOntologyList(@RequestParam("q") String query,
			HttpServletRequest request) {// throws PeakForestManagerException, IOException

		// ORIGINE FILE
		String appRoot = request.getSession().getServletContext().getRealPath("/");
		String templateFileDir = appRoot + Utils.getBundleConfElement("ontologies.folder");
		String templateFileName = Utils.getBundleConfElement("ontologies.type.file");

		File sourceOntologyFile = new File(templateFileDir + File.separator + templateFileName);

		List<OntologyMapper> results = grepOntology(query, sourceOntologyFile);

		return results;
	}

	/**
	 * @param query
	 * @param sourceOntologyFile
	 * @return
	 */
	private List<OntologyMapper> grepOntology(String query, File sourceOntologyFile) {
		List<OntologyMapper> results = new ArrayList<OntologyMapper>();

		Pattern regexp = Pattern.compile(query.toLowerCase());
		Matcher matcher = regexp.matcher("");

		Path path = Paths.get(sourceOntologyFile.getAbsolutePath());
		try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8);
				LineNumberReader lineReader = new LineNumberReader(reader);) {
			String line = null;
			while ((line = lineReader.readLine()) != null) {
				matcher.reset(line.toLowerCase()); // reset the input
				if (matcher.find()) {
					String[] dataLine = line.split("\\t");
					results.add(new OntologyMapper(Long.parseLong(dataLine[0]), dataLine[1]));
				}
			}
		} catch (Exception ex) {
			// ex.printStackTrace();
			// results.add("s");
		}
		return results;
	}

	/**
	 * Mapper for Ontologies data
	 * 
	 * @author Nils Paulhe
	 *
	 */
	public class OntologyMapper {
		long id;
		String text;

		public OntologyMapper(long id, String text) {
			this.id = id;
			this.text = text;
		}

		public long getId() {
			return id;
		}

		public void setId(long id) {
			this.id = id;
		}

		public String getText() {
			return text;
		}

		public void setText(String text) {
			this.text = text;
		}
	}
}

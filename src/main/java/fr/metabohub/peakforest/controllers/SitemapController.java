package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import eu.bitwalker.useragentutils.UserAgent;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.utils.SpectralDatabaseLogger;
import fr.metabohub.peakforest.utils.Utils;

@Controller
public class SitemapController {

	@RequestMapping(value = "/sitemap.xml", method = RequestMethod.GET)
	@ResponseBody
	public XmlUrlSet main(HttpServletRequest request) {
		XmlUrlSet xmlUrlSet = new XmlUrlSet();
		create(xmlUrlSet, "", XmlUrl.Priority.HIGH);
		create(xmlUrlSet, "/home", XmlUrl.Priority.HIGH);
		create(xmlUrlSet, "/home?page=tools", XmlUrl.Priority.HIGH);
		create(xmlUrlSet, "/home?page=peakmatching", XmlUrl.Priority.MEDIUM);
		create(xmlUrlSet, "/about-peakforest", XmlUrl.Priority.MEDIUM);

		// db connect
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String login = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");

		// for loop to generate all the links by querying against database
		List<StructureChemicalCompound> listOfStructCC = new ArrayList<StructureChemicalCompound>();
		try {
			listOfStructCC.addAll(ChemicalCompoundManagementService.readAll(dbName, login, password));
			listOfStructCC.addAll(GenericCompoundManagementService.readAll(dbName, login, password));
			for (StructureChemicalCompound scc : listOfStructCC)
				create(xmlUrlSet, "/cpd:" + scc.getInChIKey(), XmlUrl.Priority.MEDIUM);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// List<Spectrum> listOfSpectra = new ArrayList<Spectrum>();
		// try {
		// listOfSpectra.addAll(FullScanLCSpectrumManagementService.readAll(dbName, login, password));
		// listOfSpectra.addAll(NMRSpectrumManagementService.readAll(dbName, login, password));
		// for (Spectrum scc : listOfSpectra)
		// create(xmlUrlSet, "/cpd:" + scc.getId(), XmlUrl.Priority.MEDIUM);
		// } catch (Exception e) {
		// e.printStackTrace();
		// }

		// LOG
		UserAgent userAgent = UserAgent.parseUserAgentString(request.getHeader("User-Agent"));
		SpectralDatabaseLogger.log(request.getRemoteAddr() + " " + userAgent.getBrowser().getName() + " "
				+ userAgent.getBrowserVersion(), "SEARCH ENGINE BOT", SpectralDatabaseLogger.LOG_INFO);

		return xmlUrlSet;
	}

	private void create(XmlUrlSet xmlUrlSet, String link, XmlUrl.Priority priority) {
		xmlUrlSet.addUrl(new XmlUrl(Utils.getBundleConfElement("peakforest.url") + link, priority));
	}

}

@XmlAccessorType(value = XmlAccessType.NONE)
@XmlRootElement(name = "url")
final class XmlUrl {
	public enum Priority {
		HIGH("1.0"), MEDIUM("0.5");

		private String value;

		Priority(String value) {
			this.value = value;
		}

		public String getValue() {
			return value;
		}
	}

	@XmlElement
	private String loc;

	@XmlElement
	private String lastmod = new DateTime().toString(DateTimeFormat.forPattern("yyyy-MM-dd"));

	@XmlElement
	private String changefreq = "yearly";

	@XmlElement
	private String priority;

	public XmlUrl() {
	}

	public XmlUrl(String loc, Priority priority) {
		this.loc = loc;
		this.priority = priority.getValue();
	}

	public String getLoc() {
		return loc;
	}

	public String getPriority() {
		return priority;
	}

	public String getChangefreq() {
		return changefreq;
	}

	public String getLastmod() {
		return lastmod;
	}
}

@XmlAccessorType(value = XmlAccessType.NONE)
@XmlRootElement(name = "urlset", namespace = "http://www.sitemaps.org/schemas/sitemap/0.9")
final class XmlUrlSet {

	@XmlElements({ @XmlElement(name = "url", type = XmlUrl.class) })
	private Collection<XmlUrl> xmlUrls = new ArrayList<XmlUrl>();

	public void addUrl(XmlUrl xmlUrl) {
		xmlUrls.add(xmlUrl);
	}

	public Collection<XmlUrl> getXmlUrls() {
		return xmlUrls;
	}
}
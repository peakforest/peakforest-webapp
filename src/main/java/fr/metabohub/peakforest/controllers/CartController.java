package fr.metabohub.peakforest.controllers;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import fr.metabohub.peakforest.model.AbstractDatasetObject;
import fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound;
import fr.metabohub.peakforest.model.compound.StructureChemicalCompound;
import fr.metabohub.peakforest.services.compound.ChemicalCompoundManagementService;
import fr.metabohub.peakforest.services.compound.GenericCompoundManagementService;
import fr.metabohub.peakforest.utils.PeakForestManagerException;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
@Controller
// @Configuration
// @EnableWebSecurity
// @EnableGlobalMethodSecurity(securedEnabled = true)
// @EnableGlobalMethodSecurity(prePostEnabled = true)
public class CartController {

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param id
	 * @param model
	 * @param session
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/is-cpd-in-cart/{id}", method = RequestMethod.GET)
	public @ResponseBody boolean isCpdInCart(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable int id, Model model, HttpSession session)
			throws PeakForestManagerException {
		List<ReferenceChemicalCompound> cpds = getListRcc(session);
		// ReferenceChemicalCompound refCompound = getRefCompound(id);
		for (ReferenceChemicalCompound rcc : cpds) {
			if (id == rcc.getId())
				return true;
		}
		return false;
	}

	/**
	 * @param request
	 * @param response
	 * @param locale
	 * @param id
	 * @param model
	 * @param session
	 * @return
	 * @throws PeakForestManagerException
	 */
	@RequestMapping(value = "/add-cpd-in-cart/{id}", method = RequestMethod.POST)
	public @ResponseBody boolean addCpdInCart(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable int id, Model model, HttpSession session)
			throws PeakForestManagerException {
		if (isCpdInCart(request, response, locale, id, model, session)) {
			return false;
		}
		List<ReferenceChemicalCompound> cpds = getListRcc(session);
		ReferenceChemicalCompound refCompound = getRefCompound(id);
		if (refCompound != null)
			cpds.add(refCompound);
		session.setAttribute("cart-cpd", cpds);
		return true;
	}

	@RequestMapping(value = "/remove-cpd-from-cart/{id}", method = RequestMethod.POST)
	public @ResponseBody boolean removeCpdFromCart(HttpServletRequest request, HttpServletResponse response,
			Locale locale, @PathVariable int id, Model model, HttpSession session)
			throws PeakForestManagerException {
		if (!isCpdInCart(request, response, locale, id, model, session)) {
			return false;
		}
		List<ReferenceChemicalCompound> oldCpds = getListRcc(session);
		List<ReferenceChemicalCompound> newCpds = new ArrayList<>();
		for (ReferenceChemicalCompound rcc : oldCpds)
			if (rcc.getId() != id)
				newCpds.add(rcc);
		session.setAttribute("cart-cpd", newCpds);
		return true;
	}

	@RequestMapping(value = "/clear-cpd-in-cart", method = RequestMethod.POST)
	public @ResponseBody boolean clearCpdFromCart(HttpServletRequest request, HttpServletResponse response,
			Locale locale, Model model, HttpSession session) throws PeakForestManagerException {
		session.setAttribute("cart-cpd", null);
		session.removeAttribute("cart-cpd");
		return true;
	}

	@RequestMapping(value = "/get-cpd-in-cart.json", method = RequestMethod.GET)
	public @ResponseBody List<String> getCpdFromCartAsJson(HttpServletRequest request,
			HttpServletResponse response, Locale locale, Model model, HttpSession session)
			throws PeakForestManagerException {
		List<String> data = new ArrayList<>();
		for (ReferenceChemicalCompound rcc : getListRcc(session)) {
			if (rcc instanceof StructureChemicalCompound)
				data.add(((StructureChemicalCompound) rcc).getInChIKey());
		}
		return data;
	}

	@RequestMapping(value = "/get-cpd-from-cart", method = RequestMethod.GET)
	public @ResponseBody List<AbstractDatasetObject> getCpdFromCart(HttpServletRequest request,
			HttpServletResponse response, Locale locale, Model model, HttpSession session)
			throws PeakForestManagerException {
		List<AbstractDatasetObject> rccList = (new ArrayList<AbstractDatasetObject>());
		for (ReferenceChemicalCompound rcc : getListRcc(session))
			rccList.add((AbstractDatasetObject) rcc);
		return Utils.prune(rccList);
	}

	@RequestMapping(value = "/load-cpd-in-cart", method = RequestMethod.POST, headers = {
			"Content-type=application/json" })
	public @ResponseBody boolean loadCpdInCart(HttpServletRequest request, @RequestBody List<String> data,
			HttpServletResponse response, Locale locale, Model model, HttpSession session)
			throws PeakForestManagerException {
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		for (String inchikey : data) {
			ReferenceChemicalCompound refCompound = null;
			try {
				refCompound = ChemicalCompoundManagementService.readByInChIKey(inchikey, dbName, username,
						password);
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (refCompound == null)
				try {
					refCompound = GenericCompoundManagementService.readByInChIKey(inchikey, dbName, username,
							password);
				} catch (Exception e) {
					e.printStackTrace();
				}
			if (refCompound != null) {
				addCpdInCart(request, response, locale, (int) refCompound.getId(), model, session);
			}
		}
		return true;
	}

	/**
	 * @param session
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private List<ReferenceChemicalCompound> getListRcc(HttpSession session) {
		List<ReferenceChemicalCompound> cpds = new ArrayList<ReferenceChemicalCompound>();
		if (session.getAttribute("cart-cpd") != null && session.getAttribute("cart-cpd") instanceof List<?>) {
			cpds = (List<ReferenceChemicalCompound>) session.getAttribute("cart-cpd");
		}
		return cpds;
	}

	/**
	 * @param id
	 * @param refCompound
	 * @return
	 */
	private ReferenceChemicalCompound getRefCompound(int id) {
		String dbName = Utils.getBundleConfElement("hibernate.connection.database.dbName");
		String username = Utils.getBundleConfElement("hibernate.connection.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.database.password");
		ReferenceChemicalCompound refCompound = null;
		try {
			refCompound = ChemicalCompoundManagementService.read(id, dbName, username, password);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (refCompound == null)
			try {
				refCompound = GenericCompoundManagementService.read(id, dbName, username, password);
			} catch (Exception e) {
				e.printStackTrace();
			}
		return refCompound;
	}

}

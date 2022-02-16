<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>

<ul class="list-group">
	<c:if test="${not empty spectrum_mass_fullscan_lc}">
		<!-- fullscan LC -->
		<li class="list-group-item"> <spring:message code="module.spectra.tag.lcms" text="LC-MS" /> </li>
		<li class="list-group-item">
			<ul class="list-group">
				<c:forEach var="spectrum" items="${spectrum_mass_fullscan_lc}">
					<li class="list-group-item">
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
						/
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
							${fn:escapeXml((spectrum.getMassBankNameHTML()))}
						</a>
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:if>
	<c:if test="${not empty spectrum_mass_fragmt_lc}">
		<!-- fragmentation LC -->
		<li class="list-group-item"> <spring:message code="module.spectra.tag.msms" text="LC-MSMS" /> </li>
		<li class="list-group-item">
			<ul class="list-group">
				<c:forEach var="spectrum" items="${spectrum_mass_fragmt_lc}">
					<li class="list-group-item">
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
						/
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
							${fn:escapeXml((spectrum.getMassBankNameHTML()))}
						</a>
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:if>
	
	<!-- ICMS -->
	<c:if test="${not empty spectrum_mass_fullscan_ic}">
		<!-- fullscan LC -->
		<li class="list-group-item"> <spring:message code="module.spectra.tag.icms" text="IC-MS" /> </li>
		<li class="list-group-item">
			<ul class="list-group">
				<c:forEach var="spectrum" items="${spectrum_mass_fullscan_ic}">
					<li class="list-group-item">
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
						/
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
							${fn:escapeXml((spectrum.getMassBankNameHTML()))}
						</a>
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:if>
	
	<!-- IC-MSMS -->
	<c:if test="${not empty spectrum_mass_fragmt_ic}">
		<!-- fragmentation LC -->
		<li class="list-group-item"> <spring:message code="module.spectra.tag.icmsms" text="IC-MSMS" /> </li>
		<li class="list-group-item">
			<ul class="list-group">
				<c:forEach var="spectrum" items="${spectrum_mass_fragmt_ic}">
					<li class="list-group-item">
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
						/
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
							${fn:escapeXml((spectrum.getMassBankNameHTML()))}
						</a>
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:if>
	
	<c:if test="${not empty spectrum_nmr}">
		<!-- NMR -->
		<li class="list-group-item"> <spring:message code="module.spectra.tag.nmr" text="NMR" /> </li>
		<li class="list-group-item">
			<ul class="list-group">
				<c:forEach var="spectrum" items="${spectrum_nmr}">
					<li class="list-group-item">
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
						/
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
							${fn:escapeXml((spectrum.getMassBankNameHTML()))}
						</a>
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:if>
	<!-- GCMS -->
	<c:if test="${not empty spectrum_mass_fullscan_gc}">
		<li class="list-group-item"> <spring:message code="module.spectra.tag.gcms" text="GC-MS" /> </li>
		<li class="list-group-item">
			<ul class="list-group">
				<c:forEach var="spectrum" items="${spectrum_mass_fullscan_gc}">
					<li class="list-group-item">
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
						/
						<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
							${fn:escapeXml((spectrum.getMassBankNameHTML()))}
						</a>
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:if>
</ul>
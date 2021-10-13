<%@page import="java.util.Random"%>
<%@page import="org.springframework.security.core.context.SecurityContextHolder"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>
<c:if test="${editor}">
	<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>
</c:if>
	<div class="" style="">
		<div class="">
			<div id="entityBody" class=" ">
				<div class="te">
					<form class="form-horizontal" onsubmit="return false;">
						<fieldset>
							<!--  ++++++++++++++++++++++++++++ start spectrum card -->
							<div class="panel-group" >
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											${(spectrum_name)} &nbsp;&nbsp;&nbsp; <small>${(spectrum_pfID)}</small> 
											<span class="pull-right">
												<c:if test="${spectrum_type == 'lc-fullscan'}">
													<a href="spectrum-massbank-export/${spectrum_id}" target="_blank" ><i class="fa fa-file-text-o"></i></a>
												</c:if>
												<c:if test="${spectrum_type == 'lc-fragmentation'}">
													<a href="spectrum-msms-massbank-export/${spectrum_id}" target="_blank" ><i class="fa fa-file-text-o"></i></a>
												</c:if>
												<c:if test="${spectrum_type == 'gc-fullscan'}">
													<a href="spectrum-gcms-massbank-export/${spectrum_id}" target="_blank" ><i class="fa fa-file-text-o"></i></a>
												</c:if>
												<c:if test="${spectrum_type == 'ic-fullscan'}">
													<a href="spectrum-icms-massbank-export/${spectrum_id}" target="_blank" ><i class="fa fa-file-text-o"></i></a>
												</c:if>
												<c:if test="${spectrum_type == 'ic-fragmentation'}">
													<a href="spectrum-icmsms-massbank-export/${spectrum_id}" target="_blank" ><i class="fa fa-file-text-o"></i></a>
												</c:if>
												<a id="linkDumpSpectrum" href="#" ><i class="fa fa-file-excel-o"></i></a>
											</span>
										</h4>
									</div>
									<div id="cardSheet1" class="">
									
									<c:if test="${spectrum_type == 'lc-fullscan' || spectrum_type == 'lc-fragmentation' || spectrum_type == 'gc-fullscan' || spectrum_type == 'ic-fullscan' || spectrum_type == 'ic-fragmentation'}">
									<!--container-->
									<div id="containerMSspectrum<%=randomID %>"
										style="width: 100%; min-width: 650px; height: 500px; margin: 0 auto">
										loading MS spectra... <br />
										<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
											title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
									</div>
									</c:if>
									
									<c:if test="${spectrum_type == 'nmr-1d' || spectrum_type == 'nmr-2d'}">
										<c:if test="${not display_real_spectrum}">
											<c:choose>
												<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D' || spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
													<br /><br /><br /><br />
													&nbsp;&nbsp;&nbsp;&nbsp;
													<spring:message code="page.resource.commingSoon" text="this resource is comming soon." />
													<br /><br /><br /><br />
												</c:when>
												<c:otherwise>
													<!--container-->
													<div id="containerNMRspectrum<%=randomID %>"
														style="width: 100%; min-width: 650px; height: 500px; margin: 0 auto">
														loading NMR spectra... <br />
														<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
															title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
													</div>
												</c:otherwise>
											</c:choose>
										</c:if>
										<c:if test="${display_real_spectrum}">
											<!--nmrpro-->
											<div class="div_container_nmrpro_wrapper">
											  <div id="container_nmrpro<%=randomID %>" class="div_container_nmrpro">
											  	loading NMR spectra... <br />
												<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
													title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
											  </div>
											</div>
										</c:if>
									</c:if>
									
									<br>
									</div>
								</div>
<c:if test="${spectrum_type == 'gc-fullscan'}">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="page.spectrum.tag.gcDerivedCompound" text="GC-Derivative" /> <i class="fa fa-puzzle-piece"></i>
										</h4>
									</div>
									<div id="cardSheet2" class="">
			<table style="width:100%">					
				<tr>
					<td width="20%">
					<img src="image/${spectrum_derivative_type}/${spectrum_derivative_inchikey}" alt="${fn:escapeXml(spectrum_derivative_name)}">
					</td>
					<td width="80%">
					<ul class="list-group" style="max-width: 600px;">
						<li class="list-group-item">
							Derivative Name:&nbsp;
							<%-- when model ready, add: data-toggle="modal" data-target="#modalShowCompound" href="show-compound-modal/${spectrum_derivative_type}/${spectrum_derivative_id}" --%>
							<c:if test="${not empty spectrum_derivative_pubchem}">
								<a href="<spring:message 
									code="resources.banklink.pubchem" 
									text="http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=" />${spectrum_derivative_pubchem}" 
									target="_blank">${fn:escapeXml(spectrum_derivative_name)} | CID ${spectrum_derivative_pubchem}</a>
							</c:if>
							<c:if test="${empty spectrum_derivative_pubchem and not empty spectrum_derivative_inchikey}">
								<a href="<spring:message 
									code="resources.banklink.pubchem" 
									text="http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=" />${spectrum_derivative_inchikey}" 
									target="_blank">${fn:escapeXml(spectrum_derivative_name)}</a>
							</c:if>
							<c:if test="${empty spectrum_derivative_pubchem and empty spectrum_derivative_inchikey}">
								${fn:escapeXml(spectrum_derivative_name)}
							</c:if>
						</li>
						<li class="list-group-item">Derived Type: ${spectrum_derivatization_types}</li>
						<li class="list-group-item">Derivation Method: ${spectrum_sample_compound_derivation_method}</li>
						<li class="list-group-item">
							<div class="form-group input-group form-group-margin0">
								<span class="input-group-addon" style="">InChI of Derivative</span>
								<input
									id="spectrum_derivative_inchi"
								    type="text" 
									class="form-control clipboad-me"
									placeholder="${spectrum_derivative_inchi}"
									value="${spectrum_derivative_inchi}">
								<span class="input-group-btn">
									<button onclick="copyToClipboad('spectrum_derivative_inchi')" class="btn btn-primary" type="button" title="copy">
										<i class="fa fa-clipboard"></i>
									</button>
								</span>
							</div>
						<!-- </li> -->
						<!-- <li class="list-group-item"> -->
							<div class="form-group input-group form-group-margin0">
								<span class="input-group-addon" style="">InChIKey of Derivative</span>
								<input
									id="spectrum_derivative_inchikey"
								    type="text" 
									class="form-control clipboad-me"
									placeholder="${spectrum_derivative_inchikey}"
									value="${spectrum_derivative_inchikey}">
								<span class="input-group-btn">
									<button onclick="copyToClipboad('spectrum_derivative_inchikey')" class="btn btn-primary" type="button" title="copy">
										<i class="fa fa-clipboard"></i>
									</button>
								</span>
							</div>
						</li>
					</ul>
				</tr>
			</table>
									</div>
								</div>
</c:if>
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="page.spectrum.tag.metadata" text="Metadata" /> <i class="fa fa-lightbulb-o"></i>
										</h4>
									</div>
									<div id="cardSheet2" class="">
<ul class="nav nav-tabs" style="margin-bottom: 15px;">
	<li class="active"><a href="#analytical_sample" data-toggle="tab"><i class="fa fa fa-flask"></i> <spring:message code="page.spectrum.tag.analyticalSample" text="Analytical Sample" /></a></li>
	<!-- MS ONLY -->
	<c:if test="${spectrum_type == 'lc-fullscan' || spectrum_type == 'lc-fragmentation' || spectrum_type == 'gc-fullscan' || spectrum_type == 'ic-fullscan' || spectrum_type == 'ic-fragmentation'}">
	<li><a href="#chromatography" data-toggle="tab"><i class="fa fa-area-chart"></i> <spring:message code="page.spectrum.tag.chromatography" text="Chromatography" /></a></li>
	<li><a href="#MS_analyzer" data-toggle="tab"><i class="fa fa-tachometer"></i> <spring:message code="page.spectrum.tag.massAnalyze" text="Mass Analyzer" /></a></li>
	<li><a href="#MS_peaks" data-toggle="tab"><i class="fa fa-bar-chart"></i> <spring:message code="page.spectrum.tag.peakList" text="Peak List" /></a></li>
	</c:if>
	<!-- NMR ONLY -->
	<c:if test="${spectrum_type == 'nmr-1d' || spectrum_type == 'nmr-2d'}">
	<li><a href="#NMR_analyzer" data-toggle="tab"><i class="fa fa-tachometer"></i> <spring:message code="page.spectrum.tag.nmrAnalyzer" text="NMR Analyzer" /></a></li>
	<li><a href="#NMR_peaks" onclick="try{refreshJSmol();}catch(e){}" data-toggle="tab"><i class="fa fa-bar-chart"></i> <spring:message code="page.spectrum.tag.peakListnmr" text="Peak List" /></a></li>
	</c:if>
	<!-- all -->
	<li><a href="#other_metadata" data-toggle="tab"><i class="fa fa-info-circle"></i> <spring:message code="page.spectrum.tag.other" text="Other" /></a></li>
	<li><a href="#related_spectra" data-toggle="tab"><i class="fa fa fa-sitemap"></i> <spring:message code="page.spectrum.tag.relatedSpectra" text="Related Spectra" /></a></li>
	<!-- more -->
	<li><a href="#more_metadata" data-toggle="tab"><i class="fa fa-plus-circle"></i> <spring:message code="page.spectrum.tag.more" text="More" /></a></li>
</ul>
<div id="div-metadata" class="tab-content">
	<div class="tab-pane fade active in" id="analytical_sample">
		<div class="panel panel-default">
<c:choose>
	<c:when test="${spectrum_sample_type == 'single-cpd'}">
			<div class="panel-heading">	
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelSingle" text="Sample type: Single Chemical Compound" /></h3>
			</div>
			<div class="panel-body">
<!-- classic data -->
<table style="width:100%">
	<tr> 
		<td width="20%">
		<img src="image/${spectrum_sample_compound_type}/${spectrum_sample_compound_inchikey}" alt="${fn:escapeXml(spectrum_sample_compound_name)}">
		</td>
		<td width="40%">
<ul class="list-group" style="max-width: 600px;">
	<li class="list-group-item">
		<c:if test="${spectrum_type == 'gc-fullscan'}">Original </c:if>Compound Name:&nbsp;
		<a href="show-compound-modal/${spectrum_sample_compound_type}/${spectrum_sample_compound_id}" data-toggle="modal" data-target="#modalShowCompound">${fn:escapeXml(spectrum_sample_compound_name)}</a>
	</li>
	<c:if test="${spectrum_sample_compound_has_concentration}">
		<c:if test="${spectrum_type != 'gc-fullscan'}">
		<li class="list-group-item">Concentration: ${spectrum_sample_compound_concentration} mmol/L</li>
		</c:if>
		<c:if test="${spectrum_type == 'gc-fullscan'}">
		<li class="list-group-item">Quantity: ${spectrum_sample_compound_concentration} nmol</li>
		</c:if>
	</c:if>
	<c:if test="${spectrum_type == 'lc-fullscan' || spectrum_type == 'lc-fragmentation'}">
	<li class="list-group-item">Solvent: ${spectrum_sample_compound_liquid_solvent}</li>
	</c:if>
	<c:if test="${spectrum_type == 'gc-fullscan'}">
	<li class="list-group-item">Solvent: ${spectrum_sample_compound_gas_solvent}</li>
	</c:if>
	<li class="list-group-item">InChI: ${spectrum_sample_compound_inchi}</li>
	<li class="list-group-item">InChIKey: ${spectrum_sample_compound_inchikey}</li>
</ul>
		</td>
		<td width="40%">
<ul class="list-group" style="max-width: 600px;">
	<li class="list-group-item">Formula: <span class="cpdFormula">${spectrum_sample_compound_formula}</span></li>
<%-- 	<c:if test="${spectrum_type == 'lc-fullscan' || spectrum_type == 'lc-fragmentation'}"> --%>
	<li class="list-group-item">Monoisotopic Mass: ${spectrum_sample_compound_exact_mass} Da</li>
	<li class="list-group-item">Average Mass: ${spectrum_sample_compound_mol_weight} Da</li>
<%-- 	</c:if> --%>
</ul>
		</td>
	</tr>
</table>
			</div>
	</c:when>
	<c:when test="${spectrum_sample_type == 'mix-cpd'}">	
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelMix" text="Sample type: Mix of Chemical Compounds" /></h3>
			</div>
			<div class="panel-body">
				<table  style="width:100%">
					<tr>
						<td width="" style="vertical-align: top; padding-top: 30px;">
							<ul style="max-width:50%">
								<li class="list-group-item">Solvent: ${select_spectrum_sample_compound_liquid_solvent}</li>
							</ul>
						</td>
						<td style="max-width:50%">
							<c:if test="${spectrum_has_main_compound}">
								All peaks are related to one compound: <a href="show-compound-modal/${spectrum_main_compound.getTypeString()}/${spectrum_main_compound.getId()}" data-toggle="modal" data-target="#modalShowCompound">${fn:escapeXml(spectrum_main_compound.getMainName())}</a>
								<img class="compoundSVG" src="image/${spectrum_main_compound.getTypeString()}/${spectrum_main_compound.getInChIKey()}" alt="${fn:escapeXml(spectrum_main_compound.getMainName())}">
								<br />
								<br />
							</c:if>
							<c:if test="${spectrum_sample_mix_display}">	
								<table class="table table-hover tablesorter tablesearch" style="max-width: 300px; display: table;">
									<thead>
										<tr>
											<th class="header " style="white-space: nowrap;"></th>
											<th class="header headerSortUp" style="white-space: nowrap;">Compound <i class="fa fa-sort"></i></th>
											<th class="header headerSortUp" style="white-space: nowrap;">Concentration (&micro;g/ml) <i class="fa fa-sort"></i></th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="compound" items="${spectrum_sample_mix_tab}">
										<tr>
											<td>
												<span class="avatar">
													<img class="compoundSVG" src="image/${compound.getTypeString()}/${compound.getInChIKey()}" alt="${fn:escapeXml(compound.getMainName())}">
												</span>
											</td>
											<td style="white-space: nowrap;">
												<a href="show-compound-modal/${compound.getTypeString()}/${compound.getId()}" data-toggle="modal" data-target="#modalShowCompound">${fn:escapeXml(compound.getMainName())}</a>
											</td>
											<td>${spectrum_sample_mix_data.getCompoundConcentration(compound.inChIKey)}</td>
										</tr>
										</c:forEach>
									</tbody>
								</table>
							</c:if>
						</td>
					</tr>
				</table>
			</div>
	</c:when>
	<c:when test="${spectrum_sample_type == 'std-matrix'}">	
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelStd" text="Sample type: Standardized Matrix" /></h3>
			</div>
			<div class="panel-body">
				${standardized_matrix.getHtmlDisplay()}
				<c:if test="${spectrum_has_main_compound}">
					<br />
					<br />
					All peaks are related to one compound: <a href="show-compound-modal/${spectrum_main_compound.getTypeString()}/${spectrum_main_compound.getId()}" data-toggle="modal" data-target="#modalShowCompound">${fn:escapeXml(spectrum_main_compound.getMainName())}</a>
					<img class="compoundSVG" src="image/${spectrum_main_compound.getTypeString()}/${spectrum_main_compound.getInChIKey()}" alt="${fn:escapeXml(spectrum_main_compound.getMainName())}">
				</c:if>
				<c:if test="${spectrum_sample_mix_display}">
					<br />
					<br />	
					<table class="table table-hover tablesorter tablesearch" style="max-width: 300px; display: table;">
						<thead>
							<tr>
								<th class="header " style="white-space: nowrap;"></th>
								<th class="header headerSortUp" style="white-space: nowrap;">Compound <i class="fa fa-sort"></i></th>
								<th class="header headerSortUp" style="white-space: nowrap;">Concentration (&micro;g/ml) <i class="fa fa-sort"></i></th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="compound" items="${spectrum_sample_mix_tab}">
							<tr>
								<td>
									<span class="avatar">    <img class="compoundSVG" src="image/${compound.getTypeString()}/${compound.getInChIKey()}" alt="gamma-aminobutyric acid">   </span>
								</td>
								<td style="white-space: nowrap;">
									<a href="show-compound-modal/${compound.getTypeString()}/${compound.getId()}" data-toggle="modal" data-target="#modalShowCompound">${fn:escapeXml(compound.getMainName())}</a>
								</td>
								<td>${spectrum_sample_mix_data.getCompoundConcentration(compound.inChIKey)}</td>
							</tr>
							</c:forEach>
						</tbody>
					</table>
				</c:if>
			</div>
	</c:when>
	<c:when test="${spectrum_sample_type == 'analytical-matrix'}">	
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelMatrix" text="Sample type: Analytical Matrix" /></h3>
			</div>
			<div class="panel-body">
				<% if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) { %>
					${analytical_matrix.getHtmlDisplay()}
				<% } else { %>
					${analytical_matrix.getNaturalLanguage()}
				<% }  %>
			</div>
	</c:when>
</c:choose>
<!-- nmr specific data -->
<c:if test="${spectrum_type == 'nmr-1d' || spectrum_type == 'nmr-2d'}">
			<div class="panel-heading">	
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelNMRtubePrep" text="NMR tube preparation" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">Solvent: ${spectrum_nmr_tube_prep.getNMRsolventAsString()}</li>
					<li class="list-group-item">Sample pH or sample apparent pH: ${spectrum_nmr_tube_prep.getPotentiaHydrogenii()}</li>
					<li class="list-group-item">Reference Chemical Shift Indicator: ${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())}</li>
<%-- 					<li class="list-group-item">Reference Chemical Shif Indicator (other): ${spectrum_sample_type}</li> --%>
					<li class="list-group-item">Reference Concentration (mmol/L): ${spectrum_nmr_tube_prep.getReferenceConcentration()}</li>
					<li class="list-group-item">Lock Substance: ${spectrum_nmr_tube_prep.getNMRlockSubstanceAsString()}</li>
					<li class="list-group-item">Lock Substance Concentration: ${spectrum_nmr_tube_prep.getLockSubstanceVolumicConcentration()} (volumic %)</li>
					<li class="list-group-item">Buffer Solution: ${spectrum_nmr_tube_prep.getNMRbufferSolutionAsString()}</li>
					<li class="list-group-item">Buffer Solution Concentration: ${spectrum_nmr_tube_prep.getBufferSolutionConcentration()} (mmol/L)</li> 
				</ul>
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">
						Deuterium isotopic labelling: 
						<c:if test="${spectrum_nmr_tube_prep.isDeuteriumIsotopicLabelling()}">yes</c:if>
						<c:if test="${not spectrum_nmr_tube_prep.isDeuteriumIsotopicLabelling()}">no</c:if>
					</li>
					<li class="list-group-item">
						Carbon-13 isotopic labelling: 
						<c:if test="${spectrum_nmr_tube_prep.isCarbon13IsotopicLabelling()}">yes</c:if>
						<c:if test="${not spectrum_nmr_tube_prep.isCarbon13IsotopicLabelling()}">no</c:if>
					</li>
					<li class="list-group-item">
						Nitrogen-15 isotopic labelling: 
						<c:if test="${spectrum_nmr_tube_prep.isNitrogenIsotopicLabelling()}">yes</c:if>
						<c:if test="${not spectrum_nmr_tube_prep.isNitrogenIsotopicLabelling()}">no</c:if>
					</li>
				</ul>
			</div>
</c:if>
		</div>
	</div>
	<div class="tab-pane " id="chromatography">
		<div class="panel panel-default">
<c:choose>	
	<c:when test="${spectrum_chromatography == 'none'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelNoChromato" text="No Chromatography" /></h3>
			</div>
			<div class="panel-body">
			...
			</div>
	</c:when>
	<c:when test="${spectrum_chromatography == 'lc'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelLCChromato" text="LC Chromatography" /></h3>
			</div>
			<div class="panel-body">
<table style="width:100%">
	<tr> 
		<td width="50%">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Method: ${spectrum_chromatography_method}</li>
				<li class="list-group-item">Column constructor: ${fn:escapeXml(spectrum_chromatography_col_constructor)}</li>
<!-- 				<li class="list-group-item">Column constructor (other): xxx</li> -->
				<li class="list-group-item">Column name: ${fn:escapeXml(spectrum_chromatography_col_name)}</li>
				<li class="list-group-item">Column length: ${spectrum_chromatography_col_length} (mm)</li>
				<li class="list-group-item">Column diameter: ${spectrum_chromatography_col_diameter} (mm)</li>
				<li class="list-group-item">Particle size: ${spectrum_chromatography_col_particule_size} (&micro;m)</li>
				<li class="list-group-item">Column temperature: ${spectrum_chromatography_col_temperature} (&#8451;)</li>
				<li class="list-group-item">LC mode: ${spectrum_chromatography_mode_lc}</li>
				<li class="list-group-item">Separation flow rate: ${spectrum_chromatography_separation_flow_rate} (&micro;L/min)</li>
				<li class="list-group-item">Separation solvent A: ${spectrum_chromatography_solventA}</li>
				<c:if test="${spectrum_chromatography_solventApH != null }">
				<li class="list-group-item">pH solvent A: ${spectrum_chromatography_solventApH}</li>
				</c:if>
				<li class="list-group-item">Separation solvent B: ${spectrum_chromatography_solventB}</li>
				<c:if test="${spectrum_chromatography_solventBpH != null }">
				<li class="list-group-item">pH solvent B: ${spectrum_chromatography_solventBpH}</li>
				</c:if>
			</ul>
		</td>
		<td width="50%">
			<b>Separation flow gradient</b>
			<br>
			<table class="table" style="max-width: 300px;">
				<thead>
					<tr>
						<td style="width: 100px;">Time (min)</td>
						<td style="width: 100px;">Solv. A (%)</td>
						<td style="width: 100px;">Solv. B (%)</td>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="time" items="${spectrum_chromatography_sfg_time}">
					<tr>
						<td style="width: 100px;">${time}</td>
						<td>${spectrum_chromatography_sfg.get(time)[0]}</td>
						<td>${spectrum_chromatography_sfg.get(time)[1]}</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</td>
	</tr>
</table>
			</div>
	</c:when>
	<c:when test="${spectrum_chromatography == 'gc'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelGCChromato" text="GC Chromatography" /></h3>
			</div>
			<div class="panel-body">
<table style="width:100%">
	<tr> 
		<td width="50%">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Method: ${spectrum_chromatography_method}</li>
				<li class="list-group-item">Column constructor: ${fn:escapeXml(spectrum_chromatography_col_constructor)}</li>
<!-- 				<li class="list-group-item">Column constructor (other): xxx</li> -->
				<li class="list-group-item">Column name: ${fn:escapeXml(spectrum_chromatography_col_name)}</li>
				<li class="list-group-item">Column length: ${spectrum_chromatography_col_length} (m)</li>
				<li class="list-group-item">Column diameter: ${spectrum_chromatography_col_diameter} (mm)</li>
				<li class="list-group-item">Particle size: ${spectrum_chromatography_col_particule_size} (&micro;m)</li>
				<li class="list-group-item">Injection volume: ${spectrum_chromatography_injection_volume} (&micro;L)</li>
				<li class="list-group-item">Injection mode: ${spectrum_chromatography_injection_mode}</li>
				<li class="list-group-item">Split ratio: ${spectrum_chromatography_split_ratio} (:1)</li>
				<li class="list-group-item">Carrier gas: ${spectrum_chromatography_carrier_gas}</li>
				<li class="list-group-item">Gas flow: ${spectrum_chromatography_gas_flow} (mL/min)</li>
				<li class="list-group-item">Gas opt: ${spectrum_chromatography_gas_opt}</li>
				<li class="list-group-item">Gas pressure: ${spectrum_chromatography_gas_pressure} (psi)</li>
				<li class="list-group-item">GC mode: ${spectrum_chromatography_mode_gc}</li>
				<li class="list-group-item">Liner Manufacturer: ${spectrum_chromatography_liner_manufacturer}</li>
				<li class="list-group-item">Liner Type: ${spectrum_chromatography_liner_type}</li>
			</ul>
		</td>
		<td width="50%">
			<b>Separation flow gradient</b>
			<br>
			<table class="table" style="max-width: 300px;">
				<thead>
					<tr>
						<td style="width: 100px;">Temp. (&#8451;)</td>
						<td style="width: 100px;">Rate (&#8451;/min)</td>
						<td style="width: 100px;">Time (min)</td>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="temp" items="${spectrum_chromatography_stp_temperature}">
					<tr>
						<td style="width: 100px;">${temp}</td>
						<td>${spectrum_chromatography_stp.get(temp)[0]}</td>
						<td>${spectrum_chromatography_stp.get(temp)[1]}</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</td>
	</tr>
</table>
			</div>
	</c:when>
	<c:when test="${spectrum_chromatography == 'ic'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelICChromato" text="IC Chromatography" /></h3>
			</div>
			<div class="panel-body">
<table style="width:100%">
	<tr> 
		<td width="50%">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Method: ${spectrum_chromatography_method}</li>
				<li class="list-group-item">Column constructor: ${fn:escapeXml(spectrum_chromatography_col_constructor)}</li>
<!-- 				<li class="list-group-item">Column constructor (other): xxx</li> -->
				<li class="list-group-item">Column name: ${fn:escapeXml(spectrum_chromatography_col_name)}</li>
				
				<li class="list-group-item">Ionic config.: ${spectrum_chromatography_col_ionic_config}</li>
				<li class="list-group-item">Suppressor constructor: ${spectrum_chromatography_col_suppressor_constructor}</li>
				<li class="list-group-item">Suppressor name: ${spectrum_chromatography_col_suppressor_name}</li>
				<c:if test="${spectrum_chromatography_col_is_makeup }">
					<li class="list-group-item">Make-up: ${spectrum_chromatography_col_makeup}</li>
					<li class="list-group-item">Make-up flow rate : ${spectrum_chromatography_col_makeup_flow_rate} (&micro;L/min)</li>
				</c:if>				
				<li class="list-group-item">Column length: ${spectrum_chromatography_col_length} (mm)</li>
				<li class="list-group-item">Column diameter: ${spectrum_chromatography_col_diameter} (mm)</li>
				<li class="list-group-item">Particle size: ${spectrum_chromatography_col_particule_size} (&micro;m)</li>
				<li class="list-group-item">Column temperature: ${spectrum_chromatography_col_temperature} (&#8451;)</li>
				<li class="list-group-item">IC mode: ${spectrum_chromatography_mode_ic}</li>
				<li class="list-group-item">Separation flow rate: ${spectrum_chromatography_separation_flow_rate} (&micro;L/min)</li>
				<li class="list-group-item">Separation solvent: ${spectrum_chromatography_solvent}</li>
			</ul>
		</td>
		<td width="50%">
			<b>Separation flow gradient</b>
			<br>
			<table class="table" style="max-width: 300px;">
				<thead>
					<tr>
						<td style="width: 100px;">Time (min)</td>
						<td style="width: 100px;">Solv. (mM)</td>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="time" items="${spectrum_chromatography_sfg_time}">
					<tr>
						<td style="width: 100px;">${time}</td>
						<td>${spectrum_chromatography_sfg.get(time)}</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</td>
	</tr>
</table>
			</div>
	</c:when>
</c:choose>
		</div>
	</div>
	
	<div class="tab-pane " id="MS_analyzer">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelIonization" text="Ionization" /></h3>
			</div>
			<div class="panel-body">
				<c:if test="${spectrum_chromatography != 'gc'}">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">Ionization method: ${fn:escapeXml(spectrum_ms_ionization.getIonizationAsString())}</li>
					<li class="list-group-item">Spray (needle) gas flow: ${fn:escapeXml(spectrum_ms_ionization.sprayGazFlow)}</li>
					<li class="list-group-item">Vaporizer gas flow: ${fn:escapeXml(spectrum_ms_ionization.vaporizerGazFlow)}</li>
					<li class="list-group-item">Vaporizer temperature: ${fn:escapeXml(spectrum_ms_ionization.vaporizerTemperature)} (&#8451;)</li>
					<li class="list-group-item">Source gas flow: ${fn:escapeXml(spectrum_ms_ionization.sourceGazFlow)}</li>		
					<li class="list-group-item">Ion transfer tube temperature /<br> Transfer capillary temperature: ${spectrum_ms_ionization.ionTransferTemperature} (&#8451;)</li>
					<li class="list-group-item">High voltage (ESI) /<br> Corona voltage (APCI): ${fn:escapeXml(spectrum_ms_ionization.ionizationVoltage)} (kV)</li>				
				</ul>
				</c:if>
				<c:if test="${spectrum_chromatography == 'gc'}">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">Ionization method: ${fn:escapeXml(spectrum_ms_ionization.getIonizationAsString())}</li>
					<li class="list-group-item">Electron energy: ${fn:escapeXml(spectrum_ms_ionization.electronEnergy)} (eV)</li>
					<li class="list-group-item">Emission current: ${fn:escapeXml(spectrum_ms_ionization.emissionCurrent)} (&micro;A)</li>
					<li class="list-group-item">Source temperature: ${fn:escapeXml(spectrum_ms_ionization.sourceTemperature)} (&#8451;)</li>
					<li class="list-group-item">Ionization gas (CI): ${fn:escapeXml(spectrum_ms_ionization.getIonizationGasAsString())}</li>		
					<li class="list-group-item">Ionization gas flow (CI): ${fn:escapeXml(spectrum_ms_ionization.ionizationGasFlow)}</li>		
					<li class="list-group-item">Interface temperature: ${spectrum_ms_ionization.interfaceTemperature} (&#8451;)</li>
					<li class="list-group-item">Repeller: ${fn:escapeXml(spectrum_ms_ionization.repeller)} (V)</li>				
					<li class="list-group-item">Extractor: ${fn:escapeXml(spectrum_ms_ionization.extractor)} (V)</li>				
					<li class="list-group-item">Ion focus: ${fn:escapeXml(spectrum_ms_ionization.ionFocus)} (V)</li>			
				</ul>
				</c:if>
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelAnalyzer" text="Analyzer" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
<%-- 					<li class="list-group-item">Instrument: ${fn:escapeXml(spectrum_ms_analyzer.instrumentName)}</li> --%>
					<li class="list-group-item">Analyzer type: ${fn:escapeXml(spectrum_ms_analyzer.getIonAnalyzerType())}</li>
					<c:if test="${spectrum_chromatography != 'gc'}">
					<li class="list-group-item">Model: ${fn:escapeXml(spectrum_ms_analyzer.instrumentModel)}</li>
					</c:if>
					<c:if test="${spectrum_chromatography == 'gc'}">
					<li class="list-group-item">Brand: ${fn:escapeXml(spectrum_ms_analyzer.instrumentBrand)}</li>
					</c:if>
<%-- 					<li class="list-group-item">Resolution FWHM: ${spectrum_ms_analyzer.instrumentResolutionFWHMresolution}@${spectrum_ms_analyzer.instrumentResolutionFWHMmass}</li> --%>
<%-- 					<li class="list-group-item">Detector: ${fn:escapeXml(spectrum_ms_analyzer.instrumentDetector)}</li> --%>
<%-- 					<li class="list-group-item">Detection protocol: ${fn:escapeXml(spectrum_ms_analyzer.instrumentDetectionProtocol)}</li>				 --%>
				</ul>
			</div>
		</div>
		<!-- start MSMS only -->
		<c:if test="${spectrum_type == 'lc-fragmentation'}">
			<div class="panel panel-default">
				<!-- // if ION STORAGE -->
				<c:if test="${not empty spectrum_msms_iontrap}">
					<div class="panel-heading">
						<h3 class="panel-title"><spring:message code="page.spectrum.metadata.msms.labelIonStorage" text="Ion storage" /></h3>
					</div>
					<div class="panel-body">
						<ul class="list-group" style="max-width: 600px;">
							<li class="list-group-item">Gas: ${spectrum_msms_iontrap.getIonGasAsHTML()}</li>
							<li class="list-group-item">Gas pressure: ${spectrum_msms_iontrap.getIonGazPressure()} ${fn:escapeXml(spectrum_msms_iontrap.getIonGazPressureUnitAsString())} </li>
							<li class="list-group-item">Frequency shift: ${fn:escapeXml(spectrum_msms_iontrap.getIonFrequencyShift())} KHz</li>
							<li class="list-group-item">Ion number (AGC or ICC): ${fn:escapeXml(spectrum_msms_iontrap.getIonNumberAGC())} </li>
						</ul>
					</div>
				</c:if>
				<!-- // if ION BEAM -->
				<c:if test="${not empty spectrum_msms_ionbeam }">
					<div class="panel-heading">
						<h3 class="panel-title"><spring:message code="page.spectrum.metadata.msms.labelIonBeam" text="Ion beam" /></h3>
					</div>
					<div class="panel-body">
						<ul class="list-group" style="max-width: 600px;">
							<li class="list-group-item">Gas: ${spectrum_msms_ionbeam.getIonGasAsHTML()}</li>
							<li class="list-group-item">Gas pressure: ${spectrum_msms_ionbeam.getIonGazPressure()} ${fn:escapeXml(spectrum_msms_ionbeam.getIonGazPressureUnitAsString())} </li>
						</ul>
					</div>
				</c:if>
			</div>
		</c:if>
		
	</div>
	
	<div class="tab-pane " id="MS_peaks">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelParameters" text="Parameters" /></h3>
			</div>
			<div class="panel-body">
				<table style="width:100%">
					<tr> 
						<td width="33%">
							<ul class="list-group" style="max-width: 300px;">
								<li class="list-group-item">Scan type: ${fn:escapeXml(spectrum_ms_scan_type)}</li>
								<li class="list-group-item">Polarity: ${fn:escapeXml(spectrum_ms_polarity)}</li>
								<li class="list-group-item">Resolution: ${fn:escapeXml(spectrum_ms_resolution)}</li>
								<li class="list-group-item">Resolution FWHM: ${spectrum_ms_resolution_FWHM}</li>
							</ul>
						</td>
						<td width="33%">
							<ul class="list-group" style="max-width: 300px;">
								<li class="list-group-item">Mass range: [${spectrum_ms_range_from} .. ${spectrum_ms_range_to}]</li>
								<li class="list-group-item">Retention time <small>(min)</small>: [${spectrum_rt_min_from} .. ${spectrum_rt_min_to}]</li>
								<c:if test="${spectrum_chromatography != 'gc'}">
								<li class="list-group-item">Retention time <small>(MeOH)</small>: [${spectrum_rt_meoh_from} .. ${spectrum_rt_meoh_to}]</li>
								<li class="list-group-item">Retention time<sup title="based on %MeOH = 1.28 %ACN ">*</sup> <small>(ACN)</small>: [${spectrum_rt_acn_from} .. ${spectrum_rt_acn_to}]</li>
								</c:if>
								<c:if test="${spectrum_chromatography == 'gc'}">
								<li class="list-group-item">Retention index <small>(alkane)</small>: [${spectrum_ri_alkane_from} .. ${spectrum_ri_alkane_to}]</li>
								</c:if>
							</ul>
						</td>
						<td width="33%">
							<!-- only if msms -->
							<c:if test="${spectrum_type == 'lc-fragmentation'}">
								<ul class="list-group" >
									<c:if test="${spectrum_msms_isMSMS}">
										<li class="list-group-item">Parent ion M/Z: ${spectrum_msms_parentIonMZ} </li>
										<li class="list-group-item">
											Parent spectrum: 
											<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum_msms_parentSpectrum.getPeakForestID()}">${ spectrum_msms_parentSpectrum.getPeakForestID()}</a> <small>${fn:escapeXml(spectrum_msms_parentSpectrum.getMassBankName())}</small> 
										</li>
									</c:if>
									<c:if test="${spectrum_msms_hasChild}">
										<li class="list-group-item">Children: 
											<c:forEach var="tSpectrum" items="${spectrum_msms_children}">
												<br /> <a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${tSpectrum.getPeakForestID()}">${tSpectrum.getPeakForestID()}</a> <small> ${fn:escapeXml(tSpectrum.getMassBankName())} </small>
											</c:forEach>
										</li>
									</c:if>
								</ul>
							</c:if>
						</td>
					</tr>
				</table>
			
				
			</div>
		</div>
		
		<!-- // MSMS data -->
		<c:if test="${spectrum_msms_isMSMS}">
			
			<div class="panel panel-default">
				<div class="panel-heading">
					<h3 class="panel-title">MSMS</h3>
				</div>
				<div class="panel-body">
					<ul class="list-group" style="max-width: 600px;">
						<li class="list-group-item">Isolation Mode: ${(isolation_mode)}</li>
						<li class="list-group-item">QZ Isolation: ${qz_isolation} </li>
						<li class="list-group-item">Activation Time: ${(activation_time)} ms</li>
						<li class="list-group-item">Isolation Window: ${(isolation_window)} </li>
						<li class="list-group-item">Center of Isolation Window: ${(center_isolation_window)} </li>
						<li class="list-group-item">Frag. Energy: ${(frag_energy)} </li>
					</ul>
				</div>
			</div>
		</c:if>
		<!-- end MSMS only -->
		
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakListMZ" text="Peak List" /></h3>
			</div>
			<div class="panel-body">
				<table class="table" style="max-width: 900px;">
					<thead>
						<tr style="white-space: nowrap;">
							<th>m/z</th><th>RI (%)</th><th>theo. mass</th><th>delta (ppm)</th><th>RDB equiv.</th><th>composition</th><th>attribution</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="peak" items="${spectrum_ms_peaks}">
						<tr>
							<td>${peak.massToChargeRatio}</td>
							<td>${peak.relativeIntensity}</td>
							<td>${peak.getTheoricalMass()}</td>
							<td>${peak.getDeltaPPM()}</td>
							<td>${peak.getRDBequiv()}</td>
							<td>${fn:escapeXml(peak.composition)}</td>
							<td>${fn:escapeXml(peak.getAttributionAsString())}</td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
				Curation: ${spectrum_ms_peaks_curation_lvl} 
			</div>
		</div>
	</div>
	
	<div class="tab-pane " id="NMR_analyzer">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelInstrument" text="Instrument" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;"> 
					<li class="list-group-item">Instrument name: ${fn:escapeXml(spectrum_nmr_analyzer.getNMRinstrumentNameAsString())}</li>
					<li class="list-group-item">Magnetic field strength: ${fn:escapeXml(spectrum_nmr_analyzer.getMagneticFieldStrenghtAsString())} (MHz)</li>
					<li class="list-group-item">Software: ${fn:escapeXml(spectrum_nmr_analyzer.getNMRsoftwareVersionAsString())}</li>
					<li class="list-group-item">NMR probe: ${fn:escapeXml(spectrum_nmr_analyzer.getNMRprobeAsString())}</li>
					<c:if test="${! spectrum_nmr_analyzer.isCell()}">
					<li class="list-group-item">NMR tube diameter: ${fn:escapeXml(spectrum_nmr_analyzer.getNMRtubeDiameterAsString())} (mm)</li>
					</c:if>
					<c:if test="${spectrum_nmr_analyzer.isCell()}">
					<li class="list-group-item">Flow cell volume: ${fn:escapeXml(spectrum_nmr_analyzer.flowCellVolume)} (&micro;l)</li>
					</c:if>
				</ul>
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelAcquisition" text="Acquisition" /></h3>
			</div>
			<div class="panel-body">
<table style="width:100%">
	<tr> 
		<td width="50%">
<c:choose>	
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Number of points: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</li>
				<li class="list-group-item">Number of scans: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW: ${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</li>	
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Number of points: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</li>
				<li class="list-group-item">Number of scans: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW: ${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</li>
				<li class="list-group-item">Mixing time: ${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)} (s)</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Number of points: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</li>
				<li class="list-group-item">Number of scans: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW: ${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</li>
				<li class="list-group-item">Spin-echo delay: ${fn:escapeXml(spectrum_nmr_analyzer_data.spinEchoDelay)} (&micro;s)</li>
				<li class="list-group-item">Number of loops: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfLoops)}</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} ((&deg;))</li>
				<li class="list-group-item">Number of points: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</li>
				<li class="list-group-item">Number of scans: ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW: ${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</li>
				<li class="list-group-item">Decoupling type: ${fn:escapeXml(spectrum_nmr_analyzer_data.decouplingType)}</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Size of FID (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</li>
				<li class="list-group-item">Size if FID (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</li>
				<li class="list-group-item">Number of Scans (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</li>
				<li class="list-group-item">Acquisition Mode for 2D (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
				<li class="list-group-item">SW (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Size of FID (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</li>
				<li class="list-group-item">Size if FID (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</li>
				<li class="list-group-item">Number of Scans (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</li>
				<li class="list-group-item">Acquisition Mode for 2D (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW (1H): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
				<li class="list-group-item">NUS: ${fn:escapeXml(spectrum_nmr_analyzer_data.getNusAsTrueFalse())}</li>
				<li class="list-group-item">NusAmount: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)} (%)</li>
				<li class="list-group-item">NusPoints: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Size of FID (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</li>
				<li class="list-group-item">Size if FID (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</li>
				<li class="list-group-item">Number of Scans (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</li>
				<li class="list-group-item">Acquisition Mode for 2D (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</li>
				<li class="list-group-item">Mixing time: ${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)} (s)</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW (1H): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
				<li class="list-group-item">NUS: ${fn:escapeXml(spectrum_nmr_analyzer_data.getNusAsTrueFalse())}</li>
				<li class="list-group-item">NusAmount: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)} (%)</li>
				<li class="list-group-item">NusPoints: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Size of FID (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</li>
				<li class="list-group-item">Size if FID (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</li>
				<li class="list-group-item">Number of Scans (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</li>
				<li class="list-group-item">Acquisition Mode for 2D (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">Mixing time D8: ${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)} (s)</li>
				<li class="list-group-item">SW (1H): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
				<li class="list-group-item">NUS: ${fn:escapeXml(spectrum_nmr_analyzer_data.getNusAsTrueFalse())}</li>
				<li class="list-group-item">NusAmount: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)} (%)</li>
				<li class="list-group-item">NusPoints: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Size of FID (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</li>
				<li class="list-group-item">Size if FID (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</li>
				<li class="list-group-item">Number of Scans (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</li>
				<li class="list-group-item">Acquisition Mode for 2D (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW (1H): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
				<li class="list-group-item">SW (13C): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF2)} (ppm)</li>
				<li class="list-group-item">Decouplage type: ${fn:escapeXml(spectrum_nmr_analyzer_data.decouplageType)}</li>
				<li class="list-group-item">JXH: ${fn:escapeXml(spectrum_nmr_analyzer_data.jxh)} (Hz)</li>
				<li class="list-group-item">NUS: ${fn:escapeXml(spectrum_nmr_analyzer_data.getNusAsTrueFalse())}</li>
				<li class="list-group-item">NusAmount: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)} (%)</li>
				<li class="list-group-item">NusPoints: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Pulse sequence: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</li>
				<li class="list-group-item">Pulse angle: ${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</li>
				<li class="list-group-item">Size of FID (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</li>
				<li class="list-group-item">Size if FID (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</li>
				<li class="list-group-item">Number of Scans (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</li>
				<li class="list-group-item">Acquisition Mode for 2D (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</li>
				<li class="list-group-item">Temperature: ${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</li>
				<li class="list-group-item">Relaxation delay D1: ${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</li>
				<li class="list-group-item">SW (1H): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</li>
				<li class="list-group-item">SW (13C): ${fn:escapeXml(spectrum_nmr_analyzer_data.swF2)} (ppm)</li>
				<li class="list-group-item">JXH long range: ${fn:escapeXml(spectrum_nmr_analyzer_data.jxh)} (Hz)</li>
				<li class="list-group-item">NUS: ${fn:escapeXml(spectrum_nmr_analyzer_data.getNusAsTrueFalse())}</li>
				<li class="list-group-item">NusAmount: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)} (%)</li>
				<li class="list-group-item">NusPoints: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}</li>
			</ul>
	</c:when>
</c:choose>
		</td>
		<td width="50%">
<%-- <c:if test="${display_real_spectrum}"> --%>
	<c:choose>
		<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D' || spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D' || spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D' }">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Fourier transform: ${spectrum_nmr_analyzer_data.getFourierTransform()}</li>
				<li class="list-group-item">SI: ${fn:escapeXml(spectrum_nmr_analyzer_data.getSiAsString())}</li>
				<li class="list-group-item">Line broadening: ${fn:escapeXml(spectrum_nmr_analyzer_data.getLineBroadening())} Hz</li>
				<%-- <li class="list-group-item">LB: ${fn:escapeXml(spectrum_nmr_analyzer_data.getLb())} Hz</li> --%>
			</ul>
		</c:when>
		<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Fourier transform: ${spectrum_nmr_analyzer_data.getFourierTransform()}</li>
				<li class="list-group-item">SI (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.getSiF1AsString())}</li>
				<li class="list-group-item">SI (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.getSiF2AsString())}</li>
				<li class="list-group-item">Window function (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.getWindowFunctionF1AsString())}</li>
				<li class="list-group-item">Window function (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.getWindowFunctionF2AsString())}</li>
				<li class="list-group-item">LB (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)} Hz</li>
				<li class="list-group-item">LB (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)} Hz</li>
				<li class="list-group-item">SSB (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}</li>
				<li class="list-group-item">SSB (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}</li>
				<li class="list-group-item">GB (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}</li>
				<li class="list-group-item">GB (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}</li>
				<li class="list-group-item">Peak Peaking: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPeakPickingAsString())}</li>
				<li class="list-group-item">NUS processing parameter: ${fn:escapeXml(spectrum_nmr_analyzer_data.nusProcessingParameter)}</li>
			</ul>
		</c:when>
		<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D' }">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">Fourier transform: ${spectrum_nmr_analyzer_data.getFourierTransform()}</li>
				<li class="list-group-item">Tilt: ${spectrum_nmr_analyzer_data.getTiltAsString()}</li>
				<li class="list-group-item">SI (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.getSiF1AsString())}</li>
				<li class="list-group-item">SI (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.getSiF2AsString())}</li>
				<li class="list-group-item">Window function (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.getWindowFunctionF1AsString())}</li>
				<li class="list-group-item">Window function (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.getWindowFunctionF2AsString())}</li>
				<li class="list-group-item">SSB (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}</li>
				<li class="list-group-item">SSB (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}</li>
				<li class="list-group-item">GB (F1): ${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}</li>
				<li class="list-group-item">GB (F2): ${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}</li>
				<li class="list-group-item">Peak Peaking: ${fn:escapeXml(spectrum_nmr_analyzer_data.getPeakPickingAsString())}</li>
				<li class="list-group-item">Symmetrize: ${fn:escapeXml(spectrum_nmr_analyzer_data.getSymmetrizeAsString())}</li>
			</ul>
		</c:when>
	</c:choose>
<%-- </c:if> --%>
		</td>
	</tr>
</table>
			</div>
		</div>
	</div>
	
	<div class="tab-pane " id="NMR_peaks">
<!-- 		<div class="panel panel-default"> -->
<!-- 			<div class="panel-heading"> -->
<!-- 				<h3 class="panel-title">Parameters</h3> -->
<!-- 			</div> -->
<!-- 			<div class="panel-body"> -->
<!-- 			... -->
<!-- 			</div> -->
<!-- 		</div> -->
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakListnmr" text="Peak List" /></h3>
			</div>
			<div class="panel-body">
				<table style="width: 100%">
					<tr valign="top">
						<td style="width: 75%">
			<c:choose>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D' || spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D'}">
							<table class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>peak index</th><th>&nu; (F1) [ppm]</th><th>intensity [rel]</th><th>half width [Hz]</th><th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<% int i = 1; %>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i++ %></td><td>${peak.getRoundedChemicalShift(2)}</td><td>${peak.getRoundedRelativeIntensity(2)}</td><td>${peak.getRoundedHalfWidthHz(2)}</td><td>${fn:escapeXml(peak.annotation)}</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
				</c:when>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D'}">
							<table class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>peak index</th><th>&nu; (F1) [ppm]</th><th>intensity [rel]</th><th>half width [Hz]</th><th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<% int i = 1; %>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i++ %></td><td>${peak.getRoundedChemicalShift(2)}</td><td>${peak.getRoundedRelativeIntensity(2)}</td><td>${peak.getRoundedHalfWidthHz(2)}</td><td>${fn:escapeXml(peak.annotation)}</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
				</c:when>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
							<table class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>peak index</th><th>&nu; (F2) [ppm]</th><th>&nu; (F1) [ppm]</th><th class="tabStrippedBg">intensity [abs]</th><th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<% int i = 1; %>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i++ %></td><td>${peak.getRoundedChemicalShiftF2(2)}</td>
										<td>${peak.getRoundedChemicalShiftF1(2)}</td>
										<td class="tabStrippedBg">${peak.getRoundedIntensity(2)}</td>
										<td>${fn:escapeXml(peak.annotation)}</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
				</c:when>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D'}">
							<table class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>peak index</th>
										<th>&nu; (F2) [ppm]</th>
										<th>&nu; (F1) [ppm]</th>
										<th class="tabStrippedBg">intensity [rel]</th>
										<th>multiplicity</th>
										<th>J (coupling constant)</th>
										<th>annotation</th>
										
									</tr>
								</thead>
								<tbody>
									<% int i = 1; %>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i++ %></td>
										<td>${peak.getRoundedChemicalShiftF2(2)}</td>
										<td>${peak.getRoundedChemicalShiftF1(2)}</td>
										<td class="tabStrippedBg">${peak.getRoundedIntensity(2)}</td>
										<td>${peak.getMultiplicityTypeAsString()}</td>
										<td>${peak.getCouplingConstantAsString()}</td> 
										<td>${fn:escapeXml(peak.annotation)}</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
				</c:when>
			</c:choose>
						</td>
						<td style="width: 33%">
<c:if test="${spectrum_sample_compound_display_numbered_mol}">
<c:if test="${mol_nb_3D_exists || mol_nb_2D_exists || editor}">
							<ul class="nav nav-tabs">
	<c:if test="${mol_nb_3D_exists}">
								<li class="${mol_nb_3D_exists_class}">
									<a href="#showMol-3D-numbered" onclick="refreshJSmol();" role="tab" id="dropdown1-tab" data-toggle="tab" aria-controls="showMol-3D-numbered" aria-expanded="false">
										<i class="fa fa-cube"></i> Nb <i class="fa fa-sort-numeric-desc"></i>
									</a>
								</li>
	</c:if>
	<c:if test="${mol_nb_2D_exists}">
								<li class="${mol_nb_2D_exists_class}">
									<a href="#showMol-2D-numbered" role="tab" id="dropdown2-tab" data-toggle="tab" aria-controls="showMol-2D-numbered" aria-expanded="true">
										<i class="fa fa-square-o"></i> Nb <i class="fa fa-sort-numeric-desc"></i>
									</a>
								</li>
	</c:if>
	<c:if test="${editor}">
								<li class="${mol_nb_upload_exists_class}">
									<a href="#showMol-upload-numbered" role="tab" id="dropdown2-tab" data-toggle="tab" aria-controls="showMol-upload-numbered" aria-expanded="true">
										<i class="fa fa-upload"></i> Nb <i class="fa fa-sort-numeric-desc"></i>
									</a>
								</li>
	</c:if>
							</ul>
</c:if>
							<div class="tab-content">
<c:if test="${mol_nb_3D_exists}">
													<!-- if mol 3D -->
													<div id="showMol-3D-numbered" class="tab-pane fade ${mol_nb_3D_exists_fad}">
														<div id="jsmol" height="520" width="420" style="border-width: inherit;" >
															loading...
														</div>
													</div>
</c:if>
<c:if test="${mol_nb_2D_exists}">
													<!-- if svg / png / jpeg -->
													<div id="showMol-2D-numbered" class="tab-pane fade ${mol_nb_2D_exists_fad}">
														<img class="molStructSVGmedium" src="numbered/${spectrum_sample_compound_inchikey}.${mol_nb_2D_ext}" alt="${fn:escapeXml(spectrum_sample_compound_name)}">
													</div>
</c:if>
<c:if test="${editor}">
													<!-- upload new image -->
													<div id="showMol-upload-numbered" class="tab-pane fade ${mol_nb_upload_exists_fad}">
														
															<div class="">
																<br />
																<span id="fileUploadContainer"></span>
																<div id="addImageFormContent" class="input-group">
																	<span class="input-group-btn">
																			<span class="btn btn-primary btn-file btn-file-cpd-nb"> Browse&#133;
																				<input id="file" type="file" name="file" accept=".mol, .svg, .png">
																			</span>
														<!-- 					multiple="" -->
																			<input type="hidden" name="ajaxUpload" value="true">
																			<input id="inchikey" name="inchikey" type="hidden" value="${spectrum_sample_compound_inchikey}" />
																	</span> <input type="text" class="form-control" readonly>
																</div>
																<small>
																	To know how to number molecules atoms (rules, softwares, ...) please contact your WP1a manager
																	or read the <a href="<c:url value="/resources/docs/PeakForest_mol_num.fr.pdf" />" target="_blank">online documentation</a>.
																</small>
																<br />
																<br />
															</div>
															<div class="">
															</div>
															<div id="imgUploading" class="" style="display:none;" >
																<br />
																<br />
																<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
															</div>
															<div id="imgUploadResults" class="" style="display:none;" >
															</div>
															<div id="imgUploadError" class="" style="" ></div>
															     
<script type="text/javascript">
//

checkUploadChemFileForm=function() {
	if ($("#file").val()=='') {
		return false;
	}
	return true;
};
//file upload
$(document).on('change', '.btn-file-cpd-nb.btn-file :file', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('.btn-file-cpd-nb.btn-file :file').on('fileselect', function(event, numFiles, label) {
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;
		if(input.length) {
			input.val(log);
			// startUpload();
			$("#addImageFormContent").appendTo("#fileUploadForm");
			$("#fileUploadForm").submit();
		} else {
			if(log) alert(log);
		}
	});
});
$(document).ready(function() {
	$("#fileUploadForm").ajaxForm({
		beforeSubmit: startUpload,
		success: function(data) {
			// reload if OK
			var data2 = data.trim();
			if (data2 == "OK")
				location.reload();
			else {
				var stringError = "";
				if (data2 == "no_file_selected")
					stringError = "no file selected!";
				else if (data2 == "wrong_ext")
					stringError = "wrong file extension";
				var errorBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> ' + stringError;
				errorBox += ' </div>';
				$("#imgUploadError").html(errorBox);
			}
			$("#imgUploading").hide();
			$("#addImageFormContent").appendTo("#fileUploadContainer");
		},
		error: function() {
			// alert message
			var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
				errorBox += ' </div>';
				$("#imgUploadError").html(errorBox);
			$("#imgUploading").hide();
			$("#addImageFormContent").appendTo("#fileUploadContainer");
		}
	});
});

function startUpload() {
	$("#imgUploadError").html("");
	$("#imgUploading").show();
	//
}

</script>
											</div>
</c:if>
							</div>
</c:if>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<c:if test="${not empty spectrum_nmr_peakpatterns}">
			<div class="panel panel-default">
				<c:choose>
					<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D' || spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D'}">
						<div class="panel-heading">
							<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakPatternListnmr" text="Peak Pattern List" /></h3>
						</div>
						<div class="panel-body">
							<table class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>&nu; (F1) [ppm]</th><th>H's</th><th>type</th><th>J(Hz)</th><th>range (ppm)</th><th>atoms</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach var="peakpattern" items="${spectrum_nmr_peakpatterns}">
									<tr>
										<td>${peakpattern.getRoundedChemicalShift(2)}</td><td>${peakpattern.atomsAttributions}</td><td>${peakpattern.getPatternTypeAsString()}</td><td>${peakpattern.getCouplageConstantAsString()}</td><td>[${peakpattern.rangeFrom} .. ${peakpattern.rangeTo}]</td><td>${fn:escapeXml(peakpattern.atom)}</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
						</div>
					</c:when>
					<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D' && not empty spectrum_nmr_peakpatterns}">
						<div class="panel-heading">
							<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakPatternListnmr" text="Peak Pattern List" /></h3>
						</div>
						<div class="panel-body">
							<table class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>&nu; (F1) [ppm]</th><th>C's</th><th>type</th><th>J(Hz)</th><th>range (ppm)</th><th>atoms</th>
									</tr>
								</thead>
								<tbody>
									<c:forEach var="peakpattern" items="${spectrum_nmr_peakpatterns}">
									<tr>
										<td>${peakpattern.getRoundedChemicalShift(2)}</td><td>${peakpattern.atomsAttributions}</td><td>${peakpattern.getPatternTypeAsString()}</td><td>${peakpattern.getCouplageConstantAsString()}</td><td>${peakpattern.getRangeAsString(2)}</td><td>${fn:escapeXml(peakpattern.atom)}</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
						</div>
					</c:when>
				</c:choose>
			</div>
		</c:if>
	</div>
	
	<div class="tab-pane " id="other_metadata">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelAboutAuthors" text="About authors" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">Authors: ${fn:escapeXml(spectrum_othermetadata.authors)}</li>
					<li class="list-group-item">Validator: ${fn:escapeXml(spectrum_othermetadata.validator)}</li>
					<li class="list-group-item">Acquisition date: <fmt:formatDate value="${spectrum_othermetadata.acquisitionDate}" pattern="yyyy-MM-dd" /></li>
					<li class="list-group-item">Data ownership: ${fn:escapeXml(spectrum_othermetadata.ownership)}</li>
				</ul>
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelRawFile" text="Raw File" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">File name: ${fn:escapeXml(spectrum_othermetadata.rawFileName)}</li>
					<li class="list-group-item">File size: ${spectrum_othermetadata.rawFileSize} (Ko)</li>
				</ul>
			</div>
		</div>
	</div>
	
	<div class="tab-pane " id="related_spectra">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelFromSameAnalyze" text="From the same analyze" /></h3>
			</div>
			<div class="panel-body">
			<c:if test="${spectrum_has_related_spectra}">
				<table class="table" style="max-width: 700px;">
					<tbody>
						<c:forEach var="tSpectrum" items="${spectrum_related_spectra}">
						<tr>
							<td><a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${tSpectrum.getPeakForestID()}">${tSpectrum.getPeakForestID()}</a> ${fn:escapeXml(tSpectrum.getMassBankName())} </td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
				</c:if>
				<c:if test="${!spectrum_has_related_spectra}">
					<spring:message code="page.spectrum.metadata.sample.txtNoRelatedSpectrum" text="No related spectrum" />
				</c:if>
			</div>
		</div>
	</div>
	
	<div class="tab-pane " id="more_metadata">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.identifier" text="Identifier" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-unstyled" style="max-width: 700px;">
					<li style="margin: 5px;">
						<div class="input-group" style="width: 100%;">
							<span class="input-group-addon">PeakForest ID <i class="fa fa-database" aria-hidden="true"></i></span> 
							<input id="pfID" class="form-control pf-autofocus" value="${spectrum_pfID}" > 
						</div>
					</li>
					<li style="margin: 5px;">
						<div class="input-group" style="width: 100%;">
							<span class="input-group-addon">PeakForest URL <i class="fa fa-globe" aria-hidden="true"></i></span> 
							<input id="pfURL" class="form-control pf-autofocus" value="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum_pfID}" > 
						</div>
					</li>
					<c:if test="${not empty spectrum_splash}">
						<li style="margin: 5px;">
							<div class="input-group" style="width: 100%;">
								<!-- 
								Wohlgemuth, G, et al., SPLASH, a Hashed Identifier for Mass Spectra. Nature Biotechnology 34, 1099-101 (2016). 
								doi:10.1038/nbt.3689
								 -->
								<span class="input-group-addon">Splash 
									<a href="http://www.nature.com/nbt/journal/v34/n11/full/nbt.3689.html" target="_blank">
										<i class="fa fa-question-circle" aria-hidden="true"></i>
									</a>
								</span> 
								<input id="pfSplash" class="form-control pf-autofocus" value="${spectrum_splash}" > 
							</div>
						</li>
					</c:if>
				</ul>
				<script type="text/javascript">
				var pfID = '${spectrum_pfID}';
				$("#pfID").keydown(function (event){
					if (event.keyCode === 8) { event.preventDefault(); }					
				}).keypress(function (event){
					event.preventDefault();
				}).bind("paste",function(e) {
					e.preventDefault();
				}).bind("cut",function(e) {
					setTimeout(function(){$("#pfID").val(pfURL);}, 1);
				});
				var pfURL = '<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum_pfID}';
				$("#pfURL").keydown(function (event){
					if (event.keyCode === 8) { event.preventDefault(); }					
				}).keypress(function (event){
					event.preventDefault();
				}).bind("paste",function(e) {
					e.preventDefault();
				}).bind("cut",function(e) {
					setTimeout(function(){$("#pfURL").val(pfURL);}, 1);
				});
				var pfSplash = '${spectrum_splash}';
				$("#pfSplash").keydown(function (event){
					if (event.keyCode === 8) { event.preventDefault(); }					
				}).keypress(function (event){
					event.preventDefault();
				}).bind("paste",function(e) {
					e.preventDefault();
				}).bind("cut",function(e) {
					setTimeout(function(){$("#pfSplash").val(pfURL);}, 1);
				});
				</script>
			</div>
		</div>
		<c:if test="${spectrum_type == 'nmr-1d' || spectrum_type == 'nmr-2d'}">
			<div class="panel panel-default">
				<div class="panel-heading">
					<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.rawFileData" text="Extracted from the raw file" /></h3>
				</div>
				<div class="panel-body">
					<c:if test="${display_real_spectrum}">
						<pre id="asyncNmrDataProcessing" class="nmrDataProcessing">...loading!</pre>
						<span class="pull-right">
							<small><spring:message code="page.spectrum.metadata.message.nmrDataPoweredBy" text="NMR files data processing are powered thanks nmrRead tool (Dec 2015 &copy; INRA - Daniel Jacob)" /></small>
						</span>
						<script type="text/javascript">
	function rawFileProcessingData() {
		$.ajax({
			type: 'get',
			url: 'show-raw-file-processing/${real_spectrum_code}'
		}).done(function(data){
			if (data!="")
				$("#asyncNmrDataProcessing").html(data.replace(/\n/gi, "<br>"));
			else 
				$("#asyncNmrDataProcessing").html("file is empty.");
		}).fail(function(data){
			var alert = 'could not show raw file processing content.';
			$("#asyncNmrDataProcessing").html(alert);
		});
		
	}
	rawFileProcessingData();
						</script>
					</c:if>
					<c:if test="${not display_real_spectrum}">
						<spring:message code="page.spectrum.metadata.message.noRawFileUploaded" text="<h3>Sorry <small>no NMR raw file uploaded and linked to this spectrum</small></h3>" />
					</c:if>
					<!-- update -->
					<c:if test="${editor}">
						<!-- upload new raw file -->
						<br />
						<div class="pull-right">
							<br />
							<span id="rawNmrFileUploadContainer"></span>
							<div id="addRawNmrFileFormContent" class="input-group pull-right" style="max-width: 350px;">
								<span class="input-group-btn">
										<span class="btn btn-primary btn-file-nmr-raw btn-file"> Browse&#133;
											<input id="rawNmrFile" type="file" name="file" accept=".zip">
										</span>
					<!-- 					multiple="" -->
										<input type="hidden" name="ajaxUpload" value="true">
										<input id="raw_file_spectrum_id" name="spectrum_id" type="hidden" value="${spectrum_id}" />
								</span> <input type="text" class="form-control" readonly>
							</div>
							<br />
							<small>
								Add / overwrite this data with a new Raw file. <br />
								You must Zip the directory of you acquisition data to upload it.
							</small>
							<br />
							<br />
						</div>
						<div class="">
						</div>
						<div id="rawNmrFileUploading" class="" style="display:none;" >
							<br />
							<br />
							<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
						</div>
						<div id="rawNmrFileUploadResults" class="" style="display:none;" >
						</div>
						<div id="rawNmrFileUploadError" class="" style="max-width: 350px;" ></div>
	<script type="text/javascript">
	//
	checkUploadRawNmrFileForm=function() {
		if ($("#rawNmrFile").val()=='') {
			return false;
		}
		return true;
	};
	//file upload
	$(document).on('change', '.btn-file-nmr-raw.btn-file :file', function() {
		var input = $(this),
		numFiles = input.get(0).files ? input.get(0).files.length : 1,
		label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
		input.trigger('fileselect', [numFiles, label]);
	});
	$(document).ready( function() {
		$('.btn-file-nmr-raw.btn-file :file').on('fileselect', function(event, numFiles, label) { 
			var input = $(this).parents('.input-group').find(':text'),
			log = numFiles > 1 ? numFiles + ' files selected' : label;
			if(input.length) {
				input.val(log);
				// startUpload();
				$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadForm");
				$("#rawNmrFileUploadForm").submit();
			} else {
				if(log) alert(log);
			}
		});
	
		$("#rawNmrFileUploadForm").ajaxForm({
			beforeSubmit: startUploadRawNmrFile,
			success: function(data) {
				var tabData = {};
				$.each(data.trim().split("\n"),function(k, v) {
					var tData = (v).split("=");
					tabData[tData[0]] = tData[1];
				}); 
				if (tabData["success"] == "true") {
					if ((tabData["reload"] == "true")) { location.reload(); }
					else {
						if (tabData["procFiles"]) {
							stringInfo = "select proc. file: <ul>";
							var files = tabData["procFiles"].split(",");
							$.each(files, function(k,v) {
								if (v!="")
									stringInfo += '<li><a onclick="submitRawNmrFile_addProcFile(\''+v+'\')">'+v+"</a></li>";
							});
						} else if (tabData["files"]) {
							stringInfo = "select aq. file: <ul>";
							var files = tabData["files"].split(",");
							$.each(files, function(k,v) {
								if (v!="")
									stringInfo += '<li><a onclick="submitRawNmrFile_addAqFile(\''+v+'\')">'+v+"</a></li>";
							});
						}
						stringInfo += "</ul>";
						var infoBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
						infoBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						infoBox += '<strong>Need more details</strong> ' + stringInfo;
						infoBox += ' </div>';
						$("#rawNmrFileUploadError").html(infoBox);
					}
				} else {
					var stringError = "";
					if (tabData["error"] == "no_file_selected")
						stringError = "no file selected!";
					else if (tabData["error"] == "wrong_ext")
						stringError = "wrong file extension";
					else if (tabData["error"] == "empty_file")
						stringError = "uploaded file is empty";
					else 
						stringError = "an error occured; please contact dev. team!";
					var errorBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
					errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> ' + stringError;
					errorBox += ' </div>';
					$("#rawNmrFileUploadError").html(errorBox);
				}
				$("#rawNmrFileUploading").hide();
				$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadContainer");
			},
			error: function() {
				// TODO alert message
				var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
					errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
					errorBox += ' </div>';
					$("#rawNmrFileUploadError").html(errorBox);
				$("#rawNmrFileUploading").hide();
				$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadContainer");
			}
		});
	});
	
	function startUploadRawNmrFile() {
		$("#rawNmrFileUploadError").html("");
		$("#rawNmrFileUploading").show();
		//
	}
	
	function submitRawNmrFile_addAqFile(file) {
		$("#rawNmrFileUploadForm").append('<input type="hidden" name="aq_file" value="'+file+'">');
		$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadForm");
		$("#rawNmrFileUploadForm").submit();
	}
	function submitRawNmrFile_addProcFile(file) {
		$("#rawNmrFileUploadForm").append('<input type="hidden" name="proc_file" value="'+file+'">');
		$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadForm");
		$("#rawNmrFileUploadForm").submit();
	}
	
	</script>
					</c:if>
				</div>
			</div>
		</c:if>
	</div>
	
</div>
<script type="text/javascript">
$.each($(".cpdFormula"), function(k,v) {
	var elem = $(v);
	var rawFromula = elem.html();
	var formatedFormula = rawFromula + "";
	$.each($.unique( rawFromula.match(/\d+/g)), function (keyF, valF) {
		var re = new RegExp(valF,"g");
		formatedFormula = formatedFormula.replace(re, "<sub>" + valF + "</sub>");
	});
	formatedFormula = formatedFormula.replace("</sub><sub>", "");
	elem.html(formatedFormula);
});
</script>
																
									</div><!-- .cardSheet2 -->
								</div>
							</div>
						</fieldset>
					</form>
				</div>
			</div>
			<c:if test="${editor}">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							 <spring:message code="modal.show.curationMessages" text="Add Curation message" />  <i class="fa fa-comments"></i>
						</h4>
					</div>
					
					<div id="cardSheet6" class="">
						<c:if test="${not empty waitingCurationMessageUser}">
							<table class="table ">
								<c:forEach var="curationMessage" items="${waitingCurationMessageUser}">
									<tr class="warning">
										<td>${curationMessage.message}</td>
									</tr>
								</c:forEach>
							</table>
						</c:if>
						<div id="newCurationMessage" style="width: 650px; margin: auto;"><br></div>
						<div class="input-group">
							<span class="input-group-addon" style="width: 200px;">
									<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.curationMessages.newCurationMessage" text="new curation message" />
							</span> 
								<span>
								<input type="text" id="cc_addNewCurationMessage" style="width: 400px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.curationMessages.newCurationMessage.ph" text="new message..." />">
<!-- 												<select id="cm_priority" class="form-control pull-left"style="width: 150px; border-radius: 0px;"></select> -->
							</span>
							<span class="input-group-btn " style="width: 50px;">  
								<span class="input-group-btn">
									<button class="btn btn-default" type="button" onclick="addNewCurationMessageAction();" style="border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-top-left-radius: 0px; border-bottom-left-radius: 0px"><i class="fa fa-plus-square"></i></button>
								</span>
							</span>
							<script type="text/javascript">
							
							var newCurationMessages = new Object();
							
							$("#cc_addNewCurationMessage").keypress(function(event) {
								if (event.keyCode == 13) {
									addNewCurationMessageAction();
								}
								if ($("#cc_addNewCurationMessage").val().length > 100) { return false; }
							});
							
							addNewCurationMessageAction = function() {
								var message = $('#cc_addNewCurationMessage').val();
								var idMessage = md5("curationMessage" + message);
								if (message != '') {
									if ($('#CM-'+idMessage).length != 0)
										alert ('<spring:message code="modal.show.curationMessages.alert.aleradyEntered" text="message already entered!" />');
									else {
										newCurationMessages[idMessage] = message;
										var newDiv = '<div id="CM-'+idMessage+'" class="alert alert-warning alert-dismissible" role="alert">';
										newDiv += '<button type="button" class="close" data-dismiss="alert" onclick="deleteCurationMessageAction(\''+idMessage+'\')">';
										newDiv += '<span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
										newDiv += message;
										newDiv += '</div>';
										$("#newCurationMessage").append(newDiv);
										$('#cc_addNewCurationMessage').val('');
									}
								}
							};
							deleteCurationMessageAction =function(idMessage) {
								delete newCurationMessages[idMessage];
								$('#CM-'+idMessage).remove();
							}
							</script>
						</div>
					</div>
				</div>
				</c:if>
			<div class="pull-right" style="padding-top: 10px;">
				<c:if test="${!editor}">
				<button type="button" class="btn btn-default" onclick="window.history.back();"><spring:message code="modal.close" text="Close" /></button>
				</c:if>
				<c:if test="${editor}">
				<button type="button" class="btn btn-default" onclick="window.history.back();"><spring:message code="modal.cancel" text="Cancel" /></button>
				</c:if>
<!-- 				<a class="btn btn-default" -->
<%-- 					href="print-compound-modal/${type}/${id}" data-toggle="modal" --%>
<!-- 					data-target="#modalPrintCompound" -->
<!-- 					onclick=""> -->
<%-- 					<i class="fa fa-print"></i> <spring:message code="modal.show.btn.print" text="Print" /></a> --%>
				<c:if test="${editor}">
				<button type="button" onclick="updateCurrentSpectra(${id})" class="btn btn-primary">
					<i class="fa fa-save"></i> <spring:message code="modal.saveChanges" text="Save Changes" />
				</button>
				<script type="text/javascript">
				var newCurrationMessagesList = [];
				updateCurrentSpectra = function(id) {
					newCurrationMessagesList = [];
					$.each(newCurationMessages, function(k,v){ newCurrationMessagesList.push(v); });
					$.ajax({
						type: "POST",
						url: "update-spectrum/" + id,
						data: JSON.stringify({ curationMessages: newCurrationMessagesList }),
						contentType: 'application/json',
						success: function(data) {
							if(data) { 
// 								closeCompoundEntity();
								location.reload();
							} else {
								alert('<spring:message code="page.spectrum.alert.failUpdateSpectrum" text="Failed to update spectrum!" />'); 
							}
						}, 
						error : function(data) {
							console.log(data);
							// alert('<spring:message code="page.spectrum.alert.failUpdateSpectrum" text="Failed to update spectrum!" />'); 
						}
					});
				};
				</script>
				</c:if>
				<c:if test="${curator}">
				<a class="btn btn-info" href="edit-spectrum-modal/${spectrum_id}" data-toggle="modal"
					data-target="#modalEditSpectrum">
					<i class="fa fa-pencil"></i> <spring:message code="modal.edit" text="Edit" />
				</a>
				<script type="text/javascript">
					$("a[data-target=#modalEditSpectrum]").click(function(ev) {
						ev.preventDefault();
						// close this modal
						//$('#modalShowCompound').modal('hide');
						//setTimeout(function() { $('.modalShowCompound').modal('hide'); }, 200);
						reopenDetailsModal = false;
						reopenDetailsSheet = true;
						var target = $(this).attr("href");
						// load the url and show modal on success
						$("#modalEditSpectrum .modal-dialog ").load(target, function() { $("#modalEditSpectrum").modal("show"); });
					});
				</script>
				</c:if>
				<br>
				<br>
				<br>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
	
	<div id="ajaxModuleMSSpectrum<%=randomID %>"></div>
	<div id="ajaxModuleNMRSpectrum<%=randomID %>"></div>
	
	<script type="text/javascript">
	loadSheetSpectrum<%=randomID %> = function (idSpectrum, titleSpectrum, typeSpectrum) {
		// seek title
		var rawSpectrumTitle = titleSpectrum;
		titleSpectrum = encodeURIComponent(titleSpectrum);
		if (typeSpectrum == 'lc-fullscan' || typeSpectrum == 'lc-fragmentation'
				|| typeSpectrum == 'gc-fullscan'
				|| typeSpectrum == 'ic-fullscan'
				|| typeSpectrum == 'ic-fragmentation'
				) {
			// set element to load
			var spectrumFullScanLCToLoad = [];
			var spectrumFragLCToLoad = [];
			var spectrumFullScanGCToLoad = [];
			var spectrumFullScanICToLoad = [];
			var spectrumFragICToLoad = [];
			if (typeSpectrum == 'lc-fullscan')
				spectrumFullScanLCToLoad.push(idSpectrum);
			else if ( typeSpectrum == 'lc-fragmentation')
				spectrumFragLCToLoad.push(idSpectrum);
			else if (typeSpectrum == 'gc-fullscan')
				spectrumFullScanGCToLoad.push(idSpectrum);
			else if (typeSpectrum == 'ic-fullscan')
				spectrumFullScanICToLoad.push(idSpectrum);
			else if (typeSpectrum == 'ic-fragmentation')
				spectrumFragICToLoad.push(idSpectrum);
			// load ajax
			$.ajax({
				type: "post",
				url: "load-ms-spectra",
				data: "fullscan-lc=" + spectrumFullScanLCToLoad + "&frag-lc=" + spectrumFragLCToLoad 
						+ "&fullscan-gc=" + spectrumFullScanGCToLoad
						+ "&fullscan-ic=" + spectrumFullScanICToLoad
						+ "&frag-ic=" + spectrumFragICToLoad
						+"&name="+ titleSpectrum
						+"&mode=single&id=<%=randomID %>",
				// dataType: "script",
				async: false,
				success: function(data) {
					$("#containerMSspectrum").html("");
					$("#ajaxModuleMSSpectrum<%=randomID %>").html(data);
				}, 
				error : function(data) {
					console.log(data);
					// TODO display (nice) error message to user
				}
			});
		} else if (typeSpectrum == 'nmr' ) {
			// <c:if test="${not display_real_spectrum}">
			// set element to load
			var spectrumNMRToLoad = [];
			spectrumNMRToLoad.push(idSpectrum);
			// load ajax
			$.ajax({
				type: "post",
				url: "load-nmr-1d-spectra",
				data: "nmr=" + spectrumNMRToLoad + "&name="+ titleSpectrum+"&mode=single&id=<%=randomID %>",
				// dataType: "script",
				async: false,
				success: function(data) {
					$("#containerNMRspectrum").html("");
					$("#ajaxModuleNMRSpectrum<%=randomID %>").html(data);
				}, 
				error : function(data) {
					console.log(data);
					// TODO display (nice) error message to user
				}
			});
			// </c:if>
			// <c:if test="${display_real_spectrum}">
			setTimeout(function(){
				var scriptsURL = ('<c:url value="/resources/nmrpro/specdraw.min.css" />').replace("specdraw.min.css","");
				var jsonURL = "spectrum-json";
				loadSpectrumNMRPro ("container_nmrpro<%=randomID %>", "${real_spectrum_code}", rawSpectrumTitle, scriptsURL, jsonURL)
			},150);
			// </c:if>
		}
	}
	
	
	// load!!!
	loadSheetSpectrum<%=randomID %>('${spectrum_id}', "${spectrum_name}", '${spectrum_type}');

	
	$(document).ready(function(){
		var initialEvent = $('#linkDumpSpectrum')[0].onclick;
		$('#linkDumpSpectrum').click(function(){
			var id = Number(0${spectrum_id});
			// get name
			var name = "${fn:escapeXml(spectrum_name)}";
			// load icon
			$("#linkDumpSpectrum i").removeClass("fa-file-excel-o");
			$("#linkDumpSpectrum i").addClass("fa-spinner fa-pulse");
			$("#linkDumpSpectrum").removeAttr("onclick");
			$.ajax({
				type: "post",
				url: "spectrum-xlsm-export",
				data: "id=" + id + "&name=" + encodeURIComponent(name) + "",
				// dataType: "script",
				async: false,
				success: function(data) {
					if (data.success) {
						$("#linkDumpSpectrum").attr("href", data.href);
						$("#linkDumpSpectrum").attr("target", "_blank");
					} else 
						alert("sorry; could not export data into XLSM file");
// 					$('#linkDumpSpectrum').trigger('click');
				}, 
				error : function(data) {
					console.log(data);
					alert("sorry; could not export data into XLSM file");
					// TODO display (nice) error message to user
				}
			}).always(function() {
				$("#linkDumpSpectrum i").removeClass("fa-spinner fa-pulse");
				$("#linkDumpSpectrum i").addClass("fa-file-excel-o");
// 				$("#linkDumpSpectrum").removeAttr("onclick");
			});
		}).click(initialEvent);
	});
	
	checkIfReOpenDetailsModal = function() {}
	
	var jsMolLoaded = false;
	var jsMolSRC = false;
	refreshJSmol = function() {
		if (!jsMolSRC) {
// 			var iframe = document.getElementById("jsmol"),
// 			doc = iframe.contentWindow.document;
			$.get("js_sandbox/${spectrum_id}", function( data ) {
// 				doc.open().write(data);
// 				doc.close();
				$("#jsmol").html(data)
				jsMolSRC = true;
			});
		}
// 		try {
// 			if (!jsMolLoaded && /firefox/.test(navigator.userAgent.toLowerCase())) {
// 				document.getElementById("jsmol").contentDocument.location.reload(true);
// 				jsMolLoaded = true;
// 			} else {
// 				document.getElementById("jsmol").contentWindow.refreshJSmol();
// 			}
// 		} catch(e) {}
	}
	</script>

<div class="modal" id="modalShowCompound" tabindex="-1" role="dialog" aria-labelledby="modalShowCompoundLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content modalLarge">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalShowCompoundLabel">Modal title</h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-primary">Save changes</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- MODAL - PRINT CPD-->
<div class="modal " id="modalPrintCompound" tabindex="-1" role="dialog" aria-labelledby="modalPrintCompoundLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalPrintCompoundLabel">Modal title</h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal print -->
<!-- MODAL - EDIT CPD-->
<div class="modal " id="modalEditCompound" tabindex="-1" role="dialog" aria-labelledby="modalEditCompoundLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalEditCompoundLabel">Modal title</h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal edit -->
<!-- MODAL - EDIT spectrum -->
<div class="modal " id="modalEditSpectrum" tabindex="-1" role="dialog" aria-labelledby="modalEditSpectrumLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalEditSpectrumLabel">Modal title</h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal edit -->

<!-- select chemical cpd - PREVIEW -->
<div class="modal" id="modalPickCompound" tabindex="-1" role="dialog" aria-labelledby="modalPickCompoundLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalPickCompoundLabel">Pick a compound</h4>
			</div>
			<div class="modal-body">
			
				<div class="form-group input-group">
					<span class="input-group-addon">Compound Name</span>
					<input id="add-one-cc-s1-value" class="form-control" placeholder="e.g. Caffeine" type="text">
					<span class="input-group-btn">
						<button class="btn btn-default" type="button" onclick="searchLocalCompound();">
							<i class="fa fa-search"></i>
						</button>
					</span>
				</div>
				<div id="load-step-1" style="display: none;">
					<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait">
				</div>
				<div id="ok-step-1" style="overflow: auto; max-height: 300px;"></div>
				
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-danger" data-dismiss="modal" onclick="clearLine()"><i class="fa fa-eraser"></i> Clear</button>
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="showEditModalBack()"><spring:message code="modal.close" text="Close" /></button>
				<!--        <button type="button" class="btn btn-primary"><spring:message code="modal.saveChanges" text="Save Changes" /></button>-->
			</div>
		</div>
	</div>
</div>

<script src="<c:url value="/resources/js/md5.min.js" />"></script>
	<div style="display:none;">
		<form id="fileUploadForm" action="upload-compound-numbered-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadChemFileForm()">
		</form>
		<form id="rawNmrFileUploadForm" action="upload-nmr-raw-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadRawNmrFileForm()">
		</form>
	</div>

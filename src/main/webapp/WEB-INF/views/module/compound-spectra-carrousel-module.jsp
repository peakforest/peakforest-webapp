<%@page import="java.util.Random"%>
<%@page import="fr.metabohub.peakforest.utils.Utils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>

<!-- javascript -->
<script type="text/javascript">
var tabTypeSpectrum<%=randomID %> = [];
var tabIdSpectrum<%=randomID %> = [];
var tabNameSpectrum<%=randomID %> = [];
var tabMassBankNameSpectrum<%=randomID %> = [];
var tabHasRawSpectrum<%=randomID %> = [];
var tabRawSpectrumName<%=randomID %> = [];
</script>

<div id="carousel-spectrum<%=randomID %>" class="carousel slide"
	data-ride="carousel">
	<!-- Indicators -->
	<ol class="carousel-indicators">
		<% int cptSpectrumDisplayed = 0; %>
		<c:forEach var="spectrum" items="${spectrum_mass_fullscan_lc}">
			<li data-target="#carousel-spectrum<%=randomID %>" data-slide-to="<%=cptSpectrumDisplayed %>" <% if(cptSpectrumDisplayed ==0) { out.print("class=\"active\"");} %>></li>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_mass_fragmt_lc}">
			<li data-target="#carousel-spectrum<%=randomID %>" data-slide-to="<%=cptSpectrumDisplayed %>" <% if(cptSpectrumDisplayed ==0) { out.print("class=\"active\"");} %>></li>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_nmr}">
			<li data-target="#carousel-spectrum<%=randomID %>" data-slide-to="<%=cptSpectrumDisplayed %>" <% if(cptSpectrumDisplayed ==0) { out.print("class=\"active\"");} %>></li>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<!-- TODO each GC -->
	</ol>

	<!-- Wrapper for slides -->
	<div class="carousel-inner">
		<!-- item -->
		<% cptSpectrumDisplayed = 0; %>
		<c:forEach var="spectrum" items="${spectrum_mass_fullscan_lc}">
			<div class="item <% if(cptSpectrumDisplayed ==0) { out.print("active");} %>">
				<table class="table" style="width:90%">
					<tr>
						<td width="20px"></td>
						<td width="">
							<!--container-->
							<div id="containerLCspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="min-width: 650px; ${set_width} height: 300px; margin: 0 auto">
								loading LC-MS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td style="z-index: 2000;">
			<c:choose>
				<c:when test="${spectrum_load_legend}">
							<div id="lcSpectrumMoreInfo<%=randomID %><%=cptSpectrumDisplayed %>">
								&nbsp;&nbsp;&nbsp;<a id="lcSpectrumMoreInfoTxt<%=randomID %><%=cptSpectrumDisplayed %>" onclick="showHideLcSpectrumMoreInfoContent<%=randomID %><%=cptSpectrumDisplayed %>()" href="javascript:void(0)">details...</a>
								<div id="lcSpectrumMoreInfoContent<%=randomID %><%=cptSpectrumDisplayed %>" style="display: none;">
									<table class="table">
										<tbody>
											<tr>
												<th style="white-space: nowrap;">Spectrum data</th>
												<th style="white-space: nowrap;">Spectrum metadata</th>
												<th style="white-space: nowrap;">Spectrum legal informations</th>
											</tr>
											<tr>
												<td>
													<ul class="list-group">
														<li class="list-group-item">Name(s): <span id="metadataLC_names<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<!-- <li class="list-group-item">Type(s): <span id="metadataLC_codes<%=randomID %><%=cptSpectrumDisplayed %>"></span></li> -->
														<li class="list-group-item">RT: <span id="metadataLC_rt<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">polarity: <span id="metadataLC_polarity<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">ionization(s): <span id="metadataLC_ionization<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
													</ul>
												</td>
												<td>
													<ul class="list-group">
														<li class="list-group-item">Type(s): <span id="metadataLC_type<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">Date(s): TODO</li>
													</ul>
												</td>
												<td>
													<ul class="list-group">
														<li class="list-group-item">Author(s): <span id="metadataLC_authors<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">Owner(s): <span id="metadataLC_owners<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">License(s): <span id="metadataLC_copyright<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
													</ul>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
				</c:when>
				<c:when test="${spectrum_load_complementary_data}">
				<c:if test="${isExt}">
				<a href="<spring:message code="peakforest.uri.compound" text="https://peakforest.org/" />${(compound_pfID)}" target="_blank">
					${(compound_main_name)}
				</a> / LC-MS / <a target="_blank" href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
				</c:if>
				<c:if test="${not isExt}">
				<a onclick="closeSpectraModal();" href="show-compound-modal/${compound_type}/${compound_id}" data-toggle="modal" data-target="#modalShowCompound">
					${(compound_main_name)}
				</a> / LC-MS / <a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
				</c:if>
				<br>
				<br>
				</c:when>
				<c:otherwise><br></c:otherwise>
			</c:choose>
						</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='lc-fullscan';
				tabIdSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				<c:if test="${spectrum.polarity == 1}">
					tabNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='MS-POS';
				</c:if>
				<c:if test="${spectrum.polarity == -1}">
					tabNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='MS-NEG';
				</c:if>
				tabMassBankNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>] = "${fn:escapeXml((spectrum.getMassBankNameHTML()))}";
				</script>
			</div>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_mass_fragmt_lc}">
			<div class="item <% if(cptSpectrumDisplayed ==0) { out.print("active");} %>">
				<table class="table" style="">
					<tr>
						<td width="20px"></td>
						<td width="">
							<!--container-->
							<div id="containerLCspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="width: 650px; height: 300px; margin: 0 auto">
								loading LC-MS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td style="z-index: 2000;">
			<c:choose>
				<c:when test="${spectrum_load_legend}">
						DETAILS
				</c:when>
				<c:when test="${spectrum_load_complementary_data}">
				<a href="show-compound-modal/${compound_type}/${compound_id}" data-toggle="modal" data-target="#modalShowCompound">
					${compound_main_name}
				</a> / LC-MSMS / <a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
				<br>
				<br>
				</c:when>
				<c:otherwise><br></c:otherwise>
			</c:choose>
						</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='lc-fragmentation';
				tabIdSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				<c:if test="${spectrum.polarity == 1}">
					tabNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='MSX-POS';
				</c:if>
				<c:if test="${spectrum.polarity == -1}">
					tabNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='MSX-NEG';
				</c:if>
				tabMassBankNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>] = "${fn:escapeXml((spectrum.getMassBankNameHTML()))}";
				</script>
			</div>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_nmr}">
			<div class="item <% if(cptSpectrumDisplayed ==0) { out.print("active");} %>">
				<table class="table" style="width:90%">
					<tr>
						<td width="20px"></td>
						<td width="">
							<c:if test="${not spectrum.hasRawData()}">
								<!--container-->
								<div id="containerNMRspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
									style="min-width: 650px; height: 300px; margin: 0 auto" class="hiddenSpectra">
									loading NMR spectra... <br />
									<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
										title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
								</div>
							</c:if>
							<c:if test="${spectrum.hasRawData()}">
								<c:if test="${spectrum.getAcquisitionAsString() == 'Proton-1D' || spectrum.getAcquisitionAsString() == 'NOESY-1D' || spectrum.getAcquisitionAsString() == 'CPMG-1D'}">
									<!--stgraph-->
									<div id="stgraph<%=randomID %><%=cptSpectrumDisplayed %>" style="min-width: 650px; min-height: 300px;" class="hiddenSpectra stgraph-light-plus">
										loading NMR spectra... <br />
										<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
											title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
									</div>
								</c:if>
								<c:if test="${spectrum.getAcquisitionAsString() == 'Carbon13-1D' || spectrum.getAcquisitionAsString() == 'COSY-2D' || spectrum.getAcquisitionAsString() == 'TOCSY-2D' || spectrum.getAcquisitionAsString() == 'NOESY-2D' || spectrum.getAcquisitionAsString() == 'HMBC-2D' || spectrum.getAcquisitionAsString() == 'HSQC-2D'}">
									<!-- static image -->
									<img class="spectraLightImgMol" alt="${spectrum.getMassBankLikeName()}" title="${spectrum.getMassBankLikeName()}" src="spectra_img/${fn:escapeXml(spectrum.getRawDataFolder())}.png">
								</c:if>
							</c:if>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td style="z-index: 2000;">
			<c:choose>
				<c:when test="${spectrum_load_legend}">
							<div id="nmrSpectrumMoreInfo<%=randomID %><%=cptSpectrumDisplayed %>">
								&nbsp;&nbsp;&nbsp;<a id="nmrSpectrumMoreInfoTxt<%=randomID %><%=cptSpectrumDisplayed %>" onclick="showHideNmrSpectrumMoreInfoContent<%=randomID %><%=cptSpectrumDisplayed %>()" href="javascript:void(0)">details...</a>
								<div id="nmrSpectrumMoreInfoContent<%=randomID %><%=cptSpectrumDisplayed %>" style="display: none;">
									<table class="table">
										<tbody>
											<tr>
												<th style="white-space: nowrap;">Spectrum data</th>
												<th style="white-space: nowrap;">Spectrum metadata</th>
												<th style="white-space: nowrap;">Spectrum legal informations</th>
											</tr>
											<tr>
												<td>
													<ul class="list-group">
														<li class="list-group-item">Name(s): <span id="metadataNMR_names<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<!-- <li class="list-group-item">Type(s): <span id="metadataNMR_codes<%=randomID %><%=cptSpectrumDisplayed %>"></span></li> -->
													</ul>
												</td>
												<td>
													<ul class="list-group">
														<li class="list-group-item">Type(s): <span id="metadataNMR_type<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">Date(s): TODO</li>
													</ul>
												</td>
												<td>
													<ul class="list-group">
														<li class="list-group-item">Author(s): <span id="metadataNMR_authors<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">Owner(s): <span id="metadataNMR_owners<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
														<li class="list-group-item">License(s): <span id="metadataNMR_copyright<%=randomID %><%=cptSpectrumDisplayed %>"></span></li>
													</ul>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
				</c:when>
				<c:when test="${spectrum_load_complementary_data}">
				<c:if test="${isExt}">
				<a href="<spring:message code="peakforest.uri.compound" text="https://peakforest.org/" />${(compound_pfID)}" target="_blank">
					${(compound_main_name)}
				</a> / NMR / <a target="_blank" href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
				</c:if>
				<c:if test="${not isExt}">
				<a onclick="closeSpectraModal();" href="show-compound-modal/${compound_type}/${compound_id}" data-toggle="modal" data-target="#modalShowCompound" onclick="$('#modalShowSpectra').modal('hide');" >
					${(compound_main_name)}
				</a> / NMR / <a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
				</c:if>
				<br>
				<br>
				</c:when>
				<c:otherwise><br></c:otherwise>
			</c:choose>
						</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				// <c:if test="${spectrum.getAcquisitionAsString() == 'Proton-1D' || spectrum.getAcquisitionAsString() == 'NOESY-1D' || spectrum.getAcquisitionAsString() == 'CPMG-1D' || spectrum.getAcquisitionAsString() == 'Carbon13-1D'}">
				tabTypeSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='nmr-1d';
				// </c:if>
				// <c:if test="${spectrum.getAcquisitionAsString() == 'COSY-2D' || spectrum.getAcquisitionAsString() == 'JRES-2D' || spectrum.getAcquisitionAsString() == 'TOCSY-2D' || spectrum.getAcquisitionAsString() == 'NOESY-2D' || spectrum.getAcquisitionAsString() == 'HMBC-2D' || spectrum.getAcquisitionAsString() == 'HSQC-2D'}">
				tabTypeSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='nmr-2d';
				// </c:if>
				tabIdSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]='${spectrum.pulseSequence}';
				tabMassBankNameSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>] = "${fn:escapeXml((spectrum.getMassBankNameHTML()))}";
				
				
				// <c:if test="${spectrum.getAcquisitionAsString() == 'Proton-1D' || spectrum.getAcquisitionAsString() == 'NOESY-1D' || spectrum.getAcquisitionAsString() == 'CPMG-1D'}">
				tabHasRawSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]=('${fn:escapeXml(spectrum.hasRawData())}' === 'true');
				// </c:if>
				// <c:if test="${spectrum.getAcquisitionAsString() == 'Carbon13-1D' || spectrum.getAcquisitionAsString() == 'COSY-2D' || spectrum.getAcquisitionAsString() == 'JRES-2D' || spectrum.getAcquisitionAsString() == 'TOCSY-2D' || spectrum.getAcquisitionAsString() == 'NOESY-2D' || spectrum.getAcquisitionAsString() == 'HMBC-2D' || spectrum.getAcquisitionAsString() == 'HSQC-2D'}">
				tabHasRawSpectrum<%=randomID %>[<%=cptSpectrumDisplayed %>]=(false);
				// </c:if>
				tabRawSpectrumName<%=randomID %>[<%=cptSpectrumDisplayed %>]='${fn:escapeXml(spectrum.getRawDataFolder())}';
				</script>
			</div>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
	</div>

	<!-- Controls -->
	<a class="left carousel-control" href="#carousel-spectrum<%=randomID %>" role="button" data-slide="prev">
		<span class="fa fa-caret-left"></span>
	</a>
	<a class="right carousel-control" href="#carousel-spectrum<%=randomID %>" role="button" data-slide="next"> 
		<span class="fa fa-caret-right"></span>
	</a>
</div>


<script type="text/javascript">
	// resize hidden div; 
	try {
		var maxDivWidth = parseInt(Number($("#cardSheet4").css("width").replace("px","")) * 0.8);
		var maxDivHeight = parseInt(Number($("#cardSheet4").css("height").replace("px","")) * 0.6);
		$(".hiddenSpectra").css("width", maxDivWidth + "px");
		$(".hiddenSpectra").css("height", maxDivHeight + "px");
	} catch (e) {}
	
	// I - spectrum functions
	// I.A - LC fullscan
	var currentChartTab<%=randomID %> = {};
	// destroy all
	if (!(typeof currentChartTab<%=randomID %> == "undefined")) {
		$.each(currentChartTab<%=randomID %>, function(index, chart) {
			try { chart.destroy(); } catch (e) {}
		});
	}
	//try { chart.destroy(); } catch (e) {}
	
	// I.B - LC frag
	// I.C - NMR
	// I.D - GC
	
	// II - carousel
	// II.A - load carousel js / css
	$('.carousel').carousel();
	$('.left.carousel-control').width('20px');
	$('.right.carousel-control').width('20px');
	$(".carousel-indicators").addClass('label label-primary');
	$("a.carousel-control span").css('margin-top', '160px');
	
	// II.B - init spectrum into carousel;
	var maxItem<%=randomID %> = <%=cptSpectrumDisplayed %> ;
	
	var isSpectrumLoaded<%=randomID %> = [];
	for(i = 0; i <= <%=cptSpectrumDisplayed %>; i++) {
		isSpectrumLoaded<%=randomID %>[i] = false;
	}
	// default
	// TODO load 0, n-1, n-2, n+1, n+2
	if (maxItem<%=randomID %>>5) {
		for(i = 0; i <= 5; i++) {
			if (!isSpectrumLoaded<%=randomID %>[i])
				loadSpectrum<%=randomID %>(i);
		}
		setTimeout(function() { 
			for(i = 5; i <= maxItem<%=randomID %>; i++) {
				if (!isSpectrumLoaded<%=randomID %>[i])
					loadSpectrum<%=randomID %>(i);
			}
		}, 200);
	} else {
		for(i = 0; i <= maxItem<%=randomID %>; i++) {
			if (!isSpectrumLoaded<%=randomID %>[i])
				loadSpectrum<%=randomID %>(i);
		}
	}
	
	// II.C - listen carousel
	var currentItem<%=randomID %> = 0;
	$('#carousel-spectrum<%=randomID %>').on('slide.bs.carousel', function () {
		console.log('next...');
		// get item to display
		var newItem = $('#carousel-spectrum<%=randomID %> .active').index('#carousel-spectrum<%=randomID %> .item');
		// next loop
		 currentItem<%=randomID %> = newItem;
	});
	
	function loadSpectrum<%=randomID %>(cpt) {
		// get correct id
		if (cpt > maxItem<%=randomID %>) 
			cpt = cpt - maxItem<%=randomID %>;
		else if (cpt < 0) 
			cpt = maxItem<%=randomID %> - cpt; 
		// check if loaded
		if (isSpectrumLoaded<%=randomID %>[i])
			 unloadSpectrum<%=randomID %>(cpt);
		// TODO load
		var typeSpectrum = tabTypeSpectrum<%=randomID %>[cpt];
		if (typeSpectrum == 'lc-fullscan' || typeSpectrum == 'lc-fragmentation') {
			// set element to load
			var spectrumFullScanLCToLoad = [];
			var spectrumFragLCToLoad = [];
			if (typeSpectrum == 'lc-fullscan')
				spectrumFullScanLCToLoad.push(tabIdSpectrum<%=randomID %>[cpt]);
			else if ( typeSpectrum == 'lc-fragmentation')
				spectrumFullScanLCToLoad.push(tabIdSpectrum<%=randomID %>[cpt]);
			// seek title
			var titleSpectrum = encodeURIComponent(tabMassBankNameSpectrum<%=randomID %>[cpt]); 
			// load ajax
			$.ajax({
				type: "post",
				//<c:if test="${isExt}">
				url: "<spring:message code="peakforest.uri" text="https://peakforest.org/" />load-lc-spetra",
				//</c:if>
				//<c:if test="${not isExt}">
				url: "load-lc-spetra",
				//</c:if>
				data: "fullscan=" + spectrumFullScanLCToLoad + "&frag=" + spectrumFragLCToLoad+"&name="+ titleSpectrum+"&mode=light&id=<%=randomID %>"+cpt,
				// dataType: "script",
				async: false,
				success: function(data) {
					$("#containerLCspectrum<%=randomID %>"+cpt+"").html("");
					$("#ajaxModuleLCSpectrum<%=randomID %>-"+cpt+"").html(data);
					isSpectrumLoaded<%=randomID %>[i] = true;
				}, 
				error : function(data) {
					console.log(data);
					// TODO display (nice) error message to user
				}
			});
		} else if (typeSpectrum == 'nmr-1d' ) {
			if (tabHasRawSpectrum<%=randomID %>[cpt]) {
				// display ML & DJ viewer 
				nmrSingle(tabRawSpectrumName<%=randomID %>[cpt], <%=randomID %>, cpt, tabMassBankNameSpectrum<%=randomID %>[cpt] );
			} else {
				// set element to load
				var spectrumNMRToLoad = [];
				spectrumNMRToLoad.push(tabIdSpectrum<%=randomID %>[cpt]);
				// seek title
				var titleSpectrum = encodeURIComponent("" + tabMassBankNameSpectrum<%=randomID %>[cpt]);
				// load ajax
				$.ajax({
					type: "post",
					//<c:if test="${isExt}">
					url: "<spring:message code="peakforest.uri" text="https://peakforest.org/" />load-nmr-1d-spectra",
					//</c:if>
					//<c:if test="${not isExt}">
					url: "load-nmr-1d-spectra",
					//</c:if>
					data: "nmr=" + spectrumNMRToLoad + "&name="+ titleSpectrum+"&mode=light&id=<%=randomID %>"+cpt,
					// dataType: "script",
					async: false,
					success: function(data) {
						$("#containerNMRspectrum<%=randomID %>"+cpt+"").html("");
						$("#ajaxModuleNMRSpectrum<%=randomID %>-"+cpt+"").html(data);
						isSpectrumLoaded<%=randomID %>[i] = true;
					}, 
					error : function(data) {
						console.log(data);
						// TODO display (nice) error message to user
					}
				});
			}
		} else if (typeSpectrum == 'nmr-2d' ) {
			if (tabHasRawSpectrum<%=randomID %>[cpt]) {
				// display ML & DJ viewer 
				nmrSingle(tabRawSpectrumName<%=randomID %>[cpt], <%=randomID %>, cpt, tabMassBankNameSpectrum<%=randomID %>[cpt] );
			} else {}
		}
	}
	
	
	function unloadSpectrum<%=randomID %>(cpt) {
	}
</script>

<% for (int i = 0; i<= cptSpectrumDisplayed; i++) { %>
<div id="ajaxModuleLCSpectrum<%=randomID %>-<%=i %>"></div>
<div id="ajaxModuleGCSpectrum<%=randomID %>-<%=i %>"></div>
<div id="ajaxModuleNMRSpectrum<%=randomID %>-<%=i %>"></div>
<script type="text/javascript">
var displayLcSpectrumMoreInfoContent<%=randomID %><%=i %> = false;
showHideLcSpectrumMoreInfoContent<%=randomID %><%=i %> = function() {
	displayLcSpectrumMoreInfoContent<%=randomID %><%=i %> = !displayLcSpectrumMoreInfoContent<%=randomID %><%=i %>;
	if (displayLcSpectrumMoreInfoContent<%=randomID %><%=i %>) {
		$("#lcSpectrumMoreInfoTxt<%=randomID %><%=i %>").html("hide details");
		$("#lcSpectrumMoreInfoContent<%=randomID %><%=i %>").show();
	} else {
		$("#lcSpectrumMoreInfoTxt<%=randomID %><%=i %>").html("show details...");
		$("#lcSpectrumMoreInfoContent<%=randomID %><%=i %>").hide();
	}
}

var displayNmrSpectrumMoreInfoContent<%=randomID %><%=i %> = false;
showHideNmrSpectrumMoreInfoContent<%=randomID %><%=i %> = function() {
	displayNmrSpectrumMoreInfoContent<%=randomID %><%=i %> = !displayNmrSpectrumMoreInfoContent<%=randomID %><%=i %>;
	if (displayNmrSpectrumMoreInfoContent<%=randomID %><%=i %>) {
		$("#nmrSpectrumMoreInfoTxt<%=randomID %><%=i %>").html("hide details");
		$("#nmrSpectrumMoreInfoContent<%=randomID %><%=i %>").show();
	} else {
		$("#nmrSpectrumMoreInfoTxt<%=randomID %><%=i %>").html("show details...");
		$("#nmrSpectrumMoreInfoContent<%=randomID %><%=i %>").hide();
	}
}

$(".carousel-caption").css('z-index',-10);

closeSpectraModal=function(){
	try{
		$("#modalShowSpectra").modal('hide');
	} catch(e){}
}

</script>
<% } %>
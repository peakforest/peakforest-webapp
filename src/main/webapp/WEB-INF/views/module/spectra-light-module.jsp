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

<!-- javascript -->
<script type="text/javascript">
var tabTypeSpectrum = [];
var tabIdSpectrum = [];
var tabNameSpectrum = [];
var tabHasRawSpectrum = [];
var tabRawSpectrumName = [];
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
		<c:forEach var="spectrum" items="${spectrum_mass_fullscan_gc}">
			<li data-target="#carousel-spectrum<%=randomID %>" data-slide-to="<%=cptSpectrumDisplayed %>" <% if(cptSpectrumDisplayed ==0) { out.print("class=\"active\"");} %>></li>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_nmr}">
			<li data-target="#carousel-spectrum<%=randomID %>" data-slide-to="<%=cptSpectrumDisplayed %>" <% if(cptSpectrumDisplayed ==0) { out.print("class=\"active\"");} %>></li>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
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
							<div id="containerMSspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="min-width: 650px; height: 300px; margin: 0 auto">
								loading LC-MS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td> &nbsp;</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum[<%=cptSpectrumDisplayed %>]='lc-fullscan';
				tabIdSpectrum[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum[<%=cptSpectrumDisplayed %>]='${fn:escapeXml((spectrum.getMassBankNameHTML()))}';
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
							<div id="containerMSspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="width: 650px; height: 300px; margin: 0 auto">
								loading LC-MSMS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td> &nbsp;</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum[<%=cptSpectrumDisplayed %>]='lc-fragmentation';
				tabIdSpectrum[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum[<%=cptSpectrumDisplayed %>]='${spectrum.getMassBankName()};';
				</script>
			</div>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_mass_fullscan_gc}">
			<div class="item <% if(cptSpectrumDisplayed ==0) { out.print("active");} %>">
				<table class="table" style="width:90%">
					<tr>
						<td width="20px"></td>
						<td width="">
							<!--container-->
							<div id="containerMSspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="min-width: 650px; height: 300px; margin: 0 auto">
								loading GC-MS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td> &nbsp;</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum[<%=cptSpectrumDisplayed %>]='gc-fullscan';
				tabIdSpectrum[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum[<%=cptSpectrumDisplayed %>]='${fn:escapeXml((spectrum.getMassBankNameHTML()))}';
				</script>
			</div>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		
		<c:forEach var="spectrum" items="${spectrum_mass_fullscan_ic}">
			<div class="item <% if(cptSpectrumDisplayed ==0) { out.print("active");} %>">
				<table class="table" style="width:90%">
					<tr>
						<td width="20px"></td>
						<td width="">
							<!--container-->
							<div id="containerMSspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="min-width: 650px; height: 300px; margin: 0 auto">
								loading IC-MS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td> &nbsp;</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum[<%=cptSpectrumDisplayed %>]='ic-fullscan';
				tabIdSpectrum[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum[<%=cptSpectrumDisplayed %>]='${fn:escapeXml((spectrum.getMassBankNameHTML()))}';
				</script>
			</div>
			<% cptSpectrumDisplayed++; %>
		</c:forEach>
		<c:forEach var="spectrum" items="${spectrum_mass_fragmt_lc}">
			<div class="item <% if(cptSpectrumDisplayed ==0) { out.print("active");} %>">
				<table class="table" style="width:90%">
					<tr>
						<td width="20px"></td>
						<td width="">
							<!--container-->
							<div id="containerMSspectrum<%=randomID %><%=cptSpectrumDisplayed %>"
								style="min-width: 650px; height: 300px; margin: 0 auto">
								loading IC-MS spectra... <br />
								<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
									title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
							</div>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td> &nbsp;</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum[<%=cptSpectrumDisplayed %>]='ic-fragmentation';
				tabIdSpectrum[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum[<%=cptSpectrumDisplayed %>]='${fn:escapeXml((spectrum.getMassBankNameHTML()))}';
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
									style="min-width: 650px; height: 300px; margin: 0 auto">
									loading NMR spectra... <br />
									<img src="<c:url value="/resources/img/ajax-loader-big.gif" />"
										title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
								</div>
							</c:if>
							<c:if test="${spectrum.hasRawData()}"> 
								<!-- static image -->
								<img class="spectraLightImg" alt="${spectrum.getMassBankLikeName()}" title="${spectrum.getMassBankLikeName()}" src="spectra_img/${fn:escapeXml(spectrum.getRawDataFolder())}.png">
								<script type="text/javascript">
								$(".pforest-spectra-name-${spectrum.getPeakForestID()}").html("${spectrum.getMassBankNameHTML()}");
								</script>
							</c:if>
						</td>
						<td width="20px"></td>
					</tr>
					<tr>
						<td></td>
						<td> &nbsp;</td>
						<td></td>
					</tr>
				</table>
				<div class="carousel-caption"></div>
				<script type="text/javascript">
				tabTypeSpectrum[<%=cptSpectrumDisplayed %>]='nmr';// spectrum_type
				tabIdSpectrum[<%=cptSpectrumDisplayed %>]=${spectrum.id};
				tabNameSpectrum[<%=cptSpectrumDisplayed %>]='${fn:escapeXml((spectrum.getMassBankNameHTML()))}';
				// <c:if test="${spectrum.getAcquisitionAsString() == 'Proton-1D' || spectrum.getAcquisitionAsString() == 'NOESY-1D' || spectrum.getAcquisitionAsString() == 'CPMG-1D'}">
				tabHasRawSpectrum[<%=cptSpectrumDisplayed %>]=('${fn:escapeXml(spectrum.hasRawData())}' === 'true');
				// </c:if>
				// <c:if test="${spectrum.getAcquisitionAsString() == 'Carbon13-1D' || spectrum.getAcquisitionAsString() == 'COSY-2D' || spectrum.getAcquisitionAsString() == 'TOCSY-2D' || spectrum.getAcquisitionAsString() == 'NOESY-2D' || spectrum.getAcquisitionAsString() == 'HMBC-2D' || spectrum.getAcquisitionAsString() == 'HSQC-2D'}">
				tabHasRawSpectrum[<%=cptSpectrumDisplayed %>]=(false);
				// </c:if>
				tabRawSpectrumName[<%=cptSpectrumDisplayed %>]='${fn:escapeXml(spectrum.getRawDataFolder())}';
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
	// I - spectrum functions
	// I.A - LC fullscan
	var currentChartTab = {};
	// destroy all
	if (!(typeof currentChartTab === "undefined")) {
		$.each(currentChartTab, function(index, chart) {
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
		var typeSpectrum = tabTypeSpectrum[cpt];
		if (typeSpectrum == 'lc-fullscan' || typeSpectrum == 'lc-fragmentation'  
				|| typeSpectrum == 'gc-fullscan'
				|| typeSpectrum == 'ic-fullscan'
				|| typeSpectrum == 'ic-fragmentation') {
			// set element to load
			var spectrumFullScanLCToLoad = [];
			var spectrumFragLCToLoad = [];
			var spectrumFullScanGCToLoad = [];
			var spectrumFullScanICToLoad = [];
			var spectrumFragICToLoad = [];
			if (typeSpectrum == 'lc-fullscan')
				spectrumFullScanLCToLoad.push(tabIdSpectrum[cpt]);
			else if ( typeSpectrum == 'lc-fragmentation')
				spectrumFragLCToLoad.push(tabIdSpectrum[cpt]);
			else if (typeSpectrum == 'gc-fullscan')
				spectrumFullScanGCToLoad.push(tabIdSpectrum[cpt]);
			else if (typeSpectrum == 'ic-fullscan')
				spectrumFullScanICToLoad.push(tabIdSpectrum[cpt]);
			else if (typeSpectrum == 'ic-fragmentation')
				spectrumFragICToLoad.push(tabIdSpectrum[cpt]);
			// seek title
			var titleSpectrum = encodeURIComponent("" + tabNameSpectrum[cpt]);
			// load ajax
			$.ajax({
				type: "post",
				url: "load-ms-spectra",
				data: "fullscan-lc=" + spectrumFullScanLCToLoad + "&frag-lc=" + spectrumFragLCToLoad 
						+ "&fullscan-gc=" + spectrumFullScanGCToLoad
						+ "&fullscan-ic=" + spectrumFullScanICToLoad 
						+ "&frag-ic=" + spectrumFragICToLoad
						+"&name="+ titleSpectrum
						+"&mode=light&id=<%=randomID %>"+cpt,
				// dataType: "script",
				async: false,
				success: function(data) {
					$("#containerMSspectrum<%=randomID %>"+cpt+"").html("");
					$("#ajaxModuleMSSpectrum<%=randomID %>-"+cpt+"").html(data);
					isSpectrumLoaded<%=randomID %>[i] = true;
				}, 
				error : function(data) {
					console.log(data);
					// TODO display (nice) error message to user
				}
			});
		} else if (typeSpectrum == 'nmr' || typeSpectrum == 'nmr-1d' || typeSpectrum == 'nmr-2d' ) {
			if (tabHasRawSpectrum[cpt]) {
			} else {
				// display "dumy" spectra
				// set element to load
				var spectrumNMRToLoad = [];
				spectrumNMRToLoad.push(tabIdSpectrum[cpt]);
				// seek title
				var titleSpectrum = encodeURIComponent ("" + tabNameSpectrum[cpt]);
				// load ajax
				$.ajax({
					type: "post",
					url: "load-nmr-1d-spectra",
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
		}
	}
	
	
	function unloadSpectrum<%=randomID %>(cpt) {
	}
</script>

<% for (int i = 0; i<= cptSpectrumDisplayed; i++) { %>
<div id="ajaxModuleMSSpectrum<%=randomID %>-<%=i %>"></div>
<div id="ajaxModuleNMRSpectrum<%=randomID %>-<%=i %>"></div>
<script type="text/javascript">


</script>
<% } %>
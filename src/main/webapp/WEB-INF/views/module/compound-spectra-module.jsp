<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<div>

		<!--JS page mode-->
		<script type="text/javascript">
		if (!(typeof currentChartTab == "undefined")) {
			$.each(currentChartTab, function(index, chart) {
				try { chart.destroy(); } catch (e) {}
			});
		}
//		try { chart.destroy(); } catch (e) {}
		</script>
		
	<ul class="nav nav-tabs" style="margin-bottom: 15px;">
		<c:if test="${first_tab_open =='lc-ms'}">
			<li<c:if test="${first_tab_open =='lc-ms'}"> class="active"</c:if>>
				<a href="#spectrum-mod-lc" data-toggle="tab"> <spring:message code="module.spectra.tag.lcms" text="LC-MS" /> </a>
			</li>
		</c:if>
		<c:if test="${first_tab_open !='lc-ms'}">
			<li class="disabled"><a><spring:message code="module.spectra.tag.lcms" text="LC-MS" /></a></li>
		</c:if>
		
		<c:if test="${not empty spectrum_nmr}">
			<li<c:if test="${first_tab_open =='nmr'}"> class="active"</c:if>>
				<a href="#spectrum-mod-nmr" data-toggle="tab"> <spring:message code="module.spectra.tag.nmr" text="NMR" /> </a>
			</li>
		</c:if>
		<c:if test="${empty spectrum_nmr}">
			<li class="disabled"><a><spring:message code="module.spectra.tag.nmr" text="NMR" /></a></li>
		</c:if>
		
		<c:if test="${not empty spectrum_mass_fullscan_gc}">
			<li<c:if test="${first_tab_open =='gc-ms'}"> class="active"</c:if>>
				<a href="#spectrum-mod-gc" data-toggle="tab"> <spring:message code="module.spectra.tag.gcms" text="GC-MS" /> </a>
			</li>
		</c:if>
		<c:if test="${empty spectrum_mass_fullscan_gc}">
			<li class="disabled"><a><spring:message code="module.spectra.tag.gcms" text="GC-MS" /></a></li>
		</c:if>
	</ul>
	<div id="spectrum-mod" class="tab-content">
		<div class="tab-pane fade <c:if test="${first_tab_open =='lc-ms'}">active in</c:if>" id="spectrum-mod-lc">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<div id="containerLCspectrum" style="min-width: 600px; height: 400px; margin: 0 auto">
							<spring:message code="module.spectra.load.lcms" text="loading LC-MS spectra..." />
							<br /><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
						</div>
					</td>
				</tr>
			</table>
		</div>
		<div class="tab-pane fade <c:if test="${first_tab_open =='nmr'}">active in</c:if>" id="spectrum-mod-nmr">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<div id="containerNMRspectrum" style="min-width: 600px; height: 400px; margin: 0 auto">
							<spring:message code="module.spectra.load.nmr" text="loading NMR spectra.." />
							<br /><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
						</div>
					</td>
				</tr>
			</table>
		</div>
		<div class="tab-pane fade <c:if test="${first_tab_open =='gc-ms'}">active in</c:if>" id="spectrum-mod-gc">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<div id="containerGCspectrum" style="min-width: 600px; height: 400px; margin: 0 auto">
							<spring:message code="module.spectra.load.gcms" text="loading GC-MS spectra..." />
							<br /><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
						</div>
					</td>
				</tr>
			</table>
		</div>
	</div>

</div>
<script type="text/javascript">
// LC-MS spectra
<c:if test="${not empty spectrum_mass_fullscan_lc || not empty spectrum_mass_fragmt_lc}">
$.get("compound-spectra-carrousel-full-module/${type}/${id}/lcms?isExt=false", function( data ) {
	$("#containerLCspectrum").html( data );
	console.log("spectrum lcms: ready!");
});
</c:if>

<c:if test="${not empty spectrum_nmr}">
// NMR
$.get("compound-spectra-carrousel-full-module/${type}/${id}/nmr?isExt=false", function( data ) {
	$("#containerNMRspectrum").html( data );
	console.log("spectrum nmr: ready!");
});
</c:if>

<c:if test="${not empty spectrum_mass_fullscan_gc}">
// GC-MS
$.get("compound-spectra-carrousel-full-module/${type}/${id}/gcms?isExt=false", function( data ) {
	$("#containerGCspectrum").html( data );
	console.log("spectrum gcms: ready!");
});
</c:if>

</script>
<div id="ajaxModuleLCSpectrum"></div>
<div id="ajaxModuleGCSpectrum"></div>
<div id="ajaxModuleNMRSpectrum"></div>
<%@page import="fr.metabohub.peakforest.model.maps.MapManager"%>
<%@page import="fr.metabohub.peakforest.utils.PeakForestUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<%
	boolean useMEwebservice = Boolean.parseBoolean(PeakForestUtils.getBundleConfElement("metexplore.ws.use"));
%>

<div class="panel panel-default">
	<div class="panel-heading">
		<h3 class="panel-title"><spring:message code="page.tools.statPF.titleTxt" text="Since may 2015 the PeakForest database is gathering Chemical Libraries and Spectra from each MetaboHUB partners." /></h3>
	</div>
	<div class="panel-body">
		
		<ul class="list-group" style="max-width: 600px;">
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbCC" text="Number of Chemical Compound:" /> <span id="nbCC"><i class="fa fa-refresh fa-spin"></i></span></li>
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbRCC" text="Number of Reference Chemical Compound:" /> <span id="nbRCC"><i class="fa fa-refresh fa-spin"></i></span></li>
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbNMRspectra" text="Number of NMR spectra:" /> <span id="nbNMRspectra"><i class="fa fa-refresh fa-spin"></i></span></li>
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbLCMSspectra" text="Number of LC-MS spectra:" /> <span id="nbLCMSspectra"><i class="fa fa-refresh fa-spin"></i></span></li>
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbLCMSMSspectra" text="Number of LC-MSMS spectra:" /> <span id="nbLCMSMSspectra"><i class="fa fa-refresh fa-spin"></i></span></li>
		  <!-- new 2.1 -->
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbGCMSspectra" text="Number of GC-MS spectra:" /> <span id="nbGCMSspectra"><i class="fa fa-refresh fa-spin"></i></span></li>
		  <!-- new 2.3 -->
		  
		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbICMSspectra" text="Number of IC-MS spectra:" /> <span id="nbICMSspectra"><i class="fa fa-refresh fa-spin"></i></span></li>
<%-- 		  <li class="list-group-item"><spring:message code="page.tools.statPF.nbICMSMSspectra" text="Number of IC-MSMS spectra:" /> <span id="nbICMSMSspectra"><i class="fa fa-refresh fa-spin"></i></span></li> --%>
		  <!-- meta stat -->
		  <li class="list-group-item"><spring:message code="page.tools.statPF.perCentRccOneSpectra" text="Percentage of Ref. Chemical Compound with at least one spectrum:" /> <span id="perCentRccOneSpectra"><i class="fa fa-refresh fa-spin"></i></span>%</li>
		</ul>
<%
	if (useMEwebservice) {
%>
		<small><spring:message code="page.tools.statPF.refMEtxt1" text="For Biological informations: please refer to" /> <a id="clickMetExploreStat" href="#"><spring:message code="page.tools.statPF.refMEtxt2" text="MetExplore statistics" /></a>.</small>
<%
	}
%>
	</div>
</div>
<br />
<small class="pull-right"><spring:message code="page.tools.statPF.lastUpdate" text="Last update:" /> <span id="statPeakforestLastUpdate"></span>.</small>
<!-- <div class="panel panel-default"> -->
<!-- 	<div class="panel-heading"> -->
<!-- 		<h3 class="panel-title">Chemical informations</h3> -->
<!-- 	</div> -->
<!-- 	<div class="panel-body"> -->
<!-- 		<ul class="list-group" style="max-width: 600px;"> -->
<!-- 		  <li class="list-group-item">Number of Ref. Compound: XXX</li> -->
<!-- 		  <li class="list-group-item">Number of Generic Compound: XX</li> -->
<!-- 		  <li class="list-group-item">Number of Sub-Structure Compound: XXX</li> -->
<!-- 		  <li class="list-group-item">Number of Putative Compound: XX</li> -->
<!-- 		  <li class="list-group-item">Number of Spectra per Thechnic: XX</li> -->
<!-- 		</ul> -->
<!-- 		<small>For Biological informations: please refer to <a id="clickMetExploreStat" href="#">MetExplore statistics</a>.</small> -->
<!-- 	</div> -->
<!-- </div> -->
<script type="text/javascript">
$("#clickMetExploreStat").on( "click", function() {
	$('#linkMetExploreStats').trigger('click');
});

$( document ).ready(function() {
	$.getJSON('json/pforest-statistics.json', function(jsonData) {
		$("#nbCC").html(jsonData.number_chemical_compounds);
		var nbRCC = jsonData.number_generic_compounds + jsonData.number_chemical_compounds;
		$("#nbRCC").html(nbRCC);
		$("#nbNMRspectra").html(jsonData.number_nmr_spectra);
		$("#nbLCMSspectra").html(jsonData.number_lcms_spectra);
		$("#nbLCMSMSspectra").html(jsonData.number_lcmsms_spectra);
		// new 2.1
		$("#nbGCMSspectra").html(jsonData.number_gcms_spectra);
		// new 2.3
		$("#nbICMSspectra").html(jsonData.number_icms_spectra);
		$("#nbICMSMSspectra").html(jsonData.number_icmsms_spectra);
		// meta
		var percent = roundNumber((jsonData.number_of_compound_with_one_or_more_spectrum/nbRCC) *100,2);
		$("#perCentRccOneSpectra").html(percent);
		// date
		try {
			var date = new Date(jsonData.updated);
			var dateString = date.toGMTString();
			$("#statPeakforestLastUpdate").html(dateString);
		} catch (e) {}
	});
});	

</script>

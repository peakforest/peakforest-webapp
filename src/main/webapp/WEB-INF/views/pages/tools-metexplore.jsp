<%@page import="fr.metabohub.peakforest.model.maps.MapManager"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<img src="<c:url value="/resources/img/Logo_Metexplore_80px.png"  />" title="MetExplore" align="left" style="padding-right:10px;" />
<div>
	<spring:message code="page.tools.statME.txtLg1" text="This table shows how PeakForest chemical library covers genome scale reconstructions of metabolic networks" />. 
	<spring:message code="page.tools.statME.txtLg2" text="This mapping is performed using MetExplore webservice" />. 
	<spring:message code="page.tools.statME.txtLg3" text="MetExplore stores metabolic networks coming from various sources (SBML files, KEGG, BioCyc)" />. 
<br /><spring:message code="page.tools.statME.txtLg4" text="If you want to perform mapping of your data in networks, please visit" /> <a href="http://www.metexplore.fr" target="_blank">metexplore.fr</a>.
</div>
<br />
<br />
<div id="loadMapMetExplore"><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" /></div>
<table id="tabMapMetExplore" class="table table-bordered table-hover table-striped tablesorter" style="display:none;">
	<thead>
		<tr>
			<th><spring:message code="page.tools.statME.tab.metaboNetwork" text="Metabolic network" /> <i class="fa fa-sort"></i></th>
			<th><spring:message code="page.tools.statME.tab.nbMetaboInNetwork" text="Number of metabolites in the network" /> <i class="fa fa-sort"></i></th>
			<th><spring:message code="page.tools.statME.tab.metaboFoundInPF" text="Metabolites found in PeakForest" /> <i class="fa fa-sort"></i></th>
			<th><spring:message code="page.tools.statME.tab.peakforestCoverage" text="Coverage of PeakForest chemical compounds in Metabolic network" /> <i class="fa fa-sort"></i></th>
		</tr>
	</thead>
	<tbody id="tabMapMetExploreBody">
	</tbody>
</table>

<button id="showAllBiosources" class="btn btn-primary" onclick="showAllMetExplore();" type="button" style="display:none;"><i class="fa fa-eye"></i> <spring:message code="page.tools.statME.btn.showAllBiosources" text="Show all biosources" /> </button>
<br />
<br />
<spring:message code="page.tools.statME.txtData1" text="This table is automatically generated once a week in order to keep up to date with latest changes in both PeakForest and MetExplore" />.
<br />
<br />
<i>
	<spring:message code="page.tools.statME.txtData2" text="Note: number of metabolites in each network is not covering the entire of each metabolome" />. 
	<spring:message code="page.tools.statME.txtData3" text="Indeed some parts like lipids are defined by compound families (e.g. a sphingolipid)" />. 
	<spring:message code="page.tools.statME.txtData4" text="Moreover, since these reconstructions are based on genome they may miss some reactions" />.
</i>
<br /><small class="pull-right"><spring:message code="page.tools.statME.lastUpdate" text="Last update:" /> <span id="dateString"></span>.</small>

<script type="text/javascript">
$.get("get-map/<%=MapManager.MAP_METEXPLORE%>", function(data) {
	// console.log(data);
	var dataInTable = [];
	var lastUpdateDate = null;
	if (data.length==0) {
		$("#tabMapMetExploreBody").parent().parent().html("service not available, please try again later");
		return;
	}
	$.each(data, function(){
		var raw = {};
		raw.biosourceId = this.biosourceId;
		raw.organism = "" + this.organism;
		raw.biosource = (this.biosource != null) ? " (" +this.biosource + ")" : "";
		raw.display = (this.displayDefault);
		raw.nbCpdMatched = this.nbMetabolitesMappedFromPForestInBiosource;
		raw.nbCpdTotBiosource = this.nbMetabolitesInBiosource;
		raw.coverage = this.coverage;
		// add to table
		dataInTable.push(raw);
		lastUpdateDate = this.created;
	});
	if (lastUpdateDate!=null) {
		try {
			var date = new Date(lastUpdateDate);
			var dateString = date.toGMTString();
			$("#dateString").html(dateString);
		} catch (e) {}
	}
	$("#templateMetExplore").tmpl(dataInTable).appendTo("#tabMapMetExploreBody");
	$("#loadMapMetExplore").hide();
	$("#tabMapMetExplore").show();
	$("#showAllBiosources").show();
	setTimeout(function() { $('table').trigger('update'); }, 250);
});

showAllMetExplore = function() {
	$("#showAllBiosources").hide();
	$(".hiddenMetExplore").show();
	setTimeout(function() { $('table').trigger('update'); }, 250);
}

</script>

<script  type="text/x-jquery-tmpl" id="templateMetExplore">
	{%if display == true %}
		<tr class="" style=""><!--  white-space: nowrap; -->
	{%/if%}
	{%if display == false %}
		<tr class="hiddenMetExplore" style="display:none;" ><!--  white-space: nowrap; -->
	{%/if%}
			<td class="">
				<a href="<spring:message code="resources.maplink.metexplore" text="http://metexplore.toulouse.inra.fr/metexplore2/?idBioSource=" />{%= biosourceId%}" target="_blank">
					<em>{%= organism%}</em>
					<small>{%= biosource%}</small>
				</a>
			</td>
			<td>{%= nbCpdTotBiosource%}</td>
			<td>{%= nbCpdMatched%}</td>
			<td>{%= coverage%} %</td>
		</tr>
</script>

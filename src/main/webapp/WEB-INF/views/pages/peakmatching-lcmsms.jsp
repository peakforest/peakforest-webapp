<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="org.jsoup.Jsoup"%>
<%@page import="org.jsoup.safety.Whitelist"%>
<%@ page session="false"%>
<%
	String searchLCMSMS = "";
	if (request.getParameter("searchLCMSMS") != null && request.getParameter("searchLCMSMS") != "") {
		// search results
		searchLCMSMS = request.getParameter("searchLCMSMS").toString();
		searchLCMSMS = Jsoup.clean(searchLCMSMS, Whitelist.basic());
	}
%>
<!-- ######################################################### QUERY -->
<div class="col-lg-12">
	<form method="get" action="home" id="searchFormLCMSMS" autocomplete="off">
		<div class="form-group input-group" style="max-width: 600px;">
			<input type="hidden" name="page" value="peakmatching">
			<input id="searchLCMSMS" name="searchLCMSMS" type="text" class="form-control" 
			placeholder="peak matching query" data-provide="typeahead" value="<%=searchLCMSMS%>">
			<span class="input-group-btn">
				<button id="peakmatchingLCMSMSmodalBtn" class="btn" type="button"><spring:message code="page.peakmatching.btn.peakMatching" text="Peak Matching" /></button>
				<button id="searchLCMSMSButton" class="btn btn-primary" type="submit" title="<spring:message code="page.peakmatching.label.search" text="search" />">
					<i class="fa fa-search"></i>
				</button>
			</span>
		</div>
	</form>
</div>
<!-- ######################################################### OPT FILTERS -->
<div id="searchLCMSMSfilterDiv" class="highlight" style="">
	<a href="#" onclick="hideshow('add-lcmsms-filter-form')"><spring:message code="page.peakmatching.txt.addFilters" text="add filters" /></a>
	<form id="add-lcmsms-filter-form" class="form-inline"
		style="display: none;" onsubmit="addLCMSMSfilter(); return false;">
		<div class="form-group">
			<div class="input-group" style="width: 500px;">
				<div class="input-group-btn" style="width:200px;">
					<select id="filterLCMSMStype" class="form-control">
						<option value="1"><spring:message code="page.peakmatching.txt.ionizationMethod" text="ionization meth." /></option>
						<option value="2"><spring:message code="page.peakmatching.txt.ionAnalyzerType" text="ion analyzer type" /></option>
						<option value="3"><spring:message code="page.peakmatching.txt.cpdName" text="cpd name" /></option>
					</select>
				</div>
				<select id="filterLCMSMSIonizationMethodValue" class="form-control filterType" style="width: 200px;"></select>
				<input type="text" class="form-control filterType" id="filterLCMSMStextIonAnalyzerValue" style="width:200px; display:none;"
					placeholder="<spring:message code="page.peakmatching.txt.ionAnalyzerType.ph" text="e.g.: QTOF" />">
				<input type="text" class="form-control filterType" id="filterLCMSMStextCpdNameValue" style="width:200px; display:none;"
					placeholder="<spring:message code="page.peakmatching.txt.cpdNameExp" text="e.g.: Glucose" />">
				<div class="input-group-btn" style="width:100px;">
					<button type="submit" style="" class="btn btn-success"><i class="fa fa-plus"></i></button>
				</div>
			</div>
		</div>
	</form>
	<br />
	<div id="filterLCMSMSdisplay" class=""></div>
</div>
<!-- ######################################################### RESULTS -->
<div id="noLCMSMSSearchResults" style="display:none;"> <h4><spring:message code="page.search.results.noResults.sorry" text="<h4>Sorry" /> <small><spring:message code="page.search.results.noResults.txt" text="no result match you query." /></small></h4></div>
<div class="loadSearchResults" style="display:none;"><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" /></div>
<table id="spectrumLCMSMSResultsTable" class="table table-hover tablesorter tablesearch" style="display: none;">
	<thead>
		<tr>
			<th># <i class="fa fa-sort"></i></th>
			<th><spring:message code="page.search.results.spectra.name" text="Name" /> <i class="fa fa-sort"></i></th>
			<th></th>
			<th><spring:message code="page.search.results.spectra.score" text="Score" /> <i class="fa fa-sort"></i> </th>
			<th> </th>
			<th> <spring:message code="page.search.results.spectra.preview" text="Preview" /></th>
		</tr>
	</thead>
	<tbody id="spectrumLCMSMSResultsTableBody">
		
	</tbody>
</table>
<div class="col-lg-12">
	<ul id="searchLCMSMSPagination" class="pagination pagination-sm" style="display: none;">
	</ul>
</div>

<!-- table template -->
<script  type="text/x-jquery-tmpl" id="templateLCMSMSSpectra">
{%if type == 'lcms'%}
<tr>
	<td>
		{%= pfID%}
	</td>
	<td>
		<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />{%= pfID%}">{%= name%}</a>
	</td>
	<td>{%= metaCol%}</td>
	<td>{%= score%}</td>
	<td>
		<img class="minispectra" src="resources/img/spectra/{%= img%}.png" alt="{%= img%}" />
		{%if compound.inchikey%}
		<span class="avatar">
			<img class="compoundSVG" src="image/{%= compound.type%}/{%= compound.inchikey%}" alt="{%= compound.name%}" />
		</span>
		{%/if%}
	</td>
	<td>
		<a href="show-spectra-modal/{%= id%}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o"></i></a>
		{%if compound.inchikey%}
		&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="addRemoveCpdFromCart({%= compound.id%})" class="btn-cpd-cart btn btn-xs btn-success"><i class="fa fa-plus-circle addRemoveCpd{%= compound.id%}"></i><i class="fa fa-shopping-cart"></i></a>
		{%/if%}
	</td>
</tr>
{%/if%}
</script>

<!-- Modal LCMSMS peakmatching -->
<div class="modal " id="LCMSMSModal" tabindex="-1" role="dialog" aria-labelledby="LCMSMSModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                 <h4 class="modal-title" id="LCMSMSModalLabel">Modal title</h4>

            </div>
            <div class="modal-body"><div class="te"></div></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script>

$.getJSON("resources/json/list-ms-ionization-methods.json", function(data) {
	$("#filterLCMSMSIonizationMethodValue").empty();
	$("#filterLCMSMSIonizationMethodValue").append('<option value="" selected="selected" disabled="disabled"><spring:message code="page.peakmatching.txt.ionizationMethod.default" text="choose in list&hellip;" /></option>');
	// load data from json
	$.each(data.methods,function(){
		if (this.name !==undefined) {
			if (this.value !==undefined) {
				$("#filterLCMSMSIonizationMethodValue").append('<option value="'+this.value+'">'+this.name+'</option>');
			} else {
				$("#filterLCMSMSIonizationMethodValue").append('<option disabled>'+this.name+'</option>');
			}
		}
	});
});

var TXT_LABEL__IONIZATION_METHOD = "<spring:message code="page.peakmatching.txtjs.ionizationMethod" text="Ionization Meth." />";
var TXT_LABEL__ION_ANALYZER = "<spring:message code="page.peakmatching.txtjs.ionAnalyzerType" text="Ion Analyzer" />";

closeLCMSMSsearchModal = function() {
	// $($(".peakmatchingLCMSMSform")[0]).change();
	$("#LCMSMSModal").modal('close');
	setTimeout(function(){$('#searchLCMSMS').focus();},250);
}
</script>
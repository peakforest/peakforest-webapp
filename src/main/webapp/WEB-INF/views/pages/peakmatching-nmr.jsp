<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="org.jsoup.Jsoup"%>
<%@page import="org.jsoup.safety.Whitelist"%>
<%@ page session="false"%>
<%
	String searchNMR = "";
	if (request.getParameter("searchNMR") != null && request.getParameter("searchNMR") != "") {
		// search results
		searchNMR = request.getParameter("searchNMR").toString();
		searchNMR = Jsoup.clean(searchNMR, Whitelist.basic());
	}
%>
<!-- ######################################################### QUERY -->
<div class="col-lg-12">
	<form method="get" action="home" id="searchFormNMR" autocomplete="off">
		<div class="form-group input-group" style="max-width: 600px;">
			<input type="hidden" name="page" value="peakmatching">
			<input id="searchNMR" name="searchNMR" type="text" class="form-control" 
			placeholder="peak matching query" data-provide="typeahead" value="<%=searchNMR%>">
			<span class="input-group-btn">
				<button id="peakmatchingNMRmodalBtn" class="btn" type="button"><spring:message code="page.peakmatching.btn.peakMatching" text="Peak Matching" /></button>
				<button id="searchNMRButton" class="btn btn-primary" type="submit" title="<spring:message code="page.peakmatching.label.search" text="search" />">
					<i class="fa fa-search"></i>
				</button>
			</span>
		</div>
	</form>
</div>
<!-- ######################################################### OPT FILTERS -->
<div id="searchNMRfilterDiv" class="highlight" style="">
	<a href="#" onclick="hideshow('add-nmr-filter-form')"><spring:message code="page.peakmatching.txt.addFilters" text="add filters" /></a>
	<form id="add-nmr-filter-form" class="form-inline"
		style="display: none;" onsubmit="addNMRfilter(); return false;">
		<div class="form-group">
			<div class="input-group" style="width: 600px;">
				<div class="input-group-btn" style="width: 300px;">
					<select id="filterNMRtype" class="form-control">
						<option value="1"><spring:message code="page.peakmatching.txt.magneticFieldStrength" text="magnetic field strength" /></option>
						<option value="2"><spring:message code="page.peakmatching.txt.pulseSeq" text="pulse seq." /></option>
						<option value="3"><spring:message code="page.peakmatching.txt.cpdName" text="cpd name" /></option>
						<option value="4"><spring:message code="page.peakmatching.txt.solvent" text="solvent" /></option>
					</select>
				</div>
				<select id="filterNMRmagneticValue" class="form-control filterType" style="width: 200px;">
					<option value="500">500</option>
					<option value="600">600</option>
					<option value="800">800</option>
				</select>
				<select id="filterNMRpulseqValue" class="form-control filterType" style="width: 200px; display:none">
					<option value="Proton">Proton</option>
					<option value="NOESY">NOESY</option>
					<option value="CPMG">CPMG</option>
				</select>
				<select id="filterNMRsolventValue" class="form-control filterType" style="width: 200px; display:none"></select>
				<input type="text" class="form-control filterType" id="filterNMRtextValue" style="width: 200px; display:none;" placeholder="<spring:message code="page.peakmatching.txt.cpdNameExp" text="e.g.: Glucose" />">
				<div class="input-group-btn" style="width: 100px;">
					<button type="submit" style="" class="btn btn-success">
						<i class="fa fa-plus"></i>
					</button>
				</div>
			</div>
		</div>
	</form>
	<br />
	<div id="filterNMRdisplay" class=""></div>
</div>
<!-- ######################################################### RESULTS -->
<div id="noNMRSearchResults" style="display:none;"> <h4><spring:message code="page.search.results.noResults.sorry" text="<h4>Sorry" /> <small><spring:message code="page.search.results.noResults.txt" text="no result match you query." /></small></h4></div>
<div class="loadSearchResults" style="display:none;"><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" /></div>
<table id="spectrumNMRResultsTable" class="table table-hover tablesorter tablesearch" style="display: none;">
	<thead>
		<tr>
			<th># <i class="fa fa-sort"></i></th>
			<th><spring:message code="page.search.results.spectra.name" text="Name" /> <i class="fa fa-sort"></i></th>
			<th><spring:message code="page.search.results.spectra.score" text="Score" /> <i class="fa fa-sort"></i> </th>
			<th> </th>
			<th> <spring:message code="page.search.results.spectra.preview" text="Preview" /></th>
		</tr>
	</thead>
	<tbody id="spectrumNMRResultsTableBody">
		
	</tbody>
</table>
<div class="col-lg-12">
	<ul id="searchNMRPagination" class="pagination pagination-sm" style="display: none;">
	</ul>
</div>

<!-- table template -->
<script  type="text/x-jquery-tmpl" id="templateNMRSpectra">
{%if type == 'nmr'%}
<tr>
	<td>
		{%= pfID%}
	</td>
	<td>
		<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/peakforest-webapp/" />{%= pfID%}">{%= name%}</a>
	</td>
	<td>{%= score%}</td>
	<td>
		<img class="minispectra" src="resources/img/spectra/{%= img%}.png" alt="{%= img%}" />
		{%if compound.inchikey%}
		<span class="avatar">
			<img class="compoundSVG" src="image/{%= compound.type%}/{%= compound.inchikey%}.svg" alt="{%= compound.name%}" />
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

<!-- Modal NMR peakmatching -->
<div class="modal " id="NMRModal" tabindex="-1" role="dialog" aria-labelledby="NMRModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                 <h4 class="modal-title" id="NMRModalLabel">Modal title</h4>

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

$.getJSON("resources/json/list-nmr-solvents.json", function(data) {
	$("#filterNMRsolventValue").empty();
	$("#filterNMRsolventValue").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	// load data from json
	$.each(data.solvents,function(){
		$("#filterNMRsolventValue").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
	});
});


var TXT_LABEL__MAGNETIC_FIELD = "<spring:message code="page.peakmatching.txtjs.magneticField" text="magnetic field" />", TXT_LABEL__PULSE_SEQ = "<spring:message code="page.peakmatching.txtjs.pulse" text="pulse seq." />", TXT_LABEL__CPD_NAME = "<spring:message code="page.peakmatching.txtjs.cpdName" text="cpd name" />";
var TXT_LABEL__SOLVENT = "<spring:message code="page.peakmatching.txtjs.solvent" text="solvent" />";
// $("#NMRModal").on('hidden.bs.modal', function () {
// 	if ($("#searchNMR").val().trim()=="")
// 		$("#NMRModal").modal('show');
// });

// $('#NMRModal').modal({
//     backdrop: 'static',
//     keyboard: false
// });

closeNMRsearchModal = function() {
	// $($(".peakmatchingNMRform")[0]).change();
	$("#NMRModal").modal('hide');
	setTimeout(function(){$('#searchNMR').focus();},250);
}
</script>
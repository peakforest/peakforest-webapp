<%@page import="org.jsoup.Jsoup"%>
<%@page import="org.jsoup.safety.Whitelist"%>
<%@page import="fr.metabohub.peakforest.services.SearchService"%>
<%@page import="fr.metabohub.peakforest.utils.PeakForestUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<%
	if (request.getParameter("search") != null && request.getParameter("search") != "") {
		// search results
		String search = request.getParameter("search").toString();
		search = Jsoup.clean(search, Whitelist.basic());
%>
<div class="row">
	<div class="col-lg-12">
		<form method="get" action="home" id="searchForm" autocomplete="off">
			<div class="form-group input-group" style="max-width: 600px;">
				<input id="search" name="search" type="text" class="form-control" onfocus="this.value = this.value;"
					placeholder="<spring:message code="page.search.searchEG" text="e.g. Glucose" />" data-provide="typeahead"
					value="<%=search%>"> 
				<span class="input-group-btn">
					<button id="advancedBtn" class="btn" type="button"><spring:message code="page.search.searchAdvancedButton" text="Advanced" /></button>
					<button id="searchButton" class="btn btn-primary" type="button" title="<spring:message code="page.search.searchButton" text="search" />">
						<i class="fa fa-search"></i>
					</button>
				</span>
			</div>
		</form>
	</div>

	<div id="search-results" class="col-lg-12">
<!-- 	search results start -->
	<%
		// TODO ?
	%>
		<div class="table-responsive">
			<div class="loadSearchResults" style="display:none;"><img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" /></div>
			
			<!-- result tab spectrum -->
			<table id="spectrumResultsTable" class="table table-hover tablesorter tablesearch" style="display:none;">
				<thead>
					<tr>
						<th><spring:message code="page.search.results.spectra.name" text="Name" /> <i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.spectra.score" text="Score" /> <i class="fa fa-sort"></i> </th>
						<th> </th>
						<th> <spring:message code="page.search.results.spectra.preview" text="Preview" /></th>
					</tr>
				</thead>
				<tbody id="spectrumResultsTableBody">
				</tbody>
			</table>
			
			<!-- result tab cpd -->
			<table id="compoundResultsTable" class="table table-hover tablesorter tablesearch" style="display:none;">
				<thead>
					<tr>
						<th><spring:message code="page.search.results.cpt.structure" text="Structure" /></th>
						<th><spring:message code="page.search.results.cpt.compoundName" text="Chemical Name" /> <i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.cpt.formula" text="Formula" /> <i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.cpt.exactMass" text="Exact mass" /> / <spring:message code="page.search.results.cpt.averageMass" text="Average mass" /> <spring:message code="page.search.results.cpt.massUnit" text="(Da)" /><i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.cpt.detailsSpectraPrint" text="Details / Spectra / Print" /></th>
					</tr>
				</thead>
				<tbody id="compoundResultsTableBody">
				</tbody>
			</table>
			
			<!-- TODO result tab metadata -->
			<div id="noSearchResults" style="display:none;"> <h4><spring:message code="page.search.results.noResults.sorry" text="<h4>Sorry" /> <small><spring:message code="page.search.results.noResults.txt" text="no result match you query." /></small></h4></div>
			<div id="divEntityDetails" style="display:none;"></div>
		</div>
		<!-- 	search results end -->
	</div>

<script  type="text/x-jquery-tmpl" id="templateCompounds">
<tr>
	<td>
		<span class="avatar">
			<img class="compoundSVG" src="image/{%= type%}/{%= inchikey%}.svg" alt="{%= name%}" />
		</span>
	</td>
	<td>
		<a href="<spring:message code="peakforest.uri.compound" text="https://peakforest.org/" />{%= pfID%}">{%= name%}</a>
	</td>
	<td class="compoundFormula">{%= formula%}</td>
	<td>{%= exactMass%} / {%= molWeight%}</td>
	<td>
		<a href="show-compound-modal/{%= type%}/{%= id%}" data-toggle="modal" data-target="#modalShowCompound"><i class="fa fa-info-circle"></i></a>
		&nbsp;&nbsp;&nbsp;&nbsp; 
		{%if spectra%}
		<a href="show-compound-spectra-modal/{%= type%}/{%= id%}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o"></i></a>
		&nbsp;&nbsp;&nbsp;&nbsp;
		{%else%}
		<i style="color: lightgray" class="fa fa-bar-chart-o"></i>
		&nbsp;&nbsp;&nbsp;&nbsp;
		{%/if%}
		<a href="print-compound-modal/{%= type%}/{%= id%}" data-toggle="modal" data-target="#modalPrintCompound"><i class="fa fa-print"></i></a> 
		&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="addRemoveCpdFromCart({%= id%})" class="btn-cpd-cart btn btn-xs btn-success"><i class="fa fa-plus-circle addRemoveCpd{%= id%}"></i><i class="fa fa-shopping-cart"></i></a>
	</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateSpectra">
<tr>
	<td>
		<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />{%= pfID%}">{%= name%}</a>
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
</script>
	<div class="col-lg-12">
		<ul id="searchPagination" class="pagination pagination-sm">
<!-- 			<li class="disabled"><a href="#">&laquo;</a></li> -->
<!-- 			<li class="active"><a href="#">1</a></li> -->
<!-- 			<li><a href="#">2</a></li> -->
<!-- 			<li class="disabled"><a href="#">&hellip;</a></li> -->
<!-- 			<li><a href="#">6</a></li> -->
<!-- 			<li><a href="#">&raquo;</a></li> -->
		</ul>
		<span class="pull-right"><small id="searchExtraInfo"></small></span>
	</div>
	
	<!-- MODAL - SHOW -->
	<div class="modal" id="modalShowCompound" tabindex="-1" role="dialog"
		aria-labelledby="modalShowCompoundLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content modalLarge">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
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
	<!-- /.modal -->

	<!-- MODAL - PRINT -->
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
	<!-- MODAL - EDIT -->
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

</div>
<!-- /.row -->
<%
	} else {
		// init search
%>
<div class="row">
	<div class="col-lg-12">
		<h1>
			<img alt="PeakForest" style="margin-top: -35px;" src="<c:url value="/resources/img/logo_pfx200.png" />"> <small> <spring:message code="page.search.subtitle" text="a spectral data portal for Metabolomics community" /></small>
		</h1>
		<form method="get" action="home" id="searchForm" autocomplete="off">
			<div class="form-group input-group"
				style="padding-top: 112px; max-width: 600px; margin: auto;">
				<input name="search" id="search" type="text" class="form-control" placeholder="<spring:message code="page.search.searchEG" text="e.g. Glucose" />">
				<ul id="autoCompleteLoadingPanel" class="typeahead dropdown-menu" style="display: none;"><li><p style="margin-left: 10px;">Loading data...</p></li></ul>
				<span class="input-group-btn">
					<button id="advancedBtn" class="btn" type="button"><spring:message code="page.search.searchAdvancedButton" text="Advanced" /></button>
					<button id="searchButton" class="btn btn-primary" type="button" title="<spring:message code="page.search.searchButton" text="search" />">
						<i class="fa fa-search"></i>
					</button>
				</span>
			</div>
		</form>
	</div>
</div>
<!-- /.row -->
	<%
		}
	%>
<script type="text/javascript">
var Utils_SEARCH_COMPOUND_AVERAGE_MASS = "<%=PeakForestUtils.SEARCH_COMPOUND_AVERAGE_MASS%>";
var Utils_SEARCH_COMPOUND_MONOISOTOPIC_MASS = "<%=PeakForestUtils.SEARCH_COMPOUND_MONOISOTOPIC_MASS%>";
var Utils_SEARCH_COMPOUND_FORMULA = "<%=PeakForestUtils.SEARCH_COMPOUND_FORMULA%>";
var switchAdvSearch = "compounds";
<%
if (request.getParameter("spectra") != null)
	if (request.getParameter("spectra").equalsIgnoreCase("nmr")) {
		out.println("switchAdvSearch = 'nmr-spectra';");
	} else if (request.getParameter("spectra").equalsIgnoreCase("lcms") || request.getParameter("spectra").equalsIgnoreCase("lc-ms")) {
		out.println("switchAdvSearch = 'lcms-spectra';");
	} else if (request.getParameter("spectra").equalsIgnoreCase("lcmsms") || request.getParameter("spectra").equalsIgnoreCase("lc-msms")) {
		out.println("switchAdvSearch = 'lcmsms-spectra';");
	}
%>
var _txt_btn_showMode = '<spring:message code="page.search.btn.showMore" text="Show more" />';
</script>
<script src="<c:url value="/resources/js/peakforest/search.min.js" />"></script>

<!-- Modal adv search -->
<div class="modal " id="advancedModal" tabindex="-1" role="dialog" aria-labelledby="advancedModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                 <h4 class="modal-title" id="advancedModalLabel">Modal title</h4>

            </div>
            <div class="modal-body"><div class="te"></div></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<!-- SPECTRA - PREVIEW -->
<div class="modal " id="modalShowSpectra" tabindex="-1" role="dialog" aria-labelledby="modalShowSpectraLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalShowSpectraLabel">Modal title</h4>
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
<!-- /.modal SPECTRA -->

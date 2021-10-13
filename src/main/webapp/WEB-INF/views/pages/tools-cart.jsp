<%@page import="fr.metabohub.peakforest.model.compound.ReferenceChemicalCompound"%>
<%@page import="java.util.List"%>
<%@page import="fr.metabohub.peakforest.model.maps.MapManager"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<div class="panel panel-default">
	<div class="panel-heading">
		<h3 class="panel-title">Compounds</h3>
	</div>
	<div class="panel-body">
		<div class="well">
			Tip: to add / remove compound from your cart, use the right-top button <img  src="<c:url value="/resources/img/tools/btn-add-cart.png" />" alt="btn add cart" title="btn add cart"> on compounds sheets!
		</div>
		<div id="noCpdInCart" style="display: none;">
			Sorry, no compound in your cart right now! 
			Otherwise try to <button onclick="updateCart()" class="btn btn-info btn-xs"><i class="fa fa-refresh"></i> update</button> this page or <button onclick="$('#jsonFileCpdCart').click()" class="btn btn-success btn-xs"><i class="fa fa-upload"></i> upload</button> a file.
		</div>
		<div id="cpdInCart" style="display: none;">
			<table id="compoundCartTable" class="table table-hover tablesorter tablesearch">
				<thead>
					<tr>
						<th><spring:message code="page.search.results.cpt.structure" text="Structure" /></th>
						<th><spring:message code="page.search.results.cpt.compoundName" text="Chemical Name" /> <i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.cpt.formula" text="Formula" /> <i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.cpt.exactMass" text="Exact mass" /> / <spring:message code="page.search.results.cpt.averageMass" text="Average mass" /> <spring:message code="page.search.results.cpt.massUnit" text="(Da)" /><i class="fa fa-sort"></i></th>
						<th><spring:message code="page.search.results.cpt.detailsSpectraPrint" text="Details / Spectra / Print" /></th>
						<th></th>
					</tr>
				</thead>
				<tbody id="compoundCartTableBody">
				</tbody>
				<tfoot>
					<tr>
						<th colspan="7">
							<div class="pull-right">
								<button onclick="cleanCpdInCart()" class="btn btn-danger btn-xs"><i class="fa fa-times-circle"></i> reset</button>
								<button onclick="updateCart()" class="btn btn-info btn-xs"><i class="fa fa-refresh"></i> update</button>
								<button onclick="$('#jsonFileCpdCart').click()" class="btn btn-success btn-xs"><i class="fa fa-upload"></i> upload</button>
								<input id="jsonFileCpdCart" type="file" style="display: none;" />
								<button onclick="saveCpdCartAsJsonFile()" class="btn btn-primary btn-xs"><i class="fa fa-download"></i> download</button>
							</div>
						</th>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>
<br />

<script type="text/javascript">
$( document ).ready(function() {
	updateCart();
	(function(){
	    function onChange(event) {
	        var reader = new FileReader();
	        reader.onload = onReaderLoad;
	        reader.readAsText(event.target.files[0]);
	    }
	    function onReaderLoad(event){
	        //console.log(event.target.result);
	        var obj = JSON.parse(event.target.result);
	        //console.log(obj);
	        loadCpdCartFromJsonFile(obj)
	    }
	    document.getElementById('jsonFileCpdCart').addEventListener('change', onChange);
	}());
});	

</script>
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
	</td>
	<td>
		<button id="addCpdInCart{%= id%}" style="display: none;" onclick="addCpdInCart({%= id%})" class="btn btn-success btn-xs"><i class="fa fa-plus-circle"></i> <i class="fa fa-shopping-cart"></i></button>
		<button id="removeCpdFromCart{%= id%}" onclick="removeCpdFromCart({%= id%})" class="btn btn-danger btn-xs"><i class="fa fa-times-circle"></i> <i class="fa fa-shopping-cart"></i></button>
	</td>
</tr>
</script>
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
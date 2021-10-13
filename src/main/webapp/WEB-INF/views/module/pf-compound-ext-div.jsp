<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>${name_rank1}</title>
<style type='text/css'>
.fa-star, .fa-star-half-o, .fa-star-o, .vote0 {
    cursor: default!important;
}
</style>

<!-- Bootstrap core CSS -->
<link href="<c:url value="/resources/css/bootstrap.min.css" />" rel="stylesheet">

<!--[if lt IE 8]>
    <link href="<c:url value="/resources/css/bootstrap-ie7.css" />" rel="stylesheet">
<![endif]-->

<!-- Add custom CSS here -->
<link href="<c:url value="/resources/css/sb-admin.min.css" />" rel="stylesheet">
<link rel="stylesheet" href="<c:url value="/resources/font-awesome/css/font-awesome.min.css" />">

<!-- Bootstrap core JavaScript -->
<script src="<c:url value="/resources/js/jquery.min.js" />"></script>
<script src="<c:url value="/resources/js/bootstrap.min.js" />"></script>

<!-- file upload -->
<%-- <script src="<c:url value="/resources/js/bootstrap.file-input.js" />"></script> --%>

<!-- autocomplete -->
<script src="<c:url value="/resources/js/bootstrap-typeahead.js" />"></script>

<!--switch-->
<script src="<c:url value="/resources/js/bootstrap-switch.min.js" />"></script>
<link href="<c:url value="/resources/css/bootstrap-switch.min.css" />" rel="stylesheet" media="screen">

<!--combobox-->
<link href="<c:url value="/resources/css/bootstrap-combobox.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-combobox.js" />" type="text/javascript"></script>

<!--dropdown multi select-->
<link href="<c:url value="/resources/css/bootstrap-select.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-select.js" />" type="text/javascript"></script>

<!--date picker-->
<link href="<c:url value="/resources/css/bootstrap-datepicker.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-datepicker.js" />" type="text/javascript"></script>
	
<!--sliders-->
<%-- <link href="<c:url value="/resources/css/bootstrap-slider2.css" />" media="screen" rel="stylesheet" type="text/css"> --%>
<%-- <script src="<c:url value="/resources/js/bootstrap-slider2.js" />" type="text/javascript"></script> --%>
	
<!--template-->
<script src="<c:url value="/resources/js/jquery.tmpl.js" />" type="text/javascript"></script>

<!-- slider -->
<!--    <script src="js/jquery-ui-1.10.3.mouse_core.js"></script>
<script src="js/jquery.ui.touch-punch.js"></script>
<script src="js/bootstrapslider.js"></script>-->

<!-- CSS template:
     many thanks to http://startbootstrap.com/sb-admin  
     & twitter bootstrap v3
-->

<!--JS-->
<script src="<c:url value="/resources/highcharts/js/highcharts.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/modules/exporting.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/themes/grid.min.js" />"></script>

<!-- custom css -->
<link href="<c:url value="/resources/css/bootstrap.overwrite.min.css" />" rel="stylesheet" media="screen">

<!-- custom js/jquery -->
<script src="<c:url value="/resources/js/peakforest.min.js" />"></script>

<!-- JS mol 3D -->
<script type="text/javascript" src="<c:url value="/resources/js/Three49custom.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/GLmol.js" />"></script>

<!-- table -->
<script type="text/javascript" src="<c:url value="/resources/js/tablesorter/jquery.tablesorter.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/tablesorter/tables.js" />"></script>

<c:if test="${mol_ready}">
<script type='text/javascript'>
	//<![CDATA[ 
	///////////////////
	function saveImage<%=randomID %>() {
		glmol<%=randomID %>.show();
		var imageURI = glmol<%=randomID %>.renderer.domElement.toDataURL("image/png");
		window.open(imageURI);
	}
	
	function reload<%=randomID %>() {
		glmol<%=randomID %>.defineRepresentation = defineRepFromController<%=randomID %>;
		glmol<%=randomID %>.rebuildScene();
		glmol<%=randomID %>.show();
	};
	
	function defineRepFromController<%=randomID %>() {
		var idHeader = "#" + this.id + '_';
		var all = this.getAllAtoms();
		var allHet = this.getHetatms(all);
		var hetatm = this.removeSolvents(allHet);
		var asu = new THREE.Object3D();
		var target = this.modelGroup;

		var hetatmMode = $(idHeader + 'hetatm').val();
		if (hetatmMode == 'stick') {
			this.drawBondsAsStick(target, hetatm, this.cylinderRadius, this.cylinderRadius, true);
		} else if (hetatmMode == 'sphere') {
			this.drawAtomsAsSphere(target, hetatm, this.sphereRadius);
		} else if (hetatmMode == 'line') {
			this.drawBondsAsLine(target, hetatm, this.curveWidth);
		} else if (hetatmMode == 'icosahedron') {
			this.drawAtomsAsIcosahedron(target, hetatm, this.sphereRadius);
		 } else if (hetatmMode == 'ballAndStick') {
			this.drawBondsAsStick(target, hetatm, this.cylinderRadius / 2.0, this.cylinderRadius, true, false, 0.3);
		 } else if (hetatmMode == 'ballAndStick2') {
			this.drawBondsAsStick(target, hetatm, this.cylinderRadius / 2.0, this.cylinderRadius, true, true, 0.3);
		 } 
	};
	///////////////////
	//     var glmol<%=randomID %> = new GLmol('glmol<%=randomID %>');
	var glmol<%=randomID %>;
	setTimeout(function() {
		try {
			glmol<%=randomID %> = new GLmol('glmol<%=randomID %>');
			setTimeout(function(){reload<%=randomID %>()},1000);
		} catch (e) {
		}
	}, 150);
	//]]>
</script>
</c:if>
</head>
<body style="margin-top: 0px!important;">
	<div class="">
		<div class="">
<!-- 			<div class="modal-header"></div> -->
			<div class=" "><!-- modal-body -->
				<div class="te">
					<form class="form-horizontal" onsubmit="return false;">
						<fieldset>
							<!--  ++++++++++++++++++++++++++++ start mol. card -->
							<div class="panel-group" id="accordion">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion"
												href="#card1"> <spring:message code="modal.show.basicInfos" text="Basic infos" /> <i class="fa fa-info-circle"></i>
											</a>
										</h4>
									</div>
									<div id="card1" class="panel-collapse collapse in">
<!-- 										<div class="panel-body"> -->
											<!--  ++++++++++++++++++++++++++++ mol card 1  -->
<!-- 											<div class="panel panel-default"> -->
												<!--<div class="panel-heading">Basic infos</div>-->
												<table class="table">
													<tr>
														<td style="width: 100px;"><spring:message code="modal.show.basicInfos.name" text="Name" /></td>
														<td>${compoundNames.get(0).name}</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.basicInfos.formula" text="Formula" /></td>
														<td>${formula}</td>
													</tr>
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.basicInfos.monoisotopicMass" text="Monoisotopic Mass" /></td>
														<td>${exactMass}</td>
													</tr>
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.basicInfos.averageMass" text="Average Mass" /></td>
														<td>${molWeight}</td>
													</tr>
													<c:if test="${mol_ready}">
													<tr>
														<td><spring:message code="modal.show.basicInfos.download" text="Download" /></td>
														<td>
															<a class="btn btn-primary" href="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/mol/${inchikey}.mol" title="${compoundNames.get(0).name}" target="_blank">
																<spring:message code="modal.show.basicInfos.mol" text="Mol" /> <i class="fa fa-download"></i>
															</a>
														</td>
													</tr>
													</c:if>
												</table>
<!-- 											</div> -->
											<!--  ++++++++++++++++++++++++++++ end card 1  -->
<!-- 										</div> -->
									</div>
								</div>
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion" href="#card2">
												 <spring:message code="modal.show.names" text="Names" /> <i class="fa fa-star-half-o"></i>
											</a>
										</h4>
									</div>
									<div id="card2" class="panel-collapse collapse">
<!-- 										<div class="panel-body"> -->
											<!--  ++++++++++++++++++++++++++++ start card 2 -->
<!-- 											<div class="panel panel-default"> -->
												<!--		      <div class="panel-heading">Names</div>-->
												<ul class="list-group" id="cc_listName" style="margin-bottom: 0px;">
													<c:forEach var="compoundName" items="${compoundNames}">
													<li id="compundName_${compoundName.id}" class="list-group-item">
														<span class="badge">${compoundName.score}</span>
														${compoundName.name}
														<span id="compundName_${compoundName.id}_score" class="pull-right">
														<!-- 0 -->
														<i class="vote0">&nbsp;&nbsp;</i>
														<!-- 1 -->
														<c:choose>
														<c:when test="${compoundName.score >= 0.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 1}"><i class="fa fa-star vote1"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote1"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote1"></i>
														</c:otherwise>
														</c:choose>
														<!-- 2 -->
														<c:choose>
														<c:when test="${compoundName.score >= 1.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 2}"><i class="fa fa-star vote2"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote2"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote2"></i>
														</c:otherwise>
														</c:choose>
														<!-- 3 -->
														<c:choose>
														<c:when test="${compoundName.score >= 2.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 3}"><i class="fa fa-star vote3"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote3"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote3"></i>
														</c:otherwise>
														</c:choose>
														<!-- 4 -->
														<c:choose>
														<c:when test="${compoundName.score >= 3.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 4}"><i class="fa fa-star vote4"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote4"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote4"></i>
														</c:otherwise>
														</c:choose>
														<!-- 5 -->
														<c:choose>
														<c:when test="${compoundName.score >= 4.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 5}"><i class="fa fa-star vote5"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote5"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote5"></i>
														</c:otherwise>
														</c:choose>
															&nbsp;
														</span>
													</li>
													</c:forEach>
												</ul>
									</div>
								</div>
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion"
												href="#card3"> <spring:message code="modal.show.structure" text="Structure" /> <i class="fa fa-eye"></i>
											</a>
										</h4>
									</div>
									<div id="card3" class="panel-collapse collapse">
<!-- 										<div class="panel-body"> -->
											<!--  ++++++++++++++++++++++++++++ start card 3  -->
<!-- 											<div class="panel panel-default"> -->
												<!--<div class="panel-heading">structure</div>-->
												<!-- *************************************************************************** -->
											<c:if test="${mol_ready}">
												<ul class="nav nav-tabs">
													<li class="active">
														<a href="#showMol-2D-modal" data-toggle="tab">
															<i class="fa fa-square-o"></i> 2D
														</a>
													</li>
													<li>
														<a href="#showMol-3D-modal" data-toggle="tab">
															<i class="fa fa-cube"></i> 3D
														</a>
													</li>
												</ul>
												<div class="tab-content">
													<div id="showMol-2D-modal" class="tab-pane fade active in">
														<img class="molStructSVG" src="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/image/${type}/${inchikey}.svg" alt="${compoundNames.get(0).name}">
													</div>
													<div id="showMol-3D-modal" class="tab-pane fade">
														<div id="glmol<%=randomID %>" class="molGL"></div>
			<%-- 												${mol} --%>
															<textarea id="glmol<%=randomID %>_src" style="display: none;">
${mol}</textarea>
<form class="form-inline" >
	<div class="form-group input-group" style="margin-bottom: 0px;">
		<span>&nbsp;&nbsp;</span>
		<span class="input-group-addon"><i class="fa fa-eye"></i></span> 
		<select id="glmol<%=randomID %>_hetatm" style="max-width: 30%;" class="form-control ">
			<option selected="selected" value="stick">sticks</option>
			<option value="ballAndStick">ball and stick</option>
			<option value="ballAndStick2">ball and stick (multiple bond)</option>
			<option value="sphere">spheres</option>
			<option value="icosahedron">icosahedrons</option>
			<option value="line">lines</option>
		</select>
		<button class="btn btn-xs" onclick="reload<%=randomID %>()"><i class="fa fa-refresh"></i></button>
		<button class="btn btn-xs" onclick="saveImage<%=randomID %>()"><i class="fa fa-save"></i></button>
	</div>
	<spring:message code="addon.glMol.poweredBy" text="<small>powered by <a href='http://webglmol.osdn.jp/index-en.html' target='_blank'>GLmol</a>.</small>" />
</form>
													</div>
												</div>
											
											</c:if>
											<c:if test="${not mol_ready}">
												<img class="molStructSVG" src="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/image/${type}/${inchikey}.svg" alt="${compoundNames.get(0).name}">
											</c:if>
<!-- 											</div> -->
											<!--  ++++++++++++++++++++++++++++ end card 3  -->
<!-- 										</div> -->
												<table class="table">
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.structure.cansmiles" text="Canonical smiles" /></td>
														<%
															String smilesAlert = "";
															if (request.getAttribute("smiles").toString().length() > 65) {
																smilesAlert = "onclick=\"alert('" + request.getAttribute("smiles") + "')\"";
															}
														%>
														<td class="smiles" <%=smilesAlert %>>${smiles}</td>
													</tr>
													<c:if test="${not empty inchi}">
													<tr>
														<td ><spring:message code="modal.show.structure.inchi" text="InChI" /></td>
														<td>${inchi}</td>
													</tr>
													</c:if>
<!-- 													<tr> -->
<!-- 														<td>InChIKey</td> -->
<%-- 														<td>${inchikey}</td> --%>
<!-- 													</tr> -->
													<c:if test="${mol_ready}">
													<tr>
														<td><spring:message code="modal.show.basicInfos.download" text="Download" /></td>
														<td>
															<a class="btn btn-primary" href="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/mol/${inchikey}.mol" title="${compoundNames.get(0).name}" target="_blank">
																<spring:message code="modal.show.basicInfos.mol" text="Mol" /> <i class="fa fa-download"></i>
															</a>
														</td>
													</tr>
													</c:if>
												</table>
									</div>
								</div>
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion"
												href="#card4"> <spring:message code="modal.show.spectra" text="Spectra" /> <i class="fa fa-bar-chart-o"></i>
											</a>
										</h4>
									</div>
									<div id="card4" class="panel-collapse collapse">
										<!-- start light spectrum viwer module -->
										<c:if test="${contains_spectrum}">
											<div id="divCompoundSpectra<%=randomID %>"></div>
											<script type="text/javascript">
												$("#divCompoundSpectra<%=randomID %>").html('<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />');
												$.get("<spring:message code="peakforest.uri" text="https://peakforest.org/" />/compound-spectra-carrousel-light-module/${type}/${id}?isExt=true", function( data ) {
													$("#divCompoundSpectra<%=randomID %>").html( data );
													console.log("spectrum: ready!");
												});
											</script>
										</c:if>
										<c:if test="${not contains_spectrum}">
											<div class="panel-body">
												<spring:message code="modal.show.missingSpectrum" text="No spectrum available. " />
												<c:if test="${editor}">
												<spring:message code="modal.show.textAdd1" text="You can" /> <a href="<c:url value="/home" />?page=add-spectrum&inchikey=${inchikey}"><spring:message code="modal.show.textAdd2" text="add a new one" /></a>.
												</c:if>
											</div>
										</c:if>
										<!-- end light spectrum viwer module -->
									</div>
								</div>
								
								
								<c:if test="${contains_alt_structure}">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion" href="#cardAltStruct"> 
												<spring:message code="modal.show.relatedCompound" text="Related Compounds" /> <i class="fa fa-sitemap"></i>
											</a>
										</h4>
									</div>
									<div id="cardAltStruct" class="panel-collapse collapse">
										<table class="table">
											<tr>
												<td>
													<!-- parent -->
													<c:if test="${alt_structure_isGeneric}">
												 	<a class="btn btn-default btn-disabled compoundzoom genericCompoundS" href="#" style="text-align: left;">
														<i class="fa fa-info-circle"></i> 
														${compoundNames.get(0).name}
														<br><i> ${inchikey} </i>
														<div style="display:none;"><img  class="molStructSVGsmall" src="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/image/generic/${inchikey}.svg" alt="${compoundNames.get(0).name}"></div>
													</a>
													</c:if>
													<c:if test="${!alt_structure_isGeneric}">
												 	<a class="btn btn-info compoundzoom genericCompoundS" href="show-compound-modal/generic/${alt_structure_parent.id}" data-toggle="modal" data-target="#modalShowCompound" style="text-align: left;">
														<i class="fa fa-info-circle"></i> 
														<span id="nameOfGC${alt_structure_parent.id}"></span>
														<br><i> ${alt_structure_parent.inChIKey} </i>
														<div style="display:none;"><img  class="molStructSVGsmall" src="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/image/generic/${alt_structure_parent.inChIKey}.svg" alt=""></div>
													</a>
													</c:if>
												</td>
												<td>
													<!-- children -->
													<ul class="list-group" id="cc_children_listName" style="margin-bottom: 0px;">
													</ul>
												</td>
											</tr>
										</table>
										<script type="text/javascript">

										var parentID = ${alt_structure_parent.id};
										var currentIDCC = ${id};
										/**
										 *
										 */
										loadChildrenCompoundNames=function(parentID) {
											$.ajax({
												type: "post",
												url: "load-children-chemical-compounds-names",
												data: 'parentId=' + parentID,
												success: function(data) {
													if(data.success) { 
														var listChildren = '';
														$.each(data.chemicalCompounds, function(key, value){
															var classS = 'btn-info';
															var hrefS = 'href="show-compound-modal/chemical/'+value.id+'" data-toggle="modal" data-target="#modalShowCompound"';
															if (value.id==currentIDCC) { classS = 'btn-default btn-disabled'; hrefS = 'href="#"'; }
															listChildren += '<li id="cc_child_'+value.id+'" class="list-group-item">';
															listChildren += '<a class="compoundzoom chemicalCompoundS btn '+classS+'" '+hrefS+' style="text-align: left;">';
															listChildren += '<i class="fa fa-info-circle"></i>'; 
															listChildren += ' ' + value.names[0].name + '';
															listChildren += '<br><i> ' + value.inChIKey + ' </i>';
															listChildren += '<div style="display:none;"><img class="molStructSVGsmall" src="<spring:message code="peakforest.uri" text="https://peakforest.org/" />/image/chemical/'+value.inChIKey+'.svg" alt="'+value.names[0].name+'"></div>';
															listChildren += '</a>';
															listChildren += '</li>';
														});
														$('#cc_children_listName').html(listChildren);
														$("a.compoundzoom").mouseover(function() {
// 															var inchikey =  $.trim($(this).find("i").text());
// 															console.log(inchikey);
// 															if ($(this).hasClass("chemicalCompoundS")) {
// 																console.log("CC");
// 															} else if ($(this).hasClass("genericCompoundS"))  {
// 																console.log("GC");
// 															}
															$(this).find("div").show();
														}).mouseout(function() {
														    // $( this ).find( "i.inchikey" ).text( "mouse out " );
															$(this).find("div").hide();
														});;
														$("a[data-target=#modalShowCompound]").click(function(ev) {
															ev.preventDefault();
															$("#modalShowCompound").modal("hide");
															var target = $(this).attr("href");
															// load the url and show modal on success
															$('#cc_children_listName').empty();
															$("#modalShowCompound .modal-dialog").html("");
															setTimeout(function() {  $("#modalShowCompound .modal-dialog ").load(target, function() { $("#modalShowCompound").modal("show"); }); } , 50);
														});
														$("#nameOfGC${alt_structure_parent.id}").html(data.parentName);
													} else {
														 $('#cc_children_listName').html('<li class="list-group-item">ERROR</i>');
													}
												}, 
												error : function(data) {
													console.log(data);
												}
											});
										};
										loadChildrenCompoundNames(parentID);
										
										</script>
<!-- 										// current -->
<!-- 										// sub structures -->
<!-- 										// current -->
<!-- 										// putatives -->
									</div>
								</div>
								</c:if>
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion"
												href="#card5"> <spring:message code="modal.show.inOtherDatabases" text="In other databases" /> <i class="fa fa-rocket"></i>
											</a>
										</h4>
									</div>
									<div id="card5" class="panel-collapse collapse">
<!-- 										<div class="panel-body">TODO</div> -->
												<table class="table">
													<tr>
														<td style="width: 100px;"><spring:message code="modal.show.inOtherDatabases.inchikey" text="InChIKey" /></td>
														<td>${inchikey}</td>
													</tr>
													<c:if test="${not empty pubchem}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.pubchem" text="PubChem" /></td>
														<td><a href="<spring:message code="resources.banklink.pubchem" text="http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=" />${pubchem}" target="_blank">CID ${pubchem}</a></td>
													</tr>
													</c:if>
													<c:if test="${not empty chebi}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.chebi" text="ChEBI" /></td>
														<td><a href="<spring:message code="resources.banklink.chebi" text="https://www.ebi.ac.uk/chebi/searchId.do?chebiId=" />${chebi}" target="_blank">CHEBI:${chebi}</a></td>
													</tr>
													</c:if>
													<c:if test="${not empty hmdb}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.hmdb" text="HMDB" /></td>
														<td><a href="<spring:message code="resources.banklink.hmdb" text="http://www.hmdb.ca/metabolites/HMDB" />${hmdb}" target="_blank">HMDB${hmdb}</a></td>
													</tr>
													</c:if>
													<c:if test="${not empty keggs}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.kegg" text="KEGG" /></td>
														<td>
															<c:forEach var="kegg" items="${keggs}">
																<a href="<spring:message code="resources.banklink.kegg" text="http://www.genome.jp/dbget-bin/www_bget?cpd:" />${kegg}" target="_blank">${kegg}</a>
															</c:forEach>
														</td>
													</tr>
													</c:if>
												</table>
									</div>
								</div>
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordion"
												href="#card7"> <spring:message code="modal.show.citation" text="In the literature" /> <i class="fa fa-certificate"></i>
											</a>
										</h4>
									</div>
									
									<div id="card7" class="panel-collapse collapse">
										<c:if test="${not empty acceptedCitations}">
											<table class="table">
												<c:forEach var="citation" items="${acceptedCitations}">
												<tr>
													<td>
														<c:if test="${not empty citation.doi}">
														<a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />${citation.doi}" class="btn btn-xs btn-info" target="_blank"><i class="fa fa-book"></i> </a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.pmid}">
														<spring:message code="modal.show.citation.pmid" text="PMID:&nbsp;" /><a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />${citation.pmid}" class="" target="_blank">${citation.pmid}</a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
										<c:if test="${empty acceptedCitations}">
											<div class="panel-body"><spring:message code="modal.show.citation.noAcceptedCitation" text="No accepted citation." /></div>
										</c:if>
										<c:if test="${not empty waitingCitationsUser}">
											<table class="table ">
												<c:forEach var="citation" items="${waitingCitationsUser}">
												<tr class="warning">
													<td>
														<c:if test="${not empty citation.doi}">
														<a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />${citation.doi}" class="btn btn-xs btn-info" target="_blank"><i class="fa fa-book"></i> </a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.pmid}">
														<spring:message code="modal.show.citation.pmid" text="PMID:&nbsp;" /><a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />${citation.pmid}" class="" target="_blank">${citation.pmid}</a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
									</div>
								</div>
							</div>
						</fieldset>
					</form>
				</div>
			</div>
<!-- 			<div class="modal-footer"> -->
<!-- 			</div> -->
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>
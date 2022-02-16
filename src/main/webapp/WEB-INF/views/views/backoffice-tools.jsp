<%@page import="org.apache.commons.lang.time.DateUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ page import="fr.metabohub.peakforest.utils.PeakForestUtils"%>
<%@ page import="fr.metabohub.peakforest.model.CurationMessage"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="org.apache.commons.lang.time.DateUtils"%>
<%
	boolean useMEwebservice = Boolean.parseBoolean(PeakForestUtils.getBundleConfElement("metexplore.ws.use"));
%>
<link href="<c:url value="/resources/css/select2.min.css" />" rel="stylesheet">
<script src="<c:url value="/resources/js/select2.min.js" />"></script>
<div class="col-lg-12">
	<div id="backOfficeToolsAltert" style="max-width: 500px;"></div>
	<div class="table-responsive">
		<table class="table table-hover ">
			<thead>
				<tr>
					<th colspan="4">Update statistics</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>
						<a class="btn btn-info" href="#" onclick="flushSessions(this);"> <i class="fa fa-refresh"></i> Flush Sessions </a>
					</td>
					<td>
<% if (useMEwebservice) { %>
						<a class="btn btn-info" href="#" onclick="updateMetExloreStats(this);"> <i class="fa fa-refresh"></i> Update MetExplore stats. </a>
<% } else { %>
						<a class="btn btn-info btn-disabled" href="#"> <i class="fa fa-refresh"></i> Update MetExplore stats. </a>
	<% } %>
					</td>
					<td>
						<a class="btn btn-info" href="#" onclick="updateMassVsLogP(this);"> <i class="fa fa-refresh"></i> Update Mass Vs LogP </a>
					</td>
					<td>
						<a class="btn btn-info" href="#" onclick="curateCompoundStructures(this);"> <i class="fa fa-refresh"></i> Curate structures </a>
					</td>
				</tr>
				<tr>
					<td>
						<a class="btn btn-info" href="#" onclick="updateSplash(this, false);"> <i class="fa fa-refresh"></i> Compute missing Splash </a>
					</td>
					<td>
						<a class="btn btn-info" href="#" onclick="updateSplash(this, true);"> <i class="fa fa-refresh"></i> (re)compute all Splash </a>
					</td>
					<td>
						<a class="btn btn-info" href="#" onclick="updateBioSM(this);"> <i class="fa fa-refresh"></i> Process BioSM </a>
					</td>
					<td>
						<a class="btn btn-info" href="#" onclick="recomputeChromatographyCodes(this);"> <i class="fa fa-refresh"></i> Recompute Chromato codes </a>
					</td>
				</tr>
			</tbody>
		</table>
		<% if (useMEwebservice) { %>
			<small><i class="fa fa-question-circle"></i> You are using <a href="https://metexplore.toulouse.inrae.fr/" target="_blank">MetExplore</a> webservices!</small>
		<% } %>
	</div> 
	<br>
	<div class="table-responsive">
		<table class="table table-hover ">
			<thead>
				<tr>
					<th colspan="2">Download PeakForest data</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>
						<a class="btn btn-info" href="#" onclick="dumpChemicalLirary(this);"> <i class="fa fa-file-excel-o"></i> Chemical library </a>
						<a id="downloadChemLibLink" target="_blank" style="display: none;" href=""><i class="fa fa-file-excel-o"></i> download Chemical library</a>
					</td>
					<td>
						<a class="btn btn-info" href="#" onclick="dumpSpectralLirary(this);"> <i class="fa fa-file-archive-o"></i> Spectral library <span id="exportSpectraXLSM"></span></a>
						<a id="downloadSpectraLibLink" target="_blank" style="display: none;" href=""><i class="fa fa-file-archive-o"></i> download Spectral library 
							(files success: <span id="spectraFileExportSuccess"></span> files fail: <span id="spectraFileExportFail"></span>)
						</a>
					</td>
				</tr>
			</tbody>
		</table>
	</div> 
	<hr />
	<h3>Clean PeakForest data</h3>
	<div class="table-responsive">
		<table class="table table-hover tablesorter table-search">
			<thead>
				<tr>
					<th>Data <i class="fa fa-sort"></i></th>
					<th>Nb entry <i class="fa fa-sort"></i></th>
					<th>Mean score <i class="fa fa-sort"></i></th>
					<th>Mean entry / entity <i class="fa fa-sort"></i></th>
					<th>Clean soft <br> <small>(if nb entry / entity &gt; 10 &amp; score &lt; 1)</small>
					</th>
					<th>Clean <br> <small>(if nb entry / entity &gt; 5 &amp; score &lt; 2)</small>
					</th>
					<th>Clean hard <br> <small>(if nb entry / entity &gt; 3 &amp; score &lt; 3)</small>
					</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>Compound Names</td>
					<td id="cpdNamesCount"></td>
					<td id="cpdNamesAvgScore"></td>
					<td id="cpdNamesPerRefCC"></td>
					<td>
						<a class="btn btn-success" href="#" onclick="cleanEntity('cptName', 10, 1.0, 'soft', this);"> <i class="fa fa-eraser"></i> Clean</a>
					</td>
					<td>
						<a class="btn btn-warning" href="#" onclick="cleanEntity('cptName', 5, 2.0, '', this);"> <i class="fa fa-eraser"></i> Clean</a>
					</td>
					<td>
						<a class="btn btn-danger" href="#" onclick="cleanEntity('cptName', 3, 3.0, 'hard', this);"> <i class="fa fa-eraser"></i> Clean</a>
					</td>
				</tr>
<!-- 				<tr> -->
<!-- 					<td>Putative Compounds / Ref. Compound</td> -->
<!-- 					<td>123</td> -->
<!-- 					<td>3.3</td> -->
<!-- 					<td>3.3</td> -->
<!-- 					<td><a class="btn btn-success" href="#"> <i -->
<!-- 							class="fa fa-eraser"></i> Clean -->
<!-- 					</a></td> -->
<!-- 					<td><a class="btn btn-warning" href="#"> <i -->
<!-- 							class="fa fa-eraser"></i> Clean -->
<!-- 					</a></td> -->
<!-- 					<td><a class="btn btn-danger" href="#"> <i -->
<!-- 							class="fa fa-eraser"></i> Clean -->
<!-- 					</a></td> -->
<!-- 				</tr> -->
			</tbody>
		</table>
	</div>
	<div class="table-responsive">
		<table class="table table-hover tablesorter table-search">
			<thead>
				<tr>
					<th>Data <i class="fa fa-sort"></i></th>
					<th>nb entries <i class="fa fa-sort"></i></th>
					<th>nb entries w/o relation <i class="fa fa-sort"></i></th>
					<th>entries w/o relation (&#37; entity tot)<i class="fa fa-sort"></i></th>
					<th>Clean </th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>Metadata</td>
					<td id="metadataTotalCount"></td>
					<td id="metadataAloneCount"></td>
					<td id=metadataAlonePerCent></td>
					<td>
						<a class="btn btn-success" href="#" onclick="cleanEntity('metadata', null, null, null, this);"> <i class="fa fa-eraser"></i> Clean</a>
					</td>
				</tr>
			</tbody>
			<tfoot>
				<tr>
					<td colspan="5">
						Warning: this routine delete all kind of metadata not related to any spectra, including Standardized and Analytical matrix metadata!
					</td>
				</tr>
			</tfoot>
		</table>
	</div>
	<div class="table-responsive">
		<table class="table table-hover tablesorter table-search">
			<thead>
				<tr>
					<th>Data <i class="fa fa-sort"></i></th>
					<th>clean mode 1</th>
					<th>clean mode 2</th>
					<th>clean mode 3</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>Curation Messages <small>(tot: <span id="cmCount0"></span>)</small></td>
					<td id="">
						<a class="btn btn-success" href="#" onclick="cleanEntityCM(<%=CurationMessage.STATUS_ACCEPTED %> , this);"> <i class="fa fa-eraser"></i> Clean CM accepted <br /> <small>(nb tot. status accepted: <span id="cmCount1"></span>)</small></a>
					</td>
					<td id="">
						<a class="btn btn-warning" href="#" onclick="cleanEntityCM(<%=CurationMessage.STATUS_REJECTED %> , this);"> <i class="fa fa-eraser"></i> Clean CM rejected <br /> <small>(nb tot. status rejected: <span id="cmCount2"></span>)</small></a>
					</td>
					<td id="">
						<a class="btn btn-danger" href="#" onclick="cleanEntityCM(<%=CurationMessage.STATUS_WAITING %> , this);"> <i class="fa fa-eraser"></i> Clean CM waiting <br /> <small>(nb tot. status waiting: <span id="cmCount3"></span>)</small></a>
					</td>
				</tr>
			</tbody>
			<tfoot>
				<tr>
					<td colspan="4">
						<div class="form-group input-group ">
							<span class="input-group-addon">clean only if older than</span> 
							<%
							DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							Date date = DateUtils.addDays(new Date(),-90);
							%>
							<input id="older-than-date" data-date-format="yyyy-mm-dd" type="text" class="form-control datepicker " value="<%=dateFormat.format(date) %>" placeholder="<%=dateFormat.format(date) %>">
						</div>
					</td>
				</tr>
			</tfoot>
		</table>
	</div>
	<hr />
	<h3>Manage analytical matrix <small>using ontologies</small></h3>
	<div class="table-responsive">
		<table class="table table-hover tablesorter table-search">
			<thead>
				<tr>
					<th>Ontology key</th>
					<th>Natural Language</th>
					<th>HTML display</th>
					<th>spectra nb</th>
					<th>manage</th>
				</tr>
			</thead>
			<tbody id="manageOntologies">
			</tbody>
			<tfoot>
				<tr>
					<td colspan="5">
<!-- 						<div class="form-group input-group "> -->
<!-- 							<span class="input-group-addon">Add</span>  -->
<!-- 							<input id="add-new-ontology" type="text" class="form-control" value="" placeholder="search..."> -->
<!-- 							<span class="input-group-btn"> -->
<!-- 								<button class="btn btn-primary" onclick="addOntologyInDatabase ();"><i class="fa fa-plus-circle"></i></button> -->
<!-- 							</span>  -->
<!-- 						</div> -->
						<div class="form-group input-group">
							<span class="input-group-addon">Add</span> 
							<select id="add-new-ontology" class="form-control" style="width: 300px;">
								<option value="" disabled="disabled"></option>
							</select>
							<span class="input-group-btn">
								<button class="btn btn-primary" onclick="addOntologyInDatabase ();"><i class="fa fa-plus-circle"></i></button>
							</span> 
						</div>
						<div>To create a new ontologie, please go to <a target="_blank" href="<spring:message code="link.site.ontologiesframework" text="https://pfem.clermont.inrae.fr/ontologies-framework/" />">ontologies framework online tool</a>.</div>
					</td>
				</tr>
			</tfoot>
		</table>
	</div>
	
	<hr />
	<h3>Manage standardized matrix </h3>
	<div class="table-responsive">
		<table class="table table-hover tablesorter table-search">
			<thead>
				<tr>
					<th>Natural Language</th>
					<th>HTML display</th>
					<th>spectra nb</th>
					<th>manage</th>
				</tr>
			</thead>
			<tbody id="manageStdMatrix">
			</tbody>
			<tfoot>
				<tr>
					<td colspan="5">
						<div class="form-group input-group">
							<span class="input-group-addon">Add</span> 
							<input id="stdMatrixTxtDescription" type="text" class="form-control" style="width: 150px;" placeholder="text description" />
							<input id="stdMatrixHtmlDescription" type="text" class="form-control" style="width: 400px;" placeholder="HTML description" />
							<span class="input-group-btn">
								<button class="btn btn-primary" onclick="addStdMatrixInDatabase();"><i class="fa fa-plus-circle"></i></button>
							</span> 
						</div>
						<div>
					</td>
				</tr>
			</tfoot>
		</table>
	</div>
	
</div>
<script type="text/javascript">

loadCMstats = function() {
	var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not get entity "curation message" stats.';
	alert += ' </div>';
	$.ajax({ 
 		type: "get",
 		url: "maintenance/get-entity-curation-message-stats",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
 			if (ret.success) {
 				$("#cmCount0").html(ret.count);
 				$("#cmCount1").html(ret.countAccepted);
 				$("#cmCount2").html(ret.countRejected);
 				$("#cmCount3").html(ret.countWaiting);
 			} else {
 				$("#backOfficeToolsAltert").html(alert);
 			}
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}
loadCMstats();

cleanEntityCM = function (status, btn) {
	$(btn).attr("disabled", true);
	$(btn).children("i").removeClass("fa-eraser").addClass("fa-refresh").addClass("fa-spin");
	var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not clean entity "curation message".';
	alert += ' </div>';
	$.ajax({ 
 		type: "post",
 		url: "maintenance/clean-entities-curation-message",
 		async: true,
		data: "status=" + status + "&date=" + $("#older-than-date").val(),
 		success: function(ret) {
 			$(btn).children("i").removeClass("fa-spin");
 			if (ret.success) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 				$("#cmCount0").html(ret.count);
 				$("#cmCount1").html(ret.countAccepted);
 				$("#cmCount2").html(ret.countRejected);
 				$("#cmCount3").html(ret.countWaiting);
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
 			$(btn).children("i").removeClass("fa-spin");
 			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

getEntityCompoundNamesStats = function() {
 	$.ajax({ 
 		type: "get",
 		url: "maintenance/get-entity-comoundnames-stats",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
 			if (ret.success) {
 				$("#cpdNamesCount").html(ret.count);
 				$("#cpdNamesAvgScore").html(roundNumber(ret.avgScore,3));
 				$("#cpdNamesPerRefCC").html(roundNumber(ret.meanEntryPerEntity,3));
 			} else {
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not get entity "compound name" stats.';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not get entity "compound name" stats.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
 	///////////////////
 	$.ajax({ 
 		type: "get",
 		url: "maintenance/get-entity-metadata-stats",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
 			if (ret.success) {
 				$("#metadataTotalCount").html(ret.countTotal);
 				$("#metadataAloneCount").html(ret.countAlone);
 				$("#metadataAlonePerCent").html(roundNumber(ret.countAlonePercent,3));
 			} else {
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not get entity "metadata" stats.';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not get entity "metadata" stats.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}
getEntityCompoundNamesStats();

cleanEntity = function (entity, listSizeThreshold, scoreThreshold, idSuffix, btn ) {
	$(btn).attr("disabled", true);
	$(btn).children("i").removeClass("fa-eraser").addClass("fa-refresh").addClass("fa-spin");
	if (entity == 'cptName')
	 	$.ajax({ 
	 		type: "post",
	 		url: "maintenance/clean-entity-comoundnames",
	 		async: true,
			data: "listSizeThreshold=" + listSizeThreshold + "&scoreThreshold=" + scoreThreshold,
	 		success: function(ret) {
	 			$(btn).children("i").removeClass("fa-spin");
	 			if (ret.success) {
	 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
	 				$("#cpdNamesCount").html(ret.count);
	 				$("#cpdNamesAvgScore").html(roundNumber(ret.avgScore,3));
	 				$("#cpdNamesPerRefCC").html(roundNumber(ret.meanEntryPerEntity,3));
	 			} else {
	 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
	 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not clean entity "compound name".';
	 				alert += ' </div>';
	 				$("#backOfficeToolsAltert").html(alert);
	 			}
	
	 		},
	 		error : function(xhr) {
	 			$(btn).children("i").removeClass("fa-spin");
	 			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
	 			// TODO alert error xhr.responseText
	 			console.log(xhr);
	 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not clean entity "compound name".';
	 			alert += ' </div>';
	 			$("#backOfficeToolsAltert").html(alert);
	 		}
	 	});
	else if (entity == 'metadata') 
		$.ajax({ 
	 		type: "post",
	 		url: "maintenance/clean-entities-metadata",
	 		async: true,
	 		success: function(ret) {
	 			$(btn).children("i").removeClass("fa-spin");
	 			if (ret.success) {
	 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
	 				$("#metadataTotalCount").html(ret.countTotal);
	 				$("#metadataAloneCount").html(ret.countAlone);
	 				$("#metadataAlonePerCent").html(roundNumber(ret.countAlonePercent,3));
	 			} else {
	 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
	 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not clean entities "metadata".';
	 				alert += ' </div>';
	 				$("#backOfficeToolsAltert").html(alert);
	 			}
	
	 		},
	 		error : function(xhr) {
	 			$(btn).children("i").removeClass("fa-spin");
	 			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
	 			// TODO alert error xhr.responseText
	 			console.log(xhr);
	 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not clean entities "metadata".';
	 			alert += ' </div>';
	 			$("#backOfficeToolsAltert").html(alert);
	 		}
	 	});
}

dumpChemicalLirary = function(btn) {
	$(btn).attr("disabled", true);
	$(btn).children("i").removeClass("fa-file-excel-o").addClass("fa-refresh").addClass("fa-spin");
	$.ajax({
		type: 'post',
		url: 'maintenance/chemical-libary-xls-download'
// 		data: 'fileSource='+$("#fileSource").val()+'&listRowFailed='+$("#listFailed").val()
	}).done(function(data){
		// console.log(data);
		// var a = $("#downloadListFailedXlsFile");
		$(btn).hide();
		$("#downloadChemLibLink").show();
		$("#downloadChemLibLink").attr({ href : data });
		$("#downloadChemLibLink").trigger('click');
		// window.open(data, '_blank');
// 		$("#downloadListFailedXlsFile").click();
		// $(a).click();
	}).fail(function(data){
		$(btn).children("i").removeClass("fa-spin");
		$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
		// TODO alert error xhr.responseText
		console.log(xhr);
		var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not dump spectra from database.';
		alert += ' </div>';
		$("#backOfficeToolsAltert").html(alert);
	}).always(function(data){
	});
}

// function makeid(){
//     var text = "";
//     var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
//     for( var i=0; i < 5; i++ )
//         text += possible.charAt(Math.floor(Math.random() * possible.length));
//     return text;
// }

// var clientID = makeid();

dumpSpectralLirary = function(btn) {
	$(btn).attr("disabled", true);
	$(btn).children("i").removeClass("fa-file-archive-o").addClass("fa-refresh").addClass("fa-spin");
	setTimeout(function() {
		checkSpectralExportXLSMProcessProgress();
	}, 500);
	$.ajax({
		type: 'post',
		url: 'maintenance/spectral-libary-xlsm-download'
//  		data: 'id='+clientID
	}).done(function(data){
		// console.log(data);
		// var a = $("#downloadListFailedXlsFile");
		$(btn).hide();
		if (data.success) {
			$("#downloadSpectraLibLink").show();
			$("#downloadSpectraLibLink").attr({ href : data.href });
			$("#downloadSpectraLibLink").trigger('click');
			$("#spectraFileExportSuccess").html(data.files_success_number);
			$("#spectraFileExportFail").html(data.files_error_number);
// 			files_error_number: 5
// 			files_success_number: 10
		} else {
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not dump compound from database.';
			alert += ' </div>';
			$("#backOfficeToolsAltert").html(alert);
		}

		// window.open(data, '_blank');
// 		$("#downloadListFailedXlsFile").click();
		// $(a).click();
	}).fail(function(data){
		$(btn).children("i").removeClass("fa-spin");
		$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
		// TODO alert error xhr.responseText
		console.log(xhr);
		var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not dump compound from database.';
		alert += ' </div>';
		$("#backOfficeToolsAltert").html(alert);
	}).always(function(data){
	});
}

checkSpectralExportXLSMProcessProgress = function() {
	$.ajax({
		type: 'post',
		url: 'maintenance/processProgressionSpectralExportXLSM'
	}).done(function(data){
		if (data!="") { console.log(data);
			$("#exportSpectraXLSM").html("(" + data +'%)');
			setTimeout(function() {
				checkSpectralExportXLSMProcessProgress();
			}, 500);
		}
		return;
	}).fail(function(data){
	}).always(function(data){
	});
};

updateMetExloreStats = function(btn) {
// 	$(btn).addClass("btn-disabled");
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/update-metexplore-data",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update MetExplore stats.';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update MetExplore stats.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

updateMassVsLogP = function(btn) {
// 	$(btn).addClass("btn-disabled");
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/update-mass-vs-logp-data",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update Mass-Vs-LogP stats.';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update Mass-Vs-LogP stats.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

updateBioSM = function(btn) {
// 	$(btn).addClass("btn-disabled");
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/process-biosm",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not process BioSM.';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not process BioSM.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

updateSplash = function(btn, force) {
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/update-splash",
 		async: true,
		data: "force=" + force,
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update Splash';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update Splash';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

recomputeChromatographyCodes = function(btn) {
// 	$(btn).addClass("btn-disabled");
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/update-chromatography-codes",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not recompute columns codes.';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not recompute columns codes.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

flushSessions = function(btn) {
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/flush-sessions",
 		async: true,
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not flush Sessions';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not fush Sessions';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

curateCompoundStructures = function(btn, force) {
	$(btn).attr("disabled", true);
	$(btn).children("i").addClass("fa-spin");
 	$.ajax({ 
 		type: "post",
 		url: "admin/process-structural-curation",
 		async: true,
 		success: function(ret) {
			$(btn).children("i").removeClass("fa-spin");
 			if (ret) {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-check-circle");
 			} else {
 				$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not curate structures';
 				alert += ' </div>';
 				$("#backOfficeToolsAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
			$(btn).children("i").removeClass("fa-spin");
			$(btn).children("i").removeClass("fa-refresh").addClass("fa-times-circle");
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not curate structures';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function listOntologiesInDatabase () {
 	$.ajax({ 
 		type: "get",
 		url: "admin/list-ontologies",
 		async: true,
// 		data: "query=" + $('#search').val(),
		dataType: 'json',
 		success: function(data) {
 			// console.log(data);
 			$("#manageOntologies").empty();
 			$("#templateListOntologies").tmpl(data).appendTo("#manageOntologies");
 			$.each($(".ontologiesHTML"),function() {
 				$(this).html($(this).text());
 			});
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not load ontologies.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function addOntologyInDatabase () {
	var ontologyKey = $("#add-new-ontology").val();
	if (ontologyKey.trim() == "") {
		return false;
	}
 	$.ajax({ 
 		type: "post",
 		url: "admin/add-analytical-matrix",
 		async: true,
 		data: "key=" + ontologyKey,
 		dataType: 'json',
 		success: function(data) {
 			if (data) {
 				$("#add-new-ontology").val("");
 				listOntologiesInDatabase ();
 				loadMatrixPicker();
 			} else {
 	 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 	 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 	 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could NOT add ontology.';
 	 			alert += ' </div>';
 	 			$("#backOfficeToolsAltert").html(alert);
 			}
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could NOT add ontology.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function addStdMatrixInDatabase () {
	var matrixText = $("#stdMatrixTxtDescription").val();
	var matrixHtml = $("#stdMatrixHtmlDescription").val();
	if (matrixText.trim() == "") {
		return false;
	}
 	$.ajax({ 
 		type: "post",
 		url: "admin/add-std-matrix",
 		async: true,
 		data: "text=" + matrixText + "&html=" + matrixHtml,
 		dataType: 'json',
 		success: function(data) {
 			if (data) {
 				$("#stdMatrixTxtDescription").val("");
 				$("#stdMatrixHtmlDescription").val("");
 				listStdMatrixInDatabase ();
 			} else {
 	 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 	 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 	 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could add std matrix.';
 	 			alert += ' </div>';
 	 			$("#backOfficeToolsAltert").html(alert);
 			}
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could add std matrix.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function listStdMatrixInDatabase () {
 	$.ajax({ 
 		type: "get",
 		url: "admin/list-std-matrix",
 		async: true,
// 		data: "query=" + $('#search').val(),
		dataType: 'json',
 		success: function(data) {
 			// console.log(data);
 			$("#manageStdMatrix").empty();
 			$("#templateListStdMatrix").tmpl(data).appendTo("#manageStdMatrix");
 			$.each($(".matrixHTML"),function() {
 				$(this).html($(this).text());
 			});
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not load std matrix.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function setOntologyFavourite (ontologyKey, isFav) {
 	$.ajax({ 
 		type: "post",
 		url: "admin/set-ontology-favourite",
 		async: true,
 		data: "key=" + ontologyKey + "&favourite=" + isFav,
 		success: function(data) {
 			if (data) {
 				listOntologiesInDatabase ();
 			} else {
 	 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 	 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 	 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could set ontology.';
 	 			alert += ' </div>';
 	 			$("#backOfficeToolsAltert").html(alert);
 			}
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could set ontology.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function deleteAnalyticalMatrix (id) { alert("TODO"); }

function setStdMatrixFavourite (id, isFav) {
	var naturalLanguage = $($("#stdMatrixTab"+id).find("td")[0]).html();
	var htmlDisplay = $($("#stdMatrixTab"+id).find("td")[1]).html();
 	$.ajax({ 
 		type: "post",
 		url: "admin/set-stdMatrix-favourite",
 		async: true,
 		data: "naturalLanguage=" + naturalLanguage + "&htmlDisplay=" + htmlDisplay+"&favourite=" + isFav,
 		success: function(data) {
 			if (data) {
 				listStdMatrixInDatabase ();
 			} else {
 	 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 	 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 	 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could set std matrix.';
 	 			alert += ' </div>';
 	 			$("#backOfficeToolsAltert").html(alert);
 			}
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could set std matrix.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

function deleteStdMatrix (id) { alert("TODO"); }

function loadMatrixPicker() {
	$("#add-new-ontology").select2({
		ajax: {
			url: '<spring:message code="peakforest.admin.ontologiesFWproxy" text="https://pfem.clermont.inrae.fr/elasticsearch-proxies/ontologies/_search" />',
			dataType: 'jsonp',
			delay: 250,
			data: function (params) {
				return {
					q: params.term, // search term
					page: params.page
				};
			},
			processResults: function (data, params) {
				//console.log(data); 
				var controle = [];
				if (data.hasOwnProperty("hits") && data.hits.hasOwnProperty("hits") ) { 
					$.each(data.hits.hits, function(){
						var e = this['_source'];
						controle.push({"id": e.id, "text": e.naturalLanguage});
					});
				}
				return {
					results: controle
				};
			},
			cache: true
		},
		escapeMarkup: function (markup) { return markup; }, 
		minimumInputLength: 6
	});
}

$(document).ready(function(){
	$('.datepicker').datepicker();
	listOntologiesInDatabase ();
	listStdMatrixInDatabase ();
	loadMatrixPicker();
});

</script>
<script  type="text/x-jquery-tmpl" id="templateListOntologies">
<tr>
	<td>{%= key%}</td>
	<td>{%= text%}</td>
	<td class="ontologiesHTML">{%= html%}</td>
	<td>{%= countSpectra%}</td>
	<td>
		{%if isFav%}
			<a href="javascript:void(0)" onclick="setOntologyFavourite('{%= key%}', false)" class="btn btn-xs btn-success">
				<i class="fa fa-star"></i>
			</a>
		{%else%}
			<a href="javascript:void(0)" onclick="setOntologyFavourite('{%= key%}', true)" class="btn btn-xs btn-danger">
				<i class="fa fa-star"></i>
			</a>
		{%/if%}
		{%if (countSpectra==0 && !isFav)%}
			<button onclick="deleteAnalyticalMatrix({%= id%})" class="btn btn-xs btn-danger">
				<i class="fa fa-trash"></i>
			</button>
		{%else%}
			<!--<button class="btn btn-xs btn-danger btn-disabled">
				<i class="fa fa-trash"></i>
			</button>-->
		{%/if%}
	</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateListStdMatrix">
<tr id="stdMatrixTab{%= id%}">
	<td>{%= text%}</td>
	<td class="matrixHTML">{%= html%}</td>
	<td>{%= countSpectra%}</td>
	<td>
		{%if isFav%}
			<a href="javascript:void(0)" onclick="setStdMatrixFavourite('{%= id%}', false)" class="btn btn-xs btn-success">
				<i class="fa fa-star"></i>
			</a>
		{%else%}
			<a href="javascript:void(0)" onclick="setStdMatrixFavourite('{%= id%}', true)" class="btn btn-xs btn-danger">
				<i class="fa fa-star"></i>
			</a>
		{%/if%}
		{%if (countSpectra==0 && !isFav)%}
			<button onclick="deleteStdMatrix({%= id%})" class="btn btn-xs btn-danger">
				<i class="fa fa-trash"></i>
			</button>
		{%else%}
			<!--<button class="btn btn-xs btn-danger btn-disabled">
				<i class="fa fa-trash"></i>
			</button>-->
		{%/if%}
	</td>
</tr>
</script>
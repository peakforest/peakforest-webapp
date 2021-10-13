<%@page import="fr.metabohub.peakforest.model.CurationMessage"%>
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
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>${name_rank1}</title>
<style type='text/css'>
</style>
<script type='text/javascript'>
	//<![CDATA[ 
	//]]>
</script>
</head>
<body>
	<div class="modal-dialog">
		<div class="modal-content modalLarge">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" onclick="checkIfReOpenDetailsModal();"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.edit.title" text="Edit" /> - ${compoundNames.get(0).name}</h4>
			</div>
			<div class="modal-body ">
				<div class="te">
					<c:if test="${curator}">
					<div>
					<c:forEach var="curationMessage" items="${curationMessages}">
						<div id="curationmessage-${curationMessage.id}" class="alert alert-warning alert-dismissible curator-curationMessageDiv" role="alert">
							<button type="button" class="close" data-dismiss="alert" onclick="deleteCurationMessageActionCurator(${curationMessage.id})">
								<span aria-hidden="true">&times;</span>
								<span class="sr-only"><spring:message code="alert.close" text="Close" /></span>
							</button>
						${fn:escapeXml(curationMessage.message)} 
						<span class="pull-right" style="margin-right: 25px;">
							<button type="button" class="btn btn-success btn-xs" onclick="validateCurationMessageActionCurator(${curationMessage.id});">
								<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
								<span class="sr-only"><spring:message code="modal.edit.curationMessage.validate" text="Validate" /></span>
							</button>
							<button type="button" class="btn btn-danger btn-xs" onclick="rejectCurationMessageActionCurator(${curationMessage.id});">
								<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
								<span class="sr-only"><spring:message code="modal.edit.curationMessage.reject" text="Reject" /></span>
							</button>
							<input type="hidden" value="${curationMessage.status}">
						</span>	
						</div>
					</c:forEach>
					</div>
						<script type="text/javascript">
						var newCurationMessagesCurator = new Object();
						deleteCurationMessageActionCurator = function (id) {
							var cm = new Object();
							cm["id"] = id;
							cm["update"]="deleted";
							newCurationMessagesCurator[id] = (cm);
						}
						validateCurationMessageActionCurator = function (id) {
							var cm = new Object();
							cm["id"] = id;
							cm["update"]="validated";
							newCurationMessagesCurator[id] = (cm);
							$("#curationmessage-" +id).removeClass("alert-warning");
							$("#curationmessage-" +id).removeClass("alert-danger");
							$("#curationmessage-" +id).addClass("alert-success");
						}
						rejectCurationMessageActionCurator = function (id) {
							var cm = new Object();
							cm["id"] = id;
							cm["update"]="rejected";
							newCurationMessagesCurator[id] = (cm);
							$("#curationmessage-" +id).removeClass("alert-warning");
							$("#curationmessage-" +id).removeClass("alert-success");
							$("#curationmessage-" +id).addClass("alert-danger");
						}
						checkCurationMessagesStatus = function() {
							var elems = $(".curator-curationMessageDiv");
							$.each(elems,function(k,v) { 
								var idDivCM = $(v).attr("id");
								var statusDivCM = $("#" + idDivCM + " input").val();
								if (statusDivCM == <%=CurationMessage.STATUS_WAITING %> ) {}
								else if (statusDivCM == <%=CurationMessage.STATUS_REJECTED %> ) { 
									$(v).removeClass("alert-warning");
									$(v).addClass("alert-danger");
								} else if (statusDivCM == <%=CurationMessage.STATUS_ACCEPTED %> ) { 
									$(v).removeClass("alert-warning");
									$(v).addClass("alert-success");
								}
							});
						}
						checkCurationMessagesStatus();
						</script>
					</c:if>
				
					<form class="form-horizontal" onsubmit="return false;">
						<fieldset>
							<!--  ++++++++++++++++++++++++++++ start mol. card -->
							<div class="panel-group" id="accordionCuration">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordionCuration"
												href="#card2Curation"> <spring:message code="modal.show.names" text="Names" /> <i
												class="fa fa-star-half-o"></i>
											</a>
										</h4>
									</div>
									<div id="card2Curation" class="panel-collapse collapse in">
<!-- 										<div class="panel-body"> -->
											<!--  ++++++++++++++++++++++++++++ start card 2 -->
<!-- 											<div class="panel panel-default"> -->
												<!--		      <div class="panel-heading">Names</div>-->
												<ul class="list-group" id="cc_listNameCurator" style="margin-bottom: 0px;">
													<c:forEach var="compoundName" items="${compoundNames}">
													<li id="compundNameModal_${compoundName.id}" class="list-group-item">
														<span id="showEditScore_${compoundName.id}" class="badge" style="margin-right: 60px;">${compoundName.score}</span>
														<span id="showEditName_${compoundName.id}" class="showEditName_${compoundName.id} compoundNameEdit">${compoundName.name}</span>
<%-- 														<span id="inputEditName_${compoundName.id}" style="display: none" class="input-group"><input type=text class="form-control" value="${compoundName.name}" placeholder="${compoundName.name}"></span> --%>
														<div id="inputEditName_${compoundName.id}" class="form-group input-group" style="display: none; width:465px">
															<input type="text" class="form-control input-active-enter-key" style="width:350px;" value="${compoundName.name}" placeholder="${compoundName.name}">
															<select class="form-control" style="width:75px;">
																<option selected="selected" value="${compoundName.score}">${compoundName.score}</option>
																<option value="5">5</option>
																<option value="4">4</option>
																<option value="3">3</option>
																<option value="2.5">2.5</option>
																<option value="2">2</option>
																<option value="1">1</option>
															</select>
															<span class="input-group-btn">
																<button class="btn btn-success" type="button" onclick="saveCompoundName(${compoundName.id});"><i class="fa fa-search fa-check-square-o"></i></button>
<%-- 																	<a class="btn btn-success btn-xs" onclick="saveCompoundName(${compoundName.id});" href="#"> <i class="fa fa-check-square-o fa-lg"></i></a> --%>
															</span>
														</div>
														<span id="btnSelectorCpdNameEdit_${compoundName.id}" class="pull-right" style="margin-right: -100px; ">
															<c:if test="${compoundName.matchCas()}">
																<a class="btn btn-warning btn-xs switchNameToCAS_${compoundName.id}" onclick="switchToCAS(${compoundName.id});" href="#"> <i class="fa fa-refresh fa-lg"></i> CAS</a>
																<script type="text/javascript"> 
																	$("#showEditScore_${compoundName.id}").hide();
																	$("#btnSelectorCpdNameEdit_${compoundName.id}").css('margin-right', '-10px');
																</script>
															</c:if>
															<c:if test="${compoundName.score == 2.5 and cpdFullData.containPotentialIupacInCommonNames() }">
																<a class="btn btn-warning btn-xs switchNameToIUPAC_${compoundName.id}" onclick="switchToIUPAC(${compoundName.id}, '${compoundName.name}');" href="#"> <i class="fa fa-refresh fa-lg"></i> IUPAC</a>
																<script type="text/javascript"> 
																	$("#showEditScore_${compoundName.id}").hide();
																	$("#btnSelectorCpdNameEdit_${compoundName.id}").css('margin-right', '-10px');
																</script>
															</c:if>
															<a class="btn btn-info btn-xs showEditName_${compoundName.id}" onclick="editCompoundName(${compoundName.id});" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
															<a class="btn btn-danger btn-xs showEditName_${compoundName.id}" onclick="deleteCompoundName(${compoundName.id}, '${compoundName.name}');" href="#"> <i class="fa fa-trash fa-lg"></i></a>
														</span>
													</li>
													
													</c:forEach>
													<li class="list-group-item">
														<spring:message code="modal.show.basicInfos.iupac" text="IUPAC:" />
														<c:if test="${not empty iupacName}">
															<span class="displayIupac">${iupacName}</span> 
															
														</c:if> 
														<c:if test="${empty iupacName}">
															<span id="targetNewIUPAC" class="displayIupac"></span>
														</c:if> 
														
														<a class="btn btn-info btn-xs showEditIupacName" onclick="editCompoundIupacName();" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
														<div id="inputEditIupacName" class="form-group input-group" style="display: none; width: 250px;">
															<input type="text" class="form-control input-active-enter-key" style="" value="${iupacName}" placeholder="${iupacName}">
															<span class="input-group-btn">
																<button class="btn btn-success" type="button" onclick="saveIupacName();"><i class="fa fa-search fa-check-square-o"></i></button>
															</span>
														</div>
													</li>
												</ul>

												<div class="input-group">
													<span class="input-group-addon" style="width: 200px;">
 														<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.names.newName" text="new name" />
													</span> 
 													<span>
														<input type="text" id="cc_addNewNameCurator" style="width: 250px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.names.newName.ph" text="new name..." />">
														<input id="cc_addNewNameScoreCurator" type="text" class="form-control pull-left" placeholder="<spring:message code="modal.edit.names.newScore.ph" text="score (between 0 and 5)" />" value="2.5" style="width: 150px; border-radius: 0px;">
													</span>
													<span class="input-group-btn " style="width: 50px;">  
														<span class="input-group-btn">
															<button class="btn btn-default" type="button" onclick="addNewNameCuratorAction();" style="border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-top-left-radius: 0px; border-bottom-left-radius: 0px"><i class="fa fa-plus-square"></i></button>
														</span>
													</span>
<!-- 														<span class="input-group-btn"> -->
<!-- 															<button class="btn btn-default" type="button" onclick="addNewNameCuratorAction();"><i class="fa fa-plus-square"></i></button> -->
<!-- 														</span> -->
<!-- 												</div> -->
<!-- 											</div> -->
<script>
$("#cc_addNewNameCurator").keypress(function(event) {
	if (event.keyCode == 13) {
		addNewNameCuratorAction();
	}
});
$("#cc_addNewNameScoreCurator").keypress(function(event) {
	if (event.keyCode == 13) {
		addNewNameCuratorAction();
	}
});
function addNewNameCuratorAction() {
	if ($("#cc_addNewNameCurator").val()!="") {
		var newName = $.trim($("#cc_addNewNameCurator").val());
		var newScore = $.trim($("#cc_addNewNameScoreCurator").val());
		var newId = md5("curator" + newName);
		if($('#'+newId).length != 0)
			alert('<spring:message code="modal.show.names.alertNameExist" text="ERROR: this name already exists!" />');
		else {
			addNewNameCurator(newId, newName, newScore);
			$("#cc_addNewNameCurator").val("");
		};
	};
}

function addNewNameCurator(newId, newName, newScore){
	var delB = '&nbsp;&nbsp;&nbsp; <a class="btn btn-danger btn-xs"onclick="deleteNameCurator(\''+newId+'\');" href="#"> <i class="fa fa-trash-o fa-lg"></i></a>';
	var e = $("<li id=\""+newId+"\" class=\"list-group-item\"><span class=\"badge\">"+newScore+"</span> "+newName+" "+ delB +" </li>");
	$("#cc_listNameCurator").append(e);
	newCompoundNamesCurator[newId] = newName;
	newCompoundNamesCuratorScore[newId] = newScore;
}

function deleteNameCurator(idName) {
 	$("#"+idName).remove();
 	delete newCompoundNamesCurator[idName];
 	delete newCompoundNamesCuratorScore[idName];
}

function editCompoundName (id) {
	$(".showEditName_"+id).hide();
	$("#inputEditName_"+id).show();
};

function switchToCAS (id) {
	//add cas in CAS gui
	$("#casEntities").append($("#showEditName_"+id).html().replace(/^CAS:/i, ''));
	// remove from names GUI
	$("#showEditName_"+id).hide();
	$("#compundNameModal_"+id).remove();
	// add new CAS to backend
	nameSwitchedToCAS.push(id);
}

function switchToIUPAC (id, name) {
	$(".showEditName_"+id).hide();
	$("#compundNameModal_"+id).hide();
	$("#targetNewIUPAC").html(name);
	nameSwitchedToIUPAC = (id);
}

function saveCompoundName (id) {
	$("#inputEditName_"+id).hide();
	$(".showEditName_"+id).show();
	// edit name / score
	namesUpdatedCurator[id] = $("#inputEditName_"+id+" input").val();
	scoresUpdatedCurator[id] = $("#inputEditName_"+id+" select").val();
	// update gui
	$("#showEditName_"+id).html($("#inputEditName_"+id+" input").val());
	$("#showEditScore_"+id).html($("#inputEditName_"+id+" select").val());
};

function deleteCompoundName (id, name) {
	if (confirm("Delete compound name '"+ name +"' ?")) {
		$("#compundNameModal_"+id).remove();
		// delete name (list)
		namesDeletedCurator.push(id);
	}
};

function editCompoundIupacName() {
	$(".showEditIupacName").hide();
	$("#inputEditIupacName").show();
	setTimeout(function(){$("#inputEditIupacName input")}, 250);
}

function saveIupacName() {
	$(".showEditIupacName").show();
	$("#inputEditIupacName").hide();
	$(".displayIupac").html($("#inputEditIupacName input").val());
	newIupacName = $("#inputEditIupacName input").val();
}
											</script>
<script src="<c:url value="/resources/js/md5.min.js" />"></script>
											<!--  ++++++++++++++++++++++++++++ end card 2  -->
										</div>
									</div>
								</div>
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordionCuration"
												href="#card5Curation"> <spring:message code="modal.show.inOtherDatabases" text="In other databases" /> <i class="fa fa-rocket"></i>
											</a>
										</h4>
									</div>
									<div id="card5Curation" class="panel-collapse collapse">
												<table class="table">
													<tr>
														<td style="width: 100px;"><spring:message code="modal.show.inOtherDatabases.inchikey" text="InChIKey" /></td>
														<td>${inchikey}</td>
													</tr>
<%-- 													<c:if test="${not empty pubchem}"> --%>
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.pubchem" text="PubChem" /></td>
														<td>
															<c:if test="${not empty pubchem}">
															<a id="linkTo_pubchem" href="<spring:message code="resources.banklink.pubchem" text="http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=" />${pubchem}" target="_blank">CID ${pubchem}</a>
															</c:if>
															<div id="inputEdit_pubchem" class="form-group input-group" style="display: none; max-width:400px;">
																<input type="text" class="form-control input-active-enter-key" style="" value="${pubchem}" placeholder="${pubchem}">
																<span class="input-group-btn">
																	<button class="btn btn-success " type="button" onclick="saveExtDBKey('pubchem');"><i class="fa fa-search fa-check-square-o"></i></button>
																</span>
															</div>
															<span class="pull-right" style="margin-right: 400px; "><a id="btn-edit-pubchem" class="btn btn-info btn-xs " onclick="editExtDBKey('pubchem');" href="#"> <i class="fa fa-pencil fa-lg"></i></a></span>
														</td>
													</tr>
<%-- 													</c:if> --%>
<%-- 													<c:if test="${not empty chebi}"> --%>
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.chebi" text="ChEBI" /></td>
														<td>
															<c:if test="${not empty chebi}">
															<a id="linkTo_chebi" href="<spring:message code="resources.banklink.chebi" text="https://www.ebi.ac.uk/chebi/searchId.do?chebiId=" />${chebi}" target="_blank">CHEBI:${chebi}</a>
															</c:if>
															<div id="inputEdit_chebi" class="form-group input-group" style="display: none; max-width:400px;">
																<input type="text" class="form-control input-active-enter-key" style="" value="${chebi}" placeholder="${chebi}">
																<span class="input-group-btn">
																	<button class="btn btn-success" type="button" onclick="saveExtDBKey('chebi');"><i class="fa fa-search fa-check-square-o"></i></button>
																</span>
															</div>
															<span class="pull-right" style="margin-right: 400px; "><a id="btn-edit-chebi" class="btn btn-info btn-xs " onclick="editExtDBKey('chebi');" href="#"> <i class="fa fa-pencil fa-lg"></i></a></span>
														</td>
													</tr>
<%-- 													</c:if> --%>
<%-- 													<c:if test="${not empty hmdb}"> --%>
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.hmdb" text="HMDB" /></td>
														<td>
															<c:if test="${not empty hmdb}">
															<a id="linkTo_hmdb" href="<spring:message code="resources.banklink.hmdb" text="http://www.hmdb.ca/metabolites/HMDB" />${hmdb}" target="_blank">HMDB${hmdb}</a>
															</c:if>
															<div id="inputEdit_hmdb" class="form-group input-group" style="display: none; max-width:400px;">
																<input type="text" class="form-control input-active-enter-key" style="" value="${hmdb}" placeholder="${hmdb}">
																<span class="input-group-btn">
																	<button class="btn btn-success" type="button" onclick="saveExtDBKey('hmdb');"><i class="fa fa-search fa-check-square-o"></i></button>
																</span>
															</div>
															<span class="pull-right" style="margin-right: 400px; "><a id="btn-edit-hmdb" class="btn btn-info btn-xs " onclick="editExtDBKey('hmdb');" href="#"> <i class="fa fa-pencil fa-lg"></i></a></span>
														</td>
													</tr>
<%-- 													</c:if> --%>
<%-- 													<c:if test="${not empty keggs}"> --%>
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.kegg" text="KEGG" /></td>
														<td>
															<ul id="keggIds" style="width: 200px;">
																<c:forEach var="kegg" items="${keggs}">
																	<li id="keggId_${kegg}" style="margin-bottom: 10px;">
																		<a href="<spring:message code="resources.banklink.kegg" text="http://www.genome.jp/dbget-bin/www_bget?cpd:" />${kegg}" target="_blank">${kegg}</a>
																		<span class="pull-right" style=""><a id="btn-delete-kegg-${kegg}" class="btn btn-danger btn-xs " onclick="deleteKeggKey('${kegg}');" href="#"> <i class="fa fa-trash-o fa-1"></i></a></span>
																	</li>
																</c:forEach>
															</ul>
															
															<div id="inputAdd_kegg" class="form-group input-group input-sm" style="max-width: 400px;">
																<input type="text" class="form-control input-active-enter-key" style="" value="" placeholder="Cxxxxx">
																<span class="input-group-btn">
																	<button class="btn btn-success" type="button" onclick="addKeggIdKey();"><i class="fa fa-search fa-plus"></i></button>
																</span>
															</div>
														</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.networkIds" text="Networks IDs" /></td>
														<td>
															<ul id="networkIds" style="width: 200px;">
																<c:forEach var="network" items="${networks}">
																	<li id="networkId_${network}" style="margin-bottom: 10px;">
																		${network}
																		<span class="pull-right" style=""><a id="btn-delete-network-${network}" class="btn btn-danger btn-xs " onclick="deleteNetworkKey('${network}');" href="#"> <i class="fa fa-trash-o fa-1"></i></a></span>
																	</li>
																</c:forEach>
															</ul>
															<div id="inputAdd_network" class="form-group input-group input-sm" style="max-width: 400px;">
																<input type="text" class="form-control input-active-enter-key" style="" value="" placeholder="...">
																<span class="input-group-btn">
																	<button class="btn btn-success" type="button" onclick="addNetworkIdKey();"><i class="fa fa-search fa-plus"></i></button>
																</span>
															</div>
														</td>
													</tr>
<%-- 													</c:if> --%>

													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.cas.simple" text="CAS" /></td>
														<td>
															<ul id="casEntities" style="width: 250px;">
																<!-- CAS:58-08-2;Sigma-Aldrich;27600 -->
																<c:forEach var="casEntity" items="${cas}">
																	<li id="casId_${casEntity.id}" style="margin-bottom: 10px;">
																		${casEntity.getCasNumber()};${casEntity.getCasProviderAsString()};${casEntity.getCasReferencer()}
																		<span class="pull-right" style=""><a id="btn-delete-cas-${casEntity.id}" class="btn btn-danger btn-xs " onclick="deleteCas('${casEntity.id}');" href="#"> <i class="fa fa-trash-o fa-1"></i></a></span>
																	</li>
																</c:forEach>
															</ul>
															
															<div id="inputAdd_cas" class="form-group input-group input-sm" style="width: 530px;">
																<input style="width: 130px;" type="text" class="form-control input-active-enter-key" style="" value="" placeholder="CAS nb. (e.g.: 58-08-2)">
																<input style="width: 170px;" type="text" class="form-control input-active-enter-key" style="" value="" placeholder="provider (e.g.: Sigma-Aldrich)">
																<input style="width: 170px;" type="text" class="form-control input-active-enter-key" style="" value="" placeholder="ref. (e.g.: 27600)">
																<span style="width: 40px;" class="input-group-btn">
																	<button class="btn btn-success" type="button" onclick="addCas();"><i class="fa fa-search fa-plus"></i></button>
																</span>
															</div>
														</td>
													</tr>

												</table>
												<script type="text/javascript">
												
												function editExtDBKey(key) {
													$("#linkTo_"+key).hide();
													$("#btn-edit-"+key).hide();
													$("#inputEdit_"+key).show();
												}
												function saveExtDBKey(key) {
													$("#linkTo_"+key).show();
													$("#btn-edit-"+key).show();
													$("#inputEdit_"+key).hide();
													// 
													var newKey = $("#inputEdit_"+key+" input").val();
													if (key == 'pubchem') {
														if (newKey !="") {
															$("#linkTo_pubchem").attr("href", '<spring:message code="resources.banklink.pubchem" text="http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=" />'+newKey);
															$("#linkTo_pubchem").html("CID "+ newKey);
															newCompoundIdExtDB[key] = newKey;
														} else {
															$("#linkTo_pubchem").attr("href", "javascript:void(0);");
															$("#linkTo_pubchem").html("NULL");
															newCompoundIdExtDB[key] = "";
														};
													} else if (key == 'chebi') {
														if (newKey !="") {
															$("#linkTo_chebi").attr("href", '<spring:message code="resources.banklink.chebi" text="https://www.ebi.ac.uk/chebi/searchId.do?chebiId=" />'+newKey);
															$("#linkTo_chebi").html("CHEBI:"+ newKey);
															newCompoundIdExtDB[key] = newKey;
														} else {
															$("#linkTo_chebi").attr("href", "javascript:void(0);");
															$("#linkTo_chebi").html("NULL");
															newCompoundIdExtDB[key] = "";
														};
													} else if (key == 'hmdb') {
														if (newKey !="") {
															$("#linkTo_hmdb").attr("href", "<spring:message code="resources.banklink.hmdb" text="http://www.hmdb.ca/metabolites/HMDB" />"+newKey);
															$("#linkTo_hmdb").html("HMDB"+ newKey);
															newCompoundIdExtDB[key] = newKey;
														} else {
															$("#linkTo_hmdb").attr("href", "javascript:void(0);");
															$("#linkTo_hmdb").html("NULL");
															newCompoundIdExtDB[key] = "";
														};
													};
												}
												
												function addKeggIdKey() {
													var newCID = $("#inputAdd_kegg input").val();
													if($('#keggId_'+newCID).length != 0)
														alert("KEGG ID already exists");
													else {
														var newDiv = '<li id="keggId_'+newCID+'" style="margin-bottom: 10px;">';
														newDiv += '<a href="<spring:message code="resources.banklink.kegg" text="http://www.genome.jp/dbget-bin/www_bget?cpd:" />'+newCID+'" target="_blank">'+newCID+'</a>';
														newDiv += '<span class="pull-right" style=" "><a id="btn-delete-kegg-'+newCID+'" class="btn btn-danger btn-xs " onclick="deleteKeggKey(\''+newCID+'\');" href="#"> <i class="fa fa-trash-o fa-1"></i></a></span>';
														//newDiv += '<br />';
														newDiv += '</li>';
														$("#keggIds").append(newDiv);
														$("#inputAdd_kegg input").val("");
														if ($.inArray(newCID, newKeggIDs)!=0)
															newKeggIDs.push(newCID);
														if ($.inArray(newCID, deleteKeggIDs)==0){
															deleteKeggIDs.splice($.inArray(newCID, deleteKeggIDs),1);
														};
													};
												}
												function deleteKeggKey(id) {
													$("#keggId_"+id).remove();
													if ($.inArray(id, newKeggIDs)==0){
														newKeggIDs.splice($.inArray(id, newKeggIDs),1);
													}
													if ($.inArray(id, deleteKeggIDs)!=0){
														deleteKeggIDs.push(id); 
													}
												}
												
												///
												function addNetworkIdKey() {
													var newCID = $("#inputAdd_network input").val();
													if($('#networkId_'+newCID).length != 0)
														alert("Network ID already exists");
													else {
														var newDiv = '<li id="networkId_'+newCID+'" style="margin-bottom: 10px;">';
														newDiv += ''+newCID+'';
														newDiv += '<span class="pull-right" style=" "><a id="btn-delete-network-'+newCID+'" class="btn btn-danger btn-xs " onclick="deleteNetworkKey(\''+newCID+'\');" href="javascript:void(0)"> <i class="fa fa-trash-o fa-1"></i></a></span>';
														//newDiv += '<br />';
														newDiv += '</li>';
														$("#networkIds").append(newDiv);
														$("#inputAdd_network input").val("");
														if ($.inArray(newCID, newNetworksIDs)!=0)
															newNetworksIDs.push(newCID);
														if ($.inArray(newCID, deleteNetworksIDs)==0){
															deleteNetworksIDs.splice($.inArray(newCID, deleteNetworksIDs),1);
														};
													};
												}
												function deleteNetworkKey(id) {
													$("#networkId_"+id).remove();
													if ($.inArray(id, newNetworksIDs)==0){
														newNetworksIDs.splice($.inArray(id, newNetworksIDs),1);
													}
													if ($.inArray(id, deleteNetworksIDs)!=0){
														deleteNetworksIDs.push(id); 
													}
												}
												
												///
												
												
												function addCas() {
													var newCasNumber = $($("#inputAdd_cas input")[0]).val();
													var newCasProvider = $($("#inputAdd_cas input")[1]).val();
													var newCasReference = $($("#inputAdd_cas input")[2]).val();

													var newDiv = '<li style="margin-bottom: 10px;">';
													newDiv += newCasNumber +';'+newCasProvider+";"+newCasReference;
// 													newDiv += '<span class="pull-right" style=" "><a id="btn-delete-kegg-'+newCID+'" class="btn btn-danger btn-xs " onclick="deleteKeggKey(\''+newCID+'\');" href="#"> <i class="fa fa-trash-o fa-1"></i></a></span>';
													//newDiv += '<br />';
													newDiv += '</li>';
													$("#casEntities").append(newDiv);
													$("#inputAdd_cas input").val("");
													newCASs.push({'number':newCasNumber,'provider':newCasProvider,'reference':newCasReference});

												}
												function deleteCas(id) {
													$("#casId_"+id).remove();
													deleteCASs.push(Number(id)); 
												}
												
												</script>
									</div>
								</div>
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<a data-toggle="collapse" data-parent="#accordionCuration"
												href="#card7Curation"> <spring:message code="modal.show.citation" text="In the literature" /> <i class="fa fa-certificate"></i>
											</a>
										</h4>
									</div>
									
									<div id="card7Curation" class="panel-collapse collapse">
										<c:if test="${not empty acceptedCitations}">
											<table class="table">
												<c:forEach var="citation" items="${acceptedCitations}">
												<tr id="citation-${citation.id}" class="success">
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
													<td class="citationApa">
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
													<td>
														<span style="white-space: nowrap;">
															<button type="button" class="btn btn-success btn-xs" onclick="validateCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.validate" text="Validate" /></span>
															</button>
															<button type="button" class="btn btn-danger btn-xs" onclick="rejectCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.reject" text="Reject" /></span>
															</button>
															<button type="button" class="btn btn-danger btn-xs" onclick="deleteCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-trash"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.delete" text="Delete" /></span>
															</button>
															<input type="hidden" value="0">
														</span>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
										<c:if test="${not empty waitingCitations}">
											<table class="table ">
												<c:forEach var="citation" items="${waitingCitations}">
												<tr id="citation-${citation.id}" class="warning">
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
													<td class="citationApa">
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
													<td>
														<span style="white-space: nowrap;">
															<button type="button" class="btn btn-success btn-xs" onclick="validateCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.validate" text="Validate" /></span>
															</button>
															<button type="button" class="btn btn-danger btn-xs" onclick="rejectCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.reject" text="Reject" /></span>
															</button>
															<button type="button" class="btn btn-danger btn-xs" onclick="deleteCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-trash"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.delete" text="Delete" /></span>
															</button>
															<input type="hidden" value="0">
														</span>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
										<c:if test="${not empty rejectedCitations}">
											<table class="table ">
												<c:forEach var="citation" items="${rejectedCitations}">
												<tr id="citation-${citation.id}" class="danger">
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
													<td class="citationApa">
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
													<td>
														<span style="white-space: nowrap;">
															<button type="button" class="btn btn-success btn-xs" onclick="validateCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.validate" text="Validate" /></span>
															</button>
															<button type="button" class="btn btn-danger btn-xs" onclick="rejectCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.reject" text="Reject" /></span>
															</button>
															<button type="button" class="btn btn-danger btn-xs" onclick="deleteCitationActionCurator(${citation.id});">
																<span aria-hidden="true"><i class="fa fa-trash"></i></span>
																<span class="sr-only"><spring:message code="modal.edit.citation.delete" text="Delete" /></span>
															</button>
															<input type="hidden" value="0">
														</span>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
										
										<div id="newCitationCuratorUpdate" style="width: 650px; margin: auto;"><br></div>
										<div class="input-group">
											<span class="input-group-addon" style="width: 200px;">
													<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.citation.newCitation" text="New citation" />
											</span> 
												<span>
<%-- 												<input type="text" id="cc_addNewCitationURL" style="width: 250px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.citation.newCitation.url" text="publication URL" />"> --%>
												<input type="text" id="cc_addNewCitationIDCurator" style="width: 400px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.citation.newCitation.id" text="PUBMED id or doi" />">
<!-- 												<select id="cm_priority" class="form-control pull-left"style="width: 150px; border-radius: 0px;"></select> -->
											</span>
											<span class="input-group-btn " style="width: 50px;">  
												<span class="input-group-btn">
													<button class="btn btn-default" type="button" onclick="addNewCitationCuratorAction();" style="border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-top-left-radius: 0px; border-bottom-left-radius: 0px"><i class="fa fa-plus-square"></i></button>
												</span>
											</span>
											<script type="text/javascript">
											var newCitationCuratorUpdate = new Object();
											deleteCitationActionCurator = function (id) {
												var cm = new Object();
												cm["id"] = id;
												cm["update"]="deleted";
												newCitationCuratorUpdate[id] = (cm);
												$("#citation-" +id).removeClass("warning");
												$("#citation-" +id).removeClass("danger");
												$("#citation-" +id).removeClass("success");
												$("#citation-" +id).addClass("danger");
												$("#citation-" +id+' .citationApa').css("text-decoration", "line-through");
											}
											validateCitationActionCurator = function (id) {
												var cm = new Object();
												cm["id"] = id;
												cm["update"]="validated";
												newCitationCuratorUpdate[id] = (cm);
												$("#citation-" +id).removeClass("warning");
												$("#citation-" +id).removeClass("danger");
												$("#citation-" +id).removeClass("success");
												$("#citation-" +id).addClass("success");
												$("#citation-" +id+' .citationApa').css("text-decoration", "");
											}
											rejectCitationActionCurator = function (id) {
												var cm = new Object();
												cm["id"] = id;
												cm["update"]="rejected";
												newCitationCuratorUpdate[id] = (cm);
												$("#citation-" +id).removeClass("warning");
												$("#citation-" +id).removeClass("danger");
												$("#citation-" +id).removeClass("success");
												$("#citation-" +id).addClass("danger");
												$("#citation-" +id+' .citationApa').css("text-decoration", "");
											}
											
											var newCitationsCurator = new Object();
											
											$("#cc_addNewCitationIDCurator").keypress(function(event) {
												if (event.keyCode == 13) {
													addNewCitationCuratorAction();
												}
												//if ($("#cc_addNewCitationURL").val().length > 250) { return false; }
											});
											
											addNewCitationCuratorAction = function() {
												//var url = $('#cc_addNewCitationURL').val();
												//var pat = /^https?:\/\//i;
												//if (!pat.test(url)) {
												//	url = 'http://'+url;
												//}
												var id = $('#cc_addNewCitationIDCurator').val();
												var idMessage = md5("citation-curator" + id);
												if (id != '') {
													if ($('#CITE-curator-'+idMessage).length != 0)
														alert ('<spring:message code="modal.show.citation.alert.aleradyEntered" text="citation already entered!" />');
													else {
														newCitations[idMessage] = {  "id" : id}; // "url" : url,
														var newDiv = '<div id="CITE-curator-'+idMessage+'" class="alert alert-warning alert-dismissible" role="alert">';
														newDiv += '<button type="button" class="close" data-dismiss="alert" onclick="deleteCitationCuratorAction(\''+idMessage+'\')">';
														newDiv += '<span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
														//if (url != "http://")
														//	newDiv += '<a href="'+url+'" target="_blank" class="btn btn-xs btn-info" ><i class="fa fa-book"></i> </a>';
														newDiv += ' <span id="CITE-RESULT-'+idMessage+'">'+id+' <img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" /></span>';
														newDiv += '</div>';
														$("#newCitationCuratorUpdate").append(newDiv);
														//$('#cc_addNewCitationURL').val('');
														$('#cc_addNewCitationIDCurator').val('');
														// TODO ajax async : overwrite this alert, set correct ids in new citation object
														$.ajax({
															type: "post",
															url: "get-citation-data",
															data: "query=" + id,
															//contentType: 'application/json'
															success: function(data) {
																console.log(data);
																if(data.success) { 
																	var apa = data.apa;
																	var doi = data.doi;
																	var pmid = data.pmid;
																	var newResult = '';
																	if (doi!=null)
																		newResult += '<a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />'+doi+'" target="_blank" class="btn btn-xs btn-info" ><i class="fa fa-book"></i> </a>';
																	if (pmid!=null)
																		newResult += ' <a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />'+pmid+'" target="_blank" >'+pmid+'</a>';
																	newResult += ' ' + apa;
																	$('#CITE-RESULT-'+idMessage).html(newResult);
																	$('#CITE-curator-'+idMessage+'').removeClass("alert-warning");
																	$('#CITE-curator-'+idMessage+'').addClass("alert-success");
																	newCitationsCurator[idMessage] = { "apa" : apa, "doi" : doi, "pmid" : pmid}; //"url" : url, 
																} else {
																	$('#CITE-RESULT-'+idMessage).html("ERROR: could not retrive publication.");
																	$('#CITE-curator-'+idMessage+'').removeClass("alert-warning");
																	$('#CITE-curator-'+idMessage+'').addClass("alert-danger");
																	delete newCitationsCurator[idMessage];
																}
															}, 
															error : function(data) {
																console.log(data);
																$('#CITE-RESULT-'+idMessage).html("FATAL: could not retrive publication.");
																$('#CITE-curator-'+idMessage+'').removeClass("alert-warning");
																$('#CITE-curator-'+idMessage+'').addClass("alert-danger");
																delete newCitationsCurator[idMessage];
															}
														});
													}
												}
											};
											deleteCitationCuratorAction =function(idMessage) {
												delete newCitationsCurator[idMessage];
												$('#CITE-curator-'+idMessage).remove();
											}
											</script>
										</div>
										
									</div>
								</div>
								
							</div>
							<!--  ++++++++++++++++++++++++++++ start card 4  -->
							<!--		    <br />-->
							<!--
		    <button type="button" class="btn btn-success">Save</button>-->

							<!-- 		    <br /> -->
						</fieldset>
					</form>
				</div>
			</div>
			<div class="modal-footer">

				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="checkIfReOpenDetailsModal();"><spring:message code="modal.cancel" text="Cancel" /></button>
				
				<c:if test="${not hasBeenManualChecked}">
					<button type="button" class="btn btn-info" onclick="flagManualCurated(this);"><i></i> Flag as curated for names / IDs / ...</button>
				</c:if>
				<c:if test="${not hasBeenStructuralChecked}">
					<button type="button" class="btn btn-info" onclick="checkStructure(this);"><i></i> Check structure</button>
				</c:if>
				
				<button type="button" onclick="updateCurrentCompoundCurator('${type}', ${id})" class="btn btn-primary">
					<i class="fa fa-save"></i> <spring:message code="modal.saveChanges" text="Save Changes" />
				</button>
				
				<script type="text/javascript">
				var isManualCurated = false;
				var doStructureCheck = false;
				
				function flagManualCurated(btn) {
					isManualCurated = true;
					$(btn).find("i").addClass("fa").addClass("fa-check-circle");
					$(btn).addClass("btn-disabled");
					$(btn).attr('disabled', true);
				}
				
				function checkStructure(btn) {
					doStructureCheck = true;
					$(btn).find("i").addClass("fa").addClass("fa-check-circle");
					$(btn).addClass("btn-disabled");
					$(btn).attr('disabled', true);
				}
				
				
				var namesDeletedCurator = [];
				var namesUpdatedCurator = new Object();
				var scoresUpdatedCurator = new Object();
				var newCompoundNamesCurator = new Object();
				var newCompoundNamesCuratorScore = new Object();
				var newCompoundIdExtDB = new Object();
				var newKeggIDs = [];
				var deleteKeggIDs = [];
				var nameSwitchedToCAS = [];
				var nameSwitchedToIUPAC = null;
				var newIupacName = null;
				var newCASs = [], deleteCASs = [];
				var newNetworksIDs = [], deleteNetworksIDs = [];
				
				updateCurrentCompoundCurator = function(type, id) {
					
					var curationUpdate = [];
					if (isManualCurated) { curationUpdate.push('manual'); }
					if (doStructureCheck) { curationUpdate.push('structure'); }
					
					newKeggIDs = $.unique( newKeggIDs );
					deleteKeggIDs = $.unique( deleteKeggIDs );
					
					newNetworksIDs = $.unique( newNetworksIDs );
					deleteNetworksIDs = $.unique( deleteNetworksIDs );
					
					var newCitationsCuratorList = [];
					$.each(newCitationsCurator, function(k,v){ newCitationsCuratorList.push(v); });
					
					$.ajax({
						type: "POST",
						url: "edit-compound/" + type + "/" + id,
						data: JSON.stringify({ 
							deletedNames: namesDeletedCurator,
							editNames: namesUpdatedCurator,
							editScores: scoresUpdatedCurator, 
							newNames: newCompoundNamesCurator, 
							newScores: newCompoundNamesCuratorScore,
							newExtID: newCompoundIdExtDB,
							deleteKeggIDs: deleteKeggIDs,
							newKeggIDs : newKeggIDs,
							deleteNetworksIDs: deleteNetworksIDs,
							newNetworksIDs : newNetworksIDs,
							newCurationMessages: newCurationMessagesCurator,
							updateCitations: newCitationCuratorUpdate,
							newCitations: newCitationsCuratorList,
							nameSwitchedToCAS: nameSwitchedToCAS,
							nameSwitchedToIUPAC: nameSwitchedToIUPAC,
							newIupacName: newIupacName,
							newCASs: newCASs,
							deleteCASs: deleteCASs,
							curationUpdate: curationUpdate
						}),
						contentType: 'application/json',
						success: function(data) {
							if(data) { 
								$("#modalEditCompound").modal('hide');
								if (reopenDetailsModal) {
									reopenDetailsModal = false;
									$("#modalShowCompound .modal-dialog ").load("show-compound-modal/${type}/${id}" , function() { $("#modalShowCompound").modal("show"); });
								}
								try {
									if (reopenDetailsSheet) {
										reopenDetailsSheet = false;
										location.reload();
// 										$.get("sheet-compound/${type}/${id}", function( data ) {
// 											$("#divEntityDetails").html( data );
// 										});
									}
								} catch (e) {}
								try { initLoadCurationMessage(); initLoadCitation(); } catch (e) {}
							} else {
								alert('<spring:message code="modal.show.alert.failUpdate" text="Failed to update compound!" />'); 
								// TODO alert message
							}
						}, 
						error : function(data) {
							console.log(data);
						}
					});
				};
				
				
				$(".input-active-enter-key").keypress(function(event) {
					if (event.keyCode == 13) {
						$(this).parent().find('button').click();
					}
				});
				
				$('body').on('hidden.bs.modal', '.modal', function () {
					  $(this).removeData('bs.modal');
				});
				
				</script>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>
<%@page import="fr.metabohub.peakforest.model.compound.Citation"%>
<%@page import="fr.metabohub.peakforest.model.compound.Compound"%>
<%@page import="fr.metabohub.peakforest.model.CurationMessage"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div class="row">
	<div class="col-lg-12">

		<!--curate message / biblio management-->
		<ul class="nav nav-tabs" style="margin-bottom: 15px;">
			<li class="active"><a href="#curation-messages-panel" data-toggle="tab"><i class="fa fa-comment"></i> Curation Messages</a></li>
			<li><a href="#bibliography-panel" data-toggle="tab"> <i class="fa fa-certificate"></i> Bibliography Annotations </a></li>
			<li><a href="#cpd-name-conv-panel" data-toggle="tab"> <i class="fa fa-certificate"></i> CAS / IUPAC conv. </a></li>
		</ul>

		<div id="curate-mgmt" class="tab-content">
			<div class="tab-pane fade active in" id="curation-messages-panel">
				<div class="row">
					<!-- menu filter -->
					<div class="col-lg-12" style="z-index: 500;">
						<div class="form-group input-group col-lg-6">
							<input type="text" id="curateMsgSearchFilter" class="form-control" placeholder="e.g. bad kegg id" onkeyup="displayCurateMsgs(0)">
							<div class="input-group-btn">
								<button type="button" class="btn btn-primary dropdown-toggle"
									data-toggle="dropdown">
									<span id="search-curateMsg-filter-status"> Only waiting</span>
									<span class="caret"></span>
								</button>
								<ul class="dropdown-menu pull-right">
									<li><a href="#" onclick="$('#search-curateMsg-filter-status').html($(this).html()); curationMessageStatusFilter = <%=CurationMessage.STATUS_WAITING %>; displayCurateMsgs(0)"> Only waiting</a></li>
									<li><a href="#" onclick="$('#search-curateMsg-filter-status').html($(this).html()); curationMessageStatusFilter = <%=CurationMessage.STATUS_ACCEPTED %>; displayCurateMsgs(0)"> Only accepted</a></li>
									<li><a href="#" onclick="$('#search-curateMsg-filter-status').html($(this).html()); curationMessageStatusFilter = <%=CurationMessage.STATUS_REJECTED %>; displayCurateMsgs(0)"> Only rejected</a></li>
									<li><a href="#" onclick="$('#search-curateMsg-filter-status').html($(this).html()); curationMessageStatusFilter = 'x'; displayCurateMsgs(0)"> All status </a></li>
								</ul>
							</div>
							<div class="input-group-btn">
								<button type="button" class="btn btn-primary dropdown-toggle"
									data-toggle="dropdown">
									<span id="search-curateMsg-filter"><i
										class="fa fa-search"></i> All types</span> <span class="caret"></span>
								</button>
								<ul class="dropdown-menu pull-right">
									<li><a href="#" onclick="$('#search-curateMsg-filter').html($(this).html()); curationMessageEntityFilter = 'all'; displayCurateMsgs(0)"><i class="fa fa-search"></i> All types</a></li>
									<li><a href="#" onclick="$('#search-curateMsg-filter').html($(this).html()); curationMessageEntityFilter = 'compound'; displayCurateMsgs(0)"><i class="fa fa-search"></i> Only Compounds</a></li>
									<li><a href="#" onclick="$('#search-curateMsg-filter').html($(this).html()); curationMessageEntityFilter = 'spectrum'; displayCurateMsgs(0)"><i class="fa fa-search"></i> Only Spectrum</a></li>
								</ul>
							</div>
						</div>
						<div class="col-lg-6">
							<div id="alertCurationMessageManagement"></div>
						</div>
					</div>

					<!--display-->
					<div id="curateMsg-search-results" class="col-lg-11">
						<div class="table-responsive">
							<table id="curateMsgSearchTable"
								class="table table-hover tablesorter table-search">
								<thead>
									<tr style="white-space: nowrap;">
										<th>Message <i class="fa fa-sort"></i></th>
										<th>Login <i class="fa fa-sort"></i></th>
										<th>Date <i class="fa fa-sort"></i></th>
										<th>Status</th>
										<th>Show/Edit entity</th>
										<th>Delete message</th>
										<!--<th>Remove</th>-->
									</tr>
								</thead>
								<tbody id="curateMsgsTableBody">
								</tbody>
							</table>
						</div>
					</div>

<script  type="text/x-jquery-tmpl" id="templateCurationMessage">
<tr id="curation-message-id-{%= id %}" class="{%= classBTS %}">
	<td>{%= message %}</td>
	<td>{%= author %}</td>
	<td>{%= created_year %}/{%= created_month %}/{%= created_day %}</td>
	<td>
		<button type="button" class="btn btn-success btn-xs" onclick="validateCurationMessage({%= id %});">
			<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
			<span class="sr-only">Validate</span>
		</button>
		<button type="button" class="btn btn-danger btn-xs" onclick="rejectCurationMessage({%= id %});">
			<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
			<span class="sr-only">Reject</span>
		</button>
	</td>
	<td>
		{%if entity == "compound" %}
		<a class="btn btn-info btn-xs" href="edit-compound-modal/{%= compound_type %}/{%= compound_id %}" data-toggle="modal" data-target="#modalEditCompound">
			<i class="fa fa-pencil fa-lg"></i>
		</a>
		{%/if%}
		{%if entity == "spectrum" %}
		<a class="btn btn-info btn-xs" href="edit-spectrum-modal/{%= spectrum_id %}" data-toggle="modal" data-target="#modalEditSpectrum">
			<i class="fa fa-pencil fa-lg"></i>
		</a>
		{%/if%}
	<td><a class="btn btn-danger btn-xs"
		onclick="deleteMessage({%= id %});" href="#"> <i
			class="fa fa-trash-o fa-lg"></i></a></td>
</tr>
</script>

					<!--pagination-->
					<div class="col-lg-6">
						<ul id="searchCurationMessagePagination" class="pagination pagination-sm">
<!-- 							<li class="disabled"><a href="#">&laquo;</a></li> -->
<!-- 							<li class="active"><a href="#">1</a></li> -->
<!-- 							<li><a href="#">2</a></li> -->
<!-- 							<li><a href="#">3</a></li> -->
<!-- 							<li class="disabled"><a href="#">&#133;</a></li> -->
<!-- 							<li><a href="#">314</a></li> -->
<!-- 							<li><a href="#">&raquo;</a></li> -->
						</ul>
					</div>
					<div class="col-lg-6"></div>

				</div>
				<!--.row-->
			</div>

			<div class="tab-pane fade" id="bibliography-panel">
			
				<div class="row">
					<!-- menu filter -->
					<div class="col-lg-12" style="z-index: 500;">
						<div class="form-group input-group col-lg-6">
							<input type="text" id="citationMngSearchFilter"
								class="form-control" placeholder="e.g. Journal of chemistry"
								onkeyup="displayCitationsMs(0)">
							<div class="input-group-btn">
								<button type="button" class="btn btn-primary dropdown-toggle"
									data-toggle="dropdown">
									<span id="search-citationMng-filter-status"> <i class="fa fa-search"></i> Only waiting</span>
									<span class="caret"></span>
								</button>
								<ul class="dropdown-menu pull-right">
									<li><a href="#" onclick="$('#search-citationMng-filter-status').html($(this).html()); citationStatusFilter = <%=Citation.STATUS_WAITING %>; displayCitationsMs(0)"> <i class="fa fa-search"></i> Only waiting</a></li>
									<li><a href="#" onclick="$('#search-citationMng-filter-status').html($(this).html()); citationStatusFilter = <%=Citation.STATUS_ACCEPTED %>; displayCitationsMs(0)"> <i class="fa fa-search"></i> Only accepted</a></li>
									<li><a href="#" onclick="$('#search-citationMng-filter-status').html($(this).html()); citationStatusFilter = <%=Citation.STATUS_REJECTED %>; displayCitationsMs(0)"> <i class="fa fa-search"></i> Only rejected</a></li>
									<li><a href="#" onclick="$('#search-citationMng-filter-status').html($(this).html()); citationStatusFilter = 'x'; displayCitationsMs(0)"> <i class="fa fa-search"></i> All status </a></li>
								</ul>
							</div>
						</div>
						<div class="col-lg-6">
							<div id="alertCitationManagement"></div>
						</div>
					</div>

					<!--display-->
					<div id="citationMng-search-results" class="col-lg-11">
						<div class="table-responsive">
							<table id="citationMngSearchTable"
								class="table table-hover tablesorter table-search">
								<thead>
									<tr style="white-space: nowrap;">
										<th>DOI</th>
										<th>PMID <i class="fa fa-sort"></i></th>
										<th>APA <i class="fa fa-sort"></i></th>
										<th>Login <i class="fa fa-sort"></i></th>
										<th>Date <i class="fa fa-sort"></i></th>
										<th>Status</th>
										<th>Show/Edit entity</th>
										<th>Delete citation</th>
										<!--<th>Remove</th>-->
									</tr>
								</thead>
								<tbody id="citationMngsTableBody">
								</tbody>
							</table>
						</div>
					</div>

<script  type="text/x-jquery-tmpl" id="templateCitation">
<tr id="citation-id-{%= id %}" class="{%= classBTS %}">
	<td><a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />{%= doi %}" class="btn btn-xs btn-info" target="_blank"><i class="fa fa-book"></i> </a></td>
	<td><a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />{%= pmid %}" class="" target="_blank">{%= pmid %}</a></td>
	<td class="citationApa">{%= apa %}</td>
	<td>{%= author %}</td>
	<td>{%= created_year %}/{%= created_month %}/{%= created_day %}</td>
	<td style="white-space: nowrap;">
		<button type="button" class="btn btn-success btn-xs" onclick="validateCitation({%= id %});">
			<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
			<span class="sr-only">Validate</span>
		</button>&nbsp;<button type="button" class="btn btn-danger btn-xs" onclick="rejectCitation({%= id %});">
			<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
			<span class="sr-only">Reject</span>
		</button>
	</td>
	<td>
		<a class="btn btn-info btn-xs" href="edit-compound-modal/{%= compound_type %}/{%= compound_id %}" data-toggle="modal" data-target="#modalEditCompound">
			<i class="fa fa-pencil fa-lg"></i>
		</a>
	<td><a class="btn btn-danger btn-xs" onclick="deleteCitation({%= id %});" href="#"> <i class="fa fa-trash-o fa-lg"></i></a></td>
</tr>
</script>

					<!--pagination-->
					<div class="col-lg-6">
						<ul id="searchCitationPagination" class="pagination pagination-sm">
						</ul>
					</div>
					<div class="col-lg-6"></div>

				</div>
				<!--.row-->
			
			</div>


			<div class="tab-pane fade" id="cpd-name-conv-panel">
			
				<div class="row">
					<!-- menu filter -->
					<!-- 
					<div class="col-lg-12" style="z-index: 500;">
						<div class="form-group input-group col-lg-6">
							<input type="text" id="cpdNameConvMngSearchFilter"
								class="form-control" placeholder="e.g. Journal of chemistry"
								onkeyup="displayCpdNameConvMs(0)">
							<div class="input-group-btn">
								<button type="button" class="btn btn-primary dropdown-toggle"
									data-toggle="dropdown">
									<span id="search-cpdNameConv-filter-status"> <i class="fa fa-search"></i> Only waiting</span>
									<span class="caret"></span>
								</button>
							</div>
						</div>
						<div class="col-lg-6">
							<div id="alertNameConvManagement"></div>
						</div>
					</div>
					 -->
					 
					<!--display-->
					<div id="cpdNameConv-search-results" class="col-lg-11">
						<div class="table-responsive">
							<table id="cpdNameConvMngSearchTable"
								class="table table-hover tablesorter table-search">
								<thead>
									<tr style="white-space: nowrap;">
										<th>cpd id <i class="fa fa-sort"></i></th>
										<th>cpd name <i class="fa fa-sort"></i></th>
										<th>action(s) </th>
										<th>edit </th>
									</tr>
								</thead>
								<tbody id="cpdNameConvMngsTableBody">
								</tbody>
							</table>
						</div>
					</div>

<script  type="text/x-jquery-tmpl" id="templateCpdNameConv">
<tr id="conv-cpd-id-{%= id %}" >
	<td>{%= pfID %} </td>
	<td>{%= mainName %} </td>
	<td>
		{%each(i) actions%}
    		<br />{%= actions[i] %}
		{%/each%}
	</td>
	<td>
		<a class="btn btn-info btn-xs" href="edit-compound-modal/{%= compound_type %}/{%= id %}" data-toggle="modal" data-target="#modalEditCompound">
			<i class="fa fa-pencil fa-lg"></i>
		</a>
	</td>
</tr>
</script>

					<!--pagination-->
					<div class="col-lg-6">
						<button id="moreCpdNameConv" class="btn btn-info" onclick="initLoadNamesConv()"><i class="fa fa-refresh"></i> <span>reload top 50</span></button>
					</div>
					<div class="col-lg-6"></div>

				</div>
				<!--.row-->
			
			</div>

		</div>


	</div>

	<script type="text/javascript">

	// init var
	var numberMaxResults = 20;
	var messagesDisplayed = [];
	
	/**
	 * Build & display curation message display
	 */
	displayCurateMsgs= function (startPoint) {
		var subCurationMessage = [];
		var currentDisplayCount = 0;
		var currentTotalCount = 0;
		$.each(listOfAllCurationMessages, function(key, value) {
			if (isFiltered(value)) { 
				if (currentTotalCount >= startPoint) {
					subCurationMessage.push(value);
					currentDisplayCount++;
					if (currentDisplayCount>=numberMaxResults) {
						//displayCurationMessageResults(subCurationMessage, startPoint);
						return false;
					}
				}
				currentTotalCount++;
			}
		});
		displayCurationMessageResults(subCurationMessage, startPoint);
		return false;
	};
	
	var currentPageDisplayed = 0;
	displayCurationMessageResults = function (listCurationMessages, startPoint) {
		currentPageDisplayed = startPoint;
		usersDisplayed = listCurationMessages;
		// build content
		$("#curateMsgsTableBody").html("");
		$("#templateCurationMessage").tmpl(listCurationMessages).appendTo("#curateMsgsTableBody");
		// rebuild page nav
		numberTotalResults = listOfAllCurationMessages.length;
		var currentPage = startPoint / numberMaxResults;
		var lastPage = Math.ceil(numberTotalResults / numberMaxResults);
//	 		console.log("currentPage=" + currentPage);
//	 		console.log("lastPage=" + lastPage);
		var htmlPagination = "";
		// first
		if (currentPage==0) {
			htmlPagination += '<li class="disabled"><a href="#">&laquo;</a></li>';
		} else {
			htmlPagination += '<li><a href="#" onclick="displayCurateMsgs(0);">&laquo;</a></li>';
		}
		// n-1
		if (currentPage>=1){
			htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
			var before = startPoint-numberMaxResults;
			htmlPagination += '<li><a href="#" onclick="displayCurateMsgs('+before+');">'+(currentPage)+'</a></li>';
		}
		// n
		htmlPagination += '<li class="active"><a href="#">'+(currentPage+1)+'</a></li>';
		// n+1
		if ((currentPage+1)<lastPage){
			var after = startPoint+numberMaxResults;
			htmlPagination += '<li><a href="#" onclick="displayCurateMsgs('+after+');">'+(currentPage+2)+'</a></li>';
			htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
		}
		// last
		if ((currentPage+1)==(lastPage)) {
			htmlPagination += '<li class="disabled"><a href="#">&raquo;</a></li>';
		} else {
			var after = (lastPage) * numberMaxResults - numberMaxResults;
			htmlPagination += '<li><a href="#" onclick="displayCurateMsgs('+(after)+');">&raquo;</a></li>';
		}
		if (numberTotalResults!=0)
			$("#searchCurationMessagePagination").html(htmlPagination);
		else
			$("#searchCurationMessagePagination").html("");
		$('table').trigger('update');
		$("#curateMsgSearchTable").tablesorter(); 
		resizeCurationMessagesListPanel();
	};
	
	var curationMessageStatusFilter = <%=CurationMessage.STATUS_WAITING %>;
	var curationMessageEntityFilter = "all";
	isFiltered=function(curationMessage){
		// filter status
		if (curationMessageStatusFilter==0 && curationMessage.status != <%=CurationMessage.STATUS_WAITING %>)
			return false;
		if (curationMessageStatusFilter== -1 && curationMessage.status != <%=CurationMessage.STATUS_REJECTED %>)
			return false;
		if (curationMessageStatusFilter== 1 && curationMessage.status != <%=CurationMessage.STATUS_ACCEPTED %>)
			return false;
		// filter entity
		if (curationMessageEntityFilter=='compound' && curationMessage.entity != 'compound')
			return false;
		if (curationMessageEntityFilter== 'spectrum' && curationMessage.entity != 'spectrum')
			return false;
		var search = $("#curateMsgSearchFilter").val();
		if (search!= "" && !(curationMessage.message.indexOf(search) >= 0) )
			return false;
		return true;
	};
	
	
	resizeCurationMessagesListPanel = function () {
		var diff_screen = 320;
		try{
			$("#curateMsg-search-results").height($(window).height()-diff_screen);
			$("#curateMsg-search-results").css("overflow","auto"); 
		}catch(e){} 
	};
	$(window).resize(function() {
		resizeCurationMessagesListPanel();
	});
	
	/**
	 * Get list of ALL users
	 */
	var users = [];
	loadUsersFromDatabase = function() {
		if ($.isEmptyObject(users)) {
			$.ajax({ 
				type: "post",
				url: "list-all-users",
				dataType: "json",
				async: false,
//		 		data: "query=" + $('#search').val(),
				success: function(json) {
					users = json;
				},
				error : function(xhr) {
					subjects = [];
					// TODO alert error xhr.responseText
					console.log(xhr);
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not load users.';
					alert += ' </div>';
					$("#alertCurationMessageManagement").html(alert);
				}
			});
		}
	};
	loadUsersFromDatabase();
	
	var listOfAllCurationMessages = [];
	
	// load curation messages
	function initLoadCurationMessage() {
		listOfAllCurationMessages = [];
		$.get("list-curation-messages/all/500", function(data) {
// 		console.log(data);
			$.each(data, function(k,v){
				var cm = new Object();
				cm['id'] = v.id;
				cm['message'] = v.message;
				var author = "???";
				if (v.userID !=null && typeof users[v.userID] != "undefined")
					author = users[v.userID];
				cm['author'] = author;
				// status
				var status = v.status;
				var classS = "warning";
				if (v.status == <%=CurationMessage.STATUS_WAITING %>) {
	// 				status = "waiting";
					classS = "warning";
				} else if (v.status == <%=CurationMessage.STATUS_ACCEPTED %>) {
	// 				status = "accepted";
					classS = "success";
				} else if (v.status == <%=CurationMessage.STATUS_REJECTED %>) {
	// 				status = "rejected";
					classS = "danger";
				}
				cm['status'] = status;
				cm['classBTS'] = classS;
				// created
				var date = new Date(v.created);
				cm['created_year']  = date.getFullYear();
				cm['created_month'] = getFormatDate(date.getMonth()+1);
				cm['created_day']  = getFormatDate(date.getDate());
				// object
				cm['entity'] = null;
				cm['spectrum'] = null;
				cm['compound'] = null;
				cm['compound_type'] = null;
				if (v.spectrum !=null) {
					// TODO
					cm['entity'] = "spectrum";
					cm['spectrum_id'] = v.spectrum.id;
				}
				if (v.compound !=null) {
					cm['entity'] = "compound";
					cm['compound_id'] = v.compound.id;
					if (v.compound.type == <%=Compound.CHEMICAL_TYPE%>)
						cm['compound_type'] = "chemical";
					else if (v.compound.type == <%=Compound.GENERIC_TYPE%>)
						cm['compound_type'] = "generic";
					else if (v.compound.type == <%=Compound.SUBSTRUCTURE_TYPE%>)
						cm['compound_type'] = "substructure";
					else if (v.compound.type == <%=Compound.PUTATIVE_TYPE%>)
						cm['compound_type'] = "putative";
				}
				listOfAllCurationMessages.push(cm);
			});
			displayCurateMsgs(0);
			console.log("curation messages: ready!");
		});
	} // initLoadCurationMessage
	initLoadCurationMessage();
	
	deleteMessage = function(id) {
		if (confirm("Are you sure to delete this message ?")) {
			$.ajax({ 
				type: "post",
				url: "delete-curation-message",
				async: false,
				data: "id=" + id,
				success: function(data) {
					if (data) {
						var newCompoundMessages = [];
						$.each(listOfAllCurationMessages, function(key, value) {
							if (value.id != id)
								newCompoundMessages.push(value);
						});
						listOfAllCurationMessages = newCompoundMessages;
						$("#curation-message-id-"+id).remove();
					} else {
						var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete this message.';
						alert += ' </div>';
						$("#alertCurationMessageManagement").html(alert);
					}
				},
				error : function(xhr) {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete this message.';
					alert += ' </div>';
					$("#alertCurationMessageManagement").html(alert);
					console.log(xhr);
				}
			});
		}
	}
	
	rejectCurationMessage = function(id) {
		$.ajax({ 
			type: "post",
			url: "update-curation-message",
			async: false,
			data: "id=" + id + "&status=<%=CurationMessage.STATUS_REJECTED %>",
			success: function(data) {
				if (data) {
					var newCompoundMessages = [];
					$.each(listOfAllCurationMessages, function(key, value) {
						if (value.id == id) {
							value.status = <%=CurationMessage.STATUS_REJECTED %>;
							value.classBTS = "danger";
						}
						newCompoundMessages.push(value);
					});
					listOfAllCurationMessages = newCompoundMessages;
					$("#curation-message-id-"+id).removeClass('success');
					$("#curation-message-id-"+id).removeClass('warning');
					$("#curation-message-id-"+id).addClass('danger');
				} else {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this message.';
					alert += ' </div>';
					$("#alertCurationMessageManagement").html(alert);
				}
			},
			error : function(xhr) {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this message.';
				alert += ' </div>';
				$("#alertCurationMessageManagement").html(alert);
				console.log(xhr);
			}
		});
	}
	
	validateCurationMessage = function(id) {
		$.ajax({ 
			type: "post",
			url: "update-curation-message",
			async: false,
			data: "id=" + id + "&status=<%=CurationMessage.STATUS_ACCEPTED %>",
			success: function(data) {
				if (data) {
					var newCompoundMessages = [];
					$.each(listOfAllCurationMessages, function(key, value) {
						if (value.id == id) {
							value.status = <%=CurationMessage.STATUS_ACCEPTED %>;
							value.classBTS = "success";
						}
						newCompoundMessages.push(value);
					});
					listOfAllCurationMessages = newCompoundMessages;
					$("#curation-message-id-"+id).removeClass('danger');
					$("#curation-message-id-"+id).removeClass('warning');
					$("#curation-message-id-"+id).addClass('success');
				} else {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this message.';
					alert += ' </div>';
					$("#alertCurationMessageManagement").html(alert);
				}
			},
			error : function(xhr) {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this message.';
				alert += ' </div>';
				$("#alertCurationMessageManagement").html(alert);
				console.log(xhr);
			}
		});
	}
	
	checkIfReOpenDetailsModal = function () {
		return false;
	}
	var reopenDetailsModal = false;
	$('body').on('hidden.bs.modal', '.modal', function () {
		  $(this).removeData('bs.modal');
	});
	
	
	/////////////////////
	// init var
	var numberMaxResultsCitation = 20;
	var citationsDisplayed = [];
	
	/**
	 * Build & display curation message display
	 */
	displayCitationsMs= function (startPoint) {
		var subCitation = [];
		var currentDisplayCount = 0;
		var currentTotalCount = 0;
		$.each(listOfAllCitations, function(key, value) {
			if (isCitationFiltered(value)) { 
				if (currentTotalCount >= startPoint) {
					subCitation.push(value);
					currentDisplayCount++;
					if (currentDisplayCount>=numberMaxResultsCitation) {
						//displayCitationResults(subCitation, startPoint);
						return false;
					}
				}
				currentTotalCount++;
			}
		});
		displayCitationResults(subCitation, startPoint);
		return false;
	};
	
	var currentPageDisplayedCitation = 0;
	displayCitationResults = function (listCitations, startPoint) {
		currentPageDisplayedCitation = startPoint;
		usersDisplayed = listCitations;
		// build content
		$("#citationMngsTableBody").html("");
		$("#templateCitation").tmpl(listCitations).appendTo("#citationMngsTableBody");
		// rebuild page nav
		numberTotalResults = listOfAllCitations.length;
		var currentPage = startPoint / numberMaxResultsCitation;
		var lastPage = Math.ceil(numberTotalResults / numberMaxResultsCitation);
//	 		console.log("currentPage=" + currentPage);
//	 		console.log("lastPage=" + lastPage);
		var htmlPagination = "";
		// first
		if (currentPage==0) {
			htmlPagination += '<li class="disabled"><a href="#">&laquo;</a></li>';
		} else {
			htmlPagination += '<li><a href="#" onclick="displayCitationsMs(0);">&laquo;</a></li>';
		}
		// n-1
		if (currentPage>=1){
			htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
			var before = startPoint-numberMaxResultsCitation;
			htmlPagination += '<li><a href="#" onclick="displayCitationsMs('+before+');">'+(currentPage)+'</a></li>';
		}
		// n
		htmlPagination += '<li class="active"><a href="#">'+(currentPage+1)+'</a></li>';
		// n+1
		if ((currentPage+1)<lastPage){
			var after = startPoint+numberMaxResultsCitation;
			htmlPagination += '<li><a href="#" onclick="displayCitationsMs('+after+');">'+(currentPage+2)+'</a></li>';
			htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
		}
		// last
		if ((currentPage+1)==(lastPage)) {
			htmlPagination += '<li class="disabled"><a href="#">&raquo;</a></li>';
		} else {
			var after = (lastPage) * numberMaxResultsCitation - numberMaxResultsCitation;
			htmlPagination += '<li><a href="#" onclick="displayCitationsMs('+(after)+');">&raquo;</a></li>';
		}
		
		$.each($(".citationApa"),function(k,v){
			$(v).html($(v).text());
		});
		if (numberTotalResults!=0)
			$("#searchCitationPagination").html(htmlPagination);
		else 
			$("#searchCitationPagination").html("");
		$('table').trigger('update');
		$("#curateMsgSearchTable").tablesorter(); 
		resizeCitationsListPanel();
	};
	
	var citationStatusFilter = <%=Citation.STATUS_WAITING %>;
	var citationEntityFilter = "all";
	isCitationFiltered=function(citation){
		// filter status
		if (citationStatusFilter==0 && citation.status != <%=Citation.STATUS_WAITING %>)
			return false;
		if (citationStatusFilter== -1 && citation.status != <%=Citation.STATUS_REJECTED %>)
			return false;
		if (citationStatusFilter== 1 && citation.status != <%=Citation.STATUS_ACCEPTED %>)
			return false;
		var search = $("#curateMsgSearchFilter").val();
		if (search!= "" && !(citation.doi.indexOf(search) >= 0) )
			return false;
		return true;
	};
	
	resizeCitationsListPanel = function () {
		var diff_screen = 320;
		try{
			$("#citationMng-search-results").height($(window).height()-diff_screen);
			$("#citationMng-search-results").css("overflow","auto"); 
		}catch(e){} 
	};
	$(window).resize(function() {
		resizeCitationsListPanel();
	});
	
	var listOfAllCitations = [];
	
	// load curation messages
	function initLoadCitation() {
		listOfAllCitations = [];
		$.get("list-citations/250", function(data) {
// 		console.log(data);
			$.each(data, function(k,v){
				var cm = new Object();
				cm['id'] = v.id;
				cm['apa'] = v.apa;
				cm['doi'] = v.doi;
				cm['pmid'] = v.pmid;
				var author = "???";
				if (v.userID !=null && typeof users[v.userID] != "undefined")
					author = users[v.userID];
				cm['author'] = author;
				// status
				var status = v.status;
				var classS = "warning";
				if (v.status == <%=Citation.STATUS_WAITING %>) {
	// 				status = "waiting";
					classS = "warning";
				} else if (v.status == <%=Citation.STATUS_ACCEPTED %>) {
	// 				status = "accepted";
					classS = "success";
				} else if (v.status == <%=Citation.STATUS_REJECTED %>) {
	// 				status = "rejected";
					classS = "danger";
				}
				cm['status'] = status;
				cm['classBTS'] = classS;
				// created
				var date = new Date(v.created);
				cm['created_year']  = date.getFullYear();
				cm['created_month'] = getFormatDate(date.getMonth()+1);
				cm['created_day']  = getFormatDate(date.getDate());
				// object
				cm['entity'] = null;
				cm['spectrum'] = null;
				cm['compound'] = null;
				cm['compound_type'] = null;
				if (v.compound !=null) {
					cm['entity'] = "compound";
					cm['compound_id'] = v.compound.id;
					if (v.compound.type == <%=Compound.CHEMICAL_TYPE%>)
						cm['compound_type'] = "chemical";
					else if (v.compound.type == <%=Compound.GENERIC_TYPE%>)
						cm['compound_type'] = "generic";
					else if (v.compound.type == <%=Compound.SUBSTRUCTURE_TYPE%>)
						cm['compound_type'] = "substructure";
					else if (v.compound.type == <%=Compound.PUTATIVE_TYPE%>)
						cm['compound_type'] = "putative";
				}
				listOfAllCitations.push(cm);
			});
			displayCitationsMs(0);
			console.log("citations: ready!");
		});
	} // initLoadCitation
	initLoadCitation();
	
	getFormatDate = function(d){
		if (d>9)
			return d;
		else return "0"+d;
	}
	
	deleteCitation = function(id) {
		if (confirm("Are you sure to delete this citation ?")) {
			$.ajax({ 
				type: "post",
				url: "delete-citation",
				async: false,
				data: "id=" + id,
				success: function(data) {
					if (data) {
						var newCompoundCitations = [];
						$.each(listOfAllCitations, function(key, value) {
							if (value.id != id)
								newCompoundCitations.push(value);
						});
						listOfAllCitations = newCompoundCitations;
						$("#citation-id-"+id).remove();
					} else {
						var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete this citation.';
						alert += ' </div>';
						$("#alertCitationManagement").html(alert);
					}
				},
				error : function(xhr) {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete this citation.';
					alert += ' </div>';
					$("#alertCitationManagement").html(alert);
					console.log(xhr);
				}
			});
		}
	}
	
	rejectCitation = function(id) {
		$.ajax({ 
			type: "post",
			url: "update-citation",
			async: false,
			data: "id=" + id + "&status=<%=Citation.STATUS_REJECTED %>",
			success: function(data) {
				if (data) {
					var newCompoundCitations = [];
					$.each(listOfAllCitations, function(key, value) {
						if (value.id == id) {
							value.status = <%=Citation.STATUS_REJECTED %>;
							value.classBTS = "danger";
						}
						newCompoundCitations.push(value);
					});
					listOfAllCitations = newCompoundCitations;
					$("#citation-id-"+id).removeClass('success');
					$("#citation-id-"+id).removeClass('warning');
					$("#citation-id-"+id).addClass('danger');
				} else {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this citation.';
					alert += ' </div>';
					$("#alertCitationManagement").html(alert);
				}
			},
			error : function(xhr) {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this citation.';
				alert += ' </div>';
				$("#alertCitationManagement").html(alert);
				console.log(xhr);
			}
		});
	}
	
	validateCitation = function(id) {
		$.ajax({ 
			type: "post",
			url: "update-citation",
			async: false,
			data: "id=" + id + "&status=<%=Citation.STATUS_ACCEPTED %>",
			success: function(data) {
				if (data) {
					var newCompoundCitations = [];
					$.each(listOfAllCitations, function(key, value) {
						if (value.id == id) {
							value.status = <%=Citation.STATUS_ACCEPTED %>;
							value.classBTS = "success";
						}
						newCompoundCitations.push(value);
					});
					listOfAllCitations = newCompoundCitations;
					$("#citation-id-"+id).removeClass('danger');
					$("#citation-id-"+id).removeClass('warning');
					$("#citation-id-"+id).addClass('success');
				} else {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this citation.';
					alert += ' </div>';
					$("#alertCitationManagement").html(alert);
				}
			},
			error : function(xhr) {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this citation.';
				alert += ' </div>';
				$("#alertCitationManagement").html(alert);
				console.log(xhr);
			}
		});
	}
	
	/////////////////////
	// init var
	var numberMaxResultsNamesConv = 20;
	var namesConvDisplayed = [];
	
	resizeNamesConvListPanel = function () {
		var diff_screen = 320;
		try{
// 			$("#cpdNameConv-search-results").height($(window).height()-diff_screen);
			$("#cpdNameConv-search-results").css("overflow","auto"); 
		}catch(e){} 
	};
	$(window).resize(function() {
		resizeNamesConvListPanel();
	});
	
	var listOfAllNamesConv = [];
	
	// load curation messages
	function initLoadNamesConv() {
		$("#cpdNameConvMngsTableBody").html("");	
		$("#cpdNameConv-search-results").hide(500)
		$("#moreCpdNameConv i").addClass("fa-spin");
		$("#moreCpdNameConv span").html("Loading...");
		listOfAllNamesConv = [];
		$.get("list-cpd-names-to-convert/50", function(data) {
// 		console.log(data);
			$.each(data, function(k, v){
				var cpd = new Object();
				cpd['id'] = v.id;
				cpd['mainName'] = v.mainName;
				cpd['pfID'] = v.pfID;
				if (v.type == <%=Compound.CHEMICAL_TYPE%>)
					cpd['compound_type'] = "chemical";
				else if (v.type == <%=Compound.GENERIC_TYPE%>)
					cpd['compound_type'] = "generic";
				else if (v.type == <%=Compound.SUBSTRUCTURE_TYPE%>)
					cpd['compound_type'] = "substructure";
				else if (v.type == <%=Compound.PUTATIVE_TYPE%>)
					cpd['compound_type'] = "putative";
				var actions = [];
				var potIUPACname = "";
				var potIUPACcount = 0;
				// check if cas(s)
				$.each(v.names, function(kName, vName) {
					if (vName.score == 1 && vName.name.toUpperCase().startsWith("CAS:") ) { actions.push("" + vName.name) ;}
					if (vName.score == 2.5 ) { potIUPACname = vName.name; potIUPACcount++; }
				});
				// check if potential iupac
				if (potIUPACname != "" && potIUPACcount == 1 && v.upacName == null) {
					actions.push("IUPAC: " + potIUPACname);
				}
				// set action
				cpd['actions'] = actions;
				// pupush
				console.log(cpd);
				listOfAllNamesConv.push(cpd);
			});
			console.log("name conv: ready!");
			$("#templateCpdNameConv").tmpl(listOfAllNamesConv).appendTo("#cpdNameConvMngsTableBody");
			$("#moreCpdNameConv i").removeClass("fa-spin");
			$("#moreCpdNameConv span").html("reload top 50 ");
			$("#cpdNameConv-search-results").show(250)
		});
	} // initLoadCitation
	initLoadNamesConv();
	
	</script>
	
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
	<!-- MODAL - EDIT -->
	<div class="modal " id="modalEditSpectrum" tabindex="-1" role="dialog" aria-labelledby="modalEditSpectrumLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="modalEditSpectrumLabel">Modal title</h4>
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
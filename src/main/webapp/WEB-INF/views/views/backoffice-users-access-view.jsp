<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<div class="col-lg-12">
	<p></p>
	<div class="col-lg-12" style="z-index: 500;">
		<div class="form-group input-group col-lg-6">
			<input type="text" id="userSearchFilter" class="form-control" placeholder="John Doe" onkeyup="displayUsers(0)">
			<div class="input-group-btn">
				<button type="button" class="btn btn-primary dropdown-toggle"
					data-toggle="dropdown">
					<span id="search-user-filter"><i class="fa fa-search"></i>
						All</span> <span class="caret"></span>
				</button>
				<ul class="dropdown-menu pull-right">
					<li><a href="#"
						onclick="$('#search-user-filter').html($(this).html()); userFilter = 0; displayUsers(0)"><i
							class="fa fa-search"></i> All</a></li>
					<li><a href="#"
						onclick="$('#search-user-filter').html($(this).html()); userFilter = 1; displayUsers(0)"><i
							class="fa fa-search"></i> Only Not Activated</a></li>
					<li><a href="#"
						onclick="$('#search-user-filter').html($(this).html()); userFilter = 2; displayUsers(0)"><i
							class="fa fa-search"></i> Only Activated</a></li>
				</ul>
			</div>
		</div>
		<div class="form-group input-group col-lg-6"><div id="alertUserManagement"></div></div>
	</div>
	<p></p>
	<div id="user-search-results" class="col-lg-11">
		<div class="table-responsive">
			<script>
// 				setTimeout(function() {
// 					$('.switch-mini').bootstrapSwitch();
// 				}, 200);
			</script>
			<table id="userSearchTable" class="table table-hover tablesorter table-search">
				<thead>
					<tr>
						<th>Email / login <i class="fa fa-sort"></i></th>
						<th>Actif </th>
						<th>Authorization</th>
						<th>Remove</th>
					</tr>
				</thead>
				<tbody id="usersTableBody">

				</tbody>
				<tfooter>
				<tr>
					<td colspan="4">
						<button id="activateAll" type="button" class="btn btn-primary" onclick="activateAll()">Activate all</button> &nbsp;
						<button id="activateDisplayed" type="button" class="btn btn-primary" onclick="activateDisplayed()">Activate displayed</button></td>
				</tr>
				</tfooter>
			</table>
		</div>
	</div>
	<div class="col-lg-6">
		<ul id="searchUserPagination" class="pagination pagination-sm">
<!-- 			<li class="disabled"><a href="#">&laquo;</a></li> -->
<!-- 			<li class="active"><a href="#">1</a></li> -->
<!-- 			<li><a href="#">2</a></li> -->
<!-- 			<li><a href="#">3</a></li> -->
<!-- 			<li class="disabled"><a href="#">&#133;</a></li> -->
<!-- 			<li><a href="#">314</a></li> -->
<!-- 			<li><a href="#">&raquo;</a></li> -->
		</ul>
	</div>
	<div class="col-lg-6"></div>
	<p></p>
</div>

<%-- <script src="<c:url value="/resources/js/tablesorter/jquery.tablesorter.js" />"></script> --%>
<%-- <script src="<c:url value="/resources/js/tablesorter/tables.js" />"></script> --%>

<script type="text/javascript">
resizeUserListPanel = function(){
	var diff_screen = 320;
	try{
		$("#user-search-results").height($(window).height()-diff_screen);
		$("#user-search-results").css("overflow","auto"); 
	}catch(e){} 
};
$(window).resize(function() {
	resizeUserListPanel();
});

var users = [];

var numberMaxResults = 10;
var usersDisplayed = [];
displayUsers = function(startPoint){
	var subUser = [];
	var currentDisplayCount = 0;
	var currentTotalCount = 0;
	$.each(users, function(key, value) {
		if (isFiltered(value)) { 
			if (currentTotalCount >= startPoint) {
				subUser.push(value);
				currentDisplayCount++;
				if (currentDisplayCount>=numberMaxResults) {
					//displayUsersResults(subUser, startPoint);
					return false;
				}
			}
			currentTotalCount++;
		}
	});
	displayUsersResults(subUser, startPoint);
	return false;
};
var currentPageDisplayed = 0;
displayUsersResults=function (listUsers, startPoint) {
	currentPageDisplayed = startPoint;
	usersDisplayed = listUsers;
	// build content
	$("#usersTableBody").html("");
	$("#templateUsers").tmpl(listUsers).appendTo("#usersTableBody");
// 	setTimeout(function() {
		$('.switch-mini').bootstrapSwitch();
// 	}, 200);
	// rebuild page nav
	numberTotalResults = users.length;
	var currentPage = startPoint / numberMaxResults;
	var lastPage = Math.ceil(numberTotalResults / numberMaxResults);
// 		console.log("currentPage=" + currentPage);
// 		console.log("lastPage=" + lastPage);
	var htmlPagination = "";
	// first
	if (currentPage==0) {
		htmlPagination += '<li class="disabled"><a href="#">&laquo;</a></li>';
	} else {
		htmlPagination += '<li><a href="#" onclick="displayUsers(0);">&laquo;</a></li>';
	}
	// n-1
	if (currentPage>=1){
		htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
		var before = startPoint-numberMaxResults;
		htmlPagination += '<li><a href="#" onclick="displayUsers('+before+');">'+(currentPage)+'</a></li>';
	}
	// n
	htmlPagination += '<li class="active"><a href="#">'+(currentPage+1)+'</a></li>';
	// n+1
	if ((currentPage+1)<lastPage){
		var after = startPoint+numberMaxResults;
		htmlPagination += '<li><a href="#" onclick="displayUsers('+after+');">'+(currentPage+2)+'</a></li>';
		htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
	}
	// last
	if ((currentPage+1)==(lastPage)) {
		htmlPagination += '<li class="disabled"><a href="#">&raquo;</a></li>';
	} else {
		var after = (lastPage) * numberMaxResults - numberMaxResults;
		htmlPagination += '<li><a href="#" onclick="displayUsers('+(after)+');">&raquo;</a></li>';
	}
	$("#searchUserPagination").html(htmlPagination);
	$('table').trigger('update');
	$("#userSearchTable").tablesorter(); 
	resizeUserListPanel();
};
var userFilter = 0;
isFiltered=function(user){
	if (userFilter==1 && user.isConfirmed)
		return false;
	if (userFilter==2 && !user.isConfirmed)
		return false;
	var search = $("#userSearchFilter").val();
	if (search!= "" && !(user.login.indexOf(search) >= 0) )
		return false;
	return true;
};

/**
 * Get list of ALL users
 */
loadUsersFromDatabase = function() {
	if ($.isEmptyObject(users)) {
		$.ajax({ 
			type: "post",
			url: "admin/listUsers",
			dataType: "json",
			async: false,
//	 		data: "query=" + $('#search').val(),
			success: function(json) {
				users = json;
				// fifo to lifo
				users.reverse();
				displayUsers(0, users.lenght);
			},
			error : function(xhr) {
				subjects = [];
				// TODO alert error xhr.responseText
				console.log(xhr);
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not load users.';
				alert += ' </div>';
				$("#alertUserManagement").html(alert);
			}
		});
	}
};
loadUsersFromDatabase();

/**
 * Delete a user
 */
deleteUser = function (id, name) {
	if (confirm("Delete user '" + name + "'?")) {
		$.ajax({ 
			type: "post",
			url: "admin/delete-user",
			async: false,
			data: "id=" + id,
			success: function(data) {
				if (data) {
					var newUsers = [];
					$.each(users, function(key, value) {
						if (value.id != id)
							newUsers.push(value);
					});
					users = newUsers;
					$("#user"+id).remove();
				} else {
// 					alert("Error: could not delete this user.");
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete this user.';
					alert += ' </div>';
					$("#alertUserManagement").html(alert);
				}
			},
			error : function(xhr) {
// 				alert('Error: could not delete this user.');
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete this user.';
				alert += ' </div>';
				$("#alertUserManagement").html(alert);
				console.log(xhr);
			}
		});
	}
};

/**
 * Update right of ONE user
 */
updateUserRight= function (id, right) {
	$.ajax({ 
		type: "post",
		url: "admin/update-user",
		async: false,
		data: "id=" + id + "&right=" + right,
		success: function(data) {
			if (data) {
				var newUsers = [];
				$.each(users, function(key, value) {
					if (value.id == id) {
						if (right==<%=User.NORMAL %>) {
							value.isCurator = false;
							value.isAdmin = false;
						} else if (right==<%=User.CURATOR %>) {
							value.isCurator = true;
							value.isAdmin = false;
						} else if (right==<%=User.ADMIN %>) {
							value.isCurator = true;
							value.isAdmin = true;
						}
					}
					newUsers.push(value);
				});
				users = newUsers;
			} else {
// 				alert("Error: could not update this user.");
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this user.';
				alert += ' </div>';
				$("#alertUserManagement").html(alert);
			}
		},
		error : function(xhr) {
// 			alert('Error: could not update this user.');
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update this user.';
			alert += ' </div>';
			$("#alertUserManagement").html(alert);
			console.log(xhr);
		}
	});
};

/**
 * Activate ALL users
 */
activateAll = function () {
	if (confirm("Activate all users ?")) {
		$.ajax({ 
			type: "post",
			url: "admin/activate-all-users",
			async: false,
			success: function(data) {
				if (data) {
					var newUsers = [];
					$.each(users, function(key, value) {
						value.isConfirmed = true;
						newUsers.push(value);
					});
					users = newUsers;
// 					$(".activateUser").prop('checked', true);
					displayUsers(currentPageDisplayed);
				} else {
// 					alert("Error: could not activate all users.");
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not activate all users.';
					alert += ' </div>';
					$("#alertUserManagement").html(alert);
				}
			},
			error : function(xhr) {
// 				alert('Error: could not activate all users.');
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not activate all users.';
				alert += ' </div>';
				$("#alertUserManagement").html(alert);
				console.log(xhr);
			}
		});
	}
};

/**
 * Activate ONE user
 */
 var firstClick = false;
setUserConfirmation = function (id, checkbox) {
	if (!firstClick) {
		firstClick = true;
		return;
	}
	// Do it!
	$.ajax({ 
		type: "post",
		url: "admin/activate-user",
		async: false,
		data: "id=" + id + "&confirmed=" + $(checkbox).prop('checked'),
		success: function(data) {
			if (data) {
				var newUsers = [];
				$.each(users, function(key, value) {
					if (value.id == id)
						value.isConfirmed = $(checkbox).prop('checked');
					newUsers.push(value);
				});
				users = newUsers;
				displayUsers(currentPageDisplayed);
			} else {
// 				alert("Error: could not activate this user");
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not activate this user.';
				alert += ' </div>';
				$("#alertUserManagement").html(alert);
			}
			firstClick = false;
		},
		error : function(xhr) {
// 			alert('Error: could not activate this user');
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not activate this user.';
			alert += ' </div>';
			$("#alertUserManagement").html(alert);
			console.log(xhr);
			firstClick = false;
		}
	});
};

/**
 * Activate users displayed
 */
activateDisplayed = function () {
	// usersDisplayed
	var usersId = [];
	$.each(usersDisplayed, function(key, value) {
		usersId.push(value.id);
	});
	$.ajax({ 
		type: "post",
		url: "admin/activate-users",
		async: false,
		data: "ids=" + usersId,
		success: function(data) {
			if (data) {
				var newUsers = [];
				$.each(users, function(key, value) {
					$.inArray(value.id, usersId)
						value.isConfirmed = true;
					newUsers.push(value);
				});
				users = newUsers;
//					$(".activateUser").prop('checked', true);
				displayUsers(currentPageDisplayed);
			} else {
// 				alert("Error: could not acivate these users.");
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not acivate these users.';
				alert += ' </div>';
				$("#alertUserManagement").html(alert);
			}
		},
		error : function(xhr) {
// 			alert('Error: could not acivate these users.');
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not acivate these users.';
			alert += ' </div>';
			$("#alertUserManagement").html(alert);
			console.log(xhr);
		}
	});
};



</script>
<script  type="text/x-jquery-tmpl" id="templateUsers">
<tr id="user{%= id%}">
	<td>
		{%if password == "ldap" %}
			{%if login == email %}
				{%= login%}
			{%/if%}
			{%if login != email %}
				<a href="mailto:{%= email%}?subject=Peak%20Forest">{%= email%}</a>
			{%/if%}
		{%/if%}
		{%if password == null %}
		<a href="mailto:{%= email%}?subject=Peak%20Forest">{%= email%}</a>
		{%/if%}
	</td>
	<td>
		<input onchange="setUserConfirmation({%= id%}, this)" type="checkbox" data-on="success" data-off="danger" class="activateUser switch-mini" {%if isConfirmed %}checked{%/if%}></td>
	<td>
		<div class="form-group" style="width:150px; margin-bottom: 0px;">
			<select class="form-control btn btn-mini btn-info" onchange="updateUserRight({%= id%}, this.value)" {%if !isConfirmed %}disabled{%/if%}>
				<option value="<%= User.NORMAL %>" {%if (isConfirmed && !isCurator) %}selected{%/if%}>User</option>
				<option value="<%= User.CURATOR %>" {%if (isCurator && !isAdmin) %}selected{%/if%}>Curator</option>
				<option value="<%= User.ADMIN %>" {%if (isAdmin) %}selected{%/if%}>Admin</option>
			</select>
		</div>
	</td>
	<td>
		<a class="btn btn-danger btn-xs" onclick="deleteUser({%= id%},'{%= login%}');" href="#"> <i class="fa fa-trash-o fa-lg"></i></a>
	</td>
</tr>
</script>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<div class="col-lg-12">
<!-- 	<div class="col-lg-1"></div> -->
	<div class="col-lg-6" style="max-width: 500px;">
	<form id="formRegister" role="form" onsubmit="return false;">
		<div id="backOfficeAddUserAltert"></div>
		<div class="form-group input-group">
			<span class="input-group-addon">@</span> <input type="text" id="backOfficeAddUserEmail"
				class="form-control" placeholder="Email">
		</div>
		<div class="form-group input-group">
			<span class="input-group-addon"><i class="fa fa-key"></i></span> <input id="backOfficeAddUserPassword"
				type="password" class="form-control" placeholder="Password">
		</div>
		<div class="form-group input-group">
			<span class="input-group-addon"><i class="fa fa-key"></i></span> <input id="backOfficeAddUserCheckPassword"
				type="password" class="form-control" placeholder="Check Password">
		</div>
		<button id="addAndActiveAccount" type="button" class="btn btn-primary">Add
			&amp; activate user</button>
	</form>
	</div>
<!-- 	<div class="col-lg-3"></div> -->
</div>
<script type="text/javascript">
$("#addAndActiveAccount").bind({
	click: function() {
		addNewUser();
	}
});
$('#backOfficeAddUserCheckPassword').keypress(function(event) {
	if (event.keyCode == 13) {
		addNewUser();
	}
});


addNewUser = function () {
	// backOfficeAddUserEmail backOfficeAddUserPassword backOfficeAddUserCheckPassword
	// backOfficeAddUserAltert
	if($("#backOfficeAddUserEmail").val()=='') {
		var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.emptyEmail" text="Enter an Email please!" />';
		alert += ' </div>';
		$("#backOfficeAddUserAltert").html(alert);
		return false;
	} else if($("#backOfficeAddUserPassword").val()!=$("#backOfficeAddUserCheckPassword").val()) {
		var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.passwordMissmatch" text="Password / Check password missmatch!" />';
		alert += ' </div>';
		$("#backOfficeAddUserAltert").html(alert);
		return false;
	} else if ($("#backOfficeAddUserPassword").val().length<6) {
		var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.weakPassword" text="Password too weak, enter one with at least 6 characters." />';
		alert += ' </div>';
		$("#backOfficeAddUserAltert").html(alert);
		return false;
	} 
	// ajax
	$.ajax({ 
		type: "post",
		url: "admin/add-new-user",
		data: "email=" + $("#backOfficeAddUserEmail").val() + "&password=" + $("#backOfficeAddUserPassword").val(),
		async: false,
// 		data: "query=" + $('#search').val(),
		success: function(ret) {
			if (ret) {
				// reload users
				users = [];
				loadUsersFromDatabase();
				// reset form
				$("#backOfficeAddUserEmail").val('');
				$("#backOfficeAddUserPassword").val('');
				$("#backOfficeAddUserCheckPassword").val('');
				// display good new	
				var alert = '<div class="alert alert-success alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong>Success!</strong> user added!';
				alert += ' </div>';
				$("#backOfficeAddUserAltert").html(alert);
			} else {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not add user (not valid email or user already in database).';
				alert += ' </div>';
				$("#backOfficeAddUserAltert").html(alert);
			}

		},
		error : function(xhr) {
			subjects = [];
			// TODO alert error xhr.responseText
			console.log(xhr);
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not add user (not valid email or user already in database).';
			alert += ' </div>';
			$("#backOfficeAddUserAltert").html(alert);
		}
	});
};
</script>
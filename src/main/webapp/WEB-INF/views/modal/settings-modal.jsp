<%@page import="fr.metabohub.peakforest.security.model.User"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title><spring:message code="modal.settings.title" text="Settings" /></title>

<style type='text/css'>
</style>
<script type='text/javascript'>
	//<![CDATA[ 

	//]]>
</script>
</head>
<body>
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.settings.title" text="Settings" /></h4>
			</div>
			<div class="modal-body">
				<div id="settingsAltert"></div>
				<div class="te">

					<div class="" id="settings">
						<form id="formSettings" role="form" onsubmit="return false;" method="POST">
							<div class="form-group input-group">
								<span class="input-group-addon"><spring:message code="modal.settings.atOr" text="@ or" /> <i
									class="fa fa-user"></i></span> <input type="text" disabled="disabled" value="${user.login}"
									class="form-control" >
							</div>
							<c:if test="${not ldap}">
								<div class="form-group input-group">
									<span class="input-group-addon"><i class="fa fa-key"></i></span>
									<input name="" id="settingPassword" type="password" class="form-control"
										placeholder="<spring:message code="modal.settings.password" text="Password" />">
								</div>
								<div class="form-group input-group">
									<span class="input-group-addon"><i class="fa fa-key"></i></span>
									<input name="" id="settingPasswordCheck" type="password" class="form-control"
										placeholder="<spring:message code="modal.settings.passwordCheck" text="Check Password" />">
								</div>
							</c:if>
			
							<div class="form-group input-group" style="width: 500px;">
								<span class="input-group-addon" style="width: 250px;"><i class="fa fa-heart"></i> <spring:message code="modal.settings.mainTechnology" text="Main Technology" /></span>
								<select id="mainTechnology" class="advancedSearch form-control " style="width: 250px;">
									<option <c:if test="${mainTechnology eq 'gcms'}">selected</c:if> value="<%=User.PREF_GCMS %>" disabled="disabled">GCMS</option>
									<option <c:if test="${mainTechnology eq 'lcms'}">selected</c:if> value="<%=User.PREF_LCMS %>">LCMS</option>
									<option <c:if test="${mainTechnology eq 'lcmsms'}">selected</c:if> value="<%=User.PREF_LCMSMS %>" disabled="disabled">LCMSMS</option>
									<option <c:if test="${mainTechnology eq 'nmr'}">selected</c:if> value="<%=User.PREF_NMR %>">NMR</option>
								</select>
							</div>
							<c:if test="${user.confirmed}">
								<div class="form-group input-group">
									<span class="input-group-addon"><spring:message code="modal.settings.apiKey" text="API key" /> <i
										class="fa fa-unlock-alt" aria-hidden="true"></i></span> 
										<input id="userToken" type="text" class="form-control"  value="${token}">
										<span class="input-group-btn">
											<button id="generateToken" class="btn btn-info" type="button" title="">
												<i class="fa fa-retweet" aria-hidden="true"></i>
											</button>
										</span>
								</div>
							</c:if>
						</form>

					</div>

				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal"><spring:message code="modal.cancel" text="Cancel" /></button>
				<!--<button type="button" class="btn btn-primary">Save changes</button>-->
				<button id="buttonSaveSettings" type="button" class="btn btn-primary" onclick="saveSettings();"><i class="fa fa-save"></i> <spring:message code="modal.saveChanges" text="Save Changes" /></button>
				<script type="text/javascript">
				saveSettings = function () {
					// check
					// <c:if test="${not ldap}">
					if($("#settingPassword").val()!=$("#settingPasswordCheck").val()) {
						var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.passwordMissmatch" text="Password / Check password missmatch!" />';
						alert += ' </div>';
						$("#settingsAltert").html(alert);
						return false;
					} else if ($("#settingPassword").val().length<6) {
						var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.weakPassword" text="Password too weak, enter one with at least 6 characters." />';
						alert += ' </div>';
						$("#settingsAltert").html(alert);
						return false;
					}
					// </c:if>
					// ajax
					$.ajax({ 
						type: "post",
						url: "user/update-settings",
						data: "password=" + $("#settingPassword").val() + "&mainTechnology=" + $("#mainTechnology").val(),
						async: false,
			//	 		data: "query=" + $('#search').val(),
						success: function(rep) {
							if (rep) {
								var alert = '<div class="alert alert-success alert-dismissible" role="alert">';
								alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
								alert += '<strong><spring:message code="alert.strong.success" text="Success!" /></strong> <spring:message code="modal.settings.updatepasswordsucess" text="Password updated." />';
								alert += ' </div>';
								$("#settingsAltert").html(alert);
								// close modal 
								setTimeout(function() {
									$("#mySettingsModal").modal('hide');
								}, 2000);
							} else {
								var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
								alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
								alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.settings.cannotupdatepassword" text="Can not update password." />';
								alert += ' </div>';
								$("#settingsAltert").html(alert);
							}
						},
						error : function(xhr) {
							subjects = [];
							// TODO alert error xhr.responseText
							console.log(xhr);
							var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
							alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
							alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.settings.cannotupdatepassword" text="Can not update password." />';
							alert += ' </div>';
							$("#settingsAltert").html(alert);
						}
					});
				};
				$("#settingPasswordCheck").keypress(function(event) {
					if (event.keyCode == 13) {
						saveSettings();
					}
				});
				var userToken = "${token}";
				$("#userToken").keydown(function (event){
					if (event.keyCode === 8) { event.preventDefault(); }					
				}).keypress(function (event){
					event.preventDefault();
				}).bind("paste",function(e) {
					e.preventDefault();
				}).bind("cut",function(e) {
					setTimeout(function(){$("#userToken").val(userToken);}, 1);
				}).focus(function() { $(this).select(); } );;
				$("#generateToken").keypress(function (event){
					event.preventDefault();
				}).click(function(){
					$.ajax({ 
						type: "post",
						url: "user/renew-token",
						async: false,
						data: null,
			//	 		data: "query=" + $('#search').val(),
						success: function(rep) {
							userToken = rep;
							$("#userToken").val(userToken);
							var alert = '<div class="alert alert-info alert-dismissible" role="alert">';
							alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
							alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.settings.tokenUpdated" text="Token has been updated!" />';
							alert += ' </div>';
							$("#settingsAltert").html(alert);
						},
						error : function(xhr) {
							subjects = [];
							// TODO alert error xhr.responseText
							console.log(xhr);
							userToken = "???";
							$("#userToken").val(userToken);
							var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
							alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
							alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.settings.cannotupdateToken" text="Could not update token." />';
							alert += ' </div>';
							$("#settingsAltert").html(alert);
						}
					});
				});
				
				</script>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Login / register</title>

<style type='text/css'>
</style>
<script type='text/javascript'>
	//<![CDATA[ 
if(!window.jQuery) {
	window.location.replace("<spring:message code="peakforest.uri" text="https://peakforest.org/:" />");
}
if(typeof(loginError) != "undefined" && loginError !== null) {
	if (loginError==true) {
		// alert(loginErrorString);
		var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.badUserPasswordCombinaison" text="Bad user / password combination!" />';
		alert += ' </div>';
		$("#loginAltert").html(alert);
	}
}
if(typeof(registerError) != "undefined" && registerError !== null) {
	if (registerError==true) {
		// alert(registerErrorString);
		var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.unableToRegister" text="Unable to register, perhaps this login is already used by someone else." />';
		alert += ' </div>';
		$("#loginAltert").html(alert);
	}
}
	//]]>
</script>
</head>
<body>
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.login.title" text="Login / Register" /></h4>
			</div>
			<div class="modal-body">
				<div id="loginAltert"></div>
				<div class="te">

					<!-- 	    <div class="bs-example"> -->
					<ul class="nav nav-tabs" style="margin-bottom: 15px;">
						<li class="active"><a id="loginMenuId" href="#login" data-toggle="tab"
							onclick="$('#loginOrRegister').html('<spring:message code="modal.login.loginAction" text="Login" />'); action='login'; setTimeout(function(){$('#loginID').focus();},250);"><spring:message code="modal.login.menuLogin" text="Login" /></a></li>
						<li><a id="registerMenuId" href="#register" data-toggle="tab"
							onclick="$('#loginOrRegister').html('<spring:message code="modal.login.registerAction" text="Register" />'); action='register'; setTimeout(function(){$('#registerEmail').focus();},250);"><spring:message code="modal.login.menuRegister" text="Register" /></a></li>
							<li style="display: none;"><a id="resetPasswordMenuId" href="#resetPassword" data-toggle="tab"
							onclick="$('#loginOrRegister').html('<spring:message code="modal.login.resetPasswordAction" text="Reset password" />'); action='reset'; setTimeout(function(){$('#resetPasswordEmail').focus();},250);"><spring:message code="modal.login.menuReset" text="Reset password" /></a></li>
					</ul>
					<div id="myTabContent" class="tab-content">
						<div class="tab-pane fade active in" id="login">
							<form id="formLogin" role="form" name="f" action="<c:url value="j_spring_security_check" />" method="POST">
								<div class="form-group input-group">
									<span class="input-group-addon"><spring:message code="modal.login.atOr" text="@ or" /> <i
										class="fa fa-user"></i></span> <input name="j_username" type="text" id="loginID"
										class="form-control" placeholder="<spring:message code="modal.login.emailOrLogin" text="Email or Login" />">
								</div>
								<div class="form-group input-group">
									<span class="input-group-addon"><i class="fa fa-key"></i></span>
									<input name="j_password" id="loginPassword" type="password" class="form-control"
										placeholder="<spring:message code="modal.login.password" text="Password" />">
								</div>
							</form>
							<a href="#" onclick="$('#resetPasswordMenuId').click(); $('#resetPasswordMenuId').parent().show(); $('#resetPasswordEmail').focus();" class="pull-right" ><spring:message code="modal.login.ispasswordlost" text="password lost?" /></a>
						</div>
						<div class="tab-pane fade" id="register">
							<form id="formRegister" role="form" name="r" action="<c:url value="register" />" method="post" onsubmit="return passwordCheck();">
								<!--		      <div class="form-group input-group">
			<span class="input-group-addon"><i class="fa fa-user"></i></span>
			<input type="text" class="form-control" placeholder="Login">
		      </div>-->
								<div class="form-group input-group">
									<span class="input-group-addon">@</span> <input type="text" id="registerEmail"  name="email"
										class="form-control" placeholder="<spring:message code="modal.login.email" text="Email" />">
								</div>
								<div class="form-group input-group">
									<span class="input-group-addon"><i class="fa fa-key"></i></span>
									<input id="registerPassword1" type="password" name="password" class="form-control"
										placeholder="<spring:message code="modal.login.password" text="Password" />">
								</div>
								<div class="form-group input-group">
									<span class="input-group-addon"><i class="fa fa-key"></i></span>
									<input id="registerPassword" type="password" class="form-control"
										placeholder="<spring:message code="modal.login.checkPassword" text="Check Password" />">
								</div>
								<div class="form-group input-group">
									<label>&nbsp;</label>
									<label class="radio-inline">
										<input id="checkBoxModalLoginTermAndConditions" name="checkBoxModalLoginTermAndConditions" type="checkbox" value="term"> <spring:message code="modal.login.agreeTo" text="I agree to&nbsp;" />
										<a onclick="hideShowTAC();"><spring:message code="modal.login.termsAndConditions" text="terms &amp; conditions" /></a>
									</label>
								</div>
								<div class="form-group input-group" style="display: none">
									<span class="input-group-addon">birthday</span> <input type="text" id="birthday"  name="birthday"
										class="form-control" placeholder="birthday">
								</div>
								<script>
									hideShowTAC = function() {
										$("#checkBoxModalLoginTermAndConditions").prop("checked", !$("#checkBoxModalLoginTermAndConditions").is(":checked"));
										if ($('#termsAndConditions').css('display') == 'none') {
											$('#termsAndConditions').css('display', 'block');
										} else {
											$('#termsAndConditions').css('display', 'none');
										}
									}
								</script>
								<div id="termsAndConditions" style="height: 250px; display: none; overflow: scroll;">
									<!-- TODO move content into localized jsp -->
									<small>
										<h5>All Users <small>PeakForest: fair-use Term Of Service:</small></h5>
										<ul class="list-group" style="margin-right: 10px;">
											<li class="list-group-item">If you are using PeakForest screen­shots or com­pu­ta­tional tools for pub­li­ca­tion pur­pose, you will cite PeakForest</li>
											<li class="list-group-item">PeakForest is an aca­d­e­mic research facil­ity free of charge.
												<ul>
													<li>You will not make any profit by train­ing peo­ple to use PeakForest. If you want to orga­nize train­ing, please con­tact us. </li>
													<li>You will not make any profit using PeakForest representation.</li>
												</ul>
											</li>
											<li class="list-group-item">If you want to get involved in the devel­op­ment, please con­tact us.</li>
										</ul>
										<hr />
										<h5>Registered Users <small>By agree­ing this Term Of Ser­vice, you con­firm that once you will be registered:</small></h5>
										<ul class="list-group" style="margin-right: 10px;">
											<li class="list-group-item">You are responsible of any data or content you add and/or modify in the PeakForest database.</li>
											<li class="list-group-item">All provided data is queryable and visible for the user community.</li>
										</ul>
										<hr />
										<h5>PeakForest service users assert:</h5>
										<ul class="list-group" style="margin-right: 10px;">
											<li class="list-group-item">They are owner of data added to the peakforest database.</li>
											<li class="list-group-item">Otherwise, they must check that data are under a free license.</li> 
											<li class="list-group-item">They are allowed to add data to the peakforest database.</li>
											<li class="list-group-item"><i class="fa fa-exclamation-triangle"></i> Users are responsible of any added data copyright infringement!</li>
										</ul>
									</small>
								</div>
							</form>
						</div>
						<div class="tab-pane fade " id="resetPassword">
							<form id="resetPasswordForm" role="form" onsubmit="return false;">
								<div class="form-group input-group">
									<span class="input-group-addon">@ </span> <input  type="text" id="resetPasswordEmail"
										class="form-control" placeholder="<spring:message code="modal.login.email" text="Email" />">
								</div>
							</form>
							
						</div>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="setTimeout(function(){$('#search').focus();},250);"><spring:message code="modal.close" text="Close" /></button>
				<!--<button type="button" class="btn btn-primary">Save changes</button>-->
				<button id="loginOrRegister" type="button" class="btn btn-primary" onclick="loginOrRegisterAction();"><spring:message code="modal.login.loginAction" text="Login" /></button>
				<script type="text/javascript">
				var action = "login";
				function loginOrRegisterAction() {
					if (action=="login") {
						localStorage.loginURL = document.location.href;
						$("#formLogin").submit();
					} else if (action=="register") {
						localStorage.loginURL = document.location.href;
						$("#formRegister").submit();
					} else if (action=="reset") {
						resetPassword();
					}
				}
				$("#loginPassword").keypress(function(event) {
					if (event.keyCode == 13) {
						localStorage.loginURL = document.location.href;
						$("#formLogin").submit();
					}
				});
				$("#registerPassword").keypress(function(event) {
					if (event.keyCode == 13) {
						localStorage.loginURL = document.location.href;
						$("#formRegister").submit();
					}
				});
				$("#resetPasswordEmail").keypress(function(event) {
					if (event.keyCode == 13) {
						resetPassword();
					}
				});
				passwordCheck = function() {
					if($("#registerEmail").val()=='') {
						var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.emptyEmail" text="Enter an Email please!" />';
						alert += ' </div>';
						$("#loginAltert").html(alert);
						return false;
					} else if($("#registerPassword1").val()!=$("#registerPassword").val()) {
						var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.passwordMissmatch" text="Password / Check password missmatch!" />';
						alert += ' </div>';
						$("#loginAltert").html(alert);
						return false;
					} else if ($("#registerPassword1").val().length<6) {
						var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.weakPassword" text="Password too weak, enter one with at least 6 characters." />';
						alert += ' </div>';
						$("#loginAltert").html(alert);
						return false;
					} else if (!$('#checkBoxModalLoginTermAndConditions').prop('checked')) {
						var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.acceptTermsAndConditions" text="You must accept the terms &amp; conditions to register." />';
						alert += ' </div>';
						$("#loginAltert").html(alert);
						return false;	
					}
					return true;
				};
				resetPassword = function () {
					var email = $("#resetPasswordEmail").val();
					if ((email.indexOf("@") >= 0)) {
						$.ajax({ 
							type: "post",
							url: "reset-password",
							data: "email=" + email,
							async: false,
//					 		data: "query=" + $('#search').val(),
							success: function(ok) {
								if (ok) {
									var alert = '<div class="alert alert-success alert-dismissible" role="alert">';
									alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
									alert += '<strong><spring:message code="alert.strong.success" text="Success!" /></strong> <spring:message code="modal.login.alert.passwordResetedSuccess" text="An email has been sent to you with a new password." />';
									alert += ' </div>';
									$("#loginAltert").html(alert);
									$('#loginMenuId').click();
									$('#resetPasswordMenuId').parent().hide();
								} else {
									var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
									alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
									alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.errorResetPassword" text="Could not reset password: unknown user." />';
									alert += ' </div>';
									$("#loginAltert").html(alert);
									$('#registerMenuId').click();
									$('#resetPasswordMenuId').parent().hide();
								}
							},
							error : function(xhr) {
								subjects = [];
								// TODO alert error xhr.responseText
								console.log(xhr);
								var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
								alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
								alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.errorResetPassword" text="Could not reset password: unknown user." />';
								alert += ' </div>';
								$("#loginAltert").html(alert);
								$('#registerMenuId').click();
								$('#resetPasswordMenuId').parent().hide();
							}
						});
					} else {
						var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
						alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
						alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <spring:message code="modal.login.alert.emptyEmail" text="Enter an Email please!" />';
						alert += ' </div>';
						$("#loginAltert").html(alert);
					}
				};
				$("#birthday").remove();
				setTimeout(function(){$("#loginID").focus()}, 50);
				</script>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>
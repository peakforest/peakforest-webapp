<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<div class="col-lg-12">
	<div id="" class="col-lg-12">
		<div class="form-group input-group col-lg-6"><div id="alertLicenseManager"></div></div>
		<br />
		<div class="table-responsive">
			<table class="table table-hover" style="max-width: 1000px;">
				<thead>
					<tr>
						<th>Key </th>
						<th>Value </th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>license status</td>
						<td>
							<span id="license-status">loading...</span>
							<a class="btn  btn-xs btn-disabled" href="#">
								<i class="fa  fa-lg"></i>
							</a>
						 </td>
					</tr>
					<tr>
						<td>email</td>
						<td>
							<span id="license-email">loading...</span>
							<div id="inputEdit_emailLicense" class="form-group input-group" style="display: none; max-width:400px;">
								<input type="text" class="form-control input-active-enter-key" style="" value="" placeholder="">
								<span class="input-group-btn">
									<button class="btn btn-success" type="button" onclick="setNewEmail();"><i class="fa fa-search fa-check-square-o"></i></button>
								</span>
							</div>
							<a class="btn btn-info btn-xs " onclick="editLicenseEmail();" href="#">
								<i class="fa fa-pencil fa-lg"></i>
							</a>
						</td>
					</tr>
					<tr>
						<td>license code</td>
						<td>
							<span id="license-code">loading...</span>
						</td>
					</tr>
					<tr>
						<td>authorizations</td>
						<td>
							<span id="license-authorizations">loading...</span>
						</td>
					</tr>
				</tbody>
				<tfoot>
					<tr>
						<td style="white-space: nowrap;">
							<!-- only display if email edited -->
							<button id="" type="button" class="btn btn-small btn-primary btnShowIfEmailChanged" style="display: none;" onclick="licenseSaveNewEmail()"><i class="fa fa-floppy-o"></i> save</button>
							<button id="" type="button" class="btn btn-small btn-default btnShowIfEmailChanged" style="display: none;"  onclick="licenseResetEmail()"><i class="fa fa-undo"></i> cancel</button>
							<!-- always display  -->
							<a class="btn btn-small btn-default btnShowIfEmailNotChanged" href="admin/get-license-file" title="download license file" target="_blank">
								<i class="fa fa-download"></i> get license file
							</a>
							
						</td>
						<td style="white-space: nowrap;">
							<!-- always display  -->
							<div class="input-group" style="">
<!-- 								<span class="input-group-btn"> <span class="btn btn-primary btn-file"> -->
<!-- 									Browse&hellip;  -->
<!-- 									<input id="" type="file" accept=".license" > -->
<!-- 								</span> -->
<!-- 								</span> <input type="text" class="form-control" readonly placeholder="select new license file to upload"> -->
								
								
<span id="licenseFileUploadContainer"></span>
<div id="addlicenseFileFormContent" class="input-group pull-right" style="">
	<span class="input-group-btn">
		<span class="btn btn-primary btn-file-nmr-raw btn-file"> Browse&#133;
			<input id="licenseFile" type="file" name="file" accept=".license">
		</span>
		<input type="hidden" name="ajaxUpload" value="true">
	</span>
	<input id="licenseFileBtn" type="text" class="form-control" readonly placeholder="select new license file to upload">
</div>
								
							</div>
						</td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>
<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>

<div id="licenseFileUploading" class="" style="display:none;" >
	<br />
	<br />
	<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
</div>
<div id="licenseFileUploadResults" class="" style="display:none;" >
</div>
<div id="licenseFileUploadError" class="" style="max-width: 350px;" ></div>
<script type="text/javascript">
//
checkUploadlicenseFileForm=function() {
	if ($("#licenseFile").val()=='') {
		return false;
	}
	return true;
};
//file upload
$(document).on('change', '.btn-file-nmr-raw.btn-file :file', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('.btn-file-nmr-raw.btn-file :file').on('fileselect', function(event, numFiles, label) { 
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;
		if(input.length) {
			input.val(log);
			// startUpload();
			$("#addlicenseFileFormContent").appendTo("#licenseFileUploadForm");
			$("#licenseFileUploadForm").submit();
		} else {
			if(log) alert(log);
		}
	});

	$("#licenseFileUploadForm").ajaxForm({
		beforeSubmit: startUploadlicenseFile,
		success: function(data) {
			var data2 = data.trim();
			if (data2 == "OK") {
				loadLicenseData();
				$(".btnShowIfEmailChanged").hide();
				$(".btnShowIfEmailNotChanged").show();
				$("#licenseFile").val("");
				$("#licenseFileBtn").val("");
			} else {
				var stringError = "";
				if (data2 == "no_file_selected")
					stringError = "no file selected!";
				else if (data2 == "wrong_ext")
					stringError = "wrong file extension";
				else if (data2 == "empty_file")
					stringError = "uploaded file is empty";
				else 
					stringError = "an error occured; please contact dev. team!";
				var errorBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> ' + stringError;
				errorBox += ' </div>';
				$("#licenseFileUploadError").html(errorBox);
			}
			$("#licenseFileUploading").hide();
			$("#addlicenseFileFormContent").appendTo("#licenseFileUploadContainer");
		},
		error: function() {
			// TODO alert message
			var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
				errorBox += ' </div>';
				$("#licenseFileUploadError").html(errorBox);
			$("#licenseFileUploading").hide();
			$("#addImageFormContent").appendTo("#fileUploadContainer");
		}
	});
});

function startUploadlicenseFile() {
	$("#licenseFileUploadError").html("");
	$("#licenseFileUploading").show();
	//
}

</script>

<div style="display:none;">
	<form id="licenseFileUploadForm" action="upload-license-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadlicenseFileForm()">
	</form>
</div>

<script type="text/javascript">

var emailLicense = null;
var newEmailLicense = null;

loadLicenseData = function() {
	$.ajax({ 
		type: "post",
		url: "admin/getLicenseData",
		dataType: "json",
		async: false,
// 		data: "query=" + $('#search').val(),
		success: function(json) {
			console.log(json);
			var valA = $("#license-status").parent().find("a");
			var valI = $("#license-status").parent().find("i");
			$(valA).removeClass("btn-success").removeClass("btn-danger");
			$(valI).removeClass("fa-check-circle").removeClass("fa-times-circle");
			if (json.validity==="true") {
				$("#license-status").html("valid"); 
				$(valA).addClass("btn-success");
				$(valI).addClass("fa-check-circle");
			} else {
				$("#license-status").html("not valid");
				$(valA).addClass("btn-danger");
				$(valI).addClass("fa-times-circle");
			}
			$("#license-email").html(json.email);
			emailLicense = json.email;
			$("#license-code").html(json.license);
			$("#license-authorizations").html(json.authorizations);
			$(".btnShowIfEmailChanged").hide();
			$(".btnShowIfEmailNotChanged").show();
		},
		error : function(xhr) {
			subjects = [];
			// TODO alert error xhr.responseText
			console.log(xhr);
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not load license datum.';
			alert += ' </div>';
			$("#alertLicenseManager").html(alert);
		}
	});
}

loadLicenseData();

editLicenseEmail = function() {
	// hide
	$("#license-email").hide();
	$("#license-email").parent().find("a").hide();
	// show
	$("#inputEdit_emailLicense").show();
	$("#inputEdit_emailLicense input").val(emailLicense);
	$("#inputEdit_emailLicense input").attr("placeholder", emailLicense);
	$("#inputEdit_emailLicense input").focus();
}

setNewEmail = function() {
	// hide
	$("#inputEdit_emailLicense").hide();
	newEmailLicense = $("#inputEdit_emailLicense input").val();
	$("#license-email").html(newEmailLicense);
	// show
	$("#license-email").show();
	$("#license-email").parent().find("a").show();
	if (newEmailLicense!=emailLicense) {
		$(".btnShowIfEmailChanged").show();
		$(".btnShowIfEmailNotChanged").hide();
	}
}

licenseSaveNewEmail = function() {
	// newEmailLicense
	$.ajax({ 
		type: "post",
		url: "admin/set-license-email",
		data: "email=" + newEmailLicense ,
		async: false,
// 		data: "query=" + $('#search').val(),
		success: function(ret) {
			if (ret) {
				// reload data
				loadLicenseData();
				// display good new	
				var alert = '<div class="alert alert-success alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong>Success!</strong> license updated!';
				alert += ' </div>';
				$("#alertLicenseManager").html(alert);
			} else {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not set email (not valid email or user not in database).';
				alert += ' </div>';
				$("#alertLicenseManager").html(alert);
			}

		},
		error : function(xhr) {
			subjects = [];
			// TODO alert error xhr.responseText
			console.log(xhr);
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not set email (not valid email or user not in database).';
			alert += ' </div>';
			$("#alertLicenseManager").html(alert);
		}
	});
}

licenseResetEmail = function () {
	$("#license-email").html(emailLicense);
	$(".btnShowIfEmailChanged").hide();
	$(".btnShowIfEmailNotChanged").show();
}

$(".input-active-enter-key").keypress(function(event) {
	if (event.keyCode == 13) {
		$(this).parent().find('button').click();
	}
});

</script>
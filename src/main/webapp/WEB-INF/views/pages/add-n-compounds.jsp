<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<%@page import="fr.metabohub.peakforest.services.ProcessProgressManager" %>

<form id="fileUploadForm" action="upload-compound-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadChemLibForm()">
	<div class="col-lg-6">
		<div class="input-group">
			<span class="input-group-btn">
					<span class="btn btn-primary btn-file"> Browse… 
						<input id="file" type="file" name="file" accept=".xls">
					</span>
<!-- 					multiple="" -->
					<input type="hidden" name="ajaxUpload" value="true" />
					<input id="requestID" name="requestID" type="hidden" value="<%=ProcessProgressManager.getNewClientID() %>" />
			</span> <input type="text" class="form-control" readonly="readonly">
		</div>
	</div>
</form>

<script>
//
checkUploadChemLibForm=function() {
	if ($("#file").val()=='') {
		return false;
	}
	return true;
};
//file upload
$(document).on('change', '.btn-file :file', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('.btn-file :file').on('fileselect', function(event, numFiles, label) {
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;
		if(input.length) {
			input.val(log);
			// startUpload();
			$("#fileUploadForm").submit();
		} else {
			if(log) alert(log);
		}
	});
});
$(document).ready(function() {
	$("#fileUploadForm").ajaxForm({
		beforeSubmit: runProcessProgress,
		success: function(data) {
			$("#importTabResults").replaceWith(data);
			if ($('#importTabResults').length == 0) {
				location.href = "home";
			}
		},
		error: function() {
			// TODO alert message
// 			alert("FAIL"); 
		}
	});
});
var uploadRuning = false;
var uploadProgress = 0;
runProcessProgress = function() {
	$("#importTabResults").replaceWith('<div id="importTabResults"></div>');
	// block other upload
	// $("#file").prop('disabled', true);
	// $("#file").attr('disabled', true);
	uploadRuning = true;
	uploadProgress = 0;
	// reset
	$("#iconImportFile").removeClass("fa-spinner fa-spin fa-check-circle fa-exclamation-triangle"); 
	$("#iconUploadFile").removeClass("fa-spinner fa-spin fa-check-circle fa-exclamation-triangle");
	$("#iconImportResults").removeClass("fa-spinner fa-spin fa-check-circle fa-exclamation-triangle");
	$("#importBar").addClass('progress-striped active');
	$("#importProgress").width('0%');
// 	$("#uploadProgressBar").addClass('progress-striped active');
// 	$("#uploadProgressBar").width('0%');
	isUploadStoped= false;
	isImportStarted = false;
	isImportStoped = false;
	$("#uploadSuccess").width('0%');
	$("#importSuccess").width('0%');
	$("#importWarning").width('0%');
	$("#importFail").width('0%');
	if ($("#file").val()=='') {
		return;
	}
	setTimeout(function() {
		checkProcessProgress();
	}, 500);
};
checkProcessProgress = function() {
	if (uploadProgress==0) {
		startUpload();
	}
	$.ajax({
		type: 'post',
		url: 'processProgression',
		data: 'requestID='+$("#requestID").val()+'&requestLabel=<%=ProcessProgressManager.XLS_IMPORT_CHEMICAL_LIB_LABEL%>'
	}).done(function(data){
		if ($("#importTabResults").hasClass("uploadChemLibDone")) {
			stopUpload();
			stopImport();
			return;
		}
		if (data!="") {
			stopUpload();
			startImport();
			$("#importProgress").width(data +'%');
		}
		// upload runing 
		if (uploadRuning) {
			if (uploadProgress<100) {
				uploadProgress += 5;
				$("#uploadProgressBar").width(uploadProgress+'%');
			}
		}
		setTimeout(function() {
			checkProcessProgress();
		}, 500);
		return;
	}).fail(function(data){
		$("#iconImportFile").removeClass("fa-spinner fa-spin"); 
		$("#iconImportFile").addClass("fa-exclamation-triangle");
		stopUpload();
		stopImport();
		// TODO alert error
	}).always(function(data){
	});
};

// download file with Failed imports
createChemicalLibFailXlsFile = function() {
	$("#createListFailedXlsFile").hide();
	$("#generatingListFailedXlsFile").show();
	$.ajax({
		type: 'post',
		url: 'chemical-libary-xls-errors',
		data: 'fileSource='+$("#fileSource").val()+'&listRowFailed='+$("#listFailed").val()
	}).done(function(data){
		// console.log(data);
		// var a = $("#downloadListFailedXlsFile");
		$("#generatingListFailedXlsFile").hide();
		$("#downloadListFailedXlsFile").show();
		$("#downloadListFailedXlsFile").attr({ href : data });
		// window.open(data, '_blank');
// 		$("#downloadListFailedXlsFile").click();
		// $(a).click();
	}).fail(function(data){
// 		alert("fail");
		// TODO message error
	}).always(function(data){
	});
};

function startUpload() {
	$("#iconUploadFile").addClass("fa-spinner fa-spin"); 
	$("#uploadBar").addClass('progress-striped active');
	uploadProgress = 5;
	uploadRuning = true;
}
var isUploadStoped = false;
function stopUpload() {
	uploadRuning = false;
	if (!isUploadStoped) {
		isUploadStoped = true;
		$("#uploadProgressBar").width('0%');
		$("#uploadSuccess").width('100%');
		$("#iconUploadFile").removeClass("fa-spinner fa-spin");
		$("#iconUploadFile").addClass("fa-check-circle"); 
	}
};
var isImportStarted = false;
function startImport() {
	if (!isImportStarted) {
		isImportStarted = true;
		$("#iconImportFile").addClass("fa-spinner fa-spin");
		$("#uploadBar").removeClass('progress-striped active');
	}
	  
};
var isImportStoped = false;
function stopImport() {
	if (!isImportStoped) {
		isImportStoped = true;
		$("#importBar").removeClass('progress-striped active');
		$("#importProgress").width('0%');
		$("#importTabResults").show();
		$("#iconImportFile").removeClass("fa-spinner fa-spin"); 
		$("#iconImportFile").addClass("fa-check-circle");
		setTimeout(function() { $("#iconImportFile").removeClass("fa-spinner fa-spin"); }, 50);
		// 		
		$("#importSuccess").width($("#newCompoundsPerCent").text() +'%');
		$("#importWarning").width($("#mergedCompoundsPerCent").text()+'%');
		// compute fail size
		var nbErrorPerCent = 0;
		if (Number($("#errorCompoundsPerCent").text())!=0) {
			nbErrorPerCent = 100 - Number($("#newCompoundsPerCent").text() ) - Number($("#mergedCompoundsPerCent").text());
		}
		$("#importFail").width(nbErrorPerCent+'%');
		//$("#iconImportResults").addClass("fa-exclamation-triangle");
		if ($('#errorCompoundsPerCent').length == 0){//}($("#errorCompoundsPerCent").text()=='0') {
			$("#iconImportResults").addClass("fa-check-circle");
		} else {
			$("#iconImportResults").addClass("fa-exclamation-triangle");
			createChemicalLibFailXlsFile();
		}
		startImport();
	}
};
</script>


<div class="col-lg-6 ">
	<a class="pull-right" target="_blank" href="<c:url value="/resources/data/template_chemical_lib.xls" />">download template</a>
</div>

<br />
<br />
<br />

<div class="col-lg-3">
	upload file <i id="iconUploadFile" class="fa"></i>
</div>
<div class="col-lg-9">
	<div id="uploadBar" class="progress">
		<div id="uploadSuccess" class="progress-bar progress-bar-success"
			style="width: 0%"></div>
		<div id="uploadProgressBar" class="progress-bar progress-striped active" style="width: 0%"></div>
	</div>
</div>

<div class="col-lg-3">
	gathering data <i id="iconImportFile" class="fa"></i>
</div>
<div class="col-lg-9">
	<div id="importBar" class="progress progress-striped active">
		<div id="importSuccess" class="progress-bar progress-bar-success"
			style="width: 0%"></div>
		<div id="importWarning" class="progress-bar progress-bar-warning"
			style="width: 0%"></div>
		<div id="importFail" class="progress-bar progress-bar-danger"
			style="width: 0%"></div>
		<div id="importProgress" class="progress-bar" style="width: 0%"></div>
	</div>
</div>

<div class="col-lg-3">
	import result <i id="iconImportResults" class="fa"></i>
</div>
<div class="col-lg-9">
	<div id="importTabResults" style="display: none;"
		class="table-responsive">
	</div>
</div>
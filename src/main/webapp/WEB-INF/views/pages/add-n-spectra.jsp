<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="fr.metabohub.peakforest.services.ProcessProgressManager" %>
<%@ page session="false"%>


<div class="col-lg-12  panel panel-default">
	<div class="panel-body">
		<!--      SELECT SPECTRE FILE-->
		<form id="fileUploadForm" action="upload-spectra-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadSpectraLibForm()">
			<div class="col-lg-12">
				<div class="input-group">
					<span class="input-group-btn">
						<span class="btn btn-primary btn-file btn-uploadAndImport"> Browse… 
							<input id="uploadSpectrumFile" name="file" type="file" multiple="" accept=".xlsm,.zip">
						</span>
						<input type="hidden" name="ajaxUpload" value="true" />
						<input id="requestID" name="requestID" type="hidden" value="<%=ProcessProgressManager.getNewClientID() %>" />
					</span>
					<input type="text" class="form-control" readonly="">
				</div>
			</div>
			
		</form>
	</div>
</div>

<div class="col-lg-12  panel panel-default">
	<div id="uploadFileStatus" class="panel-body">
		<div class="col-lg-3">
			upload file <i id="iconUploadFile" class="fa "></i>
		</div>
		<div class="col-lg-9">
			<div id="uploadBar" class="progress">
				<div id="uploadSuccess" class="progress-bar progress-bar-success"
					style="width: 0%"></div>
				<div id="uploadProgressBar" class="progress-bar" style="width: 0%"></div>
			</div>
		</div>

		<div class="col-lg-3">
			gathering data <i id="iconImportFile" class="fa "></i>
		</div>
		<div class="col-lg-9">
			<div id="importBar" class="progress progress-striped active">
				<div id="importSuccess" class="progress-bar progress-bar-success" style="width: 0%"></div>
				<div id="importFail" class="progress-bar progress-bar-danger" style="width: 0%"></div>
				<div id="importProgress" class="progress-bar" style="width: 0%"></div>
			</div>
		</div>


		<div class="col-lg-3">
			import result <i id="#iconImportResults" class="fa "></i>
		</div>
		<div class="col-lg-9">
			<div id="importTabResults" style="display: none;" class="table-responsive">
			</div>
		</div>
	</div>
</div>

<div id="uploadRawNMRfileDiv" class="col-lg-12  panel panel-default" style="display: none;">
	<div id="" class="panel-body">
					<div class="pull-right">
						<br />
						<span id="rawNmrFileUploadContainer_file"></span>
						<div id="addRawNmrFileFormContent_file" class="input-group pull-right" style="max-width: 350px;">
							<span class="input-group-btn">
									<span class="btn btn-primary btn-file-nmr-raw_file btn-file"> Browse&#133;
										<input id="rawNmrFile_file" type="file" name="file" accept=".zip">
									</span>
				<!-- 					multiple="" -->
									<input type="hidden" name="ajaxUpload" value="true">
									<input id="raw_file_spectrum_id__file" name="spectrum_id" type="hidden" value="-1" />
							</span> <input type="text" class="form-control" readonly>
						</div>
						<br />
						<small>
							Add / overwrite this data with a new Raw file. <br />
							You must Zip the directory of you acquisition data to upload it.
						</small>
						<br />
						<br />
					</div>
					<div class="">
					</div>
					<div id="rawNmrFileUploading_file" class="" style="display:none;" >
						<br />
						<br />
						<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
					</div>
					<div id="rawNmrFileUploadResults_file" class="" style="display:none;" ></div>
					<div id="rawNmrFileUploadError_file" class="" style="max-width: 350px;" ></div>
<script type="text/javascript">
//
checkUploadRawNmrFileForm_file=function() {
	if ($("#rawNmrFile_file").val()=='') {
		return false;
	}
	return true;
};
//file upload
$(document).on('change', '.btn-file-nmr-raw_file.btn-file :file', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('.btn-file-nmr-raw_file.btn-file :file').on('fileselect', function(event, numFiles, label) { 
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;
		if(input.length) {
			input.val(log);
			// startUpload();
			$("#addRawNmrFileFormContent_file").appendTo("#rawNmrFileUploadForm_file");
			$("#rawNmrFileUploadForm_file").submit();
		} else {
			if(log) alert(log);
		}
	});

	$("#rawNmrFileUploadForm_file").ajaxForm({
		beforeSubmit: startUploadRawNmrFile_file,
		success: function(data) {
			var tabData = {};
			$.each(data.trim().split("\n"),function(k, v) {
				var tData = (v).split("=");
				tabData[tData[0]] = tData[1];
			}); 
			if (tabData["success"] == "true") {
				if ((tabData["reload"] == "true")) { 
					// no reload!
					document.location = ("?pf=" + listSpectraNMRids);
				}
				else {
					if (tabData["procFiles"]) {
						stringInfo = "select proc. file: <ul>";
						var files = tabData["procFiles"].split(",");
						$.each(files, function(k,v) {
							if (v!="")
								stringInfo += '<li><a onclick="submitRawNmrFile_addProcFile_file(\''+v+'\')">'+v+"</a></li>";
						});
					} else if (tabData["files"]) {
						stringInfo = "select aq. file: <ul>";
						var files = tabData["files"].split(",");
						$.each(files, function(k,v) {
							if (v!="")
								stringInfo += '<li><a onclick="submitRawNmrFile_addAqFile_file(\''+v+'\')">'+v+"</a></li>";
						});
					}
					stringInfo += "</ul>";
					var infoBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
					infoBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					infoBox += '<strong>Need more details</strong> ' + stringInfo;
					infoBox += ' </div>';
					$("#rawNmrFileUploadError_file").html(infoBox);
				}
			} else {
				var stringError = "";
				if (tabData["error"] == "no_file_selected")
					stringError = "no file selected!";
				else if (tabData["error"] == "wrong_ext")
					stringError = "wrong file extension";
				else if (tabData["error"] == "empty_file")
					stringError = "uploaded file is empty";
				else 
					stringError = "an error occured; please contact dev. team!";
				var errorBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> ' + stringError;
				errorBox += ' </div>';
				$("#rawNmrFileUploadError_file").html(errorBox);
			}
			$("#rawNmrFileUploading_file").hide();
			$("#addRawNmrFileFormContent_file").appendTo("#rawNmrFileUploadContainer_file");
		},
		error: function() {
			// alert message
			var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
				errorBox += ' </div>';
			$("#rawNmrFileUploadError_file").html(errorBox);
			$("#rawNmrFileUploading_file").hide();
			$("#addRawNmrFileFormContent_file").appendTo("#rawNmrFileUploadContainer_file");
		}
	});
});

function startUploadRawNmrFile_file() {
	$("#rawNmrFileUploadError_file").html("");
	$("#rawNmrFileUploading_file").show();
	//
}

function submitRawNmrFile_addAqFile_file(file) {
	$("#rawNmrFileUploadForm_file").append('<input type="hidden" name="aq_file" value="'+file+'">');
	$("#addRawNmrFileFormContent_file").appendTo("#rawNmrFileUploadForm_file");
	$("#rawNmrFileUploadForm_file").submit();
}
function submitRawNmrFile_addProcFile_file(file) {
	$("#rawNmrFileUploadForm_file").append('<input type="hidden" name="proc_file" value="'+file+'">');
	$("#addRawNmrFileFormContent_file").appendTo("#rawNmrFileUploadForm_file");
	$("#rawNmrFileUploadForm_file").submit();
}

</script>
	</div>
</div>

<script type="text/javascript">

/**
 * Check if form ready to be submit
 */
checkUploadSpectraLibForm=function() {
	if ($("#file").val()=='') {
		return false;
	}
	return true;
};

/**
 * file upload: form / action listener
 */	
$(document).on('change', '.btn-uploadAndImport :file', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('.btn-uploadAndImport :file').on('fileselect', function(event, numFiles, label) {
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

/**
 * file upload: action process
 */
var uploadRuning = false;
var uploadProgress = 0;
runProcessProgress = function() {
	// init
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
	$("#importFail").width('0%');
	if ($("#file").val()=='') {
		return;
	}
	setTimeout(function() {
		checkProcessProgress();
	}, 500);
};

/**
 * file upload: check process completion
 */
checkProcessProgress = function() {
	if (uploadProgress==0) {
		startUpload();
	}
	$.ajax({
		type: 'post',
		url: 'processProgression',
		data: 'requestID='+$("#requestID").val()+'&requestLabel=<%=ProcessProgressManager.XLSX_IMPORT_CHEMICAL_LIB_LABEL%>'
	}).done(function(data){
		if ($("#importTabResults").hasClass("uploadSpectraLibDone")) {
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

//download file with Failed imports
createSpectrumFailXlsmFile = function() {
	$("#createListFailedXlsmFile").hide();
	$("#generatingListFailedXlsmFile").show();
	$.ajax({
		type: 'post',
		url: 'spectrum-libary-xlsm-errors',
		data: 'fileSource='+$("#fileSource").val()+'&listRowFailed='+$("#listFailed").val()
	}).done(function(data){
		// console.log(data);
		// var a = $("#downloadListFailedXlsmFile");
		$("#generatingListFailedXlsmFile").hide();
		$("#downloadListFailedXlsmFile").show();
		$("#downloadListFailedXlsmFile").attr({ href : data });
		// window.open(data, '_blank');
// 		$("#downloadListFailedXlsmFile").click();
		// $(a).click();
	}).fail(function(data){
// 		alert("fail");
		// TODO message error
	}).always(function(data){
	});
};

function startUpload() {
	$("#uploadRawNMRfileDiv").hide();
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
		$("#importSuccess").width($("#newSpectraPerCent").text()+'%');
		$("#importFail").width($("#errorSpectraPerCent").text()+'%');
		//$("#iconImportResults").addClass("fa-exclamation-triangle");
		if ($('#errorSpectraPerCent').length == 0){//}($("#errorSpectraPerCent").text()=='0') {
			$("#iconImportResults").addClass("fa-check-circle");
		} else {
			$("#iconImportResults").addClass("fa-exclamation-triangle");
			//createSpectrumFailXlsmFile();
		}
		//
		if ($("#newSpectraInt").html()=="1") {
			listSpectraNMRids = listSpectraNMRids.replace("[", "").replace("]", "")
			if (listSpectraNMRids!="") {
				$("#uploadRawNMRfileDiv").show();
				$("#raw_file_spectrum_id__file").val(listSpectraNMRids);
			}
		}
		//
		startImport();
	}
};

$('body').on('hidden.bs.modal', '.modal', function () {
	  $(this).removeData('bs.modal');
});

</script>
<div style="display:none;">
	<form id="rawNmrFileUploadForm_file" action="upload-nmr-raw-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadRawNmrFileForm_file()">
	</form>
</div>
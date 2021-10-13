<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="fr.metabohub.peakforest.services.ProcessProgressManager" %>
<%@ page session="false"%>
<script src="<c:url value="/resources/js/peakforest/add-one-spectrum.min.js" />"></script>

<div class="col-lg-12  panel panel-default">
	<div class="panel-body">
		<!--      SELECT SPECTRE FILE-->
		<form id="fileUploadForm" action="upload-gcms-data-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadSpectraLibForm()">
			<div class="col-lg-12">
				<div class="input-group">
					<span class="input-group-btn">
						<span class="btn btn-primary btn-file btn-uploadAndImport"> Browse… 
							<input id="uploadSpectrumFile" name="file" type="file" accept=".zip">
						</span>
						<input type="hidden" name="ajaxUpload" value="true" />
						<input id="requestID" name="requestID" type="hidden" value="<%=ProcessProgressManager.getNewClientID() %>" />
					</span>
					<input type="text" class="form-control" readonly>
				</div>

				<div class="form-group input-group ">
					<span class="input-group-addon">InChIKey</span> 
					<input id="importspectrum-sample-inchikey" name="inchikey" type="text" class="pickChemicalCompound form-control add1spectrum add1spectrum-sampleForm is-mandatory" placeholder="e.g. RYYVLZVUVIJVGH-UHFFFAOYSA-N">
					<span class="input-group-btn">
						<button class="btn btn-default" type="button" onclick="pickChemicalCompound();">
							<i class="fa fa-search"></i>
						</button>
					</span>
				</div>

				<div class="input-group ">
					<input type="submit" value="Import">
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
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', label);
});
$(document).ready( function() {
	$('.btn-uploadAndImport :file').on('fileselect', function(event, label) {
		var input = $(this).parents('.input-group').find(':text');
		if(input.length) {
			input.val(label);
			// startUpload();
			$("#fileUploadForm").submit();
		} else {
			if(label) alert(label);
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
		data: 'requestID='+$("#requestID").val()+'&requestLabel=<%=ProcessProgressManager.GCMS_RAW_DATA_IMPORT_LABEL%>'
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

/* //download file with Failed imports
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
}; */

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
		startImport();
	}
};

$('body').on('hidden.bs.modal', '.modal', function () {
	  $(this).removeData('bs.modal');
});

</script>


<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>      
<script src="<c:url value="/resources/js/md5.min.js" />"></script>

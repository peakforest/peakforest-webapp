/**
 * Download default template file
 */
defaultFileDownload = function(subid) {
	$(".downloadTemplateSelectUploadFile"+"-"+subid).hide();
	// download
	var sampleType = $("#downloadTemplateSpectrumSampleType").val();
	//$(".downloadTemplateDownloadFile").show();
	var technology = $("#downloadTemplateSpectrumType").val();
	//var eTmp = $("div.downloadTemplateDownloadFile a");
	if (technology == 'lc-ms') {
		$("#generatingTemplate-empty").show();
		dumpEmptyFile("lcms", sampleType)
		//eTmp.attr('href', 'spectrum_LC-MS_template_v0.1.0.xlsm');
		//eTmp.html('<i class="fa fa-cloud-download"></i> spectrum_LC-MS_template_v0.1.0.xlsm');
	} else if (technology == 'lc-msms') {
		$("#generatingTemplate-empty").show();
		dumpEmptyFile("lcmsms", sampleType)
	} else if (technology == 'nmr') {
		$("#generatingTemplate-empty").show();
		dumpEmptyFile("nmr", sampleType);
		//eTmp.attr('href', 'spectrum_NMR_template_v0.1.0.xlsm');
		//eTmp.html('<i class="fa fa-cloud-download"></i> spectrum_NMR_template_v0.1.0.xlsm');
	} else if (technology == 'gc-ms') {
		$("#generatingTemplate-empty").show();
		dumpEmptyFile("gcms", sampleType);
	} 
}

function ontologies_load(filter) {
	$(".ontologies_modalTitle").hide();
	$("#ontologies_show").hide();
	$("#ontologies_loading").show();
	if (filter == "top") {
		$("#ontologies_topPeakForest").show();
		listOntologiesFromPeakForest (filter)
	} else if (filter == "all") {
		$("#ontologies_allPeakForest").show();
		listOntologiesFromPeakForest (filter)
	}
}

function listOntologiesFromPeakForest (filter) {
 	$.ajax({ 
 		type: "get",
 		url: "list-peakforest-ontologies?filter="+filter+"",
 		async: true,
 		success: function(data) {
 			$("#ontologies_tbody").empty();
 			$("#templateListOntologies").tmpl(data).appendTo("#ontologies_tbody");
 			$.each($(".ontologiesHTML"),function() {
 				$(this).html($(this).text());
 			});
 			$("#ontologies_loading").hide();
 			$("#ontologies_show").show();
 		},
 		error : function(xhr) {
 			// TODO alert error xhr.responseText
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not load ontologies.';
 			alert += ' </div>';
 			$("#backOfficeToolsAltert").html(alert);
 		}
 	});
}

/**
 * Add JS listener in template form
 */
$(document).ready(function() {
	
	// build form from JSON file
	$("#generateFromLCMSmethod").append('<option value="" selected="selected" disabled="disabled"></option>');
	$("#generateFromLCMSMSmethod").append('<option value="" selected="selected" disabled="disabled"></option>');
	$("#generateFromGCMSmethod").append('<option value="" selected="selected" disabled="disabled"></option>');
	$.getJSON("resources/json/list-lc-methods.json", function(data) {
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined)
					$("#generateFromLCMSmethod").append('<option value="'+this.value+'">'+this.name+'</option>');
				else
					$("#generateFromLCMSmethod").append('<option disabled>'+this.name+'</option>');
			}
		});
	});
	$.getJSON("resources/json/list-lc-msms-methods.json", function(data) {
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined)
					$("#generateFromLCMSMSmethod").append('<option value="'+this.value+'">'+this.name+'</option>');
				else
					$("#generateFromLCMSMSmethod").append('<option disabled>'+this.name+'</option>');
			}
		});
	});
	$.getJSON("resources/json/list-gc-methods.json", function(data) {
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined)
					$("#generateFromGCMSmethod").append('<option value="'+this.value+'">'+this.name+'</option>');
				else
					$("#generateFromGCMSmethod").append('<option disabled>'+this.name+'</option>');
			}
		});
	});
	// ADD VIA FILE
	$(".downloadTemplateForm").change(function() {
//		console.log( "Handler for .change() called #" + $(this).attr('id') );
		var idElem = $(this).attr('id');
		switch(idElem) {
		case 'downloadTemplateSpectrumSampleType':
			if ($("#downloadTemplateSpectrumSampleType").val()==SAMPLE_TYPE_ANALYTICAL_MATRIX) {
				$(".downloadTemplateSelectMatrix").show();
			} else {
				$(".downloadTemplateSelectMatrix").hide();
			}
			if ($("#downloadTemplateSpectrumType").val()=="") {
				break;
			}
			dumpEmptyTemplate();
			break;
		case 'downloadTemplateSpectrumType':
			if ($("#downloadTemplateSpectrumSampleType").val()=="") {
				break;
			}
			dumpEmptyTemplate();
			break;
		case 'downloadTemplatePresfieldY-lcms':
			$("#generateFromLCMSmethod").val("");
			$(".downloadTemplateSelectUploadFile-lcms").show();
			$(".downloadTemplateDownloadFile").hide();
			break;
		case 'downloadTemplatePresfieldY-lcmsms':
			$("#generateFromLCMSMSmethod").val("");
			$(".downloadTemplateSelectUploadFile-lcmsms").show();
			$(".downloadTemplateDownloadFile").hide();
			break;
		case 'downloadTemplatePresfieldY-gcms':
			$("#generateFromGCMSmethod").val("");
			$(".downloadTemplateSelectUploadFile-gcms").show();
			$(".downloadTemplateDownloadFile").hide();
			break;
		case 'downloadTemplatePresfieldN-lcms':
			defaultFileDownload('lcms');
			break;
		case 'downloadTemplatePresfieldN-lcmsms':
			defaultFileDownload('lcmsms');
			break;
		case 'downloadTemplatePresfieldN-gcms':
			defaultFileDownload('gcms');
			break;
		case 'downloadTemplatePresfieldY-nmr':
			$(".downloadTemplateSelectUploadFile-nmr").show();
			$(".downloadTemplateDownloadFile").hide();
			resetNMRFileUpload4Dump();
			break;
		case 'downloadTemplatePresfieldN-nmr':
			defaultFileDownload('nmr');
			break;
		case 'generateFromLCMSmethod':
			dumpLCSpectralDataFromJson($(this).val());
			break;
		case 'generateFromLCMSMSmethod':
			dumpLCSpectralDataFromJson($(this).val());
			break;
		case 'generateFromGCMSmethod':
			dumpGCSpectralDataFromJson($(this).val());
			break;
		}
	});
});

dumpEmptyTemplate = function() {
	// reset
	$(".downloadTemplateUploadFile").hide();
	$(".downloadTemplateSelectUploadFile").hide();
	$(".downloadTemplateDownloadFile").hide();
//	$(".downloadTemplateSelectMatrix").hide();
	$("#generateFromLCMSmethod").val("");
	$("#generateFromLCMSMSmethod").val("");
	$("#generateFromGCMSmethod").val("");
	// lock
	$("input[name='matrixToDump']").attr("disabled", true);
	switch($("#downloadTemplateSpectrumType").val()) {
	case "lc-ms":
		// choose to prefield
		$(".downloadTemplateUploadFile-lcms").show();
		$("#downloadTemplatePresfieldY-lcms").prop('checked', false);
		$("#downloadTemplatePresfieldN-lcms").prop('checked', true);
		defaultFileDownload('lcms');
		break;
	case "lc-msms":
		// choose to prefield
		$(".downloadTemplateUploadFile-lcmsms").show();
		$("#downloadTemplatePresfieldY-lcmsms").prop('checked', false);
		$("#downloadTemplatePresfieldN-lcmsms").prop('checked', true);
		defaultFileDownload('lcmsms');
		break;
	case "nmr":
		// choose to prefield
		$(".downloadTemplateUploadFile-nmr").show();
		$("#downloadTemplatePresfieldY-nmr").prop('checked', false);
		$("#downloadTemplatePresfieldN-nmr").prop('checked', true);
		defaultFileDownload('nmr');
		break;
	case "gc-ms":
		// choose to prefield
		$(".downloadTemplateUploadFile-gcms").show();
		$("#downloadTemplatePresfieldY-gcms").prop('checked', false);
		$("#downloadTemplatePresfieldN-gcms").prop('checked', true);
		defaultFileDownload('gcms');
		break;
	default:
		// TODO other spec here or just before 
		break;
	}
}

/**
 * Dump JSON file data into a XLSM file for LC-MS / LC-MSMS methods.
 */
dumpLCSpectralDataFromJson = function(jsonFileName) { 
	// start process progress
	$("#generatingTemplate-lcms-file").show();
	// get JSON data and dump them into XLSM file
	$.getJSON("resources/json/lc-methods/"+jsonFileName+".json", function(json) {
		// $.POST
		dumpJsonDataInXLSMfile(json);
	}).error(function(event, jqxhr, exception) {
		if (event.status == 404) {
			$(".generatingTemplate").hide();
			$(".downloadTemplateDownloadFile").show();
			cleanLinkDnlTemplate();
			$("#alertBoxDumpTemplate").html(_alert_unablePresFieldData);
		}
	});
}

/**
 * Dump JSON file data into a XLSM file for GC-MS methods.
 */
dumpGCSpectralDataFromJson = function(jsonFileName) { 
	// start process progress
	$("#generatingTemplate-gcms-file").show();
	// get JSON data and dump them into XLSM file
	$.getJSON("resources/json/gc-methods/"+jsonFileName+".json", function(json) {
		// $.POST
		dumpJsonDataInXLSMfile(json);
	}).error(function(event, jqxhr, exception) {
		if (event.status == 404) {
			$(".generatingTemplate").hide();
			$(".downloadTemplateDownloadFile").show();
			cleanLinkDnlTemplate();
			$("#alertBoxDumpTemplate").html(_alert_unablePresFieldData);
		}
	});
}

cleanLinkDnlTemplate = function() {
	var eTmp = $("div.downloadTemplateDownloadFile a");
	eTmp.attr('href', "");
	eTmp.html('');
}

/**
 * Dump JSON data data into an empty XLSM file.
 */
dumpEmptyFile = function(method, sampleType) {
	var json = {};
	if (method =="lcms")
		json["dumper_type"] = "lc-ms";
	else if (method =="lcmsms")
		json["dumper_type"] = "lc-msms";
	else if (method =="nmr")
		json["dumper_type"] = "nmr";
	else if (method =="gcms")
		json["dumper_type"] = "gc-ms";
	else
		json["dumper_type"] = method;
	if (sampleType!==null && sampleType!==undefined && sampleType!="") {
		var initSample = false;
		var sampleObject = {};
		switch (sampleType) {
		case SAMPLE_TYPE_CHEMICAL_COMPOUND_LIBRARY:
			initSample = true;
			sampleObject["sample_type"] = "reference-chemical-compound";
			break;
		case SAMPLE_TYPE_CHEMICAL_COMPOUND_MIX:
			initSample = true;
			sampleObject["sample_type"] = "mix-chemical-compound";
			break;
		case SAMPLE_TYPE_STANDARDIZED_MATRIX:
			initSample = true;
			sampleObject["sample_type"] = "standardized-matrix";
			break;
		case SAMPLE_TYPE_ANALYTICAL_MATRIX:
			initSample = true;
			sampleObject["sample_type"] = "analytical-matrix";
			sampleObject["analytical-matrix-filter"] = $("input[name='matrixToDump']:checked").val();
			break;
		default:
			break;
		}
		if (initSample)
			json["analytical_sample"] = sampleObject;
	}
	// run
	$("#generatingTemplate-empty").show();
	dumpJsonDataInXLSMfile(json);
}

/**
 * Dump JSON data data into a XLSM file.
 */
dumpJsonDataInXLSMfile = function(json) {
	// sample
	var jsonSampleD = {};
	switch($("#downloadTemplateSpectrumSampleType").val()) {
	// II.A - chemical lib. compound
	case "0":
		jsonSampleD["sample_type"] = "reference-chemical-compound"; // -from-library
		break;
		// II.B - chemical lib. compound mix
	case "1": 
		jsonSampleD["sample_type"] = "mix-chemical-compound";
		break;
		// II.C - std matrix
	case "2":
		jsonSampleD["sample_type"] = "standardized-matrix";
		break;
		// II.D - bio matrix
	case "3":
		jsonSampleD["sample_type"] = "analytical-matrix";
		jsonSampleD["analytical-matrix-filter"] = $("input[name='matrixToDump']:checked").val();
		break;
	case "4":
		// II.E - chemical lib. compound for GC
		jsonSampleD["sample_type"] = "reference-chemical-compound-for-GC";
		break;
	default:
		return false;
	}
	json["analytical_sample"] = jsonSampleD;
	$("#alertBoxDumpTemplate").html("");
	$(".downloadTemplateDownloadFile").hide();
	$("select.downloadTemplateForm").attr("disabled", true);
	$("#generateFromLCMSmethod").attr("disabled", false);
	$("#generateFromLCMSMSmethod").attr("disabled", false);
	$("#generateFromGCMSmethod").attr("disabled", false);
	$.ajax({
		type: "post",
		url: "dumpTemplate",
		data:  JSON.stringify(json), // json,
		contentType: 'application/json',
		success: function(data) {
			if(data.success) { 
				//$(".downloadTemplateSelectUploadFile").hide();
				$(".generatingTemplate").hide();
				$(".downloadTemplateDownloadFile").show();
				var eTmp = $("div.downloadTemplateDownloadFile a");
				eTmp.attr('href', data.fileURL);
				eTmp.html('<i class="fa fa-cloud-download"></i> ' + data.fileName);
				// TODO reset form
//				console.log(data);
			} else {
				$(".generatingTemplate").hide();
				$(".downloadTemplateDownloadFile").show();
				cleanLinkDnlTemplate();
				$("#alertBoxDumpTemplate").html(_alert_unablePresFieldData);
//				console.log(data);					
			}
		}, 
		error : function(data) {
			$(".generatingTemplate").hide();
			$(".downloadTemplateDownloadFile").show();
			cleanLinkDnlTemplate();
			$("#alertBoxDumpTemplate").html(_alert_unablePresFieldData);
//			console.log(data);
		}
	}).always(function() {
		$(".generatingTemplate").hide();
	});
}

///////////////////////////////////////////////////////////
// NMR - init json object
var jsonNMRdata = {};
jsonNMRdata["dumper_type"] = "nmr";

/**
 * Reset NMR file upload form
 */
resetNMRFileUpload4Dump = function() {
	// form
	$("#uploadMetadataFileNMR_display").val("");
	$("#uploadSpectrumFileNMR_display").val("");
	//
	// data
	jsonNMRdata = {};
	jsonNMRdata["dumper_type"] = "nmr";
}


/**
 * Dump NMR file action
 */
dumpNMRTemplateFromUploadedFiles = function() {
	$("#generatingTemplate-empty").show()
	$(".downloadTemplateSelectUploadFile-nmr").hide();
	dumpJsonDataInXLSMfile(jsonNMRdata);
}

/**
 * Reset ALL dumper forms
 */
resetAllDumperForms = function() {
	// rest first button
	$("#downloadTemplateSpectrumSampleType").val('');
	$("#downloadTemplateSpectrumType").val('');
	// reset div
	$(".downloadTemplateUploadFile").hide();
	$(".downloadTemplateSelectUploadFile").hide();
	$(".downloadTemplateDownloadFile").hide();
	$(".generatingTemplate").hide();
	// reset matrix source / type
	$(".downloadTemplateSelectMatrix").hide();
	$("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_source").val("");
	$("#select2-downloadTemplateSpectrumSampleTypeAnalyticalMatrix_source-container").html("").attr("title","");
	$("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_type").val("");
	$("#select2-downloadTemplateSpectrumSampleTypeAnalyticalMatrix_type-container").html("").attr("title","");
	// set to enabled
	$("select.downloadTemplateForm").attr("disabled", false);
	//
	$("input[name='matrixToDump']").attr("disabled", false).attr("selected", false);
	$("#dumpTopMatrix").attr("selected", true);
	// reset data
	resetNMRFileUpload4Dump();
	// reset link
	cleanLinkDnlTemplate();
	// reset alert box
	$("#alertBoxDumpTemplate").html("");
}
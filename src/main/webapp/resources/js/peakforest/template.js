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
	}
}

/**
 * Add JS listener in template form
 */
$(document).ready(function() {
	//  use select2 for ontologies data
	$("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_source").select2({
		ajax: {
			url: "ontologies-sources",
			dataType: 'json',
			delay: 250,
			data: function (params) {
				return {
					q: params.term, // search term
					page: params.page
				};
			},
			processResults: function (data, params) {
				return {
					results: data//,
//					pagination: {
//						more: (params.page * 30) < data.total_count
//					}
				};
			},
			cache: true
		},
		escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
		minimumInputLength: 3//,
//		templateResult: formatOntologies, // omitted for brevity, see the source of this page
//		templateSelection: formatOntologiesSelection // omitted for brevity, see the source of this page
	});
	$.ajax({
		type: "GET",
		dataType: "text/tsv",
		async: false,
		url: "resources/ontologies/brenda_tissus_obo.tsv",//
		complete: function (result) { 
			var data3 =[];
			$.each(result.responseText.split('\n'),function(k,v){
				var obj = {};
				var tmp = v.split("\t");
				obj.id = tmp[0]; obj.text = tmp[1];
				data3.push(obj);
			});
			$("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_type").select2({
				data: data3
			});
		}
	});
	$("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_type").select2({
		ajax: {
			url: "ontologies-types",
			dataType: 'json',
			delay: 250,
			data: function (params) {
				return {
					q: params.term, // search term
					page: params.page
				};
			},
			processResults: function (data, params) {
				return {
					results: data//,
//					pagination: {
//						more: (params.page * 30) < data.total_count
//					}
				};
			},
			cache: true
		},
		escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
		minimumInputLength: 3//,
//		templateResult: formatOntologies, // omitted for brevity, see the source of this page
//		templateSelection: formatOntologiesSelection // omitted for brevity, see the source of this page
	});
	
	
	// build form from JSON file
	$("#generateFromLCMSmethod").append('<option value="" selected="selected" disabled="disabled"></option>');
	$("#generateFromLCMSMSmethod").append('<option value="" selected="selected" disabled="disabled"></option>');
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
		case 'downloadTemplatePresfieldN-lcms':
			defaultFileDownload('lcms');
			break;
		case 'downloadTemplatePresfieldN-lcmsms':
			defaultFileDownload('lcmsms');
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
			sampleObject["analytical-matrix-source"] = Number($("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_source").val());
			sampleObject["analytical-matrix-type"] = Number($("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_type").val());
			break;
		default:
			break;
		}
		if (initSample)
			json["analytical_sample"] = sampleObject;
	}
	// run
	$("#generatingTemplate-emtpy").show();
	dumpJsonDataInXLSMfile(json)
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
		jsonSampleD["analytical-matrix-source"] = Number($("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_source").val());
		jsonSampleD["analytical-matrix-type"] = Number($("#downloadTemplateSpectrumSampleTypeAnalyticalMatrix_type").val());
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
	// reset data
	resetNMRFileUpload4Dump();
	// reset link
	cleanLinkDnlTemplate();
	// reset alert box
	$("#alertBoxDumpTemplate").html("");
}
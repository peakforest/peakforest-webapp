///////////////////////////////////////////////////////////////////////////////
// STD MATRIX TAB
///////////////////////////////////////////////////////////////////////////////
$(document).ready( function() {
	$("#add1spectrum-sample-stdMatrix").change(function() {
		var e = $("#add1spectrum-sample-stdMatrix").parent().children("span").children("a");
		if (this.value == "NIST plasma") {
			$(e).attr("href", "http://srm1950.nist.gov/");
			$(e).show();
		} else {
			$(e).hide();
		}
	});
});
///////////////////////////////////////////////////////////////////////////////
// FILE UPLOAD (NMR RAW SPECTRA)
///////////////////////////////////////////////////////////////////////////////
/**
 * 
 * @returns
 */
function checkUploadRawNmrFileForm () {
	if ($("#rawNmrFile").val()=='') {
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
			$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadForm");
			$("#rawNmrFileUploadForm").submit();
		} else {
			if(log) alert(log);
		}
	});
	$("#rawNmrFileUploadForm").ajaxForm({
		beforeSubmit: startUploadRawNmrFile,
		success: function(data) {
			var tabData = {};
			$.each(data.trim().split("\n"),function(k, v) {
				var tData = (v).split("=");
				tabData[tData[0]] = tData[1];
			}); 
			if (tabData["success"] == "true") {
				if ((tabData["reload"] == "true")) { 
					// no reload!
					stringInfo = "Raw spectrum dataum uploaded!";
					var infoBox = '<br><br><div class="alert alert-success alert-dismissible" role="alert">';
					infoBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					infoBox += '<strong>Informations</strong> ' + stringInfo;
					infoBox += ' </div>';
					$("#rawNmrFileUploadError").html(infoBox);
					// TODO add form field
					$("#rawFileTmpName").val(tabData['new_raw_file_name']);
				}
				else {
					if (tabData["procFiles"]) {
						stringInfo = "select proc. file: <ul>";
						var files = tabData["procFiles"].split(",");
						$.each(files, function(k,v) {
							if (v!="")
								stringInfo += '<li><a onclick="submitRawNmrFile_addProcFile(\''+v+'\')">'+v+"</a></li>";
						});
					} else if (tabData["files"]) {
						stringInfo = "select aq. file: <ul>";
						var files = tabData["files"].split(",");
						$.each(files, function(k,v) {
							if (v!="")
								stringInfo += '<li><a onclick="submitRawNmrFile_addAqFile(\''+v+'\')">'+v+"</a></li>";
						});
					}
					stringInfo += "</ul>";
					var infoBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
					infoBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					infoBox += '<strong>Need more details</strong> ' + stringInfo;
					infoBox += ' </div>';
					$("#rawNmrFileUploadError").html(infoBox);
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
				$("#rawNmrFileUploadError").html(errorBox);
			}
			$("#rawNmrFileUploading").hide();
			$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadContainer");
		},
		error: function() {
			// alert message
			var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
				errorBox += ' </div>';
				$("#rawNmrFileUploadError").html(errorBox);
			$("#rawNmrFileUploading").hide();
			$("#rawNmrFormContent").appendTo("#rawNmrFileUploadContainer");
		}
	});
});
/**
 * 
 * @returns
 */
function startUploadRawNmrFile() {
	$("#rawNmrFileUploadError").html("");
	$("#rawNmrFileUploading").show();
	//
}
/**
 * 
 * @param file
 * @returns
 */
function submitRawNmrFile_addAqFile(file) {
	$("#rawNmrFileUploadForm").append('<input type="hidden" name="aq_file" value="'+file+'">');
	$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadForm");
	$("#rawNmrFileUploadForm").submit();
}
/**
 * 
 * @param file
 * @returns
 */
function submitRawNmrFile_addProcFile(file) {
	$("#rawNmrFileUploadForm").append('<input type="hidden" name="proc_file" value="'+file+'">');
	$("#addRawNmrFileFormContent").appendTo("#rawNmrFileUploadForm");
	$("#rawNmrFileUploadForm").submit();
}
///////////////////////////////////////////////////////////////////////////////
// SPECTRA PREVIEW
///////////////////////////////////////////////////////////////////////////////
modeEditSpectrum13C = false;
/**
 * 
 * @returns
 */
function updateNMRspectraViewer13c () {
	// reset current viewer
	$("#containter-nmr-spectrum-preview-13c").empty();
	// reset data.
	spectrumMinPPM = 10;
	spectrumMaxPPM = -100000;
	maxGraph = 0;
	var localData = [];
	var localDataAnnot = [];
	// gather new data
	// TODO switch tab in function of technic
	$.each(hot_NMR_C_Peaks.getData(),function(){
		if(this["peak index"]!= undefined && this["peak index"]!=="") {
			var x = -(Number(this["ν (F1) [ppm]"]));
			var y = Number(this['intensity [rel]']);
			var a = this["annotation"];
			localData.push([(x-0.000001),-150]);
			localData.push([(x+0.000001),-150]);
			localData.push([x,y]);
			localDataAnnot[x] = a;
			if (x < spectrumMinPPM)
				spectrumMinPPM = x;
			if (x > spectrumMaxPPM)
				spectrumMaxPPM = x;
			if (y > maxGraph)
				maxGraph = y;
		}
	});
	
	// build new one
	spectrumMinPPM = spectrumMinPPM + (0.1 * spectrumMinPPM);
	spectrumMaxPPM = spectrumMaxPPM - (0.1 * spectrumMaxPPM);
	maxGraph = maxGraph + (0.1 * maxGraph);
	localData.sort();
	localData.reverse();
	// build graph
	$("#containter-nmr-spectrum-preview-13c").highcharts({
		chart : {
			zoomType : 'x',
			spacingRight : 10,
			spacingLeft : 10,
			type: 'scatter'
		},
		title : {
			text : "Spectrum Preview",
			useHTML: true
		},
		subtitle : {
			text : document.ontouchstart === undefined ? 'Select area' : 'Pinch the chart to zoom in'
		},
		xAxis : {
			type : 'number',
			//maxZoom : 2, // in %
			title : {
				text : 'Chemical Shift (ppm)'
			},
			min : spectrumMinPPM,
			max : spectrumMaxPPM,
			labels: {
			    formatter: function () {
					return (Math.abs(this.value) + '');
				    }
				}
		},
		yAxis : {
			title : {
				text : 'Relative Intensity (%)'
			},
			min : 0,
			max : maxGraph
		},
		tooltip : {
			crosshairs : true,
			formatter : function() {
				var compo = '';
				return '<b>' + this.series.name
				+ '</b><br/>chemical shift:' + Math.abs(this.x) + ' ppm'
				+ ';<br/>Relative Intensity: ' + this.y
				+ '%;<br/>Annotation: ' + localDataAnnot[ this.x]
				+ '';
			}
		},
		legend : {
			enabled: false
		},
		plotOptions : {
			scatter : {}
		},
		series : [
			{
				name : "preview", showInLegend : true, 
				// point : { events : { click : function() { selectPointNMR"+spectrumDivId+"("+ (i)+ ", this.x, this.y, this.series.name, "+i+ } } },
				color : "#f00", lineColor : "#f00", 
				pointInterval : 10, pointStart : 100, lineWidth : 2, 
				marker : { enabled : true, radius : 2, lineColor : "#f00" }, 
				data : localData,
				zIndex : 10
			}
		]
	});
}
modeEditSpectrum = false;
/**
 * 
 * @returns
 */
function updateNMRspectraViewer () {
	// reset current viewer
	$("#containter-nmr-spectrum-preview").empty();
	// reset data.
	spectrumMinPPM = 10;
	spectrumMaxPPM = -100000;
	maxGraph = 0;
	var localData = [];
	var localDataAnnot = [];
	// gather new data
	// TODO switch tab in function of technic
	$.each(hot_NMR_H_Peaks.getData(),function(){
		if(this["peak index"]!= undefined && this["peak index"]!=="") {
			var x = -(Number(this["ν (F1) [ppm]"]));
			var y = Number(this['intensity [rel]']);
			var a = this["annotation"];
			localData.push([(x-0.000001),-150]);
			localData.push([(x+0.000001),-150]);
			localData.push([x,y]);
			localDataAnnot[x] = a;
			if (x < spectrumMinPPM)
				spectrumMinPPM = x;
			if (x > spectrumMaxPPM)
				spectrumMaxPPM = x;
			if (y > maxGraph)
				maxGraph = y;
		}
	});
	
	// build new one
	spectrumMinPPM = spectrumMinPPM + (0.1 * spectrumMinPPM);
	spectrumMaxPPM = spectrumMaxPPM - (0.1 * spectrumMaxPPM);
	maxGraph = maxGraph + (0.1 * maxGraph);
	localData.sort();
	localData.reverse();
	// build graph
	$("#containter-nmr-spectrum-preview").highcharts({
		chart : {
			zoomType : 'x',
			spacingRight : 10,
			spacingLeft : 10,
			type: 'scatter'
		},
		title : {
			text : "Spectrum Preview",
			useHTML: true
		},
		subtitle : {
			text : document.ontouchstart === undefined ? 'Select area' : 'Pinch the chart to zoom in'
		},
		xAxis : {
			type : 'number',
			//maxZoom : 2, // in %
			title : {
				text : 'Chemical Shift (ppm)'
			},
			min : spectrumMinPPM,
			max : spectrumMaxPPM,
			labels: {
			    formatter: function () {
					return (Math.abs(this.value) + '');
				    }
				}
		},
		yAxis : {
			title : {
				text : 'Relative Intensity (%)'
			},
			min : 0,
			max : maxGraph
		},
		tooltip : {
			crosshairs : true,
			formatter : function() {
				var compo = '';
				return '<b>' + this.series.name
				+ '</b><br/>chemical shift:' + Math.abs(this.x) + ' ppm'
				+ ';<br/>Relative Intensity: ' + this.y
				+ '%;<br/>Annotation: ' + localDataAnnot[ this.x]
				+ '';
			}
		},
		legend : {
			enabled: false
		},
		plotOptions : {
			scatter : {}
		},
		series : [
			{
				name : "preview", showInLegend : true, 
				// point : { events : { click : function() { selectPointNMR"+spectrumDivId+"("+ (i)+ ", this.x, this.y, this.series.name, "+i+ } } },
				color : "#f00", lineColor : "#f00", 
				pointInterval : 10, pointStart : 100, lineWidth : 2, 
				marker : { enabled : true, radius : 2, lineColor : "#f00" }, 
				data : localData,
				zIndex : 10
			}
		]
	});
} // updateNMRspectraViewer
function updateLCMSspectraViewer () {
	// reset current viewer
	$("#containter-lcms-spectrum-preview").empty();
	// reset data.
	spectrumMinPPM = 10000;
	if (Number( $('#add1spectrum-peaksMS-rangeFrom').val())!='');
		spectrumMinPPM = Number( $('#add1spectrum-peaksMS-rangeFrom').val());
	spectrumMaxPPM = 0;
	if (Number($('#add1spectrum-peaksMS-rangeTo').val())!='');
		spectrumMaxPPM = Number($('#add1spectrum-peaksMS-rangeTo').val());
	maxGraph = 0;
	var localData = [];
	var localDataAnnot = [];
	// gather new data
	// TODO switch tab in function of technic
	$.each(hot_MS_Peaks.getData(),function(){
		if(this[0]!= undefined && this[0]!="") {
			var x = (Number(this[0]));
			var y = Number(this[2]);
			var a = this[6];
			localData.push([(x-0.000001),-150]);
			localData.push([(x+0.000001),-150]);
			localData.push([x,y]);
			localDataAnnot[x] = a;
			if (x < spectrumMinPPM)
				spectrumMinPPM = x;
			if (x > spectrumMaxPPM)
				spectrumMaxPPM = x;
			if (y > maxGraph)
				maxGraph = y;
		}
	});
	
	// build new one
	spectrumMinPPM = spectrumMinPPM - (0.1 * spectrumMinPPM);
	spectrumMaxPPM = spectrumMaxPPM + (0.1 * spectrumMaxPPM);
	maxGraph = maxGraph + (0.1 * maxGraph);
	localData.sort();
	// build graph
	$("#containter-lcms-spectrum-preview").highcharts( {
		chart : {
			zoomType : 'x',
			spacingRight : 10,
			spacingLeft : 10,
			type: 'scatter'
		},
		title : {
			text : "Spectrum Preview",
			useHTML: true
		},
		subtitle : {
			text : document.ontouchstart === undefined ? 'Select area' : 'Pinch the chart to zoom in'
		},
		xAxis : {
			type : 'number',
			//maxZoom : 2, // in %
			title : {
				text : 'm/z'
			},
			min : spectrumMinPPM,
			max : spectrumMaxPPM,
			labels: {
			    formatter: function () {
					return (Math.abs(this.value) + '');
				    }
				}
		},
		yAxis : {
			title : {
				text : 'Relative Intensity (%)'
			},
			min : 0,
			max : maxGraph
		},
		tooltip : {
			crosshairs : true,
			formatter : function() {
					var compo = '';
				return '<b>' + this.series.name
					+ '</b><br/>m/z:' + Math.abs(this.x) + ''
					+ ';<br/>Relative Intensity: ' + this.y
					+ '%;<br/>Annotation: ' + localDataAnnot[ this.x]
					+ '';
			}
		},
		legend : {
			enabled: false
		},
		plotOptions : {
			scatter : {}
		},
		series : [
			{
				name : "preview", showInLegend : true, 
				// point : { events : { click : function() { selectPointNMR"+spectrumDivId+"("+ (i)+ ", this.x, this.y, this.series.name, "+i+ } } },
				color : "#f00", lineColor : "#f00", 
				pointInterval : 10, pointStart : 100, lineWidth : 2, 
				marker : { enabled : true, radius : 2, lineColor : "#f00" }, 
				data : localData,
				zIndex : 10
			}
		]
	});
} // updateNMRspectraViewer
///////////////////////////////////////////////////////////////////////////////
// ONLOAD
///////////////////////////////////////////////////////////////////////////////
setTimeout(function() {
	$("#add1spectrum-other-date").focusout(function() {
		if($(this).parent().hasClass("has-warning"))
			$(this).parent().removeClass("has-warning");
		if($(this).parent().hasClass("has-success"))
			$(this).parent().removeClass("has-success");
		if ($(this).val()=="")
			$(this).parent().addClass("has-warning");
		else
			$(this).parent().addClass("has-success");
	});
}, 500);
var isSeparationFlowRateInit = false;
var isMSpeaksInit = false;
$(document).ready(function() {
	// init form fields
	// LC methods
	$("#add1spectrum-chromatoLC-method").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-lc-methods.json", function(data) {
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined)
					$("#add1spectrum-chromatoLC-method").append('<option value="'+this.value+'">'+this.name+'</option>');
				else
					$("#add1spectrum-chromatoLC-method").append('<option disabled>'+this.name+'</option>');
			}
		});
	});
	
	// LC columns
	$("#add1spectrum-chromatoLC-colConstructor").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-lc-columns.json", function(data) {
		// load data from json
		$.each(data.columns,function(){
			$("#add1spectrum-chromatoLC-colConstructor").append('<option value="'+this.value+'">'+this.name+'</option>');
		});
		$("#add1spectrum-chromatoLC-colConstructor").append('<option value="other" >Other</option>');
	});
		
	// LC solvents
	$("#add1spectrum-chromatoLC-separationSolvA").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#add1spectrum-chromatoLC-separationSolvB").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-lc-solvents.json", function(data) {
		// load data from json
		$.each(data.solvents,function(){
			$("#add1spectrum-chromatoLC-separationSolvA").append('<option value="'+this.value+'">'+this.name+'</option>');
			$("#add1spectrum-chromatoLC-separationSolvB").append('<option value="'+this.value+'">'+this.name+'</option>');
		});
	});
		
	// MS ionization method
	//$("#add1spectrum-analyzserMS-ionizationMethod-pos").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	//$("#add1spectrum-analyzserMS-ionizationMethod-neg").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-ms-ionization-methods.json", function(data) {
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined) {
					$("#add1spectrum-analyzserMS-ionizationMethod-pos").append('<option value="'+this.value+'">'+this.name+'</option>');
					$("#add1spectrum-analyzserMS-ionizationMethod-neg").append('<option value="'+this.value+'">'+this.name+'</option>');
				} else {
					$("#add1spectrum-analyzserMS-ionizationMethod-pos").append('<option disabled>'+this.name+'</option>');
					$("#add1spectrum-analyzserMS-ionizationMethod-neg").append('<option disabled>'+this.name+'</option>');
				}
			}
		});
	});
	
	// MS solents
	$("#add1spectrum-sample-lcmsSolvent").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-lcms-solvents.json", function(data) {
		// load data from json
		$.each(data.solvents,function(){
			$("#add1spectrum-sample-lcmsSolvent").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
	});
		
	// NMR solents
	$("#add1spectrum-sample-nmrSolvent").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-nmr-solvents.json", function(data) {
		// load data from json
		$.each(data.solvents,function(){
			$("#add1spectrum-sample-nmrSolvent").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
	});
	
	// NMR reference chemical shif indicator
	$("#add1spectrum-sample-nmrReferenceChemicalShifIndicatort").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-nmr-referenceChemShiftIndicators.json", function(data) {
		// load data from json
		$.each(data.referenceChemShiftIndicator,function(){
			$("#add1spectrum-sample-nmrReferenceChemicalShifIndicatort").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
	});
	
	// NMR Lock Substance
	$("#add1spectrum-sample-nmrLockSubstance").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-nmr-lockSubstances.json", function(data) {
		// load data from json
		$.each(data.lockSubstance,function(){
			$("#add1spectrum-sample-nmrLockSubstance").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
	});
	
	// NMR Buffer Solution
	$("#add1spectrum-sample-nmrBufferSolution").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-nmr-bufferSolutions.json", function(data) {
		// load data from json
		$.each(data.bufferSolution,function(){
			$("#add1spectrum-sample-nmrBufferSolution").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
	});
	
	// NMR instrument
	$("#add1spectrum-analyzer-nmr-instrument-name").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#add1spectrum-analyzer-nmr-instrument-magneticFieldStrength").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#add1spectrum-analyzer-nmr-instrument-software").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#add1spectrum-analyzer-nmr-instrument-probe").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#add1spectrum-analyzer-nmr-instrument-tube").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-nmr-instrumentOptions.json", function(data) {
		// load data from json
		$.each(data.model,function(){
			$("#add1spectrum-analyzer-nmr-instrument-name").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.magnetic_field_strength,function(){
			$("#add1spectrum-analyzer-nmr-instrument-magneticFieldStrength").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.software,function(){
			$("#add1spectrum-analyzer-nmr-instrument-software").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.probe,function(){
			$("#add1spectrum-analyzer-nmr-instrument-probe").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.tubes,function(){
			$("#add1spectrum-analyzer-nmr-instrument-tube").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
	});
	
	////
	resetFromColors();
	$(".add1spectrum").change(function() {
		console.log( "Handler for .change() called #" + $(this).attr('id') );
		var idElem = $(this).attr('id');
		var valElem = $(this).val();
		// display
		var isSuccess = $(this).parent().hasClass("has-success");
		var isWarning = $(this).parent().hasClass("has-warning");
		var isError = $(this).parent().hasClass("has-error");
		// mandatory / optional
		var isOptional = $(this).hasClass("is-optional");
		var isMandatory = $(this).hasClass("is-mandatory");
		// id/val
		switch(idElem) {
		case 'add1spectrum-sample-type':
			$("#add1spectrum-sample-type-compound-ref").hide();
			$("#add1spectrum-sample-type-compound-mix").hide();
			$("#add1spectrum-sample-type-matrix-ref").hide();
			$("#add1spectrum-sample-type-matrix-bio").hide();
			$("#add1spectrum-sample-type-rcc-added").hide();
			if (valElem == "compound-ref") {
				$("#add1spectrum-sample-type-compound-ref").show();
			} else if (valElem == "compound-mix") {
				$("#add1spectrum-sample-type-compound-mix").show();
				$("#add1spectrum-sample-type-rcc-added").show();
				handsontableRefChemCpdAdded(null);
			} else if (valElem == "matrix-ref") {
				$("#add1spectrum-sample-type-matrix-ref").show();
				$("#add1spectrum-sample-type-rcc-added").show();
				handsontableRefChemCpdAdded(null);
			} else if (valElem == "matrix-bio") {
				$("#add1spectrum-sample-type-matrix-bio").show();
			}
			break;
		case 'add1spectrum-sample-nmrSolvent':
			resetElemColor("add1spectrum-sample-nmrpH");
			var hasDisplayPHOpt = $("#add1spectrum-sample-nmrSolvent option:selected").hasClass("displayPHOpt");
			if (valElem == "" || valElem == null || !hasDisplayPHOpt ) { 
				disableElem("add1spectrum-sample-nmrpH");
			} else if ($("#add1spectrum-sample-nmrpH").val() == "") {
				enableElem("add1spectrum-sample-nmrpH");
			} else if ($("#add1spectrum-sample-nmrpH").val() != "" ) {
				enableElem("add1spectrum-sample-nmrpH");
			}
			break;
		case 'add1spectrum-sample-nmrReferenceChemicalShifIndicatort':
			resetElemColor("add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther");
			var hasDisplayOtherOpt = $("#add1spectrum-sample-nmrReferenceChemicalShifIndicatort option:selected").hasClass("displayOtherOpt");
			if (valElem == "" || valElem == null || !hasDisplayOtherOpt ) {
				disableElem("add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther");
			} else if ($("#add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther").val() == "") {
				enableElem("add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther");
			} else if ($("#add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther").val() != "" ) {
				enableElem("add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther");
			}
			break;
		case 'add1spectrum-chromatoLC-colConstructor':
			resetElemColor("add1spectrum-chromatoLC-colConstructorOther");
			if (valElem == "" || valElem == null || valElem != "other" ) {
				disableElem("add1spectrum-chromatoLC-colConstructorOther");
			} else if ($("#add1spectrum-chromatoLC-colConstructorOther").val() == "") {
				enableElem("add1spectrum-chromatoLC-colConstructorOther");
			} else if ($("#add1spectrum-chromatoLC-colConstructorOther").val() != "" ) {
				enableElem("add1spectrum-chromatoLC-colConstructorOther");
			}
			break;
		case 'add1spectrum-analyzer-nmr-instrument-cellOrTube':
			resetElemColor("add1spectrum-analyzer-nmr-instrument-tube");
			resetElemColor("add1spectrum-analyzer-nmr-instrument-flowCellVolume");
			if (valElem == "" || valElem == null ) {
				disableElem("add1spectrum-analyzer-nmr-instrument-tube");
				disableElem("add1spectrum-analyzer-nmr-instrument-flowCellVolume");
			} else if (valElem == "cell") {
				disableElem("add1spectrum-analyzer-nmr-instrument-tube");
				enableElem("add1spectrum-analyzer-nmr-instrument-flowCellVolume");
			} else if (valElem == "tube") {
				disableElem("add1spectrum-analyzer-nmr-instrument-flowCellVolume");
				enableElem("add1spectrum-analyzer-nmr-instrument-tube");
			}
			break;
		case 'add1spectrum-analyzserNMR-programm':
			hideShowProgrammeOption();
			break;
		case 'add1spectrum-chromatoLC-method':
			fulfillLCdata(valElem);
			break;
		case 'add1spectrum-analyzserMS-ionizationMethod-pos':
			if ($("#add1spectrum-analyzserMS-ionizationMethod-pos").val()!=null)
				$($("#add1spectrum-peaksMS-polarity option")[1]).attr("disabled", false);
			break;
		case 'add1spectrum-analyzserMS-ionizationMethod-neg':
			if ($("#add1spectrum-analyzserMS-ionizationMethod-neg").val()!=null)
				$($("#add1spectrum-peaksMS-polarity option")[2]).attr("disabled", false);
			break;				
		}
		// 
		if (isMandatory && (valElem=="" || valElem==null)) {
			if (isSuccess) 
				$(this).parent().removeClass("has-success");
			else if (isWarning) 
				$(this).parent().removeClass("has-warning");
			else if (isError) 
				$(this).parent().removeClass("has-error");
			$(this).parent().addClass("has-error");
		}
		else if (isOptional && (valElem=="" || valElem==null)) {
			if (isSuccess) 
				$(this).parent().removeClass("has-success");
			else if (isWarning) 
				$(this).parent().removeClass("has-warning");
			else if (isError) 
				$(this).parent().removeClass("has-error");
			$(this).parent().addClass("has-warning");
		}
		if (isMandatory && (valElem!="" && valElem!=null)) {
			if (isError)
				$(this).parent().removeClass("has-error");
			$(this).parent().addClass("has-success");
		} else if (isOptional && valElem!="") {
			if (isWarning)
				$(this).parent().removeClass("has-warning");
			$(this).parent().addClass("has-success");
		}
		if ($(this).parent().children("input").size() == 2) {
			isSuccess = $(this).parent().hasClass("has-success");
			isWarning = $(this).parent().hasClass("has-warning");
			isError = $(this).parent().hasClass("has-error");
			if (isMandatory) {
				if (isSuccess) 
					$(this).parent().removeClass("has-success");
				else if (isWarning) 
					$(this).parent().removeClass("has-warning");
				else if (isError) 
					$(this).parent().removeClass("has-error");
				var isTmpSuccess = true;
				$.each($(this).parent().children("input"), function(id, child){
					if ($(child).val()==null||$(child).val()=="")
						isTmpSuccess=false;
				});
				if (isTmpSuccess)
					$(this).parent().addClass("has-success");
				else
					$(this).parent().addClass("has-error");
			}
			else if (isOptional) {
				isSuccess = $(this).parent().hasClass("has-success");
				isWarning = $(this).parent().hasClass("has-warning");
				isError = $(this).parent().hasClass("has-error");
				if (isSuccess) 
					$(this).parent().removeClass("has-success");
				else if (isWarning) 
					$(this).parent().removeClass("has-warning");
				else if (isError) 
					$(this).parent().removeClass("has-error");
				var isTmpSuccess = true;
				$.each($(this).parent().children("input"), function(id, child){
					if ($(child).val()==null||$(child).val()=="")
						isTmpSuccess=false;
				});
				if (isTmpSuccess)
					$(this).parent().addClass("has-success");
				else
					$(this).parent().addClass("has-warning");
			}
		}
		if ($(this).hasClass("one-or-more")) {
			// get parent class
			isSuccess = $(this).parent().hasClass("has-success");
			isWarning = $(this).parent().hasClass("has-warning");
			isError = $(this).parent().hasClass("has-error");
			// reset class
			if (isSuccess) 
				$(this).parent().removeClass("has-success");
			else if (isWarning) 
				$(this).parent().removeClass("has-warning");
			else if (isError) 
				$(this).parent().removeClass("has-error");
			// parkour
			isTmpSuccess=false;
			// each child (INPUT)
			$.each($(this).parent().children("input"), function(id, child){
				if ($(child).val()!=null && $(child).val()!="")
					isTmpSuccess=true;
			});
			// each child (SELECT)
			$.each($(this).parent().children("select"), function(id, child){
				if ($(child).val()!=null && $(child).val()!="")
					isTmpSuccess=true;
			});
			// end parkour
			if (isTmpSuccess)
				$(this).parent().addClass("has-success");
			else
				$(this).parent().addClass("has-error");
		}
		
		// CHECK IF OK STEP 2
		if ($(this).hasClass("add1spectrum-sampleForm")) {
			var isBtnStep2OK = true;
			$.each($(".add1spectrum-sampleForm"), function(id, elem){
				if ($(elem).parent().hasClass("has-error") && $(elem).is(":visible") )
					isBtnStep2OK = false;
			});
			if (isBtnStep2OK) {
				if ($("#btnSwitch-gotoStep2").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep2").removeClass("btn-disabled");
				if (!$("#btnSwitch-gotoStep2").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep2").addClass("btn-primary");
				$("#btnSwitch-gotoStep2").prop("disabled", false);
			} else {
				if (!$("#btnSwitch-gotoStep2").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep2").addClass("btn-disabled");
				if ($("#btnSwitch-gotoStep2").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep2").removeClass("btn-primary");
				$("#btnSwitch-gotoStep2").prop("disabled", true);
			}
		}
		// CHECK IF OK STEP 3 - NMR
		if ($(this).hasClass("add1spectrum-analyzerNMRForm") && $("#btnSwitch-gotoStep4-nmr").is(":visible")) {
			var isBtnStep3OK = true;
			$.each($(".add1spectrum-analyzerNMRForm"), function(id, elem){
				if ($(elem).parent().hasClass("has-error") && $(elem).is(":visible") )
					isBtnStep3OK = false;
			});
			if (isBtnStep3OK) {
				if ($("#btnSwitch-gotoStep4-nmr").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep4-nmr").removeClass("btn-disabled");
				if (!$("#btnSwitch-gotoStep4-nmr").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep4-nmr").addClass("btn-primary");
				$("#btnSwitch-gotoStep4-nmr").prop("disabled", false);
				$("#btnSwitch-gotoStep5-nmr").prop("disabled", false);
			} else {
				if (!$("#btnSwitch-gotoStep4-nmr").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep4-nmr").addClass("btn-disabled");
				if ($("#btnSwitch-gotoStep4-nmr").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep4-nmr").removeClass("btn-primary");
				$("#btnSwitch-gotoStep4-nmr").prop("disabled", true);
				$("#btnSwitch-gotoStep5-nmr").prop("disabled", true);
			}
		}
		// CHECK IF OK STEP 3 - LC
		if ($(this).hasClass("add1spectrum-chromatoLCForm") && $("#btnSwitch-gotoStep3-lc").is(":visible")) {
			var isBtnStep3OK = true;
			$.each($(".add1spectrum-chromatoLCForm"), function(id, elem){
				if ($(elem).parent().hasClass("has-error") && $(elem).is(":visible") )
					isBtnStep3OK = false;
			});
			if (isBtnStep3OK) {
				if ($("#btnSwitch-gotoStep3-lc").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep3-lc").removeClass("btn-disabled");
				if (!$("#btnSwitch-gotoStep3-lc").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep3-lc").addClass("btn-primary");
				$("#btnSwitch-gotoStep3-lc").prop("disabled", false);
			} else {
				if (!$("#btnSwitch-gotoStep3-lc").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep3-lc").addClass("btn-disabled");
				if ($("#btnSwitch-gotoStep3-lc").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep3-lc").removeClass("btn-primary");
				$("#btnSwitch-gotoStep3-lc").prop("disabled", true);
			}
		}
		// TODO CHECK IF OK STEP 3 - GC
		// CHECK IF OK STEP 4 - MS ANALYZER
		if ($(this).hasClass("add1spectrum-analyzerMSForm") && $("#btnSwitch-gotoStep4-ms").is(":visible")) {
			var isBtnStep4OK = true;
			$.each($(".add1spectrum-analyzerMSForm"), function(id, elem){
				if ($(elem).parent().hasClass("has-error") && $(elem).is(":visible") )
					isBtnStep4OK = false;
			});
			if (isBtnStep4OK) {
				if ($("#btnSwitch-gotoStep4-ms").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep4-ms").removeClass("btn-disabled");
				if (!$("#btnSwitch-gotoStep4-ms").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep4-ms").addClass("btn-primary");
				$("#btnSwitch-gotoStep4-ms").prop("disabled", false);
			} else {
				if (!$("#btnSwitch-gotoStep4-ms").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep4-ms").addClass("btn-disabled");
				if ($("#btnSwitch-gotoStep4-ms").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep4-ms").removeClass("btn-primary");
				$("#btnSwitch-gotoStep4-ms").prop("disabled", true);
			}
		}
		// CHECK IF OK STEP 5 - PEAKS
		if ($(this).hasClass("add1spectrum-peaksMSForm-peaklist") && $("#btnSwitch-gotoStep5-ms").is(":visible")) {
			var isBtnStep5OK = true;
			$.each($(".add1spectrum-peaksMSForm-peaklist"), function(id, elem){
				if ($(elem).parent().hasClass("has-error") && $(elem).is(":visible") )
					isBtnStep5OK = false;
			});
			if (isBtnStep5OK) {
				if ($("#btnSwitch-gotoStep5-ms").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep5-ms").removeClass("btn-disabled");
				if (!$("#btnSwitch-gotoStep5-ms").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep5-ms").addClass("btn-primary");
				$("#btnSwitch-gotoStep5-ms").prop("disabled", false);
			} else {
				if (!$("#btnSwitch-gotoStep5-ms").hasClass("btn-disabled"))
					$("#btnSwitch-gotoStep5-ms").addClass("btn-disabled");
				if ($("#btnSwitch-gotoStep5-ms").hasClass("btn-primary"))
					$("#btnSwitch-gotoStep5-ms").removeClass("btn-primary");
				$("#btnSwitch-gotoStep5-ms").prop("disabled", true);
			}
		}
		
		
		// CHECK IF OK STEP 6 - OTHER DATA
		if ($(this).hasClass("add1spectrum-otherForm") && $("#btnSwitch-gotoStep6").is(":visible")) {
			checkIfEnableSubmit();
		}
	});
});
	
function fulfillLCdata(jsonFileName) {
	$.getJSON("resources/json/lc-methods/"+jsonFileName+".json", function(json) {
		// $.POST
		console.log(json);
		// lc chromato
		if (json.lc_chromatography!=null) {
			$("#add1spectrum-chromatoLC-colConstructor").val(json.lc_chromatography.column_constructor);
			$("#add1spectrum-chromatoLC-colConstructor").change();
			$("#add1spectrum-chromatoLC-colConstructorOther").val(json.lc_chromatography.column_constructor_other);
			$("#add1spectrum-chromatoLC-colConstructorOther").change();
			$("#add1spectrum-chromatoLC-colName").val(json.lc_chromatography.column_name);
			$("#add1spectrum-chromatoLC-colName").change();
			$("#add1spectrum-chromatoLC-colLength").val(json.lc_chromatography.column_length);
			$("#add1spectrum-chromatoLC-colLength").change();
			$("#add1spectrum-chromatoLC-colDiameter").val(json.lc_chromatography.column_diameter);
			$("#add1spectrum-chromatoLC-colDiameter").change();
			$("#add1spectrum-chromatoLC-colParticuleSize").val(json.lc_chromatography.particule_size);
			$("#add1spectrum-chromatoLC-colParticuleSize").change();
			$("#add1spectrum-chromatoLC-colTemperature").val(json.lc_chromatography.column_temperature);
			$("#add1spectrum-chromatoLC-colTemperature").change();
			try {
				$("#add1spectrum-chromatoLC-LCMode").val(json.lc_chromatography.LC_mode.toLowerCase());	
			} catch (e) {}
			$("#add1spectrum-chromatoLC-LCMode").change();
			$("#add1spectrum-chromatoLC-separationFlowRate").val(json.lc_chromatography.separation_flow_rate);
			$("#add1spectrum-chromatoLC-separationFlowRate").change();
			$("#add1spectrum-chromatoLC-separationSolvA").val(json.lc_chromatography.separation_solvent_a);
			$("#add1spectrum-chromatoLC-separationSolvA").change();
			$("#add1spectrum-chromatoLC-separationSolvApH").val(json.lc_chromatography.ph_solvent_a);
			$("#add1spectrum-chromatoLC-separationSolvApH").change();
			$("#add1spectrum-chromatoLC-separationSolvB").val(json.lc_chromatography.separation_solvent_b);
			$("#add1spectrum-chromatoLC-separationSolvB").change();
			$("#add1spectrum-chromatoLC-separationSolvBpH").val(json.lc_chromatography.ph_solvent_b);
			$("#add1spectrum-chromatoLC-separationSolvBpH").change();
			// lc separation_flow_gradient
			var handsontableSeparationFlowRateData = [];
			if (json.lc_chromatography.separation_flow_gradient != null) {
				$.each(json.lc_chromatography.separation_flow_gradient, function(){
					var e = [ "" + this.time, "" + this.solvA, "" + this.solvB ];
					handsontableSeparationFlowRateData.push(e);
				});
			} else {
				handsontableSeparationFlowRateData = null;
			}
			handsontableSeparationFlowRate(handsontableSeparationFlowRateData);
		}
		// ms_analyzer
		if (json.ms_analyzer !=null) {
			$("#add1spectrum-analyzer-ms-instrument").val(json.ms_analyzer.instrument);
			$("#add1spectrum-analyzer-ms-instrument").change();
			$("#add1spectrum-analyzer-ms-model").val(json.ms_analyzer.model);
			$("#add1spectrum-analyzer-ms-model").change();
			$("#add1spectrum-analyzer-ms-resolutionFWHM").val(json.ms_analyzer.resolution_FWHM);
			$("#add1spectrum-analyzer-ms-resolutionFWHM").change();
			$("#add1spectrum-analyzer-ms-ionAnalyzerType").val(json.ms_analyzer.ion_analyzer_type);
			$("#add1spectrum-analyzer-ms-ionAnalyzerType").change();
// 				$("#add1spectrum-analyzer-ms-detector").val(json.ms_analyzer.detector);
// 				$("#add1spectrum-analyzer-ms-detector").change();
// 				$("#add1spectrum-analyzer-ms-detectionProtocol").val(json.ms_analyzer.detection_protocol);
// 				$("#add1spectrum-analyzer-ms-detectionProtocol").change();
		}
		// molecule_ionization
		if (json.molecule_ionization != null) {
			if (json.molecule_ionization.mode_pos != null) {
				$("#add1spectrum-analyzserMS-ionizationMethod-pos").val(json.molecule_ionization.mode_pos.ionisation_method);
				$("#add1spectrum-analyzserMS-ionizationMethod-pos").change();
				$("#add1spectrum-analyzserMS-sprayGazFlow-pos").val(json.molecule_ionization.mode_pos.spray_gaz_flow);
				$("#add1spectrum-analyzserMS-sprayGazFlow-pos").change();
				$("#add1spectrum-analyzserMS-vaporizerGazFlow-pos").val(json.molecule_ionization.mode_pos.vaporizer_gaz_flow);
				$("#add1spectrum-analyzserMS-vaporizerGazFlow-pos").change();
				$("#add1spectrum-analyzserMS-vaporizerTemperature-pos").val(json.molecule_ionization.mode_pos.vaporizer_temperature);
				$("#add1spectrum-analyzserMS-vaporizerTemperature-pos").change();
				$("#add1spectrum-analyzserMS-sourceGazFlow-pos").val(json.molecule_ionization.mode_pos.source_gaz_flow);
				$("#add1spectrum-analyzserMS-sourceGazFlow-pos").change();
				$("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-pos").val(json.molecule_ionization.mode_pos.tube_temperature);
				$("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-pos").change();
				$("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-pos").val(json.molecule_ionization.mode_pos.voltage);
				$("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-pos").change();
			}
			if (json.molecule_ionization.mode_neg != null) {
				$("#add1spectrum-analyzserMS-ionizationMethod-neg").val(json.molecule_ionization.mode_neg.ionisation_method);
				$("#add1spectrum-analyzserMS-ionizationMethod-neg").change();
				$("#add1spectrum-analyzserMS-sprayGazFlow-neg").val(json.molecule_ionization.mode_neg.spray_gaz_flow);
				$("#add1spectrum-analyzserMS-sprayGazFlow-neg").change();
				$("#add1spectrum-analyzserMS-vaporizerGazFlow-neg").val(json.molecule_ionization.mode_neg.vaporizer_gaz_flow);
				$("#add1spectrum-analyzserMS-vaporizerGazFlow-neg").change();
				$("#add1spectrum-analyzserMS-vaporizerTemperature-neg").val(json.molecule_ionization.mode_neg.vaporizer_temperature);
				$("#add1spectrum-analyzserMS-vaporizerTemperature-neg").change();
				$("#add1spectrum-analyzserMS-sourceGazFlow-neg").val(json.molecule_ionization.mode_neg.source_gaz_flow);
				$("#add1spectrum-analyzserMS-sourceGazFlow-neg").change();
				$("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-neg").val(json.molecule_ionization.mode_neg.tube_temperature);
				$("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-neg").change();
				$("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-neg").val(json.molecule_ionization.mode_neg.voltage);
				$("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-neg").change();
			}
			//////////////
		}
		// other
		if (json.other != null) {
			$("#add1spectrum-other-author").val(json.other.data_authors);
			$("#add1spectrum-other-author").change();
			$("#add1spectrum-other-validator").val(json.other.data_validator);
			$("#add1spectrum-other-validator").change();
			$("#add1spectrum-other-date").val(json.other.acquisition_date);
			$("#add1spectrum-other-date").change();
			$("#add1spectrum-other-owner").val(json.other.data_ownership);
			$("#add1spectrum-other-owner").change();
		}
	}).error(function(event, jqxhr, exception) {
		if (event.status == 404) {
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to load pre-filled data!';
			alert += ' </div>';
			$("#alertBoxSelectTemplate").html(alert);
		}
	});
}
/////////////////////////////////////////////////////////////////////////// WEB FORM
// tech
var isLC = false;
var isGC = false;
var isMS = false;
var isNMR = false;

/**
 * reset form color
 */
function resetFromColors() {
	$.each($(".add1spectrum"), function(id, elem){
		if ($(elem).parent().hasClass("has-success"))
			$(elem).parent().removeClass("has-success");
		if ($(elem).parent().hasClass("has-warning"))
			$(elem).parent().removeClass("has-warning");
		if ($(elem).parent().hasClass("has-error"))
			$(elem).parent().removeClass("has-error");
		if ($(elem).hasClass("is-mandatory") &&  ($(elem).val() == "" || $(elem).val() == null) )
			$(elem).parent().addClass("has-error");
		if ($(elem).hasClass("is-optional") &&  ($(elem).val() == "" || $(elem).val() == null) )
			$(elem).parent().addClass("has-warning");
		if (($(elem).val() != "" && $(elem).val() != null) )
			$(elem).parent().addClass("has-success");
	});
	$.each($("button.switchStep"), function(id, elem) {
		if (!$(this).hasClass("btn-disabled"))
			$(this).addClass("btn-disabled");
		if ($(this).hasClass("btn-primary"))
			$(this).removeClass("btn-primary");
		$(this).prop("disabled", true);
	});
	
	// peak list: no data to check
	$("#btnSwitch-gotoStep5-ms").removeClass("btn-disabled");
	$("#btnSwitch-gotoStep5-nmr").removeClass("btn-disabled");
	$("#btnSwitch-gotoStep5-ms").addClass("btn-primary");
	$("#btnSwitch-gotoStep5-nmr").addClass("btn-primary");
	$("#btnSwitch-gotoStep5-ms").prop("disabled", false);
	$("#btnSwitch-gotoStep5-nmr").prop("disabled", false);
	
	$("#add1spectrum-other-author").prop("disabled", false);
	$("#add1spectrum-other-validator").prop("disabled", false);
	$("#add1spectrum-other-date").prop("disabled", false);
	$("#add1spectrum-other-owner").prop("disabled", false);
	$("#add1spectrum-other-fileName").prop("disabled", false);
	$("#add1spectrum-other-fileSize").prop("disabled", false);
	
}

/**
 * Go to step...
 */
 function  switchToStep(step) {
	switch(step) {
	case 2:
		// hide after step 2 / alt step 2
		$("#add1spectrum-chromatographyData-LC").hide();
		$("#add1spectrum-chromatographyData-GC").hide();
		$("#add1spectrum-analyserData-NMR").hide();
		$("#add1spectrum-analyserData-MS").hide();
		$("#add1spectrum-peaksData-MS").hide();
		$("#add1spectrum-peaksData-NMR").hide();
		$("#add1spectrum-otherData").hide();
		// step 1 ok
		if ($("#step1sign").hasClass("fa-question-circle"))
			$("#step1sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		// check panel to show
		if (isLC) {
			$("#add1spectrum-chromatographyData-LC").show();
			$("#linkActivateStep2-lc").trigger('click');
			if ($("#step2-lc-sign").hasClass("fa-check-circle"))
				$("#step2-lc-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
			// LC SFG
			if (!isSeparationFlowRateInit) {
				handsontableSeparationFlowRate(null);
				isSeparationFlowRateInit = true;
			}
		} else if (isGC) {
			$("#add1spectrum-chromatographyData-GC").show();
			$("#linkActivateStep2-gc").trigger('click');
			if ($("#step2-gc-sign").hasClass("fa-check-circle"))
				$("#step2-gc-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
		} else if (isNMR) { // GO FROM 1 TO 3
			resetNMRprogramms();
			$("#add1spectrum-analyserData-NMR").show();
			$("#linkActivateStep3-nmr").trigger('click');
			if ($("#step3-nmr-sign").hasClass("fa-check-circle"))
				$("#step3-nmr-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
		}
		break;
	case 3:
		// hide after step 3 / alt step 3
		$("#add1spectrum-analyserData-MS").hide();
		if (!isNMR)
			$("#add1spectrum-analyserData-NMR").hide();
		$("#add1spectrum-peaksData-MS").hide();
		$("#add1spectrum-peaksData-NMR").hide();
		$("#add1spectrum-otherData").hide();
		// step 2 ok 
		if ($("#step2-lc-sign").hasClass("fa-question-circle"))
			$("#step2-lc-sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		if ($("#step2-gc-sign").hasClass("fa-question-circle"))
			$("#step2-gc-sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		// check panel to show
		if (isMS) {
			$("#add1spectrum-analyserData-MS").show();
			$("#linkActivateStep3-ms").trigger('click');
			// debug display
			$("#add1spectrum-analyzserMS-sprayGazFlow-pos").height($("#add1spectrum-analyzserMS-sprayGazFlow-pos").parent().children("span").height());
			$("#add1spectrum-analyzserMS-sprayGazFlow-neg").height($("#add1spectrum-analyzserMS-sprayGazFlow-neg").parent().children("span").height());
			$("#add1spectrum-analyzserMS-vaporizerGazFlow-pos").height($("#add1spectrum-analyzserMS-vaporizerGazFlow-pos").parent().children("span").height());
			$("#add1spectrum-analyzserMS-vaporizerGazFlow-neg").height($("#add1spectrum-analyzserMS-vaporizerGazFlow-neg").parent().children("span").height());
			$("#add1spectrum-analyzserMS-vaporizerTemperature-pos").height($("#add1spectrum-analyzserMS-vaporizerTemperature-pos").parent().children("span").height());
			$("#add1spectrum-analyzserMS-vaporizerTemperature-neg").height($("#add1spectrum-analyzserMS-vaporizerTemperature-neg").parent().children("span").height());
			$("#add1spectrum-analyzserMS-sourceGazFlow-pos").height($("#add1spectrum-analyzserMS-sourceGazFlow-pos").parent().children("span").height());
			$("#add1spectrum-analyzserMS-sourceGazFlow-neg").height($("#add1spectrum-analyzserMS-sourceGazFlow-neg").parent().children("span").height());
			$("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-pos").height($("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-pos").parent().children("span").height());
			$("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-neg").height($("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-neg").parent().children("span").height());
			$("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-pos").height($("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-pos").parent().children("span").height());
			$("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-neg").height($("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-neg").parent().children("span").height());
			if ($("#step3-ms-sign").hasClass("fa-check-circle"))
				$("#step3-ms-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
		} else if (isNMR) { // case LC-NMR
			resetNMRprogramms();
			$("#add1spectrum-analyserData-NMR").show();
			$("#linkActivateStep3-nmr").trigger('click');
			if ($("#step3-nmr-sign").hasClass("fa-check-circle"))
				$("#step3-nmr-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
			$(".add1spectrum-analyzserNMR-programm-peaklist").change();
		}
		// avoid display bug
		$("#add1spectrum-analyzer-ms-instrument").change();
		break;
	case 4:
		// hide after step 4 / alt step 4
		$("#add1spectrum-peaksData-MS").hide();
		$("#add1spectrum-peaksData-NMR").hide();
		$("#add1spectrum-otherData").hide();
		// step 3 ok 
		if ($("#step3-ms-sign").hasClass("fa-question-circle"))
			$("#step3-ms-sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		if ($("#step3-nmr-sign").hasClass("fa-question-circle"))
			$("#step3-nmr-sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		// check panel to show
		if (isMS) {
			$("#add1spectrum-peaksData-MS").show();
			$("#linkActivateStep4-ms").trigger('click');
			if ($("#step4-ms-sign").hasClass("fa-check-circle"))
				$("#step4-ms-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
			// LC MS
			if (!isMSpeaksInit) {
				handsontableMSpeaks(null);
				isMSpeaksInit = true;
				$(".add1spectrum-peaksMSForm-peaklist-reset").val("").change();
			}
		} else if (isNMR) { // case LC-NMR
			$("#add1spectrum-peaksData-NMR").show();
			$("#linkActivateStep4-nmr").trigger('click');
			if ($("#step4-nmr-sign").hasClass("fa-check-circle"))
				$("#step4-nmr-sign").removeClass("fa-check-circle").addClass("fa-question-circle");
		}
		// show ms tab
		if (isMS)
			setTimeout(function(){ $("#container_MS_Peaks").trigger('click'); }, 250);
		break;
	case 5:
		// hide after step 5 / alt step 5
		$("#add1spectrum-otherData").hide();
		// step 4 ok 
		if ($("#step4-ms-sign").hasClass("fa-question-circle"))
			$("#step4-ms-sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		if ($("#step4-nmr-sign").hasClass("fa-question-circle"))
			$("#step4-nmr-sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		// check btn to set
		if (isMS) {} else if (isNMR) {} // case LC-NMR
		if ($("#step5sign").hasClass("fa-check-circle"))
			$("#step5sign").removeClass("fa-check-circle").addClass("fa-question-circle");
		$("#add1spectrum-otherData").show();
		$("#linkActivateStep5").trigger('click');
		// reset step 6 button
		checkIfEnableSubmit();
		$("#import1SpectrumLoadingBare").hide();
		$("#import1SpectrumResults").hide();
		break;
	case 6:
		postOneSpectrumFrom();
		cptPeakListTab++;
		break;
	case 7:
		dumpOneSpectrumFrom();
		break;
	}
}

resetElemColor = function(idElem) {
	if ($("#"+idElem).parent().hasClass("has-success"))
		$("#"+idElem).parent().removeClass("has-success");
	if ($("#"+idElem).parent().hasClass("has-warning"))
		$("#"+idElem).parent().removeClass("has-warning");
	if ($("#"+idElem).parent().hasClass("has-error"))
		$("#"+idElem).parent().removeClass("has-error");
};

disableElem = function(idElem) {
	$("#"+idElem).prop("disabled", true);
	$("#"+idElem).val("");
	if ($("#"+idElem).hasClass("is-mandatory"))
		$("#"+idElem).removeClass("is-mandatory");
};

enableElem = function(idElem) {
	$("#"+idElem).prop("disabled", false);
	$("#"+idElem).parent().addClass("has-error");
	if (!$("#"+idElem).hasClass("is-mandatory"))
		$("#"+idElem).addClass("is-mandatory");
};

function checkIfEnableSubmit () {
	var isBtnStep6OK = true;
	$.each($(".add1spectrum-otherForm"), function(id, elem){
		if ($(elem).parent().hasClass("has-error") && $(elem).is(":visible") )
			isBtnStep6OK = false;
	});
	if (isBtnStep6OK) {
		if ($("#btnSwitch-gotoStep6").hasClass("btn-disabled"))
			$("#btnSwitch-gotoStep6").removeClass("btn-disabled");
		if (!$("#btnSwitch-gotoStep6").hasClass("btn-primary"))
			$("#btnSwitch-gotoStep6").addClass("btn-primary");
		$("#btnSwitch-gotoStep6").prop("disabled", false);
		if ($("#btnSwitch-gotoStep7").hasClass("btn-disabled"))
			$("#btnSwitch-gotoStep7").removeClass("btn-disabled");
		if (!$("#btnSwitch-gotoStep7").hasClass("btn-primary"))
			$("#btnSwitch-gotoStep7").addClass("btn-primary");
		$("#btnSwitch-gotoStep7").prop("disabled", false);
	} else {
		if (!$("#btnSwitch-gotoStep6").hasClass("btn-disabled"))
			$("#btnSwitch-gotoStep6").addClass("btn-disabled");
		if ($("#btnSwitch-gotoStep6").hasClass("btn-primary"))
			$("#btnSwitch-gotoStep6").removeClass("btn-primary");
		$("#btnSwitch-gotoStep6").prop("disabled", true);
		if (!$("#btnSwitch-gotoStep7").hasClass("btn-disabled"))
			$("#btnSwitch-gotoStep7").addClass("btn-disabled");
		if ($("#btnSwitch-gotoStep7").hasClass("btn-primary"))
			$("#btnSwitch-gotoStep7").removeClass("btn-primary");
		$("#btnSwitch-gotoStep7").prop("disabled", true);
	}
};

/////////////////////////////////////////////////////////////////////////// step 0 - spectrum type
/**
 * Select spectrum type: switch from step 0 to step 1
 */
function addOneSpectrum(type) {
 	// unlock
	$(".add1spectrum-sampleForm").prop("disabled", false);
	$(".add1spectrum-chromatoLCForm").prop("disabled", false);
	$(".add1spectrum-analyzerMSForm").prop("disabled", false);
	$(".add1spectrum-analyzerNMRForm-lock").prop("disabled", false);
	$(".add1spectrum-otherForm").prop("disabled", false);
	$("#add1spectrum-chromatoLC-colConstructor").change();
	// reset
	isLC = false;
	isGC = false;
	isMS = false;
	isNMR = false;
	$("#alertBoxSubmitSpectrum").html("");
	// reset std matrix link
	var stdMatrixLink = $("#add1spectrum-sample-stdMatrix").parent().children("span").children("a");
	$(stdMatrixLink).attr("href", "");
	$(stdMatrixLink).hide();
	// hide in all steps
	$(".opt-nmr").hide();
	$(".opt-ms").hide();
	// hide step 2
	$("#add1spectrum-chromatographyData-LC").hide();
	$("#add1spectrum-chromatographyData-GC").hide();
	// hide step 3
	$("#add1spectrum-analyserData-NMR").hide();
	$("#add1spectrum-analyserData-MS").hide();
	// hide step 4
	$("#add1spectrum-peaksData-MS").hide();
	$("#add1spectrum-peaksData-NMR").hide();
	// hide step 5
	$("#add1spectrum-otherData").hide();
	// reset field step 1
	$("#add1spectrum-sample-type").val("");
	$(".add1spectrum-sample-type-panel").hide();
	$(".add1spectrum-sampleForm").val("");
	$("#sample-bonus-display").html("");
	// reset field step 2
	$(".add1spectrum-chromatoLCForm").val("");
	// reset field step 3
	$(".add1spectrum-analyzerMSForm").val("");
	$(".add1spectrum-analyzerNMRForm").val("");
	// reset field step 4
	// reset peak lists / all tabs
	isSeparationFlowRateInit = false;
	isMSpeaksInit = false;
	$(".handsontable").html("");
	// reset field step 5 => NO!
	// set icon
	$("#step0sign").removeClass("fa-question-circle").addClass("fa-check-circle");
	if ($("#step1sign").hasClass("fa-check-circle"))
		$("#step1sign").removeClass("fa-check-circle").addClass("fa-question-circle");
	// collapse step 0 / uncollaspe step 1
	$("#linkActivateStep1").trigger('click');
	// show step 1 content
	$('#add1spectrum-sampleData').show();
	switch(type) {
	case 1:
		// TODO GC-MS stuff
		isGC = true;
		isMS = true;
		break;
	case 2:
		// LC-MS stuff
		isLC = true;
		isMS = true;
		$(".opt-ms").show();
		break;
	case 3:
		// NMR stuff
		isNMR = true;
		$(".opt-nmr").show();
		break;
	case 4:
		// TODO LC-NMR stuff
		isLC = true;
		isNMR = true;
		break;
	}
	// 
	resetFromColors();
	// reset json obj to submit form
	jsonSpectrumType = null;
	isJsonSpectrumTypeComplete = false;
	jsonSample = null;
	isJsonSampleComplete = false;
	isJsonRCCaddedComplete = false;
	jsonChromato = null;
	isJsonChromatoComplete = false;
	jsonAnalyzer = null;
	isJsonAnalyzerComplete = false;
	jsonPeaksList = [];
	isJsonPeaksListComplete = false;
	jsonOtherMetadata = null;
	isJsonOtherMetadataComplete = false;
	
	cptPeakListTab = 0;
	jsonAnalyzerAcquisition = [];
	idMetadataMap = {}
	listOfViewableSpectra = [];
	
	// spec MS
	jsonMolIonization = null;
	
	// try load cpd
	if (inchikey !== null) {
		loadJSCompound(inchikey);
	}
}

/**
 * 
 * @param inchikey
 * @returns
 */
function loadJSCompound(inchikey) {
	
	$("#add1spectrum-sample-type").val("compound-ref");
	$("#add1spectrum-sample-type").change();
	$("#add1spectrum-sample-inchikey").val(inchikey);
	$("#add1spectrum-sample-inchikey").change();
	$.ajax({
		type: "get",
		url: "get-cpd-data",
//		 	data:  JSON.stringify({ inchikey: inchikey }),
		data: "inchikey="+inchikey,
//		 	contentType: 'application/json',
		dataType: 'json',
		success: function(data) {
			if (data.success) {
				$("#add1spectrum-sample-inchi").val(data.inchi);
				$("#add1spectrum-sample-inchi").change();
				$("#add1spectrum-sample-commonName").val(data.name);
				$("#add1spectrum-sample-commonName").change();
				$("#sample-bonus-display").html('<img class="" src="image/'+data.type+'/'+data.inchikey+'.svg" alt="'+data.name+'">');
			}
		}, 
		error : function(data) {
		}
	}).always(function() {
	});
}




/**
 * Reset NMR programm
 */
resetNMRprogramms = function() {
	$("#add1spectrum-analyzserNMR-programm").val("");
	$(".input-nmrProg").hide();
	$(".add1spectrum-analyzserNMR-programm-peaklist").prop("disabled", false);
	$(".add1spectrum-analyzserNMR-programm-processing").prop("disabled", false);
	$(".add1spectrum-analyzserNMR-programm-peaklist").val("").change();
}

hideShowProgrammeOption = function() {
	var prog = $("#add1spectrum-analyzserNMR-programm").val();
	$(".input-nmrProg").hide();
	$(".nmr-1dh").hide();
	$(".nmr-1dc").hide();
	$(".nmr-2d-jres").hide();
	$(".nmr-2d-cosy").hide();
	$(".nmr-2d-tocsy").hide();
	$(".nmr-2d-noesy").hide();
	$(".nmr-2d-hsqc").hide();
	$(".nmr-2d-hmbc").hide();
	switch (prog) {
	case "":
		return false;
	case "proton":
	case "proton-1d":
		$(".input-nmrProg-H").show();
		handsontableNmrProtPeaks(null);
		handsontableNmrProtPeakSats(null);
		handsontableNmrMultiPeaks(null);
		$(".nmr-1dh").show();
		$(".input-nmrProg-all-1d").show();
		break;
	case "noesy-1d":
		$(".input-nmrProg-noesy1d").show();
		handsontableNmrProtPeaks(null);
		handsontableNmrProtPeakSats(null);
		handsontableNmrMultiPeaks(null);
		$(".nmr-1dh").show();
		$(".input-nmrProg-all-1d").show();
		break;
	case "cpmg-1d":
		$(".input-nmrProg-cpmg1d").show();
		handsontableNmrProtPeaks(null);
		handsontableNmrProtPeakSats(null);
		handsontableNmrMultiPeaks(null);
		$(".nmr-1dh").show();
		$(".input-nmrProg-all-1d").show();
		break;
	case "carbon13-1d":
		$(".input-nmrProg-C13").show();
		handsontableNmrCarbPeaks(null);
		handsontableNmrCarbMultiPeaks(null);
		$(".nmr-1dc").show();
		$(".input-nmrProg-all-1d").show();
		break;
	case "JRES-2d":
		$(".input-nmrProg-JRES").show();
		handsontableNmr_JRES_Peaks(null);
		$(".nmr-2d-jres").show();
		break;
	case "COSY-2d":
		$(".input-nmrProg-COSY").show();
		handsontableNmr_2DHH_Peaks(null);
		$(".nmr-2d-cosy").show();
		break;
	case "TOCSY-2d":
		$(".input-nmrProg-TOCSY").show();
		handsontableNmr_2DHH_Peaks(null);
		$(".nmr-2d-tocsy").show();
		break;
	case "NOESY-2d":
		$(".input-nmrProg-NOESY").show();
		handsontableNmr_2DHH_Peaks(null);
		$(".nmr-2d-noesy").show();
		break;
	case "HSQC-2d":
		$(".input-nmrProg-HSQC").show();
		handsontableNmr_2DHC_Peaks(null);
		$(".nmr-2d-hsqc").show();
		break;
	case "HMBC-2d":
		$(".input-nmrProg-HMBC").show();
		handsontableNmr_2DHC_Peaks(null);
		$(".nmr-2d-hmbc").show();
		break;
	default:
		break;	
	}
	$(".input-nmrProg-all").show();
	resetFromColors();
	return true;
};

$(document).ready( function() {
	$("#add1spectrum-analyzer-nmr-processing-windowFunctionF1").on("change", function() {
		var v = $("#add1spectrum-analyzer-nmr-processing-windowFunctionF1").val();
		if (v == "SINE" || v == "QSINE") {
			$("#add1spectrum-analyzer-nmr-processing-ssbF1").parent().show();
		} else {
			$("#add1spectrum-analyzer-nmr-processing-ssbF1").parent().hide();
		}
		if (v == "GM") {
			$("#add1spectrum-analyzer-nmr-processing-gbF1").parent().show();
		} else {
			$("#add1spectrum-analyzer-nmr-processing-gbF1").parent().hide();
		}
	});
	$("#add1spectrum-analyzer-nmr-processing-windowFunctionF2").on("change", function() {
		var v = $("#add1spectrum-analyzer-nmr-processing-windowFunctionF2").val();
		if (v == "SINE" || v == "QSINE") {
			$("#add1spectrum-analyzer-nmr-processing-ssbF2").parent().show();
		} else {
			$("#add1spectrum-analyzer-nmr-processing-ssbF2").parent().hide();
		}
		if (v == "GM") {
			$("#add1spectrum-analyzer-nmr-processing-gbF2").parent().show();
		} else {
			$("#add1spectrum-analyzer-nmr-processing-gbF2").parent().hide();
		}
	});
});

	
// Handsontable - Grid Excel like
// def colors
var yellowRenderer = function (instance, td, row, col, prop, value, cellProperties) {
	Handsontable.renderers.TextRenderer.apply(this, arguments);
	td.style.backgroundColor = 'yellow';
};
var lightgrayRenderer = function (instance, td, row, col, prop, value, cellProperties) {
	Handsontable.renderers.TextRenderer.apply(this, arguments);
	td.style.backgroundColor = '#EEE';
};

// def graph
var container_LC_SFG, hot_LC_SFG;
var container_MS_Peaks, hot_MS_Peaks;
var container_NMR_H_Peaks, hot_NMR_H_Peaks;
var container_NMR_Hsat_Peaks, hot_NMR_Hsat_Peaks;
var container_NMR_C_Peaks, hot_NMR_C_Peaks;
var container_NMR_C_Multi_Peaks, hot_NMR_C_Multi_Peaks;

var container_NMR_Multi_Peaks, hot_NMR_Multi_Peaks;
var container_NMR_2DHC_Peaks, hot_NMR_2DHC_Peaks;
var container_NMR_2DHH_Peaks, hot_NMR_2DHH_Peaks;
var container_NMR_JRES_Peaks, hot_NMR_JRES_Peaks;

var container_RCC_ADDED, hot_RCC_ADDED;

/**
 * 
 */
function handsontableSeparationFlowRate(data) {
	// reset
	$("#container_LC_SFG").html("");
	// init
	var data_LC_SFG;
	if (data==null) {
		data_LC_SFG = [
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   			[ "", "", "" ],
   		];
	} else {
		data_LC_SFG = data;
	}
	
	container_LC_SFG = document.getElementById('container_LC_SFG');
	hot_LC_SFG = new Handsontable(container_LC_SFG, {
		data : data_LC_SFG,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["time (min)", "solv. A (%)", "solv. B (%)"],
		contextMenu : false
	});
	function bindDumpButton_LC_SFG() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON"&& element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_LC_SFG = window[instance];
				console.log('data of ' + name, hot_LC_SFG.getData());
			}
		});
	}
	bindDumpButton_LC_SFG();
	$("#container_LC_SFG table.htCore").css("width","100%");
}
/**
 * 
 */
handsontableMSpeaks = function (data) {
	// reset
	$("#container_MS_Peaks").html("");
// 	var attribTab = {
// 		type: 'dropdown',
// 		source: ['[M]', // NEUTRAL
// 		         '[M+H]+', '[M+NH4]+', '[M+Na]+', '[M+K]+', '[M+H-H2O]+', '[M+H-2H2O]+', '[M+CH3OH+H]+', '[M+CH3CN+H]+',// POS 1M
// 		         '[2M+H]+', '[2M+NH4]+', '[2M+Na]+', '[2M+K]+', // POS 2M
// 		         '[M-H]-', '[M-H-H2O]-', '[M+HCOOH-H]-', '[M+CH3COOH-H]-', // NEG 1M
// 		         '[2M-H]-', '[2M+HCOOH-H]-', '[2M+CH3COOH-H]-', // NEG 2M
// 		         '[3M-H]-' // NEG 3M
// 		         ]
// 	};
	var data_MS_Peaks = [
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
	];
	
	if (data != null)
		data_MS_Peaks = data;
	
  	container_MS_Peaks = document.getElementById('container_MS_Peaks');
  	hot_MS_Peaks = new Handsontable(container_MS_Peaks, {
  		data : data_MS_Peaks,
  		minSpareRows : 1,
  		colHeaders : true,
  		colHeaders: ["m/z", "absolute intensity", "relative intensity (%)", "theo. mass", "delta (ppm)", "composition", "attribution"],
  		contextMenu : false,
  		columns: [
            {type: 'numeric', format: '0.0000'},
            {type: 'numeric', format: '0.00'},
            {type: 'numeric', format: '0.00'},
            {type: 'numeric', format: '0.0000'},
            {type: 'numeric', format: '0.0000'},
			{type: 'text'},
			{type: 'text'},
  		]
  	});
      function bindDumpButton_MS_Peaks() {
      	Handsontable.Dom.addEvent(document.body, 'click', function(e) {
  			var element = e.target || e.srcElement;
  			if (element.nodeName == "BUTTON" && element.name == 'dump') {
  				var name = element.getAttribute('data-dump');
  				var instance = element.getAttribute('data-instance');
  				var hot_MS_Peaks = window[instance];
  				console.log('data of ' + name, hot_MS_Peaks.getData());
  			}
  		});
  	}
  	bindDumpButton_MS_Peaks();
  	
  	$("#container_MS_Peaks table.htCore").css("width","100%");
}



/**
 * 
 */
function handsontableNmrProtPeaks(data) {
	// reset
	$("#container_NMR_H_Peaks").html("");
	// init
	var data_NMR_H_Peaks = [
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ]
	 ];
	if (data != null)
		data_NMR_H_Peaks = data;
	
	container_NMR_H_Peaks = document.getElementById('container_NMR_H_Peaks');
	hot_NMR_H_Peaks = new Handsontable(container_NMR_H_Peaks, {
		data : data_NMR_H_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["peak index", "region", "index (F1)", "ν (F1) [ppm]", "ν (F1) [Hz]", "intensity [abs]", "intensity [rel]", "half width [ppm]", "half width [Hz]", "annotation"],
		contextMenu : false,
		columns: [
			{data: "peak index", type: 'text'},
			{data: "region", renderer: lightgrayRenderer},
			{data: "index (F1)", renderer: lightgrayRenderer},
			{data: "ν (F1) [ppm]", type: 'text'},
			{data: "ν (F1) [Hz]", renderer: lightgrayRenderer},
			{data: "intensity [abs]", renderer: lightgrayRenderer},
			{data: "intensity [rel]", type: 'text'},
			{data: "half width [ppm]", type: 'text'},
			{data: "half width [Hz]", renderer: lightgrayRenderer}, 
			{data: "annotation", type: 'text'} 
		],
	});
	function bindDumpButton_NMR_H_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_H_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_H_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_H_Peaks();
	hot_NMR_H_Peaks.selectCell(0,0);
	$("#container_NMR_H_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmrProtPeakSats(data) {
	// reset
	$("#container_NMR_Hsat_Peaks").html("");
	// init
	var data_NMR_Hsat_Peaks = [
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_Hsat_Peaks = data;
	
	container_NMR_Hsat_Peaks = document.getElementById('container_NMR_Hsat_Peaks');
	hot_NMR_Hsat_Peaks = new Handsontable(container_NMR_Hsat_Peaks, {
		data : data_NMR_Hsat_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["peak index", "region", "index (F1)", "ν (F1) [ppm]", "ν (F1) [Hz]", "intensity [abs]", "intensity [rel]", "half width [ppm]", "half width [Hz]", "annotation"],
		contextMenu : false,
		columns: [
			{data: "peak index", type: 'text'},
			{data: "region", renderer: lightgrayRenderer},
			{data: "index (F1)", renderer: lightgrayRenderer},
			{data: "ν (F1) [ppm]", type: 'text'},
			{data: "ν (F1) [Hz]", renderer: lightgrayRenderer},
			{data: "intensity [abs]", renderer: lightgrayRenderer},
			{data: "intensity [rel]", type: 'text'},
			{data: "half width [ppm]", type: 'text'},
			{data: "half width [Hz]", renderer: lightgrayRenderer}, 
			{data: "annotation", type: 'text'} 
		],
	});
	function bindDumpButton_NMR_Hsat_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_Hsat_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_Hsat_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_Hsat_Peaks();
	hot_NMR_Hsat_Peaks.selectCell(0,0);
	$("#container_NMR_Hsat_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmrCarbPeaks(data) {
	// reset
	$("#container_NMR_C_Peaks").html("");
	// init
	var data_NMR_C_Peaks = [
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_C_Peaks = data;
		
	container_NMR_C_Peaks = document.getElementById('container_NMR_C_Peaks');
	hot_NMR_C_Peaks = new Handsontable(container_NMR_C_Peaks, {
		data : data_NMR_C_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["peak index", "region", "index (F1)", "ν (F1) [ppm]", "ν (F1) [Hz]", "intensity [abs]", "intensity [rel]", "half width [ppm]", "half width [Hz]", "annotation"],
		contextMenu : false,
		columns: [
			{data: "peak index", type: 'text'},
			{data: "region", renderer: lightgrayRenderer},
			{data: "index (F1)", renderer: lightgrayRenderer},
			{data: "ν (F1) [ppm]", type: 'text'},
			{data: "ν (F1) [Hz]", renderer: lightgrayRenderer},
			{data: "intensity [abs]", renderer: lightgrayRenderer},
			{data: "intensity [rel]", type: 'text'},
			{data: "half width [ppm]", type: 'text'},
			{data: "half width [Hz]", renderer: lightgrayRenderer}, 
			{data: "annotation", type: 'text'} 
		],
	});
	function bindDumpButton_NMR_C_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_C_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_C_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_C_Peaks();
	hot_NMR_C_Peaks.selectCell(0,0);
	$("#container_NMR_C_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmrMultiPeaks(data) {
	// reset
	$("#container_NMR_Multi_Peaks").html("");
	// init
	var data_NMR_Multi_Peaks = [
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_Multi_Peaks = data;
	
	container_NMR_Multi_Peaks = document.getElementById('container_NMR_Multi_Peaks');
	hot_NMR_Multi_Peaks = new Handsontable(container_NMR_Multi_Peaks, {
		data : data_NMR_Multi_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		// ν (F1) [ppm]	H's	type	J(Hz)	range (ppm)	atoms	MSI level
		colHeaders: ["ν (F1) [ppm]", "H's", "type", "J(Hz)", "range (ppm)", "atoms", "MSI level"],
		contextMenu : false,
		columns: [
			{data: "ν (F1) [ppm]", type: 'text'},
			{data: "H's", type: 'text'},
			{data: "type", type: 'text'},
			{data: "J(Hz)", type: 'text'},
			{data: "range (ppm)", type: 'text'},
			{data: "atoms", type: 'text'},
			{data: "MSI level", renderer: lightgrayRenderer}
		],
	});
	function bindDumpButton_NMR_Multi_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_Multi_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_Multi_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_Multi_Peaks();
	hot_NMR_Multi_Peaks.selectCell(0,0);
	$("#container_NMR_Multi_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmrCarbMultiPeaks(data) {
	// reset
	$("#container_NMR_C_Multi_Peaks").html("");
	// init
	var data_NMR_Multi_Peaks = [
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ],
		[ "", "", "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_Multi_Peaks = data;
	
	container_NMR_C_Multi_Peaks = document.getElementById('container_NMR_C_Multi_Peaks');
	hot_NMR_C_Multi_Peaks = new Handsontable(container_NMR_C_Multi_Peaks, {
		data : data_NMR_Multi_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		// ν (F1) [ppm]	H's	type	J(Hz)	range (ppm)	atoms	MSI level
		colHeaders: ["ν (F1) [ppm]", "C's", "type", "J(Hz)", "range (ppm)", "atoms", "MSI level"],
		contextMenu : false,
		columns: [
			{data: "ν (F1) [ppm]", type: 'text'},
			{data: "C's", type: 'text'},
			{data: "type", type: 'text'},
			{data: "J(Hz)", type: 'text'},
			{data: "range (ppm)", type: 'text'},
			{data: "atoms", type: 'text'},
			{data: "MSI level", renderer: lightgrayRenderer}
		],
	});
	function bindDumpButton_NMR_Multi_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_Multi_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_Multi_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_Multi_Peaks();
	hot_NMR_C_Multi_Peaks.selectCell(0,0);
	$("#container_NMR_C_Multi_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmr_2DHC_Peaks(data) {
	// reset
	$("#container_NMR_2DHC_Peaks").html("");
	// init
	var data_NMR_2DHC_Peaks = [
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_2DHC_Peaks = data;
	container_NMR_2DHC_Peaks = document.getElementById('container_NMR_2DHC_Peaks');
	hot_NMR_2DHC_Peaks = new Handsontable(container_NMR_2DHC_Peaks, {
		data : data_NMR_2DHC_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["peak index", "ν (F2) (1H) [ppm]", "ν (F1) (13C) [ppm]", "intensity [rel]", "annotation"],
		contextMenu : false,
		columns: [
			{data: "peak index", type: 'text'},
			{data: "F2 (ppm)", type: 'text'},
			{data: "F1 (ppm)", type: 'text'},
			{data: "intensity (rel)", type: 'text'},
			{data: "annotation", type: 'text'}
		],
	});
	function bindDumpButton_NMR_2DHC_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_2DHC_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_2DHC_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_2DHC_Peaks();
	hot_NMR_2DHC_Peaks.selectCell(0,0);
	$("#container_NMR_2DHC_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmr_2DHH_Peaks(data) {
	// reset
	$("#container_NMR_2DHH_Peaks").html("");
	// init
	var data_NMR_2DHH_Peaks = [
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_2DHH_Peaks = data;
	container_NMR_2DHH_Peaks = document.getElementById('container_NMR_2DHH_Peaks');
	hot_NMR_2DHH_Peaks = new Handsontable(container_NMR_2DHH_Peaks, {
		data : data_NMR_2DHH_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["peak index", "ν (F2) [ppm]", "ν (F1) [ppm]", "intensity [rel]", "annotation"],
		contextMenu : false,
		columns: [
			{data: "peak_index", type: 'text'},
			{data: "F2_ppm", type: 'text'},
			{data: "F1_ppm", type: 'text'},
			{data: "intensity_ppm", type: 'text'},
			{data: "annotation", type: 'text'}
		],
	});
	function bindDumpButton_NMR_2DHH_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_2DHH_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_2DHH_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_2DHH_Peaks();
	hot_NMR_2DHH_Peaks.selectCell(0,0);
	$("#container_NMR_2DHH_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableNmr_JRES_Peaks(data) {
	// reset
	$("#container_NMR_JRES_Peaks").html("");
	// init
	var data_NMR_JRES_Peaks = [
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ],
		[ "", "", "", "", "" ]
	 ];
	if (data !=null)
		data_NMR_JRES_Peaks = data;
	container_NMR_JRES_Peaks = document.getElementById('container_NMR_JRES_Peaks');
	hot_NMR_JRES_Peaks = new Handsontable(container_NMR_JRES_Peaks, {
		data : data_NMR_JRES_Peaks,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["peak index", "ν (F2) [ppm]", "ν (F1) [ppm]", "intensity [rel]", "multiplicity", "J (coupling constant)", "annotation"],
		contextMenu : false,
		columns: [
			{data: "peak_index", type: 'text'},
			{data: "F2_ppm", type: 'text'},
			{data: "F1_ppm", type: 'text'},
			{data: "intensity_rel", type: 'text'},
			{data: "multiplicity", type: 'text'},
			{data: "J", type: 'text'},
			{data: "annotation", type: 'text'}
		],
	});
	function bindDumpButton_NMR_JRES_Peaks() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON" && element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_NMR_JRES_Peaks = window[instance];
				console.log('data of ' + name, hot_NMR_JRES_Peaks.getData());
			}
		});
	}
	bindDumpButton_NMR_JRES_Peaks();
	hot_NMR_JRES_Peaks.selectCell(0,0);
	$("#container_NMR_JRES_Peaks table.htCore").css("width","100%");
}

/**
 * 
 */
function handsontableRefChemCpdAdded(data) { //var container_RCC_ADDED, hot_RCC_ADDED;
	// reset
	$("#container_RCC_ADDED").html("");
	$("#sample-bonus-display").html("");
	// init
	var data_RCC_ADDED, colHeaderData;
	
	if (data==null) {
		if (isNMR) {
			data_RCC_ADDED = [
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   			[ "", "", "","" ],
	   		];
			colHeaderData = [
			     			{data: "common name", type: 'text'},
			    			{data: "<b>InChIKey</b>", type: 'text'},
			    			{data: "composition", renderer: lightgrayRenderer},
			    			{data: "<b>concentration (&micro;g/ml)</b>", type: 'text'}
			    		]
		} else {
			data_RCC_ADDED = [
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   			[ "", "", "","", "", "" ],
			  	   		];
			colHeaderData = [
				     			{data: "common name", type: 'text'},
				    			{data: "<b>InChIKey</b>", type: 'text'},
				    			{data: "composition", renderer: lightgrayRenderer},
				    			{data: "<b>concentration (&micro;g/ml)</b>", type: 'text'},
				    			{data: "exact mass", renderer: lightgrayRenderer},
				    			{data: "(M+H)+ or (M-H)-", renderer: lightgrayRenderer}
				    		]
		}
	} else {
		container_RCC_ADDED = data;
		if (isNMR) {
			colHeaderData = [
				     			{data: "common name", type: 'text'},
				    			{data: "<b>InChIKey</b>", type: 'text'},
				    			{data: "composition", renderer: lightgrayRenderer},
				    			{data: "<b>concentration (&micro;g/ml)</b>", type: 'text'}
				    		]
		} else {
			colHeaderData = [
				     			{data: "common name", type: 'text'},
				    			{data: "<b>InChIKey</b>", type: 'text'},
				    			{data: "composition", renderer: lightgrayRenderer},
				    			{data: "<b>concentration (&micro;g/ml)</b>", type: 'text'},
				    			{data: "exact mass", renderer: lightgrayRenderer},
				    			{data: "(M+H)+ or (M-H)-", renderer: lightgrayRenderer}
				    		]
		}
	}
	
	container_RCC_ADDED = document.getElementById('container_RCC_ADDED');
	hot_RCC_ADDED = new Handsontable(container_RCC_ADDED, {
		data : data_RCC_ADDED,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["common name", "<b>InChIKey</b>", "composition", "<b>concentration (&micro;g/ml)</b>", "exact mass", "(M+H)+ or (M-H)-"],
		contextMenu : false,
		columns: colHeaderData
	});
	function bindDumpButton_RCC_ADDED() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON"&& element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_RCC_ADDED = window[instance];
				console.log('data of ' + name, hot_RCC_ADDED.getData());
			}
		});
	}
	bindDumpButton_RCC_ADDED();
	$("#container_RCC_ADDED table.htCore").css("width","100%");
	// celect cell
	hot_RCC_ADDED.selectCell(0,0);
	// add select listener
	hot_RCC_ADDED.addHook('afterSelection', hookSelection);
	// 
	
}

/**
 * 
 * @param r
 * @param c
 * @returns
 */
function hookSelection(r, c) {
// 	console.log("select!" + r + ":" + c);
// 	console.log(this);
	// display modalbox
	if (c == 0 || c == 1 || c == 2) 
		pickChemicalCompound4Mix(r);
};

// // all 
// $(".handsontable table.htCore").css("width","100%");

/**
 * reset only nmr peak lists
 */
function resetNMRpeaks() {
	$("#container_NMR_H_Peaks").html("");
	$("#container_NMR_Hsat_Peaks").html("");
	$("#container_NMR_C_Peaks").html("");
	$("#container_NMR_Multi_Peaks").html("");
	$("#container_NMR_C_Multi_Peaks").html("");
	$("#container_NMR_2DHC_Peaks").html("");
	$("#container_NMR_2DHH_Peaks").html("");
	$("#container_NMR_JRES_Peaks").html("");
}

// init json obj to submit form
var jsonSpectrumType = null;
var isJsonSpectrumTypeComplete = false;

var jsonSample = null;
var isJsonSampleComplete = false;
var isJsonRCCaddedComplete = false;

var jsonChromato = null;
var isJsonChromatoComplete = false;

var jsonAnalyzer = null;
var isJsonAnalyzerComplete = false;

var jsonPeaksList = [];
var isJsonPeaksListComplete = false;

var jsonOtherMetadata = null;
var isJsonOtherMetadataComplete = false;

// other spec ms
var jsonMolIonization = null;

var cptPeakListTab = 0;
var jsonAnalyzerAcquisition = [];

var idMetadataMap = {};
var listOfViewableSpectra = [];


$('#add1spectrum-analyzserNMR-programm').focus(function(){
	this.selectionStart = this.selectionEnd = this.value.length;
});

/**
 * post form
 */
postOneSpectrumFrom = function() {
	// I - lock form
// 	// I.A - lock other metadata field
// 	$("#add1spectrum-other-author").prop("disabled", true);
// 	$("#add1spectrum-other-validator").prop("disabled", true);
// 	$("#add1spectrum-other-date").prop("disabled", true);
// 	$("#add1spectrum-other-owner").prop("disabled", true);
// 	$("#add1spectrum-other-fileName").prop("disabled", true);
// 	$("#add1spectrum-other-fileSize").prop("disabled", true);
	// I.B - show ajax progress bare (start browser client side huge compute)
	$("#import1SpectrumLoadingBare").show();
	if (!$("#btnSwitch-gotoStep6").hasClass("btn-disabled"))
		$("#btnSwitch-gotoStep6").addClass("btn-disabled");
	if ($("#btnSwitch-gotoStep6").hasClass("btn-primary"))
		$("#btnSwitch-gotoStep6").removeClass("btn-primary");
	$("#btnSwitch-gotoStep6").prop("disabled", true);
	
// 	if (!$("#btnSwitch-gotoStep7").hasClass("btn-disabled"))
// 		$("#btnSwitch-gotoStep7").addClass("btn-disabled");
// 	if ($("#btnSwitch-gotoStep7").hasClass("btn-primary"))
// 		$("#btnSwitch-gotoStep7").removeClass("btn-primary");
// 	$("#btnSwitch-gotoStep7").prop("disabled", true);
	
	if ($("#step5sign").hasClass("fa-question-circle"))
		$("#step5sign").removeClass("fa-question-circle").addClass("fa-spinner fa-spin");
	if ($("#step5sign").hasClass("fa-check-circle"))
		$("#step5sign").removeClass("fa-check-circle").addClass("fa-spinner fa-spin");
	
	// II - form data -> json object
	loadFomDataIntoJsonObjects();
	// II.A - check if json object complete
	var alertMsg = getFormErrorMessage();
	
	if (alertMsg != "") {
		$("#alertBoxSubmitSpectrum").html(alertMsg);
		$("#import1SpectrumLoadingBare").hide();
		return false;	
	} else {
		// all OK: lock!
		// lock sample
		$(".add1spectrum-sampleForm").prop("disabled", true);
		// lock chromato
		$(".add1spectrum-chromatoLCForm").prop("disabled", true);
		if (!$('#container_LC_SFG').is(':empty'))
			hot_LC_SFG.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_MS_Peaks').is(':empty'))
			hot_MS_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_H_Peaks').is(':empty'))
			hot_NMR_H_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_Hsat_Peaks').is(':empty'))
			hot_NMR_Hsat_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_C_Peaks').is(':empty'))
			hot_NMR_C_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_Multi_Peaks').is(':empty'))
			hot_NMR_Multi_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_C_Multi_Peaks').is(':empty'))
			hot_NMR_C_Multi_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_2DHC_Peaks').is(':empty'))
			hot_NMR_2DHC_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_2DHH_Peaks').is(':empty'))
			hot_NMR_2DHH_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_NMR_JRES_Peaks').is(':empty'))
			hot_NMR_JRES_Peaks.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
		if (!$('#container_RCC_ADDED').is(':empty')) {
			hot_RCC_ADDED.updateSettings({
				cells: function (row, col, prop) {
					var cellProperties = {};
					cellProperties.readOnly = true;
					return cellProperties;
				}
			});
			hot_RCC_ADDED.removeHook('afterSelection', hookSelection);
		}

		// lock analyzer
		$(".add1spectrum-analyzerMSForm").prop("disabled", true);
		$(".add1spectrum-analyzerNMRForm-lock").prop("disabled", true);
		$(".add1spectrum-analyzserNMR-programm-peaklist").prop("disabled", true);
		$(".add1spectrum-analyzserNMR-programm-processing").prop("disabled", true);
		// lock other metadata field
		$(".add1spectrum-otherForm").prop("disabled", true);
		// lock switch btn
		$("#btnSwitch-gotoStep2").prop("disabled", true);
		$("#btnSwitch-gotoStep3-lc").prop("disabled", true);
		$("#btnSwitch-gotoStep4-ms").prop("disabled", true);
		$("#btnSwitch-gotoStep4-nmr").prop("disabled", true);
		$("#btnSwitch-gotoStep5-nmr").prop("disabled", true);
	}
	
	// II.B - rebuild json full object (with all metadata or just id if already in base)
	var jsonData = gatherJsonObjects();
	
	// II.C - add id metadata (if exist)
	jsonData["metadata_map"] = idMetadataMap;
	
	// III - post json object
	// III.A - success
	$.ajax({
		type: "post",
		url: "addOneSpectrum",
		data:  JSON.stringify(jsonData), // json,
		contentType: 'application/json',
		success: function(data) {
			if(data.success) { 
				idMetadataMap = data.idMetadataMap;
				if (data["spectra-nmr-fail"].length === 0 && data["spectra-lcms-fail"].length === 0) {
					if (isNMR) {
						$("#btnSwitch-returntoStep3").attr("onclick","switchToStep(3)");
						$("#add1spectrum-analyzserNMR-programm").focus();
						if ($("#add1spectrum-analyzserNMR-programm").parent().hasClass("has-success"))
							$("#add1spectrum-analyzserNMR-programm").parent().removeClass("has-success");
						if ($("#add1spectrum-analyzserNMR-programm").parent().hasClass("has-warning"))
							$("#add1spectrum-analyzserNMR-programm").parent().removeClass("has-warning");
						if (!$("#add1spectrum-analyzserNMR-programm").parent().hasClass("has-error"))
							$("#add1spectrum-analyzserNMR-programm").parent().addClass("has-error");
						// clear grid
						//resetNMRpeaks();
						if (data["spectra-nmr-success"].length===1)
							listOfViewableSpectra.push(data["spectra-nmr-success"][0]);
					} else if (isMS) {
						$("#btnSwitch-returntoStep3").attr("onclick", "switchToStep(4)");
						// clear grid
						//handsontableMSpeaks(null);
						isMSpeaksInit = false;
						if (data["spectra-lcms-success"].length===1)
							listOfViewableSpectra.push(data["spectra-lcms-success"][0]);
					}
					var idsV = '';
					$.each(listOfViewableSpectra, function(k,v) {
						if (idsV!='')
							idsV += '-';
						idsV += '' + v;
					});
					$("#btnSwitch-view").attr("href", "show-spectra-modal/" + idsV);
					$("#import1SpectrumResults").show();
				} else {
	 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
	 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
	 				alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to add spectrum!';
	 				alert += ' </div>';
	 				$("#alertBoxSubmitSpectrum").html(alert);
				}
			} else {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to add spectrum!';
				alert += ' </div>';
				$("#alertBoxSubmitSpectrum").html(alert);
// 				console.log(data);
			}
		}, 
		error : function(data) {
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to add spectrum!';
			alert += ' </div>';
			$("#alertBoxSubmitSpectrum").html(alert);
// 			console.log(data);
		}
	}).always(function() {
		if ($("#step5sign").hasClass("fa-question-circle"))
			$("#step5sign").removeClass("fa-question-circle").addClass("fa-check-circle");
		if ($("#step5sign").hasClass("fa-spinner"))
			$("#step5sign").removeClass("fa-spinner fa-spin").addClass("fa-check-circle");
		$("#import1SpectrumLoadingBare").hide();
	});
	return true;
}

/**
 * load form data into json objects
 */
loadFomDataIntoJsonObjects = function () {
	// I - Spectrum type
	isJsonSpectrumTypeComplete = false;
	if (isGC && isMS)
		jsonSpectrumType = "gc-ms";
	else if (isLC && isMS)
		jsonSpectrumType = "lc-ms";
	else if (isNMR)
		jsonSpectrumType = "nmr";
	if (jsonSpectrumType != null && jsonSpectrumType != "")
		isJsonSpectrumTypeComplete = true;
	
	// II - Sample
	isJsonSampleComplete = true;
	isJsonRCCaddedComplete = true;
	jsonSample = {};
	if (isNMR) {
		$.each($(".add1spectrum-sampleForm-nmr").parent(), function(){
			if ($(this).hasClass("has-error"))
				isJsonSampleComplete = false;
		});
		if (!isJsonSampleComplete)
			return false;
		jsonSample["nmr_tube_prep"] = {};
		jsonSample.nmr_tube_prep.solvent = $("#add1spectrum-sample-nmrSolvent").val();
		jsonSample.nmr_tube_prep.pH = $("#add1spectrum-sample-nmrpH").val();
		jsonSample.nmr_tube_prep.referenceChemicalShifIndicatort = $("#add1spectrum-sample-nmrReferenceChemicalShifIndicatort").val();
		jsonSample.nmr_tube_prep.referenceChemicalShifIndicatortOther = $("#add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther").val();
		jsonSample.nmr_tube_prep.referenceConcentration = $("#add1spectrum-sample-nmrReferenceConcentration").val();
		jsonSample.nmr_tube_prep.lockSubstance = $("#add1spectrum-sample-nmrLockSubstance").val();
		jsonSample.nmr_tube_prep.lockSubstanceConcentration = $("#add1spectrum-sample-nmrLockSubstanceConcentration").val();
		jsonSample.nmr_tube_prep.bufferSolution = $("#add1spectrum-sample-nmrBufferSolution").val();
		jsonSample.nmr_tube_prep.bufferSolutionConcentration = $("#add1spectrum-sample-nmrBufferSolutionConcentration").val();
		jsonSample.nmr_tube_prep.nmrIsotopicLabellingD = $("#add1spectrum-sample-nmrIsotopicLabellingD").val();
		jsonSample.nmr_tube_prep.nmrIsotopicLabelling13C = $("#add1spectrum-sample-nmrIsotopicLabelling13C").val();
		jsonSample.nmr_tube_prep.nmrIsotopicLabelling15N = $("#add1spectrum-sample-nmrIsotopicLabelling15N").val();
	}
	switch($("#add1spectrum-sample-type").val()) {
	// II.A - chemical lib. compound
	case "compound-ref":
		if ($("#add1spectrum-sample-inchikey").val()=="") {
			return false;
		}
		jsonSample["sample_type"] = "reference-chemical-compound"; // -from-library
		jsonSample["compound_inchikey"] = $("#add1spectrum-sample-inchikey").val();
		jsonSample["compound_concentration"] = $("#add1spectrum-sample-concentration").val();
		if (isMS)
			jsonSample["compound_ms_solvent"] = $("#add1spectrum-sample-lcmsSolvent").val();
		jsonSample["compound_inchi"] = $("#add1spectrum-sample-inchi").val();
		jsonSample["compound_common_name"] = $("#add1spectrum-sample-commonName").val();
		isJsonSampleComplete = true;
		break;
		// II.B - chemical lib. compound mix
	case "compound-mix": 
		jsonSample["sample_type"] = "mix-chemical-compound";
		// solvent
		jsonSample["compounds_solvent"] = $("#add1spectrum-sample-mixSolvent").val();
		// cpd added
		jsonSample.rcc_added = getRCCADDED();
		if (jsonSample.rcc_added.length==0) {
			isJsonRCCaddedComplete = false;
			return false;
		}
		isJsonSampleComplete = true;
		break;
		// II.C - std matrix
	case "matrix-ref":
		jsonSample["sample_type"] = "standardized-matrix";
		// matrix type
		jsonSample["matrix_type"] = $("#add1spectrum-sample-stdMatrix").val();
		// cpd added
		jsonSample.rcc_added = getRCCADDED();
// 		if (jsonSample.rcc_added.length==0) {
// 			isJsonRCCaddedComplete = false;
// 			return false;
// 		}
		isJsonSampleComplete = true;
		break;
		// II.D - bio matrix
	case "matrix-bio":
		jsonSample["sample_type"] = "analytical-matrix";
		// TODO get source and type
		break;
	default:
		return false;
	}

	// III - Chromato
	isJsonChromatoComplete = true;
	jsonChromato = {};
	
	// III.A - no chromato
	// nope?

	// III.B - GC	
	if (isGC) {
		isJsonChromatoComplete = false;
		// TODO
	}
	
	// III.C - LC
	if (isLC) {
		isJsonChromatoComplete = true;
		jsonChromato = {};
		jsonChromato["lc_chromatography"] = {}
		// check error
		$.each($(".add1spectrum-chromatoLCForm").parent(), function(){
			if ($(this).hasClass("has-error"))
				isJsonChromatoComplete = false;
		});
		if (!isJsonChromatoComplete)
			return false;
		// fulfill json object
		jsonChromato["method"] = $("#add1spectrum-chromatoLC-method option:selected").text();
		jsonChromato["column_constructor"] = $("#add1spectrum-chromatoLC-colConstructor").val();
		jsonChromato["column_constructor_other"] = $("#add1spectrum-chromatoLC-colConstructorOther").val();
		jsonChromato["column_name"] = $("#add1spectrum-chromatoLC-colName").val();
		jsonChromato["column_length"] = $("#add1spectrum-chromatoLC-colLength").val();
		jsonChromato["column_diameter"] = $("#add1spectrum-chromatoLC-colDiameter").val();
		jsonChromato["particule_size"] = $("#add1spectrum-chromatoLC-colParticuleSize").val();
		jsonChromato["column_temperature"] = $("#add1spectrum-chromatoLC-colTemperature").val();
		jsonChromato["LC_mode"] = $("#add1spectrum-chromatoLC-LCMode").val();
		jsonChromato["separation_flow_rate"] = $("#add1spectrum-chromatoLC-separationFlowRate").val();
		jsonChromato["separation_solvent_a"] = $("#add1spectrum-chromatoLC-separationSolvA").val();
		jsonChromato["ph_solvent_a"] = $("#add1spectrum-chromatoLC-separationSolvApH").val();
		jsonChromato["separation_solvent_b"] = $("#add1spectrum-chromatoLC-separationSolvB").val();
		jsonChromato["ph_solvent_b"] = $("#add1spectrum-chromatoLC-separationSolvBApH").val();
		
		// separation_flow_gradient
		jsonSFG = [];
		$.each(hot_LC_SFG.getData(), function(){
			var formatData = {};
			if (this[0]!="") {
				if (!isNaN(this[0]) && !isNaN(this[1]) && !isNaN(this[2])) {
					formatData['time'] = Number(this[0]);
					formatData['solvA'] = Number(this[1]);
					formatData['solvB'] = Number(this[2]);
					jsonSFG.push(formatData);
				}
			}
		});
		jsonChromato.separation_flow_gradient = jsonSFG;
	}
	
	// IV - Analyzer
	isJsonAnalyzerComplete = true;
	isJsonAnalyzer = {};
	// IV.A - MS
	if (isMS) {
		isJsonAnalyzerComplete = true;
		jsonAnalyzer = {};
		// check error
		$.each($(".add1spectrum-analyzerMSForm").parent(), function(){
			if ($(this).hasClass("has-error"))
				isJsonAnalyzerComplete = false;
		});
		if (!isJsonAnalyzerComplete)
			return false;
		
		// fulfill json object
		jsonAnalyzer["instrument"] = $("#add1spectrum-analyzer-ms-instrument").val();
		jsonAnalyzer["model"] = $("#add1spectrum-analyzer-ms-model").val();
// 		jsonAnalyzer["resolution_FWHM"] = $("#add1spectrum-analyzer-ms-resolutionFWHM").val();
		jsonAnalyzer["ion_analyzer_type"] = $("#add1spectrum-analyzer-ms-ionAnalyzerType").val();
// 		jsonAnalyzer["detector"] = $("#add1spectrum-analyzer-ms-detector").val();
// 		jsonAnalyzer["detection_protocol"] = $("#add1spectrum-analyzer-ms-detectionProtocol").val();
		
		jsonMolIonization = {};
		var jsonModePos = {};
		var jsonModeNeg = {};
		
		jsonModePos["ionisation_method"] = $("#add1spectrum-analyzserMS-ionizationMethod-pos").val();
		jsonModePos["spray_gaz_flow"] = $("#add1spectrum-analyzserMS-sprayGazFlow-pos").val();
		jsonModePos["vaporizer_gaz_flow"] = $("#add1spectrum-analyzserMS-vaporizerGazFlow-pos").val();
		jsonModePos["vaporizer_temperature"] = $("#add1spectrum-analyzserMS-vaporizerTemperature-pos").val();
		jsonModePos["source_gaz_flow"] = $("#add1spectrum-analyzserMS-sourceGazFlow-pos").val();
		jsonModePos["tube_temperature"] = $("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-pos").val();
		jsonModePos["voltage"] = $("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-pos").val();
		
		jsonModeNeg["ionisation_method"] = $("#add1spectrum-analyzserMS-ionizationMethod-neg").val();
		jsonModeNeg["spray_gaz_flow"] = $("#add1spectrum-analyzserMS-sprayGazFlow-neg").val();
		jsonModeNeg["vaporizer_gaz_flow"] = $("#add1spectrum-analyzserMS-vaporizerGazFlow-neg").val();
		jsonModeNeg["vaporizer_temperature"] = $("#add1spectrum-analyzserMS-vaporizerTemperature-neg").val();
		jsonModeNeg["source_gaz_flow"] = $("#add1spectrum-analyzserMS-sourceGazFlow-neg").val();
		jsonModeNeg["tube_temperature"] = $("#add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-neg").val();
		jsonModeNeg["voltage"] = $("#add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-neg").val();

		jsonMolIonization["mode_pos"] = jsonModePos;
		jsonMolIonization["mode_neg"] = jsonModeNeg;
	} // isMS
	
	// IV.B - NMR
	var isNMRprot = false;
	var isNMRcarbo = false;
	var isNMR_2d_jres = false;
	var isNMR_2d_hh = false;
	var isNMR_2d_hc = false;
	// TODO other tech.
	if (isNMR) {
		isJsonAnalyzerComplete = true;
		jsonAnalyzer = {};
		// check error
		$.each($(".add1spectrum-analyzerNMRForm-lock").parent(), function(){
			if ($(this).hasClass("has-error"))
				isJsonAnalyzerComplete = false;
		});
		if (!isJsonAnalyzerComplete)
			return false;
		
		// fulfill json object
		jsonAnalyzer["instrument_name"] = $("#add1spectrum-analyzer-nmr-instrument-name").val();
		jsonAnalyzer["magnetic_field_strength"] = ($("#add1spectrum-analyzer-nmr-instrument-magneticFieldStrength").val());
		jsonAnalyzer["software_version"] = $("#add1spectrum-analyzer-nmr-instrument-software").val();
		jsonAnalyzer["nmr_probe"] = $("#add1spectrum-analyzer-nmr-instrument-probe").val();
		if ($("#add1spectrum-analyzer-nmr-instrument-cellOrTube").val()=="cell")
			jsonAnalyzer["is_cell"] = true;
		else
			jsonAnalyzer["is_cell"] = false;
		jsonAnalyzer["flow_cell_volume"] = $("#add1spectrum-analyzer-nmr-instrument-flowCellVolume").val();
		jsonAnalyzer["nmr_tube_diameter"] = $("#add1spectrum-analyzer-nmr-instrument-tube").val();
		
		// fullfill peaklist acq param
		jsonAnalyzerAcquisition[cptPeakListTab] = {};
		var newACQ = {};
		switch($("#add1spectrum-analyzserNMR-programm").val()) {
		case 'proton': 
		case 'proton-1d': 
		case 'noesy-1d': 
		case 'cpmg-1d':
			isNMRprot = true;
			break;
		case 'carbon13-1d': 
			isNMRcarbo = true;
			break;
		case 'JRES-2d':
			isNMR_2d_jres = true;
			break;
		case 'HSQC-2d':
		case 'HMBC-2d':
			isNMR_2d_hc = true;
			break;
		case 'COSY-2d':
		case 'TOCSY-2d':
		case 'NOESY-2d':
			isNMR_2d_hh = true;
			break;
		default:
			break;
		}
		// 1D and 2D
		newACQ['programm'] = $("#add1spectrum-analyzserNMR-programm").val();
		newACQ['PULPROG'] = $("#add1spectrum-analyzserNMR-programm-PULPROG").val();
		newACQ['TE'] = $("#add1spectrum-analyzserNMR-programm-TE").val();
		newACQ['DS'] = $("#add1spectrum-analyzserNMR-programm-DS").val();
		// 1D only
		if (isNMRprot ||isNMRcarbo) {
			newACQ['F1'] = $("#add1spectrum-analyzserNMR-programm-F1").val();
			newACQ['TD'] = $("#add1spectrum-analyzserNMR-programm-TD").val();
			newACQ['NS'] = $("#add1spectrum-analyzserNMR-programm-NS").val();
			newACQ['SW'] = $("#add1spectrum-analyzserNMR-programm-SW").val();
			newACQ['D8'] = $("#add1spectrum-analyzserNMR-programm-D8").val();//mixing time
			// MISSING Spin-echo delay (µs)  // add1spectrum-analyzserNMR-programm-spinEchoDelay
			newACQ['sed'] = $("#add1spectrum-analyzserNMR-programm-spinEchoDelay").val();//spinEchoDelay
			newACQ['nol'] = $("#add1spectrum-analyzserNMR-programm-numberOfLoops").val();//numberOfLoops
			newACQ['dt'] = $("#add1spectrum-analyzserNMR-programm-decouplingType").val();//decouplingType
			newACQ['processing-fourier-transform'] = $("#add1spectrum-analyzer-nmr-processing-fourierTransfo").val();
			newACQ['processing-si'] = $("#add1spectrum-analyzer-nmr-processing-si").val();
			newACQ['processing-line-broadening'] = $("#add1spectrum-analyzer-nmr-processing-lineBroadening").val();
		}
		// 2D only
		else if (isNMR_2d_hh || isNMR_2d_hc || isNMR_2d_jres) {
			// aq
			newACQ['F1'] = $("#add1spectrum-analyzserNMR-programm-F1").val();
			newACQ['TD1'] = $("#add1spectrum-analyzserNMR-programm-TD1").val();
			newACQ['TD2'] = $("#add1spectrum-analyzserNMR-programm-TD2").val();
			newACQ['NS'] = $("#add1spectrum-analyzserNMR-programm-NSf2").val();
			newACQ['AQ'] = $("#add1spectrum-analyzserNMR-programm-aq2d").val();
			if ($("#add1spectrum-analyzserNMR-programm-aq2df1").val() != "") { newACQ['AQ'] = $("#add1spectrum-analyzserNMR-programm-aq2df1").val(); }
			newACQ['D8'] = $("#add1spectrum-analyzserNMR-programm-D8-noesy2d").val();
			if ($("#add1spectrum-analyzserNMR-programm-D8").val() != "") { newACQ['D8'] = $("#add1spectrum-analyzserNMR-programm-D8").val(); } // TOCSY!
			newACQ['SWF1'] = $("#add1spectrum-analyzserNMR-programm-SWf1").val();
			newACQ['SWF2'] = $("#add1spectrum-analyzserNMR-programm-SWf2").val();
			if ($("#add1spectrum-analyzserNMR-programm-SW1h").val() != "") { newACQ['SWF1'] = $("#add1spectrum-analyzserNMR-programm-SW1h").val(); }
			if ($("#add1spectrum-analyzserNMR-programm-SWc").val() != "")  { newACQ['SWF2'] = $("#add1spectrum-analyzserNMR-programm-SWc").val(); }
			newACQ['DECOUP'] = $("#add1spectrum-analyzserNMR-programm-decouplageType").val();
			newACQ['JXH'] = $("#add1spectrum-analyzserNMR-programm-JXH").val();
			if ($("#add1spectrum-analyzserNMR-programm-JXH-lr").val() != "")  { newACQ['JXH'] = $("#add1spectrum-analyzserNMR-programm-JXH-lr").val(); }
			newACQ['NUS'] = $("#add1spectrum-analyzserNMR-programm-nus").val();
			newACQ['NUSA'] = $("#add1spectrum-analyzserNMR-programm-nus-amount").val();
			newACQ['NUSP'] = $("#add1spectrum-analyzserNMR-programm-nus-points").val();
			// prorcessing
			newACQ['processing-fourier-transform'] = $("#add1spectrum-analyzer-nmr-processing-fourierTransfo-2d").val();
			newACQ['processing-tilt'] = $("#add1spectrum-analyzer-nmr-processing-tilt").val();
			newACQ['processing-si-f1'] = $("#add1spectrum-analyzer-nmr-processing-SIf1").val();
			newACQ['processing-si-f2'] = $("#add1spectrum-analyzer-nmr-processing-SIf2").val();
			newACQ['processing-winfn-f1'] = $("#add1spectrum-analyzer-nmr-processing-windowFunctionF1").val();
			newACQ['processing-winfn-f2'] = $("#add1spectrum-analyzer-nmr-processing-windowFunctionF2").val();
			newACQ['processing-line-broadening-f1'] = $("#add1spectrum-analyzer-nmr-processing-lineBroadeningF1").val();
			newACQ['processing-line-broadening-f2'] = $("#add1spectrum-analyzer-nmr-processing-lineBroadeningF2").val();
			newACQ['processing-ssb-f1'] = $("#add1spectrum-analyzer-nmr-processing-ssbF1").val();
			newACQ['processing-ssb-f2'] = $("#add1spectrum-analyzer-nmr-processing-ssbF2").val();
			newACQ['processing-gb-f1'] = $("#add1spectrum-analyzer-nmr-processing-gbF1").val();
			newACQ['processing-gb-f2'] = $("#add1spectrum-analyzer-nmr-processing-gbF2").val();
			newACQ['processing-peakPicking'] = $("#add1spectrum-analyzer-nmr-processing-peakPicking").val();
			newACQ['processing-symmetrize'] = $("#add1spectrum-analyzer-nmr-processing-symmetrize").val();
			newACQ['processing-nusParameter'] = $("#add1spectrum-analyzer-nmr-processing-nusProcessingParameter").val();
		}

		// missing data in v 0.1
		jsonAnalyzerAcquisition[cptPeakListTab] = newACQ;
		jsonAnalyzer["acquisition"] = jsonAnalyzerAcquisition;

		
	}//isNMR

	// V - peaklists
	isJsonPeaksListComplete = false;
	// V.A - MS
	// V.A.1 - MS fullscan
	if (isMS) {
		// init
		var peaklist = [];
		var peakdata = {};
		var spectrumData = {};
		// peaklist
		$.each(hot_MS_Peaks.getData(), function(){
			var formatData = {};
			if (this[0]!="") {
				if (!isNaN(this[0]) && !isNaN(this[2])) {
					formatData["mz"] = Number(this[0]);
					formatData["RI"] = Number(this[2]);
					formatData["theoMass"] = Number(this[3]);
					formatData["deltaPPM"] = Number(this[4]);
					formatData["composition"] = (this[5]);
					formatData["attribution"] = (this[6]);
					peaklist.push(formatData);
					isJsonPeaksListComplete = true;
				}
			}
		});
		// peak list data
		peakdata["ms_lvl"] = $("#add1spectrum-peaksMS-msLevel").val();
		peakdata["polarity"] = $("#add1spectrum-peaksMS-polarity").val();
		peakdata["resolution"] = $("#add1spectrum-peaksMS-resolution").val();
		peakdata["mz_range_from"] = $("#add1spectrum-peaksMS-rangeFrom").val();
		peakdata["mz_range_to"] = $("#add1spectrum-peaksMS-rangeTo").val();
		peakdata["rt_abs_from"] = $("#add1spectrum-peaksMS-rtMinFrom").val();
		peakdata["rt_abs_to"] = $("#add1spectrum-peaksMS-rtMinTo").val();
		peakdata["rt_solv_from"] = $("#add1spectrum-peaksMS-rtSolvFrom").val();
		peakdata["rt_solv_to"] = $("#add1spectrum-peaksMS-rtSolvTo").val();
		peakdata["resolution_FWHM"] = $("#add1spectrum-analyzer-ms-resolutionFWHM").val();
		// gather
		spectrumData["peakdata"] = peakdata;
		spectrumData["peaklist"] = peaklist;
		jsonPeaksList[cptPeakListTab] = spectrumData;
	}// isMS
	
	// V.A.2 - MSMS (frag)
	// V.B - NMR
	if (isNMR) {
		//////////////
		if (isNMRprot) {
			currentNMRpeakListMapper = {};
			// peaklist
			var peaklist = [];
			$.each(hot_NMR_H_Peaks.getData(), function(){
			var formatData = {};
				if (this["ν (F1) [ppm]"]!="") {
					if (!isNaN(this["ν (F1) [ppm]"]) && !isNaN(this["intensity [rel]"])) {
						// peak index
						if(typeof this["peak index"] !== 'undefined')
							formatData['peak_index'] = Number(this["peak index"]) + "";
						// region
						if(typeof this["region"] !== 'undefined')
							formatData['region'] = Number(this["region"]) + "";
						// index (F1)
						if(typeof this["index (F1)"] !== 'undefined')
							formatData['index_F1'] = Number(this["index (F1)"]) + "";
						// ν (F1) [ppm]
						if(typeof this["ν (F1) [ppm]"] !== 'undefined')
							formatData['f1'] = Number(this["ν (F1) [ppm]"]) + "";
						// ν (F1) [Hz]
						// intensity [abs]
						// intensity [rel]
						if(typeof this["intensity [rel]"] !== 'undefined')
							formatData['intensity'] = Number(this["intensity [rel]"]) + "";
						// half width [ppm]
						if(typeof this["half width [ppm]"] !== 'undefined')
						formatData['half_width'] = Number(this["half width [ppm]"]) + "";
						// half width [Hz]
						if(typeof this["half width [Hz]"] !== 'undefined')
							formatData['half_width_hz'] = Number(this["half width [Hz]"]) + "";
						// annotation
						if(typeof this["annotation"] !== 'undefined')
							formatData['annotation'] = (this["annotation"]) + "";
						// wtf is this?
						formatData['type'] = "1";
						peaklist.push(formatData);
						isJsonPeaksListComplete = true;
					}
				}
			});
			currentNMRpeakListMapper["peaklist"] = peaklist;
			// peaklist + sat
			var peaklistsat = [];
			$.each(hot_NMR_Hsat_Peaks.getData(), function(){
				var formatData = {};
				if (this["ν (F1) [ppm]"]!="") {
					if (!isNaN(this["ν (F1) [ppm]"]) && !isNaN(this["intensity [rel]"])) {
						// peak index
						if(typeof this["peak index"] !== 'undefined')
							formatData['peak_index'] = Number(this["peak index"]) + "";
						// region
						if(typeof this["region"] !== 'undefined')
							formatData['region'] = Number(this["region"]) + "";
						// index (F1)
						if(typeof this["index (F1)"] !== 'undefined')
							formatData['index_F1'] = Number(this["index (F1)"]) + "";
						// ν (F1) [ppm]
						if(typeof this["ν (F1) [ppm]"] !== 'undefined')
							formatData['f1'] = Number(this["ν (F1) [ppm]"]) + "";
						// ν (F1) [Hz]
						// intensity [abs]
						// intensity [rel]
						if(typeof this["intensity [rel]"] !== 'undefined')
							formatData['intensity'] = Number(this["intensity [rel]"]) + "";
						// half width [ppm]
						if(typeof this["half width [ppm]"] !== 'undefined')
							formatData['half_width'] = Number(this["half width [ppm]"]) + "";
						// half width [Hz]
						if(typeof this["half width [Hz]"] !== 'undefined')
							formatData['half_width_hz'] = Number(this["half width [Hz]"]) + "";
						// annotation
						if(typeof this["annotation"] !== 'undefined')
							formatData['annotation'] = (this["annotation"]) + "";
						// wtf is this?
						formatData['type'] = "1";
						peaklistsat.push(formatData);
					}
				}
			});
			if (peaklistsat.length>0)
				currentNMRpeakListMapper["peaklist"] = peaklistsat;
			// multi
			var patternlist = [];
			$.each(hot_NMR_Multi_Peaks.getData(), function(){
				var formatData = {};
				if (this["ν (F1) [ppm]"]!="") {
					// {peaks: [{f1: "5.2416", annotation: "H1a", intensity: "1.57", type: "1"},…], chemicalShift: 5.2378,…}
					// type: "d"
					// chemicalShift: 5.2378
					if (!isNaN(this["ν (F1) [ppm]"])) {
						// ν (F1) [ppm]
						if(typeof this["ν (F1) [ppm]"] !== 'undefined')
							formatData['chemicalShift'] = Number(this['ν (F1) [ppm]']) + "";
						// H's
						if(typeof this["H's"] !== 'undefined')
							formatData['H_or_C'] = (this["H's"]) + "";
						// type
						if(typeof this["type"] !== 'undefined')
							formatData['type'] = (this["type"]) + "";
						// J(Hz)
						if(typeof this["J(Hz)"] !== 'undefined')
							formatData['J'] = (this["J(Hz)"]) + "";
						// range (ppm)
						if(typeof this["range (ppm)"] !== 'undefined')
							formatData['range'] = (this["range (ppm)"]) + "";
						// atoms
						if(typeof this["atoms"] !== 'undefined')
							formatData['atoms'] = (this["atoms"]) + "";
						// MSI level
						if(typeof this["MSI level"] !== 'undefined')
							formatData['msi'] = (this["MSI level"]) + "";
						patternlist.push(formatData);
					}
				}
			});
			currentNMRpeakListMapper["patternlist"] = patternlist;
			// put all in
			jsonPeaksList[cptPeakListTab] = currentNMRpeakListMapper;
		} else if (isNMRcarbo) {
			currentNMRpeakListMapper = {};
			// peaklist
			var peaklist = [];
			$.each(hot_NMR_C_Peaks.getData(), function(){
			var formatData = {};
				if (this["ν (F1) [ppm]"]!="") {
					if (!isNaN(this["ν (F1) [ppm]"]) && !isNaN(this["intensity [rel]"])) {
						// peak index
						if(typeof this["peak index"] !== 'undefined')
							formatData['peak_index'] = Number(this["peak index"]) + "";
						// region
						if(typeof this["region"] !== 'undefined')
							formatData['region'] = Number(this["region"]) + "";
						// index (F1)
						if(typeof this["index (F1)"] !== 'undefined')
							formatData['index_F1'] = Number(this["index (F1)"]) + "";
						// ν (F1) [ppm]
						if(typeof this["ν (F1) [ppm]"] !== 'undefined')
							formatData['f1'] = Number(this["ν (F1) [ppm]"]) + "";
						// ν (F1) [Hz]
						// intensity [abs]
						// intensity [rel]
						if(typeof this["intensity [rel]"] !== 'undefined')
							formatData['intensity'] = Number(this["intensity [rel]"]) + "";
						// half width [ppm]
						if(typeof this["half width [ppm]"] !== 'undefined')
						formatData['half_width'] = Number(this["half width [ppm]"]) + "";
						// half width [Hz]
						if(typeof this["half width [Hz]"] !== 'undefined')
							formatData['half_width_hz'] = Number(this["half width [Hz]"]) + "";
						// annotation
						if(typeof this["annotation"] !== 'undefined')
							formatData['annotation'] = (this["annotation"]) + "";
						// wtf is this?
						formatData['type'] = "1";
						peaklist.push(formatData);
						isJsonPeaksListComplete = true;
					}
				}
			});
			currentNMRpeakListMapper["peaklist"] = peaklist;
			// multi
			var patternlist = [];
			$.each(hot_NMR_C_Multi_Peaks.getData(), function(){
				var formatData = {};
				if (this["ν (F1) [ppm]"]!="") {
					// {peaks: [{f1: "5.2416", annotation: "H1a", intensity: "1.57", type: "1"},…], chemicalShift: 5.2378,…}
					// type: "d"
					// chemicalShift: 5.2378
					if (!isNaN(this["ν (F1) [ppm]"])) {
						// ν (F1) [ppm]
						if(typeof this["ν (F1) [ppm]"] !== 'undefined')
							formatData['chemicalShift'] = Number(this['ν (F1) [ppm]']) + "";
						// C's
						if(typeof this["C's"] !== 'undefined')
							formatData['H_or_C'] = (this["C's"]) + "";
						// type
						if(typeof this["type"] !== 'undefined')
							formatData['type'] = (this["type"]) + "";
						// J(Hz)
						if(typeof this["J(Hz)"] !== 'undefined')
							formatData['J'] = (this["J(Hz)"]) + "";
						// range (ppm)
						if(typeof this["range (ppm)"] !== 'undefined')
							formatData['range'] = (this["range (ppm)"]) + "";
						// atoms
						if(typeof this["atoms"] !== 'undefined')
							formatData['atoms'] = (this["atoms"]) + "";
						// MSI level
						if(typeof this["MSI level"] !== 'undefined')
							formatData['msi'] = (this["MSI level"]) + "";
						patternlist.push(formatData);
					}
				}
			});
			currentNMRpeakListMapper["patternlist"] = patternlist;
			// put all in
			jsonPeaksList[cptPeakListTab] = currentNMRpeakListMapper;
		}
		// 2D methods
		else if (isNMR_2d_jres) {
			currentNMRpeakListMapper = {};
			var peaklist = [];
			$.each(hot_NMR_JRES_Peaks.getData(), function(){
				var formatData = {};
				if (this["F2_ppm"]!="") {
					if (!isNaN(this["F1_ppm"]) && !isNaN(this["F2_ppm"])) {
						if(typeof this["peak_index"] !== 'undefined')
							formatData['peak_index'] = Number(this["peak_index"]) + "";
						if(typeof this["F2_ppm"] !== 'undefined')
							formatData['f2'] = Number(this["F2_ppm"]) + "";
						if(typeof this["F1_ppm"] !== 'undefined')
							formatData['f1'] = Number(this["F1_ppm"]) + "";
						if(typeof this["intensity_rel"] !== 'undefined')
							formatData['intensity_rel'] = Number(this["intensity_rel"]) + "";
						if(typeof this["multiplicity"] !== 'undefined')
							formatData['multiplicity'] = (this["multiplicity"]) + "";
						if(typeof this["J"] !== 'undefined')
							formatData['J'] = (this["J"]) + "";
						if(typeof this["annotation"] !== 'undefined')
							formatData['annotation'] = (this["annotation"]) + "";
						peaklist.push(formatData);
						isJsonPeaksListComplete = true;
					}
				}
			});
			currentNMRpeakListMapper["peaklist-jres"] = peaklist;
			// put all in
			jsonPeaksList[cptPeakListTab] = currentNMRpeakListMapper;
		} else if (isNMR_2d_hh) {
			currentNMRpeakListMapper = {};
			var peaklist = [];
			$.each(hot_NMR_2DHH_Peaks.getData(), function(){
				var formatData = {};
				if (this["F1_ppm"]!="") {
					if (!isNaN(this["F1_ppm"]) && !isNaN(this["F2_ppm"])) {
						if(typeof this["peak_index"] !== 'undefined')
							formatData['peak_index'] = Number(this["peak index"]) + "";
						if(typeof this["F1_ppm"] !== 'undefined')
							formatData['f1'] = Number(this["F1_ppm"]) + "";
						if(typeof this["F2_ppm"] !== 'undefined')
							formatData['f2'] = Number(this["F2_ppm"]) + "";
						if(typeof this["annotation"] !== 'undefined')
							formatData['annotation'] = (this["annotation"]) + "";
						if(typeof this["intensity_rel"] !== 'undefined')
							formatData['intensity'] = Number(this["intensity_rel"]) + "";
						if(typeof this["multiplicity"] !== 'undefined')
							formatData['multiplicity'] = (this["multiplicity"]) + "";
						if(typeof this["J"] !== 'undefined')
							formatData['J'] = (this["J"]) + "";
						peaklist.push(formatData);
						isJsonPeaksListComplete = true;
					}
				}
			});
			currentNMRpeakListMapper["peaklist-2d"] = peaklist;
			// put all in
			jsonPeaksList[cptPeakListTab] = currentNMRpeakListMapper;
		} else if (isNMR_2d_hc) {
			currentNMRpeakListMapper = {};
			var peaklist = [];
			$.each(hot_NMR_2DHC_Peaks.getData(), function(){
				var formatData = {};
				if (this["F1 (ppm)"]!="") {
					if (!isNaN(this["F1 (ppm)"]) && !isNaN(this["F2 (ppm)"])) {
						if(typeof this["peak index"] !== 'undefined')
							formatData['peak_index'] = Number(this["peak index"]) + "";
						if(typeof this["F1 (ppm)"] !== 'undefined')
							formatData['f1'] = Number(this["F1 (ppm)"]) + "";
						if(typeof this["F2 (ppm)"] !== 'undefined')
							formatData['f2'] = Number(this["F2 (ppm)"]) + "";
						if(typeof this["annotation"] !== 'undefined')
							formatData['annotation'] = (this["annotation"]) + "";
						if(typeof this["intensity (rel)"] !== 'undefined')
							formatData['intensity'] = Number(this["intensity (rel)"]) + "";
						peaklist.push(formatData);
						isJsonPeaksListComplete = true;
					}
				}
			});
			currentNMRpeakListMapper["peaklist-2d"] = peaklist;
			// put all in
			jsonPeaksList[cptPeakListTab] = currentNMRpeakListMapper;
		}
	}
	// var jsonPeaksList = null;
	// var isJsonPeaksListComplete = false;
	// VI - other metadata
	isJsonOtherMetadataComplete = true;
	jsonOtherMetadata = {};
	// check error
	$.each($(".add1spectrum-otherForm").parent(), function(){
		if ($(this).hasClass("has-error"))
			isJsonOtherMetadataComplete = false;
	});
	if (!isJsonOtherMetadataComplete)
		return false;
	// fulfill
	jsonOtherMetadata["data_authors"] =  $("#add1spectrum-other-author").val();
	jsonOtherMetadata["data_validator"] =  $("#add1spectrum-other-validator").val();;
	jsonOtherMetadata["acquisition_date"] =  $("#add1spectrum-other-date").val();
	jsonOtherMetadata["data_ownership"] =  $("#add1spectrum-other-owner").val();
	jsonOtherMetadata["raw_file_name"] =  $("#add1spectrum-other-fileName").val();
	jsonOtherMetadata["raw_file_size"] =  $("#add1spectrum-other-fileSize").val();
	return true;
}

/**
 * 
 */
function getFormErrorMessage() {
	var alertMsg = "";
	if (!isJsonSpectrumTypeComplete) {
		alertMsg = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alertMsg += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alertMsg += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Error processing spectrum type!';
		alertMsg += ' </div>';
	} else if (!isJsonSampleComplete) {
		alertMsg = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alertMsg += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alertMsg += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Missing mandatory data into sample section!';
		alertMsg += ' <br /> <a href="#" onclick="$(\'#linkActivateStep1\').trigger(\'click\');" >Go to this section</a>';
		alertMsg += ' </div>';
	} else if (!isJsonRCCaddedComplete) {
		alertMsg = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alertMsg += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alertMsg += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Pease enter at least ONE compound in mix into sample section!';
		alertMsg += ' <br /> <a href="#" onclick="$(\'#linkActivateStep1\').trigger(\'click\');" >Go to this section</a>';
		alertMsg += ' </div>';
	} // TODO chromato / ms||nmr analyzer //  
	else if (!isJsonPeaksListComplete) {
		alertMsg = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alertMsg += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alertMsg += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Missing peaklist!';
		if (isMS)
			alertMsg += ' <br /> <a href="#" onclick="$(\'#linkActivateStep4-ms\').trigger(\'click\');" >Go to this section</a>';
		else if (isNMR)
			alertMsg += ' <br /> <a href="#" onclick="$(\'#linkActivateStep4-nmr\').trigger(\'click\');" >Go to this section</a>';
		alertMsg += ' </div>';
	}
	// TODO other
	return alertMsg;
}

function gatherJsonObjects() {
	var jsonData = {};
	jsonData["dumper_type"] = jsonSpectrumType;
	jsonData["analytical_sample"] = jsonSample;
	if (isLC)
		jsonData["lc_chromatography"] = jsonChromato;
	if (isMS) {
		jsonData["ms_analyzer"] = jsonAnalyzer;
		jsonData["molecule_ionization"] = jsonMolIonization;
		jsonData["ms_peaklist"] = jsonPeaksList;
	} else if (isNMR) {
		jsonData["nmr_analyzer"] = jsonAnalyzer;
		jsonData["nmr_peaklist"] = jsonPeaksList;
		jsonData["rawFileTmpName"] = $("#rawFileTmpName").val();
	}
	jsonData['other'] = jsonOtherMetadata;
	return jsonData;
}


/**
 * dump form
 */
function dumpOneSpectrumFrom() {
	
	// I - show ajax progress bare (start browser client side huge compute)
	$("#import1SpectrumLoadingBare").show();

	// lock dump btn
	if (!$("#btnSwitch-gotoStep7").hasClass("btn-disabled"))
		$("#btnSwitch-gotoStep7").addClass("btn-disabled");
	if ($("#btnSwitch-gotoStep7").hasClass("btn-primary"))
		$("#btnSwitch-gotoStep7").removeClass("btn-primary");
	$("#btnSwitch-gotoStep7").prop("disabled", true);
	
	// reset dnl btn
	
	var eTmp = $("#btnDownloadDumpForm");
	eTmp.hide();
	eTmp.attr('href', '#');
	eTmp.html('');
	
	// II - form data -> json object
	loadFomDataIntoJsonObjects();
	// II.A - check if json object complete
	var alertMsg = getFormErrorMessage();
	
	if (alertMsg != "") {
		$("#alertBoxSubmitSpectrum").html(alertMsg);
		$("#import1SpectrumLoadingBare").hide();
		return false;	
	}
	
	// II.B - rebuild json full object (with all metadata or just id if already in base)
	var jsonData = gatherJsonObjects();
	
	// III - post json object
	// III.A - success
	$.ajax({
		type: "post",
		url: "dumpTemplate",
		data:  JSON.stringify(jsonData), // json,
		contentType: 'application/json',
		success: function(data) {
			if(data.success) { 
				eTmp.attr('href', data.fileURL);
				eTmp.html('<i class="fa fa-cloud-download"></i> ' + data.fileName);
				eTmp.show();
				// TODO reset form
				console.log(data);
			} else {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to generate file!';
				alert += ' </div>';
				$("#alertBoxSubmitSpectrum").html(alert);
				console.log(data);					
			}
		}, 
		error : function(data) {
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to generate file!';
			alert += ' </div>';
			$("#alertBoxSubmitSpectrum").html(alert);
			console.log(data);
		}
	}).always(function() {
		$("#import1SpectrumLoadingBare").hide();
		// unlock btn
		if ($("#btnSwitch-gotoStep7").hasClass("btn-disabled"))
			$("#btnSwitch-gotoStep7").removeClass("btn-disabled");
		if (!$("#btnSwitch-gotoStep7").hasClass("btn-primary"))
			$("#btnSwitch-gotoStep7").addClass("btn-primary");
		$("#btnSwitch-gotoStep7").prop("disabled", false);
	});
	return true;
}


var singlePick = true;
var multiPickLine = -1;

/**
 * 
 */
function pickChemicalCompound() {
	// reset modal
	// $("#add-one-cc-s1-value").val("");
	// init
	singlePick = true;
	// display modal
	$("#modalPickCompound").modal("show");
	$("#add-one-cc-s1-value").focus();
}

/**
 * 
 */
function pickChemicalCompound4Mix(rowNumber) {
	// init
	singlePick = false;
	multiPickLine = rowNumber;
	// display modal
	$("#modalPickCompound").modal("show");
	$("#add-one-cc-s1-value").focus();
}

// autocomplete
var subjects = [];
$(document).ready( function() {
	$('#add-one-cc-s1-value').bind('keypress', function(e) {
		var code = e.keyCode || e.which;
		if (code == 13) {
			searchLocalCompound();
		}
	});
	$('#add-one-cc-s1-value').typeahead({
		source: function (query, process) {
	        return searchAjax();
	    }
	});
	$(".pickChemicalCompound").click(function() {
		pickChemicalCompound();
	});
});

/**
 * 
 */
function searchAjax() {
	var results = [];
	var rawQuery = $('#add-one-cc-s1-value').val();
	if (rawQuery.length > 2) {
		$.ajax({ 
				type: "post",
				url: "search",
				dataType: "json",
				async: false,
				data: "query=" + $('#add-one-cc-s1-value').val(),
				success: function(json) {
					if (json.success) {
						// names
						$.each(json.compoundNames, function(){
							results.push(this.name);
						}); 
						$.each(json.compounds, function(){
							if (this.inChIKey.indexOf(rawQuery))
								results.push(this.inChIKey);
						});
					}
			},
			error : function(xhr) {
				subjects = [];
				// TODO alert error xhr.responseText
				console.log(xhr);
			}
		});
	}
	return results;
};
/**
 * 
 */
function searchLocalCompound() {
	$("#load-step-1").show();
	$.ajax({ 
		type: "post",
		url: "pick-one-compound-search",
		async: true,
		data: "query=" + $('#add-one-cc-s1-value').val() + "&filter=" + fitlerSearchLoadlCpd,
		success: function(data) {
			$("#ok-step-1").html(data);
		},
		error : function(xhr) {
			// log
			console.log(xhr);
			// error
			$("#ok-step-1").html("Error: could not process request.");
		}
	}).always(function() {
		$("#load-step-1").hide();
	});
}

/**
 * 
 */
function getRCCADDED() {
	jsonRCC_ADDED = [];
	$.each(hot_RCC_ADDED.getData(), function(){
		var formatData = {};
		if ("<b>InChIKey</b>" in this && this["<b>InChIKey</b>"]!= undefined && this["<b>InChIKey</b>"] != "") {
			formatData['inchikey'] = (this["<b>InChIKey</b>"]);
			formatData['concentration'] = (this["<b>concentration (&micro;g/ml)</b>"]);
			jsonRCC_ADDED.push(formatData);
		}
	});
	return jsonRCC_ADDED;
};

/**
 * 
 */
function clearLine() {
	// restet form
	setTimeout(function(){
		$("#add-one-cc-s1-value").val("");
		$("#ok-step-1").html("");
	}, 200);
	$("img.mixRCCadd"+multiPickLine).remove();
	if (singlePick) {
		$("#add1spectrum-sample-inchikey").val("");
		$("#add1spectrum-sample-inchikey").change();
		$("#add1spectrum-sample-inchi").val("");
		$("#add1spectrum-sample-inchi").change();
		$("#add1spectrum-sample-commonName").val("");
		$("#add1spectrum-sample-commonName").change();
		$("#sample-bonus-display").html('');
	} else if (multiPickLine >= 0) {
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 0, "");
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 1, "");
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 2, "");
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 3, "");
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 4, "");
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 5, "");
	}
}

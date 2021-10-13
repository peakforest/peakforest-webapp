// Creative Commons - Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// http://creativecommons.org/licenses/by-nc-sa/4.0/
// MetaboHUB 2015
$(document).ready(function() {
//	// READ FILE AND PREFILL HTML FORM // TODO
//	var fileNMRpeaklistInput_form = document.getElementById("fileNMRpeaklistInput");
//	fileNMRpeaklistInput_form.addEventListener('change', function(e) { 
//		var myNMRfile = fileNMRpeaklistInput_form.files[0];
//		var acquNameMatch = /peaklist-.*\.xml/;
//		// test if file OK (regexp on name)
//		if (myNMRfile.name.match(acquNameMatch)) {
//			var reader = new FileReader();
//			reader.onload = function(e) {
//				//console.log();
//				// reset file
//				// $(".NMRpeakdataLoad").val("");
//				$("#tbodyPeaklist").empty();
//				$("#tbodyPeakPatternlist").empty();
//				var xmlDoc = $.parseXML( reader.result );
//				parseXMLElement(xmlDoc, 'PeakList');
//			}
//			reader.readAsText(myNMRfile);
//		} else {
//			alert("file name does not like: 'peaklist-.*\.xml'");
//		}
//	});
	// READ FILE AND DUMP DATA IN JSON OBJECT
	var fileNMRpeaklistInput_file = document.getElementById("uploadSpectrumFileNMR_file");
	fileNMRpeaklistInput_file.addEventListener('change', function(e) { 
		var myNMRfile = fileNMRpeaklistInput_file.files[0];
		var acquNameMatch = /peaklist-.*\.xml/;
		// test if file OK (regexp on name)
		if (myNMRfile.name.match(acquNameMatch)) {
			$("#uploadSpectrumFileNMR_display").val(myNMRfile.name);
			var reader = new FileReader();
			reader.onload = function(e) {
				$("#generatingTemplate-nmr-peaks").show();
				//console.log();
				// reset file
				// $(".NMRpeakdataLoad").val("");
				$("#tbodyPeaklist").empty();
				$("#tbodyPeakPatternlist").empty();
				var xmlDoc = $.parseXML( reader.result );
				parseXMLElement(xmlDoc, 'PeakList', true);
				$("#generatingTemplate-nmr-peaks").hide();
			}
			reader.readAsText(myNMRfile);
		} else {
			alert("file name does not like: 'peaklist-.*\.xml'");
		}
	});
});

var patternList = [];
var peakList = [];
var currentPattern = null;
var currentPeak = null;

/**
 * Parse XML file
 */
function parseXMLElement(root, elem, isFile) {
	$(root).find(elem).each(function(index){
		// raw debug
		// console.log($(this));
		var id = $(this).attr("id");
  		var text = $(this).text();
		//var arr = text.split('\n');
		if (elem === 'PeakList') {
			parseXMLElement(this, "PeakList1D");
			// TODO other peak list reading
			// debug
			console.log(peakList);
			console.log(patternList);
			// dump for xlsm file
			if (isFile) {
				if (jsonNMRdata ==null) {
					jsonNMRdata = {};
					jsonNMRdata["dumper_type"] = "nmr";
				}
//				jsonNMRdata["peaklist"] = {};
//				jsonNMRdata["patternlist"] = {};
//				jsonNMRdata["peaklist"] = peakList;
//				jsonNMRdata["patternlist"] = patternList;
				jsonNMRdata["nmr_peaklist"] = [];
				currentNMRpeaklistTemplate = {};
				currentNMRpeaklistTemplate["peaklist"] = peakList;
				currentNMRpeaklistTemplate["patternlist"] = patternList;
				jsonNMRdata.nmr_peaklist[0] = currentNMRpeaklistTemplate;
			} else // fulfill html form
				htmlRender();
		} else if (elem === 'PeakList1D') {
			// PeakList1DHeader -> osef
			// PeakList1DHeader.PeakPickDetails -> osef
			// Peak1D
			currentPattern = { "peaks": [] };
			parseXMLElement(this, "Peak1D");
			currentPattern.chemicalShift = getChemicalShift(currentPattern.peaks);
			switch(currentPattern.peaks.length) {
				case 1:
					currentPattern.type = "s";
					break;
				case 2:
					currentPattern.type = "d";
					break;
				case 3:
					currentPattern.type = "t";
					break;
				default:
					currentPattern.type = "m";
					break;
			}
			patternList.push(currentPattern);
		}  else if (elem === 'Peak1D') {
			var f1 = $(this).attr("F1");
			var annotation = $(this).attr("annotation");
			var intensity = $(this).attr("intensity");
			var type = $(this).attr("type");
			currentPeak = { "f1": f1, "annotation": annotation, "intensity": intensity, "type" : type };
			peakList.push(currentPeak);
			currentPattern.peaks.push(currentPeak);
		}
	});
}

/**
 * Get chemical Shift
 */
getChemicalShift = function(listOfPeaks) {
	var cpt = 0;
	var addAll = 0;
	$.each(listOfPeaks, function(index, elem){
		addAll += Number(elem.f1);
		cpt++;
	});
	if (cpt != 0)
		return (addAll / cpt);
	return 0;
}

/**
 * HTML render
 */
htmlRender = function() {
//	$.each(peakList, function(index, elem){
//		//var line = "<tr><td>" + (index+1) + "</td><td>x</td><td>x</td><td>" + elem.f1 + "</td><td>x</td><td>x</td><td>"+elem.intensity+"</td><td>x</td><td>x</td><td>"+elem.annotation+"</td></tr>";
//		var line = $("<tr></tr>");
//		$(line).append("<td>" + (index+1) + "</td>");//<th>peak index</th>
//		$(line).append("<td>x</td>");//<th>region</th>
//		$(line).append("<td>x</td>");//<th>index (F1)</th>
//		$(line).append("<td>" + elem.f1 + "</td>");//<th>ν (F1) [ppm]</th>
//		$(line).append("<td>x</td>");//<th>ν (F1) [Hz]</th>
//		$(line).append("<td>x</td>");//<th>intensity [abs]</th>
//		$(line).append("<td>"+elem.intensity+"</td>");//<th>intensity [rel]</th>
//		$(line).append("<td>x</td>");//<th>half width [ppm]</th>
//		$(line).append("<td>x</td>");//<th>half width [Hz]</th>
//		$(line).append("<td>"+elem.annotation+"</td>");//<th>annotation</th>
//		$("#tbodyPeaklist").append(line);
//		//console.log(elem);
//	});
//	$.each(patternList, function(index, elem){
//		//var line = "<tr><td>" + (index+1) + "</td><td>x</td><td>x</td><td>" + elem.f1 + "</td><td>x</td><td>x</td><td>"+elem.intensity+"</td><td>x</td><td>x</td><td>"+elem.annotation+"</td></tr>";
//		var line = $("<tr></tr>");
//		//$(line).append("<td>" + (index+1) + "</td>");//<th>peak index</th>
//		$(line).append("<td>" + elem.chemicalShift + "</td>");// <th>ν (F1) [ppm]</th>
//		$(line).append("<td>" + "</td>");// <th>H's</th>
//		$(line).append("<td>" + elem.type + "</td>");// <th>type</th>
//		$(line).append("<td>" + "</td>");// <th>J(Hz)</th>
//		$(line).append("<td>" + "</td>");// <th>range (ppm)</th>
//		$(line).append("<td>" + "</td>");// <th>atoms</th>
//		$(line).append("<td>" + "</td>");// <th>MSI level</th>
//		$("#tbodyPeakPatternlist").append(line);
//		console.log(elem);
//	});
} 

// init var
var currentNMRpeaklistTemplate = {};
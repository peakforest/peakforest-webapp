// Creative Commons - Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// http://creativecommons.org/licenses/by-nc-sa/4.0/
// MetaboHUB 2014
/**
 * Add listener on button, upload file (client side) and read it line by line.
 */
$(document).ready(function() {
//	// READ FILE AND PREFILL HTML FORM // TODO
//	var fileNMRmetadataInput_from = document.getElementById("fileNMRmetadataInput_from");
//	fileNMRmetadataInput_from.addEventListener('change', function(e) { 
//		var myNMRfile = fileNMRmetadataInput_from.files[0];
//		var acquNameMatch = /acqu-.*/;
//		// test if file OK (regexp on name)
//		if (myNMRfile.name.match(acquNameMatch)) {
//			var reader = new FileReader();
//			reader.onload = function(e) {
//				//console.log();
//				// reset file
//				$(".NMRmetadataLoad").val("");
//				// for each line in file
//				$.each(reader.result.split('\n##'), function(index, line) {
//					// console.log(index + "=>" + line);
//					processNMRfileLine(index, line, false);
//				});
//				// special case: pulse angle
//				if ($("#F1").text().trim()=="")
//					$("#F1").html("90");
//			}
//			reader.readAsText(myNMRfile);
//		} else
//			alert("file name does not like: 'acqu-*'");
//	});
	// READ FILE AND DUMP DATA IN JSON OBJECT
	var fileNMRmetadataInput_dumper = document.getElementById("uploadParamFileNMR_file");
	fileNMRmetadataInput_dumper.addEventListener('change', function(e) { 
		var myNMRfile = fileNMRmetadataInput_dumper.files[0];
		var acquNameMatch = /acqu-.*/;
		// test if file OK (regexp on name)
		if (myNMRfile.name.match(acquNameMatch)) {
			$("#uploadMetadataFileNMR_display").val(myNMRfile.name);
			var reader = new FileReader();
			reader.onload = function(e) {
				$("#generatingTemplate-nmr-device").show();
				//console.log();
				// reset data
				jsonNMRdata["nmr_analyzer"] = {};
				nmrAcquisitionData = {};
				// for each line in file
				$.each(reader.result.split('\n##'), function(index, line) {
					// console.log(index + "=>" + line);
					processNMRfileLine(index, line, false);
				});
				// special case: pulse angle
				if (typeof nmrAcquisitionData.F1 ===  'undefined' || nmrAcquisitionData.F1 === null) 
					nmrAcquisitionData.F1 = 90.0;
				$("#generatingTemplate-nmr-device").hide();
				jsonNMRdata.nmr_analyzer["acquisition"] = [];
				jsonNMRdata.nmr_analyzer.acquisition[0] = nmrAcquisitionData;
			}
			reader.readAsText(myNMRfile);
		} else
			alert("file name does not like: 'acqu-*'");
	});
});

/**
 * Process file content (line by line)
 */
processNMRfileLine = function (index, line, isForm) {
	if (jsonNMRdata == null) {
		jsonNMRdata = {};
		jsonNMRdata["dumper_type"] = "nmr";
		jsonNMRdata["nmr_analyzer"] = {};
	}
	if (index == 0) {
		// softeware version
		if (line.match(/TOPSPIN\t\tVersion\s3\.1/)) {
			if (isForm)
				$("#software_version").html("TOPSPIN V 3.1");
			else
				jsonNMRdata.nmr_analyzer.software_version = "TopSpin 3.1";
			return false;
		} else if (line.match(/TOPSPIN\t\tVersion\s3\.0/)) {
			if (isForm)
				$("#software_version").html("TOPSPIN V 3.0");
			else
				jsonNMRdata.nmr_analyzer.software_version = "TopSpin 3.0";
			return false;
		} else if (line.match(/TOPSPIN\t\tVersion\s2\.1/)) {
			if (isForm)
				$("#software_version").html("TOPSPIN V 2.1");
			else
				jsonNMRdata.nmr_analyzer.software_version = "TopSpin 2.1";
			return false;
		}
		return false;
	}
	//
	// $PULPROG =<…>
	var keyValTab = line.match(/(.*)=(.*)/);
	//console.log(key);
	if (keyValTab) {
		var key = keyValTab[1].trim();
		var val = keyValTab[2].trim();
// 		console.log(key);
		switch (key) {
			case '$PULPROG':
				if (isForm)
					$("#PULPROG").html(cleanString(val));
				else
					nmrAcquisitionData.PULPROG = (cleanString(val));
				break;
			case '$TD':
			case '$NS':
			case '$TE':
			case '$DS':
			case '$SW':
				if (isForm)
					$("#" + cleanString(key)).html(cleanString(val));
				else {
					var tmpD = nmrAcquisitionData;
					tmpD[cleanString(key)] = cleanString(val);
					nmrAcquisitionData = tmpD;
				}
				break;
			case '$D':
				var numberTab = line.split(")")[1].replace(/\n/g, " ").split(" ");
				if (isForm)
					$("#D8").html(numberTab[9]);
				else
					nmrAcquisitionData.D8 = cleanString(numberTab[9]);
				break;
			default:
				break;
		}//switch
		return true;
	}
	//console.log(index + "=>" + line);
	return false;
}

/**
 * Remove HTML markup and "$" symbol in string
 */
cleanString = function(value) {
	return value.replace(/</g, "").replace(/>/g, "").replace(/\$/g, "");
}

// init local var
var nmrAcquisitionData = {};
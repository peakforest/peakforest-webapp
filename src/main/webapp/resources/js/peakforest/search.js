var reopenDetailsModal = false;
var reopenDetailsSheet = false;
var hideSpectraScoreZero = true;
var filterCpd = 0;
var filterNMR = [];
var filterLCMS = [];
var filterLCMSMS = [];
var isCountMaxResults = false;
checkIfReOpenDetailsModal = function() {
	if (reopenDetailsModal) {
		$('#modalShowCompound').modal('show');
		reopenDetailsModal = false;
	}
};

$('body').on('hidden.bs.modal', '.modal', function () {
	  $(this).removeData('bs.modal');
});

$('#search').focus(function(){
	this.selectionStart = this.selectionEnd = this.value.length;
});

var searchResultsHeight = 0;
var isCompoundEntityOpen = false;
function openCompoundEntity (type, id) {
	isCompoundEntityOpen = true;
	//divEntityDetails
	//var divClose = '<div id="divCloseEntity"></div>';
	$.get("sheet-compound/"+type+"/"+id, function( data ) {
		$("#divEntityDetails").html( data );
		$("#compoundResultsTable").hide();
		$("#spectrumResultsTable").hide();
		$("#metadataResultsTable").hide();
		$("#searchForm").hide()
		$("#searchPagination").hide();
		$("#divCloseEntity").show();
		$("#divEntityDetails").show();
		console.log("entity: ready!");
		var diff_screen = 190;
		$("#entityBody").height($(window).height()-diff_screen);
		$("#entityBody").css("overflow","auto");
		$("#search-results").css("overflow","hidden");
		//setTimeout(function() { $("#search-results").css("overflow","auto"); }, 25);
		searchResultsHeight = $('#search-results').height();
		$('#search-results').removeAttr('style');
		
	});
}
function closeCompoundEntity () {
	isCompoundEntityOpen = false;
	$("#divCloseEntity").hide();
	$("#divEntityDetails").html("");
	$("#divEntityDetails").hide();
	if ($("#compoundResultsTable tr").size()>0)
		$("#compoundResultsTable").show();
	if ($("#spectrumResultsTable tr").size()>0)
		$("#spectrumResultsTable").show();
	if ($("#metadataResultsTable tr").size()>0)
		$("#metadataResultsTable").show();
	$("#searchForm").show()
	$("#searchPagination").show();
	$("#search-results").css("overflow","auto");
	$("#search-results").height(searchResultsHeight);
}

var numberMaxResults = 10;
var compoundsData = new Array();
var spectrumData = new Array();
var metadataData = new Array();
var isMainQueryAnsync = false;
var divSearch = "search";

// SEARCH ALL
var inputSearch = $("input#search");
if (($(inputSearch).length)&&($("#search").val() != ""))
	loadSearchResults();

// PEAKMATCHING NMR
var inputSearchNMR = $("input#searchNMR");
if (($(inputSearchNMR).length)&&($("#searchNMR").val() != "")) {
	divSearch = "searchNMR";
	isMainQueryAnsync = true;
	loadSearchResults();
}

// PEAKMATCHING MS
var inputSearchLCMS = $("input#searchLCMS");
if (($(inputSearchLCMS).length)&&($("#searchLCMS").val() != "")) {
	divSearch = "searchLCMS";
	isMainQueryAnsync = true;
	loadSearchResults();
}

////////////////////////////////////////////////////
// new 2.0 MSMS MATCHING
var inputSearchLCMSMS = $("input#searchLCMSMS");
if (($(inputSearchLCMSMS).length)&&($("#searchLCMSMS").val() != "")) {
	divSearch = "searchLCMSMS";
	isMainQueryAnsync = true;
	loadSearchResults();
}


// 	var numberTotalResults = 0;
var totalElementFound = 0;
function loadSearchResults() {
	$(".loadSearchResults").show();
	$("#compoundResultsTable").hide();
	$("#spectrumResultsTable").hide();
	$("#metadataResultsTable").hide();
	$("#noSearchResults").hide();
	$("#noLCMSSearchResults").hide();
	$("#noNMRSearchResults").hide();
	// init search request
	var rawSearchRequestQuery = $.trim($('#'+divSearch).val());
	if (/^PF(c|s)\d{3,}$/.test(rawSearchRequestQuery)) {
		document.location = rawSearchRequestQuery;
		return;
	}
	var searchRequest = "query=" + rawSearchRequestQuery; 
	searchRequest = getSearchRequestFormated(searchRequest, rawSearchRequestQuery);
	if ($.isEmptyObject(compoundsData) && $.isEmptyObject(spectrumData) && $.isEmptyObject(metadataData)) { // ||
		var compoundsDataTmp = [];
		var spectraDataTmp = [];
		$.ajax({ 
			type: "post",
			url: "search",
			dataType: "json",
			async: isMainQueryAnsync,
			data: searchRequest,
			success: function(json) {
				if (json.success ) { // || json.hasOwnProperty('nmrCandidates')
					var compoundCount = 0;
					var spectrumCount = 0;
					var metadataCound = 0;
					// names
					var unicNameDisplay = [];
					if (json.hasOwnProperty('compoundNames'))
						$.each(json.compoundNames, function() {
							//console.log(this);
							try {
								if (this.compound.id in unicNameDisplay) {
									throw false;
								}
								// 
								var rawFromula = this.compound.formula;
								var formatedFormula = rawFromula + "";
								try {
									$.each($.unique( rawFromula.match(/\d/g)), function (keyF, valF) {
										var re = new RegExp(valF,"g");
										formatedFormula = formatedFormula.replace(re, "<sub>" + valF + "</sub>");
									});
									formatedFormula = formatedFormula.replace("</sub><sub>", "");
								} catch (e) {}
								var type = "?";
								if (this.compound.hasOwnProperty("parent")) 
									type = "chemical";
								if (this.compound.hasOwnProperty("children"))
									type = "generic";
								var hasSpectra = this.compound.containSpectra;
								//
								var object = { 
									name: this.name, 
									id: this.compound.id, 
									formula: formatedFormula, //this.compound.formula,
									exactMass: roundNumber(this.compound.monoisotopicMass, 7),
									molWeight: roundNumber(this.compound.averageMass, 7),
									inchikey: this.compound.inChIKey,
									type: type,
									spectra: hasSpectra,
									pfID: this.compound.pfID
								};
								unicNameDisplay [this.compound.id] = object;
								compoundsDataTmp.push(object);
								compoundCount++;
							} catch (e) { console.log(e);}
						}); 
					//
					//try {
					if (json.hasOwnProperty('compounds'))
						$.each(json.compounds, function() {
// 							results.push(this.name);
							var nameBestScore = this.mainName;
//									var bestScore = 0;
//									$.each(this.names, function(key, compName) {
//										if (compName.score > bestScore) {
//											bestScore = compName.score;
//											nameBestScore = compName.bestScorename;
//										}
//									});
							var rawFromula = this.formula;
							var formatedFormula = rawFromula + "";
							try {
								$.each($.unique( rawFromula.match(/\d/g)), function (keyF, valF) {
									var re = new RegExp(valF,"g");
									formatedFormula = formatedFormula.replace(re, "<sub>" + valF + "</sub>");
								});
								formatedFormula = formatedFormula.replace("</sub><sub>", "");
							} catch (e) {}
							var type = "?";
							if (this.hasOwnProperty("parent")) 
								type = "chemical";
							if (this.hasOwnProperty("children"))
								type = "generic";
							var hasSpectra = this.containSpectra;
							//
							var object = { 
									name : nameBestScore, 
									id : this.id, 
									formula: formatedFormula,
									exactMass: roundNumber(this.monoisotopicMass,7),
									molWeight: roundNumber(this.averageMass,7),
									inchikey: this.inChIKey,
									type: type,
									spectra: hasSpectra,
									pfID: this.pfID
								};
								compoundsDataTmp.push(object);
								compoundCount++;
						});
					
					if (json.hasOwnProperty('nmrCandidates')) {
						var nmrSpectraMap = {};
						$.each(json.nmrSpectra, function() {
							nmrSpectraMap[this.id] = this;
						}); //console.log(nmrSpectraMap)
						$.each(json.nmrCandidates, function() {
							var key = this.key;
							key = Number(key.replace("pf:","")); //console.log(key)
							var rawSpectra = nmrSpectraMap[key];
							if (rawSpectra !== undefined) {
								var spectraImg = "nmr-light";
								var nbPeak = rawSpectra.peaks.length;
								if (nbPeak > 10)
									spectraImg = "nmr-avg";
								if (nbPeak > 20)
									spectraImg = "nmr-big";
								var cpd = {
									
								};
								if (rawSpectra.label=="reference" && rawSpectra.listOfCompounds.length == 1) {
									var cpdInChIKey = rawSpectra.listOfCompounds[0].inChIKey;
									var cpdID = rawSpectra.listOfCompounds[0].id;
									var cpdType = "?";
									if (rawSpectra.listOfCompounds[0].type == 101) 
										cpdType = "chemical";
									if (rawSpectra.listOfCompounds[0].type == 100)
										cpdType = "generic";
									cpd = {
										id: cpdID,
										inchikey: cpdInChIKey,
										type: cpdType
									};
								}
// 									if (rawSpectra.)
// 										listOfCompounds 	inChIKey type
								var object = { 
									id: rawSpectra.id,
									name: rawSpectra.massBankLikeName,
									score: this.score,
									type: "nmr",
									img: spectraImg,
									compound: cpd,
									sampleNMRTubeConditionsMetadata: rawSpectra.sampleNMRTubeConditionsMetadata,
									pfID: rawSpectra.pfID
								};
							spectraDataTmp.push(object);
							spectrumCount++;
							}
						});
					} // if(json.hasOwnProperty('nmrCandidates')) {
					var containsNMRspectra = false;
					var containsLCMSspectra = false;
					var containsLCMSMSspectra = false;
					
					if(json.hasOwnProperty('nmrSpectra') && !json.hasOwnProperty('nmrCandidates'))
						$.each(json.nmrSpectra, function() {
							containsNMRspectra = true;
							var rawSpectra = this;
							if (rawSpectra !== undefined) {
								var spectraImg = "nmr-light";
								var nbPeak = rawSpectra.peaks.length;
								if (nbPeak > 10)
									spectraImg = "nmr-avg";
								if (nbPeak > 20)
									spectraImg = "nmr-big";
								var cpd = {
									
								};
								if (rawSpectra.label=="reference" && rawSpectra.listOfCompounds.length == 1) {
									var cpdInChIKey = rawSpectra.listOfCompounds[0].inChIKey;
									var cpdID = rawSpectra.listOfCompounds[0].id;
									var cpdType = "?";
									if (rawSpectra.listOfCompounds[0].type == 101) 
										cpdType = "chemical";
									if (rawSpectra.listOfCompounds[0].type == 100)
										cpdType = "generic";
									cpd = {
										id: cpdID,
										inchikey: cpdInChIKey,
										type: cpdType
									};
								}
								
// 									if (rawSpectra.)
// 										listOfCompounds 	inChIKey type
								var object = { 
									id: rawSpectra.id,
									name: rawSpectra.massBankLikeName,
									score: roundNumber(this.matchingScore, 3),
									type: "nmr",
									img: spectraImg,
									compound: cpd,
									sampleNMRTubeConditionsMetadata: rawSpectra.sampleNMRTubeConditionsMetadata,
									pfID: rawSpectra.pfID
								};
							spectraDataTmp.push(object);
							spectrumCount++;
							}
						});
					
					if(json.hasOwnProperty('lcmsSpectra') || json.hasOwnProperty('lcmsmsSpectra')) {
						var arrayMSspectra = [];
						// concat
						if (json.hasOwnProperty('lcmsSpectra')) {
							arrayMSspectra = arrayMSspectra.concat(json.lcmsSpectra);
						} 
						if (json.hasOwnProperty('lcmsmsSpectra')) {
							arrayMSspectra = arrayMSspectra.concat(json.lcmsmsSpectra);
						} 
						// add img
						$.each(arrayMSspectra, function() {
							containsLCMSspectra = true;
							var rawSpectra = this;
							if (rawSpectra !== undefined) {
								var spectraImg = "lcms-light";
								var nbPeak = rawSpectra.peaks.length;
								if (nbPeak > 10)
									spectraImg = "lcms-avg";
								if (nbPeak > 20)
									spectraImg = "lcms-big";
								var cpd = {
									
								};
								if (rawSpectra.label=="reference" && rawSpectra.listOfCompounds.length == 1) {
									var cpdInChIKey = rawSpectra.listOfCompounds[0].inChIKey;
									var cpdID = rawSpectra.listOfCompounds[0].id;
									var cpdType = "?";
									if (rawSpectra.listOfCompounds[0].type == 101) 
										cpdType = "chemical";
									if (rawSpectra.listOfCompounds[0].type == 100)
										cpdType = "generic";
									cpd = {
										id: cpdID,
										inchikey: cpdInChIKey,
										type: cpdType
									};
								}
// 									if (rawSpectra.)
// 										listOfCompounds 	inChIKey type
								var object = { 
									id: rawSpectra.id,
									name: rawSpectra.massBankName,
									score: roundNumber(this.matchingScore, 3),
									type: "lcms",
									img: spectraImg,
									compound: cpd,
									pfID: rawSpectra.pfID
								};
							spectraDataTmp.push(object);
							spectrumCount++;
							}
						});
					}
					
					// sort
					if (containsNMRspectra || containsLCMSspectra)
						spectraDataTmp.sort(function(a, b) { 
						    return b.score - a.score;
						});
					
					//} catch (e) {}
					compoundsData = compoundsDataTmp;
					// spectrum
					spectrumData = spectraDataTmp;
					// TODO metadata
					// compute number of results
					totalElementFound = compoundCount + spectrumCount + metadataCound;
					filterSearchResults(0, totalElementFound);
				} else {
					subjects = [];
					filterSearchResults(0, 0);
				}
				//console.log(compoundsData);
		},
		error : function(xhr) {
			subjects = [];
			// alert error xhr.responseText
			console.log(xhr);
			filterSearchResults(0, 0);
		}
		});
	}
}
function filterSearchResults(startPoint, numberTotalResults) {
	startPoint = parseInt(startPoint);
	numberTotalResults = parseInt(numberTotalResults);
	// uri
	setTimeout(function() {
		var currentURI = location.href;
		if (currentURI.indexOf("#")>0) {
			currentURI = currentURI.substr(0,currentURI.indexOf('#'));
		}
		location.href = currentURI + "#" + startPoint + "-" + numberTotalResults;
	}, 20);
	// gui
	$(".loadSearchResults").show();
	$("#compoundResultsTable").hide();
	$("#spectrumResultsTable").hide();
	$("#spectrumNMRResultsTable").hide();
	$("#spectrumLCMSResultsTable").hide();
	$("#spectrumLCMSMSResultsTable").hide();
	$("#metadataResultsTable").hide();
	$("#noSearchResults").hide();
	// init local var
	var currentDisplayCount = 0;
	var currentTotalCount = 0;
	var compoundsDataDisplay = new Array();
	var spectrumDataDisplay = new Array();
	var metadataDataDisplay = new Array();
	var displayed = false;
	
	var filterNMRspectra = false;
	for(var i= 0; i < filterNMR.length; i++)
		if (filterNMR[i] != null) 
			filterNMRspectra = true;
	
	var filterLCMSspectra = false;
	for(var i= 0; i < filterLCMS.length; i++)
		if (filterLCMS[i] != null) 
			filterLCMSspectra = true;
	
	// spectrum
	$.each(spectrumData, function(key, value) {
		if (currentTotalCount >= startPoint) {
			if (filterNMRspectra) {
				var okMSF = true;
				var okPULSEQ = true;
				var okCPD = true;
				var okSolvent = true;
				for(var i= 0; i < filterNMR.length; i++)
					if (filterNMR[i] != null) {
						var filter = filterNMR[i];
						if (filter.hasOwnProperty('mfs')) {
							if (!((value.name).toLowerCase().indexOf("-"+filter.mfs+"mhz") >= 0)) {
								okMSF = false;
								break;
							}
						} 
						if (filter.hasOwnProperty('pulseq')) {
							if (!((value.name).toUpperCase().indexOf("; "+filter.pulseq.toUpperCase()+"") >= 0)) {
								okPULSEQ = false;
								break;
							}
						}
						if (filter.hasOwnProperty('cpd')) {
							if (!((value.name).toUpperCase().indexOf(""+filter.cpd.toUpperCase()+"") >= 0)) {
								okCPD = false;
								break;
							}
						}
						if (filter.hasOwnProperty('solvent')) {
							if (!((value.sampleNMRTubeConditionsMetadata.solventNMR).toUpperCase().indexOf(""+filter.solvent.toUpperCase()+"") >= 0)) {
								okSolvent = false;
								break;
							}
						}
					}
				if (okMSF&&okPULSEQ&&okCPD&&okSolvent) {
					spectrumDataDisplay.push(value);
					currentDisplayCount++;
				}
			} else if (filterLCMSspectra) {
				var okIM = true;
				var okAT = true;
				var okCPD = true;
				for(var i= 0; i < filterLCMS.length; i++)
					if (filterLCMS[i] != null) {
						var filter = filterLCMS[i];
						if (filter.hasOwnProperty('ioniztionMethod')) {
							if (!((value.name).toUpperCase().indexOf("; LC-"+filter.ioniztionMethod+"-") >= 0)) {
								okIM = false;
								break;
							}
						} 
						if (filter.hasOwnProperty('ionAnalyzer')) {
							if (!((value.name).toUpperCase().indexOf("-"+filter.ionAnalyzer.toUpperCase()+"; MS;") >= 0)) {
								okAT = false;
								break;
							}
						}
						if (filter.hasOwnProperty('cpd')) {
							if (!((value.name).toUpperCase().indexOf(""+filter.cpd.toUpperCase()+"") >= 0)) {
								okCPD = false;
								break;
							}
						}
					}
				if (okIM&&okAT&&okCPD) {
					spectrumDataDisplay.push(value);
					currentDisplayCount++;
				}
			} else {
				spectrumDataDisplay.push(value);
				currentDisplayCount++;
			}
			if (currentDisplayCount>=numberMaxResults) {
				displaySearchResults(compoundsDataDisplay, spectrumDataDisplay, metadataDataDisplay, startPoint, numberTotalResults);
				displayed = true;
				return false;
			}
		}
		currentTotalCount++;
		if (currentDisplayCount>=numberMaxResults) {
			displaySearchResults(compoundsDataDisplay, spectrumDataDisplay, metadataDataDisplay, startPoint, numberTotalResults);
			displayed = true;
			return false;
		}
	});
	
	// check if display now
	if (currentDisplayCount>=numberMaxResults) {
		displaySearchResults(compoundsDataDisplay, spectrumDataDisplay, metadataDataDisplay, startPoint, numberTotalResults);
		displayed = true;
		return false;
	}
	
	// compounds
	$.each(compoundsData, function(key, value) {
		if (currentTotalCount >= startPoint) {
			compoundsDataDisplay.push(value);
			currentDisplayCount++;
			if (currentDisplayCount>=numberMaxResults) {
				displaySearchResults(compoundsDataDisplay, spectrumDataDisplay, metadataDataDisplay, startPoint, numberTotalResults);
				displayed = true;
				return false;
			}
		}
		currentTotalCount++;
	});
	
	// TODO metadata
	// end
	if (!displayed)
		displaySearchResults(compoundsDataDisplay, spectrumDataDisplay, metadataDataDisplay, startPoint, numberTotalResults);		
	
	return true;
};

checkIfLoadSubPage = function() {
	var currentURI = location.href;
	if (currentURI.indexOf("#")>0) {
		currentURI = currentURI.substr((currentURI.indexOf('#')+1), currentURI.length);
		var tabCurrentURI = currentURI.split("-");
		if (tabCurrentURI.length ==2)
			filterSearchResults(tabCurrentURI[0], tabCurrentURI[1]);
	}
};
if(!isMainQueryAnsync)
	setTimeout(function(){checkIfLoadSubPage();},50);

var firstLoadTabData = true;

function displaySearchResults(compoundsDataDisplay, spectrumDataDisplay, metadataDataDisplay, startPoint, numberTotalResults) {
	// remove tablesorter
	if (firstLoadTabData)
		$('table').unbind('appendCache applyWidgetId applyWidgets sorton update updateCell').removeClass('tablesorter').find('thead th').unbind('click mousedown').removeClass('header headerSortDown headerSortUp');
	
	//
	var isFirstTab = false;
	$(".loadSearchResults").hide();
	//console.log(compoundsDataDisplay);
	
	$("#noNMRSearchResults").hide();
	$("#noLCMSSearchResults").hide();
	$("#noSearchResults").hide();
	
	// COMPOUNDS
	$("#compoundResultsTableBody").empty();
	if (!$.isEmptyObject(compoundsDataDisplay)) {
		$("#templateCompounds").tmpl(compoundsDataDisplay).appendTo("#compoundResultsTableBody");
		$("#compoundResultsTable").show();
		// format formula
		$.each($(".compoundFormula"), function(id, elem) {
			$(elem).html($(elem).text());
		});
		//
	}
	
	// display spectrum
	$("#spectrumResultsTableBody").empty();
	$("#spectrumNMRResultsTableBody").empty();
	$("#spectrumLCMSResultsTableBody").empty();
	$("#spectrumLCMSMSResultsTableBody").empty();
	if (!$.isEmptyObject(spectrumDataDisplay)) {
		if ($($("tbody#spectrumResultsTableBody")).length) {
			$("#templateSpectra").tmpl(spectrumDataDisplay).appendTo("#spectrumResultsTableBody");
			$("#spectrumResultsTable").show();
			hideSpectraScoreZeroF('spectrumResultsTableBody');
		} else {
			if ($($("tbody#spectrumNMRResultsTableBody")).length) {
				$("#templateNMRSpectra").tmpl(spectrumDataDisplay).appendTo("#spectrumNMRResultsTableBody");
				$("#spectrumNMRResultsTable").show();
				$("#searchNMRfilterDiv").show();
				hideSpectraScoreZeroF('spectrumNMRResultsTableBody');
			} 
			if ($($("tbody#spectrumLCMSResultsTableBody")).length) {
				$("#templateLCMSSpectra").tmpl(spectrumDataDisplay).appendTo("#spectrumLCMSResultsTableBody");
				$("#spectrumLCMSResultsTable").show();
				$("#searchLCMSfilterDiv").show();
				hideSpectraScoreZeroF('spectrumLCMSResultsTableBody');
			}
			if ($($("tbody#spectrumLCMSMSResultsTableBody")).length) {
				$("#templateLCMSMSSpectra").tmpl(spectrumDataDisplay).appendTo("#spectrumLCMSMSResultsTableBody");
				$("#spectrumLCMSMSResultsTable").show();
				$("#searchLCMSMSfilterDiv").show();
				hideSpectraScoreZeroF('spectrumLCMSMSResultsTableBody');
			}
		}
	}
	
	// TODO display metadata
	// if all empty : display null
	if ($.isEmptyObject(compoundsDataDisplay) && $.isEmptyObject(spectrumDataDisplay)) { // TODO add  metadata
		$("#noSearchResults").show();
		$("#noNMRSearchResults").show();
		$("#noLCMSSearchResults").show();
		$("#noLCMSMSSearchResults").show();
//		$("#searchNMRfilterDiv").hide();
		$("#"+divSearch+"Pagination").html("");
		return true;
	}
	
	//
	computeDisplayCpdInCartList();
	
	// rebuild page nav
	var moreThanOne = false;
	var currentPage = startPoint / numberMaxResults;
	var lastPage = Math.ceil(numberTotalResults / numberMaxResults);
// 		console.log("currentPage=" + currentPage);
// 		console.log("lastPage=" + lastPage);
	var htmlPagination = "";
	// first
	if (currentPage==0) {
		htmlPagination += '<li class="disabled"><a href="#">&laquo;</a></li>';
		isFirstTab = true;
	} else {
		htmlPagination += '<li><a href="#" onclick="filterSearchResults(0, '+numberTotalResults+');">&laquo;</a></li>';
	}
	// n-3
	if (currentPage>=3){
		if (currentPage!=3)
			htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
		var before = startPoint-numberMaxResults-(2*numberMaxResults);
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+before+', '+numberTotalResults+');">'+(currentPage-2)+'</a></li>';
	}
	// n-2
	if (currentPage>=2){
//				if (currentPage!=2)
//					htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
		var before = startPoint-numberMaxResults-(1*numberMaxResults);
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+before+', '+numberTotalResults+');">'+(currentPage-1)+'</a></li>';
	}
	// n-1
	if (currentPage>=1){
		moreThanOne = true;
		//htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
		var before = startPoint-numberMaxResults;
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+before+', '+numberTotalResults+');">'+(currentPage)+'</a></li>';
	}
	// n
	htmlPagination += '<li class="active"><a href="#">'+(currentPage+1)+'</a></li>';
	// n+1
	if ((currentPage+1)<lastPage){
		moreThanOne = true;
		var after = startPoint+numberMaxResults;
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+after+', '+numberTotalResults+');">'+(currentPage+2)+'</a></li>';
//				if (!((currentPage+3)<lastPage))
//					htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
	}
	// n+2
	if ((currentPage+2)<lastPage) {
		var after = startPoint+numberMaxResults+(1*numberMaxResults);
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+after+', '+numberTotalResults+');">'+(currentPage+3)+'</a></li>';
//				if (!((currentPage+4)<lastPage))
//					htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
	}
	// n+3
	if ((currentPage+3)<lastPage) {
		var after = startPoint+numberMaxResults+(2*numberMaxResults);
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+after+', '+numberTotalResults+');">'+(currentPage+4)+'</a></li>';
//				if (!((currentPage+4)<lastPage))
//					htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
	}
	if ((currentPage+4)<lastPage)
		htmlPagination += '<li class="disabled"><a href="#">&hellip;</a></li>';
	// last
	if ((currentPage+1)==lastPage) {
		htmlPagination += '<li class="disabled"><a href="#">&raquo;</a></li>';
	} else {
		var after = (lastPage) * numberMaxResults - numberMaxResults;
		htmlPagination += '<li><a href="#" onclick="filterSearchResults('+after+', '+numberTotalResults+');">&raquo;</a></li>';
	}
	// display pageination
	if (moreThanOne) {
		$("#"+divSearch+"Pagination").html(htmlPagination);
		$("#"+divSearch+"Pagination").show();
	}
	// sort page
	if (firstLoadTabData) {
		setTimeout(function() { 
			$("#compoundResultsTable").tablesorter(); 
			$("#spectrumResultsTable").tablesorter();
			$("#spectrumNMRResultsTable").tablesorter(); 
			$("#spectrumLCMSResultsTable").tablesorter(); 
			$("#spectrumLCMSMSResultsTable").tablesorter(); 
		}, 150);
	}
	setTimeout(function() { 
		$('table').trigger('update');
	}, 300);
//	$("#compoundResultsTable").tablesorter(); 

	// resize tab
	setTimeout(resizeMainPanel(), 50);
	// for modal reload
//			$("a[data-target=#modalPrintCompound]").click(function(ev) {
//				ev.preventDefault();
//				var target = $(this).attr("href");
//				// load the url and show modal on success
//				$("#modalPrintCompound .modal-dialog ").load(target, function() { $("#modalPrintCompound").modal("show"); });
//			});
//			$("a[data-target=#modalShowCompound]").click(function(ev) {
//				ev.preventDefault();
//				var target = $(this).attr("href");
//				// load the url and show modal on success
//				$("#modalShowCompound .modal-dialog ").load(target, function() { $("#modalShowCompound").modal("show"); });
//			});
	firstLoadTabData = false;
	
	// new 2.0.1: load nb results
	if (!isCountMaxResults)
		countMaxResults()
	
	return true;
}

// search action
$("#searchButton").click(function() {
	if ($("#search").val() != "") {
		$("#searchForm").submit();
	}
});
var autoCompleteLoadingPanelTimeout ;
function showAutocompleteLoadingPanel(bool) {
	if (bool) {
		clearTimeout(autoCompleteLoadingPanelTimeout);
		autoCompleteLoadingPanelTimeout = setTimeout(function() {
			$('#autoCompleteLoadingPanel').css('display', "block");
		},500);
	}
	else {
		clearTimeout(autoCompleteLoadingPanelTimeout);
		$('#autoCompleteLoadingPanel').css('display', "none");
	}
}
// autocomplete
var subjects = [];
//	$('#search').typeahead({source: subjects});
$('#search').typeahead({
	dynamic: true,
	delay: 0,
	source: function (query, process) {
		return searchAjax(process);
    }
});
//  bind keys
$('#search').bind('keypress', function(e) {
	var code = e.keyCode || e.which;
	// bind enter
	if (code == 13 && $("#search").val() != "") {
		$("#searchForm").submit();
	}
	// bind spacebar
	if (code == 32 && $("#search").val() != "") {
		var elem = $("#search").parent().find("ul");
		if ($(elem).is(":visible")){
			var tabLi = $(elem).find("li")
			for (var i = 0; i < tabLi.length; i++) {
				if ($(tabLi[i]).hasClass("active") && i > 0) {
					$("#search").val($(tabLi[i]).text());
				}
			}
		}
	}
	
}).focus();

searchAjax = function (callbackProcess) {
	var results = [];
	var rawQuery = ($('#search').val()).trim();
	results.push(rawQuery);
	if (rawQuery.length > 2) {
		showAutocompleteLoadingPanel(true);
		$.ajax({ 
				type: "post",
				url: "search",
				dataType: "json",
				async: true,
				data: "query=" + ($('#search').val()).trim() + "&quick=true",
				success: function(json) {
					if (json.success) {
						// names
						$.each(json.compoundNames, function(){
							if($.inArray(this.name, results) === -1) results.push(this.name);
						}); 
						//  compounds: 
						$.each(json.compounds, function(){
							if (this.inChIKey.indexOf(rawQuery))
								if($.inArray(this.inChIKey, results) === -1) results.push(this.inChIKey);
							if (this.formula.indexOf(rawQuery))
								if($.inArray(this.formula, results) === -1) results.push(this.formula);
						});
						// spectra keyworks
						results = matchingSpectraKeywords(rawQuery, results);
//						if (rawQuery != spectraAutoComplet)
//							if($.inArray(spectraAutoComplet, results) === -1) results.push(spectraAutoComplet);
					}
//					console.log(json);
					if (results.length==1)
						results = new Array();
					
					callbackProcess(results);
					showAutocompleteLoadingPanel(false);
			},
			error : function(xhr) {
				subjects = [];
				// TODO alert error xhr.responseText
				console.log(xhr);

				results = new Array();
				callbackProcess(results);
				showAutocompleteLoadingPanel(false);
			}
		});
	}
};

matchingSpectraKeywords = function (rawQwery, results) {
	var outData = "";
	var tab = rawQwery.split(" ");
	for (var i in tab){
		var keyword = tab[i];
		// if not last
// 		if (i < (tab.length -1))
// 			outData = outData + keyword;
// 		if (keyword.length < 5)
			//////////// NMR
			if (keyword.toLowerCase().startsWith("nm")) {
				outData = outData + "NMR";
			} else if (keyword.toLowerCase().startsWith("40")) {
				outData = outData + "400";
			} else if (keyword.toLowerCase().startsWith("50")) {
				outData = outData + "500";
			} else if (keyword.toLowerCase().startsWith("60")) {
				outData = outData + "600";
			} else if (keyword.toLowerCase().startsWith("70")) {
				outData = outData + "700";
			} else if (keyword.toLowerCase().startsWith("75")) {
				outData = outData + "750";
			} else if (keyword.toLowerCase().startsWith("80")) {
				outData = outData + "800";
			} else if (keyword.toLowerCase().startsWith("85")) {
				outData = outData + "850";
			} else if (keyword.toLowerCase().startsWith("90")) {
				outData = outData + "900";
			} else if (keyword.toLowerCase().startsWith("10")) {
				outData = outData + "1000";
			} else if (keyword.toLowerCase().startsWith("12")) {
				outData = outData + "1200";
			}
			//////////// 1D NMR
			else if (keyword.toLowerCase().startsWith("pr")) {
				outData = outData + "proton";
			} else if (keyword.toLowerCase().startsWith("no")) {
				results.push("NOESY-1D");
				results.push("NOESY-2D");
				outData = outData + " ";
			} else if (keyword.toLowerCase().startsWith("cp")) {
				outData = outData + "CPMG";
			} else if (keyword.toLowerCase().startsWith("car")) {
				outData = outData + "Carbon-13";
			} 
			//////////// 2D NMR
			else if (keyword.toLowerCase().startsWith("co")) {
				outData = outData + "COSY-2D";
			} else if (keyword.toLowerCase().startsWith("jr")) {
				outData = outData + "JRES";
			} else if (keyword.toLowerCase().startsWith("to")) {
				outData = outData + "TOCSY-2D";
			} else if (keyword.toLowerCase().startsWith("hm")) {
				outData = outData + "HMBC-2D";
			} else if (keyword.toLowerCase().startsWith("hs")) {
				outData = outData + "HSQC-2D";
			} 
			//////////// LCMS
			else if (keyword.toLowerCase().startsWith("lc")) {
				outData = outData + "LC-MS";
			} else if (keyword.toLowerCase().startsWith("to")) {
				outData = outData + "TOF";
			} else if (keyword.toLowerCase().startsWith("qt")) {
				outData = outData + "QTOF";
			} else if (keyword.toLowerCase().startsWith("qq")) {
				outData = outData + "QQQ";
			} 
			//////////// LCMSMS
			else if (keyword.toLowerCase().startsWith("lc-msm")||keyword.toLowerCase().startsWith("lc-ms2")) {
				outData = outData + "LC-MSMS";
			}
			//////////// MS
			else if (keyword.toLowerCase().startsWith("pos")) {
				outData = outData + "positive";
			} else if (keyword.toLowerCase().startsWith("neg")) {
				outData = outData + "negative";
			} else if (keyword.toLowerCase().startsWith("hig")) {
				outData = outData + "High";
			} else if (keyword.toLowerCase().startsWith("low")) {
				outData = outData + "Low";
			} 
			//////////// no match
			else {
				outData = outData + keyword;
			}
// 		else 
// 			outData = outData + keyword;
		outData = outData + " ";
	}
	var spectraAutoComplet = (outData.trim());
	if ($.inArray(spectraAutoComplet, results) === -1) results.push(spectraAutoComplet);
	return results;
}	

var isAdvancedModalLoaded = false;
$("#advancedBtn").click(function() {
	//$("#advancedModal").modal("show");
	if (isAdvancedModalLoaded) {
		$("#advancedModal").modal("show");
		loadRawQuery();
	} else {
		$("#advancedModal .modal-dialog").load("search-advanced-modal", function() { 
		$("#advancedModal").modal("show"); 
		isAdvancedModalLoaded = true;
	});
	}
});

$("#filterNMRtype").change(function() {
	var filterType = $("#filterNMRtype").val();
	switch(filterType){
	case "1":
		$(".filterType").hide();
		$("#filterNMRmagneticValue").show();
		break;
	case "2":
		$(".filterType").hide();
		$("#filterNMRpulseqValue").show();
		break;
	case "3":
		$(".filterType").hide();
		$("#filterNMRtextValue").show();
		break;
	case "4":
		$(".filterType").hide();
		$("#filterNMRsolventValue").show();
		break;
	}
});

hideshow = function (id) {
	var element = $("#"+id);
	if ($(element).is(":visible")) {
		$("#"+id).hide();
	} else {
		$("#"+id).show();
	}
}

addNMRfilter = function() {
	var filterType = $("#filterNMRtype").val();
	var filterValue = "";
	var newLabel = '';
	switch(filterType){
	case "1":
		var filterValue = $("#filterNMRmagneticValue").val();
		filterNMR[filterCpd]={"mfs":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__MAGNETIC_FIELD+': '+filterValue+' | <a href="#" onclick="removeNMRfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "2":
		var filterValue = $("#filterNMRpulseqValue").val();
		filterNMR[filterCpd]={"pulseq":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__PULSE_SEQ+': '+filterValue+' | <a href="#" onclick="removeNMRfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "3":
		var filterValue = $("#filterNMRtextValue").val();
		filterNMR[filterCpd]={"cpd":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__CPD_NAME+': '+filterValue+' | <a href="#" onclick="removeNMRfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "4":
		var filterValue = $("#filterNMRsolventValue").val();
		filterNMR[filterCpd]={"solvent":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__SOLVENT+': '+filterValue+' | <a href="#" onclick="removeNMRfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	}
	$("#filterNMRdisplay").append(newLabel);
	// filter in gui
	filterSearchResults(0, totalElementFound);
	filterCpd++;
}

removeNMRfilter = function(id) {
	filterNMR[id]=null;
	// filter in gui
	filterSearchResults(0, totalElementFound);
	// remove label
	$("#filter"+id).remove();
}

var isNMRModalLoaded = false;
openNMRtoolbox = function () {
	if (isNMRModalLoaded) {
		$("#NMRModal").modal("show");
		loadRawQueryNMR();
	} else {
		$("#NMRModal .modal-dialog").load("peakmatching-nmr-query-modal", function() { 
			$("#NMRModal").modal("show"); 
			isNMRModalLoaded = true;
		});
	}
};

$("#peakmatchingNMRmodalBtn").click(function() {
	openNMRtoolbox();
});
$("#searchNMR").click(function() {
	openNMRtoolbox();
});


$("#filterLCMStype").change(function() {
	var filterType = $("#filterLCMStype").val();
	switch(filterType){
	case "1":
		$(".filterType").hide();
		$("#filterLCMIonizationMethodValue").show();
		break;
	case "2":
		$(".filterType").hide();
		$("#filterLCMStextIonAnalyzerValue").show();
		break;
	case "3":
		$(".filterType").hide();
		$("#filterLCMStextCpdNameValue").show();
		break;
	}
});
addLCMSfilter = function() {
	var filterType = $("#filterLCMStype").val();
	var filterValue = "";
	var newLabel = '';
	switch(filterType){
	case "1":
		var filterValue = $("#filterLCMIonizationMethodValue").val();
		filterLCMS[filterCpd]={"ioniztionMethod":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__IONIZATION_METHOD+': '+filterValue+' | <a href="#" onclick="removeLCMSfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "2":
		var filterValue = $("#filterLCMStextIonAnalyzerValue").val();
		filterLCMS[filterCpd]={"ionAnalyzer":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__ION_ANALYZER+': '+filterValue+' | <a href="#" onclick="removeLCMSfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "3":
		var filterValue = $("#filterLCMStextCpdNameValue").val();
		filterLCMS[filterCpd]={"cpd":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__CPD_NAME+': '+filterValue+' | <a href="#" onclick="removeLCMSfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	}
	$("#filterLCMSdisplay").append(newLabel);
	// filter in gui
	filterSearchResults(0, totalElementFound);
	filterCpd++;
}

removeLCMSfilter = function(id) {
	filterLCMS[id]=null;
	// filter in gui
	filterSearchResults(0, totalElementFound);
	// remove label
	$("#filter"+id).remove();
}

var isLCMSModalLoaded = false;
openLCMStoolbox = function () {
	if (isLCMSModalLoaded) {
		$("#LCMSModal").modal("show");
		loadRawQueryLCMS();
	} else {
		$("#LCMSModal .modal-dialog").load("peakmatching-lcms-query-modal", function() { 
			$("#LCMSModal").modal("show"); 
			isLCMSModalLoaded = true;
		});
	}
};

$("#peakmatchingLCMSmodalBtn").click(function() {
	openLCMStoolbox();
});
$("#searchLCMS").click(function() {
	openLCMStoolbox();
});

///////////////////////////////////////////////////////////////////////////////
// NEW 2.0: MSMS matching
$("#filterLCMSMStype").change(function() {
	var filterType = $("#filterLCMSMStype").val();
	switch(filterType){
	case "1":
		$(".filterType").hide();
		$("#filterLCMSMSIonizationMethodValue").show();
		break;
	case "2":
		$(".filterType").hide();
		$("#filterLCMSMStextIonAnalyzerValue").show();
		break;
	case "3":
		$(".filterType").hide();
		$("#filterLCMSMStextCpdNameValue").show();
		break;
	}
});
addLCMSMSfilter = function() {
	var filterType = $("#filterLCMSMStype").val();
	var filterValue = "";
	var newLabel = '';
	switch(filterType){
	case "1":
		var filterValue = $("#filterLCMSMSIonizationMethodValue").val();
		filterLCMSMS[filterCpd]={"ioniztionMethod":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__IONIZATION_METHOD+': '+filterValue+' | <a href="#" onclick="removeLCMSMSfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "2":
		var filterValue = $("#filterLCMSMStextIonAnalyzerValue").val();
		filterLCMSMS[filterCpd]={"ionAnalyzer":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__ION_ANALYZER+': '+filterValue+' | <a href="#" onclick="removeLCMSMSfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	case "3":
		var filterValue = $("#filterLCMSMStextCpdNameValue").val();
		filterLCMSMS[filterCpd]={"cpd":filterValue};
		// create label
		newLabel = '<span id="filter'+filterCpd+'"><span class="label label-warning ">'+TXT_LABEL__CPD_NAME+': '+filterValue+' | <a href="#" onclick="removeLCMSMSfilter('+filterCpd+');"class="">&times;</a></span><span>&nbsp;</span></span>';
		break;
	}
	$("#filterLCMSMSdisplay").append(newLabel);
	// filter in gui
	filterSearchResults(0, totalElementFound);
	filterCpd++;
}

removeLCMSMSfilter = function(id) {
	filterLCMSMS[id]=null;
	// filter in gui
	filterSearchResults(0, totalElementFound);
	// remove label
	$("#filter"+id).remove();
}

var isLCMSMSModalLoaded = false;
openLCMSMStoolbox = function () {
	if (isLCMSMSModalLoaded) {
		$("#LCMSMSModal").modal("show");
		loadRawQueryLCMSMS();
	} else {
		$("#LCMSMSModal .modal-dialog").load("peakmatching-lcmsms-query-modal", function() { 
			$("#LCMSMSModal").modal("show"); 
			isLCMSMSModalLoaded = true;
		});
	}
};

$("#peakmatchingLCMSMSmodalBtn").click(function() {
	openLCMSMStoolbox();
});
$("#searchLCMSMS").click(function() {
	openLCMSMStoolbox();
});
///////////////////////////////////////////////////////////////////////////////

// modal gui interaction
$( document ).ready(function() {
	$("#link-pm-nmr").click(function() {
		if (($($("#searchNMR")).length)&&$("#searchNMR").val().trim()=="") {
			$("#peakmatchingNMRmodalBtn").click();
		}
	});
	$("#link-pm-lcms").click(function() {
		if (($($("#searchLCMS")).length)&&$("#searchLCMS").val().trim()=="") {
			$("#peakmatchingLCMSmodalBtn").click();
		}
	});
	// new 2.0: MSMS matching
	$("#link-pm-lcmsms").click(function() {
		if (($($("#searchLCMSMS")).length)&&$("#searchLCMSMS").val().trim()=="") {
			$("#peakmatchingLCMSMSmodalBtn").click();
		}
	});
});

// bop!
function hideSpectraScoreZeroF(tbody) {
	if (hideSpectraScoreZero) {
		var hasHide = false;
		$.each($("#"+tbody+" tr"), function() {
			var tr = $(this);
			if ($($(tr).find("td")[1]).html()=="0") { 
				$(tr).hide();
				hasHide = true;
			}
		});
		if (hasHide) {
			// add btn show
			$("#"+tbody+"").append('<tr id="lineBtnShowMore"><td colspan="4"><button class="btn btn-primary" onclick="showSpectraScoreZero(\''+tbody+'\')"><i class="fa fa-eye"></i> '+_txt_btn_showMode+'</button></td></tr>');
			// tmp hide pagination
			setTimeout(function(){if ($("#searchPagination").find("li.active a").html() == "1") { $("#searchPagination").hide();}},50);
		}
	}
}
function showSpectraScoreZero(tbody) {
	hideSpectraScoreZero = false;
	$("#searchPagination").show();
	$("#lineBtnShowMore").remove();
	$("#"+tbody+" tr").show();
}

// 
function countMaxResults() {
	var searchRequest = "query=" + rawSearchRequestQuery; 
	var rawSearchRequestQuery = $.trim($('#'+divSearch).val());
	var searchRequest = getSearchRequestFormated(searchRequest, rawSearchRequestQuery);
	searchRequest = "query=" + rawSearchRequestQuery;
	$.ajax({ 
		type: "post",
		url: "search-count",
		dataType: "json",
		async: true,
		data: searchRequest,
		success: function(json) {
			$("#searchExtraInfo").html(json + " relevant results." );
		},
		error : function(xhr) {
			console.log(xhr);
		}
	});
	isCountMaxResults = true;
	return;
}

function getSearchRequestFormated(searchRequest, rawSearchRequestQuery) {
	if (rawSearchRequestQuery.startsWith('"') && rawSearchRequestQuery.endsWith('"')) {
		searchRequest = "query=" + $.trim((rawSearchRequestQuery).replace(/"/g,''));
	} else if (rawSearchRequestQuery.indexOf(":") > -1) {
		var cleanQuery = "";
		var qFilterEntity = null;
		var qFilterType = -1;
		var qFilterVal = "";
		var qFilterVal2 = "";
		var qFilterVal3 = "";
		var rawQueryTab = rawSearchRequestQuery.split(" ");
		var specialQuery = false;
		$.each(rawQueryTab, function(k, v) {
			if (v != "") {
				var res = v.split(":");
				if (res != null && res.length == 2) {
					var filterType = res[0];
					var filterVal = res[1];
					switch (filterType) {
					case "AVM":
						var massData = filterVal.split("d");
						var mass = massData[0];
						var tol = massData[1];
						qFilterEntity = "compounds";
						qFilterType = Utils_SEARCH_COMPOUND_AVERAGE_MASS
						qFilterVal = mass;
						qFilterVal2 = tol;
						specialQuery = true;
						break;
					case "MIM":
						var massData = filterVal.split("d");
						var mass = massData[0];
						var tol = massData[1];
						qFilterEntity = "compounds";
						qFilterType = Utils_SEARCH_COMPOUND_MONOISOTOPIC_MASS
						qFilterVal = mass;
						qFilterVal2 = tol;
						specialQuery = true;
						break;
					case "mode":
						qFilterVal3 = filterVal;
						qFilterEntity = "compounds";
//						specialQuery = true;
						break;
					case "FOR":
						qFilterEntity = "compounds";
						qFilterType = Utils_SEARCH_COMPOUND_FORMULA
						qFilterVal = filterVal;
						qFilterVal2 = "";
						specialQuery = true;
						break;
					case "NMR":
						qFilterEntity = "nmr-spectra";
						var jsonData = JSON.parse(filterVal.replace(/=/g, ':'));
						cleanQuery = jsonData.pl;
						qFilterType = -1;
						qFilterVal = jsonData.d;
						qFilterVal2 = jsonData.mm + '-' +jsonData.pH;
						break;
					case "LC-MS":
					case "LCMS":
						qFilterEntity = "lcms-spectra";
						var jsonData = JSON.parse(filterVal.replace(/=/g, ':'));
						cleanQuery = jsonData.pl + ';' +jsonData.rtl+';'+ jsonData.col;
						qFilterType = -1;
						qFilterVal = jsonData.pol + ';' + jsonData.res + ';' + jsonData.algo;
						qFilterVal2 = jsonData.dM + ';' +jsonData.dT;
						break;
					case "LC-MSMS":
					case "LCMSMS":
						qFilterEntity = "lcmsms-spectra";
						var jsonData = JSON.parse(filterVal.replace(/=/g, ':'));
						//JSON.stringify(lcmsmsPeakList)
						cleanQuery = JSON.stringify(jsonData.pl) ;
						qFilterType = -1;
						qFilterVal = jsonData.pol + ';' + jsonData.res + ';';
						qFilterVal2 = jsonData.P + ';' +jsonData.dP + ';' +jsonData.dPL;
						if(jsonData.hasOwnProperty('dmz')) {
							qFilterVal2 += ''+jsonData.dmz+';'+jsonData.intexp+';'+jsonData.mzexp+';';     
						}
						break;
					default:
						qFilerEntity = "compounds";
						qFilterType = -1
						break;
					}//switch
				} else {
					cleanQuery += v + " ";
				}
			}
			//console.log(v);
		});
		if ($.trim(cleanQuery) == "" && !specialQuery)
			searchRequest = "query=" + $.trim(rawSearchRequestQuery);
		else {
			try {
				searchRequest = "query=" + $.trim(cleanQuery) + "&filterEntity="+ qFilterEntity + "&filerType="+ qFilterType + "&filterVal=" + qFilterVal + "&filterVal2=" + qFilterVal2 + "&filterVal3=" + qFilterVal3 ;
			} catch(e) {
				searchRequest = "query=" + $.trim(rawSearchRequestQuery) ;
			}
		}
	}
	return searchRequest;
}

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>LCMS PeakMatching</title>
<script src="<c:url value="/resources/handsontable/dist2/handsontable.full.min.js" />"></script>
<link rel="stylesheet" media="screen" href="<c:url value="/resources/handsontable/dist2/handsontable.full.min.css" />">
<link rel="stylesheet" media="screen" href="<c:url value="/resources/handsontable/bootstrap/handsontable.bootstrap.min.css" />">

<style type='text/css'>
</style>
<script type='text/javascript'>
	//<![CDATA[ 
	//]]>
</script>

</head>
<body>
	<div class="modal-dialog ">
		<div class="modal-content modalLarge">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.peakmatching.lcms.title" text="Peak Matching - LCMS" /></h4>
			</div>
			<div class="modal-body">
				<div class="te">
					<div class="col-lg-12">
						<div id="searchAdvance-mgmt-lcms" class="tab-content">
							<div class="" id="searchAdvance-spectra-lcms-panel">
								<div class="searchAdvance-spectra-lcms-panel-all">
									<div class="form-group input-group" style="">
										<label><spring:message code="modal.peakmatching.params.polarity" text="Polarity" />&nbsp;</label>
										<label class="radio-inline">
											<input type="radio" name="lcms-polarity" class="advancedSearch peakmatchingLCMSform" id="lcms-polarity-pos" value="pos"> <spring:message code="modal.peakmatching.params.polarity.pos" text="positive" />
										</label>
										<label class="radio-inline">
											<input type="radio" name="lcms-polarity" class="advancedSearch peakmatchingLCMSform" id="lcms-polarity-neg" value="neg"> <spring:message code="modal.peakmatching.params.polarity.neg" text="negative" />
										</label>
<!-- 										<label class="radio-inline"> -->
<!-- 											<input type="radio" name="lcms-polarity" class="advancedSearch peakmatchingLCMSform" id="lcms-polarity-neu" value="neu"> neutral -->
<!-- 										</label> -->
									</div>
									<div class="form-group input-group" style="">
										<label><spring:message code="modal.peakmatching.params.resolution" text="Resolution" />&nbsp;</label>
										<label class="radio-inline">
											<input type="checkbox" name="lcms-resolution" class="advancedSearch peakmatchingLCMSform" id="lcms-resolution-high" value="high" checked="checked" disabled="disabled"> <spring:message code="modal.peakmatching.params.resolution.high" text="high" />
										</label>
										<label class="radio-inline">
											<input type="checkbox" name="lcms-resolution" class="advancedSearch peakmatchingLCMSform" id="lcms-resolution-low" value="low"> <spring:message code="modal.peakmatching.params.resolution.low" text="low" />
										</label>
									</div>
									<div class="form-group input-group" style="width: 400px;">
										<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.peakmatching.params.algo" text="Algo Search" /></span>
										<select id="lcms-algo" class="advancedSearch form-control peakmatchingLCMSform" style="width: 250px;">
											<option value="" selected="selected" disabled="disabled"><spring:message code="modal.peakmatching.params.algo.choose" text="choose in list&hellip;" /></option>
											<option value="bih-mass" >BiH - mass</option>
											<option value="bih-mass-rt">BiH - mass &amp; RT</option>
											<option value="lcmsmatching-mass">LCMS Matching - mass</option>
											<option value="lcmsmatching-mass-rt">LCMS Matching - mass &amp; RT</option>
										</select>
									</div>
								</div><!-- searchAdvance-spectra-lcms-panel-all -->
								<div class="searchAdvance-spectra-lcms-panel-bih lcms-peakmatching" style="display:none;">
									<!-- CROMATO OPT: YES/ NOPE -->
									<div class="form-group input-group lcms-peakmatching-mass-rt"  style="display:none">
										<label><spring:message code="modal.peakmatching.params.filterChromato" text="Filter Chromatography" />&nbsp;</label>
										<label class="radio-inline">
											<input type="checkbox" name="lcms-filter-chromato" class="advancedSearch peakmatchingLCMSform" id="lcms-filter-chromato-yes" value="yes"> yes
										</label>
									</div>
									<!-- START CHROMATO OPT -->
									<div class=" col-lg-12 lcms-peakmatching-mass-rt" style="display:none;">
										<div class="form-group input-group col-lg-6 lcms-filter-chromato-yes" style=" display: none;">
											<span class="input-group-addon" style="">Constructor</span>
											<select id="lcms-mass-rt-filter-col-constructor" class="advancedSearch peakmatchingLCMSform form-control" style="">
												<option value=""></option>
											</select>
										</div>
										<div class="form-group input-group col-lg-6 lcms-filter-chromato-yes" style=" display: none;">
											<span class="input-group-addon" style=";">Mode</span>
											<select id="lcms-mass-rt-filter-col-mode" class="advancedSearch peakmatchingLCMSform form-control" style="">
												<option value=""></option>
											</select>
										</div> 
										<div class="form-group input-group col-lg-6 lcms-filter-chromato-yes" style="display: none;">
											<span class="input-group-addon" style="">Col. length <small>(mm)</small></span>
											<select id="lcms-mass-rt-filter-col-length" class="advancedSearch peakmatchingLCMSform form-control" style="">
												<option value=""></option>
											</select>
										</div>
										<div class="form-group input-group col-lg-6 lcms-filter-chromato-yes" style="display: none;">
											<span class="input-group-addon" style="">Col. diameter <small>(mm)</small></span>
											<select id="lcms-mass-rt-filter-col-diameter" class="advancedSearch peakmatchingLCMSform form-control" style="">
												<option value=""></option>
											</select>
										</div>
										<div class="form-group input-group col-lg-6 lcms-filter-chromato-yes" style="display: none;">
											<span class="input-group-addon" style="">Col. particule size <small>(&micro;m)</small></span>
											<select id="lcms-mass-rt-filter-col-particule-size" class="advancedSearch peakmatchingLCMSform form-control" style="">
												<option value=""></option>
											</select>
										</div>
										<div class="form-group input-group col-lg-6 lcms-filter-chromato-yes" style="display: none;">
											<span class="input-group-addon" style="">Flow rate <small>(&micro;L/min)</small></span>
											<select id="lcms-mass-rt-filter-col-flow-rate" class="advancedSearch peakmatchingLCMSform form-control" style="">
												<option value=""></option>
											</select>
										</div>
									</div>
									<!-- END CHROMATO OPT -->
									<!-- PEAK LISTS -->
									<div class="form-group input-group lcms-peakmatching-mass" style="width: 700px;">
										<label class="text-inline"><spring:message code="modal.peakmatching.params.peakList" text="Peak list" /> <small>(M/Z)</small></label>
										<textarea id="lcms-peakmatching-peaklist" class="form-control lcmsSearch"
											placeholder="<spring:message code="modal.peakmatching.params.peakList.ph" text="enter a list of peaks (M/Z), one per line" />" rows="4"></textarea>
									</div>
									<div class="form-group input-group lcms-peakmatching-mass-rt" style="width: 700px; display: none;">
										<label class="text-inline"><spring:message code="modal.peakmatching.params.peakListRTList" text="Peaks &amp; RT list" /></label>
										<div id="container_peakmatching_mass_rt" class="handsontable"></div>
										<br />
										<br />
										<br />
									</div>
									<!-- TOL MASS -->
									<div class="col-lg-12 lcms-peakmatching-mass-rt lcms-peakmatching-mass">
										<div class="col-lg-6" style="z-index:20000">
											<div class="form-group input-group" style="width: 300px;">
												<span class="input-group-addon" style="width: 150px;">
													<spring:message code="modal.peakmatching.params.massTol" text="Mass tolerance" />
													<small>(M/Z)</small></span> <input id="lcms-peakmatching-tolerance-mass" style="width: 150px;"
													type="number" min="0" max="0.1" step="0.001" class="lcmsSearch form-control"
													placeholder="0.005" value="0.005">
											</div>
										</div>
										<div class="col-lg-6" style="z-index:20000">
											<input id="massTol" data-slider-id='ex1Slider' type="text" data-slider-min="0" data-slider-max="0.1" data-slider-step="0.001" data-slider-value="0.005"/>
										</div>
									</div>
									<div class="col-lg-12 lcms-peakmatching-mass-rt lcms-peakmatching-mass"><br /></div>
									<div class="col-lg-12 lcms-peakmatching-mass-rt lcms-peakmatching-mass"><br /></div>
									<div class="col-lg-12 lcms-peakmatching-mass-rt lcms-peakmatching-mass"><br /></div>
									<!-- TOL RT -->
									<div class="col-lg-12 lcms-peakmatching-mass-rt">
										<div class="col-lg-6" style="z-index:20000">
											<div class="form-group input-group" style="width: 300px;">
												<span class="input-group-addon" style="width: 150px;">
													<spring:message code="modal.peakmatching.params.rtTol" text="RT tolerance" />
													<small>(min)</small></span> <input id="lcms-peakmatching-tolerance-rt" style="width: 150px;"
													type="number" min="0" max="0.5" step="0.1" class="lcmsSearch form-control"
													placeholder="0.1" value="0.1">
											</div>
										</div>
										<div class="col-lg-6" style="z-index:20000">
											<input id="rtTol" data-slider-id='ex2Slider' type="text" data-slider-min="0" data-slider-max="0.5" data-slider-step="0.1" data-slider-value="0.1"/>
										</div>
									</div>
									<div class="col-lg-12 lcms-peakmatching-mass-rt"><br /></div>
									<div class="col-lg-12 lcms-peakmatching-mass-rt"><br /></div>
									<div class="col-lg-12 lcms-peakmatching-mass-rt"><br /></div>
									<!-- PAGE FOOTER -->
									<div class="col-lg-12">
										<hr />
										<button class="btn btn-info btn-xs pull-right" onclick="loadLCMSdemoDataMass()"><i class="fa fa-magic"></i> <spring:message code="modal.peakmatching.params.loadDemo" text="load demo" /></button>
										<span class="pull-right">&nbsp;</span>
										<button class="btn btn-warning btn-xs pull-right" onclick="resetLCMSdemoDataBiHmass()"><i class="fa fa-eraser"></i> <spring:message code="modal.peakmatching.params.resetForm" text="reset" /></button>
										<small class="lcms-bih-only ">
											<spring:message code="modal.peakmatching.params.bih.poweredBy" text="powered by <a href='http://galaxy.workflow4metabolomics.org/root?tool_id=toolshed4metabolomics.sb-roscoff.fr:9009/repos/pfem/bank_inhouse/bank_inhouse/1.0.0' target='_blank'>Bank in House</a> - &copy; INRA UMR 1019 - F.L.A.M.E. / W4M" />
										</small>
										<small class="lcms-cea-only ">
											<spring:message code="modal.peakmatching.params.lcmsmatching.poweredBy" text="powered by <a href='https://github.com/pierrickrogermele/lcmsmatching' target='_blank'>LCMS Matching</a> - &copy; CEA - MetaboHUB / W4M" />
										</small>
										<small class="lcms-cea-only lcms-bih-only">
											<hr />
										 	How scores are computed? 
										 	We get the count of similar peaks between the query and matched spectrum, then remove the sum of all deltas between earch query and matched peaks.
										 	Finally we divide this result by the number of matched spectra.
										</small>
									</div>
								</div><!-- ./searchAdvance-spectra-lcms-panel-bih -->
							</div>

						</div>
						<!-- /.row -->
						<script type="text/javascript">
// 						console.log("a " + searchAdvanceEntities);
						
function loadRawQueryLCMS() {
	var rawQuery = $("#searchLCMS").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	$.each(rawQueryTab, function(k, v) {
		if (v != "") {
			var res = v.split(":");
			if (res != null && res.length == 2) {
				var filterType = res[0];
				var filterVal = res[1];
				switch (filterType) {
				case "LCMS":
					try {
						var jsonData = JSON.parse(filterVal.replace(/=/g, ':'));
	 					// LCMS:{"pol"="'+lcmsPolarity+'","algo"="'+lcmsAlgo+'","dM"='+lcmsTolMass+',"dT"='+lcmsTolRT+',"res"="'+lcmsReso+'","pl"=['+lcmsPeakList+']",rtl"=['+lcmsRTList+'],col"=['+lcmsColList+']}';
						// polarity
						$("#lcms-polarity-" +jsonData.pol).prop('checked', true);
						// resolution
						if (jsonData.res=='h+l') {
							$("#lcms-resolution-low").prop('checked', true);
						}
						// algo
						switch(jsonData.algo) {
						case "BiH":
						case "LCMSMatching":
							if (jsonData.algo=="BiH")
								$("#lcms-algo").val('bih-mass');
							else if (jsonData.algo=="LCMSMatching")
								$("#lcms-algo").val('lcmsmatching-mass');
							var peakListRet = "";
			 				$.each(jsonData.pl, function(kE,vE){
								peakListRet += vE+"\n";
								$('#lcms-peakmatching-peaklist').val(peakListRet);
							});
			 				setTimeout(function(){
			 					$("#lcms-peakmatching-tolerance-mass").val(jsonData.dM);
			 					$("#lcms-peakmatching-tolerance-mass").change();
			 				},250);
	 		 				//$("#lcms-peakmatching-tolerance-rt").val();
							break;
						case "BiHrt":
						case "LCMSMatchingRT":
							if (jsonData.algo=="BiHrt")
								$("#lcms-algo").val('bih-mass-rt');
							else if (jsonData.algo=="LCMSMatchingRT")
								$("#lcms-algo").val('lcmsmatching-mass-rt');
							//
							var superTab = [];
							var init = false;
							$.each(jsonData.pl, function(kE,vE){
								superTab.push([jsonData.pl[kE], jsonData.rtl[kE] ]);
								init = true;
							});
							if (init)
								setTimeout(function(){ handsontableBiHmassRT(superTab); },250);
							// 
	// 						$.each(jsonData.pl, function(kE,vE){
	// 							listColumnToSearch.push(vE);
	// 						});
							setTimeout(function(){
								listColumnToSearch=jsonData.col;
								if (listColumnToSearch.length>0) {
									$("#lcms-filter-chromato-yes").prop("checked",true);
									checkShowChromatoForm();
								}
							},250);
							//
							setTimeout(function(){
								$("#lcms-peakmatching-tolerance-mass").val(jsonData.dM);
								$("#lcms-peakmatching-tolerance-mass").change();
							},250);
							setTimeout(function(){
								$("#lcms-peakmatching-tolerance-rt").val(jsonData.dT);
								$("#lcms-peakmatching-tolerance-rt").change();
							},250);
							break;
							// TODO LCMSMatching MASS
							// TODO LCMSMatching MASS RT
						}
					}catch(e){}
					break;
				default: 
					break;
				}//switch
			} else {
				query += v + " ";
			}
		}
		//console.log(v);
		setTimeout(function(){$("#lcms-algo").change();},200);
	});
	$("#advancedSearchCompQuery").val(query);
	//console.log(query);
	
	$('#lcms-peaklist').focus(function(){
		this.selectionStart = this.selectionEnd = this.value.length;
	});
	setTimeout(function(){$("#lcms-peaklist").focus();},200);
}

loadRawQueryLCMS();


submitLCMSpeakmatchingForm = function() {
	loadAdvancedSearchLCMS(null);
	$("#searchFormLCMS").submit();
};

$(".peakmatchingLCMSform").change(function() {
	loadAdvancedSearchLCMS(this);
});

function loadAdvancedSearchLCMS(elem) {
	var e = $(elem);
	var id = e.attr('id');
	var val = e.val();
	//
	var mainSearchQuery = "";
	//
	var lcmsPolarity = $('input[name="lcms-polarity"]:checked').val();
	var lcmsReso = "h";
	if ($("#lcms-resolution-low").is(':checked'))
		lcmsReso = "h+l";
	var lcmsAlgo = null;
	var lcmsPeakList = [];
	var lcmsRTList = [];
	var lcmsColList = [];
	var lcmsTolMass = null;
	var lcmsTolRT = null;
	
	var algoSelect = $("#lcms-algo").val();
	switch (algoSelect) {
	case "bih-mass":
	case "lcmsmatching-mass":
		if (algoSelect=="bih-mass")
			lcmsAlgo = "BiH";
		else if (algoSelect=="lcmsmatching-mass")
			lcmsAlgo = "LCMSMatching";
		$.each($("#lcms-peakmatching-peaklist").val().split("\n"), function() {
			var valAsDouble = Number(this.replace(/[^0-9\.]+/g,""));
			if (valAsDouble!="")
				lcmsPeakList.push(valAsDouble);
		});
		lcmsTolMass = $("#lcms-peakmatching-tolerance-mass").val();
// 		lcmsTolRT = $("#lcms-peakmatching-tolerance-rt").val();
		break;
	case "bih-mass-rt":
	case "lcmsmatching-mass-rt":
		if (algoSelect=="bih-mass-rt")
			lcmsAlgo = "BiHrt";
		else if (algoSelect=="lcmsmatching-mass-rt")
			lcmsAlgo = "LCMSMatchingRT";
		// peaklist / timelist
		try {
			$.each(hot_bih_mass_rt.getData(), function(){
				var formatData = {};
				if (this[0]!= undefined && this[0] != "") {
					var valAsDoubleMass = Number(this[0]);
					var valAsDoubleRT = Number(this[1]);
					if (valAsDoubleMass!="" && valAsDoubleRT!="") {
						lcmsPeakList.push(valAsDoubleMass);
						lcmsRTList.push(valAsDoubleRT);
					}
				}
			});
		} catch(e){}
		//  collist
		if ($("#lcms-filter-chromato-yes").is(":checked"))
			$.each(listColumnToSearch,function(kE,vE){
				lcmsColList.push('"'+vE+'"');
			}); 
		// delta
		lcmsTolMass = $("#lcms-peakmatching-tolerance-mass").val();
		lcmsTolRT = $("#lcms-peakmatching-tolerance-rt").val();
		break;
		// TODO case CEA
	}
	//
	mainSearchQuery = 'LCMS:{"pol"="'+lcmsPolarity+'","algo"="'+lcmsAlgo+'","dM"='+lcmsTolMass+',"dT"='+lcmsTolRT+',"res"="'+lcmsReso+'","pl"=['+lcmsPeakList+'],"rtl"=['+lcmsRTList+'],"col"=['+lcmsColList+']}';
	if (mainSearchQuery != "") {
		$("#searchLCMS").val(mainSearchQuery);
	}
}

/**
 * fullfile form for LCMS search
 */
function loadLCMSdemoDataMass() {
	// polarity
	$("#lcms-polarity-pos").prop('checked', true);
	// resolution
	$("#lcms-resolution-low").prop('checked', false);
	// algo
	$("#lcms-algo").val('lcmsmatching-mass');
	$('#lcms-peakmatching-peaklist').val("154.0499\n152.0352\n123.45\n124.96");
		
	$("#lcms-peakmatching-tolerance-mass").val(0.05);
	$("#lcms-peakmatching-tolerance-mass").change();
	$("#lcms-algo").change();
		
}

/**
 * reset form for LCMS search
 */
function resetLCMSdemoDataBiHmass() {
	$('input[name="lcms-polarity"]').prop("checked",false);
	$('#lcms-resolution-low').prop("checked",false);
	$('#lcms-algo').val('');
	
	$('#lcms-peakmatching-peaklist').val('');
	handsontableBiHmassRT(null);
	
	$('#lcms-peakmatching-tolerance-mass').val('0.05');
	$('#lcms-peakmatching-tolerance-rt').val('0.1');
	
	$('#lcms-algo').change();
}

$("#lcms-algo").on("change", function() {
	$(".lcms-peakmatching").show();
	$(".lcms-peakmatching-mass").hide();
	$(".lcms-peakmatching-mass-rt").hide();
	
	$(".lcms-bih-only").hide();
	$(".lcms-cea-only").hide();
	switch($(this).val()) {
	case "bih-mass":
		$(".lcms-peakmatching").show();
		$(".lcms-peakmatching-mass").show();
		$(".lcms-bih-only").show();
		break;
	case "bih-mass-rt":
		$(".lcms-peakmatching").show();
		$(".lcms-peakmatching-mass-rt").show();
		$(".lcms-bih-only").show();
		checkShowChromatoForm();
		if ($("#container_peakmatching_mass_rt").html()=="")
			handsontableBiHmassRT(null);
		break;
	case "lcmsmatching-mass":
		$(".lcms-peakmatching").show();
		$(".lcms-peakmatching-mass").show();
		$(".lcms-cea-only").show();
		break;
	case "lcmsmatching-mass-rt":
		$(".lcms-peakmatching").show();
		$(".lcms-peakmatching-mass-rt").show();
		$(".lcms-cea-only").show();
		checkShowChromatoForm();
		if ($("#container_peakmatching_mass_rt").html()=="")
			handsontableBiHmassRT(null);
		break;
	}
});

//////////////////////////////////////////////////////////////////////////////
// BiH
// slider
$(function() {
	$('#massTol').slider({
		formatter: function(value) {
			$("#lcms-peakmatching-tolerance-mass").val(value);
			return 'Current value: ' + value;
		}
	});
	$('#rtTol').slider({
		formatter: function(value) {
			$("#lcms-peakmatching-tolerance-rt").val(value);
			return 'Current value: ' + value;
		}
	});
});
$("#lcms-peakmatching-tolerance-mass").on("change", function() {
	$('#massTol').slider("destroy");
	$("#ex1Slider").remove();
	$('#massTol').parent().find(".slider").remove()
	var val = Number($("#lcms-peakmatching-tolerance-mass").val());
	// $("#massTol").prop("data-slider-value", val);
	$('#massTol').slider({
		value: val,
		formatter: function(value) {
			$("#lcms-peakmatching-tolerance-mass").val(value);
			return 'Current value: ' + value;
		}
	});
	
});
$("#lcms-peakmatching-tolerance-rt").on("change", function() {
	$('#rtTol').slider("destroy");
	$("#ex2Slider").remove();
	$('#rtTol').parent().find(".slider").remove()
	var val = Number($("#lcms-peakmatching-tolerance-rt").val());
	$('#rtTol').slider({
		value: val,
		formatter: function(value) {
			$("#lcms-peakmatching-tolerance-rt").val(value);
			return 'Current value: ' + value;
		}
	});
});
	
///////////////////////////////
// V 1.0: chromato filter

// fetch list columns + codes
var jsonColLCMS = {};
$.ajax({
	type : "get",
	dataType : "json",
	url : 'metadata/lcms/list-code-columns'
}).done(function(data) {
	jsonColLCMS = data;
	loadLCMScolumnsData()
}).always(function(jqXHR, textStatus) {
	if (textStatus != "success") {
		// fail
		if(jqXHR.status==404)
			console.log("[ERROR] Webservice change address.");
		else
			alert("Error: " + jqXHR.statusText);
	}
});
	
listConstructor = [];
listDiameter = [];
listFlowRate = [];
listLength = [];
listMode = [];
// 	listName = [];
listParticuleSize = [];

currentConstructor = "";
currentDiameter = "";
currentFlowRate = "";
currentLength = "";
currentMode = "";
// 	currentName = [];
currentParticuleSize = "";

listColumnToSearch = [];

function loadLCMScolumnsData() {
	// load from json
	$.each(jsonColLCMS, function(key, val) { 
		buildFilterLists(val);
	});
	// build html forms
	buildHTMLcolForms();
}

buildFilterLists = function (val) {
	// constructor: "waters"
	if ($.inArray(val.constructor, listConstructor)==-1)
		listConstructor.push(val.constructor);
	// diameter: 2.1
	if ($.inArray(val.diameter, listDiameter)==-1)
		listDiameter.push(val.diameter);
	// flow_rate: 400
	if ($.inArray(val.flow_rate, listFlowRate)==-1)
		listFlowRate.push(val.flow_rate);
	// length: 150
	if ($.inArray(val.length, listLength)==-1)
		listLength.push(val.length);
	// mode: "gradient"
	if ($.inArray(val.mode, listMode)==-1)
		listMode.push(val.mode);
	// name: "Acquity UPLC HSS T3"
//			if ($.inArray(val.name, listName)==-1)
//				listName.push(val.name);
	// particule_size: 1.8
	if ($.inArray(val.particule_size, listParticuleSize)==-1)
		listParticuleSize.push(val.particule_size);
};
	
buildHTMLcolForms = function() {
	
	$("#lcms-mass-rt-filter-col-constructor").empty();
	$("#lcms-mass-rt-filter-col-constructor").append('<option value=""></option>');
	
	$("#lcms-mass-rt-filter-col-mode").empty();
	$("#lcms-mass-rt-filter-col-mode").append('<option value=""></option>');
	
	$("#lcms-mass-rt-filter-col-length").empty();
	$("#lcms-mass-rt-filter-col-length").append('<option value=""></option>');
	
	$("#lcms-mass-rt-filter-col-diameter").empty();
	$("#lcms-mass-rt-filter-col-diameter").append('<option value=""></option>');
	
	$("#lcms-mass-rt-filter-col-particule-size").empty();
	$("#lcms-mass-rt-filter-col-particule-size").append('<option value=""></option>');
	
	$("#lcms-mass-rt-filter-col-flow-rate").empty();
	$("#lcms-mass-rt-filter-col-flow-rate").append('<option value=""></option>');
	
	$.each(listConstructor, function(key, val){
		var selected = '';
		if (currentConstructor == val)
			selected = ' selected="selected"';
		$("#lcms-mass-rt-filter-col-constructor").append('<option value="'+val+'"'+selected+'>'+val+'</option>');
	})
	$.each(listMode, function(key, val){
		var selected = '';
		if (currentMode == val)
			selected = ' selected="selected"';
		$("#lcms-mass-rt-filter-col-mode").append('<option value="'+val+'"'+selected+'>'+val+'</option>');
	})
	$.each(listLength, function(key, val){
		var selected = '';
		if (currentLength == val)
			selected=' selected="selected"';
		$("#lcms-mass-rt-filter-col-length").append('<option value="'+val+'"'+selected+'>'+val+'</option>');
	})
	$.each(listDiameter, function(key, val){ 
		var selected = '';
		if (currentDiameter == (val+''))
			selected = ' selected="selected"';
		$("#lcms-mass-rt-filter-col-diameter").append('<option value="'+val+'"'+selected+'>'+val+'</option>');
	})
	$.each(listParticuleSize, function(key, val){ 
		var selected = '';
		if (currentParticuleSize == (val+''))
			selected = ' selected="selected"';
		$("#lcms-mass-rt-filter-col-particule-size").append('<option value="'+val+'"'+selected+'>'+val+'</option>');
	})
	$.each(listFlowRate, function(key, val){ 
		var selected = '';
		if (currentFlowRate == (val+''))
			selected = ' selected="selected"';
		$("#lcms-mass-rt-filter-col-flow-rate").append('<option value="'+val+'"'+selected+'>'+val+'</option>');
	})
	
}

$("#lcms-filter-chromato-yes").on("click", function(){
	checkShowChromatoForm();
});
checkShowChromatoForm = function() {
	if ($("#lcms-filter-chromato-yes").is(":checked"))
		$(".lcms-filter-chromato-yes").show();
	else 
		$(".lcms-filter-chromato-yes").hide();
}

$(".lcms-filter-chromato-yes select").on('change', function(){
	
	// reset list
	listConstructor = [];
	listDiameter = [];
	listFlowRate = [];
	listLength = [];
	listMode = [];
//	 	listName = [];
	listParticuleSize = [];
	
	listColumnToSearch = [];
	
	// reset current
	currentConstructor = "";
	currentDiameter = "";
	currentFlowRate = "";
	currentLength = "";
	currentMode = "";
//	 	currentName = [];
	currentParticuleSize = "";
	
	$.each(jsonColLCMS, function(key, val) { 
		var isFilter = false;
		if ($("#lcms-mass-rt-filter-col-constructor").val() != "" && $("#lcms-mass-rt-filter-col-constructor").val() != val.constructor) {
			isFilter = true;
		} 
		if ($("#lcms-mass-rt-filter-col-mode").val() != "" && $("#lcms-mass-rt-filter-col-mode").val() != val.mode) {
			isFilter = true;
		} 
		if ($("#lcms-mass-rt-filter-col-length").val() != "" && $("#lcms-mass-rt-filter-col-length").val() != val.length) {
			isFilter = true;
		}  
		if ($("#lcms-mass-rt-filter-col-diameter").val() != "" && Number($("#lcms-mass-rt-filter-col-diameter").val()) != (val.diameter) ) {
			isFilter = true; 
		} 
		if ($("#lcms-mass-rt-filter-col-particule-size").val() != "" && Number($("#lcms-mass-rt-filter-col-particule-size").val()) != (val.particule_size) ) {
			isFilter = true; 
		} 
		if ($("#lcms-mass-rt-filter-col-flow-rate").val() != "" && Number($("#lcms-mass-rt-filter-col-flow-rate").val()) != (val.flow_rate) ) {
			isFilter = true; 
		} 
		
		currentConstructor=$("#lcms-mass-rt-filter-col-constructor").val();
		currentMode = $("#lcms-mass-rt-filter-col-mode").val();
		currentLength = $("#lcms-mass-rt-filter-col-length").val();
		currentDiameter = $("#lcms-mass-rt-filter-col-diameter").val();
		currentParticuleSize = $("#lcms-mass-rt-filter-col-particule-size").val();
		currentFlowRate = $("#lcms-mass-rt-filter-col-flow-rate").val();
		
		if (!isFilter) {
			buildFilterLists(val);
			listColumnToSearch.push(key);
		}
	});
	buildHTMLcolForms();
});

///////////////////////////////
// handsontable
var container_peakmatching_mass_rt, hot_bih_mass_rt;
function handsontableBiHmassRT(data) {
	// reset
	$("#container_peakmatching_mass_rt").html("");
	// init
	var data_bih_mass_rt;
	if (data==null) {
		data_bih_mass_rt = [
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   		];
	} else {
		data_bih_mass_rt = data;
	}
	
	container_peakmatching_mass_rt = document.getElementById('container_peakmatching_mass_rt');
	hot_bih_mass_rt = new Handsontable(container_peakmatching_mass_rt, {
		data : data_bih_mass_rt,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["mass (Da)", "RT (min)"],
		contextMenu : false,
		stretchH: 'none',
		colWidths: [150, 150],
	});
	function bindDumpButton_bih_mass_rt() {
		Handsontable.dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON"&& element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_bih_mass_rt = window[instance];
				console.log('data of ' + name, hot_bih_mass_rt.getData());
			}
		});
	}
	bindDumpButton_bih_mass_rt();
	$("#container_peakmatching_mass_rt table.htCore").css("width","100%");
	hot_bih_mass_rt.selectCell(0,0);
}

//////////////////////////////////////////////////////////////////////////////
// CEA

						</script>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="closeLCMSsearchModal()"><spring:message code="modal.close" text="Close" /></button>
				<button type="button" class="btn btn-primary" onclick="submitLCMSpeakmatchingForm();">
					<i class="fa fa-search"></i> <spring:message code="modal.peakmatching.btnSearch" text="Search" />
				</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>

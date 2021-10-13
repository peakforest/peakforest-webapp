<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>LCMSMS PeakMatching</title>
<script src="<c:url value="/resources/handsontable/dist/handsontable.full.min.js" />"></script>
<link rel="stylesheet" media="screen" href="<c:url value="/resources/handsontable/dist/handsontable.full.min.css" />">
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
				<h4 class="modal-title"><spring:message code="modal.peakmatching.lcmsms.title" text="Peak Matching - LCMSMS" /></h4>
			</div>
			<div class="modal-body">
				<div class="te">
					<div class="col-lg-12">
						<div id="searchAdvance-mgmt-lcmsms" class="tab-content">
							<div class="" id="searchAdvance-spectra-lcmsms-panel">
								<div class="searchAdvance-spectra-lcmsms-panel-all">
									<div class="form-group input-group" style="">
										<label><spring:message code="modal.peakmatching.params.polarity" text="Polarity" />&nbsp;</label>
										<label class="radio-inline">
											<input type="radio" name="lcmsms-polarity" class="advancedSearch peakmatchingLCMSMSform" id="lcmsms-polarity-pos" value="pos"> <spring:message code="modal.peakmatching.params.polarity.pos" text="positive" />
										</label>
										<label class="radio-inline">
											<input type="radio" name="lcmsms-polarity" class="advancedSearch peakmatchingLCMSMSform" id="lcmsms-polarity-neg" value="neg"> <spring:message code="modal.peakmatching.params.polarity.neg" text="negative" />
										</label>
									</div>
									<!-- 
									<div class="form-group input-group" style="">
										<label><spring:message code="modal.peakmatching.params.resolution" text="Resolution" />&nbsp;</label>
										<label class="radio-inline">
											<input type="checkbox" name="lcmsms-resolution" class="advancedSearch peakmatchingLCMSMSform" id="lcmsms-resolution-high" value="high" checked="checked" disabled="disabled"> <spring:message code="modal.peakmatching.params.resolution.high" text="high" />
										</label>
										<label class="radio-inline">
											<input type="checkbox" name="lcmsms-resolution" class="advancedSearch peakmatchingLCMSMSform" id="lcmsms-resolution-low" value="low"> <spring:message code="modal.peakmatching.params.resolution.low" text="low" />
										</label>
									</div>
									 -->
									<!-- <div class="form-group input-group" style="width: 400px;">
										<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.peakmatching.params.algo" text="Algo Search" /></span>
										<select id="lcmsms-algo" class="advancedSearch form-control peakmatchingLCMSMSform" style="width: 250px;">
											<option value="" selected="selected" disabled="disabled"><spring:message code="modal.peakmatching.params.algo.choose" text="choose in list&hellip;" /></option>
											<option value="lcmsmsmatching-mass">LCMSMS Matching - mass</option>
											<option value="lcmsmsmatching-mass-rt">LCMSMS Matching - mass &amp; RT</option>
										</select>
									</div>-->
									<!-- 
									// TODO basic options here
									// delta mz
									// ppm  -->
									<!-- PRECURSOR ION + PREC. ION TOL. -->
									<div class="col-lg-12" style="padding-left: 0px !important;">
										<div class="col-lg-4" style="padding-left: 0px !important;">
											<div class="form-group input-group" style="width: 225px;">
												<span class="input-group-addon" style="width: 150px;">
													<spring:message code="modal.peakmatching.params.precursor" text="Precursor Ion" />
													<small>(M/Z)</small></span> <input id="lcmsms-peakmatching-prec" style="width: 75px;"
													type="number" min="0" max="5000" step="0.01" class="lcmsmsSearch form-control peakmatchingLCMSMSform"
													placeholder="123.456" value="">
											</div>
										</div>
										<div class="col-lg-4" style="z-index:20000">
											<div class="form-group input-group" style="width: 175px;">
												<span class="input-group-addon" style="width: 115px;">
													<spring:message code="modal.peakmatching.params.precursor.tol" text="Prec tol." />
													<small>(MZ)</small></span> <input id="lcmsms-peakmatching-prec-tol" style="width: 60px;"
													type="number" min="0" max="3.0" step="0.1" class="lcmsmsSearch form-control peakmatchingLCMSMSform"
													placeholder="0.1" value="0.1">
											</div>
										</div>
										<div class="col-lg-4" style="z-index:20000">
											<input id="precTol" data-slider-id='exSliderPrec' type="text" data-slider-min="0" data-slider-max="3.0" data-slider-step="0.1" data-slider-value="0.1"/>
										</div>
									</div>
									<!-- PEAKLIST -->
									<div class="form-group input-group lcms-peakmatching-mass-ri" style="width: 700px;">
										<label class="text-inline"><spring:message code="modal.peakmatching.params.peakListRIList" text="Peaks &amp; RI list" /></label>
										<div id="container_peakmatching_mass_ri" class="handsontable"></div>
									</div>
									<!-- PEAKLIST TOL -->
									<div class="col-lg-12" style="padding-left: 0px !important;">
										<div class="col-lg-6" style="z-index:20000">
											<div class="form-group input-group" style="width: 300px;">
												<span class="input-group-addon" style="width: 200px;">
													<spring:message code="modal.peakmatching.params.peaklist.tol" text="Peaklist Mass tol." />
													<small>(ppm)</small></span> <input id="lcmsms-peakmatching-peaklist-tol" style="width: 100px;"
													type="number" min="0" max="10" step="0.1" class="lcmsmsSearch form-control peakmatchingLCMSMSform"
													placeholder="5.0" value="5.0">
											</div>
										</div>
										<div class="col-lg-6" style="z-index:20000">
											<input id="peakListTol" data-slider-id='exSliderPeakList' type="text" data-slider-min="0" data-slider-max="10.0" data-slider-step="0.1" data-slider-value="5.0"/>
										</div>
									</div>
									<div class="col-lg-12"><br /><br /><br /></div>
									<!-- ADVANCED OPT -->
									<div class="col-lg-12">
										<div class="form-group input-group lcms-peakmatching-mass-rt">
											<label><spring:message code="modal.peakmatching.params.advOpt.fullTxt" text="Advanced options" />&nbsp;</label>
											<label class="radio-inline">
												<input type="checkbox" name="lcmsms-adv-opt" class="advancedSearch peakmatchingLCMSMSform " id="lcmsms-adv-opt-yes" value="yes"> yes
											</label>
										</div>
									</div>
								</div><!-- searchAdvance-spectra-lcmsms-panel-all -->
								<!-- TODO advanced options here -->
								<div class="searchAdvance-spectra-lcmsms-panel-msmsAdvOpt" style="display:none;">
									<div class="col-lg-12" style="z-index: 1000;">
										<div class="col-lg-6" >
											<div class="form-group input-group" >
												<span class="input-group-addon" >
													DMZ<sup>(1)</sup>
												</span> 
												<input id="lcmsms-peakmatching-dmz" 
													type="number" min="0" step="0.001" class="lcmsmsSearch form-control peakmatchingLCMSMSform"
													placeholder="0.005" value="">
											</div>
										</div>
										<div class="col-lg-6" ><br /><br /><br /></div>
									</div><!-- ./col-12 -->
									<div class="col-lg-12" style="z-index: 1000;" >
										<div class="col-lg-6"  >
											<div class="form-group input-group" style="width: 225px;">
												<span class="input-group-addon" style="width: 150px;">
													INTEXP<sup>(2)</sup>
												</span> <input id="lcmsms-peakmatching-intexp" style="width: 75px;"
													type="number" min="0" step="0.1" class="lcmsmsSearch form-control peakmatchingLCMSMSform"
													placeholder="2.0" value="">
											</div>
										</div>
										<div class="col-lg-6"  >
											<div class="form-group input-group" style="width: 225px;">
												<span class="input-group-addon" style="width: 150px;">
													MZEXP<sup>(2)</sup>
												</span> <input id="lcmsms-peakmatching-mzexp" style="width: 75px;"
													type="number" min="0" step="0.1" class="lcmsmsSearch form-control peakmatchingLCMSMSform"
													placeholder="0.5" value="">
											</div>
										</div>
									</div>
									<div class="col-lg-12">
										<small>
											<br /><sup>(1)</sup>: minimal tol. to match peaks.
											<br /><sup>(2)</sup>: set default weight to MZ and RI.
										</small>
									</div>
								</div>
								<!-- load demo / reset btn / 'powered by' banner -->
									<div class="col-lg-12">
										<hr />
										<button class="btn btn-info btn-xs pull-right" onclick="loadLCMSMSdemoData()"><i class="fa fa-magic"></i> <spring:message code="modal.peakmatching.params.loadDemo" text="load demo" /></button>
										<span class="pull-right">&nbsp;</span>
										<button class="btn btn-warning btn-xs pull-right" onclick="resetLCMSMSdemoData()"><i class="fa fa-eraser"></i> <spring:message code="modal.peakmatching.params.resetForm" text="reset" /></button>
										<small class="">
											<spring:message code="modal.peakmatching.params.msmsmatching.poweredBy" text="powered by LCMSMS Matching - Alexis Delabrière &copy; CEA - MetaboHUB / W4M" />
											<hr />
										 	How scores are computed? 
										 	We get the count of similar peaks between the query and matched spectrum, then remove the sum of all deltas between earch query and matched peaks.
										 	Finally we divide this result by the number of matched spectra.
										</small>
									</div>
							</div>
						</div>
						<!-- /.row -->
						<script type="text/javascript">

						
function loadRawQueryLCMSMS() {
	var rawQuery = $("#searchLCMSMS").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	$.each(rawQueryTab, function(k, v) {
		if (v != "") {
			var res = v.split(":");
			if (res != null && res.length == 2) {
				var filterType = res[0];
				var filterVal = res[1];
				switch (filterType) {
				case "LCMSMS":
					try {
						var jsonData = JSON.parse(filterVal.replace(/=/g, ':'));
						// polarity
						$("#lcmsms-polarity-" +jsonData.pol).prop('checked', true);
						// resolution
// 						if (jsonData.res=='h+l') {
// 							$("#lcmsms-resolution-low").prop('checked', true);
// 						}
						// precursor
						if (jsonData.P != null) {
							$("#lcmsms-peakmatching-prec").val(jsonData.P);
						}
						if (jsonData.dP!=null) {
							setTimeout(function(){$("#lcmsms-peakmatching-prec-tol").val(jsonData.dP).change();},200);
						}
						// peaklist tol
						if (jsonData.dPL!=null) {
							setTimeout(function(){$("#lcmsms-peakmatching-peaklist-tol").val(jsonData.dPL).change();},200);
						}
						// peaklist
						handsontable_mass_ri(jsonData.pl);
						// other msms options
						if(jsonData.hasOwnProperty('dmz')) {
							//extraOpt = ',"dmz"="'+$("#lcmsms-peakmatching-dmz").val()+'","intexp"="'+$("#lcmsms-peakmatching-intexp").val()+'","mzexp"="'+$("#lcmsms-peakmatching-mzexp").val()+'"';
							setTimeout(function(){
								$("#lcmsms-adv-opt-yes").prop('checked', true).change()
								if (jsonData.dmz!=null) {
									$("#lcmsms-peakmatching-dmz").val(jsonData.dmz);
								}
								if (jsonData.intexp!=null) {
									$("#lcmsms-peakmatching-intexp").val(jsonData.intexp);
								}
								if (jsonData.mzexp!=null) {
									$("#lcmsms-peakmatching-mzexp").val(jsonData.mzexp);
								}
							},200);
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
		
	});
	$("#advancedSearchCompQuery").val(query);
	//console.log(query);
	
// 	$('#lcmsms-peaklist').focus(function(){
// 		this.selectionStart = this.selectionEnd = this.value.length;
// 	});
// 	setTimeout(function(){$("#lcmsms-peaklist").focus();},200);
}

loadRawQueryLCMSMS();

///////////////////////////////
//handsontable
var container_peakmatching_mass_ri, hot_mass_ri;
function handsontable_mass_ri(data) {
	// reset
	$("#container_peakmatching_mass_ri").html("");
	// init
	var data_mass_ri;
	if (data==null) {
		data_mass_ri = [
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   			[ "", "" ],
   		];
	} else {
		data_mass_ri = data;
	}
	
	container_peakmatching_mass_ri = document.getElementById('container_peakmatching_mass_ri');
	hot_mass_ri = new Handsontable(container_peakmatching_mass_ri, {
		data : data_mass_ri,
		minSpareRows : 1,
		colHeaders : true,
		colHeaders: ["M/Z", "RI (%)"],
		contextMenu : false
	});
	function bindDumpButton_mass_ri() {
		Handsontable.Dom.addEvent(document.body, 'click', function(e) {
			var element = e.target || e.srcElement;
			if (element.nodeName == "BUTTON"&& element.name == 'dump') {
				var name = element.getAttribute('data-dump');
				var instance = element.getAttribute('data-instance');
				var hot_mass_ri = window[instance];
				console.log('data of ' + name, hot_mass_ri.getData());
			}
		});
	}
	bindDumpButton_mass_ri();
	$("#container_peakmatching_mass_ri table.htCore").css("width","100%");
	setTimeout(function(){hot_mass_ri.selectCell(0,0);},100);
}

function initPeakListRITab () {
	if ($("#container_peakmatching_mass_ri").html()=="") {
		handsontable_mass_ri(null);
	} else {
		// already init: DO NOT TOUCH!!!
	}
}
initPeakListRITab ();

submitLCMSMSpeakmatchingForm = function() {
	loadAdvancedSearchLCMSMS(null);
	$("#searchFormLCMSMS").submit();
};

$(".peakmatchingLCMSMSform").change(function() {
	loadAdvancedSearchLCMSMS(this);
});

function loadAdvancedSearchLCMSMS(elem) {
	var e = $(elem);
	var id = e.attr('id');
	var val = e.val();
	//
	var mainSearchQuery = "";
	//
	var lcmsmsPolarity = $('input[name="lcmsms-polarity"]:checked').val();
	var lcmsmsReso = "h+l";
// 	if ($("#lcmsms-resolution-low").is(':checked'))
// 		lcmsmsReso = "h+l";
	// peaklist
	var lcmsmsPeakList = []; 
	$.each(hot_mass_ri.getData(), function(){
		if (this[0]!="" && this[0]!=null) { lcmsmsPeakList.push(Array(this[0],this[1])); }
	});
	// other
	var lcmsmsPrec = $("#lcmsms-peakmatching-prec").val();
	var lcmsmsPrecTol = $("#lcmsms-peakmatching-prec-tol").val();
	var lcmsmsPeakListTol = $("#lcmsms-peakmatching-peaklist-tol").val();
	//adv
	var extraOpt = '';
	if ($("#lcmsms-adv-opt-yes").is(":checked")) {
		extraOpt = ',"dmz"="'+$("#lcmsms-peakmatching-dmz").val()+'","intexp"="'+$("#lcmsms-peakmatching-intexp").val()+'","mzexp"="'+$("#lcmsms-peakmatching-mzexp").val()+'"';
	}
	// finalize
	mainSearchQuery = 'LCMSMS:{"pol"="'+lcmsmsPolarity+'","res"="'+lcmsmsReso+'","P"="'+lcmsmsPrec+'","dP"="'+lcmsmsPrecTol+'","dPL"="'+lcmsmsPeakListTol+'","pl"='+JSON.stringify(lcmsmsPeakList)+extraOpt+'}';
	if (mainSearchQuery != "") {
		$("#searchLCMSMS").val(mainSearchQuery);
	}
}

$("#lcmsms-adv-opt-yes").on('change', function(){
	if ($("#lcmsms-adv-opt-yes").is(":checked")) {
		$(".searchAdvance-spectra-lcmsms-panel-msmsAdvOpt").show();
	} else {
		$(".searchAdvance-spectra-lcmsms-panel-msmsAdvOpt").hide();
	}
});

/**
 * fullfile form for LCMSMS search
 */
function loadLCMSMSdemoData() {
	// polarity
	$("#lcmsms-polarity-neg").prop('checked', true);
	$("#lcmsms-polarity-pos").prop('checked', false);
	// resolution
// 	$("#lcmsms-resolution-low").prop('checked', false);
	// peaklist
	data_mass_ri = [
		[ "158.1", "100.0" ], 
		[ "112.0", "35.54" ], 
		[ "110.0", "12.8" ], 
		[ "141.1", "6.59" ], 
		[ "116.0", "4.56" ], 
		[ "140.3", "3.19" ], 
   	];
	handsontable_mass_ri(data_mass_ri);
	$("#lcmsms-peakmatching-prec").val("158.12");
	$("#lcmsms-peakmatching-prec-tol").val("0.1").change();
	$("#lcmsms-peakmatching-peaklist-tol").val("5.0").change();
	// adv opt
	$("#lcmsms-adv-opt-yes").prop('checked', false).change();
	$("#lcmsms-peakmatching-dmz").val("").change();
	$("#lcmsms-peakmatching-intexp").val("").change();
	$("#lcmsms-peakmatching-mzexp").val("").change();
}

/**
 * reset form for LCMSMS search
 */
function resetLCMSMSdemoData() {
	$('input[name="lcmsms-polarity"]').prop("checked",false);
// 	$('#lcmsms-resolution-low').prop("checked",false);
	// peaklist
	handsontable_mass_ri(null);
	$("#lcmsms-peakmatching-prec").val("");
	$("#lcmsms-peakmatching-prec-tol").val("0.1").change();
	$("#lcmsms-peakmatching-peaklist-tol").val("5.0").change();
	// adv opt
	$("#lcmsms-adv-opt-yes").attr('checked', false).change();
	$("#lcmsms-peakmatching-dmz").val("").change();
	$("#lcmsms-peakmatching-intexp").val("").change();
	$("#lcmsms-peakmatching-mzexp").val("").change();
}



//////////////////////////////////////////////////////////////////////////////
// slider
$(function() {
	$('#precTol').slider({
		formatter: function(value) {
			$("#lcmsms-peakmatching-prec-tol").val(value);
			return 'Current value: ' + value;
		}
	});
	$('#peakListTol').slider({
		formatter: function(value) {
			$("#lcmsms-peakmatching-peaklist-tol").val(value);
			return 'Current value: ' + value;
		}
	});
});
$("#lcmsms-peakmatching-prec-tol").on("change", function() {
	$('#precTol').slider("destroy");
	$("#exSliderPrec").remove();
	$('#precTol').parent().find(".slider").remove()
	var val = Number($("#lcmsms-peakmatching-prec-tol").val());
	// $("#massTol").prop("data-slider-value", val);
	$('#precTol').slider({
		value: val,
		formatter: function(value) {
			$("#lcmsms-peakmatching-prec-tol").val(value);
			return 'Current value: ' + value;
		}
	});
});
$("#lcmsms-peakmatching-peaklist-tol").on("change", function() {
	$('#peakListTol').slider("destroy");
	$("#exSliderPeakList").remove();
	$('#peakListTol').parent().find(".slider").remove()
	var val = Number($("#lcmsms-peakmatching-peaklist-tol").val());
	// $("#massTol").prop("data-slider-value", val);
	$('#peakListTol').slider({
		value: val,
		formatter: function(value) {
			$("#lcmsms-peakmatching-peaklist-tol").val(value);
			return 'Current value: ' + value;
		}
	});
});

						</script>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="closeLCMSMSsearchModal()"><spring:message code="modal.close" text="Close" /></button>
				<button type="button" class="btn btn-primary" onclick="submitLCMSMSpeakmatchingForm();">
					<i class="fa fa-search"></i> <spring:message code="modal.peakmatching.btnSearch" text="Search" />
				</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>

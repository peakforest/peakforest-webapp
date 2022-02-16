<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>NMR PeakMatching</title>


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
				<h4 class="modal-title"><spring:message code="modal.peakmatching.nmr.title" text="Peak Matching - NMR" /></h4>
			</div>
			<div class="modal-body">
				<div class="te">
					<div class="col-lg-12">
						<div id="searchAdvance-mgmt" class="tab-content">
							
							<div class="" id="searchAdvance-spectra-nmr-panel">
								
								<div class="form-group input-group" style="width: 150px;">
									<span class="input-group-addon" style="width: 50px;"><spring:message code="modal.peakmatching.params.pH" text="pH" /></span>
									<input id="nmr-ph" style="width: 100px;" type="number" class="peakmatchingNMRform form-control" placeholder="6" value="" style="width: 600px;" min="1" max="14">
								</div>
								
								<div class="form-group input-group" style="width: 700px;">
									<label class="text-inline"><spring:message code="modal.peakmatching.params.peakList" text="Peak list <small>(ppm)</small>" /></label>
									<textarea id="nmr-peaklist" class="form-control peakmatchingNMRform" placeholder="<spring:message code="modal.peakmatching.params.enterAPeakList" text="enter a list of peaks (ppm), one per line" />" rows="4"></textarea>
								</div>
								
								<div class="form-group input-group" style="">
									<label><spring:message code="modal.peakmatching.params.matchingMethod" text="Matching method:&nbsp;" /></label>
									<label class="radio-inline">
										<input type="radio" name="nmr-matchingMethod" class="peakmatchingNMRform" id="nmr-matchingMethod-all" value="all" checked="checked"> <spring:message code="modal.peakmatching.params.matchingMethodAll" text="All peaks" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="nmr-matchingMethod" class="peakmatchingNMRform" id="nmr-matchingMethod-one" value="one"> <spring:message code="modal.peakmatching.params.matchingMethodOne" text="At least one peak" />
									</label>
								</div>
								
								<div class="form-group input-group" style="width: 300px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.peakmatching.params.hTolerance" text="<sup>1</sup>H tolerance (ppm)" /></span>
									<input id="nmr-tolerance" style="width: 150px;" type="text" class="peakmatchingNMRform form-control" placeholder="0.02" value="0.02" style="width: 600px;">
								</div>

								<hr>
								<button class="btn btn-info btn-xs pull-right" onclick="loadNMRdemoData()"><i class="fa fa-magic"></i> <spring:message code="modal.peakmatching.params.loadDemo" text="load demo" /></button>
								<span class="pull-right">&nbsp;</span>
								<button class="btn btn-warning btn-xs pull-right" onclick="resetNMRdemoData()"><i class="fa fa-eraser"></i> <spring:message code="modal.peakmatching.params.resetForm" text="reset" /></button>
								<small><spring:message code="modal.peakmatching.params.poweredBy" text="powered by <a href='https://pmb-bordeaux.fr/PM/webapp' target='_blank'>NMR PeakMatching 1.0</a>  -  &copy; INRA UMR 1332 - MetaboHUB" /></small>
							</div>

						</div>
						<!-- /.row -->
						<script type="text/javascript">
// 						console.log("a " + searchAdvanceEntities);
						
function loadRawQueryNMR() {
	var rawQuery = $("#searchNMR").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	$.each(rawQueryTab, function(k, v) {
		if (v != "") {
			var res = v.split(":");
			if (res != null && res.length == 2) {
				var filterType = res[0];
				var filterVal = res[1];
				switch (filterType) {
				case "NMR":
					var jsonData = JSON.parse(filterVal.replace(/=/g, ':'));
					$("#nmr-tolerance").val(jsonData.d);
					$("#nmr-ph").val(jsonData.pH);
					if (jsonData.mm=="one") {
						$('#nmr-matchingMethod-all').prop('checked', false);
						$('#nmr-matchingMethod-one').prop('checked', true);
					} else {
						$('#nmr-matchingMethod-one').prop('checked', false);
						$('#nmr-matchingMethod-all').prop('checked', true);
					}
					var peakListRet = "";
					$.each(jsonData.pl, function(kE,vE){
						peakListRet += vE+"\n";
					});
					$('#nmr-peaklist').val(peakListRet);
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
	
	$('#nmr-peaklist').focus(function(){
		this.selectionStart = this.selectionEnd = this.value.length;
	});
	setTimeout(function(){$("#nmr-peaklist").focus();},200);
}

loadRawQueryNMR();


submitNMRpeakmatchingForm = function() {
	$("#searchFormNMR").submit();
};

$(".peakmatchingNMRform").change(function() {
	loadAdvancedSearchNMR(this);
});

function loadAdvancedSearchNMR(elem) {
	var e = $(elem);
	var id = e.attr('id');
	var val = e.val();
	//console.log("id="+id);
	//console.log("val="+val);
	var mainSearchQuery = "";// $("#search").val();;
	var nmrTol = $("#nmr-tolerance").val();
	var nmrMM = "all";
	if ($("#nmr-matchingMethod-one").is(':checked'))
		nmrMM = "one";
	var nmrPeakList = [];
	$.each($("#nmr-peaklist").val().split("\n"), function() {
		var valAsDouble = Number(this.replace(/[^0-9\.]+/g,""));
		if (valAsDouble!="")
			nmrPeakList.push(valAsDouble);
	});
	var pH = $("#nmr-ph").val();
	if (pH == "")
		pH = null;
	mainSearchQuery = 'NMR:{"pH"='+pH+',"d"='+nmrTol+',"mm"="'+nmrMM+'","pl"=['+nmrPeakList+']}';
	if (mainSearchQuery != "") {
		$("#searchNMR").val(mainSearchQuery);
	}
}

/**
 * fullfile form for NMR search
 */
function loadNMRdemoData() {
	$("#nmr-ph").val("7");
	$("#nmr-peaklist").val("5.242\n4.657\n3.92\n");
	
	$('#nmr-matchingMethod-one').prop('checked', true);
	$('#nmr-matchingMethod-all').prop('checked', false);
	
	$('#nmr-tolerance').val("0.02");
	$('#nmr-tolerance').change();
}

/**
 * reset form for NMR search
 */
function resetNMRdemoData() {
	$("#nmr-ph").val("");
	$("#nmr-peaklist").val("");
	
	$('#nmr-matchingMethod-one').prop('checked', false);
	$('#nmr-matchingMethod-all').prop('checked', true);
	
	$('#nmr-tolerance').val("0.02");
	$('#nmr-tolerance').change();
}
						</script>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="closeNMRsearchModal()"><spring:message code="modal.close" text="Close" /></button>
				<button type="button" class="btn btn-primary" onclick="submitNMRpeakmatchingForm();">
					<i class="fa fa-search"></i> <spring:message code="modal.peakmatching.btnSearch" text="Search" />
				</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>

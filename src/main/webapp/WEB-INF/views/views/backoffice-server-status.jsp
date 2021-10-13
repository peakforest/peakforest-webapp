<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<script src="<c:url value="/resources/highcharts/js/highcharts.alt.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/modules/exporting.min.js" />"></script>

<div class="col-lg-12">
	
	<div class="col-lg-8">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-bar-chart-o"></i> CPU load; Memory used</h3>
			</div>
			<div class="panel-body">
				<div id="containerServerStatus" style="height: 400px; margin: 0 auto; width: 100%; min-width: 500px;"></div>
			</div>
			<div class="panel-footer"><button id="systemGC" type="button" class="btn btn-primary"><i class="fa fa-coffee"></i> Call Garbage Collector</button></div>
		</div>
	</div>
	<div class="col-lg-4">
		<div id="backOfficeServerAltert"></div>
		<ul class="list-group" style="max-width: 600px;">
			<li class="list-group-item"><button id="cleanUploadFiles" class="btn btn-primary" onclick="deleteUploadedFiles();" type="button" style=""><i class="fa fa-eraser"></i> Clean uploaded files</button></li>
			<li class="list-group-item"><button id="cleanDownloadFiles" class="btn btn-primary" onclick="deleteGeneratedFiles();" type="button" style=""><i class="fa fa-eraser"></i> Clean generated files</button></li>
			<li class="list-group-item"><button id="showLogFiles" class="btn btn-primary" onclick="showLogModal();" type="button" style=""><i class="fa fa-eye"></i> Show PeakForest log</button></li>
			<li class="list-group-item"><a id="openPhpMyAdmin" class="btn btn-primary" target="_blank" href="<spring:message code="peakforest.admin.phpmyadmin" text="https://managers.pfem.clermont.inra.fr/phpmyadmin/index.php?server=3" />" type="button" style=""><i class="fa fa-database"></i> Open phpMyAdmin</a></li>
		</ul>
		<div id="containerDiskUsage" style="height: 300px; margin: 0 auto; width: 100%; min-width: 250px;"></div>
		<br />
		<small class="pull-right">Disk space: <span id="diskTotalSpace"></span>.</small>
	</div>	
	
</div>

<div class="modal " id="logModal" tabindex="-1" role="dialog" aria-labelledby="logModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content modalLarge">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="logModalLabel">show PeakForest logs</h4>
			</div>
			<div class="modal-body">
				<p id="logContent" style="overflow: auto; max-height: 500px; max-width: 1000px; font-family: Monospace; white-space: nowrap;">loading...</p>
				<div id="backOfficeLogAltert"></div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-primary" onclick="resetLogFile()"><i class="fa fa-refresh"></i> rotate log </button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><spring:message code="modal.close" text="Close" /></button>
				<!--        <button type="button" class="btn btn-primary"><spring:message code="modal.saveChanges" text="Save Changes" /></button>-->
			</div>
		</div>
	</div>
</div>


<script type="text/javascript">

function showLogModal() {
	$.ajax({
		type: 'get',
		url: 'server/show-log'
	}).done(function(data){
		if (data!="")
			$("#logContent").html(data.replace(/\n/gi, "<br>").replace(/fr.metabohub.peakforest.utils.SpectralDatabaseLogger/gi, ""));
		else 
			$("#logContent").html("log file is empty.");
		$('#logModal').modal('show');
	}).fail(function(data){
		var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
		alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not show log file content.';
		alert += ' </div>';
		$("#backOfficeServerAltert").html(alert);
	});
	
}

$("#systemGC").click(function(){
	callGC();
	return false;
});

function callGC(){
	$.ajax({
		type: 'post',
		url: 'server/call-gc'
	}).done(function(data){

	}).fail(function(data){ });
}

var serieCpuLoad;
var serieMemUsed;
// var serieMemHeap;

// var series_fileSize;

$(document).ready(function() {
	
	// opt
	Highcharts.setOptions({ global: {  useUTC: false } });

	// chart
	$('#containerServerStatus').highcharts({
		chart: {
			type: 'spline',
			animation: Highcharts.svg, // don't animate in old IE
			marginRight: 10,
			events: {
				load: function () {
					// set up the updating of the chart each second
					serieCpuLoad = this.series[0];
					serieMemUsed = this.series[1];
					serieMemHeap = this.series[2];
					
					setInterval(function () {
						// current time
						var x = (new Date()).getTime();
						$.ajax({
							type: 'POST',
							url: 'server/get-server-stats'
						}).done(function(data){
							serieCpuLoad.addPoint([x, (data.cpu_load * 100)], true, true);
							serieMemUsed.addPoint([x, (data.memory_load * 100)], true, true);
// 							serieMemHeap.addPoint([x, hp], true, true);
						}).fail(function(data){
						});

					}, 1000);
				}
			}
		},
		title: {
			text: 'Server status'
		},
		xAxis: {
			type: 'datetime',
			tickPixelInterval: 150
		},
		yAxis: {
			min: 0,
			title: {
				text: 'Usage (%)'
			},
			plotLines: [{
				value: 0,
				width: 1,
				color: '#808080'
			}]
		},
		tooltip: {
			formatter: function () {
				return '<b>' + this.series.name + '</b><br/>' +
					Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + '<br/>' +
					Highcharts.numberFormat(this.y, 2)  + "%";
			}
		},
		legend: {
			enabled: false
		},
		exporting: {
			enabled: false
		},
		// init series
		series: [{
			name: 'CPU load <small>(last minute)</small>',
			data: (function () {
				// generate an array of 'flat' data
				var data = [], time = (new Date()).getTime(), i;
				for (i = -190; i <= 0; i += 1) {
					data.push({
						x: time + i * 1000,
						y: 0
					});
				}
				return data;
			}())
		},{
			name: 'Memory usage',
			data: (function () {
				// generate an array of 'flat' data
				var data = [], time = (new Date()).getTime(), i;
				for (i = -190; i <= 0; i += 1) {
					data.push({
						x: time + i * 1000,
						y: 0
					});
				}
				return data;
			}())
		}]
// 		,{
// 			name: 'Heap space',
// 			data: (function () {
// 				// generate an array of 'flat' data
// 				var data = [], time = (new Date()).getTime(), i;
// 				for (i = -120; i <= 0; i += 1) {
// 					data.push({
// 						x: time + i * 1000,
// 						y: 0
// 					});
// 				}
// 				return data;
// 			}())
// 		}]
	});
	
	loadDiskUsageChart();
});


deleteGeneratedFiles = function() {
 	$.ajax({ 
 		type: "post",
 		url: "server/clean-generated-files",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
 			if (ret) {
 				loadDiskUsageChart();
 			} else {
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete generated files.';
 				alert += ' </div>';
 				$("#backOfficeServerAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete generated files.';
 			alert += ' </div>';
 			$("#backOfficeServerAltert").html(alert);
 		}
 	});
}

deleteUploadedFiles = function() {
 	$.ajax({ 
 		type: "post",
 		url: "server/clean-uploaded-files",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
 			if (ret) {
 				loadDiskUsageChart();
 			} else {
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete uploaded files.';
 				alert += ' </div>';
 				$("#backOfficeServerAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not delete uploaded files.';
 			alert += ' </div>';
 			$("#backOfficeServerAltert").html(alert);
 		}
 	});
}

function loadDiskUsageChart() {
	$('#containerDiskUsage').html("");
	
	$.ajax({
		type: 'post',
		url: 'server/get-disk-usage'
	}).done(function(dataDisk){
		console.log(dataDisk);
		$("#diskTotalSpace").html((dataDisk.total_size /1024 / 1024) + " mb");
		
		$('#containerDiskUsage').highcharts({
			chart: {
				plotBackgroundColor: null,
				plotBorderWidth: 0,
				plotShadow: false
			},
			title: {
				text: 'Disk<br>usage',
				align: 'center',
				verticalAlign: 'middle',
				y: 50
			},
			tooltip: {
				pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
			},
			plotOptions: {
				pie: {
					dataLabels: {
						enabled: true,
						distance: -50,
						style: {
							fontWeight: 'bold',
							color: 'white',
							textShadow: '0px 1px 2px black'
						}
					},
					startAngle: -90,
					endAngle: 90,
					center: ['50%', '75%']
				}
			},
			series: [{
				type: 'pie',
				name: 'Disk space',
				innerSize: '70%',
				data: [
					['locked', dataDisk.locked*100],
					['free', dataDisk.free*100],
					['used', dataDisk.used*100],
					['peakforest-data', dataDisk.pf_files],
					['uploaded files', dataDisk.uploaded_files*100],
					['generated files', dataDisk.generated_files*100],
					{
						name: 'unknown',
						y: 0,
						dataLabels: {
							enabled: false
						}
					}
				]
			}]
		});
	}).fail(function(dataDisk){
	});
}

resetLogFile = function() {
 	$.ajax({ 
 		type: "post",
 		url: "server/log-rotation",
 		async: true,
// 		data: "query=" + $('#search').val(),
 		success: function(ret) {
 			if (ret) {
 				$("#logModal").modal("hide");
 				$("#logContent").html("loading!")
 				showLogModal();
 			} else {
 				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not reset log files.';
 				alert += ' </div>';
 				$("#backOfficeLogAltert").html(alert);
 			}

 		},
 		error : function(xhr) {
 			console.log(xhr);
 			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
 			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
 			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not reset log file.';
 			alert += ' </div>';
 			$("#backOfficeLogAltert").html(alert);
 		}
 	});
}

</script>
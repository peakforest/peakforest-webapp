<%@page import="fr.metabohub.peakforest.utils.PeakForestUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<!--JS-->
<script src="<c:url value="/resources/highcharts/js/highcharts.alt.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/highcharts-more.alt.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/modules/exporting.min.js" />"></script>
<!-- <script src="http://code.highcharts.com/highcharts.js"></script> -->
<!-- <script src="http://code.highcharts.com/highcharts-more.js"></script> -->
<!-- <script src="http://code.highcharts.com/modules/exporting.js"></script> -->

<spring:message code="page.tools.massVsLogp.line1" text="This chart shows a representation of the PeakForest chemical library content repartition in two major biofluids (Human blood or urine). " />
<spring:message code="page.tools.massVsLogp.line2" text="This biological distribution is based on the use of the solubility property of each metabolite. " />
<br /><em><spring:message code="page.tools.massVsLogp.thxObabel1" text="The logP values are computed thanks to" /> <a href="http://openbabel.org/" target="_blank">Open Babel</a></em>
<spring:message code="page.tools.massVsLogp.thxObabel2" text="software" /> [<a target="_blank" href="http://www.jcheminf.com/content/3/1/33">J. Cheminf. 2011, 3:33</a>].
<br />
<div id="container-mass-vs-logp" style="width: 80%; height: 75%; max-height: 750px; max-width: 750px; margin: 0 auto"></div>

<br />
<small class="pull-right"><spring:message code="page.tools.massVsLogp.lastUpdate" text="Last update:" /> <span id="statMassVsLogPLastUpdate"></span>.</small>

<script type="text/javascript">
var activePoint = -1;
var dualDimData = [];
var inchikey2Dots = [];
var chartMassVsLogP = null;
$( document ).ready(function() {
	$.getJSON('json/<%=PeakForestUtils.getBundleConfElement("json.massVsLogP")%>', function(jsonData) {
		chartMassVsLogP = new Highcharts.Chart( {
			chart : { zoomType : 'xy', renderTo : 'container-mass-vs-logp' },
// 			zoomType : 'xy',
	        title: {
	            text: ('<spring:message code="page.tools.massVsLogp.chart.title" text="Mass vs Solubility" />'),
	            useHTML: true
	        },
	        subtitle: {
	            text: '<spring:message code="page.tools.massVsLogp.chart.subtitle" text="Monoisotopic mass vs LogP; pinch to zoom" />',
	            useHTML: true
	        },
	        xAxis: {
	            gridLineWidth: 1,
	            title: {
	                enabled: true,
	                text: '<spring:message code="page.tools.massVsLogp.chart.axisX" text="LogP" />'
	            },
	            startOnTick: true,
	            endOnTick: true,
	            showLastLabel: true,
				min : -8,
				max : 14
	        },
	        yAxis: {
	            title: {
	                text: '<spring:message code="page.tools.massVsLogp.chart.axisY" text="monoisotopic mass (Da)" />'
	            },
	            startOnTick: true,
	            min : 0,
	            endOnTick: true,
				max : 1500
	        },
	        legend: {
	            layout: 'vertical',
	            align: 'right',
	            verticalAlign: 'middle'
	        },
	        series: [{
	            name: '<spring:message code="page.tools.massVsLogp.chart.urine" text="Urine" />',
	            type: 'polygon',
	            data: [[-4, 0], [4, 0], [4, 2000], [-4, 2000]],
	            color: Highcharts.Color(Highcharts.getOptions().colors[6]).setOpacity(0.5).get(),
	            enableMouseTracking: false
	
	        }, {
	            name: '<spring:message code="page.tools.massVsLogp.chart.blood" text="Blood" />',
	            type: 'polygon',
	            data: [[-4, 0], [11, 0], [11, 2000], [-4, 2000]],
	            color: Highcharts.Color(Highcharts.getOptions().colors[3]).setOpacity(0.5).get(),
	            enableMouseTracking: false
	
	        }, {
	            name: '<spring:message code="page.tools.massVsLogp.chart.metabolites" text="Metabolite" />',
	            type: 'scatter',
	            color: Highcharts.getOptions().colors[1],
	            marker : {
                    enabled : true,
                    radius : 1
                },
	            data: jsonData.metabolites
	
	        }],
	        tooltip: {
// 	            headerFormat: '<b>{series.name}</b><br>',
// 	            pointFormat: 'LogP:{point.x}, monoisotopic mass: {point.y} Da' + dualDimData[point.x][point.y]
				formatter : function() {
					if (this.x in dualDimData && this.y in dualDimData[this.x] ) {
						var dataD = "<spring:message code="page.tools.massVsLogp.chart.metabolites" text="Metabolite" />(s): ";
						$.each(dualDimData[this.x][this.y], function(k,v){
							dataD += v + ", ";
						});
						dataD = dataD.substring(0, dataD.length - 2);
						dataD += "<br><spring:message code="page.tools.massVsLogp.chart.logp" text="LogP:" /> "+roundNumber(this.x,5)+"<br><spring:message code="page.tools.massVsLogp.chart.monoIsoMass" text="monoisotopic mass:" /> "+roundNumber(this.y,6)+" Da";
						return dataD;
					} else {
						return "<spring:message code="page.tools.massVsLogp.chart.logp" text="LogP:" /> "+roundNumber(this.x,5)+"<br><spring:message code="page.tools.massVsLogp.chart.monoIsoMass" text="monoisotopic mass:" /> "+roundNumber(this.y,6)+" Da";
					}
				}
	        },
	        plotOptions: {
	            series: {
	                allowPointSelect: true
	            }
	        }
	    });
		try {
			var date = new Date(jsonData.updated);
			var dateString = date.toGMTString();
			$("#statMassVsLogPLastUpdate").html(dateString);
		} catch (e) {}
		var cptPoint = 0;
		$.each(jsonData.dualDim, function(k,v){
			var tmpYdata = []; 
			if (v.x in dualDimData) {
				tmpYdata = dualDimData[v.x];
			}
			if (v.y in tmpYdata) {
				tmpYdata[v.y].push(v.name);
			} else {
				tmpYdata[v.y] = [];
				tmpYdata[v.y].push(v.name);
			}
			dualDimData[v.x] = tmpYdata;
			//inchikey2Dots[v.inchikey] = {'x':v.x,'y':v.y};
			<% if (request.getParameter("logp") != null) { %>
			if (v.inchikey == "<%=request.getParameter("logp")%>") {
				chartMassVsLogP.tooltip.refresh(chartMassVsLogP.series[2].points[cptPoint]);
				activePoint = cptPoint;
				//$("#container-mass-vs-logp svg").mouseout(function(){ chartMassVsLogP.tooltip.refresh(chartMassVsLogP.series[2].points[activePoint]); } );
				setInterval(function() {
					if (!$('#container-mass-vs-logp').is(":hover")) {
						chartMassVsLogP.tooltip.refresh(chartMassVsLogP.series[2].points[activePoint]);
					}
				},1000);
			}
			<% } %>
			cptPoint++;
		});
		<% if (request.getParameter("logp") != null) { %>
	//	console.log('inchikey', "<%=request.getParameter("logp")%>");
	//	console.log("dualDimData", dualDimData)
	//	console.log("inchikey2Dots", inchikey2Dots["<%=request.getParameter("logp")%>"])
		<% } %>
    });
});
</script>
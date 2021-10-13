<%@page import="java.util.Random"%>
<%@page import="fr.metabohub.peakforest.model.spectrum.Spectrum"%>
<%@page import="fr.metabohub.peakforest.model.metadata.OtherMetadata"%>
<%@page import="fr.metabohub.peakforest.model.spectrum.MassPeak"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<script type="text/javascript">

	///////////////////////////////////////////////////////////////////////////
	// spectra viewer options
	var seriesNMRColors = [ '#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9',
			'#f15c80', '#e4d354', '#8085e8', '#8d4653', '#91e8e1' ];
// 	var seriesNMRSymboles = [ "triangle", "circle", "square" ];

	///////////////////////////////////////////////////////////////////////////
	<%int cpt = 0; double max = 0.0;
	Object[] seriesNames = (Object[]) request.getAttribute("spectrum_series_name");
	Object[] seriesShow = (Object[]) request.getAttribute("spectrum_series_show");
// 	Object[] seriesHide = (Object[]) request.getAttribute("spectrum_series_hide");
	
	Object[] seriesComposition = (Object[]) request.getAttribute("spectrum_series_composition");
// 	Object[] seriesAdducts = (Object[]) request.getAttribute("spectrum_series_adducts");
	
	Object[] seriesMetadata = (Object[]) request.getAttribute("spectrum_series_metadata");
	
	boolean loadLegend = (Boolean) request.getAttribute("spectrum_load_legend");
	String spectrumDivId = (String) request.getAttribute("spectrum_div_id");
	%>
	// data spectra 
	<%for (int i = 0; i < seriesShow.length; i++) {%>
		var seriesNMRShow<%=spectrumDivId %><%=i%> = [];
		var seriesNMRCompo<%=spectrumDivId %><%=i%> = {};
		var seriesNMRMetadata<%=spectrumDivId %><%=i%> = {};
		
		<%
		@SuppressWarnings("unchecked")
		HashMap<Double, Double> dataS = (HashMap<Double, Double>) seriesShow[i];
		@SuppressWarnings("unchecked")
		HashMap<Double, String> dataCompo = (HashMap<Double, String>) seriesComposition[i];
		for (Map.Entry<Double, Double> entry : dataS.entrySet()) {
			Double key = entry.getKey();
			Double value = entry.getValue();
			if (value!=null && max < value)
				max = value;
			out.print("seriesNMRShow" + spectrumDivId + "" + i + ".push([" + key + "," + value + "]);\n");
			// super data
			out.print("seriesNMRCompo" + spectrumDivId + "" + i + "[" + key + "]=\"" + dataCompo.get(key) + "\";\n");
		}
		@SuppressWarnings("unchecked")
		HashMap<String, String> metadata = (HashMap<String, String>) seriesMetadata[i];
		for (Map.Entry<String, String> entry : metadata.entrySet()) {
			String key = entry.getKey();
			String value = entry.getValue();
			out.print("seriesNMRMetadata" + spectrumDivId + "" + i + "[\"" + key + "\"]=\""+value+"\";\n");
		}
		out.print(" seriesNMRShow" + spectrumDivId + "" + i + ".sort(); seriesNMRShow" + spectrumDivId + "" + i + ".reverse();"); %>
		// super data
	<%}%>
	<% 
	int maxInt = (int)(max * 1.2);
	%>
	var maxGraph = <%=maxInt %>;
	
	// try destroy old chartNMR<%=spectrumDivId %>
	try {
		chartNMR<%=spectrumDivId %>.destroy();
	} catch (e) {}
	
	///////////////////////////////////////////////////////////////////////////
	// graph function

	var chartNMR<%=spectrumDivId %>;
	var spectrumMinPPM = ${spectrum_min_x};
	var spectrumMaxPPM = ${spectrum_max_x};
	
	/**
	 *
	 */
	loadNMRSpectre<%=spectrumDivId %> = function() {
		lastPointNMR = "";
		$("#peakdivNMRspectrum").html("");
		$('#containerNMRspectrum${spectrum_div_id}').highcharts(
						{
							chart : {
								zoomType : 'x',
								spacingRight : 10,
								spacingLeft : 10,
								type: 'scatter'
								//type : 'scatter'
							},
							title : {
								text : "${spectrum_name}",
								useHTML: true
							},
							//<c:if test="${!mode_light}">
							subtitle : {
								text : document.ontouchstart === undefined ? 'Select area' : 'Pinch the chart to zoom in'
							},
							//</c:if>
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
										<% for (int i = 0; i < seriesShow.length; i++) { %>
											if (this.series.index == <%=(i) %>)
												compo = seriesNMRCompo<%=spectrumDivId %><%=i %>[this.x];
										<% } %>
										return '<b>' + this.series.name
												+ '</b><br/>chemical shift:' + Math.abs(this.x) + ' ppm'
												+ ';<br/>Relative Intensity: ' + this.y
												+ '%;<br/>Composition: ' + compo
												+ '';
								}
							},
							
							legend : {
								<% if (loadLegend) {
									out.print(" layout : 'vertical',\n");
									out.print(" align : 'right',\n");
									out.print(" verticalAlign : 'middle',\n");
									out.print(" borderWidth : 1,\n");
									out.print(" backgroundColor : '#FFFFFF'\n");
// 									out.print(" \n");
								 } else {
									 out.print(" enabled: false \n");
								 } %>
							},
							plotOptions : {
								scatter : {}
							},
							series : [
									// ### LOOP
									<% 
									Random randomGenerator = new Random();
									int startColor = randomGenerator.nextInt(10);
									int startSymb = randomGenerator.nextInt(3);
									
									int serieColor = startColor;
									serieColor = startColor;
 									int serieSymbole = startSymb;
									for (int i = 0; i < seriesShow.length; i++) {
										if (i>0) { out.print(","); }  
										out.print("{");
										out.print("name : \""+seriesNames[i]+"\", showInLegend : true, ");
										out.print("point : { events : { click : function() { selectPointNMR"+spectrumDivId+"("+ (i)+ ", this.x, this.y, this.series.name, "+i+"); } } },");
										out.print("color : seriesNMRColors["+serieColor+"], lineColor : seriesNMRColors["+serieColor+"], ");
										out.print("pointInterval : 10, pointStart : 100, lineWidth : 2, ");
										out.print("marker : { enabled : true, radius : 2, lineColor : seriesNMRColors["+serieColor+"] }, ");
										out.print("data : seriesNMRShow"+spectrumDivId+""+i+",");
										out.print("zIndex : 10");
										out.print("}\n");
										//  change color
										serieColor++;
 										serieSymbole++;
										if (serieColor == 10)
											serieColor = 0;
										if (serieSymbole == 3)
											serieSymbole = 0;
										
									} %>
							]
						});

		chartNMR<%=spectrumDivId %> = $('#containerNMRspectrum${spectrum_div_id}').highcharts();
		
		if ('${spectrum_div_id}'!='') {
			var idSpectrum = '${spectrum_div_id}' + 's';
			try {
				currentChartTab[idSpectrum]=chartNMR<%=spectrumDivId %>;				
			} catch(e){}
		}

	};

	$("g.highcharts-legend-item").bind('click', function(ev) {
		loadMetadataNMRDetail<%=spectrumDivId %>();
	});
	
	<% for (int i = 0; i < seriesShow.length; i++) { %>
	var serie<%=spectrumDivId %><%=(i) %>IsShow = true;
	<% } %>
	
	var lastPointNMR = "";

	/**
	 *
	 */
	selectPointNMR<%=spectrumDivId %> = function(s, x, y, spectrum, id) {
		var i = -1;
		$.each(chartNMR<%=spectrumDivId %>.series[s].data, function(k, v) {
			if (v.x == x) {
				chartNMR<%=spectrumDivId %>.series[s].data[k].select();
				i = k;
			}
		});
		var newPoint = s + "d" + x;
		if (i > -1 && lastPointNMR != newPoint) {
			var compo = '';
			var adduct = '';
			<% for (int i = 0; i < seriesShow.length; i++) { %>
				if (id == <%=(i) %>) {
					compo = seriesNMRCompo<%=spectrumDivId %><%=i %>[x];
				}
			<% } %>
			var divConent = '<table id="" class="jqplot-highlighter" style="font-size:75%"> \
						<tr><td>spectrum:</td><td>' + spectrum + '</td></tr> \
						<tr><td>Chemical Shift: </td><td>' 	+ Math.abs(x) + ' ppm</td></tr> \
						<tr><td>Intensity: </td><td>' + y + '%</td></tr> \
						<tr><td>Composition: </td><td class="composition">' + compo + '</td></tr> \
						<tr><td colspan=2></td></tr></table>';
			$("#peakdivNMRspectrum").html(divConent);
			lastPointNMR = newPoint;
		} else {
			$("#peakdivNMRspectrum").html("");
			lastPointNMR = "";
		} //

	}

	/**
	 *
	 */
	spectreNMRCheckboxListener = function(e, x, s) {
		//console.log($(e).parent());
		//      select ([Boolean select], [Boolean accumulate])
		alert('load:' + x + ";check:" + $(e).prop('checked'));
		//chartNMR<%=spectrumDivId %>.series[0].data[x].select();
		$.each(chartNMR<%=spectrumDivId %>.series[s].data, function(k, v) {
			if (v.x == x) {
				chartNMR<%=spectrumDivId %>.series[s].data[k].select();
			}
		});
		//console.log( );
	}

	// load init chartNMR<%=spectrumDivId %>
	setTimeout(function() {
		loadNMRSpectre<%=spectrumDivId %>();
	}, 100);
	///////////////////////////////////////////////////////////////////////////
	// metadata
	/** 
	 * Refresh spectrum metadata
	 */
	loadMetadataNMRDetail<%=spectrumDivId %> = function() {
		// init
		var spectraName = {};
// 		var spectraCode = {};
		var spectraType = {};
		var spectraAuthors = {};
		var spectraOwners = {};
		var spectraCopyright = {};
		// check visible series
		<% for (int i = 0; i < seriesShow.length; i++) { %>
		if (serie<%=spectrumDivId %><%=(i) %>IsShow) {
			// meta
			var keyID = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['pforest_id'];
			var keyPfemName = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['pfem_name'];
			$(".pforest-spectra-name-" + keyID).html(keyPfemName);
			// Names
			var keyName = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['name'];
			if(keyName in spectraName) {
				spectraName[keyName].push(<%=(i+1) %>); 
			} else {
				spectraName[keyName] =[<%=(i+1) %>]; 
			}
			// type
			var keyLabelRaw = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['label'];
			var keyLabel = '';
			switch (keyLabelRaw) {
			case '<%=Spectrum.SPECTRUM_LABEL_REFERENCE %>':
				keyLabel = 'Reference';
				break;
			case '<%=Spectrum.SPECTRUM_LABEL_SIMULATED %>':
				keyLabel = 'Simulated';
				break;
			case '<%=Spectrum.SPECTRUM_LABEL_EXPERIMENTAL %>':
				keyLabel = 'Experimental';
				break;
			case '<%=Spectrum.SPECTRUM_LABEL_VIRTUAL %>':
				keyLabel =  'Virtual';
				break;
			default:
				keyLabel =  "?";
				break;
			}
			if(keyLabel in spectraType) {
				spectraType[keyLabel].push(<%=(i+1) %>); 
			} else {
				spectraType[keyLabel] =[<%=(i+1) %>]; 
			}
			// authors
			var keyAuthors = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['authors'];
			if(keyAuthors in spectraAuthors) {
				spectraAuthors[keyAuthors].push(<%=(i+1) %>); 
			} else {
				spectraAuthors[keyAuthors] =[<%=(i+1) %>]; 
			}
			// owners
			var keyOwners = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['owners'];
			if(keyOwners in spectraOwners) {
				spectraOwners[keyOwners].push(<%=(i+1) %>); 
			} else {
				spectraOwners[keyOwners] =[<%=(i+1) %>]; 
			}
			// license
			var keyLicense = seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['license'];
			var keyCopyright = '';
			switch (keyLicense) {
			case '<%=OtherMetadata.LICENSE__CC__BY_NC_SA %>':
				keyCopyright = 'Creative Commons [by/nc/sa]';
				break;
			case '<%=OtherMetadata.LICENSE__CC__BY_SA %>':
				keyCopyright = 'Creative Commons [by/sa]';
				break;
			case '<%=OtherMetadata.LICENSE__COPYRIGHT %>':
				keyCopyright = '&copy; copyright - all rights reserved';
				break;
			case '<%=OtherMetadata.LICENSE__OTHER %>':
				keyCopyright =  seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['licenseOther'];
				break;
			default:
				keyCopyright =  seriesNMRMetadata<%=spectrumDivId %><%=(i) %>['licenseOther'];
				break;
			}
			if(keyCopyright in spectraCopyright) {
				spectraCopyright[keyCopyright].push(<%=(i+1) %>); 
			} else {
				spectraCopyright[keyCopyright] =[<%=(i+1) %>]; 
			}
		}
		<% } %>
		// rebuild
		var spectraNameString = "";
		$.each(spectraName, function(k, v){
			if (spectraNameString != "")
				spectraNameString += ", ";
			spectraNameString += k + " (" + v + ")";
		});
		//
		var spectraTypeString = "";
		$.each(spectraType, function(k, v){
			if (spectraTypeString != "")
				spectraTypeString += ", ";
			spectraTypeString += k + " (" + v + ")";
		});
		var spectraAuthorsString = "";
		$.each(spectraAuthors, function(k, v){
			if (spectraAuthorsString != "")
				spectraAuthorsString += ", ";
			spectraAuthorsString += k + " (" + v + ")";
		});
		var spectraOwnersString = "";
		$.each(spectraOwners, function(k, v){
			if (spectraOwnersString != "")
				spectraOwnersString += ", ";
			spectraOwnersString += k + " (" + v + ")";
		});
		var spectraCopyrightsString = "";
		$.each(spectraCopyright, function(k, v) {
			if (spectraCopyrightsString != "")
				spectraCopyrightsString += ", ";
			spectraCopyrightsString += k + " (" + v + ")";
		});
		// reload
		$("#metadataNMR_names<%=spectrumDivId %>").html(spectraNameString);
		
		$("#metadataNMR_type<%=spectrumDivId %>").html(spectraTypeString);
		$("#metadataNMR_authors<%=spectrumDivId %>").html(spectraAuthorsString);
		$("#metadataNMR_owners<%=spectrumDivId %>").html(spectraOwnersString);
		$("#metadataNMR_copyright<%=spectrumDivId %>").html(spectraCopyrightsString);
	}; // 
	loadMetadataNMRDetail<%=spectrumDivId %>();
	
	
</script>

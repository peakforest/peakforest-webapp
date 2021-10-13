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
	var seriesColors = [ '#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9',
			'#f15c80', '#e4d354', '#8085e8', '#8d4653', '#91e8e1' ];
	var seriesSymboles = [ "triangle", "circle", "square" ];

	///////////////////////////////////////////////////////////////////////////
	<%int cpt = 0; double max = 0.0;
	Object[] seriesNames = (Object[]) request.getAttribute("spectrum_series_name");
	Object[] seriesShow = (Object[]) request.getAttribute("spectrum_series_show");
	Object[] seriesHide = (Object[]) request.getAttribute("spectrum_series_hide");
	
	Object[] seriesComposition = (Object[]) request.getAttribute("spectrum_series_composition");
	Object[] seriesAdducts = (Object[]) request.getAttribute("spectrum_series_adducts");
	
	Object[] seriesMetadata = (Object[]) request.getAttribute("spectrum_series_metadata");
	
	boolean loadLegend = (Boolean) request.getAttribute("spectrum_load_legend");
	String spectrumDivId = (String) request.getAttribute("spectrum_div_id");
	%>
	// data spectra 
	<%for (int i = 0; i < seriesShow.length; i++) {%>
		var seriesShow<%=spectrumDivId %><%=i%> = [];
		var seriesCompo<%=spectrumDivId %><%=i%> = {};
		var seriesAdducts<%=spectrumDivId %><%=i%> = {};
		var seriesMetadata<%=spectrumDivId %><%=i%> = {};
		
		<%
		@SuppressWarnings("unchecked")
		HashMap<Double, Double> dataS = (HashMap<Double, Double>) seriesShow[i];
		@SuppressWarnings("unchecked")
		HashMap<Double, String> dataCompo = (HashMap<Double, String>) seriesComposition[i];
		@SuppressWarnings("unchecked")
		HashMap<Double, Short> dataAdducts = (HashMap<Double, Short>) seriesAdducts[i];
		for (Map.Entry<Double, Double> entry : dataS.entrySet()) {
			Double key = entry.getKey();
			Double value = entry.getValue();
			if (value!=null && max < value)
				max = value;
			out.print("seriesShow" + spectrumDivId + "" + i + ".push([" + key + "," + value + "]);\n");
			// super data
			out.print("seriesCompo" + spectrumDivId + "" + i + "[" + key + "]='" + dataCompo.get(key) + "';\n");
			out.print("seriesAdducts" + spectrumDivId + "" + i + "[" + key + "]='" + dataAdducts.get(key) + "';\n");
		}
		@SuppressWarnings("unchecked")
		HashMap<String, String> metadata = (HashMap<String, String>) seriesMetadata[i];
		for (Map.Entry<String, String> entry : metadata.entrySet()) {
			String key = entry.getKey();
			String value = entry.getValue();
			out.print("seriesMetadata" + spectrumDivId + "" + i + "['" + key + "']='"+value+"';\n");
		}%>
		var seriesHide<%=spectrumDivId %><%=i%> = []; 
		
		<%
		@SuppressWarnings("unchecked")
		HashMap<Double, Double> dataH = (HashMap<Double, Double>) seriesHide[i];
		for (Map.Entry<Double, Double> entry : dataH.entrySet()) {
			Double key = entry.getKey();
			Double value = entry.getValue();
			out.print("seriesHide" + spectrumDivId + "" + i + ".push([" + key + "," + value + "]);");
		}%>
		<% out.print("seriesHide" + spectrumDivId + "" + i + ".sort(); \n seriesShow" + spectrumDivId + "" + i + ".sort();"); %>
		// super data
	<%}%>
	<% 
	int maxInt = (int)(max * 1.2);
	%>
	var maxGraph = <%=maxInt %>;
	
	// try destroy old chart<%=spectrumDivId %>
	try {
		chart<%=spectrumDivId %>.destroy();
	} catch (e) {}
	
	///////////////////////////////////////////////////////////////////////////
	// graph function

	var chart<%=spectrumDivId %>;
	var spectrumMinMass = ${spectrum_min_mass};
	var spectrumMaxMass = ${spectrum_max_mass};
	
	/**
	 *
	 */
	loadSpectre<%=spectrumDivId %> = function() {
		lastPoint = "";
		$("#peakdivLCspectrum").html("");
		$('#containerLCspectrum${spectrum_div_id}').highcharts(
						{
							chart : {
								zoomType : 'x',
								spacingRight : 10,
								spacingLeft : 10,
								type : 'scatter'
							},
							title : {
								text : "${spectrum_name}",
								useHTML: true
							},
							//<c:if test="${!mode_light}">
							subtitle : {
								text : 'Select area to zoom; ' + '<small> <a target="_BLANK" href="http://www.massbank.jp/manuals/MassBankRecord_en.pdf" title="MassBank Record documentation"><i class="fa fa-question-circle"></i> about MassBank Record documentation </a></small>',
								useHTML: true
							},
							//</c:if>
							xAxis : {
								type : 'number',
								maxZoom : 2, // in %
								title : {
									text : 'm/z'
								},
								min : spectrumMinMass,
								max : spectrumMaxMass
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
									if ((this.series.name).match(/ - HIDE$/)) {
										return false;
									} else {
										var compo = '';
										<% for (int i = 0; i < seriesShow.length; i++) { %>
											if (this.series.index == <%=(seriesShow.length+i) %>)
												compo = seriesCompo<%=spectrumDivId %><%=i %>[this.x];
												attrib = seriesAdducts<%=spectrumDivId %><%=i %>[this.x];
												//if (attrib == "null") { attrib = ""; } 
										<% } %>
										return '<b>' + this.series.name
												+ '</b><br/>m/z:' + this.x
												+ ';<br/>Relative Intensity: ' + this.y
												+ '%;<br/>Composition: ' + compo
												+ ';<br/>Attribution: ' + attrib
												+ '';
									}
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
// 									int serieSymbole = 0;
									for (int i = 0; i < seriesShow.length; i++) {
										if (i>0) { out.print(","); }  
										out.print("{");
										out.print("type : 'line', name : \""+seriesNames[i]+" - HIDE\", showInLegend : false, ");
										out.print("color : seriesColors["+serieColor+"], lineColor : seriesColors["+serieColor+"], ");
										out.print("pointInterval : 10, pointStart : 0, ");
										out.print("marker : {enabled : false, lineColor : seriesColors["+serieColor+"]}, ");
										out.print("data : seriesHide"+spectrumDivId+""+i+",");
										out.print("zIndex : -10");
										out.print("}\n");
										// change color
										serieColor++;
// 										serieSymbole++;
										if (serieColor == 10)
											serieColor = 0;
// 										if (serieSymbole == 3)
// 											serieSymbole = 0;
										
									} 
									serieColor = startColor;
 									int serieSymbole = startSymb;
									for (int i = 0; i < seriesShow.length; i++) {
										out.print(",{");
										out.print("name : \""+seriesNames[i]+"\", showInLegend : true, ");
										out.print("point : { events : { click : function() { selectPoint("+ (seriesShow.length+i)+ ", this.x, this.y, this.series.name, "+i+"); } } },");
										out.print("color : seriesColors["+serieColor+"], lineColor : seriesColors["+serieColor+"], ");
										out.print("pointInterval : 10, pointStart : 100, lineWidth : 0, ");
										out.print("marker : {symbol : seriesSymboles["+serieSymbole+"], enabled : true, lineColor : seriesColors["+serieColor+"], lineWidth : 1}, ");
										out.print("data : seriesShow"+spectrumDivId+""+i+",");
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

		chart<%=spectrumDivId %> = $('#containerLCspectrum${spectrum_div_id}').highcharts();
		
		if ('${spectrum_div_id}'!='') {
			var idSpectrum = '${spectrum_div_id}' + 's';
			try {
				currentChartTab[idSpectrum]=chart<%=spectrumDivId %>;				
			} catch(e){}
		}
		
		
		/**
		 *
		 */
		$("g.highcharts-legend-item").bind('click', function(ev) {
			var txt = $(this).text();
			$.each(chart<%=spectrumDivId %>.series, function(k, v) {
				if (v.name == txt + " - HIDE") {
					<% for (int i = 0; i < seriesShow.length; i++) { %>
					if (v.index == <%=(i) %> && serie<%=spectrumDivId %><%=(i) %>IsShow) {
						chart<%=spectrumDivId %>.series[v.index].hide();
						serie<%=spectrumDivId %><%=(i) %>IsShow = false;
					} else if (v.index == <%=(i) %>) {
						chart<%=spectrumDivId %>.series[v.index].show();
						serie<%=spectrumDivId %><%=(i) %>IsShow = true;
					}
					<% } %>
				}
			});
			loadMetadataDetail<%=spectrumDivId %>();
		});

	};

	<% for (int i = 0; i < seriesShow.length; i++) { %>
	var serie<%=spectrumDivId %><%=(i) %>IsShow = true;
	<% } %>
	
	var lastPoint = "";

	/**
	 *
	 */
	selectPoint = function(s, x, y, spectrum, id) {
		var i = -1;
		$.each(chart<%=spectrumDivId %>.series[s].data, function(k, v) {
			if (v.x == x) {
				chart<%=spectrumDivId %>.series[s].data[k].select();
				i = k;
			}
		});
		var newPoint = s + "d" + x;
		if (i > -1 && lastPoint != newPoint) {
			var compo = '';
			var adduct = '';
			<% for (int i = 0; i < seriesShow.length; i++) { %>
				if (id == <%=(i) %>) {
					compo = seriesCompo<%=spectrumDivId %><%=i %>[x];
					adduct = seriesAdducts<%=spectrumDivId %><%=i %>[x];
				}
			<% } %>
			var divConent = '<table id="" class="jqplot-highlighter" style="font-size:75%"> \
						<tr><td>spectrum:</td><td>' + spectrum + '</td></tr> \
						<tr><td>m/z: </td><td>' 	+ x + '</td></tr> \
						<tr><td>Intensity: </td><td>' + y + '%</td></tr> \
						<tr><td>Composition: </td><td class="composition">' + compo + '</td></tr> \
						<tr><td>Adducts: </td><td class="adducts">' + getAdductAsString<%=spectrumDivId %>(adduct) + '</td></tr> \
						<tr><td colspan=2></td></tr></table>';
			$("#peakdivLCspectrum").html(divConent);
			lastPoint = newPoint;
		} else {
			$("#peakdivLCspectrum").html("");
			lastPoint = "";
		} //

	}

	/**
	 *
	 */
	spectreCheckboxListener = function(e, x, s) {
		//console.log($(e).parent());
		//      select ([Boolean select], [Boolean accumulate])
		alert('load:' + x + ";check:" + $(e).prop('checked'));
		//chart<%=spectrumDivId %>.series[0].data[x].select();
		$.each(chart<%=spectrumDivId %>.series[s].data, function(k, v) {
			if (v.x == x) {
				chart<%=spectrumDivId %>.series[s].data[k].select();
			}
		});
		//console.log( );
	}

	// load init chart<%=spectrumDivId %>
	loadSpectre<%=spectrumDivId %>();

	///////////////////////////////////////////////////////////////////////////
	// metadata
	/** 
	 * Refresh spectrum metadata
	 */
	loadMetadataDetail<%=spectrumDivId %> = function() {
		// init
		var spectraName = {};
// 		var spectraCode = {};
		var spectraRT = {};
		var spectraPolarity = {};
		var spectraIonization = {};
		var spectraType = {};
		var spectraAuthors = {};
		var spectraOwners = {};
		var spectraCopyright = {};
		// check visible series
		<% for (int i = 0; i < seriesShow.length; i++) { %>
		if (serie<%=spectrumDivId %><%=(i) %>IsShow) {
			// Names
			var keyName = seriesMetadata<%=spectrumDivId %><%=(i) %>['name'];
			if(keyName in spectraName) {
				spectraName[keyName].push(<%=(i+1) %>); 
			} else {
				spectraName[keyName] =[<%=(i+1) %>]; 
			}
			// RT
			var keyRT = seriesMetadata<%=spectrumDivId %><%=(i) %>['RT'];
			if(keyRT in spectraRT) {
				spectraRT[keyRT].push(<%=(i+1) %>); 
			} else {
				spectraRT[keyRT] =[<%=(i+1) %>]; 
			}
			// polarity
			var keyPolarity = seriesMetadata<%=spectrumDivId %><%=(i) %>['polarity'];
			if(keyPolarity in spectraPolarity) {
				spectraPolarity[keyPolarity].push(<%=(i+1) %>); 
			} else {
				spectraPolarity[keyPolarity] =[<%=(i+1) %>]; 
			}
			// ionization
			var keyIonization = seriesMetadata<%=spectrumDivId %><%=(i) %>['ionization'];
			if(keyIonization in spectraIonization) {
				spectraIonization[keyIonization].push(<%=(i+1) %>); 
			} else {
				spectraIonization[keyIonization] =[<%=(i+1) %>]; 
			}	
			// type
			var keyLabelRaw = seriesMetadata<%=spectrumDivId %><%=(i) %>['label'];
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
			var keyAuthors = seriesMetadata<%=spectrumDivId %><%=(i) %>['authors'];
			if(keyAuthors in spectraAuthors) {
				spectraAuthors[keyAuthors].push(<%=(i+1) %>); 
			} else {
				spectraAuthors[keyAuthors] =[<%=(i+1) %>]; 
			}
			// owners
			var keyOwners = seriesMetadata<%=spectrumDivId %><%=(i) %>['owners'];
			if(keyOwners in spectraOwners) {
				spectraOwners[keyOwners].push(<%=(i+1) %>); 
			} else {
				spectraOwners[keyOwners] =[<%=(i+1) %>]; 
			}
			// license
			var keyLicense = seriesMetadata<%=spectrumDivId %><%=(i) %>['license'];
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
				keyCopyright =  seriesMetadata<%=spectrumDivId %><%=(i) %>['licenseOther'];
				break;
			default:
				keyCopyright =  seriesMetadata<%=spectrumDivId %><%=(i) %>['licenseOther'];
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
		var spectraRTString = "";
		$.each(spectraRT, function(k, v){
			if (spectraRTString != "")
				spectraRTString += ", ";
			spectraRTString += k + " (" + v + ")";
		});
		var spectraPolarityString = "";
		$.each(spectraPolarity, function(k, v){
			if (spectraPolarityString != "")
				spectraPolarityString += ", ";
			spectraPolarityString += k + " (" + v + ")";
		});
		var spectraIonizationString = "";
		$.each(spectraIonization, function(k, v){
			if (spectraIonizationString != "")
				spectraIonizationString += ", ";
			spectraIonizationString += k + " (" + v + ")";
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
		$("#metadataLC_names<%=spectrumDivId %>").html(spectraNameString);
// 		$("#metadataLC_codes<%=spectrumDivId %>").html(spectraNameString);
		$("#metadataLC_rt<%=spectrumDivId %>").html(spectraRTString);
		$("#metadataLC_polarity<%=spectrumDivId %>").html(spectraPolarityString);
		$("#metadataLC_ionization<%=spectrumDivId %>").html(spectraIonizationString);
		
		$("#metadataLC_type<%=spectrumDivId %>").html(spectraTypeString);
		$("#metadataLC_authors<%=spectrumDivId %>").html(spectraAuthorsString);
		$("#metadataLC_owners<%=spectrumDivId %>").html(spectraOwnersString);
		$("#metadataLC_copyright<%=spectrumDivId %>").html(spectraCopyrightsString);
	}; // 
	loadMetadataDetail<%=spectrumDivId %>();
	
	/**
	 * Convert an adductor from short to string 
	 */
	getAdductAsString<%=spectrumDivId %> = function (addusct) {
		var adductAsString = "?";
		switch(adductAsString) {
		// NEU
		case <%=MassPeak.ATTRIBUTION_M%>:
			adductAsString = '[M]';
			break;
		// POS 1 M
		case <%=MassPeak.ATTRIBUTION_M_P_H%>:
			adductAsString = '[M+H]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_NH4%>:
			adductAsString = '[M+NH4]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_Na%>:
			adductAsString = '[M+Na]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_K%>:
			adductAsString = '[M+K]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_H_H2O%>:
			adductAsString = '[M+H-H2O]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_H_2H2O%>:
			adductAsString = '[M+H-2H2O]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_CH3OH_H%>:
			adductAsString = '[M+CH3OH+H]+';
			break;
		case <%=MassPeak.ATTRIBUTION_M_P_CH3CN_H%>:
			adductAsString = '[M+CH3CN+H]+';
			break;
		// POS 2 M
		case <%=MassPeak.ATTRIBUTION_2M_P_H %>:
			adductAsString = '[2M+H]+';
			break;
		case <%=MassPeak.ATTRIBUTION_2M_P_NH4 %>:
			adductAsString = '[2M+NH4]+';
			break;
		case <%=MassPeak.ATTRIBUTION_2M_P_Na %>:
			adductAsString = '[2M+Na]+';
			break;
		case <%=MassPeak.ATTRIBUTION_2M_P_K %>:
			adductAsString = '[2M+K]+';
			break;
		// NEG 1 M
		case <%=MassPeak.ATTRIBUTION_M_N_H %>:
			adductAsString = '[M-H]-';
			break;
		case <%=MassPeak.ATTRIBUTION_M_N_H_H2O %>:
			adductAsString = '[M-H-H2O]-';
			break;
		case <%=MassPeak.ATTRIBUTION_M_N_HCOOH_H %>:
			adductAsString = '[M+HCOOH-H]-';
			break;
		case <%=MassPeak.ATTRIBUTION_M_N_CH3COOH_H %>:
			adductAsString = '[M+CH3COOH-H]-';
			break;
		// NEG 2 M
		case <%=MassPeak.ATTRIBUTION_2M_N_H %>:
			adductAsString = '[2M-H]-';
			break;
		case <%=MassPeak.ATTRIBUTION_2M_N_HCOOH_H %>:
			adductAsString = '[2M+HCOOH-H]-';
			break;
		case <%=MassPeak.ATTRIBUTION_2M_N_CH3COOH_H %>:
			adductAsString = '[2M+CH3COOH-H]-';
			break;
		// NEG 3 M
		case <%=MassPeak.ATTRIBUTION_3M_N_H %>:
			adductAsString = '[3M-H]-';
			break;
		default:
			adductAsString = "-";
			break;
		}
		return adductAsString;
	}
</script>

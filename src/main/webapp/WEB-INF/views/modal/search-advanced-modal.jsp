<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<title><spring:message code="modal.advSearch.title" text="Advanced Search" /></title>
	<style type="text/css"></style>
	<script type="text/javascript">
	//<![CDATA[ 
var alreadyTryNMRload = false;
function tryLoadNMRdata() {
	alreadyTryNMRload = true;
	var rawQuery = $("#search").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	var openAdvSearch = false;
	$.each(rawQueryTab, function(k, v) {
		v = v.trim();
		if (v != "") {
			switch (v.toUpperCase()) {
			case "NMR":
				break;
			case "400":
			case "500":
			case "600":
			case "700":
			case "750":
			case "800":
			case "850":
			case "900":
			case "950":
			case "1000":
			case "1100":
			case "1200":
				setTimeout(function(){$("#nmr-magneticFieldStrength-value").val(Number(v));},50);
				break;
			case "PROTON-1D":
				$("#nmr-pulseseq-value").val("Proton-1D");
				break;
			case "CARBON-13":
				$("#nmr-pulseseq-value").val("Carbon-13");
				break;
			case "NOESY-1D":
			case "CPMG-1D":
			case "JRES-2D":
			case "COSY-2D":
			case "TOCSY-2D":
			case "NOESY-2D":
			case "HMBC-2D":
			case "HCQC-2D":
				$("#nmr-pulseseq-value").val(v.toUpperCase());
				break;
			case "H2O":
			case "CDCL3":
			case "D2O":
			case "CD3OD":
			case "H2O/D2O":
				setTimeout(function(){$("#nmr-solvent-value").val(v);},50);
				break;
			case "D":
				openAdvSearch = true;
				$("#isotopic_labelling_Dy").attr('checked',true);
				break;
			case "13C":
				openAdvSearch = true;
				$("#isotopic_labelling_Cy").attr('checked',true);
				break;
			case "15N":
				openAdvSearch = true;
				$("#isotopic_labelling_Ny").attr('checked',true);
				break;
			case "ONLY_WITH_RAW_DATA":
				setTimeout(function(){ $("#filter_nmr_raw_data").attr('checked',true); }, 150); 
				break;
			default:
				// exact matcher
				if ((!/~/i.test(v))) {
					// ph value
					var e = parseInt(v);
					if (e + '' == v && (e < 15 && e > 0) && $("#nmr-ph-value") =="") {
						$("#nmr-ph-value").val(e);
					} else if ((!/:/i.test(v))) {
						query += v + " ";
					}
				} else {
					// exact matcher
					var nmrField = v.split("~");
					var linker = nmrField[0];
					var search = nmrField[1];
					var value = nmrField[2];
					switch (search) {
					case "ph":
						$("#nmr-ph-linker").val(linker);
						$("#nmr-ph-value").val(value); 
						break;
					case "pulseseq":
						$("#nmr-pulseseq-linker").val(linker);
						$("#nmr-pulseseq-value").val(value); 
						break;
					case "magneticFieldStrength":
						setTimeout(function(){ $("#nmr-magneticFieldStrength-linker").val(linker) }, 50); 
						setTimeout(function(){ $("#nmr-magneticFieldStrength-value").val(Number(value)) }, 50); 
						break;
					case "solvent":
						setTimeout(function(){ $("#nmr-solvent-linker").val(linker)}, 50); 
						setTimeout(function(){ $("#nmr-solvent-value").val(value)}, 50); ; 
						break;
					default:
						break;
					}
				}
				break;
			}
		}
	});
	if (openAdvSearch) {
		setTimeout(function(){showHideAvancedSearchNmrPanel();},300);
	}
	$("#nmr-cpd-name").val(query);
}
var alreadyTryLCMSload = false;
function tryLoadLCMSdata() {
	alreadyTryLCMSload = true;
	var rawQuery = $("#search").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	$.each(rawQueryTab, function(k, v) {
		v = v.trim();
		if (v != "") {
			switch (v.toUpperCase()) {
			case "LC-MS":
			case "LCMS":
			case "LC-MSMS":
			case "LCMSMS":
			case "IC-MS":
			case "ICMS":
			case "IC-MSMS":
			case "ICMSMS":
				break;
			case "POSITIVE":
				$("#ms-polarity-value").val("positive");
// 				$("#lcms-polarity-pos").prop('checked', true);
// 				$("#lcmsms-polarity-pos").prop('checked', true);
				break;
			case "NEGATIVE":
				$("#ms-polarity-value").val("negative");
// 				$("#lcms-polarity-neg").prop('checked', true);
// 				$("#lcmsms-polarity-neg").prop('checked', true);
				break;
			case "HIGH":
				$("#ms-resolution-value").val("high");
// 				$("#lcms-resolution-high").prop('checked', true);
// 				$("#lcmsms-resolution-high").prop('checked', true);
				break;
			case "LOW":
				$("#ms-resolution-value").val("low");
// 				$("#lcms-resolution-low").prop('checked', true);
// 				$("#lcmsms-resolution-low").prop('checked', true);
				break;
				//
			case "ACPI":
			case "APPI":
			case "EI":
			case "ESI":
			case "FAB":
			case "MALDI":
			case "TOF":
			case "ITFT":
			case "QTOF":
			case "QQQ":
				$("#ms-ionization_method-value").val(v.toUpperCase());
// 				$("#lcms-ionAnalyzer").val(v.toUpperCase());
// 				$("#lcmsms-ionAnalyzer").val(v.toUpperCase());
				break;
// 			case "EB":
// 				$("#lcms-ionAnalyzer").val("EB");
// 				break;
			default:
				if ((!/:/i.test(v)))
					query += v + " ";
				break;
			}
		}
	});
	$("#ms-compound-name").val(query);
// 	$("#lcms-cpd-name").val(query);
// 	$("#lcmsms-cpd-name").val(query);
}

$('input[type=text]').focus(function(){
	this.selectionStart = this.selectionEnd = this.value.length;
});

var searchAdvanceEntities = "compounds"; //spectrums // ...
searchAdvanceSwitchPanel = function (entities) {
	searchAdvanceEntities = entities;
	switch (entities) {
	case 'compounds':
		setTimeout(function(){$("#advancedSearchCompQuery").focus();},200);
		break;
// 	case 'lcms-spectra':
// 		setTimeout(function(){$("#lcms-cpd-name").focus();},200);
// 		tryLoadLCMSdata();
// 		break;
// 	case 'lcmsms-spectra':
// 		setTimeout(function(){$("#lcmsms-cpd-name").focus();},200);
// 		tryLoadLCMSdata();
// 		break;
	case 'nmr-spectra':
		setTimeout(function(){$("#nmr-cpd-name").focus();},200);
		tryLoadNMRdata();
		break;
	case 'gcms-spectra':
		setTimeout(function(){$("#gcms-cpd-name").focus();},200);
		tryLoadGCMSdata();
		break;
	// new 2.3
	case 'ms-spectra':
	case 'lcms-spectra':
	case 'lcmsms-spectra':
	case 'icms-spectra':
	case 'icmsms-spectra':
		setTimeout(function(){$("#ms-compound-name").focus();},200);
		tryLoadMSdata();
		break;
	default:  
		break;
	}
}

var alreadyTryGCMSload = false;
function tryLoadGCMSdata() {
	alreadyTryGCMSload = true;
	var rawQuery = $("#search").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	var openAdvSearch = false;
	$.each(rawQueryTab, function(k, v) {
		v = v.trim();
		if (v != "") {
			switch (v.toUpperCase()) {
			case "GC-MS":
			case "GCMS":
				break;
			default:
				if ((!/~/i.test(v))) {
					query += v + " ";
				} else {
					var gcmsField = v.split("~");
					var linker = gcmsField[0];
					var search = gcmsField[1];
					var value = gcmsField[2];
					switch (search) {
					case "derivation":
						$("#gcms-derivation-linker").val(linker);
						$("#gcms-derivation-value").val(value); 
						break;
					case "derivated_type":
						$("#gcms-derivated_type-linker").val(linker);
						$("#gcms-derivated_type-value").val(value); 
						break;
					case "ionization":
						$("#gcms-ionization-linker").val(linker);
						$("#gcms-ionization-value").val(value); 
						break;
					case "analyzer":
						$("#gcms-analyzer-linker").val(linker);
						$("#gcms-analyzer-value").val(value); 
						break;
					default:
						break;
					}
				}
				break;
			}
		}
	});
	$("#gcms-cpd-name").val(query);
}

// new 2.3
var alreadyTryMSload = false;
function tryLoadMSdata() {
	alreadyTryMSload = true;
	var rawQuery = $("#search").val();
	var rawQueryTab = rawQuery.split(" ");
	var query = "";
	var openAdvSearch = false;
	$.each(rawQueryTab, function(k, v) {
		v = v.trim();
		if (v != "") {
			switch (v.toUpperCase()) {
			case "LC-MS":
			case "LCMS":
				$("#ms-search-type").val("LCMS");
				break;
			case "IC-MS":
			case "ICMS":
				$("#ms-search-type").val("ICMS");
				break;
			case "LC-MSMS":
			case "LCMSMS":
				$("#ms-search-type").val("LCMSMS");
				break;
			case "IC-MSMS":
			case "ICMSMS":
				$("#ms-search-type").val("ICMSMS");
				break;
			case "POSITIVE":
				$("#ms-polarity-value").val("positive");
				break;
			case "NEGATIVE":
				$("#ms-polarity-value").val("negative");
				break;
			case "HIGH":
				$("#ms-resolution-value").val("high");
				break;
			case "LOW":
				$("#ms-resolution-value").val("low");
				break;
			case "ACPI":
			case "APPI":
			case "EI":
			case "ESI":
			case "FAB":
			case "MALDI":
			case "TOF":
			case "ITFT":
			case "QTOF":
			case "QQQ":
				$("#ms-ionization_method-value").val(v.toUpperCase());
			default:
				if ((!/~/i.test(v))) {
					query += v + " ";
				} else {
					var msField = v.split("~");
					var linker = msField[0];
					var search = msField[1];
					var value = msField[2];
					switch (search) {
					case "polarity":
						$("#ms-polarity-linker").val(linker);
						$("#ms-polarity-value").val(value); 
						break;
					case "resolution":
						$("#ms-resolution-linker").val(linker);
						$("#ms-resolution-value").val(value); 
						break;
					case "ionization":
						$("#ms-ionization_method-linker").val(linker);
						$("#ms-ionization_method-value").val(value); 
						break;
					case "analyzer":
						$("#ms-analyzer-linker").val(linker);
						$("#ms-analyzer-value").val(value); 
						break;
					default:
						break;
					}
				}
				break;
			}
		}
	});
	$("#ms-compound-name").val(query);
}


$(document).ready(function() {
	var rawQuery = $("#search").val().toUpperCase();
	if (rawQuery.startsWith("LCMS ")) {
		$("#link-searchAdvance-spectra-ms").click();
    } else if (rawQuery.startsWith("LCMSMS ")) {
    	$("#link-searchAdvance-spectra-ms").click();
    } else if (rawQuery.startsWith("GCMS ")) {
    	$("#link-searchAdvance-spectra-gcms").click();
    } else if (rawQuery.startsWith("NMR ")) {
    	$("#link-searchAdvance-spectra-nmr").click();
    }
	// new 2.3
	else if (rawQuery.startsWith("ICMS ")) {
    	$("#link-searchAdvance-spectra-ms").click();
    } else if (rawQuery.startsWith("ICMSMS ")) {
    	$("#link-searchAdvance-spectra-ms").click();
    }
    // classic
    else {
    	$("#link-searchAdvance-compounds").click();
    }
});

	//]]>
	</script>


</head>
<body>
	<div class="modal-dialog">
		<div class="modal-content ">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.advSearch.title" text="Advanced Search" /></h4>
			</div>
			<div class="modal-body">
				<div class="te">
					<div class="col-lg-12">
						<ul class="nav nav-tabs" style="margin-bottom: 15px;">
							<li class="active">
								<a href="#searchAdvance-compounds-panel" data-toggle="tab" onclick="searchAdvanceSwitchPanel('compounds');">
									<i class="fa fa-flask"></i> <spring:message code="modal.advSearch.tabCompounds" text="Compounds" />
								</a>
							</li>
							<!-- new 2.3 - all MS spectra together -->
							<li>
								<a id="link-searchAdvance-spectra-ms" href="#searchAdvance-spectra-ms-panel" data-toggle="tab" onclick="searchAdvanceSwitchPanel('ms-spectra');">
									<i class="fa fa-bar-chart-o"></i> <spring:message code="modal.advSearch.tabSpectrumsMS" text="LC/IC - MS/MSMS Spectra" />
								</a>
							</li>
<!-- 							<li> -->
<!-- 								<a id="link-searchAdvance-spectra-lcms" href="#searchAdvance-spectra-lcms-panel"  onclick="searchAdvanceSwitchPanel('lcms-spectra');" data-toggle="tab"> -->
<%-- 									<i class="fa fa-bar-chart-o"></i> <spring:message code="modal.advSearch.tabSpectrumsLCMS" text="LC-MS Spectra" /> --%>
<!-- 								</a> -->
<!-- 							</li> -->
<!-- 							<li> -->
<!-- 								<a id="link-searchAdvance-spectra-lcmsms" href="#searchAdvance-spectra-lcmsms-panel"  onclick="searchAdvanceSwitchPanel('lcmsms-spectra');" data-toggle="tab"> -->
<%-- 									<i class="fa fa-bar-chart-o"></i> <spring:message code="modal.advSearch.tabSpectrumsLCMSMS" text="LC-MSMS Spectra" /> --%>
<!-- 								</a> -->
<!-- 							</li> -->
							<li>
								<a id="link-searchAdvance-spectra-nmr" href="#searchAdvance-spectra-nmr-panel" data-toggle="tab" onclick="searchAdvanceSwitchPanel('nmr-spectra');">
									<i class="fa fa-bar-chart-o fa-flip-horizontal"></i> <spring:message code="modal.advSearch.tabSpectrumsNMR" text="NMR Spectra" />
								</a>
							</li>
							<li>
								<a id="link-searchAdvance-spectra-gcms" href="#searchAdvance-spectra-gcms-panel" data-toggle="tab" onclick="searchAdvanceSwitchPanel('gcms-spectra');">
									<i class="fa fa-bar-chart-o"></i> <spring:message code="modal.advSearch.tabSpectrumsGCMS" text="GCMS Spectra" />
								</a>
							</li>
							<!-- new 2.3 -->
<!-- 							<li> -->
<!-- 								<a id="link-searchAdvance-spectra-icms" href="#searchAdvance-spectra-icms-panel" data-toggle="tab" onclick="searchAdvanceSwitchPanel('icms-spectra');"> -->
<%-- 									<i class="fa fa-bar-chart-o"></i> <spring:message code="modal.advSearch.tabSpectrumsICMS" text="ICMS Spectra" /> --%>
<!-- 								</a> -->
<!-- 							</li> -->
<!-- 							<li> -->
<!-- 								<a id="link-searchAdvance-spectra-icmsms" href="#searchAdvance-spectra-icmsms-panel" data-toggle="tab" onclick="searchAdvanceSwitchPanel('icmsms-spectra');"> -->
<%-- 									<i class="fa fa-bar-chart-o"></i> <spring:message code="modal.advSearch.tabSpectrumsICMSMS" text="ICMSMS Spectra" /> --%>
<!-- 								</a> -->
<!-- 							</li> -->
							
						</ul>
						<div id="searchAdvance-mgmt" class="tab-content">
							<div class="tab-pane fade active in" id="searchAdvance-compounds-panel">
								<div class="form-group input-group" style="width: 700px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.nameLike" text="Name like" /></span>
									<input id="advancedSearchCompQuery" style="width: 550px;" type="text" class="form-control advancedSearch" placeholder="<spring:message code="modal.advSearch.nameLike.ph" text="e.g.: acid" />" style="width: 600px;">
								</div>
								<div class="form-group input-group" style="width: 700px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params" text="params" /></span>
									<select id="advancedSearch-compound-filter" class="form-control advancedSearch" style="width: 200px;">
										<option value="1"><spring:message code="modal.advSearch.params.filterMIM" text="Monoisotopic Mass (Da)" /></option>
										<option value="2"><spring:message code="modal.advSearch.params.filterAVM" text="Average Mass (Da)" /></option>
										<option value="3"><spring:message code="modal.advSearch.params.filterFOR" text="Formula" /></option>
										<!-- <option value="5">Chemical Name</option> -->
										<option value="4"><spring:message code="modal.advSearch.params.filterLOGP" text="LogP" /></option>
									</select>
									<input id="advancedSearchMassMass" class="form-control advancedSearch advancedSearchMass" style="width: 175px;" placeholder="<spring:message code="modal.advSearch.params.mass.ph" text="mass (e.g.: 180.03)" />">
									<input id="advancedSearchMassTol" class="form-control advancedSearch advancedSearchMass" class="form-control" style="width: 175px;" placeholder="<spring:message code="modal.advSearch.params.tol.ph" text="tolerance (e.g.: 0.5)" />"> 
									<input id="advancedSearchFormulaFor" class="form-control advancedSearch advancedSearchFormula" class="form-control" style="width: 350px; display: none;" placeholder="<spring:message code="modal.advSearch.params.for.ph" text="formula (e.g.: C8H10N4O2)" />">
									<input id="advancedSearchLogPLogP" class="form-control advancedSearch advancedSearchLogP" style="width: 175px;" placeholder="<spring:message code="modal.advSearch.params.logp.ph" text="LogP (e.g.: -3.4)" />">
									<input id="advancedSearchLogPTol" class="form-control advancedSearch advancedSearchLogP" class="form-control" style="width: 175px;" placeholder="<spring:message code="modal.advSearch.params.tol.ph" text="tolerance (e.g.: 0.5)" />">
								</div>
								<div>
									<small>
										<spring:message code="modal.advSearch.params.massHelp1" text="Note: for mass search, the default delta value is 0.1 Da if the query mass has one or less number after the comma. " /> 
										<spring:message code="modal.advSearch.params.massHelp2" text="The default delta value decrease if the accuracy of the mass increase (last decimal number &plusmn; 1). " />
										<spring:message code="modal.advSearch.params.massHelp3" text="The default delta value can not be lower than 10<sup>-6</sup>. " />
									</small>
								</div>
								
								<a id="linkShowHideAvancedSearchMass" href="javascript:void(0)" onclick="showHideAvancedSearchMassPanel();" class=""><spring:message code="modal.advSearch.cpd.more" text="more..." /></a>
								<div id="avancedSearchMassPanel" style="display: none;">
									<form class="form-horizontal" role="form">
										<fielset>
										<legend></legend>
										<div class="form-group">
											<label class="control-label col-sm-2"><spring:message code="modal.advSearch.cpd.more.charge" text="Charge" /></label>
											<div class="field col-sm-10 field ">
												<label class="radio-inline">
													<input class="advancedSearch advancedSearchMassCharge" checked="checked" id="mode_positive" name="mode" type="radio" value="positive"> <spring:message code="modal.advSearch.cpd.more.chargePos" text="positive" />
												</label>
												<label class="radio-inline">
													<input class="advancedSearch advancedSearchMassCharge" id="mode_negative" name="mode" type="radio" value="negative"> <spring:message code="modal.advSearch.cpd.more.chargeNeg" text="negative" />
												</label>
												<label class="radio-inline">
													<input class="advancedSearch advancedSearchMassCharge" id="mode_neutral" name="mode" type="radio" value="neutral"> <spring:message code="modal.advSearch.cpd.more.chargeNeu" text="neutral" />
												</label>
											</div>
											<div>
												<small>
													<spring:message code="modal.advSearch.params.massModeCharge.note" text="Note:" />
														<ul>
															<li><spring:message code="modal.advSearch.params.massModeCharge.neutral" text="neutral: search same Monoisotopic Mass" /></li>
															<li><spring:message code="modal.advSearch.params.massModeCharge.positive" text="positive: Monoisotopic Mass + 1.0072767" /></li>
															<li><spring:message code="modal.advSearch.params.massModeCharge.negative" text="negative: Monoisotopic Mass - 1.0072766" /></li>
														</ul>
												</small>
											</div>
										</div>
										<!-- 
										<div class="form-group">
											<label class="control-label col-sm-2"><spring:message code="modal.advSearch.cpd.more.massUnit" text="Mass Unit" /></label>
											<div class="field col-sm-10 field ">
												<label class="radio-inline"><input checked="checked" id="unit_da" name="unit" type="radio" value="da"><spring:message code="modal.advSearch.cpd.more.massUnitDa" text="Da" /></label>
												<label class="radio-inline"><input id="unit_ppm" name="unit" type="radio" value="ppm"><spring:message code="modal.advSearch.cpd.more.massUnitPPM" text="ppm" /></label>
											</div>
										</div>
										<div class="form-group">
											<label class="control-label col-sm-2"><spring:message code="modal.advSearch.cpd.more.adducts" text="Adducts" /></label>
											<div class="field col-sm-10">
												<select class="adduct-select form-control " id="neutral-adducts" multiple="multiple" name="neutral_adducts[]" size="3" style="display: none">
													<option value="M">M</option>
												</select>
												<select class="adduct-select form-control" id="positive-adducts" multiple="multiple" name="positive_adducts[]" size="12">
													<option value="[M+H]+">[M+H]+</option>
													<option value="[M+NH4]+">[M+NH4]+</option>
													<option value="[M+Na]+">[M+Na]+</option>
													<option value="[M+K]+">[M+K]+</option>
													<option value="[M+H-H2O]+">[M+H-H2O]+</option>
													<option value="[M+H-2H2O]+">[M+H-2H2O]+</option>
													<option value="[M+CH3OH+H]+">[M+CH3OH+H]+</option>
													<option value="[M+CH3CN+H]+">[M+CH3CN+H]+</option>
													<option value="[2M+H]+">[2M+H]+</option>
													<option value="[2M+NH4]+">[2M+NH4]+</option>
													<option value="[2M+Na]+">[2M+Na]+</option>
													<option value="[2M+K]+">[2M+K]+</option>
												</select>
												<select class="adduct-select form-control" id="negative-adducts" multiple="multiple" name="negative_adducts[]" size="8" style="display: none">
													<option value="[M-H]-">[M-H]-</option>
													<option value="[M-H-H2O]-">[M-H-H2O]-</option>
													<option value="[M+HCOOH-H]-">[M+HCOOH-H]-</option>
													<option value="[M+CH3COOH-H]-">[M+CH3COOH-H]-</option>
													<option value="[2M-H]-">[2M-H]-</option>
													<option value="[2M+HCOOH-H]-">[2M+HCOOH-H]-</option>
													<option value="[2M+CH3COOH-H]-">[2M+CH3COOH-H]-</option>
													<option value="[3M-H]-">[3M-H]-</option>
												</select>
											</div>
										</div>
										 -->
										</fielset>
									</form>
								</div>
							</div>
							<div class="tab-pane fade" id="searchAdvance-spectra-lcms-panel">
								<div class="form-group input-group" style="width: 350px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.compoundLike" text="Compound like" /></span>
									<input id="lcms-cpd-name" style="width: 200px;" type="text" class="form-control advancedSearch" placeholder="<spring:message code="modal.advSearch.params.compoundLike.eg" text="e.g.: Gluc" />" value="" >
								</div>
								<div class="form-group input-group" style="">
									<label><spring:message code="modal.advSearch.params.polarity" text="Polarity" />&nbsp;</label>
									<label class="radio-inline">
										<input type="radio" name="lcms-polarity" class="advancedSearch" id="lcms-polarity-all" value="" checked="checked"> <spring:message code="modal.advSearch.params.polarity.all" text="all" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcms-polarity" class="advancedSearch" id="lcms-polarity-pos" value="positive"> <spring:message code="modal.advSearch.params.polarity.positive" text="positive" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcms-polarity" class="advancedSearch" id="lcms-polarity-neg" value="negative"> <spring:message code="modal.advSearch.params.polarity.negative" text="negative" />
									</label>
								</div>
								<div class="form-group input-group" style="">
									<label><spring:message code="modal.advSearch.params.resolution" text="Resolution" />&nbsp;</label>
									<label class="radio-inline">
										<input type="radio" name="lcms-resolution" class="advancedSearch" id="lcms-resolution-all" value="" checked="checked"> <spring:message code="modal.advSearch.params.resolution.all" text="all" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcms-resolution" class="advancedSearch" id="lcms-resolution-high" value="high"> <spring:message code="modal.advSearch.params.resolution.high" text="high" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcms-resolution" class="advancedSearch" id="lcms-resolution-low" value="low"> <spring:message code="modal.advSearch.params.resolution.low" text="low" />
									</label>
								</div>
								<div class="form-group input-group" style="width: 300px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.ionMethod" text="Ionization Method" /></span>
									<select id="lcms-ionMeth" class="advancedSearch form-control" style="width: 150px;">
										<option value=""></option>
<!-- 										<option value="XXX">XXX</option> -->
									</select>
								</div>
								<div class="form-group input-group" style="width: 300px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.ionAnalyzerType" text="Ion analyzer type" /></span>
									<select id="lcms-ionAnalyzer" class="advancedSearch form-control" style="width: 150px;">
										<option value=""></option>
										<option value="TOF">TOF</option>
										<option value="EB">EB</option>
										<option value="ITFT">ITFT</option>
										<option value="QTOF">QTOF</option>
										<option value="QQQ">QQQ</option>
<!-- 										<option value="XXX">XXX</option> -->
									</select>
								</div>
							</div>
							<!--
							////////////////////////////////////////////////////// 
							 -->
							<div class="tab-pane fade" id="searchAdvance-spectra-lcmsms-panel">
								<div class="form-group input-group" style="width: 350px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.compoundLike" text="Compound like" /></span>
									<input id="lcmsms-cpd-name" style="width: 200px;" type="text" class="form-control advancedSearch" placeholder="<spring:message code="modal.advSearch.params.compoundLike.eg" text="e.g.: Gluc" />" value="" >
								</div>
								<div class="form-group input-group" style="">
									<label><spring:message code="modal.advSearch.params.polarity" text="Polarity" />&nbsp;</label>
									<label class="radio-inline">
										<input type="radio" name="lcmsms-polarity" class="advancedSearch" id="lcmsms-polarity-all" value="" checked="checked"> <spring:message code="modal.advSearch.params.polarity.all" text="all" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcmsms-polarity" class="advancedSearch" id="lcmsms-polarity-pos" value="positive"> <spring:message code="modal.advSearch.params.polarity.positive" text="positive" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcmsms-polarity" class="advancedSearch" id="lcmsms-polarity-neg" value="negative"> <spring:message code="modal.advSearch.params.polarity.negative" text="negative" />
									</label>
								</div>
								<div class="form-group input-group" style="">
									<label><spring:message code="modal.advSearch.params.resolution" text="Resolution" />&nbsp;</label>
									<label class="radio-inline">
										<input type="radio" name="lcmsms-resolution" class="advancedSearch" id="lcmsms-resolution-all" value="" checked="checked"> <spring:message code="modal.advSearch.params.resolution.all" text="all" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcmsms-resolution" class="advancedSearch" id="lcmsms-resolution-high" value="high"> <spring:message code="modal.advSearch.params.resolution.high" text="high" />
									</label>
									<label class="radio-inline">
										<input type="radio" name="lcmsms-resolution" class="advancedSearch" id="lcmsms-resolution-low" value="low"> <spring:message code="modal.advSearch.params.resolution.low" text="low" />
									</label>
								</div>
								<div class="form-group input-group" style="width: 300px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.ionMethod" text="Ionization Method" /></span>
									<select id="lcmsms-ionMeth" class="advancedSearch form-control" style="width: 150px;">
										<option value=""></option>
<!-- 										<option value="XXX">XXX</option> -->
									</select>
								</div>
								<div class="form-group input-group" style="width: 300px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.ionAnalyzerType" text="Ion analyzer type" /></span>
									<select id="lcmsms-ionAnalyzer" class="advancedSearch form-control" style="width: 150px;">
										<option value=""></option>
										<option value="TOF">TOF</option>
										<option value="EB">EB</option>
										<option value="ITFT">ITFT</option>
										<option value="QTOF">QTOF</option>
										<option value="QQQ">QQQ</option>
<!-- 										<option value="XXX">XXX</option> -->
									</select>
								</div>
							</div>
							<!--
							////////////////////////////////////////////////////// 
							 -->
							<div class="tab-pane fade" id="searchAdvance-spectra-nmr-panel">
								<div class="form-group input-group" style="width: 350px;">
									<span class="input-group-addon" style="width: 150px;"><spring:message code="modal.advSearch.params.compoundLike" text="Compound like" /></span>
									<input id="nmr-cpd-name" style="width: 200px;" type="text" class="form-control advancedSearch" placeholder="<spring:message code="modal.advSearch.params.compoundLike.eg" text="e.g.: Gluc" />" value="" >
								</div>
								
								<!-- pH -->
								<div class="form-group input-group" style="width: 340px;">
									<select id="nmr-ph-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">
										<spring:message code="modal.advSearch.params.pH" text="pH" />&nbsp;
									</span>
									<input id="nmr-ph-value" style="width: 100px;" type="number" class="form-control advancedSearch" placeholder="<spring:message code="modal.advSearch.params.pH.eg" text="7" />" value="" min="0" max="15">
								</div>
								
								<!-- pulse sequence -->
								<div class="form-group input-group" style="width: 340px;">
									<select id="nmr-pulseseq-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">
										<spring:message code="modal.advSearch.params.pulseSeq" text="pulse seq." />&nbsp;
									</span>
									<select id="nmr-pulseseq-value" class="form-control advancedSearch" style="width: 200px;">
										<option value=""></option>
										<optgroup label="1D-NMR">
											<option value="Proton-1D">Proton</option>
											<option value="NOESY-1D">NOESY</option>
											<option value="CPMG-1D">CPMG</option>
											<option value="Carbon-13">Carbon-13</option>
										</optgroup>
										<optgroup label="2D-NMR">
											<option value="JRES-2D">JRES</option>
											<option value="COSY-2D">COSY</option>
											<option value="TOCSY-2D">TOCSY</option>
											<option value="NOESY-2D">NOESY</option>
											<option value="HMBC-2D">HMBC</option>
											<option value="HSQC-2D">HSQC</option>
										</optgroup>
									</select>
								</div>
								 
								<!-- magnetic force field -->
								<div class="form-group input-group" style="width: 340px;">
									<select id="nmr-magneticFieldStrength-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">
										<spring:message code="modal.advSearch.params.magneticFieldStrength" text="magnetic field strength" />&nbsp;
									</span>
									<select id="nmr-magneticFieldStrength-value" class="advancedSearch form-control" style="width: 170px;"></select>
								</div>
								 
								<!-- solvent -->
								<div class="form-group input-group" style="width: 340px;">
									<select id="nmr-solvent-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">
										<spring:message code="modal.advSearch.params.solvent" text="solvent" />&nbsp;
									</span>
									<select id="nmr-solvent-value" class="advancedSearch form-control" style="width: 200px;"></select>
								</div>
								
								<!-- raw filter -->
								<div class="form-group col-sm-11">
									<label class="control-label col-sm-6"><spring:message code="modal.advSearch.nmr.filter.onlyRawData" text="Check to search only spectra with RAW data" /></label>
									<div class="field col-sm-4 field ">
										<label class="radio-inline">
											<input class="advancedSearch" id="filter_nmr_raw_data" name="filter_nmr_raw_data" type="checkbox" value="true"> 
										</label> 
									</div>
								</div>
								
								<a id="linkShowHideAvancedSearchNmr" href="javascript:void(0)" onclick="showHideAvancedSearchNmrPanel();" class="" style="display: inline;"><spring:message code="modal.advSearch.cpd.more" text="more..." /></a>
								<div id="avancedSearchNmrPanel" style="display: none;">
									<form class="form-horizontal" role="form">
										<fielset>
											<legend></legend>
											<div class="form-group col-sm-11">
												<label class="control-label col-sm-6"><spring:message code="modal.advSearch.cpd.more.isotopicLabelling.D" text="Deuterium isotopic labelling" /></label>
												<div class="field col-sm-4 field ">
													<label class="radio-inline">
														<input class="advancedSearch advancedSearchNmrD" id="isotopic_labelling_Dy" name="isotopic_labelling_D" type="radio" value="yes"> <spring:message code="modal.advSearch.cpd.more.isotopicLabelling.yes" text="yes" />
													</label>
													<label class="radio-inline">
														<input class="advancedSearch advancedSearchNmrD" checked="checked" id="isotopic_labelling_Dn" name="isotopic_labelling_D" type="radio" value="no"> <spring:message code="modal.advSearch.cpd.more.isotopicLabelling.no" text="no" />
													</label>
												</div>
											</div>
											<div class="form-group col-sm-11">
												<label class="control-label col-sm-6"><spring:message code="modal.advSearch.cpd.more.isotopicLabelling.C" text="Carbon-13 isotopic labelling" /></label>
												<div class="field col-sm-4 field ">
													<label class="radio-inline">
														<input class="advancedSearch advancedSearchNmrC" id="isotopic_labelling_Cy" name="isotopic_labelling_C" type="radio" value="yes"> <spring:message code="modal.advSearch.cpd.more.isotopicLabelling.yes" text="yes" />
													</label>
													<label class="radio-inline">
														<input class="advancedSearch advancedSearchNmrC" checked="checked" id="isotopic_labelling_Cn" name="isotopic_labelling_C" type="radio" value="no"> <spring:message code="modal.advSearch.cpd.more.isotopicLabelling.no" text="no" />
													</label>
												</div>
											</div>
											<div class="form-group col-sm-11">
												<label class="control-label col-sm-6"><spring:message code="modal.advSearch.cpd.more.isotopicLabelling.N" text="Nitrogen-15 isotopic labelling" /></label>
												<div class="field col-sm-4 field ">
													<label class="radio-inline">
														<input class="advancedSearch advancedSearchNmrN" id="isotopic_labelling_Ny" name="isotopic_labelling_N" type="radio" value="yes"> <spring:message code="modal.advSearch.cpd.more.isotopicLabelling.yes" text="yes" />
													</label>
													<label class="radio-inline">
														<input class="advancedSearch advancedSearchNmrN" checked="checked" id="isotopic_labelling_Nn" name="isotopic_labelling_N" type="radio" value="no"> <spring:message code="modal.advSearch.cpd.more.isotopicLabelling.no" text="no" />
													</label>
												</div>
											</div>
										</fielset>
									</form>
								</div><!-- ./avancedSearchNmrPanel -->
							</div>
							<!--
							////////////////////////////////////////////////////// 
							 -->
							<div class="tab-pane fade" id="searchAdvance-spectra-gcms-panel">
								<!-- compound name -->
								<div class="form-group input-group" style="width: 350px;">
									<span class="input-group-addon" 
										style="width: 150px;">
											<spring:message code="modal.advSearch.params.compoundLike" 
												text="Compound like" />
									</span>
									<input id="gcms-cpd-name" 
										style="width: 200px;" 
										type="text" 
										class="form-control advancedSearch" 
										placeholder="<spring:message code="modal.advSearch.params.compoundLike.eg" text="e.g.: Gluc" />" 
										value="" />
								</div>
								<!-- derivation -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="gcms-derivation-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="OR"  selected>OR</option>
										<option value="AND" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">derivation method</span>
									<select id="gcms-derivation-value" class="form-control advancedSearch" style="width: 420px;">
										<option value="na" selected></option>
										<option value="oximation_and_sylilation">oximation and sylilation</option> 
										<option value="sylilation">sylilation</option> 
										<option value="acylation">acylation</option> 
										<option value="esterification">esterification</option> 
										<option value="none">none</option> 
									</select>
								</div>
								<!-- derivated type -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="gcms-derivated_type-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="OR"  selected>OR</option>
										<option value="AND" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">derivated type</span>
									<select id="gcms-derivated_type-value" class="form-control advancedSearch" style="width: 420px;">
										<option value="na" selected></option>
										<option value="None">None</option>
										<option value="1_TMS">1 TMS</option>
										<option value="2_TMS">2 TMS</option>
										<option value="3_TMS">3 TMS</option>
										<option value="4_TMS">4 TMS</option>
										<option value="5_TMS">5 TMS</option>
										<option value="6_TMS">6 TMS</option>
										<option value="7_TMS">7 TMS</option>
										<option value="8_TMS">8 TMS</option>
										<option value="9_TMS">9 TMS</option>
										<option value="10_TMS">10 TMS</option>
										<option value="11_TMS">11 TMS</option>
										<option value="12_TMS">12 TMS</option>
										<option value="1_TBDMS">1 TBDMS</option>
										<option value="2_TBDMS">2 TBDMS</option>
										<option value="3_TBDMS">3 TBDMS</option>
										<option value="4_TBDMS">4 TBDMS</option>
										<option value="5_TBDMS">5 TBDMS</option>
										<option value="1_MeOx">1 MeOx</option>
										<option value="2_MeOx">2 MeOx</option>
										<option value="3_MeOx">3 MeOx</option>
										<option value="Unknown">Unknown</option>
									</select>
								</div>
								<!-- ionization -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="gcms-ionization-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="OR" selected>OR</option>
										<option value="AND" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">ionization method</span>
									<select id="gcms-ionization-value" class="form-control advancedSearch" style="width: 420px;">
										<option value="na" selected></option>
										<option value="EI">EI - Electron Impact</option> 
										<option value="CI">CI - Chemical Ionization</option>  
									</select>
								</div>
								<!-- analyzer type -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="gcms-analyzer-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="OR"  selected>OR</option>
										<option value="AND" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">analyzer type</span>
									<input id="gcms-analyzer-value" type="text" class="form-control advancedSearch" placeholder="e.g.: TOF / QTOF / QQQ / ..." style="width: 420px;">
								</div>
								
							</div><!-- #/searchAdvance-spectra-gcms-panel -->
							<!-- ######################################################################### -->
							<div class="tab-pane fade" id="searchAdvance-spectra-ms-panel">
								
								<!-- search entities -->
								<div class="form-group input-group" style="width: 490px;">
<!-- 									<select id="ms-ionization-method-linker" class="form-control advancedSearch" style="width: 100px;"> -->
<!-- 										<option value="OR"  selected>OR</option> -->
<!-- 										<option value="AND" >AND</option>  -->
<!-- 									</select> -->
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">search spectra</span>
									<select id="ms-search-type" class="form-control advancedSearch" style="width: 310px;">
										<option value="LCMS">LC-MS</option>
										<option value="LCMSMS">LC-MSMS</option>
										<option value="ICMS">IC-MS</option>
										<option value="ICMSMS" disabled="disabled">IC-MSMS</option>
									</select>
								</div>
								
								<!-- compound name -->
								<div class="form-group input-group" style="width: 450px;">
									<span class="input-group-addon" 
										style="width: 150px;">
											<spring:message code="modal.advSearch.params.compoundLike" 
												text="Compound like" />
									</span>
									<input id="ms-compound-name" 
										style="width: 300px;" 
										type="text" 
										class="form-control advancedSearch" 
										placeholder="<spring:message code="modal.advSearch.params.compoundLike.eg" text="e.g.: Gluc" />" 
										value="" />
								</div>
								
								<!-- polarity -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="ms-polarity-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">
										<spring:message code="modal.advSearch.params.polarity" text="Polarity" />&nbsp;
									</span>
									<select id="ms-polarity-value" class="form-control advancedSearch" style="width: 420px;">
										<option selected="selected" disabled="disabled"></option>
										<option value="positive" ><spring:message code="modal.advSearch.params.polarity.positive" text="positive" /></option> 
										<option value="negative" ><spring:message code="modal.advSearch.params.polarity.negative" text="negative" /></option> 
									</select>
								</div>
								
								<!-- resolution -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="ms-resolution-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">
										<spring:message code="modal.advSearch.params.resolution" text="Resolution" />&nbsp;
									</span>
									<select id="ms-resolution-value" class="form-control advancedSearch" style="width: 420px;">
										<option selected="selected" disabled="disabled"></option>
										<option value="high" ><spring:message code="modal.advSearch.params.resolution.high" text="high" /></option> 
										<option value="low" ><spring:message code="modal.advSearch.params.resolution.low" text="low" /></option> 
									</select>
								</div>
								
								<!-- MS ionization method -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="ms-ionization_method-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">ionization method</span>
									<select id="ms-ionization_method-value" class="form-control advancedSearch" style="width: 420px;">
										<option value=""></option>
									</select>
								</div>
								
								<!-- MS ion analyzer type -->
								<div class="form-group input-group" style="width: 600px;">
									<select id="ms-analyzer-linker" class="form-control advancedSearch" style="width: 100px;">
										<option value="or"  selected>OR</option>
										<option value="and" >AND</option> 
									</select>
									<span class="input-group-addon" style="width: 140px; min-width: 140px;">analyzer type</span>
<!-- 									<input id="icms-analyzer-value" type="text" class="form-control advancedSearch" placeholder="e.g.: TOF / QTOF / QQQ / ..." style="width: 420px;"> -->
									<select id="ms-analyzer-value" class="form-control advancedSearch" style="width: 420px;">
										<option value=""></option>
										<option value="TOF">TOF</option>
										<option value="EB">EB</option>
										<option value="ITFT">ITFT</option>
										<option value="QTOF">QTOF</option>
										<option value="QQQ">QQQ</option>
									</select>
								</div>
								
							</div><!-- #/searchAdvance-spectra-ms-panel -->
							
							<!-- ######################################################################### -->
						</div>
						<!-- /.row -->
						<script type="text/javascript">
// 						console.log("a " + searchAdvanceEntities);
						
		$.getJSON("resources/json/list-ms-ionization-methods.json", function(data) {
			// load data from json
			$.each(data.methods, function(){
				if (this.name !== undefined) {
					if (this.value !== undefined) {
						$("#ms-ionization_method-value").append('<option value="'+this.value+'">' + this.name + '</option>');
// 						$("#lcms-ionMeth").append('<option value="'+this.value+'">'+this.name+'</option>');
// 						$("#lcmsms-ionMeth").append('<option value="'+this.value+'">'+this.name+'</option>');
// 						$("#icms-ionization-method-value").append('<option value="'+this.value+'">'+this.name+'</option>');
// 						$("#icmsms-ionization-method-value").append('<option value="'+this.value+'">'+this.name+'</option>');
					} else {
						$("#ms-ionization_method-value").append('<option disabled="disabled">' + this.name + '</option>');
// 						$("#icms-ionization-method-value").append('<option disabled>'+this.name+'</option>');
// 						$("#icmsms-ionization-method-value").append('<option disabled>'+this.name+'</option>');
					}
				}
			});
		});
		
		// NMR instrument
		$.getJSON("resources/json/list-nmr-instrumentOptions.json", function(data) {
			$("#nmr-magneticFieldStrength-value").empty();
			$("#nmr-magneticFieldStrength-value").append('<option value="" selected="selected" ></option>');
			// load data from json
			$.each(data.magnetic_field_strength,function(){
				$("#nmr-magneticFieldStrength-value").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
			});
		});
		
		// NMR solvent
		$("#nmr-solvent-value").append('<option value="" selected="selected" ></option>');
		$.getJSON("resources/json/list-nmr-solvents.json", function(data) {
			// load data from json
			$.each(data.solvents,function(){
				$("#nmr-solvent-value").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
			});
		});
						
		function loadRawQuery() {
			var rawQuery = $("#search").val();
			var rawQueryTab = rawQuery.split(" ");
			var query = "";
			$.each(rawQueryTab, function(k, v) {
				if (v != "") {
					var res = v.split(":");
					if (res != null && res.length == 2) {
						var filterType = res[0];
						var filterVal = res[1];
						switch (filterType) {
						case "AVM":
							$("#advancedSearch-compound-filter").val(2);
							var massData = filterVal.split("d");
							var mass = massData[0];
							var tol = massData[1];
							$("#advancedSearchMassMass").val(mass);
							$("#advancedSearchMassTol").val(tol);
							searchAdvanceEntities = "compounds";
							//$("#avancedSearchMassPanel-link").show();
							break;
						case "MIM":
							$("#advancedSearch-compound-filter").val(1);
							var massData = filterVal
									.split("d");
							var mass = massData[0];
							var tol = massData[1];
							$("#advancedSearchMassMass").val(mass);
							$("#advancedSearchMassTol").val(tol);
							searchAdvanceEntities = "compounds";
							$("#avancedSearchMassPanel-link").show();
							break;
						case "FOR":
							$("#advancedSearch-compound-filter").val(3);
							$("#advancedSearchFormulaFor").val(filterVal);
							searchAdvanceEntities = "compounds";
							$("#avancedSearchMassPanel-link").hide();
							break;
						case "LOGP":
							$("#advancedSearch-compound-filter").val(4);
							var logpData = filterVal.split("d");
							var logp = logpData[0];
							var tol = logpData[1];
							$("#advancedSearchLogPLogP").val(logp);
							$("#advancedSearchLogPTol").val(tol);
							searchAdvanceEntities = "compounds";
							$("#avancedSearchMassPanel-link").hide();
							break;
						case "mode":
							$("#mode_" +filterVal).prop("checked", true);
							$("#linkShowHideAvancedSearchMass").click();
							break;
						default: 
							searchAdvanceEntities = "compounds";
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
			switch (switchAdvSearch) {
			case "nmr-spectra":
				searchAdvanceEntities = 'nmr-spectra';
				break;
			case "lcms-spectra":
			case "lcmsms-spectra":
			case "icms-spectra":
			case "icmsms-spectra":
				searchAdvanceEntities = switchAdvSearch;
				break;
			case "gcms-spectra":
				searchAdvanceEntities = switchAdvSearch;
				break;
			}
			switch (searchAdvanceEntities) {
			case "lcms-spectra":
			case "lcmsms-spectra":
			case "icms-spectra":
			case "icmsms-spectra":
				$('#link-searchAdvance-spectra-ms').click();
				break;
			case "gcms-spectra":
				$('#link-searchAdvance-spectra-gcms').click();
				break;
// 			case "lcms-spectra":
// 				$('#link-searchAdvance-spectra-lcms').click();
// 				break;
// 			case "lcmsms-spectra":
// 				$('#link-searchAdvance-spectra-lcmsms').click();
// 				break;
			case "nmr-spectra":
				$('#link-searchAdvance-spectra-nmr').click();
				setTimeout(function(){$("#nmr-peaklist").focus();},200);
				break;
			default:
				setTimeout(function(){$("#advancedSearchCompQuery").focus();},200);
				break;
			}//switch
			displayAdvancedSearch();
		}

		loadRawQuery();
		//acid AVM:123.456d0.0003
		
		
		submitAdvancedSearchForm = function() {
			loadAdvancedSearch();
			$("#searchForm").submit();
		};
		
		$(".advancedSearch").change(function() {
			loadAdvancedSearch(this);
		});

		$(".advancedSearchMassCharge").click(function() {
			var id = $(this).attr('id');
			console.log("id=" + id);
			switch (id) {
			case "mode_negative":
				$("#negative-adducts").show();
				$("#neutral-adducts").hide();
				$("#positive-adducts").hide();
				break;
			case "mode_neutral":
				$("#negative-adducts").hide();
				$("#neutral-adducts").show();
				$("#positive-adducts").hide();
				break;
			case "mode_positive":
				$("#negative-adducts").hide();
				$("#neutral-adducts").hide();
				$("#positive-adducts").show();
				break;
			}//switch
		});

		function displayAdvancedSearch() {
			var hideMass = Number($("#advancedSearch-compound-filter").val());
			$(".advancedSearchFormula").hide();
			$(".advancedSearchMass").hide(); 
			$(".advancedSearchLogP").hide(); 
			$("#avancedSearchMassPanel").hide();
			$("#linkShowHideAvancedSearchMass").hide();
			switch (hideMass) {
			case 1:
				$(".advancedSearchMass").show();
				$("#linkShowHideAvancedSearchMass").show();
				if (displayAvancedSearchMassPanel) {
					$("#avancedSearchMassPanel").show();
				}
				break;
			case 2:
				$(".advancedSearchMass").show();
				break;
			case 3:
				$(".advancedSearchFormula").show();
				break;
			case 4:
				$(".advancedSearchLogP").show();
				break;
			default:
				break;
			}
		}

		var displayAvancedSearchMassPanel = false;
		function showHideAvancedSearchMassPanel() {
			displayAvancedSearchMassPanel = !displayAvancedSearchMassPanel;
			if (displayAvancedSearchMassPanel) {
				$("#avancedSearchMassPanel").show();
				$("#linkShowHideAvancedSearchMass").html('<spring:message code="modal.advSearch.cpd.less" text="...less" />');
			} else {
				$("#avancedSearchMassPanel").hide();
				$("#linkShowHideAvancedSearchMass").html('<spring:message code="modal.advSearch.cpd.more" text="more..." />');
			}
		}
		
		var displayAvancedSearchNmrPanel = false;
		function showHideAvancedSearchNmrPanel() {
			displayAvancedSearchNmrPanel = !displayAvancedSearchNmrPanel;
			if (displayAvancedSearchNmrPanel) {
				$("#avancedSearchNmrPanel").show();
				$("#linkShowHideAvancedSearchNmr").html('<spring:message code="modal.advSearch.cpd.less" text="...less" />');
				$("#searchAdvance-spectra-nmr-panel").css('height', (+110 + Number($("#searchAdvance-spectra-nmr-panel").css('height').replace("px",""))) + "px");
			} else {
				$("#avancedSearchNmrPanel").hide();
				$("#linkShowHideAvancedSearchNmr").html('<spring:message code="modal.advSearch.cpd.more" text="more..." />');
				$("#searchAdvance-spectra-nmr-panel").css('height', (-110 + Number($("#searchAdvance-spectra-nmr-panel").css('height').replace("px",""))) + "px");
			}
		}

		function loadAdvancedSearch(elem) {
			var e = $(elem);
			var id = e.attr('id');
			var val = e.val();
			//console.log("id="+id);
			//console.log("val="+val);
			var mainSearchQuery = "";// $("#search").val();;
			switch (searchAdvanceEntities) {
			case "compounds":
				$("#searchSpectraF").remove();
				switch ($("#advancedSearch-compound-filter").val()) {
				case "1":
					mainSearchQuery += $("#advancedSearchCompQuery").val() + " ";
					mainSearchQuery += "MIM:" + $("#advancedSearchMassMass").val() + "d" + $("#advancedSearchMassTol").val();
					if ($("#avancedSearchMassPanel").is(":visible")) {
						mainSearchQuery += " " + "mode:" + $("input[name='mode']:checked").val();
					}
					break;
				case "2":
					mainSearchQuery += $("#advancedSearchCompQuery").val() + " ";
					mainSearchQuery += "AVM:" + $("#advancedSearchMassMass").val() + "d" + $("#advancedSearchMassTol").val();
					break;
				case "3":
					mainSearchQuery += $("#advancedSearchCompQuery").val() + " ";
					mainSearchQuery += "FOR:" + $("#advancedSearchFormulaFor").val();
					break;
				case "4":
					mainSearchQuery += $("#advancedSearchCompQuery").val() + " ";
					mainSearchQuery += "LOGP:" + $("#advancedSearchLogPLogP").val() + "d" + $("#advancedSearchLogPTol").val();
					break;
				}
				break; 
			case "nmr-spectra":
				if (!($($("input#searchSpectraF")).length)) {
					$("form#searchForm").append('<input id="searchSpectraF" type="hidden" name="spectra" value="nmr" />');
				}
				mainSearchQuery = 'NMR ' + $("#nmr-cpd-name").val();
				if ($("#nmr-ph-value").val() !== null && $("#nmr-ph-value").val() != "") {
					mainSearchQuery += " " + $("#nmr-ph-linker").val() + "~ph~" + $("#nmr-ph-value").val();
				}
				if ($("#nmr-pulseseq-value").val() !== null && $("#nmr-pulseseq-value").val() != "") {
					mainSearchQuery += " " + $("#nmr-pulseseq-linker").val() + "~pulseseq~" + $("#nmr-pulseseq-value").val();
				}
				if ($("#nmr-magneticFieldStrength-value").val() !== null && $("#nmr-magneticFieldStrength-value").val() != "") {
					mainSearchQuery += " " + $("#nmr-magneticFieldStrength-linker").val() + "~magneticFieldStrength~" + $("#nmr-magneticFieldStrength-value").val();
				}
				if ($("#nmr-solvent-value").val() !== null && $("#nmr-solvent-value").val() != "") {
					mainSearchQuery += " " + $("#nmr-solvent-linker").val() + "~solvent~" + $("#nmr-solvent-value").val();
				}
				if ($("#filter_nmr_raw_data").is(":checked")) {
					mainSearchQuery += " only_with_raw_data";
				}
				if ($("#isotopic_labelling_Dy").is(":checked"))
					mainSearchQuery += " D";
				if ($("#isotopic_labelling_Cy").is(":checked"))
					mainSearchQuery += " 13C";
				if ($("#isotopic_labelling_Ny").is(":checked"))
					mainSearchQuery += " 15N";
				mainSearchQuery = mainSearchQuery.replace(/\s+/i, " ")
				break;
			case "gcms-spectra":
				if (!($($("input#searchSpectraF")).length)) {
					$("form#searchForm").append('<input id="searchSpectraF" type="hidden" name="spectra" value="gcms" />');
				}
				mainSearchQuery = 'GCMS ' + $("#gcms-cpd-name").val() 
				if ($("#gcms-derivation-value").val() !== null && $("#gcms-derivation-value").val() != "na") {
					mainSearchQuery += " " + $("#gcms-derivation-linker").val() + "~derivation~" + $("#gcms-derivation-value").val();
				}
				if ($("#gcms-derivated_type-value").val() !== null && $("#gcms-derivated_type-value").val() != "na") {
					mainSearchQuery += " " + $("#gcms-derivated_type-linker").val()
						+ "~derivated_type~" + $("#gcms-derivated_type-value").val();
				}
				if ($("#gcms-ionization-value").val() !== null && $("#gcms-ionization-value").val() != "na") {
					mainSearchQuery += " " + $("#gcms-ionization-linker").val() + "~ionization~" + $("#gcms-ionization-value").val();
				}
				if ($("#gcms-analyzer-value").val() !== "") {
					mainSearchQuery += " " + $("#gcms-analyzer-linker").val() + "~analyzer~" + $("#gcms-analyzer-value").val();
				}
				mainSearchQuery = mainSearchQuery.replace(/\s+/i, " ")
				break;
			// new 2.3
			case "ms-spectra":
// 				if (!($($("input#searchSpectraF")).length)) {
// 					$("form#searchForm").append('<input id="searchSpectraF" type="hidden" name="spectra" value="lcms" />');
// 				}
				mainSearchQuery = $("#ms-search-type").val() ;
				mainSearchQuery	+= " " + $("#ms-compound-name").val();  
				if ($("#ms-polarity-value").val() !== null && $("#ms-polarity-value").val() != "") {
					mainSearchQuery += " " + $("#ms-polarity-linker").val() + "~polarity~" + $("#ms-polarity-value").val();
				}
				if ($("#ms-resolution-value").val() !== null && $("#ms-resolution-value").val() != "") {
					mainSearchQuery += " " + $("#ms-resolution-linker").val() + "~resolution~" + $("#ms-resolution-value").val();
				}
				if ($("#ms-ionization_method-value").val() !== null && $("#ms-ionization_method-value").val() != "") {
					mainSearchQuery += " " + $("#ms-ionization_method-linker").val() + "~ionization_method~" + $("#ms-polarity-value").val();
				}
				if ($("#ms-analyzer-value").val() !== null && $("#ms-analyzer-value").val() != "") {
					mainSearchQuery += " " + $("#ms-analyzer-linker").val() + "~analyzer~" + $("#ms-analyzer-value").val();
				}
				mainSearchQuery = mainSearchQuery.replace(/\s+/i, " ")
				break;
			}
			
			if (mainSearchQuery != "") {
				$("#search").val(mainSearchQuery);
			}
			displayAdvancedSearch();
		}
						</script>
						<hr />
						<small>
						<spring:message code="modal.advSearch.helpDoubleQuotes" text="Help: you can add double quotes (\") to perform an exact matcher on an expression; e.g. NMR cholic acid COSY-2D" />
						</small>
					</div>
				</div>
			</div>
			<div class="modal-footer">
			
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="setTimeout(function(){$('#search').focus();},250);"><spring:message code="modal.close" text="Close" /></button>
				<button type="button" class="btn btn-primary" onclick="submitAdvancedSearchForm();">
					<i class="fa fa-search"></i> <spring:message code="modal.advSearch.btnSearch" text="Search" />
				</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>
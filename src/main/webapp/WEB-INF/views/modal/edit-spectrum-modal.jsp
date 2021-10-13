<%@page import="fr.metabohub.peakforest.model.CurationMessage"%>
<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="fr.metabohub.peakforest.utils.PeakForestUtils"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>${(spectrum_name)}</title>
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
	<div class="modal-dialog">
		<div class="modal-content modalLarge">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" onclick="checkIfReOpenDetailsModal();"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.edit.title" text="Edit" /> - ${(spectrum_name)}</h4>
			</div>
			<div class="modal-body ">
				<div class="te">
					<c:if test="${curator}">
						<div>
							<c:forEach var="curationMessage" items="${curationMessages}">
								<div id="curationmessage-${curationMessage.id}" class="alert alert-warning alert-dismissible curator-curationMessageDiv" role="alert">
									<button type="button" class="close" data-dismiss="alert" onclick="deleteCurationMessageActionCurator(Number('${curationMessage.id}'))">
										<span aria-hidden="true">&times;</span>
										<span class="sr-only"><spring:message code="alert.close" text="Close" /></span>
									</button>
								${fn:escapeXml(curationMessage.message)} 
								<span class="pull-right" style="margin-right: 25px;">
									<button type="button" class="btn btn-success btn-xs" onclick="validateCurationMessageActionCurator(${curationMessage.id});">
										<span aria-hidden="true"><i class="fa fa-check-circle"></i></span>
										<span class="sr-only"><spring:message code="modal.edit.curationMessage.validate" text="Validate" /></span>
									</button>
									<button type="button" class="btn btn-danger btn-xs" onclick="rejectCurationMessageActionCurator(${curationMessage.id});">
										<span aria-hidden="true"><i class="fa fa-times-circle"></i></span>
										<span class="sr-only"><spring:message code="modal.edit.curationMessage.reject" text="Reject" /></span>
									</button>
									<input type="hidden" value="${curationMessage.status}">
								</span>	
								</div>
							</c:forEach>
						</div>
						<script type="text/javascript">
						var cpdMixOriData = [];	
						var updatedCpdMixData = {};
						var singlePick = true;
						
						var lcSFGOriData = [];
// 						var updatedLC_SFGdata = {};
						
						var msPeaksOrdiData = [];
						
						var nmrPeaksOriData = [];
						var nmrPeakPatternsOriData = [];
						
						var newCurationMessagesCurator = new Object();
						deleteCurationMessageActionCurator = function (id) {
							var cm = new Object();
							cm["id"] = id;
							cm["update"]="deleted";
							newCurationMessagesCurator[id] = (cm);
						}
						validateCurationMessageActionCurator = function (id) {
							var cm = new Object();
							cm["id"] = id;
							cm["update"]="validated";
							newCurationMessagesCurator[id] = (cm);
							$("#curationmessage-" +id).removeClass("alert-warning");
							$("#curationmessage-" +id).removeClass("alert-danger");
							$("#curationmessage-" +id).addClass("alert-success");
						}
						rejectCurationMessageActionCurator = function (id) {
							var cm = new Object();
							cm["id"] = id;
							cm["update"]="rejected";
							newCurationMessagesCurator[id] = (cm);
							$("#curationmessage-" +id).removeClass("alert-warning");
							$("#curationmessage-" +id).removeClass("alert-success");
							$("#curationmessage-" +id).addClass("alert-danger");
						}
						checkCurationMessagesStatus = function() {
							var elems = $(".curator-curationMessageDiv");
							$.each(elems,function(k,v) { 
								var idDivCM = $(v).attr("id");
								var statusDivCM = $("#" + idDivCM + " input").val();
								if (statusDivCM == <%=CurationMessage.STATUS_WAITING%> ) {}
								else if (statusDivCM == <%=CurationMessage.STATUS_REJECTED%> ) { 
									$(v).removeClass("alert-warning");
									$(v).addClass("alert-danger");
								} else if (statusDivCM == <%=CurationMessage.STATUS_ACCEPTED%> ) { 
									$(v).removeClass("alert-warning");
									$(v).addClass("alert-success");
								}
							});
						}
						checkCurationMessagesStatus();
						</script>
					</c:if>
					<form action="" onsubmit="return false;">
						<!-- tab bar start ##################################################################################################### -->
<ul class="nav nav-tabs" style="margin-bottom: 15px;">
	<li class="active"><a href="#analytical_sample-modal" data-toggle="tab"><i class="fa fa fa-flask"></i> <spring:message code="page.spectrum.tag.analyticalSample" text="Analytical Sample" /></a></li>
	<!-- MS ONLY -->
	<c:if test="${spectrum_type == 'lc-fullscan' || spectrum_type == 'lc-fragmentation'}">
	<li><a href="#chromatography-modal" data-toggle="tab"><i class="fa fa-area-chart"></i> <spring:message code="page.spectrum.tag.chromatography" text="Chromatography" /></a></li>
	<li><a href="#MS_analyzer-modal" data-toggle="tab"><i class="fa fa-tachometer"></i> <spring:message code="page.spectrum.tag.massAnalyze" text="Mass Analyzer" /></a></li>
	<li><a href="#MS_peaks-modal" data-toggle="tab"><i class="fa fa-bar-chart"></i> <spring:message code="page.spectrum.tag.peakList" text="Peak List" /></a></li>
	</c:if>
	<!-- NMR ONLY -->
	<c:if test="${spectrum_type == 'nmr-1d' || spectrum_type == 'nmr-2d'}">
	<li><a href="#NMR_analyzer-modal" data-toggle="tab"><i class="fa fa-tachometer"></i> <spring:message code="page.spectrum.tag.nmrAnalyzer" text="NMR Analyzer" /></a></li>
	<li><a href="#NMR_peaks-modal" onclick="try{refreshJSmol();}catch(e){}" data-toggle="tab"><i class="fa fa-bar-chart"></i> <spring:message code="page.spectrum.tag.peakListnmr" text="Peak List" /></a></li>
	</c:if>
	<!-- all -->
	<li><a href="#other_metadata-modal" data-toggle="tab"><i class="fa fa-info-circle"></i> <spring:message code="page.spectrum.tag.other" text="Other" /></a></li>
</ul>
						<!-- tab bar end   ##################################################################################################### -->
<div id="div-metadata-modal" class="tab-content">
						<!-- #####################################################################################################        SAMPLE -->
	<div class="tab-pane fade active in" id="analytical_sample-modal">
		<div class="panel panel-default">
<c:choose>
	<c:when test="${spectrum_sample_type == 'single-cpd'}">
			<div class="panel-heading">	
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelSingle" text="Sample type: Single Chemical Compound" /></h3>
			</div>
			<div class="panel-body">
<!-- classic data -->

<ul class="list-group" style="max-width: 600px;">
	<li class="list-group-item">
		Compound Name:&nbsp;
		${fn:escapeXml(spectrum_sample_compound_name)} <small>(can not be changed!)</small>
	</li>
<%-- 	<c:if test="${spectrum_sample_compound_has_concentration}"> --%>
	<li class="list-group-item">
		Concentration: <span id="input_spectrum_sample_compound_concentration">${spectrum_sample_compound_concentration} mmol/L</span>
		<div id="inputEdit_spectrum_sample_compound_concentration" class="form-group input-group" style="max-width: 400px; display: none;">
			<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_sample_compound_concentration}" placeholder="${spectrum_sample_compound_concentration}">
			<span class="input-group-btn">
				<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_sample_compound_concentration', ' mmol/L');"><i class="fa fa-check-square-o"></i></button>
			</span>
		</div>
		<a id="btn-edit_spectrum_sample_compound_concentration" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_sample_compound_concentration');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
	</li>
<%-- 	</c:if> --%>
	<c:if test="${spectrum_type == 'lc-fullscan' || spectrum_type == 'lc-fragmentation'}">
	<li class="list-group-item">
		Solvent: <span id="select_spectrum_sample_compound_liquid_solvent">${select_spectrum_sample_compound_liquid_solvent}</span>
		<div id="selectEdit_select_spectrum_sample_compound_liquid_solvent" class="form-group  select-group" style="max-width: 400px; display: none;">
			<select id="selectElem_select_spectrum_sample_compound_liquid_solvent" class="form-control col-xs-3" style="max-width: 340px;"></select>
			<span class="input-group-btn" style="max-width: 50px;">
				<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('select_spectrum_sample_compound_liquid_solvent');"><i class="fa fa-check-square-o"></i></button>
			</span>
		</div>
		<a id="btn-edit_select_spectrum_sample_compound_liquid_solvent" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('select_spectrum_sample_compound_liquid_solvent');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
	</li>
	</c:if>
</ul>
			</div>
	</c:when>
	<c:when test="${spectrum_sample_type == 'mix-cpd'}">	
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelMix" text="Sample type: Mix of Chemical Compounds" /></h3>
			</div>
			<div class="panel-body">
							<ul style="">
									<li class="list-group-item">
										Solvent: <span id="select_select_spectrum_sample_compound_liquid_solvent_mix">${select_spectrum_sample_compound_liquid_solvent}</span>
										<div id="selectEdit_select_spectrum_sample_compound_liquid_solvent_mix" class="form-group  select-group" style="max-width: 400px; display: none;">
											<select id="selectElem_select_spectrum_sample_compound_liquid_solvent_mix" class="form-control col-xs-3" style="max-width: 340px;">
												<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
												<option value="H2O/ethanol (75/25)">H2O/ethanol (75/25)</option>
											</select>
											<span class="input-group-btn" style="max-width: 50px;">
												<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('select_spectrum_sample_compound_liquid_solvent_mix');"><i class="fa fa-check-square-o"></i></button>
											</span>
										</div>
										<a id="btn-edit_select_spectrum_sample_compound_liquid_solvent_mix" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('select_spectrum_sample_compound_liquid_solvent_mix');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
									</li>
							</ul>
<%-- 							<c:if test="${spectrum_has_main_compound}"> --%>
<%-- 								All peaks are related to one compound: <a href="show-compound-modal/${spectrum_main_compound.getTypeString()}/${spectrum_main_compound.getId()}" data-toggle="modal" data-target="#modalShowCompound">${fn:escapeXml(spectrum_main_compound.getMainName())}</a> --%>
<%-- 								<img class="compoundSVG" src="image/${spectrum_main_compound.getTypeString()}/${spectrum_main_compound.getInChIKey()}" alt="${fn:escapeXml(spectrum_main_compound.getMainName())}"> --%>
<!-- 								<br /> -->
<!-- 								<br /> -->
<%-- 							</c:if> --%>
								<table id="tab_spectrum_sample_mix_tab" class="table table-hover tablesorter tablesearch" style="display: table;">
									<thead>
										<tr>
											<th class="header " style="white-space: nowrap;"></th>
											<th class="header headerSortUp" style="white-space: nowrap;">Compound <i class="fa fa-sort"></i></th>
											<th class="header headerSortUp" style="white-space: nowrap;">Concentration (&micro;g/ml) <i class="fa fa-sort"></i></th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="compound" items="${spectrum_sample_mix_tab}">
										<tr>
											<td>
												<span class="avatar">
													<img class="compoundSVG" src="image/${compound.getTypeString()}/${compound.getInChIKey()}" alt="${fn:escapeXml(compound.getMainName())}">
												</span>
												<script type="text/javascript">
 
													var currentCpt = { 
															"name": "${fn:escapeXml(compound.getMainName())}",
															"type": "${compound.getTypeString()}",
															"concentration": Number("${spectrum_sample_mix_data.getCompoundConcentration(compound.inChIKey)}"),
															"inchikey": "${compound.getInChIKey()}"
													}; 
													cpdMixOriData.push(currentCpt);
													updatedCpdMixData["${fn:escapeXml(compound.getMainName())}"] = currentCpt;
												</script>
											</td>
											<td style="white-space: nowrap;">
												${fn:escapeXml(compound.getMainName())}
											</td>
											<td>${spectrum_sample_mix_data.getCompoundConcentration(compound.inChIKey)}</td>
										</tr>
										</c:forEach>
									</tbody>
								</table>
								<a id="btn-edit_spectrum_sample_mix_tab" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_sample_mix_tab');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								<div id="tabEdit_spectrum_sample_mix_tab" class="handsontable" style="display:none"></div>
								<a id="btn-validate_spectrum_sample_mix_tab" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_sample_mix_tab');" href="#"> <i class="fa fa-check fa-lg"></i></a>
								<br />
			</div>
	</c:when>
	<c:when test="${spectrum_sample_type == 'std-matrix'}">	
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelStd" text="Sample type: Standardized Matrix" /></h3>
			</div>
			<div class="panel-body">
					<br />
					<br />	
					<table id="tab_spectrum_sample_mix_tab" class="table table-hover tablesorter tablesearch" style="display: table;">
									<thead>
										<tr>
											<th class="header " style="white-space: nowrap;"></th>
											<th class="header headerSortUp" style="white-space: nowrap;">Compound <i class="fa fa-sort"></i></th>
											<th class="header headerSortUp" style="white-space: nowrap;">Concentration (&micro;g/ml) <i class="fa fa-sort"></i></th>
										</tr>
									</thead>
									<tbody>
										<c:forEach var="compound" items="${spectrum_sample_mix_tab}">
										<tr>
											<td>
												<span class="avatar">
													<img class="compoundSVG" src="image/${compound.getTypeString()}/${compound.getInChIKey()}" alt="${fn:escapeXml(compound.getMainName())}">
												</span>
												<script type="text/javascript">
													var currentCpt = { 
															"name": "${fn:escapeXml(compound.getMainName())}",
															"type": "${compound.getTypeString()}",
															"concentration": Number("${spectrum_sample_mix_data.getCompoundConcentration(compound.inChIKey)}"),
															"inchikey": "${compound.getInChIKey()}"
													}; 
													cpdMixOriData.push(currentCpt);
													updatedCpdMixData["${fn:escapeXml(compound.getMainName())}"] = currentCpt;
												</script>
											</td>
											<td style="white-space: nowrap;">
												${fn:escapeXml(compound.getMainName())}
											</td>
											<td>${spectrum_sample_mix_data.getCompoundConcentration(compound.inChIKey)}</td>
										</tr>
										</c:forEach>
									</tbody>
								</table>
								<a id="btn-edit_spectrum_sample_mix_tab" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_sample_mix_tab');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								<div id="tabEdit_spectrum_sample_mix_tab" class="handsontable" style="display:none"></div>
								<a id="btn-validate_spectrum_sample_mix_tab" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_sample_mix_tab');" href="#"> <i class="fa fa-check fa-lg"></i></a>
								<br />
			</div>
	</c:when>
	<c:when test="${spectrum_sample_type == 'analytical-matrix'}">	
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelMatrix" text="Sample type: Analytical Matrix" /></h3>
			</div>
			<div class="panel-body">
			...
			</div>
	</c:when>
</c:choose>
<!-- nmr specific data -->
<c:if test="${spectrum_type == 'nmr-1d' || spectrum_type == 'nmr-2d'}">
			<div class="panel-heading">	
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelNMRtubePrep" text="NMR tube preparation" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">
						Solvent: 
						<span id="select_spectrum_nmr_tube_prep_solvent">${spectrum_nmr_tube_prep.getNMRsolventAsString()}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_solvent" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_solvent" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_solvent');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_solvent" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_solvent');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Sample pH or sample apparent pH: 
						<span id="input_spectrum_nmr_tube_prep_poentiaHydrogenii">${spectrum_nmr_tube_prep.getPotentiaHydrogenii()}</span>
						<div id="inputEdit_spectrum_nmr_tube_prep_poentiaHydrogenii" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_nmr_tube_prep.getPotentiaHydrogenii()}" placeholder="${spectrum_nmr_tube_prep.getPotentiaHydrogenii()}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_tube_prep_poentiaHydrogenii');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_poentiaHydrogenii" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_tube_prep_poentiaHydrogenii');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Reference Chemical Shift Indicator: 
						<span id="select_spectrum_nmr_tube_prep_ref_chemical_shift_indocator">${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_ref_chemical_shift_indocator" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_ref_chemical_shift_indocator');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_ref_chemical_shift_indocator" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_ref_chemical_shift_indocator');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li id="specialDiv_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other" class="list-group-item" style="display:none;">
						Reference Chemical Shift Indicator Other: <span id="input_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other">${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())} </span>
						<div id="inputEdit_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())}" placeholder="${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
<%-- 					<li class="list-group-item">Reference Chemical Shif Indicator (other): ${spectrum_sample_type}</li> --%>
					<li class="list-group-item">
						Reference Concentration : 
						<span id="input_spectrum_nmr_tube_prep_ref_concentration">${spectrum_nmr_tube_prep.getReferenceConcentration()} (mmol/L)</span>
						<div id="inputEdit_spectrum_nmr_tube_prep_ref_concentration" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_nmr_tube_prep.getReferenceConcentration()}" placeholder="${spectrum_nmr_tube_prep.getReferenceConcentration()}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_tube_prep_ref_concentration', ' (mmol/L)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_ref_concentration" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_tube_prep_ref_concentration');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Lock Substance: 
						<span id="select_spectrum_nmr_tube_prep_lock_substance">${spectrum_nmr_tube_prep.getNMRlockSubstanceAsString()}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_lock_substance" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_lock_substance" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_lock_substance');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_lock_substance" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_lock_substance');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Lock Substance Concentration: 
						<span id="input_spectrum_nmr_tube_prep_lock_substance_vol_concentration">${spectrum_nmr_tube_prep.getLockSubstanceVolumicConcentration()}</span>
						<div id="inputEdit_spectrum_nmr_tube_prep_lock_substance_vol_concentration" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_nmr_tube_prep.getLockSubstanceVolumicConcentration()}" placeholder="${spectrum_nmr_tube_prep.getLockSubstanceVolumicConcentration()}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_tube_prep_lock_substance_vol_concentration', ' (volumic %)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_lock_substance_vol_concentration" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_tube_prep_lock_substance_vol_concentration');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Buffer Solution: 
						<span id="select_spectrum_nmr_tube_prep_buffer_solution">${spectrum_nmr_tube_prep.getNMRbufferSolutionAsString()}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_buffer_solution" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_buffer_solution" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_buffer_solution');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_buffer_solution" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_buffer_solution');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Buffer Solution Concentration: 
						<span id="input_spectrum_nmr_tube_prep_buffer_solution_concentration">${spectrum_nmr_tube_prep.getBufferSolutionConcentration()}</span>
						<div id="inputEdit_spectrum_nmr_tube_prep_buffer_solution_concentration" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_nmr_tube_prep.getBufferSolutionConcentration()}" placeholder="${spectrum_nmr_tube_prep.getBufferSolutionConcentration()}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_tube_prep_buffer_solution_concentration',' (mmol/L)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_buffer_solution_concentration" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_tube_prep_buffer_solution_concentration');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li> 
				</ul>
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">
						Deuterium isotopic labelling: 
						<span id="select_spectrum_nmr_tube_prep_iso_D_labelling">${spectrum_nmr_tube_prep.isDeuteriumIsotopicLabelling()}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_iso_D_labelling" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_iso_D_labelling" class="form-control col-xs-3" style="max-width: 340px;">
								<option ${spectrum_nmr_tube_prep.isDeuteriumIsotopicLabelling() ? "selected " : " "}>no</option>
							</select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_iso_D_labelling');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_iso_D_labelling" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_iso_D_labelling');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li> 
					<li class="list-group-item">
						Carbon-13 isotopic labelling: 
						<span id="select_spectrum_nmr_tube_prep_iso_C_labelling">${spectrum_nmr_tube_prep.isCarbon13IsotopicLabelling()}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_iso_C_labelling" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_iso_C_labelling" class="form-control col-xs-3" style="max-width: 340px;">
								<option ${spectrum_nmr_tube_prep.isCarbon13IsotopicLabelling() ? "selected " : " "}>yes</option>
								<option ${spectrum_nmr_tube_prep.isCarbon13IsotopicLabelling() ? " " : "selected "}>no</option>
							</select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_iso_C_labelling');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_iso_C_labelling" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_iso_C_labelling');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li> 
					<li class="list-group-item">
						Nitrogen-15 isotopic labelling: 
						<span id="select_spectrum_nmr_tube_prep_iso_N_labelling">${spectrum_nmr_tube_prep.isNitrogenIsotopicLabelling()}</span>
						<div id="selectEdit_spectrum_nmr_tube_prep_iso_N_labelling" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_tube_prep_iso_N_labelling" class="form-control col-xs-3" style="max-width: 340px;">
								<option ${spectrum_nmr_tube_prep.isNitrogenIsotopicLabelling() ? " selected" : " "}>yes</option>
								<option ${spectrum_nmr_tube_prep.isNitrogenIsotopicLabelling() ? " " : " selected"}>no</option>
							</select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_tube_prep_iso_N_labelling');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_tube_prep_iso_N_labelling" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_tube_prep_iso_N_labelling');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li> 
				</ul>
			</div>
</c:if>
		</div>
	</div>
						<!-- #####################################################################################################            LC -->
	<div class="tab-pane " id="chromatography-modal">
		<div class="panel panel-default">
<c:choose>	
	<c:when test="${spectrum_chromatography == 'none'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelNoChromato" text="No Chromatography" /></h3>
			</div>
			<div class="panel-body">
			...
			</div>
	</c:when>
	<c:when test="${spectrum_chromatography == 'lc'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelLCChromato" text="LC Chromatography" /></h3>
			</div>
			<div class="panel-body">
<table style="width:100%">
	<tr> 
		<td width="50%">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Method: <span id="select_spectrum_chromatography_method">${spectrum_chromatography_method}</span>
					<div id="selectEdit_spectrum_chromatography_method" class="form-group  select-group" style="max-width: 400px; display: none;">
						<select id="selectElem_spectrum_chromatography_method" class="form-control col-xs-3" style="max-width: 200px;"></select>
						<span class="input-group-btn" style="max-width: 50px;">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_chromatography_method');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_method" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_chromatography_method');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Column constructor: <span id="select_spectrum_chromatography_col_constructor">${fn:escapeXml(spectrum_chromatography_col_constructor)}</span>
					<div id="selectEdit_spectrum_chromatography_col_constructor" class="form-group  select-group" style="max-width: 400px; display: none;">
						<select id="selectElem_spectrum_chromatography_col_constructor" class="form-control col-xs-3" style="max-width: 200px;"></select>
						<span class="input-group-btn" style="max-width: 50px;">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_chromatography_col_constructor');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_constructor" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_chromatography_col_constructor');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li id="specialDiv_spectrum_chromatography_col_constructor_other" class="list-group-item" style="display:none;">
					Col. Construct. Other: <span id="input_spectrum_chromatography_col_constructor_other">${fn:escapeXml(spectrum_chromatography_col_constructor)} </span>
					<div id="inputEdit_spectrum_chromatography_col_constructor_other" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_chromatography_col_constructor)}" placeholder="${fn:escapeXml(spectrum_chromatography_col_constructor)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_col_constructor_other');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_constructor_other" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_col_constructor_other');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
<!-- 				<li class="list-group-item">Column constructor (other): xxx</li> -->
				<li class="list-group-item">
					Column name: <span id="input_spectrum_chromatography_col_name">${fn:escapeXml(spectrum_chromatography_col_name)}</span>
					<div id="inputEdit_spectrum_chromatography_col_name" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_chromatography_col_name)}" placeholder="${fn:escapeXml(spectrum_chromatography_col_name)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_col_name');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_name" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_col_name');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Column length: <span id="input_spectrum_chromatography_col_length">${fn:escapeXml(spectrum_chromatography_col_length)} (mm)</span>
					<div id="inputEdit_spectrum_chromatography_col_length" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_col_length}" placeholder="${spectrum_chromatography_col_length}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_col_length', ' (mm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_length" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_col_length');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Column diameter: <span id="input_spectrum_chromatography_col_diameter">${fn:escapeXml(spectrum_chromatography_col_diameter)} (mm)</span>
					<div id="inputEdit_spectrum_chromatography_col_diameter" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_col_diameter}" placeholder="${spectrum_chromatography_col_diameter}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_col_diameter', ' (mm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_diameter" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_col_diameter');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Particule size: <span id="input_spectrum_chromatography_col_particule_size">${fn:escapeXml(spectrum_chromatography_col_particule_size)} (&micro;m)</span>
					<div id="inputEdit_spectrum_chromatography_col_particule_size" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_col_particule_size}" placeholder="${spectrum_chromatography_col_particule_size}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_col_particule_size', '  (&micro;m)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_particule_size" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_col_particule_size');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Column temperature: <span id="input_spectrum_chromatography_col_temperature">${fn:escapeXml(spectrum_chromatography_col_temperature)} (&deg;C)</span>
					<div id="inputEdit_spectrum_chromatography_col_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_col_temperature}" placeholder="${spectrum_chromatography_col_temperature}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_col_temperature', ' (&deg;C)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_col_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_col_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					LC mode: <span id="select_spectrum_chromatography_mode_lc">${spectrum_chromatography_mode_lc}</span>
					<div id="selectEdit_spectrum_chromatography_mode_lc" class="form-group  select-group" style="max-width: 400px; display: none;">
						<select id="selectElem_spectrum_chromatography_mode_lc" class="form-control col-xs-3" style="max-width: 200px;">
							<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
							<option value="gradient">Gradient</option>
							<option value="isocratique">Isocratique</option>
						</select>
						<span class="input-group-btn" style="max-width: 50px;">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_chromatography_mode_lc');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_mode_lc" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_chromatography_mode_lc');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Separation flow rate: <span id="input_spectrum_chromatography_separation_flow_rate">${fn:escapeXml(spectrum_chromatography_separation_flow_rate)} (&micro;L/min)</span>
					<div id="inputEdit_spectrum_chromatography_separation_flow_rate" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_separation_flow_rate}" placeholder="${spectrum_chromatography_separation_flow_rate}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_separation_flow_rate', ' (&micro;L/min)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_separation_flow_rate" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_separation_flow_rate');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Separation solvent A: <span id="select_spectrum_chromatography_solventA">${spectrum_chromatography_solventA}</span>
					<div id="selectEdit_spectrum_chromatography_solventA" class="form-group  select-group" style="max-width: 400px; display: none;">
						<select id="selectElem_spectrum_chromatography_solventA" class="form-control col-xs-3" style="max-width: 200px;"></select>
						<span class="input-group-btn" style="max-width: 50px;">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_chromatography_solventA');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_solventA" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_chromatography_solventA');" href="#"> <i class="fa fa-pencil fa-lg"></i></a> 
				</li>
<%-- 				<c:if test="${spectrum_chromatography_solventApH != null }"> --%>
				<li class="list-group-item">
					pH solvent A: <span id="input_spectrum_chromatography_solventApH">${fn:escapeXml(spectrum_chromatography_solventApH)}</span>
					<div id="inputEdit_spectrum_chromatography_solventApH" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_solventApH}" placeholder="${spectrum_chromatography_solventApH}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_solventApH', '');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_solventApH" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_solventApH');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
<%-- 				</c:if> --%>
				<li class="list-group-item">
					Separation solvent B: <span id="select_spectrum_chromatography_solventB">${spectrum_chromatography_solventB}</span>
					<div id="selectEdit_spectrum_chromatography_solventB" class="form-group  select-group" style="max-width: 400px; display: none;">
						<select id="selectElem_spectrum_chromatography_solventB" class="form-control col-xs-3" style="max-width: 200px;"></select>
						<span class="input-group-btn" style="max-width: 50px;">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_chromatography_solventB');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_solventB" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_chromatography_solventB');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
<%-- 				<c:if test="${spectrum_chromatography_solventBpH != null }"> --%>
				<li class="list-group-item">
					pH solvent B: <span id="input_spectrum_chromatography_solventBpH">${fn:escapeXml(spectrum_chromatography_solventBpH)}</span>
					<div id="inputEdit_spectrum_chromatography_solventBpH" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_chromatography_solventBpH}" placeholder="${spectrum_chromatography_solventBpH}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_chromatography_solventBpH', '');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_chromatography_solventBpH" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_chromatography_solventBpH');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
<%-- 				</c:if> --%>
			</ul>
		</td>
		<td width="50%">
			<b>Separation flow gradient</b>
			<br>
			<table id="tab_spectrum_chromatography_sfg_time" class="table" style="max-width: 300px;">
				<thead>
					<tr>
						<td style="width: 100px;">Time (min)</td>
						<td style="width: 100px;">Solv. A (%)</td>
						<td style="width: 100px;">Solv. B (%)</td>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="time" items="${spectrum_chromatography_sfg_time}">
					<tr>
						<td style="width: 100px;">${time}</td>
						<td>${spectrum_chromatography_sfg.get(time)[0]}</td>
						<td>${spectrum_chromatography_sfg.get(time)[1]}
							<script type="text/javascript">
							var currentSFG = { 
									"time": Number("${time}"),
									"a": Number("${spectrum_chromatography_sfg.get(time)[0]}"),
									"b": Number("${spectrum_chromatography_sfg.get(time)[1]}")
							}; 
							lcSFGOriData.push(currentSFG);
							</script>
						</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
			<a id="btn-edit_spectrum_chromatography_sfg_time" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_chromatography_sfg_time');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
			<div id="tabEdit_spectrum_chromatography_sfg_time" class="handsontable" style="display:none"></div>
			<a id="btn-validate_spectrum_chromatography_sfg_time" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_chromatography_sfg_time');" href="#"> <i class="fa fa-check fa-lg"></i></a>
			<br />
		</td>
	</tr>
</table>
			</div>
	</c:when>
	<c:when test="${spectrum_chromatography == 'gc'}">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelGCChromato" text="GC Chromatography" /></h3>
			</div>
			<div class="panel-body">
			...
			</div>
	</c:when>
</c:choose>
		</div>
	</div>
						<!-- #####################################################################################################  ANALYZER MS  -->
	<div class="tab-pane " id="MS_analyzer-modal">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelIonization" text="Ionization" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">
						Ionization method: 
						<span id="select_spectrum_ms_ionization_ionization_method">${fn:escapeXml(spectrum_ms_ionization.getIonizationAsString())}</span>
						<div id="selectEdit_spectrum_ms_ionization_ionization_method" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_ms_ionization_ionization_method" class="form-control col-xs-3" style="max-width: 200px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_ms_ionization_ionization_method');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_ionization_method" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_ms_ionization_ionization_method');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Spray (needle) gaz flow: 
						<span id="input_spectrum_ms_ionization_spray_gaz_flow">${fn:escapeXml(spectrum_ms_ionization.sprayGazFlow)}</span>
						<div id="inputEdit_spectrum_ms_ionization_spray_gaz_flow" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_ionization.sprayGazFlow)}" placeholder="${fn:escapeXml(spectrum_ms_ionization.sprayGazFlow)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_ionization_spray_gaz_flow');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_spray_gaz_flow" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_ionization_spray_gaz_flow');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Vaporizer gaz flow: 
						<span id="input_spectrum_ms_ionization_vaporizer_gaz_flow">${fn:escapeXml(spectrum_ms_ionization.vaporizerGazFlow)}</span>
						<div id="inputEdit_spectrum_ms_ionization_vaporizer_gaz_flow" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_ionization.vaporizerGazFlow)}" placeholder="${fn:escapeXml(spectrum_ms_ionization.vaporizerGazFlow)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_ionization_vaporizer_gaz_flow');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_vaporizer_gaz_flow" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_ionization_vaporizer_gaz_flow');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Vaporizer temperature:  
						<span id="input_spectrum_ms_ionization_vaporizer_tempertature">${fn:escapeXml(spectrum_ms_ionization.vaporizerTemperature)} (&deg;C)</span>
						<div id="inputEdit_spectrum_ms_ionization_vaporizer_tempertature" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_ionization.vaporizerTemperature)}" placeholder="${fn:escapeXml(spectrum_ms_ionization.vaporizerTemperature)} (&deg;C)">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_ionization_vaporizer_tempertature', '(&deg;C)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_vaporizer_tempertature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_ionization_vaporizer_tempertature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Source gaz flow: 
						<span id="input_spectrum_ms_ionization_source_gaz_flow">${fn:escapeXml(spectrum_ms_ionization.sourceGazFlow)}</span>
						<div id="inputEdit_spectrum_ms_ionization_source_gaz_flow" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_ionization.sourceGazFlow)}" placeholder="${fn:escapeXml(spectrum_ms_ionization.sourceGazFlow)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_ionization_source_gaz_flow');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_source_gaz_flow" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_ionization_source_gaz_flow');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>		
					<li class="list-group-item">
						Ion transfer tube temperature /<br> Transfer capillary temperature: 
						<span id="input_spectrum_ms_ionization_ion_transfer_temperature">${spectrum_ms_ionization.ionTransferTemperature} (&deg;C)</span>
						<div id="inputEdit_spectrum_ms_ionization_ion_transfer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_ms_ionization.ionTransferTemperature}" placeholder="${spectrum_ms_ionization.ionTransferTemperature}  (&deg;C)">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_ionization_ion_transfer_temperature', '(&deg;C)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_ion_transfer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_ionization_ion_transfer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						High voltage (ESI) /<br> Corona voltage (APCI):  
						<span id="input_spectrum_ms_ionization_ionization_voltage">${fn:escapeXml(spectrum_ms_ionization_ionization_voltage)} (kV)</span>
						<div id="inputEdit_spectrum_ms_ionization_ionization_voltage" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_ionization.ionizationVoltage)}" placeholder="${fn:escapeXml(spectrum_ms_ionization.ionizationVoltage)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_ionization_ionization_voltage', '(kV)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_ionization_ionization_voltage" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_ionization_ionization_voltage');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>				
				</ul>
			</div>
		</div>
		
		<!-- start MSMS only -->
		<c:if test="${spectrum_type == 'lc-fragmentation'}">
			<div class="panel panel-default">
				<!-- // if ION STORAGE -->
				<c:if test="${not empty spectrum_msms_iontrap}">
					<div class="panel-heading">
						<h3 class="panel-title"><spring:message code="page.spectrum.metadata.msms.labelIonStorage" text="Ion storage" /></h3>
					</div>
					<div class="panel-body">
						<ul class="list-group" style="max-width: 600px;">
							<li class="list-group-item">Gas: ${spectrum_msms_iontrap.getIonGasAsHTML()}</li>
							<li class="list-group-item">Gas pressure: ${spectrum_msms_iontrap.getIonGazPressure()} </li>
							<li class="list-group-item">Gas pressure unit: ${fn:escapeXml(spectrum_msms_iontrap.getIonGazPressureUnitAsString())} </li>
							<li class="list-group-item">Frequency shift: ${fn:escapeXml(spectrum_msms_iontrap.getIonFrequencyShift())} KHz</li>
							<li class="list-group-item">Ion number (AGC or ICC): ${fn:escapeXml(spectrum_msms_iontrap.getIonNumberAGC())} </li>
						</ul>
					</div>
				</c:if>
				<!-- // if ION BEAM -->
				<c:if test="${not empty spectrum_msms_ionbeam }">
					<div class="panel-heading">
						<h3 class="panel-title"><spring:message code="page.spectrum.metadata.msms.labelIonBeam" text="Ion beam" /></h3>
					</div>
					<div class="panel-body">
						<ul class="list-group" style="max-width: 600px;">
							<li class="list-group-item">Gas: ${spectrum_msms_ionbeam.getIonGasAsHTML()}</li>
							<li class="list-group-item">Gas pressure: ${spectrum_msms_ionbeam.getIonGazPressure()} </li>
							<li class="list-group-item">Gas pressure unit: ${fn:escapeXml(spectrum_msms_ionbeam.getIonGazPressureUnitAsString())} </li>
						</ul>
					</div>
				</c:if>
			</div>
		</c:if>
		<!-- developper note: add option to switch from ionbean to iontrap and vice-versa? -->
		<!-- end MSMS only -->
		
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelAnalyzer" text="Analyzer" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<!-- 
					<li class="list-group-item">
						Instrument: 
						<span id="input_spectrum_ms_analyzer_instrument_name">${fn:escapeXml(spectrum_ms_analyzer.instrumentName)}</span>
						<div id="inputEdit_spectrum_ms_analyzer_instrument_name" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_analyzer.instrumentName)}" placeholder="${fn:escapeXml(spectrum_ms_analyzer.instrumentName)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_analyzer_instrument_name');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_analyzer_instrument_name" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_analyzer_instrument_name');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					 -->
					<li class="list-group-item">
						Analyzer type: 
						<span id="input_spectrum_ms_analyzer_ion_analyzer_type">${fn:escapeXml(spectrum_ms_analyzer.getIonAnalyzerType())}</span>
						<div id="inputEdit_spectrum_ms_analyzer_ion_analyzer_type" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_analyzer.getIonAnalyzerType())}" placeholder="${fn:escapeXml(spectrum_ms_analyzer.getIonAnalyzerType())}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_analyzer_ion_analyzer_type');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_analyzer_ion_analyzer_type" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_analyzer_ion_analyzer_type');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						<small>
							<hr />
							Ion analyzer types are "B", "E", "FT" (include other types using FT like FTICR or Orbitrap), "IT", "Q", "TOF" (e.g.: "QTOF", "QQQ", "EB", "ITFT"); 
							for further informations please refer to <a target="_BLANK" href="http://www.massbank.jp/manuals/MassBankRecord_en.pdf">MassBank Record documentation</a>.
						</small>
					</li>
					<li class="list-group-item">
						Model: 
						<span id="input_spectrum_ms_analyzer_instrument_model">${fn:escapeXml(spectrum_ms_analyzer.instrumentModel)}</span>
						<div id="inputEdit_spectrum_ms_analyzer_instrument_model" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_ms_analyzer.instrumentModel)}" placeholder="${fn:escapeXml(spectrum_ms_analyzer.instrumentModel)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_analyzer_instrument_model');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_ms_analyzer_instrument_model" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_analyzer_instrument_model');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
<!-- 					<li class="list-group-item"> -->
<!-- 						Resolution FWHM:  -->
<%-- 						<span id="input_spectrum_ms_analyzer_resolution_fwhm">${spectrum_ms_analyzer.instrumentResolutionFWHMresolution}@${spectrum_ms_analyzer.instrumentResolutionFWHMmass}</span> --%>
<!-- 						<div id="inputEdit_spectrum_ms_analyzer_resolution_fwhm" class="form-group input-group" style="max-width: 400px; display: none;"> -->
<%-- 							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_ms_analyzer.instrumentResolutionFWHMresolution}@${spectrum_ms_analyzer.instrumentResolutionFWHMmass}" placeholder="${spectrum_ms_analyzer.instrumentResolutionFWHMresolution}@${spectrum_ms_analyzer.instrumentResolutionFWHMmass}"> --%>
<!-- 							<span class="input-group-btn"> -->
<!-- 								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_analyzer_resolution_fwhm');"><i class="fa fa-check-square-o"></i></button> -->
<!-- 							</span> -->
<!-- 						</div> -->
<!-- 						<a id="btn-edit_spectrum_ms_analyzer_resolution_fwhm" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_analyzer_resolution_fwhm');" href="#"> <i class="fa fa-pencil fa-lg"></i></a> -->
<!-- 					</li> -->
<%-- 					<li class="list-group-item">Detector: ${fn:escapeXml(spectrum_ms_analyzer.instrumentDetector)}</li> --%>
<%-- 					<li class="list-group-item">Detection protocol: ${fn:escapeXml(spectrum_ms_analyzer.instrumentDetectionProtocol)}</li>				 --%>
				</ul>
			</div>
		</div>
	</div>
						<!-- #####################################################################################################  PEAKLIST MS  -->
	<div class="tab-pane " id="MS_peaks-modal">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelParameters" text="Parameters" /></h3>
			</div>
			<div class="panel-body">
				<table style="width:100%">
					<c:if test="${spectrum_type == 'lc-fragmentation'}">
						<tr> 
							<td width="50%">
								<!-- only if msms -->
								<ul class="list-group" >
									<c:if test="${spectrum_msms_isMSMS}">
										<li class="list-group-item">Parent ion M/Z: ${spectrum_msms_parentIonMZ} </li>
										<li class="list-group-item">
											Parent spectrum: 
											<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum_msms_parentSpectrum.getPeakForestID()}">${ spectrum_msms_parentSpectrum.getPeakForestID()}</a> <small>${fn:escapeXml(spectrum_msms_parentSpectrum.getMassBankName())}</small>
											<!-- developpers note: should we list available spectra and allow edit? --> 
										</li>
									</c:if>
									<c:if test="${spectrum_msms_hasChild}">
										<li class="list-group-item">Children: 
											<c:forEach var="tSpectrum" items="${spectrum_msms_children}">
												<br /> <a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${tSpectrum.getPeakForestID()}">${tSpectrum.getPeakForestID()}</a> <small> ${fn:escapeXml(tSpectrum.getMassBankName())} </small>
											</c:forEach>
										</li>
										<!-- developpers note: do not allow edition of adding / removing a child; do it from the parent (if allowed) -->
									</c:if>
								</ul>
							</td>
							<td width="50%">
							</td>
						</tr>
					</c:if>
					<tr> 
						<td width="50%">
							<ul class="list-group" style="max-width: 300px;">
								<li class="list-group-item">
									Scan type: ${fn:escapeXml(spectrum_ms_scan_type)}
								</li>
								<li class="list-group-item">
									Polarity: ${fn:escapeXml(spectrum_ms_polarity)}
								</li>
								<li class="list-group-item">
									Resolution: ${fn:escapeXml(spectrum_ms_resolution)}
								</li>
								<li class="list-group-item">
									Resolution FWHM: 
									<span id="input_spectrum_ms_analyzer_resolution_fwhm">${spectrum_ms_resolution_FWHM}</span>
									<div id="inputEdit_spectrum_ms_analyzer_resolution_fwhm" class="form-group input-group" style="max-width: 400px; display: none;">
										<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_ms_resolution_FWHM}" placeholder="${spectrum_ms_resolution_FWHM}">
										<span class="input-group-btn">
											<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_analyzer_resolution_fwhm');"><i class="fa fa-check-square-o"></i></button>
										</span>
									</div>
									<a id="btn-edit_spectrum_ms_analyzer_resolution_fwhm" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_analyzer_resolution_fwhm');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								</li>
								
								<!-- // MSMS data -->
								<c:if test="${spectrum_msms_isMSMS}">
									<li class="list-group-item">
										Fragmentation energy: 
										<span id="input_spectrum_ms_analyzer_frag_energy">${frag_energy}</span>
										<div id="inputEdit_spectrum_ms_analyzer_frag_energy" class="form-group input-group" style="max-width: 400px; display: none;">
											<input type="text" class="form-control input-active-enter-key" style="" value="${frag_energy}" placeholder="${frag_energy}">
											<span class="input-group-btn">
												<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_ms_analyzer_frag_energy');"><i class="fa fa-check-square-o"></i></button>
											</span>
										</div>
										<a id="btn-edit_spectrum_ms_analyzer_frag_energy" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_ms_analyzer_frag_energy');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
									</li>
								</c:if> 
								<!-- end MSMS only -->
								
							</ul>
						</td>
						<td width="50%">
							<ul class="list-group" style="max-width: 300px;">
								<li class="list-group-item">
									Mass range: 
									<span id="input_spectrum_ms_range_mass">[${spectrum_ms_range_from} .. ${spectrum_ms_range_to}]</span>
									<div id="inputEdit_spectrum_ms_range_mass" class="form-group input-group" style="width: 195px; display: none;">
										<input type="text" class="form-control input-active-enter-key" style="width:75px;" value="${spectrum_ms_range_from}" placeholder="${spectrum_ms_range_from}">
										<input type="text" class="form-control input-active-enter-key" style="width:75px;" value="${spectrum_ms_range_to}"   placeholder="${spectrum_ms_range_to}" > 
										<span class="input-group-btn">
											<button class="btn btn-success " style="width: 39px;" type="button" onclick="saveSpectrumLiveDataInput2('spectrum_ms_range_mass');"><i class="fa fa-check-square-o"></i></button>
										</span>
									</div>
									<a id="btn-edit_spectrum_ms_range_mass" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput2('spectrum_ms_range_mass');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								</li>
								<li class="list-group-item">
									Retention time <small>(min)</small>: 
									<span id="input_spectrum_ms_rt_min">[${spectrum_rt_min_from} .. ${spectrum_rt_min_to}]</span>
									<div id="inputEdit_spectrum_ms_rt_min" class="form-group input-group" style="width: 195px; display: none;">
										<input type="text" class="form-control input-active-enter-key" style="width:75px;" value="${spectrum_rt_min_from}" placeholder="${spectrum_rt_min_from}">
										<input type="text" class="form-control input-active-enter-key" style="width:75px;" value="${spectrum_rt_min_to}"   placeholder="${spectrum_rt_min_to}" > 
										<span class="input-group-btn">
											<button class="btn btn-success " style="width: 39px;" type="button" onclick="saveSpectrumLiveDataInput2('spectrum_ms_rt_min');"><i class="fa fa-check-square-o"></i></button>
										</span>
									</div>
									<a id="btn-edit_spectrum_ms_rt_min" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput2('spectrum_ms_rt_min');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								</li>
								<li class="list-group-item">
									Retention time <small>(MeOH)</small>: 
									<span id="input_spectrum_ms_rt_meoh">[${spectrum_rt_meoh_from} .. ${spectrum_rt_meoh_to}]</span>
									<div id="inputEdit_spectrum_ms_rt_meoh" class="form-group input-group" style="width: 195px; display: none;">
										<input type="text" class="form-control input-active-enter-key" style="width:75px;" value="${spectrum_rt_meoh_from}" placeholder="${spectrum_rt_meoh_from}">
										<input type="text" class="form-control input-active-enter-key" style="width:75px;" value="${spectrum_rt_meoh_to}"   placeholder="${spectrum_rt_meoh_to}" > 
										<span class="input-group-btn">
											<button class="btn btn-success " style="width: 39px;" type="button" onclick="saveSpectrumLiveDataInput2('spectrum_ms_rt_meoh');"><i class="fa fa-check-square-o"></i></button>
										</span>
									</div>
									<a id="btn-edit_spectrum_ms_rt_meoh" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput2('spectrum_ms_rt_meoh');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								</li>
								<li class="list-group-item">
									Curation: 
									<span id="select_spectrum_ms_curation_lvl">${spectrum_ms_peaks_curation_lvl} </span>
									<div id="selectEdit_spectrum_ms_curation_lvl" class="form-group  select-group" style="max-width: 400px; display: none;">
										<select id="selectElem_spectrum_ms_curation_lvl" class="form-control col-xs-3" style="max-width: 200px;">
											<option value="no_curation" selected="selected">no curation</option>
											<option value="peaks_RI_sup_1percent">Peaks RI > 1%</option>
											<option value="top_50_peaks">Top 50 peaks</option>
											<option value="top_20_peaks">Top 20 peaks</option>
											<option value="top_10_peaks">Top 10 peaks</option>
											<option value="similar_chromatographic_profile">Similar chromatographic profile</option>
										</select>
										<span class="input-group-btn" style="max-width: 50px;">
											<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_ms_curation_lvl');"><i class="fa fa-check-square-o"></i></button>
										</span>
									</div>
									<a id="btn-edit_spectrum_ms_curation_lvl" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_ms_curation_lvl');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
								</li>
							</ul>
						</td>
					</tr>
				</table>
			</div>
		</div>
		
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakListMZ" text="Peak List" /></h3>
			</div>
			<div class="panel-body"> 
				<table id="tab_spectrum_ms_peaks" class="table" style="max-width: 900px;">
					<thead>
						<tr style="white-space: nowrap;">
							<th>m/z</th><th>RI (%)</th><th>theo. mass</th><th>delta (ppm)</th><th>composition</th><th>attribution</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach var="peak" items="${spectrum_ms_peaks}">
						<tr>
							<td>${peak.massToChargeRatio}</td>
							<td>${peak.relativeIntensity}</td>
							<td>${peak.getTheoricalMass()}</td>
							<td>${peak.getDeltaPPM()}</td>
							<td>${fn:escapeXml(peak.composition)}</td>
							<td>
								${fn:escapeXml(peak.getAttributionAsString())}
								<script type="text/javascript">
								var currentMSpeak = { 
										"mz": Number("${peak.massToChargeRatio}"),
										"ri": Number("${peak.relativeIntensity}"),
										"theoricalMass": Number("${peak.getTheoricalMass()}"),
										"deltaMass": Number("${peak.getDeltaPPM()}"),
										"composition": ("${fn:escapeXml(peak.composition)}"),
										"attribution": ("${fn:escapeXml(peak.getAttributionAsString())}")
								}; 
								msPeaksOrdiData.push(currentMSpeak);
								</script>
							</td>
						</tr>
						</c:forEach>
					</tbody>
				</table>
				<a id="btn-edit_spectrum_ms_peaks" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_ms_peaks');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				<div id="tabEdit_spectrum_ms_peaks" class="handsontable" style="display:none"></div>
				<a id="btn-validate_spectrum_ms_peaks" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_ms_peaks');" href="#"> <i class="fa fa-check fa-lg"></i></a>
				<br />
			</div>
		</div>
	</div>
						<!-- #####################################################################################################  ANALYZER NMR -->
	<div class="tab-pane " id="NMR_analyzer-modal">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelInstrument" text="Instrument" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;"> 
					<li class="list-group-item">
						Instrument name: 
						<span id="select_spectrum_nmr_analyzer_name">${fn:escapeXml(spectrum_nmr_analyzer.getNMRinstrumentNameAsString())}</span>
						<div id="selectEdit_spectrum_nmr_analyzer_name" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_analyzer_name" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_name');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_analyzer_name" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_name');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Magnetic field strength: 
						<span id="select_spectrum_nmr_analyzer_magneticFieldStrength">${fn:escapeXml(spectrum_nmr_analyzer.getMagneticFieldStrenghtAsString())} (MHz)</span>
						<div id="selectEdit_spectrum_nmr_analyzer_magneticFieldStrength" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_analyzer_magneticFieldStrength" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_magneticFieldStrength',' (MHz)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_analyzer_magneticFieldStrength" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_magneticFieldStrength');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Software: 
						<span id="select_spectrum_nmr_analyzer_software">${fn:escapeXml(spectrum_nmr_analyzer.getNMRsoftwareVersionAsString())}</span>
						<div id="selectEdit_spectrum_nmr_analyzer_software" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_analyzer_software" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_software');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_analyzer_software" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_software');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						NMR probe: 
						<span id="select_spectrum_nmr_analyzer_probe">${fn:escapeXml(spectrum_nmr_analyzer.getNMRprobeAsString())}</span>
						<div id="selectEdit_spectrum_nmr_analyzer_probe" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_analyzer_probe" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_probe');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_analyzer_probe" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_probe');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
		<c:if test="${! spectrum_nmr_analyzer.isCell()}">
					<li class="list-group-item">
						NMR tube diameter: 
						<span id="select_spectrum_nmr_analyzer_tube">${fn:escapeXml(spectrum_nmr_analyzer.getNMRtubeDiameterAsString())} (mm)</span>
						<div id="selectEdit_spectrum_nmr_analyzer_tube" class="form-group  select-group" style="max-width: 400px; display: none;">
							<select id="selectElem_spectrum_nmr_analyzer_tube" class="form-control col-xs-3" style="max-width: 340px;"></select>
							<span class="input-group-btn" style="max-width: 50px;">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_tube', ' (mm)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_analyzer_tube" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_tube');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
		</c:if>
		<c:if test="${spectrum_nmr_analyzer.isCell()}">
					<li class="list-group-item">
						Flow cell volume: 
						<span id="input_spectrum_nmr_analyzer_flow_cell_vol">${fn:escapeXml(spectrum_nmr_analyzer.flowCellVolume)} (&micro;l)</span>
						<div id="inputEdit_spectrum_nmr_analyzer_flow_cell_vol" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer.flowCellVolume)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer.flowCellVolume)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_flow_cell_vol',' (&micro;l)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_nmr_analyzer_flow_cell_vol" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_flow_cell_vol');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
		</c:if>
				</ul>
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelAcquisition" text="Acquisition" /></h3>
			</div>
			<div class="panel-body">
<table style="width:100%">
	<tr> 
		<td width="50%">
<c:choose>	
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Pulse sequence: 
					<span id="input_spectrum_nmr_analyzer_pulse_seq">${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_seq" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_seq" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Pulse angle: 
					<span id="input_spectrum_nmr_analyzer_pulse_angle">${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_angle" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle',' (&deg;)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_angle" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of points: 
					<span id="input_spectrum_nmr_analyzer_number_of_points">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_points" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_points" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of scans: 
					<span id="input_spectrum_nmr_analyzer_number_of_scans">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_scans" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_scans" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Temperature: 
					<span id="input_spectrum_nmr_analyzer_temperature">${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature',' (K)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Relaxation delay D1: 
					<span id="input_spectrum_nmr_analyzer_relaxationDelayD1">${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_relaxationDelayD1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_relaxationDelayD1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW: 
					<span id="input_spectrum_nmr_analyzer_sw">${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_sw" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_sw',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_sw" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_sw');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>	
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Pulse sequence: 
					<span id="input_spectrum_nmr_analyzer_pulse_seq">${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_seq" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_seq" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Pulse angle: 
					<span id="input_spectrum_nmr_analyzer_pulse_angle">${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_angle" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle',' (&deg;)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_angle" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of points: 
					<span id="input_spectrum_nmr_analyzer_number_of_points">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_points" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_points" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of scans: 
					<span id="input_spectrum_nmr_analyzer_number_of_scans">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_scans" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_scans" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Temperature: 
					<span id="input_spectrum_nmr_analyzer_temperature">${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature',' (K)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Relaxation delay D1: 
					<span id="input_spectrum_nmr_analyzer_relaxationDelayD1">${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_relaxationDelayD1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_relaxationDelayD1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW: 
					<span id="input_spectrum_nmr_analyzer_sw">${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_sw" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_sw',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_sw" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_sw');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Mixing time: 
					<span id="input_spectrum_nmr_analyzer_mixingTime">${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_mixingTime" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_mixingTime',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_mixingTime" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_mixingTime');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Pulse sequence: 
					<span id="input_spectrum_nmr_analyzer_pulse_seq">${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_seq" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_seq" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Pulse angle: 
					<span id="input_spectrum_nmr_analyzer_pulse_angle">${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_angle" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle',' (&deg;)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_angle" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of points: 
					<span id="input_spectrum_nmr_analyzer_number_of_points">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_points" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_points" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of scans: 
					<span id="input_spectrum_nmr_analyzer_number_of_scans">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_scans" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_scans" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Temperature: 
					<span id="input_spectrum_nmr_analyzer_temperature">${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature',' (K)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Relaxation delay D1: 
					<span id="input_spectrum_nmr_analyzer_relaxationDelayD1">${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_relaxationDelayD1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_relaxationDelayD1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW: 
					<span id="input_spectrum_nmr_analyzer_sw">${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_sw" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_sw',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_sw" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_sw');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Spin-echo delay: 
					<span id="input_spectrum_nmr_analyzer_spinEchoDelay">${fn:escapeXml(spectrum_nmr_analyzer_data.spinEchoDelay)} (&micro;s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_spinEchoDelay" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.spinEchoDelay)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.spinEchoDelay)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_spinEchoDelay',' (&micro;s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_spinEchoDelay" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_spinEchoDelay');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of loops: 
					<span id="input_spectrum_nmr_analyzer_numberOfLoops">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfLoops)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_numberOfLoops" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfLoops)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfLoops)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_numberOfLoops','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_numberOfLoops" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_numberOfLoops');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Pulse sequence: 
					<span id="input_spectrum_nmr_analyzer_pulse_seq">${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_seq" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_seq" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Pulse angle: 
					<span id="input_spectrum_nmr_analyzer_pulse_angle">${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_angle" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle',' (&deg;)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_angle" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of points: 
					<span id="input_spectrum_nmr_analyzer_number_of_points">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_points" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfPoints)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_points" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_points');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of scans: 
					<span id="input_spectrum_nmr_analyzer_number_of_scans">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_scans" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScans)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_scans" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Temperature: 
					<span id="input_spectrum_nmr_analyzer_temperature">${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature',' (K)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Relaxation delay D1: 
					<span id="input_spectrum_nmr_analyzer_relaxationDelayD1">${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_relaxationDelayD1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_relaxationDelayD1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW: 
					<span id="input_spectrum_nmr_analyzer_sw">${fn:escapeXml(spectrum_nmr_analyzer_data.sw)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_sw" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sw)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_sw',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_sw" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_sw');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Decoupling type: 
					<span id="input_spectrum_nmr_analyzer_decouplingType">${fn:escapeXml(spectrum_nmr_analyzer_data.decouplingType)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_decouplingType" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.decouplingType)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.decouplingType)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_decouplingType','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_decouplingType" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_decouplingType');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Pulse sequence: 
					<span id="input_spectrum_nmr_analyzer_pulse_seq">${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_seq" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_seq" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Size of FID (F1): 
					<span id="input_spectrum_nmr_analyzer_size_of_fid_f1">${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_size_of_fid_f1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f1','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_size_of_fid_f1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Size if FID (F2): 
					<span id="input_spectrum_nmr_analyzer_size_of_fid_f2">${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_size_of_fid_f2" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f2','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_size_of_fid_f2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of Scans (F2): 
					<span id="input_spectrum_nmr_analyzer_number_of_scans">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_scans" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_scans" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>	
				</li>
				<li class="list-group-item">
					Acquisition Mode for 2D (F1): 
					<span id="input_spectrum_nmr_analyzer_acquisition_mode_for_2d">${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_acquisition_mode_for_2d" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_acquisition_mode_for_2d','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_acquisition_mode_for_2d" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_acquisition_mode_for_2d');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Temperature: 
					<span id="input_spectrum_nmr_analyzer_temperature">${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature',' (K)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Relaxation delay D1: 
					<span id="input_spectrum_nmr_analyzer_relaxationDelayD1">${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_relaxationDelayD1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_relaxationDelayD1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>	
				</li>
				<li class="list-group-item">
					SW (F1): 
					<span id="input_spectrum_nmr_analyzer_swF1">${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_swF1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_swF1',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_swF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_swF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW (F2): 
					<span id="input_spectrum_nmr_analyzer_swF2">${fn:escapeXml(spectrum_nmr_analyzer_data.swF2)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_swF2" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.swF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_swF2',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_swF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_swF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
			</ul>
	</c:when>
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
			<ul class="list-group" style="max-width: 600px;">
				<li class="list-group-item">
					Pulse sequence: 
					<span id="input_spectrum_nmr_analyzer_pulse_seq">${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_seq" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getPulseSequence())}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_seq" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_seq');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Pulse angle: 
					<span id="input_spectrum_nmr_analyzer_pulse_angle">${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)} (&deg;)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_pulse_angle" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.pulseAngle)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle',' (&deg;)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_pulse_angle" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_pulse_angle');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Size of FID (F1): 
					<span id="input_spectrum_nmr_analyzer_size_of_fid_f1">${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_size_of_fid_f1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f1','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_size_of_fid_f1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Size if FID (F2): 
					<span id="input_spectrum_nmr_analyzer_size_of_fid_f2">${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_size_of_fid_f2" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.sizeOfFIDF2)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f2','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_size_of_fid_f2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_size_of_fid_f2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Number of Scans (F2): 
					<span id="input_spectrum_nmr_analyzer_number_of_scans">${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_number_of_scans" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.numberOfScansF2)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_number_of_scans" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_number_of_scans');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>	
				</li>
				<li class="list-group-item">
					Acquisition Mode for 2D (F1): 
					<span id="input_spectrum_nmr_analyzer_acquisition_mode_for_2d">${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}</span>
					<div id="inputEdit_spectrum_nmr_analyzer_acquisition_mode_for_2d" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.acquisitionModeFor2DF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_acquisition_mode_for_2d','');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_acquisition_mode_for_2d" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_acquisition_mode_for_2d');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Temperature: 
					<span id="input_spectrum_nmr_analyzer_temperature">${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)} (K)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_temperature" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.temperature)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature',' (K)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_temperature" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_temperature');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					Relaxation delay D1: 
					<span id="input_spectrum_nmr_analyzer_relaxationDelayD1">${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_relaxationDelayD1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.relaxationDelayD1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_relaxationDelayD1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_relaxationDelayD1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">Mixing time <small>(only if TOCSY-2D or NOESY-2D (D8) )</small>: 
					<span id="input_spectrum_nmr_analyzer_mixingTime">${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)} (s)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_mixingTime" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.mixingTime)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_mixingTime',' (s)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_mixingTime" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_mixingTime');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW (1H, if TOCSY, NOESY, HMBC, HSQC): 
					<span id="input_spectrum_nmr_analyzer_swF1">${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_swF1" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_swF1',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_swF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_swF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					SW (13C, if HMBC, HSQC): 
					<span id="input_spectrum_nmr_analyzer_swF2">${fn:escapeXml(spectrum_nmr_analyzer_data.swF2)} (ppm)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_swF2" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.swF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.swF1)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_swF2',' (ppm)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_swF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_swF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					JXH <small>(if HMBC, HSQC)</small>: 
					<span id="input_spectrum_nmr_analyzer_jxh">${fn:escapeXml(spectrum_nmr_analyzer_data.jxh)} (Hz)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_jxh" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.jxh)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.jxh)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_jxh',' (Hz)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_jxh" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_jxh');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					NUS: 
					<span id="select_spectrum_nmr_analyzer_nus">${spectrum_nmr_analyzer_data.getNusAsTrueFalse()}</span>
					<div id="selectEdit_spectrum_nmr_analyzer_nus" class="form-group  select-group" style="max-width: 150px; display: none;">
						<select id="selectElem_spectrum_nmr_analyzer_nus" class="form-control col-xs-3" style="max-width: 100px;"></select>
						<span class="input-group-btn" style="max-width: 50px;">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_nus', '');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_nus" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_nus');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					NusAmount: 
					<span id="input_spectrum_nmr_analyzer_nus_amount">${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)} (%)</span>
					<div id="inputEdit_spectrum_nmr_analyzer_nus_amount" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.nusAmount)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_nus_amount',' (%)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_nus_amount" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_nus_amount');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
				<li class="list-group-item">
					NusPoints: 
					<span id="input_spectrum_nmr_analyzer_nus_points">${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)} </span>
					<div id="inputEdit_spectrum_nmr_analyzer_nus_points" class="form-group input-group" style="max-width: 400px; display: none;">
						<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.nusPoints)}">
						<span class="input-group-btn">
							<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_nus_points',' (%)');"><i class="fa fa-check-square-o"></i></button>
						</span>
					</div>
					<a id="btn-edit_spectrum_nmr_analyzer_nus_points" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_nus_points');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
				</li>
			</ul>
	</c:when>
</c:choose>
		</td>
		<c:choose>
			<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D' || spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D' || spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D' }">
				<td width="50%">
					<ul class="list-group" style="max-width: 600px;">
						<li class="list-group-item">
							Fourier transform: 
							<span id="select_spectrum_nmr_analyzer_data_fourier_transform">${spectrum_nmr_analyzer_data.getFourierTransform()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_fourier_transform" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_fourier_transform" class="form-control col-xs-3" style="max-width: 100px;"></select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_fourier_transform', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_fourier_transform" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_fourier_transform');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SI: 
							<span id="select_spectrum_nmr_analyzer_data_si">${spectrum_nmr_analyzer_data.getSiAsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_si" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_si" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="16000">16k</option>
									<option value="32000">32k</option>
									<option value="64000">64k</option>
									<option value="128000">128k</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_si', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_si" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_si');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Line broadening: 
							<span id="input_spectrum_nmr_analyzer_line_broadening">${fn:escapeXml(spectrum_nmr_analyzer_data.getLineBroadening())} Hz</span>
							<div id="inputEdit_spectrum_nmr_analyzer_line_broadening" class="form-group input-group" style="max-width: 150px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.getLineBroadening())}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.getLineBroadening())}">
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_line_broadening', ' Hz');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_line_broadening" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_line_broadening');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
					</ul>
				</td>
			</c:when>
			<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
				<td width="50%">
					<ul class="list-group" style="max-width: 600px;">
						<li class="list-group-item">
							Fourier transform: 
							<span id="select_spectrum_nmr_analyzer_data_fourier_transform">${spectrum_nmr_analyzer_data.getFourierTransform()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_fourier_transform" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_fourier_transform" class="form-control col-xs-3" style="max-width: 100px;"></select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_fourier_transform', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_fourier_transform" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_fourier_transform');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SI (F1): 
							<span id="select_spectrum_nmr_analyzer_data_siF1">${spectrum_nmr_analyzer_data.getSiF1AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_siF1" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_siF1" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="64">64</option>
									<option value="128">128</option>
									<option value="256">256</option>
									<option value="512">512</option>
									<option value="1024">1024</option>
									<option value="2048">2048</option>
									<option value="4096">4096</option>
									<option value="8192">8192</option>
									<option value="16000">16k</option>
									<option value="32000">32k</option>
									<option value="64000">64k</option>
									<option value="128000">128k</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF1', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_siF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SI (F2): 
							<span id="select_spectrum_nmr_analyzer_data_siF2">${spectrum_nmr_analyzer_data.getSiF2AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_siF2" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_siF2" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="64">64</option>
									<option value="128">128</option>
									<option value="256">256</option>
									<option value="512">512</option>
									<option value="1024">1024</option>
									<option value="2048">2048</option>
									<option value="4096">4096</option>
									<option value="8192">8192</option>
									<option value="16000">16k</option>
									<option value="32000">32k</option>
									<option value="64000">64k</option>
									<option value="128000">128k</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF2', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_siF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Window function (F1): 
							<span id="select_spectrum_nmr_analyzer_data_windowFunctionF1">${spectrum_nmr_analyzer_data.getWindowFunctionF1AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_windowFunctionF1" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_windowFunctionF1" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="NO">NO</option>
									<option value="EM">EM</option>
									<option value="QSINE">QSINE</option>
									<option value="SINE">SINE</option>
									<option value="GM">GM</option>
									<option value="OTHER">OTHER</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF1', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_windowFunctionF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Window function (F2): 
							<span id="select_spectrum_nmr_analyzer_data_windowFunctionF2">${spectrum_nmr_analyzer_data.getWindowFunctionF2AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_windowFunctionF2" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_windowFunctionF2" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="NO">NO</option>
									<option value="EM">EM</option>
									<option value="QSINE">QSINE</option>
									<option value="SINE">SINE</option>
									<option value="GM">GM</option>
									<option value="OTHER">OTHER</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF2', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_windowFunctionF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							LB (F1): 
							<span id="input_spectrum_nmr_analyzer_lbF1">${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)} Hz</span>
							<div id="inputEdit_spectrum_nmr_analyzer_lbF1" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF1',' Hz');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_lbF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							LB (F2): 
							<span id="input_spectrum_nmr_analyzer_lbF2">${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)} Hz</span>
							<div id="inputEdit_spectrum_nmr_analyzer_lbF2" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF2',' Hz');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_lbF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SSB (F1): 
							<span id="input_spectrum_nmr_analyzer_ssbF1">${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_ssbF1" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF1','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_ssbF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SSB (F2): 
							<span id="input_spectrum_nmr_analyzer_ssbF2">${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_ssbF2" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF2','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_ssbF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							GB (F1): 
							<span id="input_spectrum_nmr_analyzer_gbF1">${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_gbF1" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF1','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_gbF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							GB (F2): 
							<span id="input_spectrum_nmr_analyzer_gbF2">${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_gbF2" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF2','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_gbF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Peak Peaking: 
							<span id="select_spectrum_nmr_analyzer_data_peak_peaking">${spectrum_nmr_analyzer_data.getPeakPickingAsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_peak_peaking" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_peak_peaking" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="manual">manual</option>
									<option value="automatic">automatic</option>
									<option value="automatic">none</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_peak_peaking', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_peak_peaking" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_peak_peaking');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							NUS processing parameter: 
							<span id="input_spectrum_nmr_analyzer_nusProcessingParameter">${fn:escapeXml(spectrum_nmr_analyzer_data.nusProcessingParameter)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_nusProcessingParameter" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.nusProcessingParameter)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.nusProcessingParameter)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_nusProcessingParameter','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_nusProcessingParameter" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_nusProcessingParameter');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
					</ul>
				</td>
			</c:when>
			<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D'}">
				<td width="50%">
					<ul class="list-group" style="max-width: 600px;">
						<li class="list-group-item">
							Fourier transform: 
							<span id="select_spectrum_nmr_analyzer_data_fourier_transform">${spectrum_nmr_analyzer_data.getFourierTransform()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_fourier_transform" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_fourier_transform" class="form-control col-xs-3" style="max-width: 100px;"></select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_fourier_transform', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_fourier_transform" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_fourier_transform');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Tilt: 
							<span id="select_spectrum_nmr_analyzer_data_tilt">${spectrum_nmr_analyzer_data.getTiltAsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_tilt" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_tilt" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="yes">yes</option>
									<option value="no">no</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_tilt', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_tilt" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_tilt');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SI (F1): 
							<span id="select_spectrum_nmr_analyzer_data_siF1">${spectrum_nmr_analyzer_data.getSiF1AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_siF1" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_siF1" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="64">64</option>
									<option value="128">128</option>
									<option value="256">256</option>
									<option value="512">512</option>
									<option value="1024">1024</option>
									<option value="2048">2048</option>
									<option value="4096">4096</option>
									<option value="8192">8192</option>
									<option value="16000">16k</option>
									<option value="32000">32k</option>
									<option value="64000">64k</option>
									<option value="128000">128k</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF1', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_siF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SI (F2): 
							<span id="select_spectrum_nmr_analyzer_data_siF2">${spectrum_nmr_analyzer_data.getSiF2AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_siF2" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_siF2" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="64">64</option>
									<option value="128">128</option>
									<option value="256">256</option>
									<option value="512">512</option>
									<option value="1024">1024</option>
									<option value="2048">2048</option>
									<option value="4096">4096</option>
									<option value="8192">8192</option>
									<option value="16000">16k</option>
									<option value="32000">32k</option>
									<option value="64000">64k</option>
									<option value="128000">128k</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF2', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_siF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_siF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Window function (F1): 
							<span id="select_spectrum_nmr_analyzer_data_windowFunctionF1">${spectrum_nmr_analyzer_data.getWindowFunctionF1AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_windowFunctionF1" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_windowFunctionF1" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="NO">NO</option>
									<option value="EM">EM</option>
									<option value="QSINE">QSINE</option>
									<option value="SINE">SINE</option>
									<option value="GM">GM</option>
									<option value="OTHER">OTHER</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF1', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_windowFunctionF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Window function (F2): 
							<span id="select_spectrum_nmr_analyzer_data_windowFunctionF2">${spectrum_nmr_analyzer_data.getWindowFunctionF2AsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_windowFunctionF2" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_windowFunctionF2" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="NO">NO</option>
									<option value="EM">EM</option>
									<option value="QSINE">QSINE</option>
									<option value="SINE">SINE</option>
									<option value="GM">GM</option>
									<option value="OTHER">OTHER</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF2', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_windowFunctionF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_windowFunctionF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							LB (F1): 
							<span id="input_spectrum_nmr_analyzer_lbF1">${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)} Hz</span>
							<div id="inputEdit_spectrum_nmr_analyzer_lbF1" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF1)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF1',' Hz');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_lbF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							LB (F2): 
							<span id="input_spectrum_nmr_analyzer_lbF2">${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)} Hz</span>
							<div id="inputEdit_spectrum_nmr_analyzer_lbF2" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.lbF2)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF2',' Hz');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_lbF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_lbF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SSB (F1): 
							<span id="input_spectrum_nmr_analyzer_ssbF1">${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_ssbF1" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF1)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF1','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_ssbF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							SSB (F2): 
							<span id="input_spectrum_nmr_analyzer_ssbF2">${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_ssbF2" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.ssbF2)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF2','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_ssbF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_ssbF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							GB (F1): 
							<span id="input_spectrum_nmr_analyzer_gbF1">${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_gbF1" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF1)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF1','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_gbF1" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF1');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							GB (F2): 
							<span id="input_spectrum_nmr_analyzer_gbF2">${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}</span>
							<div id="inputEdit_spectrum_nmr_analyzer_gbF2" class="form-group input-group" style="max-width: 400px; display: none;">
								<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}" placeholder="${fn:escapeXml(spectrum_nmr_analyzer_data.gbF2)}">
								<span class="input-group-btn">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF2','');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_gbF2" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_nmr_analyzer_gbF2');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Peak Peaking: 
							<span id="select_spectrum_nmr_analyzer_data_peak_peaking">${spectrum_nmr_analyzer_data.getPeakPickingAsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_peak_peaking" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_peak_peaking" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="manual">manual</option>
									<option value="automatic">automatic</option>
									<option value="automatic">none</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_peak_peaking', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_peak_peaking" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_peak_peaking');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
						<li class="list-group-item">
							Symmetrize: ${fn:escapeXml(spectrum_nmr_analyzer_data.getSymmetrizeAsString())}
							<span id="select_spectrum_nmr_analyzer_data_symmetrize">${spectrum_nmr_analyzer_data.getSymmetrizeAsString()}</span>
							<div id="selectEdit_spectrum_nmr_analyzer_data_symmetrize" class="form-group  select-group" style="max-width: 150px; display: none;">
								<select id="selectElem_spectrum_nmr_analyzer_data_symmetrize" class="form-control col-xs-3" style="max-width: 100px;">
									<option value="" selected="selected" disabled="disabled">choose in list...</option>
									<option value="yes">yes</option>
									<option value="no">no</option>
								</select>
								<span class="input-group-btn" style="max-width: 50px;">
									<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_symmetrize', '');"><i class="fa fa-check-square-o"></i></button>
								</span>
							</div>
							<a id="btn-edit_spectrum_nmr_analyzer_data_symmetrize" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataSelect('spectrum_nmr_analyzer_data_symmetrize');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						</li>
					</ul>
				</td>
			</c:when>
		</c:choose>
	</tr>
</table>
			</div>
		</div>
	</div>
						<!-- #####################################################################################################  PEAKLIST NMR -->
	<div class="tab-pane " id="NMR_peaks-modal">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakListnmr" text="Peak List" /></h3>
			</div>
			<div class="panel-body">
			<c:choose>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D' || spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D'}">
							<table id="tab_spectrum_nmr_peaks" class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>peak index</th><th>&nu; (F1) [ppm]</th><th>intensity [rel]</th><th>half width [ppm]</th><th>half width [Hz]</th><th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<%
										int i = 1;
									%>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i%></td>
										<td>${peak.chemicalShift}</td>
										<td>${peak.relativeIntensity}</td>
										<td>${peak.halfWidth}</td>
										<td>${peak.halfWidthHz}</td>
										<td>
											${fn:escapeXml(peak.annotation)}
											<script type="text/javascript">
											var currentNMRpeak = { 
													"index": Number("<%=i++%>"),
													"chemicalShift": Number("${peak.chemicalShift}"),
													"relativeIntensity": Number("${peak.relativeIntensity}"),
													"halfWidth": Number("${peak.halfWidth}"),
													"halfWidthHz": Number("${peak.halfWidthHz}"),
													"annotation": ("${fn:escapeXml(peak.annotation)}")
											}; 
											nmrPeaksOriData.push(currentNMRpeak);
											</script>
										</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
							<a id="btn-edit_spectrum_nmr_peaks" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_nmr_peaks');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
							<div id="tabEdit_spectrum_nmr_peaks" class="handsontable" style="display:none"></div>
							<a id="btn-validate_spectrum_nmr_peaks" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_nmr_peaks');" href="#"> <i class="fa fa-check fa-lg"></i></a>
							<br />
				</c:when>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D'}">
							<table id="tab_spectrum_nmr_peaks" class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<th>peak index</th><th>&nu; (F1) [ppm]</th><th>intensity [rel]</th><th>half width [ppm]</th><th>half width [Hz]</th><th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<%
										int i = 1;
									%>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i%></td>
										<td>${peak.chemicalShift}</td>
										<td>${peak.relativeIntensity}</td>
										<td>${peak.halfWidth}</td>
										<td>${peak.halfWidthHz}</td>
										<td>
											${fn:escapeXml(peak.annotation)}
											<script type="text/javascript">
											var currentNMRpeak = { 
													"index": Number("<%=i++%>"),
													"chemicalShift": Number("${peak.chemicalShift}"),
													"relativeIntensity": Number("${peak.relativeIntensity}"),
													"halfWidth": Number("${peak.halfWidth}"),
													"halfWidthHz": Number("${peak.halfWidthHz}"),
													"annotation": ("${fn:escapeXml(peak.annotation)}")
											}; 
											nmrPeaksOriData.push(currentNMRpeak);
											</script>
										</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
							<a id="btn-edit_spectrum_nmr_peaks" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_nmr_peaks');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
							<div id="tabEdit_spectrum_nmr_peaks" class="handsontable" style="display:none"></div>
							<a id="btn-validate_spectrum_nmr_peaks" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_nmr_peaks');" href="#"> <i class="fa fa-check fa-lg"></i></a>
							<br />
				</c:when>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'JRES-2D'}">
							<table id="tab_spectrum_nmr_jres_peaks" class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<!-- peak index	&nu; (F2) [ppm]	&nu; (F1) [ppm]	intensity [rel]	multiplicity	J (coupling constant)	annotation   -->
										<th>peak index</th>
										<th>&nu; (F2) [ppm]</th>
										<th>&nu; (F1) [ppm]</th>
										<th class="tabStrippedBg">intensity [rel]</th>
										<th>multiplicity</th>
										<th>J</th>
										<th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<%
										int i = 1;
									%>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i%></td>
										<td>${peak.chemicalShiftF2}</td>
										<td>${peak.chemicalShiftF1}</td>
										<td class="tabStrippedBg">${peak.intensity}</td>
										<td>${peak.getMultiplicityTypeAsString()}</td>
										<td>${peak.getCouplingConstantAsString()}</td> 
										<td>
											${fn:escapeXml(peak.annotation)}
											<script type="text/javascript">
											var currentNMRpeak = { 
													"index": Number("<%=i++%>"),
													"chemicalShiftF2": Number("${peak.chemicalShiftF2}"),
													"chemicalShiftF1": Number("${peak.chemicalShiftF1}"),
													"intensity": Number("${peak.intensity}"),
													"multiplicity": ("${fn:escapeXml(peak.getMultiplicityTypeAsString())}"),
													"j": ("${fn:escapeXml(peak.getCouplingConstantAsString())}"),
													"annotation": ("${fn:escapeXml(peak.annotation)}")
											}; 
											nmrPeaksOriData.push(currentNMRpeak);
											</script>
										</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
							<a id="btn-edit_spectrum_nmr_jres_peaks" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_nmr_jres_peaks');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
							<div id="tabEdit_spectrum_nmr_jres_peaks" class="handsontable" style="display:none"></div>
							<a id="btn-validate_spectrum_nmr_jres_peaks" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_nmr_jres_peaks');" href="#"> <i class="fa fa-check fa-lg"></i></a>
							<br />
				</c:when>
				<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
							<table id="tab_spectrum_nmr_2dpeaks" class="table" style="max-width: 700px;">
								<thead>
									<tr>
										<!-- peak index	&nu; (F2) [ppm]	&nu; (F1) [ppm]	intensity [rel]	annotation   -->
										<th>peak index</th>
										<th>&nu; (F2) [ppm]</th>
										<th>&nu; (F1) [ppm]</th>
										<th>intensity [abs]</th>
										<th>annotation</th>
									</tr>
								</thead>
								<tbody>
									<%
										int i = 1;
									%>
									<c:forEach var="peak" items="${spectrum_nmr_analyzer_data.peaks}">
									<tr>
										<td><%=i%></td>
										<td>${peak.chemicalShiftF2}</td>
										<td>${peak.chemicalShiftF1}</td>
										<td>${peak.intensity}</td>
										<td>
											${fn:escapeXml(peak.annotation)}
											<script type="text/javascript">
											var currentNMRpeak = { 
													"index": Number("<%=i++%>"),
													"chemicalShiftF2": Number("${peak.chemicalShiftF2}"),
													"chemicalShiftF1": Number("${peak.chemicalShiftF1}"),
													"intensity": Number("${peak.intensity}"),
													"annotation": ("${fn:escapeXml(peak.annotation)}")
											}; 
											nmrPeaksOriData.push(currentNMRpeak);
											</script>
										</td>
									</tr>
									</c:forEach>
								</tbody>
							</table>
							<a id="btn-edit_spectrum_nmr_2dpeaks" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_nmr_2dpeaks');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
							<div id="tabEdit_spectrum_nmr_2dpeaks" class="handsontable" style="display:none"></div>
							<a id="btn-validate_spectrum_nmr_2dpeaks" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_nmr_2dpeaks');" href="#"> <i class="fa fa-check fa-lg"></i></a>
							<br />
				</c:when>
			</c:choose>
			</div>
		</div>
		
		<c:choose>
			<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'Proton-1D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-1D' || spectrum_nmr_analyzer_data_acquisition == 'CPMG-1D' || spectrum_nmr_analyzer_data_acquisition == 'Carbon13-1D' }">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelPeakPatternListnmr" text="Peak Pattern List" /></h3>
					</div>
					<div class="panel-body">
						<table id="tab_spectrum_nmr_peak_patterns" class="table" style="max-width: 700px;">
							<thead>
								<tr>
									<th>&nu; (F1) [ppm]</th><th>H's|C's</th><th>type</th><th>J(Hz)</th><th>range (ppm)</th><th>atoms</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="peakpattern" items="${spectrum_nmr_peakpatterns}">
								<tr>
									<td>${peakpattern.chemicalShift}</td>
									<td>${peakpattern.atomsAttributions}</td>
									<td>${peakpattern.getPatternTypeAsString()}</td>
									<td>${peakpattern.getCouplageConstantAsString()}</td>
									<td>[${peakpattern.rangeFrom} .. ${peakpattern.rangeTo}]</td>
									<td>
										${fn:escapeXml(peakpattern.atom)}
										<script type="text/javascript">
										var currentNMRpeakPattern = { 
												"chemicalShift": Number("${peakpattern.chemicalShift}"),
												"hORc": ("${peakpattern.atomsAttributions}"),
												"pattern": ("${peakpattern.getPatternTypeAsString()}"),
												"couplageConstant": ("${peakpattern.getCouplageConstantAsString()}"),
												"rangeFrom": Number("${peakpattern.rangeFrom}"),
												"rangeTo": Number("${peakpattern.rangeTo}"),
												// "composition": ("${fn:escapeXml(peak.composition)}"),
												"atom": ("${fn:escapeXml(peakpattern.atom)}")
										}; 
										nmrPeakPatternsOriData.push(currentNMRpeakPattern);
										</script>
									</td>
								</tr>
								</c:forEach>
							</tbody>
						</table>
						<a id="btn-edit_spectrum_nmr_peak_patterns" class="btn btn-info btn-xs pull-right " onclick="editSpectrumLiveDataTab('spectrum_nmr_peak_patterns');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
						<div id="tabEdit_spectrum_nmr_peak_patterns" class="handsontable" style="display:none"></div>
						<a id="btn-validate_spectrum_nmr_peak_patterns" class="btn btn-success btn-xs pull-right " style="display:none;" onclick="updateSpectrumLiveDataTab('spectrum_nmr_peak_patterns');" href="#"> <i class="fa fa-check fa-lg"></i></a>
						<br />
					</div>
				</div>
			</c:when>
		</c:choose>
	</div>
	<!-- #####################################################################################################         OTHER -->
	<div class="tab-pane " id="other_metadata-modal">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelAboutAuthors" text="About authors" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">
						Authors: 
						<span id="input_spectrum_othermetadata_authors">${fn:escapeXml(spectrum_othermetadata.authors)}</span>
						<div id="inputEdit_spectrum_othermetadata_authors" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_othermetadata.authors)}" placeholder="${fn:escapeXml(spectrum_othermetadata.authors)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_othermetadata_authors');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_othermetadata_authors" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_othermetadata_authors');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Validator: 
						<span id="input_spectrum_othermetadata_validator">${fn:escapeXml(spectrum_othermetadata.validator)}</span>
						<div id="inputEdit_spectrum_othermetadata_validator" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_othermetadata.validator)}" placeholder="${fn:escapeXml(spectrum_othermetadata.validator)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_othermetadata_validator');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_othermetadata_validator" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_othermetadata_validator');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Acquisition date: 
						<span id="input_spectrum_othermetadata_aquisition_date"><fmt:formatDate value="${spectrum_othermetadata.acquisitionDate}" pattern="yyyy-MM-dd" /></span>
						<div id="inputEdit_spectrum_othermetadata_aquisition_date" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key datepicker" data-date-format="yyyy-mm-dd" style="" value="<fmt:formatDate value="${spectrum_othermetadata.acquisitionDate}" pattern="yyyy-MM-dd" />" placeholder="<fmt:formatDate value="${spectrum_othermetadata.acquisitionDate}" pattern="yyyy-MM-dd" />">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_othermetadata_aquisition_date');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_othermetadata_aquisition_date" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_othermetadata_aquisition_date');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						Data ownership: 
						<span id="input_spectrum_othermetadata_ownership">${fn:escapeXml(spectrum_othermetadata.ownership)}</span>
						<div id="inputEdit_spectrum_othermetadata_ownership" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_othermetadata.ownership)}" placeholder="${fn:escapeXml(spectrum_othermetadata.ownership)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_othermetadata_ownership');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_othermetadata_ownership" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_othermetadata_ownership');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
				</ul>
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title"><spring:message code="page.spectrum.metadata.sample.labelRawFile" text="Raw File" /></h3>
			</div>
			<div class="panel-body">
				<ul class="list-group" style="max-width: 600px;">
					<li class="list-group-item">
						File name: 
						<span id="input_spectrum_othermetadata_raw_file_name">${fn:escapeXml(spectrum_othermetadata.rawFileName)}</span>
						<div id="inputEdit_spectrum_othermetadata_raw_file_name" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${fn:escapeXml(spectrum_othermetadata.rawFileName)}" placeholder="${fn:escapeXml(spectrum_othermetadata.rawFileName)}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_othermetadata_raw_file_name');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_othermetadata_raw_file_name" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_othermetadata_raw_file_name');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
					<li class="list-group-item">
						File size: 
						<span id="input_spectrum_othermetadata_raw_file_size">${spectrum_othermetadata.rawFileSize} (Ko)</span>
						<div id="inputEdit_spectrum_othermetadata_raw_file_size" class="form-group input-group" style="max-width: 400px; display: none;">
							<input type="text" class="form-control input-active-enter-key" style="" value="${spectrum_othermetadata.rawFileSize}" placeholder="${spectrum_othermetadata.rawFileSize}">
							<span class="input-group-btn">
								<button class="btn btn-success " type="button" onclick="saveSpectrumLiveDataInput('spectrum_othermetadata_raw_file_size', ' (Ko)');"><i class="fa fa-check-square-o"></i></button>
							</span>
						</div>
						<a id="btn-edit_spectrum_othermetadata_raw_file_size" class="btn btn-info btn-xs " onclick="editSpectrumLiveDataInput('spectrum_othermetadata_raw_file_size');" href="#"> <i class="fa fa-pencil fa-lg"></i></a>
					</li>
				</ul>
			</div>
		</div>
	</div>
						<!-- #####################################################################################################         end tab -->
</div>
					</form>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal" onclick="checkIfReOpenDetailsModal();"><spring:message code="modal.cancel" text="Cancel" /></button>
				<button type="button" class="btn btn-danger" onclick="deleteCurrentSpectrumCurator(${id}, '${spectrum_type}');"><i class="fa fa-trash"></i> Delete Spectrum </button>
				<button type="button" id="updateSpectrumButton" onclick="updateCurrentSpectrumCurator(${id}, '${spectrum_type}')" class="btn btn-primary">
					<i class="fa fa-save"></i> <spring:message code="modal.saveChanges" text="Save Changes" />
				</button>
				<script type="text/javascript">
				modeEditSpectrum = true;
				var jsonRCC_ADDED = [];
				updateCurrentSpectrumCurator = function( id) {
					$.ajax({
						type: "POST",
						url: "edit-spectrum/" + id,
						data: JSON.stringify({ 
							newCurationMessages: newCurationMessagesCurator,
							newSpectrumData: jsonDataUpdate
						}),
						contentType: 'application/json',
						success: function(data) {
							if(data) { 
								$("#modalEditSpectrum").modal('hide');
								if (document.location.href.indexOf("?PFs=")!=-1) {location.reload();}
								else { try { initLoadCurationMessage(); initLoadCitation(); } catch (e) {} }
								// if on spectrum sheet: reload
							} else {
								alert('<spring:message code="page.spectrum.alert.failUpdateSpectrum" text="Failed to update spectrum!" />'); 
								// TODO alert message
							}
						}, 
						error : function(data) {
							console.log(data);
							alert('<spring:message code="page.spectrum.alert.failUpdateSpectrum" text="Failed to update spectrum!" />'); 
						}
					});
				};
				
				deleteCurrentSpectrumCurator = function(id, type) {
					if (confirm("WARNING: are you sure that you want to permanently delete this spectrum? (cannot be undone)")) {
						$.ajax({
							type: "POST",
							url: "delete-spectrum/" + type + "/" + id + "",
							success: function(data) {
								if(data) { 
									$("#modalEditSpectrum").modal('hide');
									try { initLoadCurationMessage(); initLoadCitation(); } catch (e) {}
								} else {
									alert('<spring:message code="page.spectrum.alert.failDeleteSpectrum" text="Failed to delete spectrum!" />'); 
									// TODO alert message
								}
							}, 
							error : function(data) {
								console.log(data);
								alert('<spring:message code="page.spectrum.alert.failDeleteSpectrum" text="Failed to delete spectrum!" />'); 
							}
						});
					} else { }
				};
				
				
				$(".input-active-enter-key").keypress(function(event) {
					if (event.keyCode == 13) {
						$(this).parent().find('button').click();
					}
				});
				
				$('body').on('hidden.bs.modal', '.modal', function () {
					  $(this).removeData('bs.modal');
				});
				
				var jsonDataUpdate = {}
				
				editSpectrumLiveDataInput = function(key) {
					$("#input_"+key).hide();
					$("#btn-edit_"+key).hide();
					$("#inputEdit_"+key).show();
					$("#updateSpectrumButton").prop("disabled", true);
				}
				saveSpectrumLiveDataInput = function(key, suffix) {
					var newVal = $("#inputEdit_"+key+ " input").val();
					$("#input_"+key).show();
					var suffixAlt = "";
					if (suffix !==undefined)
						suffixAlt = "" + suffix;
					$("#input_"+key).html(newVal + ""+ suffixAlt);
					$("#btn-edit_"+key).show();
					$("#inputEdit_"+key).hide();
					jsonDataUpdate[key]=newVal;
					
					if ($(".btn.btn-success:visible").size()==0)
						$("#updateSpectrumButton").prop("disabled", false);
				}
				
				editSpectrumLiveDataSelect = function(key) {
					$("#select_"+key).hide();
					$("#btn-edit_"+key).hide();
					$("#selectEdit_"+key).show();
					$("#updateSpectrumButton").prop("disabled", true);
				}
				saveSpectrumLiveDataSelect = function(key, suffix) {
					var newVal = $("#selectEdit_"+key+ " select option:selected").html();
					$("#select_"+key).show();
					var suffixAlt = "";
					if (suffix !==undefined)
						suffixAlt = "" + suffix;
					$("#select_"+key).html(newVal + ""+suffixAlt);
					$("#btn-edit_"+key).show();
					$("#selectEdit_"+key).hide();
					jsonDataUpdate[key]=newVal;
					
					if ($(".btn.btn-success:visible").size()==0)
							$("#updateSpectrumButton").prop("disabled", false);
					//
					if (key=="spectrum_chromatography_col_constructor") {
						if ( newVal == 'Other') {
							$("#specialDiv_spectrum_chromatography_col_constructor_other").show();
						} else {
							$("#specialDiv_spectrum_chromatography_col_constructor_other").hide();
						}
					}
					if (key=="spectrum_nmr_tube_prep_ref_chemical_shift_indocator") {
						if ( newVal == 'other') {
							$("#specialDiv_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other").show();
						} else {
							$("#specialDiv_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other").hide();
						}
					}
				}
				
				editSpectrumLiveDataInput2 = function(key) {
					$("#input_"+key).hide();
					$("#btn-edit_"+key).hide();
					$("#inputEdit_"+key).show();
					$("#updateSpectrumButton").prop("disabled", true);
				}
				saveSpectrumLiveDataInput2 = function(key) {
					var newVal1 = $($("#inputEdit_"+key+ " input")[0]).val()
					var newVal2 = $($("#inputEdit_"+key+ " input")[1]).val()
					var newVal = "["+newVal1 + " .. " + newVal2+"]";
					$("#input_"+key).show();
					$("#input_"+key).html(newVal);
					$("#btn-edit_"+key).show();
					$("#inputEdit_"+key).hide();
					jsonDataUpdate[key+"_from"]=newVal1;
					jsonDataUpdate[key+"_to"]=newVal2;
					
					if ($(".btn.btn-success:visible").size()==0)
						$("#updateSpectrumButton").prop("disabled", false);
				}
				
				var container_RCC_ADDED, hot_RCC_ADDED;
				var container_LC_SFG, hot_LC_SFG;
				var container_MS_peaks, hot_MS_peaks;
				var container_NMR_peaks, hot_NMR_peaks;
				var container_NMR_peak_patterns, hot_NMR_peak_patterns;
				
				editSpectrumLiveDataTab = function(key) {
					$("#tab_"+key).hide();
					$("#btn-edit_"+key).hide();
					$("#tabEdit_"+key).show();
					$("#btn-validate_"+key).show();
					$("#updateSpectrumButton").prop("disabled", true);
					
					switch (key) {
					case 'spectrum_sample_mix_tab':
						singlePick = false;
						$("#tabEdit_spectrum_sample_mix_tab").html("");
						var data_RCC_ADDED, colHeaderData;
						// load data
						data_RCC_ADDED = [];
						$.each(cpdMixOriData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["common name"] = v.name;
							tmpDataArray ["<b>concentration (&micro;g/ml)</b>"] = v.concentration;
							data_RCC_ADDED.push(tmpDataArray);
						});						 
						colHeaderData = [
			     			{data: "common name", type: 'text'},
			    			{data: "<b>concentration (&micro;g/ml)</b>", type: 'number' , format: '0.000'}
			    		];
						container_RCC_ADDED = document.getElementById('tabEdit_spectrum_sample_mix_tab');
						hot_RCC_ADDED = new Handsontable(container_RCC_ADDED, {
							data : data_RCC_ADDED,
							minSpareRows : 1,
							colHeaders : true,
							colHeaders: ["common name", "<b>concentration (&micro;g/ml)</b>"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_RCC_ADDED() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_RCC_ADDED = window[instance];
									console.log('data of ' + name, hot_RCC_ADDED.getData());
								}
							});
						}
						bindDumpButton_RCC_ADDED();
						$("#tabEdit_spectrum_sample_mix_tab table.htCore").css("width","100%");
						// celect cell
// 						hot_RCC_ADDED.selectCell(0,0);
						// add select listener
						hot_RCC_ADDED.addHook('afterSelection', hookSelection);
						break;
					case 'spectrum_chromatography_sfg_time':
						$("#tabEdit_spectrum_chromatography_sfg_time").html("");
						var data_LC_SFG = [];
						$.each(lcSFGOriData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["time"] = v.time;
							tmpDataArray ["a"] = v.a;
							tmpDataArray ["b"] = v.b;
							data_LC_SFG.push(tmpDataArray);
						});		
						var colHeaderData = [
			     			{data: "time", type: 'numeric', format: '0.0'},
			     			{data: "a", type: 'numeric', format: '0.0'},
			     			{data: "b", type: 'numeric', format: '0.0'}
			    		];
						container_LC_SFG = document.getElementById('tabEdit_spectrum_chromatography_sfg_time');
						hot_LC_SFG = new Handsontable(container_LC_SFG, {
							data : data_LC_SFG,
							minSpareRows : 1,
							colHeaders : true,
							colHeaders: ["time (min)", "solv. A (%)", "solv. B (%)"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_LC_SFG() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_LC_SFG = window[instance];
									console.log('data of ' + name, hot_LC_SFG.getData());
								}
							});
						}
						bindDumpButton_LC_SFG();
						$("#tabEdit_spectrum_chromatography_sfg_time table.htCore").css("width","100%");
						break;
					case 'spectrum_ms_peaks':
// 						var attribTab = {
// 							data: "attribution",
// 							type: 'dropdown',
// 							source: ['[M]', // NEUTRAL
// 							         '[M+H]+', '[M+NH4]+', '[M+Na]+', '[M+K]+', '[M+H-H2O]+', '[M+H-2H2O]+', '[M+CH3OH+H]+', '[M+CH3CN+H]+',// POS 1M
// 							         '[2M+H]+', '[2M+NH4]+', '[2M+Na]+', '[2M+K]+', // POS 2M
// 							         '[M-H]-', '[M-H-H2O]-', '[M+HCOOH-H]-', '[M+CH3COOH-H]-', // NEG 1M
// 							         '[2M-H]-', '[2M+HCOOH-H]-', '[2M+CH3COOH-H]-', // NEG 2M
// 							         '[3M-H]-' // NEG 3M
// 							         ]
// 						};
						$("#tabEdit_spectrum_ms_peaks").html("");
						var data_MS_peaks = [];
						$.each(msPeaksOrdiData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["mz"] = v.mz;
							tmpDataArray ["ri"] = v.ri;
							tmpDataArray ["theoricalMass"] = v.theoricalMass;
							tmpDataArray ["deltaMass"] = v.deltaMass;
							tmpDataArray ["composition"] = v.composition;
							tmpDataArray ["attribution"] = v.attribution;
							data_MS_peaks.push(tmpDataArray);
						});		
						var colHeaderData = [
			     			{data: "mz", type: 'numeric', format: '0.0000'},
			     			{data: "ri", type: 'numeric', format: '0.0000'},
			     			{data: "theoricalMass", type: 'numeric', format: '0.0000'},
			     			{data: "deltaMass", type: 'numeric', format: '0.0000'},
			     			{data: "composition", type: 'text'},
			     			{data: "attribution", type: 'text'},
			    		];
						container_MS_peaks = document.getElementById('tabEdit_spectrum_ms_peaks');
						hot_MS_peaks = new Handsontable(container_MS_peaks, {
							data : data_MS_peaks,
							minSpareRows : 1,
							colHeaders : true,
							colHeaders: ["m/z", "RI (%)", "Theo. Mass", "Delta ppm", "composition", "attribution"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_MS_peaks() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_MS_peaks = window[instance];
									console.log('data of ' + name, hot_MS_peaks.getData());
								}
							});
						}
						bindDumpButton_MS_peaks();
						hot_MS_peaks.selectCell(0,0);
						$.each(msPeaksOrdiData, function (k,v) {
							hot_MS_peaks.setDataAtCell(k,5,v.attribution);
						});	
						$("#tabEdit_spectrum_ms_peaks table.htCore").css("width","100%");
						break;
					case "spectrum_nmr_peaks":
						$("#tabEdit_spectrum_nmr_peaks").html("");
						var data_NMR_peaks = [];
						$.each(nmrPeaksOriData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["index"] = v.index;
							tmpDataArray ["chemicalShift"] = v.chemicalShift;
							tmpDataArray ["relativeIntensity"] = v.relativeIntensity;
							tmpDataArray ["halfWidth"] = v.halfWidth;
							tmpDataArray ["halfWidthHz"] = v.halfWidthHz;
// 							tmpDataArray ["attribution"] = v.attribution;
							tmpDataArray ["annotation"] = v.annotation;
							data_NMR_peaks.push(tmpDataArray);
						});		
						var colHeaderData = [
			     			{data: "index", type: 'numeric'},
			     			{data: "chemicalShift", type: 'numeric', format: '0.0000'},
			     			{data: "relativeIntensity", type: 'numeric', format: '0.0000'},
			     			{data: "halfWidth", type: 'numeric', format: '0.0000'},
			     			{data: "halfWidthHz", type: 'numeric', format: '0.0000'},
			     			{data: "annotation", type: 'text'}
			    		];
						container_NMR_peaks = document.getElementById('tabEdit_spectrum_nmr_peaks');
						hot_NMR_peaks = new Handsontable(container_NMR_peaks, {
							data : data_NMR_peaks,
							minSpareRows : 1,
							colHeaders : true,
							colHeaders: ["index", "&nu; (F1) [ppm]", "intensity [rel]", "half width [ppm]", "half width [Hz]", "annotation"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_NMR_peaks() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_NMR_peaks = window[instance];
									console.log('data of ' + name, hot_NMR_peaks.getData());
								}
							});
						}
						bindDumpButton_NMR_peaks();
						hot_NMR_peaks.selectCell(0,0);
						$("#tabEdit_spectrum_nmr_peaks table.htCore").css("width","100%");
						break;
					case "spectrum_nmr_2dpeaks":
						$("#tabEdit_spectrum_nmr_2dpeaks").html("");
						var data_NMR_peaks = [];
						$.each(nmrPeaksOriData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["index"] = v.index;
							tmpDataArray ["chemicalShiftF1"] = v.chemicalShiftF1;
							tmpDataArray ["chemicalShiftF2"] = v.chemicalShiftF2;
							tmpDataArray ["intensity"] = v.intensity;
// 							tmpDataArray ["attribution"] = v.attribution;
							tmpDataArray ["annotation"] = v.annotation;
							data_NMR_peaks.push(tmpDataArray);
						});		
						var colHeaderData = [
			     			{data: "index", type: 'numeric'},
			     			{data: "chemicalShiftF2", type: 'numeric', format: '0.0000'},
			     			{data: "chemicalShiftF1", type: 'numeric', format: '0.0000'},
			     			{data: "intensity", type: 'numeric', format: '0.0000'},
			     			{data: "annotation", type: 'text'}
			    		];
						container_NMR_peaks = document.getElementById('tabEdit_spectrum_nmr_2dpeaks');
						hot_NMR_peaks = new Handsontable(container_NMR_peaks, {
							data : data_NMR_peaks,
							minSpareRows : 1,
							colHeaders : true,
							colHeaders: ["index", "&nu; (F2) [ppm]", "&nu; (F1) [ppm]", "intensity [abs]",  "annotation"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_NMR_peaks() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_NMR_peaks = window[instance];
									console.log('data of ' + name, hot_NMR_peaks.getData());
								}
							});
						}
						bindDumpButton_NMR_peaks();
						hot_NMR_peaks.selectCell(0,0);
						$("#tabEdit_spectrum_nmr_2dpeaks table.htCore").css("width","100%");
						break;
					case "spectrum_nmr_jres_peaks":
						$("#tabEdit_spectrum_nmr_jres_peaks").html("");
						var data_NMR_peaks = [];
						$.each(nmrPeaksOriData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["index"] = v.index;
							tmpDataArray ["chemicalShiftF1"] = v.chemicalShiftF1;
							tmpDataArray ["chemicalShiftF2"] = v.chemicalShiftF2;
							tmpDataArray ["intensity"] = v.intensity;
							tmpDataArray ["multiplicity"] = v.multiplicity;
							tmpDataArray ["j"] = v.j;
// 							tmpDataArray ["attribution"] = v.attribution;
							tmpDataArray ["annotation"] = v.annotation;
							data_NMR_peaks.push(tmpDataArray);
						});		
						var colHeaderData = [
			     			{data: "index", type: 'numeric'},
			     			{data: "chemicalShiftF2", type: 'numeric', format: '0.0000'},
			     			{data: "chemicalShiftF1", type: 'numeric', format: '0.0000'},
			     			{data: "intensity", type: 'numeric', format: '0.0000'},
			     			{data: "multiplicity", type: 'text'},
			     			{data: "j", type: 'text'},
			     			{data: "annotation", type: 'text'}
			    		];
						container_NMR_peaks = document.getElementById('tabEdit_spectrum_nmr_jres_peaks');
						hot_NMR_peaks = new Handsontable(container_NMR_peaks, {
							data : data_NMR_peaks,
							minSpareRows : 1,
							colHeaders : true,
							colHeaders: ["index", "&nu; (F2) [ppm]", "&nu; (F1) [ppm]", "intensity", "multiplicity", "J",  "annotation"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_NMR_peaks() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_NMR_peaks = window[instance];
									console.log('data of ' + name, hot_NMR_peaks.getData());
								}
							});
						}
						bindDumpButton_NMR_peaks();
						hot_NMR_peaks.selectCell(0,0);
						$("#tabEdit_spectrum_nmr_jres_peaks table.htCore").css("width","100%");
						break;
					case "spectrum_nmr_peak_patterns":
						$("#tabEdit_spectrum_nmr_peak_patterns").html("");
						var data_NMR_peak_patterns = [];
						$.each(nmrPeakPatternsOriData, function (k,v) {
							var tmpDataArray = [];
							tmpDataArray ["chemicalShift"] = v.chemicalShift;
							tmpDataArray ["H_or_C"] = v.hORc;
							tmpDataArray ["pattern"] = v.pattern;
							tmpDataArray ["couplageConstant"] = v.couplageConstant;
							tmpDataArray ["rangeFrom"] = "" + v.rangeFrom ;
							tmpDataArray ["rangeTo"] = v.rangeTo + "";
// 							tmpDataArray ["range"] = "[" + v.rangeFrom + " .. " + v.rangeTo + "]";
							tmpDataArray ["atom"] = v.atom;
							data_NMR_peak_patterns.push(tmpDataArray);
						});		
						var colHeaderData = [
			     			{data: "chemicalShift", type: 'numeric', format: '0.0000'},
			     			{data: "H_or_C", type: 'numeric', format: '0'},
			     			{data: "pattern", type: 'text'},
			     			{data: "couplageConstant", type: 'text'},
			     			{data: "rangeFrom", type: 'numeric', format: '0.0000'},
			     			{data: "rangeTo", type: 'numeric', format: '0.0000'},
			     			{data: "atom", type: 'text'}
			    		];
						container_NMR_peak_patterns = document.getElementById('tabEdit_spectrum_nmr_peak_patterns');
						hot_NMR_peak_patterns = new Handsontable(container_NMR_peak_patterns, {
							data : data_NMR_peak_patterns,
							minSpareRows : 1,
							colHeaders : true,
							// NOTE: not "H's" column
							colHeaders: ["&nu; (F1) [ppm]", "H's || C's", "type", "J(Hz)", "range from (ppm)", "range to (ppm)", "atoms"],
							contextMenu : false,
							columns: colHeaderData
						});
						function bindDumpButton_NMR_peak_patterns() {
							Handsontable.Dom.addEvent(document.body, 'click', function(e) {
								var element = e.target || e.srcElement;
								if (element.nodeName == "BUTTON"&& element.name == 'dump') {
									var name = element.getAttribute('data-dump');
									var instance = element.getAttribute('data-instance');
									var hot_NMR_peak_patterns = window[instance];
									console.log('data of ' + name, hot_NMR_peak_patterns.getData());
								}
							});
						}
						bindDumpButton_NMR_peak_patterns();
						hot_NMR_peak_patterns.selectCell(0,0);
						$("#tabEdit_spectrum_nmr_peak_patterns table.htCore").css("width","100%");
						break;
					default:
						break;
					}
				}
				
				updateSpectrumLiveDataTab = function(key) {
					// MOO
					switch (key) {
					case 'spectrum_sample_mix_tab':
						jsonRCC_ADDED = [];
						$.each(hot_RCC_ADDED.getData(), function(){
							var formatData = {};
							if ("common name" in this && this["common name"]!= undefined && this["common name"] != "") {
								var compound = updatedCpdMixData[(this["common name"])];
								compound['concentration'] = Number(this["<b>concentration (&micro;g/ml)</b>"]);
								jsonRCC_ADDED.push(compound);
							}
						});
						// update data edit table
						cpdMixOriData = [];
						$.each(jsonRCC_ADDED,function(k,v){
							cpdMixOriData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=cpdMixOriData;
						// TODO update data in html
						$("#tab_spectrum_sample_mix_tab tbody").empty();
						$("#templateCompoundsMix").tmpl(cpdMixOriData).appendTo("#tab_spectrum_sample_mix_tab tbody");
						break;
					case 'spectrum_chromatography_sfg_time':
						jsonSFG = [];
						$.each(hot_LC_SFG.getData(), function(){
							var formatData = {};
							try {
// 								if (dataT['time']!= NaN) {
									var dataT = {};
									dataT['time'] = Number(this["time"]);
									dataT['a'] = Number(this["a"]);
									dataT['b'] = Number(this["b"]);
									jsonSFG.push(dataT);
// 								}
							} catch(e){}
						});
						// update data edit table
						lcSFGOriData = [];
						$.each(jsonSFG,function(k,v){
							if (v.time==Number(v.time+""))
								lcSFGOriData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=lcSFGOriData;
						// update data in html
						$("#tab_spectrum_chromatography_sfg_time tbody").empty();
						$("#templateSFG").tmpl(lcSFGOriData).appendTo("#tab_spectrum_chromatography_sfg_time tbody");
						break;
					case 'spectrum_ms_peaks':
						jsonMSpeaks = [];
						$.each(hot_MS_peaks.getData(), function(){
							var formatData = {};
							try {
								var dataT = {};
								dataT['mz'] = Number(this["mz"]);
								dataT['ri'] = Number(this["ri"]);
								dataT['theoricalMass'] = Number(this["theoricalMass"]);
								dataT['deltaMass'] = Number(this["deltaMass"]);
								dataT['composition'] = (this["composition"]);
								dataT['attribution'] = (this["attribution"]);
								jsonMSpeaks.push(dataT);
							} catch(e){}
						});
						// update data edit table
						msPeaksOrdiData = [];
						$.each(jsonMSpeaks,function(k,v){
							if (v.mz==Number(v.mz+""))
								msPeaksOrdiData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=msPeaksOrdiData;
						// update data in html
						$("#tab_spectrum_ms_peaks tbody").empty();
						$("#templateMSpeaks").tmpl(msPeaksOrdiData).appendTo("#tab_spectrum_ms_peaks tbody");
						break;
					default:
					case 'spectrum_nmr_peaks':
						jsonNMRpeaks = [];
						var i = 1;
						$.each(hot_NMR_peaks.getData(), function(){
							var formatData = {};
							try {
								var dataT = {};
								dataT['index'] = i;
								dataT['chemicalShift'] = Number(this["chemicalShift"]);
								dataT['relativeIntensity'] = Number(this["relativeIntensity"]);
								dataT['halfWidth'] = Number(this["halfWidth"]);
								dataT['halfWidthHz'] = Number(this["halfWidthHz"]);
								dataT['annotation'] = (this["annotation"]);
								jsonNMRpeaks.push(dataT);
								i++;
							} catch(e){}
						});
						// update data edit table
						nmrPeaksOriData = [];
						$.each(jsonNMRpeaks,function(k,v){
							if (v.chemicalShift==Number(v.chemicalShift+""))
								nmrPeaksOriData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=nmrPeaksOriData;
						// update data in html
						$("#tab_spectrum_nmr_peaks tbody").empty();
						$("#templateNMRpeaks").tmpl(nmrPeaksOriData).appendTo("#tab_spectrum_nmr_peaks tbody");
						break;
					case 'spectrum_nmr_2dpeaks':
						jsonNMRpeaks = [];
						var i = 1;
						$.each(hot_NMR_peaks.getData(), function(){
							var formatData = {};
							try {
								var dataT = {};
								dataT['index'] = i;
								dataT['chemicalShiftF1'] = Number(this["chemicalShiftF1"]);
								dataT['chemicalShiftF2'] = Number(this["chemicalShiftF2"]);
								dataT['intensity'] = Number(this["intensity"]);
								dataT['annotation'] = (this["annotation"]);
								jsonNMRpeaks.push(dataT);
								i++;
							} catch(e){}
						});
						// update data edit table
						nmrPeaksOriData = [];
						$.each(jsonNMRpeaks,function(k,v){
							if (v.chemicalShiftF1==Number(v.chemicalShiftF1+""))
								nmrPeaksOriData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=nmrPeaksOriData;
						// update data in html
						$("#tab_spectrum_nmr_2dpeaks tbody").empty();
						$("#templateNMR2Dpeaks").tmpl(nmrPeaksOriData).appendTo("#tab_spectrum_nmr_2dpeaks tbody");
						break;
					case 'spectrum_nmr_jres_peaks':
						jsonNMRpeaks = [];
						var i = 1;
						$.each(hot_NMR_peaks.getData(), function(){
							var formatData = {};
							try {
								var dataT = {};
								dataT['index'] = i;
								dataT['chemicalShiftF1'] = Number(this["chemicalShiftF1"]);
								dataT['chemicalShiftF2'] = Number(this["chemicalShiftF2"]);
								dataT['multiplicity'] = (this["multiplicity"]);
								dataT['j'] = (this["j"]);
								dataT['intensity'] = Number(this["intensity"]);
								dataT['annotation'] = (this["annotation"]);
								jsonNMRpeaks.push(dataT);
								i++;
							} catch(e){}
						});
						// update data edit table
						nmrPeaksOriData = [];
						$.each(jsonNMRpeaks,function(k,v){
							if (v.chemicalShiftF1==Number(v.chemicalShiftF1+""))
								nmrPeaksOriData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=nmrPeaksOriData;
						// update data in html
						$("#tab_spectrum_nmr_jres_peaks tbody").empty();
						$("#templateNMRJRESpeaks").tmpl(nmrPeaksOriData).appendTo("#tab_spectrum_nmr_jres_peaks tbody");
						break;
					case 'spectrum_nmr_peak_patterns':
						jsonNMRpeakPatterns = [];
						$.each(hot_NMR_peak_patterns.getData(), function(){
							var formatData = {};
							try {
								var dataT = {};
								dataT['chemicalShift'] = Number(this["chemicalShift"]);
								dataT['H_or_C'] = Number(this["H_or_C"]);
								dataT['pattern'] = (this["pattern"]);
								dataT['couplageConstant'] = (this["couplageConstant"]);
								dataT['rangeFrom'] = (this["rangeFrom"]);
								dataT['rangeTo'] = (this["rangeTo"]);
								dataT['atom'] = (this["atom"]);
								jsonNMRpeakPatterns.push(dataT);
							} catch(e){}
						});
						// update data edit table
						nmrPeakPatternsOriData = [];
						$.each(jsonNMRpeakPatterns,function(k,v){
							if (v.chemicalShift==Number(v.chemicalShift+""))
								nmrPeakPatternsOriData.push(v);
						});
						// update data to update in controller
						jsonDataUpdate[key]=nmrPeakPatternsOriData;
						// update data in html
						$("#tab_spectrum_nmr_peak_patterns tbody").empty();
						$("#templateNMRpeakpatterns").tmpl(nmrPeakPatternsOriData).appendTo("#tab_spectrum_nmr_peak_patterns tbody");
						break;
					}
					// display
					$("#tab_"+key).show();
					$("#btn-edit_"+key).show();
					$("#tabEdit_"+key).hide();
					$("#btn-validate_"+key).hide();
					if ($.each($("button.btn-success:visible"), function(){ console.log(this) }).size()==0)
						$("#updateSpectrumButton").prop("disabled", false);
				};
				
				hookSelection = function(r, c) {
					// display modalbox
					if (c == 0) 
						pickChemicalCompound4Mix(r);
				};
				pickChemicalCompound4Mix = function(rowNumber) {
					// init
					singlePick = false;
					multiPickLine = rowNumber;
					// display modal
					$("#modalEditSpectrum .modal-dialog").hide();
					$("#modalPickCompound").modal("show");
					$("#add-one-cc-s1-value").focus();
				}
		
				
				
$(document).ready(function() {
	
	$("#tab_spectrum_sample_mix_tab").tablesorter();
	$('.datepicker').datepicker();
	
	// LCMS solents
	$("#selectElem_select_spectrum_sample_compound_liquid_solvent").append('<option value="" disabled="disabled">choose in list&hellip;</option>');
	$.getJSON("resources/json/list-lcms-solvents.json", function(data) {
		// load data from json
		$.each(data.solvents,function(){
			$("#selectElem_select_spectrum_sample_compound_liquid_solvent").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$("#selectElem_select_spectrum_sample_compound_liquid_solvent").val("${select_spectrum_sample_compound_liquid_solvent}");
	});
	
	// LCMS mix solvents
	$("#selectElem_select_spectrum_sample_compound_liquid_solvent_mix").val("${select_spectrum_sample_compound_liquid_solvent}");

	// LC column
	$.getJSON("resources/json/list-lc-methods.json", function(data) {
		$("#selectElem_spectrum_chromatography_method").empty();
		$("#selectElem_spectrum_chromatography_method").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined)
					$("#selectElem_spectrum_chromatography_method").append('<option value="'+this.value+'">'+this.name+'</option>');
				else
					$("#selectElem_spectrum_chromatography_method").append('<option disabled>'+this.name+'</option>');
			}
		});
		$("#selectElem_spectrum_chromatography_method").val("${spectrum_chromatography_method}");
	});
	
	// LC columns
	$.getJSON("resources/json/list-lc-columns.json", function(data) {
		$("#selectElem_spectrum_chromatography_col_constructor").empty();
		$("#selectElem_spectrum_chromatography_col_constructor").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.columns,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined)
					$("#selectElem_spectrum_chromatography_col_constructor").append('<option value="'+this.value+'">'+this.name+'</option>');
				else
					$("#selectElem_spectrum_chromatography_col_constructor").append('<option disabled>'+this.name+'</option>');
			}
		});
		$("#selectElem_spectrum_chromatography_col_constructor").append('<option value="other" >Other</option>');
		$("#selectElem_spectrum_chromatography_col_constructor").val("${fn:escapeXml(spectrum_chromatography_col_constructor)}");
		if ($("#selectElem_spectrum_chromatography_col_constructor").val() != "${fn:escapeXml(spectrum_chromatography_col_constructor)}") {
			$("#specialDiv_spectrum_chromatography_col_constructor_other").show();
			// $("#specialDiv_spectrum_chromatography_col_constructor_other").val("${fn:escapeXml(spectrum_chromatography_col_constructor)}")
			$("#selectElem_spectrum_chromatography_col_constructor").val("Other");
		}
	});
	
	// LC mode
	$("#selectElem_spectrum_chromatography_mode_lc").val(("${spectrum_chromatography_mode_lc}").toLowerCase());
	
	// LC solvent pH
	$.getJSON("resources/json/list-lc-solvents.json", function(data) {
		$("#selectElem_spectrum_chromatography_solventA").empty();
		$("#selectElem_spectrum_chromatography_solventB").empty();
		$("#selectElem_spectrum_chromatography_solventA").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		$("#selectElem_spectrum_chromatography_solventB").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.solvents,function(){
			$("#selectElem_spectrum_chromatography_solventA").append('<option value="'+this.value+'">'+this.name+'</option>');
			$("#selectElem_spectrum_chromatography_solventB").append('<option value="'+this.value+'">'+this.name+'</option>');
		});
		$("#selectElem_spectrum_chromatography_solventA").val("${spectrum_chromatography_solventA}");
		$("#selectElem_spectrum_chromatography_solventB").val("${spectrum_chromatography_solventB}");
	});

	// NMR solents
	$.getJSON("resources/json/list-nmr-solvents.json", function(data) {
		$("#selectElem_spectrum_nmr_tube_prep_solvent").empty();
		$("#selectElem_spectrum_nmr_tube_prep_solvent").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.solvents,function(){
			$("#selectElem_spectrum_nmr_tube_prep_solvent").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$("#selectElem_spectrum_nmr_tube_prep_solvent").val("${spectrum_nmr_tube_prep.getNMRsolventAsString()}");
	});
	
	// NMR reference chemical shif indicator
	$.getJSON("resources/json/list-nmr-referenceChemShiftIndicators.json", function(data) {
		$("#selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator").empty();
		$("#selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.referenceChemShiftIndicator,function(){
			$("#selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$("#selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator").val("${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())}");
		
		if ($("#selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator").val() != "${fn:escapeXml(spectrum_nmr_tube_prep.getNMRreferenceChemicalShifIndicatorAsString())}") {
			$("#specialDiv_spectrum_nmr_tube_prep_ref_chemical_shift_indocator_other").show();
			// $("#specialDiv_spectrum_chromatography_col_constructor_other").val("${fn:escapeXml(spectrum_chromatography_col_constructor)}")
			$("#selectElem_spectrum_nmr_tube_prep_ref_chemical_shift_indocator").val("other");
		}
	});
	
	// NMR Lock Substance
	$.getJSON("resources/json/list-nmr-lockSubstances.json", function(data) {
		$("#selectElem_spectrum_nmr_tube_prep_lock_substance").empty();
		$("#selectElem_spectrum_nmr_tube_prep_lock_substance").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.lockSubstance,function(){
			$("#selectElem_spectrum_nmr_tube_prep_lock_substance").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$("#selectElem_spectrum_nmr_tube_prep_lock_substance").val("${spectrum_nmr_tube_prep.getNMRlockSubstanceAsString()}");
	});
	
	// NMR Buffer Solution
	$.getJSON("resources/json/list-nmr-bufferSolutions.json", function(data) {
		$("#selectElem_spectrum_nmr_tube_prep_buffer_solution").empty();
		$("#selectElem_spectrum_nmr_tube_prep_buffer_solution").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.bufferSolution,function(){
			$("#selectElem_spectrum_nmr_tube_prep_buffer_solution").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$("#selectElem_spectrum_nmr_tube_prep_buffer_solution").val("${spectrum_nmr_tube_prep.getNMRbufferSolutionAsString()}");
	});

	// MASS
	$.getJSON("resources/json/list-ms-ionization-methods.json", function(data) {
		$("#selectElem_spectrum_ms_ionization_ionization_method").empty();
		$("#selectElem_spectrum_ms_ionization_ionization_method").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		// load data from json
		$.each(data.methods,function(){
			if (this.name !==undefined) {
				if (this.value !==undefined) {
					$("#selectElem_spectrum_ms_ionization_ionization_method").append('<option value="'+this.value+'">'+this.name+'</option>');
				} else {
					$("#selectElem_spectrum_ms_ionization_ionization_method").append('<option disabled>'+this.name+'</option>');
				}
			}
		});
		$("#selectElem_spectrum_ms_ionization_ionization_method").val("${fn:escapeXml(spectrum_ms_ionization.getIonizationAsString())}");
	});
	
	// NMR instrument
	$.getJSON("resources/json/list-nmr-instrumentOptions.json", function(data) {
		$("#selectElem_spectrum_nmr_analyzer_name").empty();
		$("#selectElem_spectrum_nmr_analyzer_magneticFieldStrength").empty();
		$("#selectElem_spectrum_nmr_analyzer_software").empty();
		$("#selectElem_spectrum_nmr_analyzer_probe").empty();
		$("#selectElem_spectrum_nmr_analyzer_tube").empty();

		$("#selectElem_spectrum_nmr_analyzer_name").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		$("#selectElem_spectrum_nmr_analyzer_magneticFieldStrength").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		$("#selectElem_spectrum_nmr_analyzer_software").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		$("#selectElem_spectrum_nmr_analyzer_probe").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
		$("#selectElem_spectrum_nmr_analyzer_tube").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');

		// load data from json
		$.each(data.model,function(){
			$("#selectElem_spectrum_nmr_analyzer_name").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.magnetic_field_strength,function(){
			$("#selectElem_spectrum_nmr_analyzer_magneticFieldStrength").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.software,function(){
			$("#selectElem_spectrum_nmr_analyzer_software").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.probe,function(){
			$("#selectElem_spectrum_nmr_analyzer_probe").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});
		$.each(data.tubes,function(){
			$("#selectElem_spectrum_nmr_analyzer_tube").append('<option value="'+this.value+'" class="'+this.classD+'">'+this.name+'</option>');
		});

		$("#selectElem_spectrum_nmr_analyzer_name").val("${fn:escapeXml(spectrum_nmr_analyzer.getNMRinstrumentNameAsString())}");
		$("#selectElem_spectrum_nmr_analyzer_magneticFieldStrength").val("${fn:escapeXml(spectrum_nmr_analyzer.getMagneticFieldStrenghtAsString())}");
		$("#selectElem_spectrum_nmr_analyzer_software").val("${fn:escapeXml(spectrum_nmr_analyzer.getNMRsoftwareVersionAsString())}");
		$("#selectElem_spectrum_nmr_analyzer_probe").val("${fn:escapeXml(spectrum_nmr_analyzer.getNMRprobeAsString())}");
		$("#selectElem_spectrum_nmr_analyzer_tube").val("${fn:escapeXml(spectrum_nmr_analyzer.getNMRtubeDiameterAsString())}");
	});
	
	// NMR boolean fields
	$("#selectElem_spectrum_nmr_analyzer_data_fourier_transform").empty();
	$("#selectElem_spectrum_nmr_analyzer_data_fourier_transform").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#selectElem_spectrum_nmr_analyzer_data_fourier_transform").append('<option value="false">False</option>');
	$("#selectElem_spectrum_nmr_analyzer_data_fourier_transform").append('<option value="true">True</option>');
	$("#selectElem_spectrum_nmr_analyzer_data_fourier_transform").val(("${spectrum_nmr_analyzer_data.getFourierTransform()}").toLowerCase());
	
	// <!--
	<c:choose> 
	<c:when test="${spectrum_nmr_analyzer_data_acquisition == 'COSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'TOCSY-2D' || spectrum_nmr_analyzer_data_acquisition == 'NOESY-2D' || spectrum_nmr_analyzer_data_acquisition == 'HMBC-2D' || spectrum_nmr_analyzer_data_acquisition == 'HSQC-2D'}">
	// NMR boolean fields
	$("#selectElem_spectrum_nmr_analyzer_nus").empty();
	$("#selectElem_spectrum_nmr_analyzer_nus").append('<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>');
	$("#selectElem_spectrum_nmr_analyzer_nus").append('<option value="false">No</option>');
	$("#selectElem_spectrum_nmr_analyzer_nus").append('<option value="true">Yes</option>');
	$("#selectElem_spectrum_nmr_analyzer_nus").val(("${spectrum_nmr_analyzer_data.nus}").toLowerCase());
	</c:when>
	</c:choose>
	// -->
});
				
				
				</script>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
	
<script  type="text/x-jquery-tmpl" id="templateCompoundsMix">
<tr>
	<td>
		<span class="avatar">
			<img class="compoundSVG" src="image/{%= type%}/{%= inchikey%}" alt="{%= name%}" />
		</span>
	</td>
	<td style="white-space: nowrap;">
		{%= name%}
	</td>
	<td>
		{%= concentration%}
	</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateSFG">
<tr>
	<td style="width: 100px;">{%= time%}</td>
	<td>{%= a%}</td>
	<td>{%= b%}</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateMSpeaks">
<tr>
	<td>{%= mz%}</td>
	<td>{%= ri%}</td>
	<td>{%= theoricalMass%}</td>
	<td>{%= deltaMass%}</td>
	<td>{%= composition%}</td>
	<td>{%= attribution%}</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateNMRpeaks">
<tr>
	<td>{%= index%}</td>
	<td>{%= chemicalShift%}</td>
	<td>{%= relativeIntensity%}</td>
	<td>{%= halfWidth%}</td>
	<td>{%= halfWidthHz%}</td>
	<td>{%= annotation%}</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateNMR2Dpeaks">
<tr>
	<td>{%= index%}</td>
	<td>{%= chemicalShiftF2%}</td>
	<td>{%= chemicalShiftF1%}</td>
	<td>{%= intensity%}</td>
	<td>{%= annotation%}</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateNMRJRESpeaks">
<tr>
	<td>{%= index%}</td>
	<td>{%= chemicalShiftF2%}</td>
	<td>{%= chemicalShiftF1%}</td>
	<td class="tabStrippedBg">{%= intensity%}</td>
	<td>{%= multiplicity%}</td>
	<td>{%= j%}</td>
	<td>{%= annotation%}</td>
</tr>
</script>
<script  type="text/x-jquery-tmpl" id="templateNMRpeakpatterns">
<tr>
	<td>{%= chemicalShift%}</td>
	<td>{%= H_or_C%}</td>
	<td>{%= pattern%}</td>
	<td>{%= couplageConstant%}</td>
	<td>[{%= rangeFrom%} .. {%= rangeTo%}]</td>
	<td>{%= atom%}</td>
</tr>
</script>
<script type="text/javascript">
$('#add-one-cc-s1-value').bind('keypress', function(e) {
	var code = e.keyCode || e.which;
	if (code == 13) {
		searchLocalCompound();
	}
});
// autocomplete
var subjects = [];
//	$('#search').typeahead({source: subjects});
$('#add-one-cc-s1-value').typeahead({
	source: function (query, process) {
        return searchAjax();
    }
});
searchAjax = function () {
	var results = [];
	var rawQuery = $('#add-one-cc-s1-value').val();
	if (rawQuery.length > 2) {
		$.ajax({ 
				type: "post",
				url: "search",
				dataType: "json",
				async: false,
				data: "query=" + $('#add-one-cc-s1-value').val(),
				success: function(json) {
					if (json.success) {
						// names
						$.each(json.compoundNames, function(){
							results.push(this.name);
						}); 
						$.each(json.compounds, function(){
							if (this.inChIKey.indexOf(rawQuery))
								results.push(this.inChIKey);
						});
					}
			},
			error : function(xhr) {
				subjects = [];
				// TODO alert error xhr.responseText
				console.log(xhr);
			}
		});
	}
	return results;
};

searchLocalCompound = function() {
	$("#load-step-1").show();
	$.ajax({ 
		type: "post",
		url: "pick-one-compound-search",
//			dataType: "html",
		async: true,
		data: "query=" + $('#add-one-cc-s1-value').val() + "&filter=<%=PeakForestUtils.SEARCH_COMPOUND_CHEMICAL_NAME%>",
		success: function(data) {
			$("#ok-step-1").html(data);
		},
		error : function(xhr) {
			// log
			console.log(xhr);
			// error
			$("#ok-step-1").html("Error: could not process request.");
		}
	}).always(function() {
		$("#load-step-1").hide();
	});
}

//
getRCCADDED = function() {
	jsonRCC_ADDED = [];
	$.each(hot_RCC_ADDED.getData(), function(){
		var formatData = {};
		if ("<b>InChIKey</b>" in this && this["<b>InChIKey</b>"]!= undefined && this["<b>InChIKey</b>"] != "") {
			formatData['inchikey'] = (this["<b>InChIKey</b>"]);
			formatData['concentration'] = (this["<b>concentration (&micro;g/ml)</b>"]);
			jsonRCC_ADDED.push(formatData);
		}
	});
	return jsonRCC_ADDED;
};

clearLine = function() {
	$("#modalEditSpectrum .modal-dialog").hide();
	// restet form
	setTimeout(function(){
		$("#add-one-cc-s1-value").val("");
		$("#ok-step-1").html("");
	}, 200);
	$("img.mixRCCadd"+multiPickLine).remove();
	if (singlePick) {
// 		$("#add1spectrum-sample-inchikey").val("");
// 		$("#add1spectrum-sample-inchikey").change();
// 		$("#add1spectrum-sample-inchi").val("");
// 		$("#add1spectrum-sample-inchi").change();
// 		$("#add1spectrum-sample-commonName").val("");
// 		$("#add1spectrum-sample-commonName").change();
// 		$("#sample-bonus-display").html('');
	} else if (multiPickLine >= 0) {
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 0, "");
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 1, "");
	}
}
showEditModalBack = function () {
	// update data
// 	jsonRCC_ADDED = [];
// 	$.each(hot_RCC_ADDED.getData(), function(){
// 		var formatData = {};
// 		if ("common name" in this && this["common name"]!= undefined && this["common name"] != "") {
// 			var compound = updatedCpdMixData[(this["common name"])];
// 			compound['concentration'] = Number(this["<b>concentration (&micro;g/ml)</b>"]);
// 			jsonRCC_ADDED.push(compound);
// 		}
// 	});
	// use jsonRCC_ADDED to update tab
	// show
	$("#modalEditSpectrum .modal-dialog").show();
}
</script>
	
</body>
</html>
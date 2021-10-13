<%@page import="fr.metabohub.spectralibraries.mapper.PeakForestDataMapper"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<!-- html5 file parser -->
<script src="<c:url value="/resources/js/peakforest/nmr-metadata-reader.min.js" />"></script>
<script src="<c:url value="/resources/js/peakforest/nmr-peaklist-reader.min.js" />"></script>
<script src="<c:url value="/resources/js/peakforest/template.min.js" />"></script>
<script src="<c:url value="/resources/js/select2.min.js" />"></script>
<link href="<c:url value="/resources/css/select2.min.css" />" rel="stylesheet">

<div class="row">
	<div class="col-lg-12">

<!-- template zone:start -->
<div class="col-lg-10">
	<div class="col-lg-6">
		<div class="form-group input-group">
			<span class="input-group-addon">sample type</span> 
			<select id="downloadTemplateSpectrumSampleType" class="form-control downloadTemplateForm">
				<option value="" selected="selected"></option>
				<option value="<%= PeakForestDataMapper.SAMPLE_TYPE_CHEMICAL_COMPOUND_LIBRARY %>">Chemical Compound from Library (single)</option>
				<option value="<%= PeakForestDataMapper.SAMPLE_TYPE_CHEMICAL_COMPOUND_MIX %>">mix of Chemical Compound from Library</option>
				<option value="<%= PeakForestDataMapper.SAMPLE_TYPE_STANDARDIZED_MATRIX %>">Standardized Matrix</option>
				<option value="<%= PeakForestDataMapper.SAMPLE_TYPE_ANALYTICAL_MATRIX %>">Analytical Matrix</option>
			</select>
		</div>
	</div>
	<div class="col-lg-6">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateSelectMatrix" style="display: none;">
	<div class="radio">
		<label>
			<input id="dumpTopMatrix" name="matrixToDump" type="radio" value="topPF" checked class="downloadTemplateForm">
			Dump only PeakForest's &quot;top&quot; analytical matrix.
			<a onclick="ontologies_load('top')" data-toggle="modal" data-target="#modalListOntologies"><i class="fa fa-question-circle" aria-hidden="true"></i> </a>
		</label>
	</div>
	<div class="radio">
		<label>
			<input id="dumpAllPForestMatrix" name="matrixToDump" type="radio" value="allPF" class="downloadTemplateForm">
			Dump all PeakForest's analytical matrix.
			<a onclick="ontologies_load('all')" data-toggle="modal" data-target="#modalListOntologies"><i class="fa fa-question-circle" aria-hidden="true"></i> </a>
		</label>
	</div>
	<!-- 
	<div class="radio">
		<label>
			<input id="dumpAllOntolgiesFWMatrix" name="matrixToDump" type="radio" value="allOntoFW" class="downloadTemplateForm">
			Add all analytical matrix described through <a target="_blank" href="<spring:message code="link.site.ontologiesframework" text="https://pfem.clermont.inra.fr/ontologies-framework/" />">ontologies framework online tool</a>.
		</label>
	</div>  
	-->
</div>
<div class="col-lg-10">
	<div class="col-lg-6">
		<div class="form-group input-group">
			<span class="input-group-addon">spectrum type</span> 
			<select id="downloadTemplateSpectrumType" class="form-control downloadTemplateForm">
				<option value="" selected="selected"></option>
				<option value="gc-ms">GC-MS</option>
				<option value="lc-ms">LC-MS</option>
				<option value="nmr">NMR</option>
				<option value="lc-msms">LC-MSMS</option>
				<option value="lc-nmr" disabled="disabled">LC-NMR</option>
			</select>
		</div>
	</div>
	<div class="col-lg-6">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateUploadFile downloadTemplateUploadFile-lcms" style="display: none;">
	<div class="col-lg-8 ">
		<div id="uploadFileLCMS" class="form-group" style="">
			<label>Autofield template with method: &nbsp;&nbsp;&nbsp;</label>
			<label class="radio-inline">
				<input type="radio" name="downloadTemplatePresfield-lcms" id="downloadTemplatePresfieldY-lcms" value="true" class="downloadTemplateForm"> Yes
			</label>
			<label class="radio-inline"> 
				<input type="radio" name="downloadTemplatePresfield-lcms" id="downloadTemplatePresfieldN-lcms" value="false" checked="checked" class="downloadTemplateForm"> No 
			</label>
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateUploadFile downloadTemplateUploadFile-lcmsms" style="display: none;">
	<div class="col-lg-8 ">
		<div id="uploadFileMSMS" class="form-group" style="">
			<label>Autofield template with method: &nbsp;&nbsp;&nbsp;</label>
			<label class="radio-inline">
				<input type="radio" name="downloadTemplatePresfield-lcmsms" id="downloadTemplatePresfieldY-lcmsms" value="true" class="downloadTemplateForm"> Yes
			</label>
			<label class="radio-inline"> 
				<input type="radio" name="downloadTemplatePresfield-lcmsms" id="downloadTemplatePresfieldN-lcmsms" value="false" checked="checked" class="downloadTemplateForm"> No 
			</label>
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateUploadFile downloadTemplateUploadFile-nmr" style="display: none;">
	<div class="col-lg-8 ">
		<div id="uploadFileNMR" class="form-group" style="">
			<label>Upload file(s) to autofield template: &nbsp;&nbsp;&nbsp;</label>
			<label class="radio-inline">
				<input type="radio" name="downloadTemplatePresfield-nmr" id="downloadTemplatePresfieldY-nmr" value="true" class="downloadTemplateForm"> Yes
			</label>
			<label class="radio-inline"> 
				<input type="radio" name="downloadTemplatePresfield-nmr" id="downloadTemplatePresfieldN-nmr" value="false" checked="checked" class="downloadTemplateForm"> No 
			</label>
		</div>
	</div>
	
	<div class="col-lg-4 ">&nbsp;</div>	
</div>
<div class="col-lg-10 downloadTemplateUploadFile downloadTemplateUploadFile-gcms" style="display: none;">
	<div class="col-lg-8 ">
		<div id="uploadFileGCMS" class="form-group" style="">
			<label>Autofield template with method: &nbsp;&nbsp;&nbsp;</label>
			<label class="radio-inline">
				<input type="radio" name="downloadTemplatePresfield-gcms" id="downloadTemplatePresfieldY-gcms" value="true" class="downloadTemplateForm"> Yes
			</label>
			<label class="radio-inline"> 
				<input type="radio" name="downloadTemplatePresfield-gcms" id="downloadTemplatePresfieldN-gcms" value="false" checked="checked" class="downloadTemplateForm"> No 
			</label>
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateSelectUploadFile downloadTemplateSelectUploadFile-lcms" style="display: none;">
	<div class="col-lg-8 ">
		<div class="form-group input-group">
			<span class="input-group-addon">LC-MS Method</span> 
			<select id="generateFromLCMSmethod" class="form-control downloadTemplateForm">
			</select>
		</div>
		<div id="generatingTemplate-lcms-file" class="generatingTemplate" style="display: none;">
			<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateSelectUploadFile downloadTemplateSelectUploadFile-lcmsms" style="display: none;">
	<div class="col-lg-8 ">
		<div class="form-group input-group">
			<span class="input-group-addon">LC-MSMS Method</span> 
			<select id="generateFromLCMSMSmethod" class="form-control downloadTemplateForm">
			</select>
		</div>
		<div id="generatingTemplate-lcms-file" class="generatingTemplate" style="display: none;">
			<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<div class="col-lg-10 downloadTemplateSelectUploadFile downloadTemplateSelectUploadFile-nmr" style="display: none;">
	<!-- DATA DEVICE -->
	<div class="col-lg-8 ">
		<div id="uploadParamFileNMR" class="form-group" style="">
			<div class="input-group">
				<span class="input-group-btn"> 
					<span class="btn btn-primary btn-file"> Select param. file&#8230; 
						<input id="uploadParamFileNMR_file" type="file" multiple="" accept="">
					</span>
				</span>
				<input id="uploadMetadataFileNMR_display" type="text" class="form-control" readonly="" placeholder="acqu-acetate">
			</div>
		</div>
	</div>
	<div class="col-lg-4 ">
		<div id="generatingTemplate-nmr-device" class="" style="display: none;">
			<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
		</div>
	</div>
	<!-- end device -->
	<div class="col-lg-10 "></div>
	<!-- DATA SPECTRUM -->
	<div class="col-lg-8 ">
		<div id="uploadSpectrumFileNMR" class="form-group" style="">
			<div class="input-group">
				<span class="input-group-btn"> 
					<span class="btn btn-primary btn-file"> Select data file&#8230; 
						<input id="uploadSpectrumFileNMR_file" type="file" multiple="" accept=".xml" >
					</span>
				</span>
				<input id="uploadSpectrumFileNMR_display" type="text" class="form-control" readonly="" placeholder="peaklist-acetate.xml">
			</div>
		</div>
	</div>
	<div class="col-lg-4 ">
		<div id="generatingTemplate-nmr-peaks" class="" style="display: none;">
			<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
		</div>
	</div>
	<!-- end data -->
	<div class="col-lg-10 "></div>
	<!-- DATA SPECTRUM -->
	<div class="col-lg-3 ">
		<button id="btnDumpNMRdataInXLSMfile" type="button" class="btn btn-primary" onclick="dumpNMRTemplateFromUploadedFiles();">Dump data in file</button>
	</div>
<!-- 	<div class="col-lg-9 "> -->
<!-- 		<div id="generatingTemplate-nmr-file" class="" style=""> -->
<%-- 			<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" /> --%>
<!-- 		</div> -->
<!-- 	</div> -->
</div>
<div class="col-lg-10 downloadTemplateSelectUploadFile downloadTemplateSelectUploadFile-gcms" style="display: none;">
	<div class="col-lg-8 ">
		<div class="form-group input-group">
			<span class="input-group-addon">GC-MS Method</span> 
			<select id="generateFromGCMSmethod" class="form-control downloadTemplateForm">
			</select>
		</div>
		<div id="generatingTemplate-gcms-file" class="generatingTemplate" style="display: none;">
			<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<div id="generatingTemplate-empty" class="col-lg-10 generatingTemplate" style="display: none;">
	<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
</div>
<div class="col-lg-10 downloadTemplateDownloadFile" style="display: none;">
	<div class="col-lg-8 ">
		<div id="alertBoxDumpTemplate"></div>
		<div class="form-group input-group">
			<a href="." target="_blank" class="">.</a>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<button id="btnDumpReset" type="button" class="btn btn-danger btn-xs " onclick="resetAllDumperForms();">Reset</button>
		</div>
	</div>
	<div class="col-lg-4 ">&nbsp;</div>
</div>
<!-- template zone:end -->

	</div>
</div>

<script type="text/javascript">
var _alert_unablePresFieldData = '<div class="alert alert-danger alert-dismissible" role="alert">';
_alert_unablePresFieldData += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
_alert_unablePresFieldData += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> unable to load pre-filled data!';
_alert_unablePresFieldData += ' </div>';
var SAMPLE_TYPE_CHEMICAL_COMPOUND_LIBRARY = '<%= PeakForestDataMapper.SAMPLE_TYPE_CHEMICAL_COMPOUND_LIBRARY %>';
var SAMPLE_TYPE_CHEMICAL_COMPOUND_MIX = '<%= PeakForestDataMapper.SAMPLE_TYPE_CHEMICAL_COMPOUND_MIX %>';
var SAMPLE_TYPE_STANDARDIZED_MATRIX = '<%= PeakForestDataMapper.SAMPLE_TYPE_STANDARDIZED_MATRIX %>';
var SAMPLE_TYPE_ANALYTICAL_MATRIX = '<%= PeakForestDataMapper.SAMPLE_TYPE_ANALYTICAL_MATRIX %>';
</script>
<div class="modal " id="modalListOntologies" tabindex="-1" role="dialog" aria-labelledby="modalListOntologiesLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalListOntologiesLabel">
					<span id="ontologies_topPeakForest" class="ontologies_modalTitle">PeakForest's favourite analytical matrix</span>
					<span id="ontologies_allPeakForest" class="ontologies_modalTitle">All PeakForest's analytical matrix</span>
				</h4>
			</div>
			<div class="modal-body">
				<div id="ontologies_loading">
					<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
				</div>
				<div id="ontologies_show">
					<!-- -->
					<div class="table-responsive">
						<table class="table table-hover tablesorter table-search">
							<thead>
								<tr>
									<th>Name</th>
									<th>spectra nb</th>
									<th>Fav.</th>
								</tr>
							</thead>
							<tbody id="ontologies_tbody">
							</tbody>
							<tfoot>
								<tr>
									<td colspan="3">
										Note: contact an administrator if you want an analytical matrix added as favourite.
									</td>
								</tr>
							</tfoot>
						</table>
					</div>
					<!-- -->
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<script  type="text/x-jquery-tmpl" id="templateListOntologies">
<tr>
	<td class="ontologiesHTML">{%= html%}</td>
	<td>{%= countSpectra%}</td>
	<td>
		{%if isFav%}
			<a class="btn btn-xs btn-success">
				<i class="fa fa-star"></i>
			</a>
		{%else%}
			<a class="btn btn-xs btn-danger">
				<i class="fa fa-star"></i>
			</a>
		{%/if%}
	</td>
</tr>
</script>
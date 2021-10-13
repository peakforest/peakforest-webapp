<%@page import="fr.metabohub.peakforest.utils.PeakForestManagerException"%>
<%@page import="fr.metabohub.spectralibraries.utils.SpectralIOException"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<c:if test="${success}">
	<div id="importTabResults" style=""	class="table-responsive uploadSpectraLibDone">
		<table
			class="table table-bordered table-hover table-striped tablesorter">
			<thead>
				<tr>
					<th>Status <i class="fa fa-sort"></i></th>
					<th>number <i class="fa fa-sort"></i></th>
					<th>% <i class="fa fa-sort"></i></th>
				</tr>
			</thead>
			<tbody>
				<tr class="success">
					<td>New</td>
					<td id="newSpectraInt">${newSpectra}</td>
					<td id="newSpectraPerCent">${newSpectraPerCent}</td>
				</tr>
				<c:if test="${errorSpectra > 0}">
					<tr class="danger">
						<td>
<!-- 							<a href="#" id="createListFailedXlsmFile" onclick="createChemicalLibFailXlsmFile()">Click to generate errors file</a> -->
<%-- 							<input type="hidden" id="listFailed" value="${errorNames}"> --%>
<%-- 							<input type="hidden" id="fileSource" value="${tmpFileName}"> --%>
<%-- 							<span id="generatingListFailedXlsmFile" style="display: none"><img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" /></span> --%>
<!-- 							<a id="downloadListFailedXlsmFile" style="display: none" -->
<!-- 								href="" target="_BLANK">Failed</a> -->
							Failed
						</td>
						<td>${errorSpectra}</td>
						<td id="errorSpectraPerCent">${errorSpectraPerCent}</td>
					</tr>
				</c:if>
			</tbody>
		</table>
		<c:if test="${newSpectra > 0}">
		<hr />
		<a class="btn btn-success" href="show-spectra-modal/${idsALLspectra}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-eye"></i> View spectrum</a>
		<script type="text/javascript">
			// init var
			var listSpectraNMRids = '${idsNMRspectra}';
			var listSpectraLCMSids = ${idsLCMSspectra};
			var listSpectraLCMSMSids = ${idsLCMSMSspectra};
			var listSpectraGCMSids = ${idsGCMSspectra};
			// new 2.3
			var listSpectraICMSids = ${idsICMSspectra};
			var listSpectraICMSMSids = ${idsICMSMSspectra};
		</script>
		</c:if>
	</div>
</c:if>

<c:if test="${not success}">
	<div id="importTabResults" class="uploadSpectraLibDone"></div>  
	
	<script type="text/javascript">
		var error = "${error}";
		var spectralIOerror = "${spectralIOerror}";
		
		var errorBox = "";
		
		if (error == "no_file_selected") {
			errorBox = '<div class="alert alert-info alert-dismissible" role="alert">';
			errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> No file selected! ';
			errorBox += ' </div>';
		} else if (error == "<%=PeakForestManagerException.COMPOUND_NOT_IN_DATABASE %>") {
			errorBox = '<div class="alert alert-info alert-dismissible" role="alert">';
			errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> Compound not in database! <a href="home?page=add-compounds&inchikey=${inchikey}">Click here to add it.</a>';
			errorBox += ' </div>';
		} else if (spectralIOerror != "") {
				try {
				var tabSplit = spectralIOerror.split("___");
				var errorType = tabSplit[0];
				var errorValue = tabSplit[1];
				if (errorType == "<%=SpectralIOException.TEMPLATE_VERSION_DEPRECATED %>".replace("___", "")) {
					errorBox = '<div class="alert alert-danger alert-dismissible" role="alert">';
					errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> Template version not recognized: ' + errorValue;
					errorBox += ' </div>';
				} else if (errorType == "<%=SpectralIOException.TEMPLATE_TYPE_UNRECOGNIZED %>".replace("___", "")) {
					errorBox = '<div class="alert alert-danger alert-dismissible" role="alert">';
					errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> Template type not recognized: ' + errorValue;
					errorBox += ' </div>';
				} else if (errorType == "<%=SpectralIOException.MISSING_DATA %>".replace("___", "")) {
					if (errorValue == "sample type")
						errorValue = "sample type";
					else if (errorValue.toLowerCase().indexOf("null_ri") >= 0)
						errorValue = "peak in peaklist with NULL relative intensity";
					errorBox = '<div class="alert alert-danger alert-dismissible" role="alert">';
					errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> Missing data: ' + errorValue;
					errorBox += ' </div>';
				}  //
			} catch (e) {
				console.log(e);
			}
		} else if (error != "" && error.indexOf("|") > -1) {
			errorBox = '<div class="alert alert-info alert-dismissible" role="alert">';
			errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> <br> ' + error.replace("|", "<br>");
			errorBox += ' </div>';
		} 
		
		document.getElementById("importTabResults").innerHTML = (errorBox);
		
		
	</script>
</c:if>




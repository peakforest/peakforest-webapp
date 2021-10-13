<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<c:if test="${success}">
	<div id="importTabResults" style=""
		class="table-responsive uploadChemLibDone">
		<table
			class="table table-bordered table-hover table-striped tablesorter">
			<thead>
				<tr>
					<th>Status <i class="fa fa-sort"></i></th>
					<th>number compound(s)<i class="fa fa-sort"></i></th>
					<th>% <i class="fa fa-sort"></i></th>
					<th>lines <i class="fa fa-sort"></i></th>
				</tr>
			</thead>
			<tbody>
				<tr class="success">
					<td>New</td>
					<td>${newCompounds}</td>
					<td id="newCompoundsPerCent">${newCompoundsPerCent}</td>
					<td>${lineNew} / ${lineTotal}</td>
				</tr>
				<tr class="warning">
					<td>Merged</td>
					<td>${mergedCompounds}</td>
					<td id="mergedCompoundsPerCent">${mergedCompoundsPerCent}</td>
					<td>${lineMerge} / ${lineTotal}</td>
				</tr>
				<c:if test="${errorCompounds > 0}">
					<tr class="danger">
						<td>
							<a href="#" id="createListFailedXlsFile" onclick="createChemicalLibFailXlsFile()">Click to generate errors file</a>
							<input type="hidden" id="listFailed" value="${errorRows}">
							<input type="hidden" id="fileSource" value="${tmpFileName}">
							<span id="generatingListFailedXlsFile" style="display: none"><img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" /></span>
							<a id="downloadListFailedXlsFile" style="display: none"
								href="" target="_BLANK">Failed</a>
						</td>
						<td>${errorCompounds}</td>
						<td id="errorCompoundsPerCent">${errorCompoundsPerCent}</td>
						<td>${lineError} / ${lineTotal}</td>
					</tr>
				</c:if>
			</tbody>
		</table>
	</div>
</c:if>

<c:if test="${not success}">
	<div id="importTabResults" class="uploadChemLibDone">${error}</div>  
	<script type="text/javascript">
	var strError = "${error}";
	if (strError == "no_file_selected") {
		var errorBox = '<div class="alert alert-danger alert-dismissible" role="alert" style="max-width: 350px;">';
		errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> No file selected!';
		errorBox += ' </div>';
		document.getElementById("importTabResults").innerHTML = (errorBox);
	} else if (strError == "server_too_busy") {
		var errorBox = '<div class="alert alert-danger alert-dismissible" role="alert" style="max-width: 350px;">';
		errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
		errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> Server is too busy; please try again in a few seconds.';
		errorBox += ' </div>';
		document.getElementById("importTabResults").innerHTML = (errorBox);
	}
	</script>		
</c:if>
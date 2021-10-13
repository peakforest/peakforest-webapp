<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>${compoundNames.get(0).name}</title>

<!--    <script type='text/javascript' src='/js/lib/dummy.js'></script>
    <link rel="stylesheet" type="text/css" href="/css/normalize.css">
    <link rel="stylesheet" type="text/css" href="/css/result-light.css">-->


<style type='text/css'>
</style>
<script type='text/javascript'>
	//<![CDATA[ 

	printDivCSS = new String('<link href="resources/css/bootstrap.min.css" rel="stylesheet">');
	function printDiv(divId) {
		window.frames["print_frame"].document.body.innerHTML = printDivCSS + document.getElementById(divId).innerHTML;
		window.frames["print_frame"].window.focus();
		setTimeout(function(){
			window.frames["print_frame"].window.print();
		}, 250);
	}
	//]]>
</script>


</head>
<body>
	<div class="modal-dialog">
		<div class="modal-content ">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" onclick="checkIfReOpenDetailsModal();"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title"><spring:message code="modal.print.title" text="Print" /> - ${compoundNames.get(0).name}</h4>
			</div>
			<div class="modal-body" id="printContent">
				<div class="te">
					<table class="" style="width: 100%">
						<tbody>
							<tr>
								<td style="width: 50%">
									<div class=" panel">
										<div class="panel-body">
											<ul class="list-group">
												<%
												int count = 0;	
												request.setAttribute("count", count);
												%>
												<c:forEach var="compoundName" items="${compoundNames}">
												<c:if test="${count <= 3}">
													<li class="list-group-item" >
														<span class="badge">${compoundName.score}</span> 
														<span style="white-space: nowrap;">${compoundName.name}</span>
													</li>
												<%
												count++;
												request.setAttribute("count", count++); %>
												</c:if>
												</c:forEach>
											</ul>
										</div>
									</div>
								</td>
								<td style="width: 50%">
									<div class=" panel">
										<!--	    <div class="panel-header">Structure</div>-->
										<div class="panel-body">
											<img src="image/${type}/${inchikey}.svg" alt="${name_rank1}"
												height="150" width="150">
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<div class=" panel">
										<!--	    <div class="panel-header">Info</div>-->
										<div class="panel-body">
											<table class="table">
												<tbody>
													<tr>
														<td><spring:message code="modal.show.basicInfos.peakForestID" text="PeakForest ID" /></td>
														<td>${pfID}</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.basicInfos.monoisotopicMass" text="Monoisotopic Mass" /></td>
														<td>${exactMass}</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.basicInfos.averageMass" text="Average Mass" /></td>
														<td>${molWeight}</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.basicInfos.formula" text="Formula" /></td>
														<td>${formula}</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.structure.cansmiles" text="Canonical smiles" /></td>
														<%
															String smilesAlert = "";
															if (request.getAttribute("smiles").toString().length() > 65) {
																smilesAlert = "onclick=\"alert('" + request.getAttribute("smiles") + "')\"";
															}
														%>
														<td class="smiles" <%=smilesAlert %>>${smiles}</td>
													</tr>
													<c:if test="${not empty iupacName}">
														<tr>
															<td><spring:message code="modal.show.basicInfos.iupac.simple" text="IUPAC" /></td>
															<td>${iupacName}</td>
														</tr>
													</c:if>
												</tbody>
											</table>
										</div>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal"
					onclick="checkIfReOpenDetailsModal();"><spring:message code="modal.close" text="Close" /></button>
				<button type="button" class="btn btn-primary"
					onclick="printDiv('printContent')">
					<i class="fa fa-print"></i> <spring:message code="modal.show.btn.print" text="Print" />
				</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->

	<iframe name=print_frame width=0 height=0 seamless src=about:blank></iframe>
</body>
</html>
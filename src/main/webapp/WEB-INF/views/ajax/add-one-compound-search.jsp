<%@page import="fr.metabohub.peakforest.model.compound.Compound"%>
<%@page import="fr.metabohub.peakforest.utils.PeakForestManagerException"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<c:if test="${success}">
	<div class="table-responsive">
		<table class="table table-bordered table-hover table-striped tablesorter" style="cursor: pointer;">
			<thead>
				<tr>
					<th class="header">Chemical Name <i class="fa fa-sort"></i></th>
					<th class="header">Monoisotopic Mass <i class="fa fa-sort"></i></th>
					<!-- 		  <th class="header">Mol weight <i class="fa fa-sort"></i></th> -->
					<th class="header">Formula <i class="fa fa-sort"></i></th>
					<th class="header" style="">Structure</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="compound" items="${compounds}">
				<tr class="success selectCC-step2" onclick="loadCompoundDetails(${compound.id}, ${compound.type});">
					<td style="vertical-align: middle;">
						${compound.listOfCompoundNames.get(0).name}
					</td>
					<td style="vertical-align: middle;" class="compoundMass">${compound.exactMass}</td>
					<!-- 		  <td>194.1906</td> -->
					<td style="vertical-align: middle;" class="compoundFormula">${compound.formula}</td>
					<td><span class="avatar">
						<c:if test="${compound.type == 101}">
						<img class="compoundSVG" src="image/chemical/${compound.inChIKey}.svg" alt="${compound.listOfCompoundNames.get(0).name}" />
						</c:if>
						<c:if test="${compound.type == 100}">
						<img class="compoundSVG" src="image/generic/${compound.inChIKey}.svg" alt="${compound.listOfCompoundNames.get(0).name}" />
						</c:if>
						</span></td>
				</tr>
				</c:forEach>
			</tbody>
		</table>

		If your compound is not listed above, run a
		<button type="submit" id="deepSearchBtn" class="btn btn-default" onclick="deepSearch()">
			Deep search <i class="fa fa-search"></i>
		</button>

<script type="text/javascript">
$.each($(".compoundFormula"), function(id, elem) {
	var rawFromula = $(elem).text();
	var formatedFormula = rawFromula;
	try {
	$.each($.unique( rawFromula.match(/\d/g)), function (keyF, valF) {
		var re = new RegExp(valF,"g");
		formatedFormula = formatedFormula.replace(re, "<sub>" + valF + "</sub>");
	});
	} catch (e){}
	formatedFormula = formatedFormula.replace("</sub><sub>", "");
	$(elem).html(formatedFormula);
});
$.each($(".compoundMass"), function(id, elem) {
	var exactMass = parseFloat( $(elem).text());
	exactMass = roundNumber(exactMass,7)
	$(elem).html(exactMass);
});
</script>

	</div>
	<!--div .table-responsive-->
</c:if>

<c:if test="${not success}">
	<%
	if (request.getAttribute("error").equals(PeakForestManagerException.NO_RESULTS_MATCHED_THE_QUERY)) {
		%>
		
		Sorry, no results matched your query; try to run a
		<button type="submit" id="deepSearchBtn" class="btn btn-default" onclick="deepSearch()">
			Deep search <i class="fa fa-search"></i>
		</button>
		
		<%
	} else if (request.getAttribute("error").equals(PeakForestManagerException.DOUBLE_EXPECTED)) {
		%>
		Please enter a correct value (e.g.: "123.456").
		<%
	}
	%>
</c:if>

	<br />
	<br />
	<div id="deepSearchMessage"></div>
	<div id="deepSearchTabResults" class="table-responsive" style="display: none;">
		<table class="table table-bordered table-hover table-striped tablesorter" style="cursor: pointer;">
			<thead>
				<tr>
					<th class="header">Chemical Names <i class="fa fa-sort"></i></th>
					<th class="header" style="white-space: nowrap;">Monoisotopic Mass <i class="fa fa-sort"></i></th>
					<th class="header" style="white-space: nowrap;">Average Mass <i class="fa fa-sort"></i></th>
					<th class="header" style="white-space: nowrap;">Formula <i class="fa fa-sort"></i></th>
				</tr>
			</thead>
			<tbody id="deepSearchTableBody">
			</tbody>
		</table>
	</div>

<script  type="text/x-jquery-tmpl" id="deepSearchTemplate">
<tr onclick="loadNewCompound({%= id %});" id="new-ref-cpd-{%= id %}" class="warning">
	<td>{%= namesL %}</td>
	<td class="compoundMass">{%= monoisotopicMass %}</td>
	<td class="compoundMass">{%= averageMass %}</td>
	<td class="compoundFormula">{%= formula %}</td>
</tr>
</script>

<script type="text/javascript">
var listOfRefCompoundsMatch = null;

loadNewCompound = function (id) {
	var compound = listOfRefCompoundsMatch[id];
// 	console.log(compound);
	$.ajax({ 
		type: "post",
		url: "add-one-compound-from-ext-db",
// 		dataType: "json",
		data: JSON.stringify(compound),
		contentType: 'application/json',
		async: true,
// 		data: "compound=" + compound,
		success: function(data) {
			if (data.id!=-1) {
				loadCompoundDetails(data.id, data.type);
			} else {
				var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> Could not add compound.';
				alert += ' </div>';
				$("#deepSearchMessage").html(alert);
			}
		},
		error : function(xhr) {
			// log
			console.log(xhr);
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Could not add compound.';
			alert += ' </div>';
			$("#deepSearchMessage").html(alert);
		}
	});
}

deepSearch = function () {
	$("#deepSearchBtn").prop('disabled', true);
	$("#deepSearchMessage").html('<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />');
	$.ajax({ 
		type: "post",
		url: "add-one-compound-search-ext-db",
		dataType: "json",
		async: true,
		data: "query=" + $('#add-one-cc-s1-value').val() + "&filter=" +$("#add-one-cc-s1-type").val(),
		success: function(json) {
			listOfRefCompoundsMatch = json;
			if (json.length!=0) {
				$("#deepSearchMessage").html("");
				$.each(listOfRefCompoundsMatch, function (k,v) {
					v.id = k;
					v.namesL = [];
					$.each(v.names, function(kt,vt){
						v.namesL.push(vt.name);
					});
				});
				$("#deepSearchTemplate").tmpl(listOfRefCompoundsMatch).appendTo("#deepSearchTableBody");
				$.each($(".compoundFormula"), function(id, elem) {
					var rawFromula = $(elem).text();
					var formatedFormula = rawFromula;
					try {
					$.each($.unique( rawFromula.match(/\d/g)), function (keyF, valF) {
						var re = new RegExp(valF,"g");
						formatedFormula = formatedFormula.replace(re, "<sub>" + valF + "</sub>");
					});
					} catch (e){}
					formatedFormula = formatedFormula.replace("</sub><sub>", "");
					$(elem).html(formatedFormula);
				});
				$.each($(".compoundMass"), function(id, elem) {
					var exactMass = parseFloat( $(elem).text());
					exactMass = roundNumber(exactMass,7)
					$(elem).html(exactMass);
				});
				$("#deepSearchTabResults").show();
			} else {
				// alert
				var alert = '<div class="alert alert-warning alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> No compound matched your query.';
				alert += ' </div>';
				$("#deepSearchMessage").html(alert);
			}
		},
		error : function(xhr) {
			// log
			console.log(xhr);
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Could not process request.';
			alert += ' </div>';
			$("#deepSearchMessage").html(alert);
		}
	});
}
</script>
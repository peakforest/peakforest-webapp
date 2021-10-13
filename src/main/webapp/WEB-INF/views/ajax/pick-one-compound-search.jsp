<%@page import="fr.metabohub.peakforest.model.compound.Compound"%>
<%@page import="fr.metabohub.peakforest.utils.PeakForestManagerException"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<c:if test="${success}">
	<div class="table-responsive">
		<table id="tabPickCpd" class="table table-bordered table-hover table-striped tablesorter" style="cursor: pointer;">
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
				<tr class="success" onclick="loadCompoundInForm(${compound.id}, '${compound.inChIKey}', '${compound.inChI}', '${compound.formula}', '${compound.exactMass}' , ${compound.type});">
					<td style="vertical-align: middle;" >
						<span id="cpt-load-name-${compound.id}">${compound.listOfCompoundNames.get(0).name}</span> 
						<c:if test="${compound.type == 100 && compound.hasChild()}">&nbsp;<sup><b>*</b></sup></c:if>
						<br /><small style="white-space: nowrap;">${compound.inChIKey}</small>
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
						</span>
					</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>


	<small><sup><b>*</b></sup>: Generic Compounds (abstract "flat" compound without (+) or (-) center).</small>

<script type="text/javascript">

$("#tabPickCpd").tablesorter();

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
		Sorry, no results matched your query; <a href="home?page=add-compounds">Add your compound into this database?</a>
		<%
	} 
	%>
</c:if>


<script type="text/javascript">
var listOfRefCompoundsMatch = null;

loadCompoundInForm = function (id, inchikey, inchi, composition, exactMass, type) {
	if (modeEditSpectrum) {
		var name = $("#cpt-load-name-" + id).html();
		if (multiPickLine >= 0) {
			hot_RCC_ADDED.setDataAtCell(multiPickLine, 0, name);
			// hot_RCC_ADDED.setDataAtCell(multiPickLine, 1, inchikey);

			// restet form
			setTimeout(function(){
				$("#add-one-cc-s1-value").val("");
				$("#ok-step-1").html("");
			}, 200);
			// img
			var typeS = "chemical";
			if (type == 100)
				typeS = "generic";
			else if (type == 101)
				typeS = "chemical";
			// '<img class="mixRCCadd'+multiPickLine+' compoundSVGZoom" src="image/'+typeS+'/'+inchikey+'.svg" alt="'+name+'">'
			var currentCpt = { 
					"name": name,
					"type": typeS,
					"concentration": "?",
					"inchikey": inchikey
			}; 
			updatedCpdMixData[name] = currentCpt;
		}
		// display
		$("#modalPickCompound").modal("hide");
		$("#modalEditSpectrum .modal-dialog").show();
		return;
	} // else: add one spectrum
	var name = $("#cpt-load-name-" + id).html();
	if (singlePick) {
		$("#add1spectrum-sample-inchikey").val(inchikey);
		$("#add1spectrum-sample-inchikey").change();
		$("#add1spectrum-sample-inchi").val(inchi);
		$("#add1spectrum-sample-inchi").change();
		$("#add1spectrum-sample-commonName").val(name);
		$("#add1spectrum-sample-commonName").change();	

		$("#importspectrum-sample-inchikey").val(inchikey);
		$("#importspectrum-sample-inchikey").change();
	} else if (multiPickLine >= 0) {
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 0, name);
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 1, inchikey);
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 2, composition);
		hot_RCC_ADDED.setDataAtCell(multiPickLine, 4, exactMass);
		// restet form
		setTimeout(function(){
			$("#add-one-cc-s1-value").val("");
			$("#ok-step-1").html("");
		}, 200);
	}
	var typeS = "chemical";
	if (type == 100)
		typeS = "generic";
	else if (type == 101)
		typeS = "chemical";
	if (singlePick)
		$("#sample-bonus-display").html('<img class="" src="image/'+typeS+'/'+inchikey+'.svg" alt="'+name+'">');
	else {
		// delete
		$("img.mixRCCadd"+multiPickLine).remove();
		// add
		$("#sample-bonus-display").append('<img class="mixRCCadd'+multiPickLine+' compoundSVGZoom" src="image/'+typeS+'/'+inchikey+'.svg" alt="'+name+'">');
		$("img.mixRCCadd"+multiPickLine+"").mouseenter(function() {
			$(this).removeClass("compoundSVGZoom");
		}).mouseleave(function() {
			$(this).addClass("compoundSVGZoom");
		});
	}
	$("#modalPickCompound").modal("hide");
}
</script>
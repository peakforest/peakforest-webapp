<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>

<c:if test="${mol_ready}">
<script type='text/javascript'>
	//<![CDATA[ 
	
	var glmol<%=randomID %> = '';
	var glmol<%=randomID %>2 = '';
	///////////////////
	function saveImage(glmolElem) {
		glmolElem.show();
		var imageURI = glmolElem.renderer.domElement.toDataURL("image/png");
		window.open(imageURI);
	}
	
	function reload(glmolElem) {
		glmolElem.defineRepresentation = defineRepFromController<%=randomID %>;
		glmolElem.rebuildScene();
		glmolElem.show();
	};
	
	function defineRepFromController<%=randomID %>() {
		var idHeader = "#" + this.id + '_';
		var all = this.getAllAtoms();
		var allHet = this.getHetatms(all);
		var hetatm = this.removeSolvents(allHet);
		var asu = new THREE.Object3D();
		var target = this.modelGroup;
		var hetatmMode = $(idHeader + 'hetatm').val();
		if (hetatmMode == 'stick') {
			this.drawBondsAsStick(target, hetatm, this.cylinderRadius, this.cylinderRadius, true);
		} else if (hetatmMode == 'sphere') {
			this.drawAtomsAsSphere(target, hetatm, this.sphereRadius);
		} else if (hetatmMode == 'line') {
			this.drawBondsAsLine(target, hetatm, this.curveWidth);
		} else if (hetatmMode == 'icosahedron') {
			this.drawAtomsAsIcosahedron(target, hetatm, this.sphereRadius);
		 } else if (hetatmMode == 'ballAndStick') {
			this.drawBondsAsStick(target, hetatm, this.cylinderRadius / 2.0, this.cylinderRadius, true, false, 0.3);
		 } else if (hetatmMode == 'ballAndStick2') {
			this.drawBondsAsStick(target, hetatm, this.cylinderRadius / 2.0, this.cylinderRadius, true, true, 0.3);
		 } 
	};
	///////////////////
	
	initLoadGLmol1 = function() {
		if (glmol<%=randomID %> !== '') { return false; }
		try {
			glmol<%=randomID %> = new GLmol('glmol<%=randomID %>');
			setTimeout(function(){reload(glmol<%=randomID %>)}, 1000);
		} catch (e) {
		}
		return true;
	};
	
	initLoadGLmol2 = function() {
		if (glmol<%=randomID %>2 !== '') { return false; }
		try {
			glmol<%=randomID %>2 = new GLmol('glmol<%=randomID %>2');
			setTimeout(function(){reload(glmol<%=randomID %>2)}, 1000);
		} catch (e) {
		}
		return true;
	};
	//]]>
</script>
</c:if>

	<div class="" style="">
		<div class="">
<!-- 			<div class=""> -->
<!-- 				<button type="button" class="close" onclick="closeCompoundEntity()" aria-hidden="true">&times;</button> -->
<%-- 				<h4 class="modal-title">${compoundNames.get(0).name}</h4> --%>
<!-- 			</div> -->
			<div id="entityBody" class=" ">
				<div class="te">
					<form class="form-horizontal" onsubmit="return false;" autocomplete="off">
						<fieldset>
							<!--  ++++++++++++++++++++++++++++ start mol. card -->
							<div class="panel-group" >
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.basicInfos" text="Basic infos" /> <i class="fa fa-info-circle"></i>
										</h4>
									</div>
									<div id="cardSheet1" class="">
												<table class="table">
													<tr>
														<td rowspan="5" style="width: 300px;">
				<c:if test="${mol_ready}">
					<ul class="nav nav-tabs">
						<li class="active">
							<a href="#showMol-2D2" data-toggle="tab">
								<i class="fa fa-square-o"></i> 2D
							</a>
						</li>
						<li>
							<a href="#showMol-3D2" data-toggle="tab" onclick="initLoadGLmol2();">
								<i class="fa fa-cube"></i> 3D
							</a>
						</li>
					</ul>
					<div class="tab-content">
						<div id="showMol-2D2" class="tab-pane fade active in">
							<img class="molStructSVGsmall" src="image/${type}/${inchikey}" alt="${compoundNames.get(0).name}">
						</div>
						<div id="showMol-3D2" class="tab-pane fade">
							<div id="glmol<%=randomID %>2"
									style="width: 350px; height: 200px; background-color: black;"></div>
								<textarea id="glmol<%=randomID %>2_src" style="display: none;">
${mol}</textarea>
<form class="form-inline" onclick="return false;" >
	<div class="form-group input-group" style="margin-bottom: 0px;">
		<span>&nbsp;&nbsp;</span>
		<span class="input-group-addon"><i class="fa fa-eye"></i></span> 
		<select id="glmol<%=randomID %>2_hetatm" style="max-width: 30%;" class="form-control ">
			<option selected="selected" value="stick">sticks</option>
			<option value="ballAndStick">ball and stick</option>
			<option value="ballAndStick2">ball and stick (multiple bond)</option>
			<option value="sphere">spheres</option>
			<option value="icosahedron">icosahedrons</option>
			<option value="line">lines</option>
		</select>
		<button class="btn btn-xs" onclick="reload(glmol<%=randomID %>2)"><i class="fa fa-refresh"></i></button>
		<button class="btn btn-xs" onclick="saveImage(glmol<%=randomID %>2)"><i class="fa fa-save"></i></button>
	</div>
	<spring:message code="addon.glMol.poweredBy" text="<small>powered by <a href='http://webglmol.osdn.jp/index-en.html' target='_blank'>GLmol</a>.</small>" />
</form>
						</div>
					</div>
				</c:if>
				<c:if test="${not mol_ready}">
					<img class="molStructSVGsmall" src="image/${type}/${inchikey}" alt="${compoundNames.get(0).name}">
				</c:if>
														</td>
														<td style="width: 100px;"><spring:message code="modal.show.basicInfos.name" text="Name" /></td>
														<td>
															${compoundNames.get(0).name}
															
															<!-- display stars -->
															<div class="pull-right">
																<c:choose>
																	<c:when test="${nbStarCuration == 0}">
																		<i class="fa fa-star-o"></i>
																		<i class="fa fa-star-o"></i>
																		<i class="fa fa-star-o"></i>
																	</c:when>
																	<c:when test="${nbStarCuration == 1}">
																		<i class="fa fa-star"></i>
																		<i class="fa fa-star-o"></i>
																		<i class="fa fa-star-o"></i>
																	</c:when>
																	<c:when test="${nbStarCuration == 2}">
																		<i class="fa fa-star"></i>
																		<i class="fa fa-star"></i>
																		<i class="fa fa-star-o"></i>
																	</c:when>
																	<c:when test="${nbStarCuration == 3}">
																		<i class="fa fa-star"></i>
																		<i class="fa fa-star"></i>
																		<i class="fa fa-star"></i>
																	</c:when>
																	<c:otherwise>
																		<!-- ??? -->
																	</c:otherwise>
																</c:choose>
															</div>
															<!-- end display stats -->
														</td>
													</tr>
													<tr>
														<td><spring:message code="modal.show.basicInfos.formula" text="Formula" /></td>
														<td>${formula}</td>
													</tr>
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.basicInfos.monoisotopicMass" text="Monoisotopic Mass" /></td>
														<td>${exactMass}</td>
													</tr>
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.basicInfos.averageMass" text="Average Mass" /></td>
														<td>${molWeight}</td>
													</tr>
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.basicInfos.peakForestID" text="PeakForest ID" /></td>
														<td>${pfID}</td>
													</tr>
													<c:if test="${mol_ready}">
													<tr>
														<td><spring:message code="modal.show.basicInfos.download" text="Download" /></td>
														<td class="download-btns">
															<a class="btn btn-primary" href="mol/${inchikey}.mol" title="${compoundNames.get(0).name}" target="_blank">
																<spring:message code="modal.show.basicInfos.mol" text="Mol" /> <i class="fa fa-download"></i>
															</a>
															
															<!-- issue #363 -->
															<a class="btn btn-primary" href="sdf/${inchikey}.sdf" title="${compoundNames.get(0).name}" target="_blank">
																<spring:message code="modal.show.basicInfos.sdf" text="SDF" /> <i class="fa fa-download"></i>
															</a>
														</td>
													</tr>
													</c:if>
												</table>
									</div>
								</div>
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.names" text="Names" /> <i class="fa fa-star-half-o"></i>
										</h4>
									</div>
									<div id="cardSheet2" class="">
<!-- 										<div class="panel-body"> -->
											<!--  ++++++++++++++++++++++++++++ start card 2 -->
<!-- 											<div class="panel panel-default"> -->
												<!--		      <div class="panel-heading">Names</div>-->
												<ul class="list-group" id="cc_listName" style="margin-bottom: 0px;">
													<c:forEach var="compoundName" items="${compoundNames}">
													<li id="compundName_${compoundName.id}" class="list-group-item">
														<span class="badge">${compoundName.score}</span>
														${compoundName.name}
														<span id="compundName_${compoundName.id}_score" class="pull-right">
														<!-- 0 -->
														<i class="vote0">&nbsp;&nbsp;</i>
														<!-- 1 -->
														<c:choose>
														<c:when test="${compoundName.score >= 0.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 1}"><i class="fa fa-star vote1"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote1"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote1"></i>
														</c:otherwise>
														</c:choose>
														<!-- 2 -->
														<c:choose>
														<c:when test="${compoundName.score >= 1.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 2}"><i class="fa fa-star vote2"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote2"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote2"></i>
														</c:otherwise>
														</c:choose>
														<!-- 3 -->
														<c:choose>
														<c:when test="${compoundName.score >= 2.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 3}"><i class="fa fa-star vote3"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote3"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote3"></i>
														</c:otherwise>
														</c:choose>
														<!-- 4 -->
														<c:choose>
														<c:when test="${compoundName.score >= 3.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 4}"><i class="fa fa-star vote4"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote4"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote4"></i>
														</c:otherwise>
														</c:choose>
														<!-- 5 -->
														<c:choose>
														<c:when test="${compoundName.score >= 4.5}">
															<c:choose>
																<c:when test="${compoundName.score >= 5}"><i class="fa fa-star vote5"></i></c:when>
																<c:otherwise><i class="fa fa-star-half-o vote5"></i></c:otherwise>
															</c:choose>
														</c:when>
														<c:otherwise>
															<i class="fa fa-star-o vote5"></i>
														</c:otherwise>
														</c:choose>
															&nbsp;
														</span>
													</li>
													</c:forEach>
<!-- 													<li id="1-3-7-Trimethylxanthine" class="list-group-item"> -->
<!-- 														<span class="badge">4.3</span> 1,3,7-Trimethylxanthine <span -->
<!-- 														class="pull-right"><i class="fa fa-star"></i><i -->
<!-- 															class="fa fa-star"></i><i class="fa fa-star"></i><i -->
<!-- 															class="fa fa-star-o"></i><i class="fa fa-star-o"></i>&nbsp;</span> -->
<!-- 													</li> -->

													<!-- new 2.0 IUPAC NAME -->
													<c:if test="${not empty iupacName}">
														<li class="list-group-item">
															<spring:message code="modal.show.basicInfos.iupac" text="IUPAC:" /> 
															${iupacName}
														</li>
													</c:if>
												
												</ul>
												<c:if test="${editor}">
												<div class="input-group">
													<span class="input-group-addon">
														<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.names.newName" text="new name" /></span>
														<input type="text" id="cc_addNewName" class="form-control" placeholder="<spring:message code="modal.show.names.newName.ph" text="new name..." />">
														<span class="input-group-btn">
															<button class="btn btn-default" type="button" onclick="addNewNameAction();"><i class="fa fa-plus-square"></i></button>
														</span>
<!-- 												</div> -->
<!-- 											</div> -->
<script>
$("#cc_addNewName").keypress(function(event) {
	if (event.keyCode == 13) {
		addNewNameAction();
	}
});
function addNewNameAction() {
	if ($("#cc_addNewName").val()!="") {
		var newName = $.trim($("#cc_addNewName").val());
		var newId =md5(newName);
		if($('#'+newId).length != 0)
			alert('<spring:message code="modal.show.names.alertNameExist" text="ERROR: this name already exists!" />');
		else {
			addNewName(newId, newName);
			$("#cc_addNewName").val("");
		}
	}
}

function addNewName(newId, newName){
	var delB = '<a class="btn btn-danger btn-xs"onclick="deleteName(\''+newId+'\');" href="#"> <i class="fa fa-trash-o fa-lg"></i></a>';
	var e = $("<li id=\""+newId+"\" class=\"list-group-item\"><span class=\"badge\">1.0</span> "+newName+" "+ delB +" <span class=\"pull-right\"><i class=\"fa fa-star\"></i> <i class=\"fa fa-star-o\"></i> <i class=\"fa fa-star-o\"></i> <i class=\"fa fa-star-o\"></i> <i class=\"fa fa-star-o\"></i>&nbsp;</span></li>");
	$("#cc_listName").append(e);
	newCompoundNames[newId] = newName;
}

function deleteName(idName) {
 	$("#"+idName).remove();
 	delete newCompoundNames[idName];
}

function loadStarListener<%=randomID %>(){
	$(".vote0").unbind();
	$(".vote1").unbind();
	$(".vote2").unbind();
	$(".vote3").unbind();
	$(".vote4").unbind();
	$(".vote5").unbind();
	//
	$(".vote0").click(function() {
		var e = $(this).parent();
		var myRegexp = /compundName_(.*?)_score/g;
		var match = myRegexp.exec($(e).attr("id"));
		updateScores[match[1]] = 0;
		$(this).parent().html('<i class="vote0">&nbsp;&nbsp;</i> <i class="fa fa-star-o vote1"></i> <i class="fa fa-star-o vote2"></i> <i class="fa fa-star-o vote3"></i> <i class="fa fa-star-o vote4"></i> <i class="fa fa-star-o vote5"></i>&nbsp; ');
//		 $(this).parent().parent().children('.badge').html("1");
		loadStarListener<%=randomID %>();
	});
	$(".vote1").click(function() {
		var e = $(this).parent();
		var myRegexp = /compundName_(.*?)_score/g;
		var match = myRegexp.exec($(e).attr("id"));
		updateScores[match[1]] = 1;
		$(this).parent().html('<i class="vote0">&nbsp;&nbsp;</i> <i class="fa fa-star vote1"></i> <i class="fa fa-star-o vote2"></i> <i class="fa fa-star-o vote3"></i> <i class="fa fa-star-o vote4"></i> <i class="fa fa-star-o vote5"></i>&nbsp; ');
//		 $(this).parent().parent().children('.badge').html("1");
		loadStarListener<%=randomID %>();
	});
	$(".vote2").click(function() {
		var e = $(this).parent();
		var myRegexp = /compundName_(.*?)_score/g;
		var match = myRegexp.exec($(e).attr("id"));
		updateScores[match[1]] = 2;
		$(this).parent().html('<i class="vote0">&nbsp;&nbsp;</i> <i class="fa fa-star vote1"></i> <i class="fa fa-star vote2"></i> <i class="fa fa-star-o vote3"></i> <i class="fa fa-star-o vote4"></i> <i class="fa fa-star-o vote5"></i>&nbsp; ');
		//$(this).parent().parent().children('.badge').html("2")
		loadStarListener<%=randomID %>();
	});
	$(".vote3").click(function() {
		var e = $(this).parent();
		var myRegexp = /compundName_(.*?)_score/g;
		var match = myRegexp.exec($(e).attr("id"));
		updateScores[match[1]] = 3;
		$(this).parent().html('<i class="vote0">&nbsp;&nbsp;</i> <i class="fa fa-star vote1"></i> <i class="fa fa-star vote2"></i> <i class="fa fa-star vote3"></i> <i class="fa fa-star-o vote4"></i> <i class="fa fa-star-o vote5"></i>&nbsp; ');
//		 $(this).parent().parent().children('.badge').html("3");
		loadStarListener<%=randomID %>();
	});
	$(".vote4").click(function() {
		var e = $(this).parent();
		var myRegexp = /compundName_(.*?)_score/g;
		var match = myRegexp.exec($(e).attr("id"));
		updateScores[match[1]] = 4;
		$(this).parent().html('<i class="vote0">&nbsp;&nbsp;</i> <i class="fa fa-star vote1"></i> <i class="fa fa-star vote2"></i> <i class="fa fa-star vote3"></i> <i class="fa fa-star vote4"></i> <i class="fa fa-star-o vote5"></i>&nbsp; ');
//		 $(this).parent().parent().children('.badge').html("4")
		loadStarListener<%=randomID %>();
	});
	$(".vote5").click(function() {
		var e = $(this).parent();
		var myRegexp = /compundName_(.*?)_score/g;
		var match = myRegexp.exec($(e).attr("id"));
		updateScores[match[1]] = 5;
		$(this).parent().html('<i class="vote0">&nbsp;&nbsp;</i> <i class="fa fa-star vote1"></i> <i class="fa fa-star vote2"></i> <i class="fa fa-star vote3"></i> <i class="fa fa-star vote4"></i> <i class="fa fa-star vote5"></i>&nbsp; ');
//		 $(this).parent().parent().children('.badge').html("5")
		loadStarListener<%=randomID %>();
	});
};

loadStarListener<%=randomID %>();

											</script>
<script src="<c:url value="/resources/js/md5.min.js" />"></script>
											<!--  ++++++++++++++++++++++++++++ end card 2  -->
										</div>
										</c:if>
									</div>
								</div>
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.spectra" text="Spectra" /> <i class="fa fa-bar-chart-o"></i>
										</h4>
									</div>
									<div id="cardSheet4" class="">
										<c:if test="${contains_spectrum}">
											<div id="divCompoundSpectra<%=randomID %>"></div>
											<script type="text/javascript">
												$("#divCompoundSpectra<%=randomID %>").html('<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />');
												$.get("compound-spectra-module/${type}/${id}", function( data ) {
													$("#divCompoundSpectra<%=randomID %>").html( data );
													console.log("spectrum: ready!");
												});
											</script>
										</c:if>
										<c:if test="${not contains_spectrum}">
											<div class="panel-body">
												<spring:message code="modal.show.missingSpectrum" text="No spectrum available. " />
												<c:if test="${editor}">
												<spring:message code="modal.show.textAdd1" text="You can" /> <a href="<c:url value="/home" />?page=add-spectrum&inchikey=${inchikey}"><spring:message code="modal.show.textAdd2" text="add a new one" /></a>.
												</c:if>
											</div>
										</c:if>
									</div>
								</div>
								
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.structure" text="Structure" /> <i class="fa fa-eye"></i>
										</h4>
									</div>
									<div id="cardSheet" class="">
<!-- 										<div class="panel-body"> -->
											<!--  ++++++++++++++++++++++++++++ start card 3  -->
<!-- 											<div class="panel panel-default"> -->
												<!--<div class="panel-heading">structure</div>-->
												<!-- *************************************************************************** -->
												<ul class="nav nav-tabs">
													<li class="active">
														<a href="#showMol-2D" data-toggle="tab">
															<i class="fa fa-square-o"></i> 2D
														</a>
													</li>
<c:if test="${mol_ready}">
													<li>
														<a href="#showMol-3D" data-toggle="tab" onclick="initLoadGLmol1();">
															<i class="fa fa-cube"></i> 3D
														</a>
													</li>
</c:if>
													<li>
<!-- 														<a href="#showMol-numbered" onclick="refreshJSmol();" data-toggle="tab"> -->
<!-- 															<i class="fa fa-cube"></i> Nb<i class="fa fa-sort-numeric-desc"></i> -->
<!-- 														</a> -->
<!-- 													</li> -->
<c:if test="${mol_nb_3D_exists || mol_nb_2D_exists || editor}">
													<li role="presentation" class="dropdown">
														<a href="#" id="myTabDrop1" class="dropdown-toggle" data-toggle="dropdown" aria-controls="myTabDrop1-contents" aria-expanded="false">
															<i class="fa fa-sort-numeric-desc"></i> Nb <span class="caret"></span>
														</a>
														<ul class="dropdown-menu" aria-labelledby="myTabDrop1" id="myTabDrop1-contents" style="z-index: 1000000000;">
<c:if test="${mol_nb_3D_exists}">
															<li>
																<a href="#showMol-3D-numbered" onclick="refreshJSmol();" role="tab" id="dropdown1-tab" data-toggle="tab" aria-controls="showMol-3D-numbered" aria-expanded="false">
																	<i class="fa fa-cube"></i> Nb <i class="fa fa-sort-numeric-desc"></i>
																</a>
															</li>
</c:if>
<c:if test="${mol_nb_2D_exists}">
															<li>
																<a href="#showMol-2D-numbered" role="tab" data-toggle="tab" aria-controls="showMol-2D-numbered" aria-expanded="true">
																	<i class="fa fa-square-o"></i> Nb <i class="fa fa-sort-numeric-desc"></i>
																</a>
															</li>
</c:if>
<c:if test="${editor}">
															<li>
																<a href="#showMol-upload-numbered" role="tab" data-toggle="tab" aria-controls="showMol-upload-numbered" aria-expanded="true">
																	<i class="fa fa-upload"></i> Nb <i class="fa fa-sort-numeric-desc"></i>
																</a>
															</li>
</c:if>
														</ul>
													</li>
</c:if>
<c:if test="${editor}">
													<li>
														<a href="#showMol-upload" role="tab"  data-toggle="tab" aria-controls="showMol-upload" aria-expanded="true">
															<i class="fa fa-upload"></i> Update Structure
														</a>
													</li>
</c:if>
												</ul>
												<div class="tab-content">
													<div id="showMol-2D" class="tab-pane fade active in">
														<img class="molStructSVG" src="image/${type}/${inchikey}" alt="${compoundNames.get(0).name}">
													</div>
<c:if test="${mol_ready}">
													<div id="showMol-3D" class="tab-pane fade">
														<div id="glmol<%=randomID %>" class="molGL"></div>
			<%-- 												${mol} --%>
															<textarea id="glmol<%=randomID %>_src" style="display: none;">
${mol}</textarea>

<div class="form-group input-group" style="max-width: 500px; margin-bottom: 0px;">
	<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>
	<span class="input-group-addon" style="width: 20px;"><i class="fa fa-eye"></i></span> 
	<select id="glmol<%=randomID %>_hetatm" style="max-width: 150px;" class="form-control ">
		<option selected="selected" value="stick">sticks</option>
		<option value="ballAndStick">ball and stick</option>
		<option value="ballAndStick2">ball and stick (multiple bond)</option>
		<option value="sphere">spheres</option>
		<option value="icosahedron">icosahedrons</option>
		<option value="line">lines</option>
	</select>
	<button class="btn btn-xs" onclick="reload(glmol<%=randomID %>)"><i class="fa fa-refresh"></i></button>
	<button class="btn btn-xs" onclick="saveImage(glmol<%=randomID %>)"><i class="fa fa-save"></i></button>
</div>
<spring:message code="addon.glMol.poweredBy" text="<small>powered by <a href='http://webglmol.osdn.jp/index-en.html' target='_blank'>GLmol</a>.</small>" />
													</div>
</c:if>
<c:if test="${mol_nb_3D_exists}">
													<!-- if mol 3D -->
													<div id="showMol-3D-numbered" class="tab-pane fade">
														<div id="jsmol" height="520" width="820"  style="border-width: inherit;">loading...</div>
													</div>
</c:if>
<c:if test="${mol_nb_2D_exists}">
													<!-- if svg / png / jpeg -->
													<div id="showMol-2D-numbered" class="tab-pane fade">
														<img class="molStructSVG" src="numbered/${inchikey}.${mol_nb_2D_ext}" alt="${compoundNames.get(0).name}">
													</div>
</c:if>
<c:if test="${editor}">
													<!-- upload new image (numbered) -->
													<div id="showMol-upload-numbered" class="tab-pane fade">
														
															<div class="col-lg-4">
																<br />
																<span id="fileUploadContainer"></span>
																<div id="addImageFormContent" class="input-group">
																	<span class="input-group-btn">
																			<span class="btn btn-primary btn-file"> Browse&#133;
																				<input id="file" type="file" name="file" accept=".mol, .svg, .png">
																			</span>
														<!-- 					multiple="" -->
																			<input type="hidden" name="ajaxUpload" value="true">
																			<input id="inchikey" name="inchikey" type="hidden" value="${inchikey}" />
																	</span> <input type="text" class="form-control" readonly>
																</div>
																<small>
																	To know how to number molecules atoms (rules, softwares, ...) please contact a MetaboHUB WP1a manager
																	or read the <a href="https://doi.org/10.15454/6TJ8-HN72" target="_blank">online documentation</a>.
																</small>
																<br />
																<br />
															</div>
															<div class="col-lg-1">
															</div>
															<div id="imgUploading" class="col-lg-4" style="display:none;" >
																<br />
																<br />
																<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
															</div>
															<div id="imgUploadResults" class="col-lg-1" style="display:none;" >
															</div>
															<div id="imgUploadError" class="col-lg-6" style="" ></div>
															<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>     
<script type="text/javascript">

//
checkUploadChemFileForm=function() {
	if ($("#file").val()=='') {
		return false;
	}
	return true;
};
//file upload
$(document).on('change', '#file', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('.btn-file :file').on('fileselect', function(event, numFiles, label) {
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;
		if(input.length) {
			input.val(log);
			// startUpload();
			$("#addImageFormContent").appendTo("#fileUploadForm");
			$("#fileUploadForm").submit();
		} else {
			if(log) alert(log);
		}
	});
});
$(document).ready(function() {
	$("#fileUploadForm").ajaxForm({
		beforeSubmit: startUpload,
		success: function(data) {
			// TODO reload
			var data2 = data.trim();
			if (data2 == "OK")
				location.reload();
			else {
				var stringError = "";
				if (data2 == "no_file_selected")
					stringError = "no file selected!";
				else if (data2 == "wrong_ext")
					stringError = "wrong file extension";
				var errorBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> ' + stringError;
				errorBox += ' </div>';
				$("#imgUploadError").html(errorBox);
			}
			$("#imgUploading").hide();
			$("#addImageFormContent").appendTo("#fileUploadContainer");
		},
		error: function() {
			// TODO alert message
			var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
				errorBox += ' </div>';
				$("#imgUploadError").html(errorBox);
			$("#imgUploading").hide();
			$("#addImageFormContent").appendTo("#fileUploadContainer");
		}
	});
});

function startUpload() {
	$("#imgUploadError").html("");
	$("#imgUploading").show();
	//
}

</script>
													
													</div>
													
													<!-- upload new image (all) -->
													<div id="showMol-upload" class="tab-pane fade">
															<div class="col-lg-6">
																<br />
																<div class="alert alert-info alert-dismissible" role="alert">
																	<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>
																	<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> check if the InChI / InChIKey of the molecule file you want to upload match current molecule in this sheet. 
																</div>
															</div>
															<div class="col-lg-4">
																<br />
																<span id="fileUploadContainer2"></span>
																<div id="addImageFormContent2" class="input-group">
																	<span class="input-group-btn">
																			<span class="btn btn-primary btn-file"> Browse&#133;
																				<input id="file2" type="file" name="file" accept=".mol, .svg, .png">
																			</span>
														<!-- 					multiple="" -->
																			<input type="hidden" name="ajaxUpload2" value="true">
																			<input id="inchikey2" name="inchikey" type="hidden" value="${inchikey}" />
																	</span> <input type="text" class="form-control" readonly>
																</div>
																<small>
																	To know how to create MOL and SVG file for molecules (rules, softwares, ...) 
																	please refer to <a href="https://peakforest.org/sop">PeakForest SOP</a>.
																	<br />The name of the uploaded file <b>must</b> be either :
																	<ul>
																		<li>&quot;${inchikey}.mol&quot; for a MOL file or</li> 
																		<li>&quot;${inchikey}.svg&quot; for a SVG file or</li>
																		<li>&quot;${inchikey}.png&quot; for a PNG file.</li>
																	</ul>
																	&#9888; avoid PNG images, or please do not upload a pixelized one.
																</small>
																<br />
																<br />
															</div>
															<div class="col-lg-1">
															</div>
															<div id="imgUploading2" class="col-lg-4" style="display:none;" >
																<br />
																<br />
																<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
															</div>
															<div id="imgUploadResults2" class="col-lg-1" style="display:none;" >
															</div>
															<div id="imgUploadError2" class="col-lg-6" style="" ></div>
<%-- 															<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>      --%>
<script type="text/javascript">

//
checkUploadChemFileForm2 = function() {
	if ($("#file2").val()=='') {
		return false;
	}
	return true;
};
//file upload
$(document).on('change', '#file2', function() {
	var input = $(this),
	numFiles = input.get(0).files ? input.get(0).files.length : 1,
	label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
	input.trigger('fileselect', [numFiles, label]);
});
$(document).ready( function() {
	$('#file2').on('fileselect', function(event, numFiles, label) {
		var input = $(this).parents('.input-group').find(':text'),
		log = numFiles > 1 ? numFiles + ' files selected' : label;
		if(input.length) {
			input.val(log);
			// startUpload();
			$("#addImageFormContent2").appendTo("#fileUploadForm2");
			$("#fileUploadForm2").submit();
		} else {
			if(log) alert(log);
		}
	});
});
$(document).ready(function() {
	$("#fileUploadForm2").ajaxForm({
		beforeSubmit: startUpload2,
		success: function(data) {
			// TODO reload
			var data2 = data.trim();
			if (data2 == "OK")
				location.reload();
			else {
				var stringError = "";
				if (data2 == "no_file_selected")
					stringError = "no file selected!";
				else if (data2 == "wrong_ext")
					stringError = "wrong file extension";
				else if (data2 == "wrong_name")
					stringError = "wrong file name (must match InChIKey)";
				var errorBox = '<br><br><div class="alert alert-info alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> ' + stringError;
				errorBox += ' </div>';
				$("#imgUploadError2").html(errorBox);
			}
			$("#imgUploading2").hide();
			$("#addImageFormContent2").appendTo("#fileUploadContainer2");
		},
		error: function() {
			// TODO alert message
			var errorBox = '<br><br><div class="alert alert-danger alert-dismissible" role="alert">';
				errorBox += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				errorBox += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not upload file';
				errorBox += ' </div>';
				$("#imgUploadError2").html(errorBox);
			$("#imgUploading2").hide();
			$("#addImageFormContent2").appendTo("#fileUploadContainer2");
		}
	});
});

function startUpload2() {
	$("#imgUploadError2").html("");
	$("#imgUploading2").show();
	//
}

</script>
													
													</div>
													
</c:if>
												</div>
<!-- 											</div> -->
											<!--  ++++++++++++++++++++++++++++ end card 3  -->
<!-- 										</div> -->
												<table class="table">
													<tr>
														<td style="white-space: nowrap;"><spring:message code="modal.show.structure.cansmiles" text="Canonical smiles" /></td>
														<%
															String smilesAlert = "";
															if (request.getAttribute("smiles").toString().length() > 65) {
																smilesAlert = "onclick=\"alert('" + request.getAttribute("smiles") + "')\"";
															}
														%>
														<td class="smiles" <%=smilesAlert %>>${smiles}</td>
													</tr>
													<c:if test="${not empty inchi}">
													<tr>
														<td ><spring:message code="modal.show.structure.inchi" text="InChI" /></td>
														<td>${inchi}</td>
													</tr>
													</c:if>
<!-- 													<tr> -->
<!-- 														<td>InChIKey</td> -->
<%-- 														<td>${inchikey}</td> --%>
<!-- 													</tr> -->
													<c:if test="${mol_ready}">
													<tr>
														<td><spring:message code="modal.show.basicInfos.download" text="Download" /></td>
														<td class="download-btns">
															<a class="btn btn-primary" href="mol/${inchikey}.mol" title="${compoundNames.get(0).name}" target="_blank">
																<spring:message code="modal.show.basicInfos.mol" text="Mol" /> <i class="fa fa-download"></i>
															</a>
															
															<!-- issue #363 -->
															<a class="btn btn-primary" href="sdf/${inchikey}.sdf" title="${compoundNames.get(0).name}" target="_blank">
																<spring:message code="modal.show.basicInfos.sdf" text="SDF" /> <i class="fa fa-download"></i>
															</a>
														</td>
													</tr>
													</c:if>
												</table>
									</div>
								</div>


								<c:if test="${contains_alt_structure}">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.relatedCompound" text="Related Compounds" /> <i class="fa fa-sitemap"></i>
										</h4>
									</div>
									<div >
										<table class="table">
											<tr>
												<td>
													<!-- parent -->
													<c:if test="${alt_structure_isGeneric}">
												 	<a class="compoundzoom btn btn-default btn-disabled " href="#" style="text-align: left;">
														<i class="fa fa-info-circle"></i> 
														${compoundNames.get(0).name}
														<br><i> ${inchikey} </i>
														<div style="display:none;"><img  class="molStructSVGsmall" src="image/generic/${inchikey}" alt="${compoundNames.get(0).name}"></div>
													</a>
													</c:if>
													<c:if test="${!alt_structure_isGeneric}">
												 	<a class="compoundzoom btn btn-info " href="show-compound-modal/generic/${alt_structure_parent.id}" data-toggle="modal" data-target="#modalShowCompound" style="text-align: left;">
														<i class="fa fa-info-circle"></i> 
														<span id="nameOfGC${alt_structure_parent.id}_sheet"></span>
														<br><i> ${alt_structure_parent.inChIKey} </i>
														<div style="display:none;"><img  class="molStructSVGsmall" src="image/generic/${alt_structure_parent.inChIKey}" alt=""></div>
													</a>
													</c:if>
												</td>
												<td>
													<!-- children -->
													<ul class="list-group" id="cc_children_listName_sheet" style="margin-bottom: 0px;">
													</ul>
												</td>
											</tr>
										</table>
										<script type="text/javascript">

										var parentID_sheet = ${alt_structure_parent.id};
										var currentIDCC_sheet = ${id};
										/**
										 *
										 */
										loadChildrenCompoundNames_sheet=function(parentID) {
											$.ajax({
												type: "post",
												url: "load-children-chemical-compounds-names",
												data: 'parentId=' + parentID,
												success: function(data) {
													if(data.success) { 
														var listChildren_sheet = '';
														$.each(data.chemicalCompounds, function(key, value){
															var classS = 'btn-info';
															var hrefS = 'href="show-compound-modal/chemical/'+value.id+'" data-toggle="modal" data-target="#modalShowCompound"';
															if (value.id==currentIDCC_sheet) { classS = 'btn-default btn-disabled'; hrefS = 'href="#"'; }
															listChildren_sheet += '<li id="cc_child_'+value.id+'" class="list-group-item">';
															listChildren_sheet += '<a class="compoundzoom btn '+classS+'" '+hrefS+' style="text-align: left;">';
															listChildren_sheet += '<i class="fa fa-info-circle"></i>'; 
															listChildren_sheet += ' ' + value.mainName + '';
															listChildren_sheet += '<br><i> ' + value.inChIKey + ' </i>';
															listChildren_sheet += '<div style="display:none;"><img class="molStructSVGsmall" src="image/chemical/'+value.inChIKey+'" alt="'+value.mainName+'"></div>';
															listChildren_sheet += '</a>';
															listChildren_sheet += '</li>';
														});
														$('#cc_children_listName_sheet').append(listChildren_sheet);
														$("a.compoundzoom").mouseover(function() {
															$(this).find("div").show();
														}).mouseout(function() {
														    // $( this ).find( "i.inchikey" ).text( "mouse out " );
															$(this).find("div").hide();
														});;
														$("a[data-target=#modalShowCompound]").click(function(ev) {
															ev.preventDefault();
															$("#modalShowCompound").modal("hide");
															var target = $(this).attr("href");
															// load the url and show modal on success
															//$('#cc_children_listName_sheet').empty();
															$('#cc_children_listName').empty();
															$("#modalShowCompound .modal-dialog").html("");
															setTimeout(function() {  $("#modalShowCompound .modal-dialog ").load(target, function() { $("#modalShowCompound").modal("show"); }); } , 50);
														});
														$("#nameOfGC${alt_structure_parent.id}_sheet").html(data.parentName);
													} else {
														 $('#cc_children_listName_sheet').append('<li class="list-group-item">ERROR</i>');
													}
												}, 
												error : function(data) {
													console.log(data);
												}
											});
										};
										loadChildrenCompoundNames_sheet(parentID_sheet);
										
										</script>
<!-- 										// current -->
<!-- 										// sub structures -->
<!-- 										// current -->
<!-- 										// putatives -->
									</div>
								</div>
								</c:if>
								

								<c:if test="${contains_gc_derivatives}">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.GCDerivedCompound" text="GC-Derivatives" /> <i class="fa fa-puzzle-piece"></i>
										</h4>
									</div>
									<div >
										<table class="table">
											<tr>
												<td>
													<!-- children -->
													<ul class="list-group" id="cc_derivatives_listName_sheet" style="margin-bottom: 0px;">
													</ul>
												</td>
											</tr>
										</table>
										<script type="text/javascript">

										var currentIDCC_sheet = ${id};
										/**
										 *
										 */
										loadDerivativesCompoundNames_sheet=function(compoundID) {
											$.ajax({
												type: "post",
												url: "load-gc-derivatives-names",
												data: 'parentId=' + compoundID,
												success: function(data) {
													if(data.success) { 
														var listChildren_sheet = '';
														$.each(data.gcDerivedCompounds, function(key, value){
															var classS = 'btn-info';
															var hrefS = '';
															// replace previous line by following line (to uncomment), when modal is ready
															// var hrefS = 'href="show-compound-modal/chemical/'+value.id+'" data-toggle="modal" data-target="#modalShowCompound"';
															listChildren_sheet += '<li id="cc_derivative_'+value.id+'" class="list-group-item">';
															listChildren_sheet += '<a class="compoundzoom btn '+classS+'" '+hrefS+' style="text-align: left;">';
															listChildren_sheet += '<i class="fa fa-info-circle"></i>'; 
															listChildren_sheet += ' ' + value.mainName + '';
															listChildren_sheet += '<br><i> ' + value.inChIKey + ' </i>';
															listChildren_sheet += '<div style="display:none;"><img class="molStructSVGsmall" src="image/gc-derived/'+value.inChIKey+'" alt="'+value.mainName+'"></div>';
															listChildren_sheet += '</a>';
															listChildren_sheet += '</li>';
														});
														$('#cc_derivatives_listName_sheet').append(listChildren_sheet);
														$("a.compoundzoom").mouseover(function() {
															$(this).find("div").show();
														}).mouseout(function() {
														    // $( this ).find( "i.inchikey" ).text( "mouse out " );
															$(this).find("div").hide();
														});;
														// $("a[data-target=#modalShowCompound]").click(function(ev) {
														// 	ev.preventDefault();
														// 	$("#modalShowCompound").modal("hide");
														// 	var target = $(this).attr("href");
														// 	// load the url and show modal on success
														// 	//$('#cc_children_listName_sheet').empty();
														// 	$('#cc_children_listName').empty();
														// 	$("#modalShowCompound .modal-dialog").html("");
														// 	setTimeout(function() {  $("#modalShowCompound .modal-dialog ").load(target, function() { $("#modalShowCompound").modal("show"); }); } , 50);
														// });
														// $("#nameOfGC${alt_structure_parent.id}_sheet").html(data.parentName);
													} else {
														 $('#cc_derivatives_listName_sheet').append('<li class="list-group-item">ERROR</i>');
													}
												}, 
												error : function(data) {
													console.log(data);
												}
											});
										};
										loadDerivativesCompoundNames_sheet(currentIDCC_sheet);
										
										</script>
<!-- 										// current -->
<!-- 										// sub structures -->
<!-- 										// current -->
<!-- 										// putatives -->
									</div>
								</div>
								</c:if>

								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.inOtherDatabases" text="In other databases" /> <i class="fa fa-rocket"></i>
										</h4>
									</div>
									<div id="cardSheet5" class="">
												<table class="table">
													<tr>
														<td style="width: 100px;"><spring:message code="modal.show.inOtherDatabases.inchikey" text="InChIKey" /></td>
														<td>${inchikey}</td>
													</tr>
													<c:if test="${not empty pubchem}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.pubchem" text="PubChem" /></td>
														<td><a href="<spring:message code="resources.banklink.pubchem" text="http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=" />${pubchem}" target="_blank">CID ${pubchem}</a></td>
													</tr>
													</c:if>
													<c:if test="${not empty chebi}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.chebi" text="ChEBI" /></td>
														<td><a href="<spring:message code="resources.banklink.chebi" text="https://www.ebi.ac.uk/chebi/searchId.do?chebiId=" />${chebi}" target="_blank">CHEBI:${chebi}</a></td>
													</tr>
													</c:if>
													<c:if test="${not empty hmdb}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.hmdb" text="HMDB" /></td>
														<td><a href="<spring:message code="resources.banklink.hmdb" text="http://www.hmdb.ca/metabolites/HMDB" />${hmdb}" target="_blank">HMDB${hmdb}</a></td>
													</tr>
													</c:if>
													<c:if test="${not empty keggs}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.kegg" text="KEGG" /></td>
														<td>
															<c:forEach var="kegg" items="${keggs}">
																<br /><a href="<spring:message code="resources.banklink.kegg" text="http://www.genome.jp/dbget-bin/www_bget?cpd:" />${kegg}" target="_blank">${kegg}</a>
															</c:forEach>
														</td>
													</tr>
													</c:if>
													<c:if test="${not empty networks}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.networkIds" text="Networks IDs" /></td>
														<td>
															<c:forEach var="network" items="${networks}">
																<br />${network}
															</c:forEach>
														</td>
													</tr>
													</c:if>
													<c:if test="${not empty cas}">
													<tr>
														<td><spring:message code="modal.show.inOtherDatabases.cas.simple" text="CAS" /></td>
														<td>
															<c:forEach var="casEntity" items="${cas}">
																<br /> ${casEntity.getCasNumber()};${casEntity.getCasProviderAsString()};${casEntity.getCasReferencer()}
															</c:forEach>
														</td>
													</tr>
													</c:if>
													<c:if test="${not empty externalIds}">
														<tr>
															<td>Ext. IDs</td>
															<td>
																<c:forEach var="externalId" items="${externalIds}">
																	<br /> <a href="${externalId.url != '' ? externalId.url : 'javascript:void(0)' }" target="_blank">${externalId.label}: ${externalId.value}</a>
																</c:forEach>
															</td>
														</tr>
													</c:if>
													
												</table>
									</div>
								</div>
								
								<c:if test="${not empty chebi}">
									<div id="panel-metabolights-studies" class="panel panel-default">
										<div class="panel-heading">
											<h4 class="panel-title">
												<spring:message code="modal.show.metabolightsStudies" text="Metabolights Studies" /> <i class="fa fa-book"></i>
											</h4>
										</div>
										<div id="cardSheet_metabolights" class="">
										</div>
									</div>
<script type='text/javascript'>
//<![CDATA[
	listMetabolightsStudies('${chebi}');
//]]>
</script>
								</c:if>
								<% /*
								<div id="MEViz__module" class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											MetExplore viz <img style="max-width: 15px;" class="" alt="logo ME Viz" src="<c:url value="/resources/img/metexplore_icon.png" />">
										</h4>
									</div>
									<div id="cardSheet_MEViz" class="" style="min-height:600px;">
										<small>
											<i class="fa fa-question-circle" aria-hidden="true"></i> Map a PeakForest metabolite or a metabolite list (from the PeakForest Cart) in a selection of biosources and theirs networks from MetExplore. For each selected network, PeakForest will filter and propose pathways where more than one of your compound is found. 
											<br />If none pathway is shown in the menu, it means that's no compound is mapped in any pathway.
											<br />
										</small>
										<br />
										<!-- select opt cart -->
										<div class="form-group">
											<label class="col-md-4 control-label">Load cart</label>
											<div class="col-md-4">
												<label><input id="MEViz__loadCart_N" name="MEViz__loadCart" type="radio" checked="checked"> Nope!</label>
												<label><input id="MEViz__loadCart_Y" name="MEViz__loadCart" type="radio" > yes :-)</label>
											</div> 
										</div>
										<!-- select network -->
										<div class="form-group" >
											<label class="col-md-4 control-label" for="selectbasic">Select your MetExplore Network and BioSource</label>
											<div class="col-md-4">
												<select id="MEViz__biosource" name="MEViz__biosource" class="form-control combobox"></select>
											</div>
										</div>
										<!-- select pathway -->
										<div class="form-group">
											<label class="col-md-4 control-label" for="selectbasic">Select your pathway(s)</label>
											<div id="MEViz__pathwaysTarget" class="col-md-4">
												<select id="MEViz__pathways" class="form-control " disabled="disabled"></select>
											</div>
										</div>
										<!-- validate / reset -->
										<div class="form-group">
											<label class="col-md-4 control-label" for="selectbasic">
												<span class=" pull-right">
													<button id="MEViz__run" disabled="disabled" class="btn btn-sm btn-success "> <i class="fa fa-flag-checkered"></i> Run MetExplore Viz</button>
													<button id="MEViz__reset" class="btn btn-xs btn-warning"> <i class="fa fa-times-circle"></i> Reset </button>
												</span>
											</label>
											<div class="col-md-4">												
											</div>
										</div>
										<!-- MetExplore Viz frame -->
										<div id="MEViz__mainFrame" style=""></div>
										<script type="text/javascript">
										var MEViz__autoLoadCart = false;
										var currentMolInChIKey = "${inchikey}";
										</script>
									</div>
								</div>
								*/  %>
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.chemProp" text="Chemical properties" /> 
											<i class="fa fa-flask" aria-hidden="true"></i>
										</h4>
									</div>
									<div id="cardSheetMetaboCard" class="">
										<table class="table">
											<tr>
												<td style="width: 350px;"><a href="<c:url value="/home" />?page=stats&logp=${inchikey}">LogP</a></td>
												<td>${logP}</td>
											</tr>
											<c:if test="${isBioactive}">
												<tr>
													<td>
														<spring:message code="modal.show.chemProp.isBioActive" text="Is a mammalian biochemical structure?" /> 
														<a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3866231/" target="_blank">
															<i class="fa fa-question-circle" aria-hidden="true"></i>
														</a> 
													</td>
													<td>
														<c:if test="${isBioactiveV}">
															<button class="btn btn-xs btn-success"><i class="fa fa-check-circle"></i></button>
														</c:if>
														<c:if test="${! isBioactiveV}">
															<button class="btn btn-xs btn-danger"><i class="fa fa-times-circle"></i></button>
														</c:if>
													</td>
												</tr>
											</c:if>
										</table>
									</div>
								</div>
								
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											<spring:message code="modal.show.citation" text="In the literature" /> <i class="fa fa-certificate"></i>
										</h4>
									</div>
									
									<div id="cardSheet7" class="">
										<c:if test="${not empty acceptedCitations}">
											<table class="table">
												<c:forEach var="citation" items="${acceptedCitations}">
												<tr>
													<td>
														<c:if test="${not empty citation.doi}">
														<a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />${citation.doi}" class="btn btn-xs btn-info" target="_blank"><i class="fa fa-book"></i> </a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.pmid}">
														<spring:message code="modal.show.citation.pmid" text="PMID:&nbsp;" /><a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />${citation.pmid}" class="" target="_blank">${citation.pmid}</a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
										<c:if test="${empty acceptedCitations}">
											<div class="panel-body"><spring:message code="modal.show.citation.noAcceptedCitation" text="No accepted citation." /></div>
										</c:if>
										<c:if test="${not empty waitingCitationsUser}">
											<table class="table ">
												<c:forEach var="citation" items="${waitingCitationsUser}">
												<tr class="warning">
													<td>
														<c:if test="${not empty citation.doi}">
														<a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />${citation.doi}" class="btn btn-xs btn-info" target="_blank"><i class="fa fa-book"></i> </a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.pmid}">
														<spring:message code="modal.show.citation.pmid" text="PMID:&nbsp;" /><a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />${citation.pmid}" class="" target="_blank">${citation.pmid}</a>
														</c:if>
													</td>
													<td>
														<c:if test="${not empty citation.apa}">
														${citation.apa}
														</c:if>
													</td>
												</tr>
												</c:forEach>
											</table>
										</c:if>
										<c:if test="${editor}">
										<div id="newCitation" style="width: 650px; margin: auto;"><br></div>
										<div class="input-group">
											<span class="input-group-addon" style="width: 200px;">
													<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.citation.newCitation" text="New citation" />
											</span> 
												<span>
<%-- 												<input type="text" id="cc_addNewCitationURL" style="width: 250px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.citation.newCitation.url" text="publication URL" />"> --%>
												<input type="text" id="cc_addNewCitationID" style="width: 400px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.citation.newCitation.id" text="PUBMED id or doi" />">
<!-- 												<select id="cm_priority" class="form-control pull-left"style="width: 150px; border-radius: 0px;"></select> -->
											</span>
											<span class="input-group-btn " style="width: 50px;">  
												<span class="input-group-btn">
													<button class="btn btn-default" type="button" onclick="addNewCitationAction();" style="border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-top-left-radius: 0px; border-bottom-left-radius: 0px"><i class="fa fa-plus-square"></i></button>
												</span>
											</span>
											<script type="text/javascript">
											
											var newCitations = new Object();
											
											$("#cc_addNewCitationID").keypress(function(event) {
												if (event.keyCode == 13) {
													addNewCitationAction();
												}
												//if ($("#cc_addNewCitationURL").val().length > 250) { return false; }
											});
											
											addNewCitationAction = function() {
												//var url = $('#cc_addNewCitationURL').val();
												//var pat = /^https?:\/\//i;
												//if (!pat.test(url)) {
												//	url = 'http://'+url;
												//}
												var id = $('#cc_addNewCitationID').val();
												var idMessage = md5("citation" + id);
												if (id != '') {
													if ($('#CITE-'+idMessage).length != 0)
														alert ('<spring:message code="modal.show.citation.alert.aleradyEntered" text="citation already entered!" />');
													else {
														newCitations[idMessage] = {  "id" : id}; // "url" : url,
														var newDiv = '<div id="CITE-'+idMessage+'" class="alert alert-warning alert-dismissible" role="alert">';
														newDiv += '<button type="button" class="close" data-dismiss="alert" onclick="deleteCitationAction(\''+idMessage+'\')">';
														newDiv += '<span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
														//if (url != "http://")
														//	newDiv += '<a href="'+url+'" target="_blank" class="btn btn-xs btn-info" ><i class="fa fa-book"></i> </a>';
														newDiv += ' <span id="CITE-RESULT-'+idMessage+'">'+id+' <img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" /></span>';
														newDiv += '</div>';
														$("#newCitation").append(newDiv);
														//$('#cc_addNewCitationURL').val('');
														$('#cc_addNewCitationID').val('');
														// TODO ajax async : overwrite this alert, set correct ids in new citation object
														$.ajax({
															type: "get",
															url: "get-citation-data",
															data: 'query='+ id + '',
															dataType: 'json',
															// contentType: 'application/json',
															success: function(data) {
																console.log(data);
																if(data.success) { 
																	var apa = data.apa;
																	var doi = data.doi;
																	var pmid = data.pmid;
																	var newResult = '';
																	if (doi!=null)
																		newResult += '<a href="<spring:message code="resources.citationlink.doi" text="http://dx.doi.org/" />'+doi+'" target="_blank" class="btn btn-xs btn-info" ><i class="fa fa-book"></i> </a>';
																	if (pmid!=null)
																		newResult += ' <a href="<spring:message code="resources.citationlink.pmid" text="http://www.ncbi.nlm.nih.gov/pubmed/?term=" />'+pmid+'" target="_blank" >'+pmid+'</a>';
																	newResult += ' ' + apa;
																	$('#CITE-RESULT-'+idMessage).html(newResult);
																	newCitations[idMessage] = { "apa" : apa, "doi" : doi, "pmid" : pmid}; //"url" : url, 
																} else {
																	$('#CITE-RESULT-'+idMessage).html("ERROR: could not retrive the publication.");
																	$('#CITE-'+idMessage+'').removeClass("alert-warning");
																	$('#CITE-'+idMessage+'').addClass("alert-danger");
																	delete newCitations[idMessage];
																}
															}, 
															error : function(data) {
																console.log(data);
																$('#CITE-RESULT-'+idMessage).html("FATAL: could not retrive the publication.");
																$('#CITE-'+idMessage+'').removeClass("alert-warning");
																$('#CITE-'+idMessage+'').addClass("alert-danger");
																delete newCitations[idMessage];
															}
														});
													}
												}
											};
											deleteCitationAction =function(idMessage) {
												delete newCitations[idMessage];
												$('#CITE-'+idMessage).remove();
											}
											</script>
										</div>
										</c:if>
									</div>
								</div>
								
								<c:if test="${editor}">
								<div class="panel panel-default">
									<div class="panel-heading">
										<h4 class="panel-title">
											 <spring:message code="modal.show.curationMessages" text="Add Curation message" />  <i class="fa fa-comments"></i>
										</h4>
									</div>
									
									<div id="cardSheet6" class="">
										<c:if test="${not empty waitingCurationMessageUser}">
											<table class="table ">
												<c:forEach var="curationMessage" items="${waitingCurationMessageUser}">
													<tr class="warning">
														<td>${curationMessage.message}</td>
													</tr>
												</c:forEach>
											</table>
										</c:if>
										<div id="newCurationMessage" style="width: 650px; margin: auto;"><br></div>
										<div class="input-group">
											<span class="input-group-addon" style="width: 200px;">
													<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.curationMessages.newCurationMessage" text="new curation message" />
											</span> 
												<span>
												<input type="text" id="cc_addNewCurationMessage" style="width: 400px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.curationMessages.newCurationMessage.ph" text="new message..." />">
<!-- 												<select id="cm_priority" class="form-control pull-left"style="width: 150px; border-radius: 0px;"></select> -->
											</span>
											<span class="input-group-btn " style="width: 50px;">  
												<span class="input-group-btn">
													<button class="btn btn-default" type="button" onclick="addNewCurationMessageAction();" style="border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-top-left-radius: 0px; border-bottom-left-radius: 0px"><i class="fa fa-plus-square"></i></button>
												</span>
											</span>
											<script type="text/javascript">
											
											var newCurationMessages = new Object();
											
											$("#cc_addNewCurationMessage").keypress(function(event) {
												if (event.keyCode == 13) {
													addNewCurationMessageAction();
												}
												if ($("#cc_addNewCurationMessage").val().length > 100) { return false; }
											});
											
											addNewCurationMessageAction = function() {
												var message = $('#cc_addNewCurationMessage').val();
												var idMessage = md5("curationMessage" + message);
												if (message != '') {
													if ($('#CM-'+idMessage).length != 0)
														alert ('<spring:message code="modal.show.curationMessages.alert.aleradyEntered" text="message already entered!" />');
													else {
														newCurationMessages[idMessage] = message;
														var newDiv = '<div id="CM-'+idMessage+'" class="alert alert-warning alert-dismissible" role="alert">';
														newDiv += '<button type="button" class="close" data-dismiss="alert" onclick="deleteCurationMessageAction(\''+idMessage+'\')">';
														newDiv += '<span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
														newDiv += message;
														newDiv += '</div>';
														$("#newCurationMessage").append(newDiv);
														$('#cc_addNewCurationMessage').val('');
													}
												}
											};
											deleteCurationMessageAction =function(idMessage) {
												delete newCurationMessages[idMessage];
												$('#CM-'+idMessage).remove();
											}
											</script>
										</div>
									</div>
								</div>
								</c:if>
							</div>
						</fieldset>
					</form>
				</div>
			</div>
			<div id="compound-cart" class="pull-right">
				<div class="alert alert-info" role="alert">
					<button id="addCpdInCart" style="display: none;" class="btn btn-success btn-xs"><i class="fa fa-plus-circle"></i> <i class="fa fa-shopping-cart"></i></button>
					<button id="removeCpdFromCart" style="display: none;" class="btn btn-danger btn-xs"><i class="fa fa-times-circle"></i> <i class="fa fa-shopping-cart"></i></button>
					<!-- test if in current cart -->
					<script type="text/javascript">
$( document ).ready(function() {
	testIfCpdInCurrentCart(Number('${id}'));
});
// add
$("#addCpdInCart").click(function(){addCpdInCart(Number('${id}'))});
// remove
$("#removeCpdFromCart").click(function(){removeCpdFromCart(Number('${id}'))});

					</script>
					<!-- end test if cpd Cart -->
				</div>
			</div>
			<div class="pull-right" style="padding-top: 10px;">
				<c:if test="${!editor}">
				<button type="button" class="btn btn-default" onclick="window.history.back();"><spring:message code="modal.close" text="Close" /></button>
				</c:if>
				<c:if test="${editor}">
				<button type="button" class="btn btn-default" onclick="window.history.back();"><spring:message code="modal.cancel" text="Cancel" /></button>
				</c:if>
				<a class="btn btn-default"
					href="print-compound-modal/${type}/${id}" data-toggle="modal"
					data-target="#modalPrintCompound"
					onclick="">
					<i class="fa fa-print"></i> <spring:message code="modal.show.btn.print" text="Print" /></a>
				<c:if test="${editor}">
				<button type="button" onclick="updateCurrentCompound('${type}', ${id})" class="btn btn-primary">
					<i class="fa fa-save"></i> <spring:message code="modal.saveChanges" text="Save Changes" />
				</button>
				<script type="text/javascript">
				var updateScores = new Object();
				var newCompoundNames = new Object();
				var newCurrationMessagesList = [];
				var newCitationsList = [];
				updateCurrentCompound = function(type, id) {
					newCurrationMessagesList = [];
					$.each(newCurationMessages, function(k,v){ newCurrationMessagesList.push(v); });
					newCitationsList = [];
					$.each(newCitations, function(k,v){ newCitationsList.push(v); });
					$.ajax({
						type: "POST",
						url: "update-compound/" + type + "/" + id,
						data: JSON.stringify({ updateScores: updateScores, newNames: newCompoundNames, curationMessages: newCurrationMessagesList, newCitations: newCitationsList }),
						contentType: 'application/json',
						success: function(data) {
							if(data) { 
								closeCompoundEntity();
							} else {
								alert('<spring:message code="modal.show.alert.failUpdate" text="Failed to update compound!" />'); 
							}
						}, 
						error : function(data) {
							console.log(data);
						}
					});
				};

				</script>
				</c:if>
				<c:if test="${curator}">
				<a class="btn btn-info" href="edit-compound-modal/${type}/${id}" data-toggle="modal"
					data-target="#modalEditCompound">
					<i class="fa fa-pencil"></i> <spring:message code="modal.edit" text="Edit" />
				</a>
				<script type="text/javascript">
					$("a[data-target=#modalEditCompound]").click(function(ev) {
						ev.preventDefault();
						// close this modal
						//$('#modalShowCompound').modal('hide');
						//setTimeout(function() { $('.modalShowCompound').modal('hide'); }, 200);
						reopenDetailsModal = false;
						reopenDetailsSheet = true;
						var target = $(this).attr("href");
						// load the url and show modal on success
						$("#modalEditCompound .modal-dialog ").load(target, function() { $("#modalEditCompound").modal("show"); });
					});
				</script>
				</c:if>
				<br>
				<br>
				<br>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
	
	<!-- MODAL - SHOW -->
	<div class="modal" id="modalShowCompound" tabindex="-1" role="dialog"
		aria-labelledby="modalShowCompoundLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content modalLarge">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="modalShowCompoundLabel">Modal title</h4>
				</div>
				<div class="modal-body">
					<div class="te"></div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
					<button type="button" class="btn btn-primary">Save changes</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal -->
	<script type="text/javascript">
		var reopenDetailsModal = false;
		var reopenDetailsSheet = false;
		checkIfReOpenDetailsModal = function() {
			if (reopenDetailsModal) {
				$('#modalShowCompound').modal('show');
				reopenDetailsModal = false;
			}
		};
		
		$('body').on('hidden.bs.modal', '.modal', function () {
			  $(this).removeData('bs.modal');
		});
	</script>
	<!-- MODAL - PRINT -->
	<div class="modal " id="modalPrintCompound" tabindex="-1" role="dialog" aria-labelledby="modalPrintCompoundLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="modalPrintCompoundLabel">Modal title</h4>
				</div>
				<div class="modal-body">
					<div class="te"></div>
				</div>
				<div class="modal-footer">
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal print -->
	<!-- MODAL - EDIT -->
	<div class="modal " id="modalEditCompound" tabindex="-1" role="dialog" aria-labelledby="modalEditCompoundLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="modalEditCompoundLabel">Modal title</h4>
				</div>
				<div class="modal-body">
					<div class="te"></div>
				</div>
				<div class="modal-footer">
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal edit -->
	
	<script type="text/javascript">
	closeCompoundEntity = function() {
		window.history.back();
	}
	var jsMolSRC = false;
	var jsMolLoaded = false;	
	refreshJSmol = function() {
		if (!jsMolSRC) {
			$.get("js_cpd_sandbox/${inchikey}", function( data ) {
				$("#jsmol").html(data)
				jsMolSRC = true;
			});
		}
// 		try {
// 			if (!jsMolLoaded && /firefox/.test(navigator.userAgent.toLowerCase())) {
// 				document.getElementById("jsmol").contentDocument.location.reload(true);
// 				jsMolLoaded = true;
// 			} else {
// 				document.getElementById("jsmol").contentWindow.refreshJSmol();
// 			}
// 		} catch(e) {}
	}
	</script>
	<div style="display:none;">
		<form id="fileUploadForm" action="upload-compound-numbered-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadChemFileForm()">
		</form>
		<form id="fileUploadForm2" action="upload-compound-image-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadChemFileForm2()">
		</form>
	</div>
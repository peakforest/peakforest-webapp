<%@page import="fr.metabohub.peakforest.utils.PeakForestManagerException"%>
<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>
<c:if test="${mol_ready}">
	<script type='text/javascript'>
		///////////////////
		function saveImage<%=randomID %>() {
			glmol<%=randomID %>.show();
			var imageURI = glmol<%=randomID %>.renderer.domElement.toDataURL("image/png");
			window.open(imageURI);
		}
		
		function reload<%=randomID %>() {
			glmol<%=randomID %>.defineRepresentation = defineRepFromController<%=randomID %>;
			glmol<%=randomID %>.rebuildScene();
			glmol<%=randomID %>.show();
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
		var glmol<%=randomID %> = '';
		initLoadGLmol1 = function() {
			if (glmol<%=randomID %> !== '') { return false; }
			try {
				glmol<%=randomID %> = new GLmol('glmol<%=randomID %>');
				setTimeout(function(){reload<%=randomID %>()},1000);
			} catch (e) {
			}
			return true;
		};

	</script>
</c:if>
	<table class="table">
		<tr>
			<td rowspan="5" style="width: 300px;">
				<c:if test="${mol_ready}">
					<ul class="nav nav-tabs">
						<li class="active">
							<a href="#showMol-2D" data-toggle="tab">
								<i class="fa fa-square-o"></i> 2D
							</a>
						</li>
						<li>
							<a href="#showMol-3D" data-toggle="tab" onclick="initLoadGLmol1();">
								<i class="fa fa-cube"></i> 3D
							</a>
						</li>
					</ul>
					<div class="tab-content">
						<div id="showMol-2D" class="tab-pane fade active in">
							<img class="molStructSVGsmall" src="image/${type}/${inchikey}" alt="${compoundNames.get(0).name}">
						</div>
						<div id="showMol-3D" class="tab-pane fade">
							<div id="glmol<%=randomID %>" class="molGL" style="height:200px; width: 350px;"></div>
<%-- 												${mol} --%>
								<textarea id="glmol<%=randomID %>_src" style="display: none;">
${mol}</textarea>
<div class="form-group input-group" style="margin-bottom: 0px;">
	<span>&nbsp;&nbsp;</span>
	<span class="input-group-addon"><i class="fa fa-eye"></i></span> 
	<select id="glmol<%=randomID %>_hetatm" style="max-width: 30%;" class="form-control ">
		<option selected="selected" value="stick">sticks</option>
		<option value="ballAndStick">ball and stick</option>
		<option value="ballAndStick2">ball and stick (multiple bond)</option>
		<option value="sphere">spheres</option>
		<option value="icosahedron">icosahedrons</option>
		<option value="line">lines</option>
	</select>
	<button class="btn btn-xs" onclick="reload<%=randomID %>()"><i class="fa fa-refresh"></i></button>
	<button class="btn btn-xs" onclick="saveImage<%=randomID %>()"><i class="fa fa-save"></i></button>
</div>
<spring:message code="addon.glMol.poweredBy" text="<small>powered by <a href='http://webglmol.osdn.jp/index-en.html' target='_blank'>GLmol</a>.</small>" />
						</div>
					</div>
				</c:if>
				<c:if test="${not mol_ready}">
					<img class="molStructSVGsmall" src="image/${type}/${inchikey}" alt="${compoundNames.get(0).name}">
				</c:if>

			</td>
			<td style="width: 200px;">Name</td>
			<td>${compoundNames.get(0).name}</td>
		</tr>
		<tr>
			<td>Formula</td>
			<td>${formula}</td>
		</tr>
		<tr>
			<td>Monoisotopic Mass</td>
			<td>${exactMass}</td>
		</tr>
		<tr>
			<td>Average Mass</td>
			<td>${molWeight}</td>
		</tr>
		<c:if test="${mol_ready}">
		<tr>
			<td>Download</td>
			<td>
				<a class="btn btn-primary" href="mol/${inchikey}.mol" title="${compoundNames.get(0).name}" target="_blank">
					Mol <i class="fa fa-download"></i>
				</a>
			</td>
		</tr>
		</c:if>
	</table>


	<table class="table">
		<tr>
			<td>Smile</td>
			<td>${smiles}</td>
		</tr>
		<c:if test="${not empty inchi}">
		<tr>
			<td>InChI</td>
			<td>${inchi}</td>
		</tr>
		</c:if>
		<tr>
			<td>InChIKey</td>
			<td>${inchikey}</td>
		</tr>
	</table>

	<div class="panel panel-default" style="margin: 20px;">
		<div class="panel-heading"><spring:message code="modal.show.names" text="Names" /></div>
		<ul class="list-group" id="cc_listName" style="margin-bottom: 0px;">
													<c:forEach var="compoundName" items="${compoundNames}">
													<li id="compundName_${compoundName.id}" class="list-group-item">
														<span class="badge">${compoundName.score}</span>
														${compoundName.name}
														<span id="compundName_${compoundName.id}_score" class="pull-right">
														<i class="vote0">&nbsp;&nbsp;</i>
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
												</ul>
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
						</div>
	</div>

	<table class="table">
		<c:if test="${not empty pubchem}">
		<tr>
			<td style="width: 100px;"><spring:message code="modal.show.inOtherDatabases.pubchem" text="PubChem" /></td>
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
					<a href="<spring:message code="resources.banklink.kegg" text="http://www.genome.jp/dbget-bin/www_bget?cpd:" />${kegg}" target="_blank">${kegg}</a>
				</c:forEach>
			</td>
		</tr>
		</c:if>
		<c:if test="${not empty networks}">
		<tr>
			<td><spring:message code="modal.show.inOtherDatabases.networkIds" text="Networks IDs" /></td>
			<td>
				<c:forEach var="network" items="${networks}">
					${kegg}
				</c:forEach>
			</td>
		</tr>
		</c:if>
	</table>

	<div><!-- citations -->
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
	</div>
	<div id="newCitation" style="width: 650px; margin: auto;"><br></div>

	<div><!-- user cutation message -->
		<c:if test="${not empty waitingCurationMessageUser}">
			<table class="table ">
				<c:forEach var="curationMessage" items="${waitingCurationMessageUser}">
					<tr class="warning">
						<td>${curationMessage.message}</td>
					</tr>
				</c:forEach>
			</table>
		</c:if>
	</div>
	<div id="newCurationMessage" style="width: 650px; margin: auto;"><br></div>
	<div id="curationBoxDiv" class="input-group" style="display:none;">
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
	</div>
	<div id="citationBoxDiv" class="input-group" style="display:none;">
		<span class="input-group-addon" style="width: 200px;">
				<i class="fa fa-plus-circle"></i> <spring:message code="modal.show.citation.newCitation" text="New citation" />
		</span> 
			<span>
			<input type="text" id="cc_addNewCitationID" style="width: 400px;" class="form-control pull-left" placeholder="<spring:message code="modal.show.citation.newCitation.id" text="PUBMED id or doi" />">
		</span>
		<span class="input-group-btn " style="width: 50px;">  
			<span class="input-group-btn">
				<button class="btn btn-default" type="button" onclick="addNewCitationAction();" style="border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-top-left-radius: 0px; border-bottom-left-radius: 0px"><i class="fa fa-plus-square"></i></button>
			</span>
		</span>
	</div>

	<button type="button" onclick="hideShowCitationBox();"
		class="btn btn-info pull-left" style="margin: 10px;">Add bibliographic ref.</button>
	<button type="button" onclick="hideShowCurationBox();"
		class="btn btn-warning pull-left" style="margin: 10px;">Add curation message</button>
	<button type="button" onclick="updateCurrentCompound('${type}', ${id});" class="btn btn-success pull-right" style="margin: 10px;">
		<i class="fa fa-save"></i> Validate
	</button>

	<br />

	<script type="text/javascript">
	hideShowCurationBox = function () {
		if($("#curationBoxDiv").css("display") == "none") {
			$("#curationBoxDiv").show();
			$("#citationBoxDiv").hide();
		} else {
			$("#curationBoxDiv").hide();
		}
	}
	
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
	
	
	hideShowCitationBox = function () {
		if($("#citationBoxDiv").css("display") == "none") {
			$("#citationBoxDiv").show();
			$("#curationBoxDiv").hide();
		} else {
			$("#citationBoxDiv").hide();
		}
	}
	
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
	
	var updateScores = new Object();
	var newCompoundNames = new Object();
	var newCurrationMessagesList = [];
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
					// reset form
					$('#add-one-cc-s1-value').val("");
					$("#divStep2").hide();
					$("#divStep3").hide();
					var alert = '<div class="alert alert-success alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.success" text="Success!" /></strong> Compound successfully updated!';
					alert += '<br /><a href="?PFc='+id+'">Click to view it</a>.';
					alert += ' </div>';
					$("#alertBoxAddOneCC").html(alert);
// 					alert('<spring:message code="modal.show.alert.failUpdate" text="Failed to update compound!" />'); 
				} else {
					var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
					alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
					alert += '<strong><spring:message code="alert.strong.error" text="Error!" /></strong> Failed to update the Compound!';
					alert += ' </div>';
					$("#alertBoxAddOneCC").html(alert);
// 					alert('<spring:message code="modal.show.alert.failUpdate" text="Failed to update compound!" />'); 
				}
			}, 
			error : function(data) {
				console.log(data);
			}
		});
	};
	</script>

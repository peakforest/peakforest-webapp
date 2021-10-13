<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<div id="molviewer" style="display:none"></div>
<div id="molviewerLoading"><h3>loading...</h3></div>
<div id="">
	<!-- <button class="btn btn-xs" onclick="Jmol.script(molviewer,'refresh;');"><i class="fa fa-refresh"></i></button> -->
	<button class="btn btn-xs" onclick="Jmol.saveImage(molviewer,'png');">
		<i class="fa fa-save"></i>
	</button>
	<button class="btn btn-xs" onclick="spinMol()">
		<i id="molviewer-spin" class="fa fa-refresh"></i>
	</button>
	<button class="btn btn-xs" onclick="vibrMol()">
		<i id="molviewer-vibr" class="fa fa-spinner"></i>
	</button>
	<br />
	<spring:message code="addon.jsMol.poweredBy"
		text="<small>powered by <a href='http://www.jmol.org' target='_blank'>JSmol</a>.</small>" />
</div>
<div style="display: none" id="jmol_infodiv" class="debug jmol_infodiv"></div>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmoljQueryExt.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmolCore.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmolApplet.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmolApi.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmolControls.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/j2sjmol.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmol.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmolMenu.js" />"></script> --%>
<%-- <script type="text/javascript" src="<c:url value="/resources/js/JSmol/js/JSmolJSV.js" />"></script> --%>
<script type="text/javascript" src="<c:url value="/resources/js/JSmol/JSmol.min.js" />"></script>
<script type="text/javascript">
	var molviewer;
	refreshJSmol = function() {
		setTimeout(function() {
			try {
				Jmol.script(molviewer, 'refresh;');
				if (!$("#molviewer_canvas2d").hasClass('debug'))
					$("#molviewer_canvas2d").addClass('debug');
			} catch (e) {
			}
		}, 250);
	}
	vibrMol = function() {
		if ($("#molviewer-vibr").hasClass("fa-spin")) {
			Jmol.script(molviewer, 'vibration on off; refresh;');
			$("#molviewer-vibr").removeClass("fa-spin");
		} else {
			Jmol.script(molviewer, 'vibration on on; refresh;');
			$("#molviewer-vibr").addClass("fa-spin");
		}

	}
	spinMol = function() {
		if ($("#molviewer-spin").hasClass("fa-spin")) {
			Jmol.script(molviewer, 'spin off; refresh;');
			$("#molviewer-spin").removeClass("fa-spin");
		} else {
			Jmol.script(molviewer, 'spin on; refresh;');
			$("#molviewer-spin").addClass("fa-spin");
		}

	}
	$(document).ready(function() {
		setTimeout(function() {
			var xxxx = "${fn:escapeXml(spectrum_sample_compound_name)}";
			var script = 'set errorCallback "myCallback";'
				+ 'set zoomlarge false;set echo top left;echo loading XXXX...;refresh;';
			script = script.replace(/XXXX/g, xxxx)
			var Info = {
				width : 400,
				height : 400,
				script : script,
				use : "HTML5",
				jarPath : "java",
				j2sPath : "resources/js/JSmol/j2s",
	// 			jarFile : "JmolAppletSigned.jar",
				isSigned : false,
				addSelectionOptions : false,
	// 			serverURL : "http://chemapps.stolaf.edu/jmol/jsmol/php/jsmol.php",
				readyFunction : null,
// 				console : "jmol_infodiv",
				disableInitialConsole : true,
				defaultModel : null,
				debug : false
			}
			$("#molviewer").html(Jmol.getAppletHtml("molviewer", Info));
	<% 
				String molName2 = request.getAttribute("spectrum_sample_compound_name").toString().replaceAll("\"", "''");
				request.setAttribute("spectrum_sample_compound_name2", molName2);
	%>
			molviewer = Jmol.getApplet("molviewer", Info);
			setTimeout( function() {
					Jmol.loadFile(molviewer, "numbered/${spectrum_sample_compound_inchikey}.mol");
					// <c:forEach var="mol_nb_3D_script" items="${mol_nb_3D_scripts}">
					Jmol.script(molviewer,"${mol_nb_3D_script}"); // </c:forEach>
					Jmol.script(molviewer, "set echo top center;echo \"${fn:escapeXml(spectrum_sample_compound_name2)}\"; refresh;");
					$("#molviewerLoading").remove();
					$("#molviewer").show()
					$("#molviewer").click();
					if (!$("#molviewer_canvas2d").hasClass('debug'))
						$("#molviewer_canvas2d").addClass('debug');
			}, 500);
		}, 500);
	});
		
		
</script>
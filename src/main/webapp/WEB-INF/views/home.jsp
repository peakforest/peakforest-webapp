<%@page import="org.springframework.security.core.context.SecurityContextHolder"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page session="false" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="author" content="MetaboHUB">
<!--favicon-->
<link rel="icon" type="image/ico" href="<c:url value="/resources/ico/favicon.ico" />" />
<script type="text/javascript">if(localStorage.loginURL!="undefined"){t=localStorage.loginURL;localStorage.loginURL=undefined;document.location.href=t;}</script>
<%
if (request.getParameter("cpd")!=null) {
	Object id = request.getParameter("cpd");
	pageContext.setAttribute("cpdId", id);
	%><jsp:include page="${request.contextPath}/data-ranking-compound/${cpdId}" /><%
} else if (request.getParameter("PFc")!=null) {
	Object id = request.getParameter("PFc");
	pageContext.setAttribute("cpdId", id);
	%><jsp:include page="${request.contextPath}/data-ranking-compound/${cpdId}" /><%
} else if (request.getParameter("PFs")!=null) {
	Object id = request.getParameter("PFs");
	pageContext.setAttribute("sptId", id);
	%><jsp:include page="${request.contextPath}/data-ranking-spectrum/${sptId}" /><%
} else if (request.getParameter("pf")!=null) {
	Object id = request.getParameter("pf");
	response.sendRedirect("home?PFs=" + id); 
	%><jsp:include page="${request.contextPath}/data-ranking-spectrum/${sptId}" /><%
} else {
%>
<c:if test="${not ranking_data}">
<title><spring:message code="home.title" text="PeakForest" /></title>
<meta name="keywords" content="spectral database, mass spectrometry, nmr, lc-ms, gc-ms, chemical, metabolomic, compound, library">
<meta name="description" content="PeakForest is a spectral data portal for Metabolomics community. It provides storage and annotation services for metabolic profils of biological matrix. It relies on the wide range of complementary methods using UPLC-(API)HRMS, GC-QToF, and NMR.">
</c:if>
<c:if test="${ranking_data}">
<title>${page_title}</title>
<meta name="keywords" content="${page_keyworks}">
<meta name="description" content="${page_description}">
</c:if>
<% } %>
<!-- Bootstrap core CSS -->
<link href="<c:url value="/resources/css/bootstrap.min.css" />" rel="stylesheet">
<!--[if lt IE 8]>
    <link href="<c:url value="/resources/css/bootstrap-ie7.min.css" />" rel="stylesheet">
<![endif]-->
<!-- Add custom CSS here -->
<link href="<c:url value="/resources/css/sb-admin.min.css" />" rel="stylesheet">
<link rel="stylesheet" href="<c:url value="/resources/font-awesome/css/font-awesome.min.css" />">
<!-- Bootstrap core JavaScript -->
<script src="<c:url value="/resources/js/jquery.min.js" />"></script>
<script src="<c:url value="/resources/js/bootstrap.min.js" />"></script>
<!-- file upload -->
<script src="<c:url value="/resources/js/bootstrap.file-input.min.js" />"></script>
<!-- autocomplete -->
<script src="<c:url value="/resources/js/bootstrap-typeahead.min.js" />"></script>
<!--switch-->
<script src="<c:url value="/resources/js/bootstrap-switch.min.js" />"></script>
<link href="<c:url value="/resources/css/bootstrap-switch.min.css" />" rel="stylesheet" media="screen">
<!--combobox-->
<link href="<c:url value="/resources/css/bootstrap-combobox.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-combobox.min.js" />" type="text/javascript"></script>


<% if ( (request.getParameter("page") != null && request.getParameter("page").equalsIgnoreCase("tools")) || (request.getParameter("page") == null && request.getParameter("PFc")!=null )) { %>
<!--multiselect-->
<link href="<c:url value="/resources/css/bootstrap-multiselect.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-multiselect.min.js" />" type="text/javascript"></script>
<script type="text/javascript" src="<c:url value="/resources/metExploreViz/metexploreviz.js" />" charset="utf-8"></script>
<script type="text/javascript" src="<c:url value="/resources/metExploreViz/resources/lib/d3.js/d3.min.js" />"></script>
<% } %>

<!--dropdown multi select-->
<link href="<c:url value="/resources/css/bootstrap-select.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-select.min.js" />" type="text/javascript"></script>
<!--date picker-->
<link href="<c:url value="/resources/css/bootstrap-datepicker.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-datepicker.min.js" />" type="text/javascript"></script>
<!--sliders-->
<link href="<c:url value="/resources/css/bootstrap-slider2.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-slider2.min.js" />" type="text/javascript"></script>
<!--template-->
<script src="<c:url value="/resources/js/jquery.tmpl.min.js" />" type="text/javascript"></script>
<!-- slider -->
<!-- <script src="js/jquery-ui-1.10.3.mouse_core.js"></script>
<script src="js/jquery.ui.touch-punch.js"></script>
<script src="js/bootstrapslider.js"></script>-->
<!-- CSS template:
     many thanks to http://startbootstrap.com/sb-admin  
     & twitter bootstrap v3
-->
<% if (request.getParameter("page")==null || (request.getParameter("page")!=null && (!request.getParameter("page").equalsIgnoreCase("backoffice"))&&(!request.getParameter("page").equalsIgnoreCase("stats")))) { %>
<!--JS-->
<script src="<c:url value="/resources/highcharts/js/highcharts.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/modules/exporting.min.js" />"></script>
<script src="<c:url value="/resources/highcharts/js/themes/grid.min.js" />"></script>
<% } %>
<!-- custom css -->
<link href="<c:url value="/resources/css/bootstrap.overwrite.min.css" />" rel="stylesheet" media="screen">
<!-- custom js/jquery -->
<script src="<c:url value="/resources/js/peakforest.min.js" />"></script>
<!-- JS mol 3D -->
<script type="text/javascript" src="<c:url value="/resources/js/Three49custom.min.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/GLmol.min.js" />"></script>
<!-- table -->
<script type="text/javascript" src="<c:url value="/resources/js/tablesorter/jquery.tablesorter.min.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/tablesorter/tables.min.js" />"></script>
<!-- NMRPro -->
<link rel="stylesheet" href="<c:url value="/resources/nmrpro/specdraw.min.css" />" type="text/css">
<!-- web semantic -->
<script type="text/javascript" src="<c:url value="/resources/js/web-semantic/discovery-web.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/web-semantic/metabolights.js" />"></script>
</head>
<body>
	<div id="wrapper">
		<!-- Sidebar -->
		<jsp:include page="block/header.jsp" />
		<!-- content -->
		<div id="page-wrapper" class="peakforest-main-wrapper">
		<div id="demo-webapp" style="max-width: 600px;"></div>
		<% 
	User user = null;
	if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
		user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
	}
	if (request.getParameter("page")!=null) {
		// CONFIRMED USER
		if (request.getParameter("page").equalsIgnoreCase("add-compounds") && user != null && user.isConfirmed()) {
			%><jsp:include page="pages/add-compounds.jsp" /><%
		} else if (request.getParameter("page").equalsIgnoreCase("add-spectrum") && user != null && user.isConfirmed()) {
			%><jsp:include page="pages/add-spectrum.jsp" /><%
		} else if (request.getParameter("page").equalsIgnoreCase("annotate") && user != null && user.isConfirmed()) {
			%><jsp:include page="pages/annotate.jsp" /><%
			// CURATOR USER
		} else	if (request.getParameter("page").equalsIgnoreCase("curation") && user != null && user.isCurator()) {
			%><jsp:include page="pages/curation.jsp" /><%
			// ADMIN USER
		} else	if (request.getParameter("page").equalsIgnoreCase("backoffice") && user != null && user.isAdmin()) {
			%><jsp:include page="pages/backoffice.jsp" /><%
			// ALL USERS
		} else if (request.getParameter("page").equalsIgnoreCase("stats")) {
			%><jsp:include page="pages/stats.jsp" /><%
		} else if (request.getParameter("page").equalsIgnoreCase("tools")) {
			%><jsp:include page="pages/tools.jsp" /><%
		} else if (request.getParameter("page").equalsIgnoreCase("template")) {
			%><jsp:include page="pages/template.jsp" /><%
		} else if (request.getParameter("page").equalsIgnoreCase("peakmatching")) {
			%><jsp:include page="pages/peakmatching.jsp" /><%
		} else if (request.getParameter("page").equalsIgnoreCase("500")) {
			%><jsp:include page="pages/500.jsp" /><%
		} else {
			%><jsp:include page="pages/404.jsp" /><%
		}
		%>
			<script type="text/javascript">
				$("#navmenulink-<%=request.getParameter("page") %>").addClass("active");
				var e = $("#navmenulink-<%=request.getParameter("page") %>");
				if ($(e).parent().length != 0 && $(e).parent().hasClass("dropdown-menu"))
					$(e).parent().parent().addClass("open");
			</script>
		<%
	} else if (request.getParameter("cpd")!=null) {
		Object id = request.getParameter("cpd");
		pageContext.setAttribute("cpdId", id);
		%><jsp:include page="${request.contextPath}/sheet-compound/${cpdId}" /><%
	} else if (request.getParameter("PFc")!=null) {
		Object id = request.getParameter("PFc");
		pageContext.setAttribute("cpdId", id);
		%><jsp:include page="${request.contextPath}/sheet-compound/${cpdId}" /><%
	} else if (request.getParameter("PFs")!=null) {
		Object id = request.getParameter("PFs");
		pageContext.setAttribute("sptId", id);
		%><jsp:include page="${request.contextPath}/sheet-spectrum/${sptId}" /><%
	} else {
		// default : home
		%><jsp:include page="pages/search.jsp" />
			<script type="text/javascript">
			  $("#navmenulink-search").addClass("active");	  
			</script>
		<%
	}
		%>
		</div>
	</div>
	<!-- /#wrapper -->
	<!--bottom fixed navbare-->
	<jsp:include page="block/footer.jsp" />
<c:if test="${not empty registerErrorCause}">
	<script type="text/javascript">var registerError = true; var registerErrorString = "${registerErrorCause}"; $("#linkLoginModalBox").click();</script>
</c:if>
<c:if test="${not empty loginErrorCause}">
	<script type="text/javascript">var loginError = true; var loginErrorString = "${loginErrorCause}"; $("#linkLoginModalBox").click();</script>
</c:if>
<c:if test="${not empty showModalID}">
	<script type="text/javascript">var showModal = true; var showModalID = "${showModalID}"; $("#"+showModalID).click();</script>
</c:if>
</body>
</html>
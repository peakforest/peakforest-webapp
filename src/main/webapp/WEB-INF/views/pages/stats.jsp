<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<%@ page import="fr.metabohub.peakforest.utils.Utils"%>
<%
boolean useMEwebservice = Boolean.parseBoolean(Utils.getBundleConfElement("metexplore.ws.use"));
boolean useWS = Boolean.parseBoolean(Utils.getBundleConfElement("use.peakforest.webservices"));
%>
<div class="row">
	<div class="col-lg-12">
		<ul class="nav nav-tabs" style="margin-bottom: 15px;">
			<li class="active"><a href="#stats-peakforest" data-toggle="tab"><i class="fa fa-info-circle"></i> <spring:message code="page.tools.tag.statsPF" text="Stats PeakForest" /></a></li>
<% if (useMEwebservice) { %>
			<li><a id="linkMetExploreStats" href="#stats-metexplore" data-toggle="tab"><i class="fa fa-pie-chart"></i> <spring:message code="page.tools.tag.statsME" text="Stats MetExplore" /></a></li>
<% } %>
			<li><a id="linkMassVsLogP" href="#mass-vs-logp" data-toggle="tab"><i class="fa fa-area-chart"></i> <spring:message code="page.tools.tag.massVSlogP" text="Mass Vs LogP" /></a></li>
<% if (useWS) { %>
			<li><a href="#ws-peakforest" data-toggle="tab"><i class="fa fa-exchange"></i> <spring:message code="page.tools.tag.wsPF" text="WebService PeakForest" /></a></li>
			<li><a href="#galaxy-client" data-toggle="tab"><i class="fa fa-sitemap fa-rotate-270"></i> <spring:message code="page.tools.tag.galaxyClient" text="Galaxy Client" /></a></li>
<% } %>
		</ul>
		<div id="div-tools" class="tab-content" style="max-width: 1000px;" >
			<div class="tab-pane fade active in" id="stats-peakforest">
<jsp:include page="tools-peakforest.jsp" />
			</div>
<% if (useMEwebservice) { %>
			<div class="tab-pane fade" id="stats-metexplore">
<jsp:include page="tools-metexplore.jsp" />
			</div>
<% } %>
<% if (useWS) { %>
			<div class="tab-pane fade" id="ws-peakforest">
<jsp:include page="tools-ws-peakforest.jsp" />
			</div>
			<div class="tab-pane fade" id="galaxy-client">
<jsp:include page="tools-galaxy-client.jsp" />
			</div>
<% } %>
			<div class="tab-pane fade" id="mass-vs-logp">
<jsp:include page="tools-mass-vs-logp.jsp" />
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
if (document.location.href.endsWith("#stats-metexplore")) {
	$("#linkMetExploreStats").click();
}
<% if (request.getParameter("logp") != null) { %>
$("#linkMassVsLogP").click();
<% } %>
</script>
<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/md5.min.js" />"></script>

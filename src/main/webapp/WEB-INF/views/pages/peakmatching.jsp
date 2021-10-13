<%@page import="org.springframework.security.core.context.SecurityContextHolder"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<%@ page import="fr.metabohub.peakforest.utils.Utils"%>
<div class="row">
	<div class="col-lg-12">
		<ul class="nav nav-tabs" style="margin-bottom: 15px;">
			<li class=""><a id="link-pm-lcms" href="#peakmatching-lcms" data-toggle="tab"><i class="fa fa-bar-chart-o"></i> <spring:message code="page.peakmatching.title.lcms" text="LC-MS" /></a></li>
			<li class=""><a id="link-pm-nmr" href="#peakmatching-nmr" data-toggle="tab"><i class="fa fa-bar-chart-o fa-flip-horizontal"></i> <spring:message code="page.peakmatching.title.nmr" text="NMR" /></a></li>
		</ul>
		<div id="peakmatching" class="tab-content" style="">
			<div class="tab-pane fade active in" id="peakmatching-all">
				<br />
				<br />
				<br />			
<% 
User user = null;
if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
	user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
}

boolean displayNMRfirst = false;
boolean isNMRbtnDisplayed = false;
if (user !=null && user.getMainTechnology() == User.PREF_NMR) {
	displayNMRfirst = true;
}
if (displayNMRfirst) {
%>
				<div class="col-lg-6">
					<button id="run-pm-nmr" type="button" class="btn btn-primary btn-lg" onclick="$('#link-pm-nmr').click();" style="margin: 10px;">
						<h3>
							<i class="fa fa-bar-chart-o fa-flip-horizontal"></i> NMR peak matching &nbsp;
						</h3>
					</button>
				</div>
<%
	isNMRbtnDisplayed = true;
}
%>

				<div class="col-lg-6">
					<button id="run-pm-lcms" type="button" class="btn btn-primary btn-lg" onclick="$('#link-pm-lcms').click();" style="margin: 10px;">
						<h3>
							<i class="fa fa-bar-chart-o"></i> LC-MS peak matching &nbsp;
						</h3>
					</button>
				</div>
<%
if (!isNMRbtnDisplayed) {
%>
				<div class="col-lg-6">
					<button id="run-pm-nmr" type="button" class="btn btn-primary btn-lg" onclick="$('#link-pm-nmr').click();" style="margin: 10px;">
						<h3>
							<i class="fa fa-bar-chart-o fa-flip-horizontal"></i> NMR peak matching &nbsp;
						</h3>
					</button>
				</div>
<%
}
%>
			</div>
			<div class="tab-pane fade " id="peakmatching-nmr">
				<!-- peakmatching NMR -->
				<jsp:include page="peakmatching-nmr.jsp" />
			</div>
			<div class="tab-pane fade " id="peakmatching-lcms">
				<!-- peakmatching LCMS -->
				<jsp:include page="peakmatching-lcms.jsp" />
			</div>
		</div><!-- /.peakmatching -->
	</div>
</div>
<!-- /.row -->

<!-- SPECTRA - PREVIEW -->
<div class="modal " id="modalShowSpectra" tabindex="-1" role="dialog" aria-labelledby="modalShowSpectraLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalShowSpectraLabel">Modal title</h4>
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
<!-- /.modal SPECTRA -->
<script src="<c:url value="/resources/js/peakforest/search.min.js" />"></script>
<script type="text/javascript">
<% if (request.getParameter("searchNMR") != null && request.getParameter("searchNMR") != "") { %>
$("#link-pm-nmr").click();
<% } %>
<% if (request.getParameter("searchLCMS") != null && request.getParameter("searchLCMS") != "") { %>
$("#link-pm-lcms").click();
<% } %>
var Utils_SEARCH_COMPOUND_AVERAGE_MASS = "<%=Utils.SEARCH_COMPOUND_AVERAGE_MASS %>";
var Utils_SEARCH_COMPOUND_MONOISOTOPIC_MASS = "<%=Utils.SEARCH_COMPOUND_MONOISOTOPIC_MASS %>";
var Utils_SEARCH_COMPOUND_FORMULA = "<%=Utils.SEARCH_COMPOUND_FORMULA %>";

</script>
<script src="<c:url value="/resources/js/md5.min.js" />"></script>
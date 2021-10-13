<%@page import="org.springframework.security.core.context.SecurityContextHolder"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
	<!-- Brand and toggle get grouped for better mobile display -->
	<div class="navbar-header">
		<button type="button" class="navbar-toggle" data-toggle="collapse"
			data-target=".navbar-ex1-collapse">
			<span class="sr-only">Toggle navigation</span> <span class="icon-bar"></span>
			<span class="icon-bar"></span> <span class="icon-bar"></span>
		</button>
		<a class="navbar-brand" href="<c:url value="/home" />"><spring:message code="block.header.home" text="PeakForest" /></a>
	</div>

	<%
		User user = null;
		if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof User) {
			user = ((User) SecurityContextHolder.getContext().getAuthentication().getPrincipal());
		}
	%>

	<!-- Collect the nav links, forms, and other content for toggling -->
	<div class="collapse navbar-collapse navbar-ex1-collapse">
		<ul class="nav navbar-nav side-nav">
			<li id="navmenulink-search"><a href="<c:url value="/home" />"><i
					class="fa fa-search"></i> <spring:message code="block.header.search" text="Search" /></a></li>
			<li id="navmenulink-peakmatching">
				<a href="<c:url value="/home" />?page=peakmatching"><i class="fa fa-eye"></i> <spring:message code="block.header.peakmatching" text="Peak Matching" /></a></li>
			<% if(user != null && user.isConfirmed()){ %>
			<li class="dropdown"><a href="#" class="dropdown-toggle"
				data-toggle="dropdown"><i class="fa fa-plus"></i> <spring:message code="block.header.add" text="Add ..." /> <b
					class="caret"></b></a>
				<ul class="dropdown-menu">
					<li id="navmenulink-add-compounds">
						<a href="<c:url value="/home" />?page=add-compounds">
							<i class="fa fa-plus-circle"></i> <spring:message code="block.header.addChemicalCompound" text="Chemical Compound" />
						</a>
					</li>
					<li id="navmenulink-add-spectrum">
						<a href="<c:url value="/home" />?page=add-spectrum">
							<i class="fa fa-plus-circle"></i> <spring:message code="block.header.addSpectrum" text="Spectrum" /></a></li>
				</ul>
			</li>
			
			<% } %>
			<li id="navmenulink-stats"><a href="<c:url value="/home" />?page=stats"><i class="fa fa-info-circle"></i> <spring:message code="block.header.statsAndApi" text="Stats and API" /></a></li>
			<li id="navmenulink-tools"><a href="<c:url value="/home" />?page=tools"><i class="fa fa-wrench"></i> <spring:message code="block.header.tools" text="Tools" /></a></li>
			<% if(user != null && user.isCurator()){ %>
<%-- 			<li id="navmenulink-annotate"><a href="<c:url value="/home" />?page=annotate"><i --%>
<%-- 					class="fa fa-cogs"></i> <spring:message code="block.header.annotate" text="Annotage" /></a></li> --%>
			<li id="navmenulink-curation"><a href="<c:url value="/home" />?page=curation">
				<i class="fa fa-university"></i> <spring:message code="block.header.curation" text="Curation" /></a></li>
			<% }
			if(user != null && user.isAdmin()){ %>
			<li id="navmenulink-backoffice"><a
				href="<c:url value="/home" />?page=backoffice"><i class="fa fa-cog"></i>
					Backoffice</a></li>
			<% } %>
		</ul>

		<ul class="nav navbar-nav navbar-right navbar-user">
			<li class="dropdown lang-dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown" id="currentLanguage">${pageContext.response.locale} <b class="caret"></b></a>
				<ul class="dropdown-menu">
				<c:set var="localeCode" value="${pageContext.response.locale}" />
				<%
					Object ob_localeCode = pageContext.getAttribute("localeCode");
					String markupFr = "";
					String markupEn = "";
					if (ob_localeCode != null) {
						String currentLanguageCode = ob_localeCode.toString();
						if (currentLanguageCode.equalsIgnoreCase("fr")) {
							markupFr = "<i class=\"fa fa-check\"></i>";
						} else {
							markupEn = "<i class=\"fa fa-check\"></i>";
						}
					}
				%>
					<li><a href="?language=en">En <%=markupEn %></a></li>
					<li><a href="?language=fr">Fr <%=markupFr %></a></li>
				</ul>
				</li>


			<% if (user !=null) { %>
			<li class="dropdown user-dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="fa fa-user"></i> <% out.print(user.getEmail()); %> <b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
<!-- 					<li><a href="#"><i class="fa fa-user"></i> Profile </a></li> -->
					<li><a href="settings-modal" data-toggle="modal" data-target="#mySettingsModal"><i class="fa fa-gear"></i> <spring:message code="block.header.settings" text="Settings" /></a></li>
					<li class="divider"></li>
					<li><a href="j_spring_security_logout"><i class="fa fa-power-off"></i> <spring:message code="block.header.logout" text="Log Out" /></a></li>
				</ul>
			</li>
<% } else { %>
			<li class="dropdown user-dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="fa fa-user"></i> <spring:message code="block.header.loginOrRegister" text="Login or Register" /><b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li>
						<a id="linkLoginModalBox" href="login-modal" data-toggle="modal" data-target="#myLoginModal">
							<i class="fa fa-power-off"></i>
							<spring:message code="block.header.loginSLregister" text="Login / register" />
						</a>
					</li>
				</ul>
			</li>
<% } %>
		</ul>
	</div>
	<!-- /.navbar-collapse -->
</nav>
<!-- Modal login -->
<div class="modal " id="myLoginModal" tabindex="-1" role="dialog" aria-labelledby="myModalLoginLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="myModalLoginLabel"><spring:message code="block.header.loginSLregister" text="Login / register" /></h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
				<!--  <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>-->
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal login -->
<!-- Modal settings -->
<div class="modal " id="mySettingsModal" tabindex="-1" role="dialog" aria-labelledby="myModalSettingsLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="myModalSettingsLabel"><spring:message code="block.header.settings" text="Settings" /></h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
				<!--  <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>-->
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal settings-->
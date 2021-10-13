<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!--bottom fixed navbare-->
<nav class="navbar navbar-default navbar-fixed-bottom navbar-inverse navbar-main" role="navigation">
	<div class="navbar-header navbar-inverse footer">
		<ul id="ul-info-footer" class="nav navbar-nav">
			<li class="li-info-footer"><a id="linkcontact" href="#"><spring:message code="block.footer.contact" text="Contact" /></a></li>
			<li class="li-info-footer">
				<a id="about-peakforest" href="about-peakforest" data-toggle="modal" data-target="#modalAbout"><spring:message code="block.footer.about" text="About" /></a>
			</li>
			<li class="li-info-footer">
				<a href="<spring:message code="link.site.mypeakforest" text="http://peakforest.org" />" target="_blank"><spring:message code="block.footer.myPeakforest" text="My PeakForest" /></a>
			</li>
			<li class="li-info-footer">
				<a href="<spring:message code="link.site.metabohub" text="http://metabohub.fr" />" target="_blank"><spring:message code="block.footer.metaboHUB" text="metaboHUB" /></a>
			</li>
		</ul>
	</div>
</nav>

<!-- Modal about -->
<div class="modal " id="modalAbout" tabindex="-1" role="dialog" aria-labelledby="modalAboutLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalAboutLabel"><spring:message code="block.footer.aboutModal.title" text="About the Peak Forest Database" /></h4>
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

<!-- Modal my peakforest -->
<div class="modal " id="modalMyPeakForest" tabindex="-1" role="dialog" aria-labelledby="modalMyPFLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalAboutLabel"><spring:message code="block.footer.myPeakforestModal.title" text="My Peak Forest Database" /></h4>
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

<jsp:include page="../../../resources/extra-jsp/analytics.jsp" />
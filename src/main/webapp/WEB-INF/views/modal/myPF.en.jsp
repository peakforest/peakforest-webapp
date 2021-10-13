<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>About</title>
<style type='text/css'>
</style>
<script type='text/javascript'>
	//<![CDATA[ 
		if(!window.jQuery) {
			window.location.replace("<spring:message code="peakforest.uri" text="https://peakforest.org/" />myPeakforest");
		}
	//]]>
</script>
</head>
<body>
	<!-- Modal -->
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalAboutLabel"><spring:message code="block.footer.myPeakforestModal.title" text="My Peak Forest Database" /></h4>
			</div>
			<div class="modal-body">
			
				<img style="max-width: 100%;" class="" alt="my peakforest" src="<c:url value="/resources/img/my-peakforest/diag_simple.png" />">
			
				
			</div>
			<div class="modal-footer">
				<a class="btn btn-primary" href="<spring:message code="peakforest.uri" text="https://peakforest.org/" />?page=my-peakforest-more"><i class="fa fa-info-circle"></i> <spring:message code="modal.moreInformations" text="More informations" /></a>
				<button type="button" class="btn btn-default" data-dismiss="modal"><spring:message code="modal.close" text="Close" /></button>
			</div>
		</div>
	</div>

	<!-- /.modal-dialog -->
</body>
</html>
<%@ page import="java.util.Random" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%
Random randomGenerator = new Random();
int randomID = randomGenerator.nextInt(1000000);
%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<title>Spectra - preview</title>
		<style type='text/css'>
		</style>
		<script type='text/javascript'>
			//<![CDATA[ 
		
		
			//]]>
		</script>
	</head>
	<body>
		<div class="modal-dialog">
			<div class="modal-content " style="min-width: 750px">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" onclick="" aria-hidden="true">&times;</button>
					<h4 class="modal-title">Spectra - preview</h4>
				</div>
				<div class="modal-body" id="" >
					
					<div id="divShowSpectra<%=randomID %>" ></div>
					<script type="text/javascript">
						$("#divShowSpectra<%=randomID %>").html('<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />');
						$.get("spectra-light-module/${ids}", function( data ) {
							$("#divShowSpectra<%=randomID %>").html( data );
							console.log("spectrum: ready!");
						});
					</script>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal" onclick=""><spring:message code="modal.close" text="Close" /></button>
	<!-- 				<button type="button" class="btn btn-primary" onclick=""> -->
	<!-- 					<i class="fa fa-xxx"></i> xxx -->
	<!-- 				</button> -->
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	
	</body>
</html>
<%@page import="java.util.Random"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Not Found!</title>
<style type='text/css'>
.fa-star, .fa-star-half-o, .fa-star-o, .vote0 {
    cursor: default!important;
}
</style>

<!-- Bootstrap core CSS -->
<link href="<c:url value="/resources/css/bootstrap.min.css" />" rel="stylesheet">

<!--[if lt IE 8]>
    <link href="<c:url value="/resources/css/bootstrap-ie7.css" />" rel="stylesheet">
<![endif]-->

<!-- Add custom CSS here -->
<link href="<c:url value="/resources/css/sb-admin.min.css" />" rel="stylesheet">
<link rel="stylesheet" href="<c:url value="/resources/font-awesome/css/font-awesome.min.css" />">

<!-- Bootstrap core JavaScript -->
<script src="<c:url value="/resources/js/jquery.min.js" />"></script>
<script src="<c:url value="/resources/js/bootstrap.min.js" />"></script>

<!-- file upload -->
<%-- <script src="<c:url value="/resources/js/bootstrap.file-input.js" />"></script> --%>

<!-- autocomplete -->
<script src="<c:url value="/resources/js/bootstrap-typeahead.js" />"></script>

<!--switch-->
<script src="<c:url value="/resources/js/bootstrap-switch.min.js" />"></script>
<link href="<c:url value="/resources/css/bootstrap-switch.min.css" />" rel="stylesheet" media="screen">

<!--combobox-->
<link href="<c:url value="/resources/css/bootstrap-combobox.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-combobox.js" />" type="text/javascript"></script>

<!--dropdown multi select-->
<link href="<c:url value="/resources/css/bootstrap-select.min.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-select.js" />" type="text/javascript"></script>

<!--date picker-->
<link href="<c:url value="/resources/css/bootstrap-datepicker.css" />" media="screen" rel="stylesheet" type="text/css">
<script src="<c:url value="/resources/js/bootstrap-datepicker.js" />" type="text/javascript"></script>
	
<!--sliders-->
<%-- <link href="<c:url value="/resources/css/bootstrap-slider2.css" />" media="screen" rel="stylesheet" type="text/css"> --%>
<%-- <script src="<c:url value="/resources/js/bootstrap-slider2.js" />" type="text/javascript"></script> --%>
	
<!--template-->
<%-- <script src="<c:url value="/resources/js/jquery.tmpl.js" />" type="text/javascript"></script> --%>

<!-- slider -->
<!--    <script src="js/jquery-ui-1.10.3.mouse_core.js"></script>
<script src="js/jquery.ui.touch-punch.js"></script>
<script src="js/bootstrapslider.js"></script>-->

<!-- CSS template:
     many thanks to http://startbootstrap.com/sb-admin  
     & twitter bootstrap v3
-->

<!--JS-->
<%-- <script src="<c:url value="/resources/highcharts/js/highcharts.min.js" />"></script> --%>
<%-- <script src="<c:url value="/resources/highcharts/js/modules/exporting.min.js" />"></script> --%>
<%-- <script src="<c:url value="/resources/highcharts/js/themes/grid.min.js" />"></script> --%>

<!-- custom css -->
<link href="<c:url value="/resources/css/bootstrap.overwrite.min.css" />" rel="stylesheet" media="screen">

<!-- custom js/jquery -->
<script src="<c:url value="/resources/js/peakforest.min.js" />"></script>

<!-- JS mol 3D -->
<script type="text/javascript" src="<c:url value="/resources/js/Three49custom.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/GLmol.js" />"></script>

<!-- table -->
<script type="text/javascript" src="<c:url value="/resources/js/tablesorter/jquery.tablesorter.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/tablesorter/tables.js" />"></script>

<c:if test="${mol_ready}">
<script type='text/javascript'>
	//<![CDATA[ 
	//]]>
</script>
</c:if>
</head>
<body style="margin-top: 0px!important;">
	<div class="">
		<div class="">
<!-- 			<div class="modal-header"></div> -->
			<div class=" "><!-- modal-body -->
				<div class="te">
					<h5>&nbsp;Sorry, this compound is not in PeakForest database.</h5>
					<h2>(&gt;*-*)&gt;</h2>
					
				</div>
			</div>
<!-- 			<div class="modal-footer"> -->
<!-- 			</div> -->
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</body>
</html>
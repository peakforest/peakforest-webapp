<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<script src="<c:url value="/resources/js/jquery.min.js" />"></script>
<!-- 		<script src="bootstrap.min.js"></script> -->
		<title>NMRPro - light</title>
		<link rel="stylesheet" href="<c:url value="/resources/nmrpro/specdraw.min.css" />" type="text/css">

		<script>
		$( document ).ready(function() {
			loadSpectrum("container_nmrpro", "${id}", "${id}");
		});
		function loadSpectrum (div, id, label) {
		  label = encodeURI ($($.parseHTML(  label )[0]).text())
		  jQuery = jQuery.noConflict();
		  jQuery.when( 
		    jQuery.getScript( "<c:url value="/resources/nmrpro/d3.v3.min.js" />" ),
		    jQuery.getScript( "<c:url value="/resources/nmrpro/specdraw.js" />" ),
		    jQuery.Deferred(function( deferred ){
		      jQuery( deferred.resolve );
		    })
		  ).done(function(){
		      //place your code here, the scripts are all loaded
		      var spec_app = specdraw.App().data('<spring:message code="peakforest.uri" text="https://peakforest.org/" />/spectrum-json/'+id+'?label=' + label); // 
		      d3.select('#'+div).call(spec_app);
		      delete Array.prototype.subset;
		      delete Array.prototype.rotate;
		      delete Array.prototype.rotateTo;
		      delete Array.prototype.whichMax;
		      delete Array.prototype.cumsum;
		  });
		  $ = jQuery.noConflict();
		  setTimeout(function(){$(".column-menu").remove()}, 1000);
		};
		</script>
		<style type="text/css">
			.div_container_nmrpro {
				width:100%;
				min-width:960px;
				height:100%;
			}
			.div_container_nmrpro_wrapper {
				width:100%;
				height:400px;
			}
		</style>
	</head>
	<body>
		<div class="div_container_nmrpro_wrapper">
			<div id="container_nmrpro" class="div_container_nmrpro"></div>
		</div>
	</body>
</html>


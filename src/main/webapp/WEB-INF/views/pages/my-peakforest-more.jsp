<%@page import="fr.metabohub.peakforest.utils.Utils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<div class="row">
	<div class="col-lg-12">
		<h1>
			My PeakForest <small> database</small>
		</h1>
		<p>
<a href="#">PeakForest.org</a> is MetaboHUB’s showcase to provide its reference datum to the whole metabolomics community. 
But PeakForest is also a project with a standardized format available through its Java environment where you can <b>create your own database</b>! 
Thanks to virtualization technologies we are able to quickly deploy and host new instances of this tool. 
Furthermore the PeakForest development team is available to <b>maintain and update</b> new releases of PeakForest on your own instance! 
If you are interested, please <b>contact us</b> :-) !
&lt;<a id="linkcontact2" href="#"></a>&gt;
		</p>
		<p style="text-align: center;">
			<img style="max-width: 50%;" class="" alt="fork your peakforest" src="<c:url value="/resources/img/my-peakforest/diag_fork_pf.png" />">
		</p>
		<p>
<b>Why</b>? 
it’s relevant to create private sub instances of PeakForest <b>specialized</b> in a scientific domain 
(e.g.: the “foodball” project focused on food metabolome) 
or to <b>store and process unpublished results</b>.
		</p>
		<p style="text-align: center;">
			<img style="max-width: 50%;" class="" alt="my peakforest" src="<c:url value="/resources/img/my-peakforest/diag_simple.png" />">
		</p>
		<p>
<b>Data agreement in return</b>: 
the main instance of PeakForest may be enriched thanks to these sub-datasets after result publication or in order to <b>cover wide metabolomics fields</b>.
		</p>
		<p>
			<table>
				<tr>
					<td style="width: 45%"><img style="max-width: 100%;" class="" alt="peakforest.org" src="<c:url value="/resources/img/my-peakforest/diag_offre_service.001.png" />"></td>
					<td style="width: 10%"></td>
					<td style="width: 45%"><img style="max-width: 100%;" class="" alt="my peakforest" src="<c:url value="/resources/img/my-peakforest/diag_offre_service.002.png" />"></td>
				</tr>
				<tr>
					<td>PeakForest.org is the showcase fulfilled with MetaboHUB's datum</td>
					<td></td>
					<td>Get your own instance of PeakForest with your own datum!</td>
				</tr>
			</table>
		</p>
		<p>
Ask your own instance of PeakForest; 
we can even protect it with authentication restriction if needed (results not published, biomedical datum, &hellip;) 
		</p>
	</div>
</div>
<!-- /.row -->
<script>
$(document).ready(function() {
    var a = "";
    a += "@";
    $("#linkcontact2").attr("href", "mailto:contact" + a + "peakforest.org?subject=%5Bmy%20peakforest%20webapp%5D")
    $("#linkcontact2").html("contact" + a + "peakforest.org");
});
</script>
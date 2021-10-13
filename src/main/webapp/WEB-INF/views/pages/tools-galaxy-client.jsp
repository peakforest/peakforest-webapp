<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

Some PeakForest's database functionalities will be available through <a href="https://wiki.galaxyproject.org/Admin/GetGalaxy" target="_blank">Galaxy</a> tools and workflows. <br>
<img style="width: 600px;" src="<c:url value="/resources/img/tools/galaxy_pftool1.png" />" alt="PeakForest in Galaxy" title="PeakForest in Galaxy"> <br />
Please refer to <a href="http://workflow4metabolomics.org/" target="_blank">W4M project</a> for further informations. <br />
<img style="width: 600px;" src="<c:url value="/resources/img/tools/logo-ifb-mono-metabohub_2.1_SD_150px.png" />" alt="W4M banner" title="W4M banner"> <br />

<blockquote>
	<p>
		In order to share metabolomics analysis strategies and centralize tools and practices, 
		the web-based platform Galaxy is the core component of the W4M infrastructure. 
		Galaxy provides several interesting features for metabolomics tools integration compared to other workflow engines. 
		This cross-platform system enables scientist without programming experience to design and run analysis workflows.
	</p>
	<footer class="pull-right">The W4M core team &mdash; <cite title="workflow4metabolomics.org"><a href="http://workflow4metabolomics.org/" target="_blank">workflow4metabolomics.org</a></cite></footer>
</blockquote>
<br />
<hr />
Note: you must generate a token in order to use PeakForest's Galaxy tools (require a PeakForest validated account).
<br />
<img src="<c:url value="/resources/img/peakforest_apikey.png" />" alt="webservice token" title="webservice token" style="max-width: 750px;">

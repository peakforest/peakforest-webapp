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
			window.location.replace("<spring:message code="peakforest.uri" text="https://peakforest.org/:" />aboutPF");
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
				<h4 class="modal-title" id="modalAboutLabel"><spring:message code="block.footer.aboutModal.title" text="About the PeakForest Database" /></h4>
			</div>
			<div class="modal-body">
			
<%-- 				<img style="max-width: 100%;" class="" alt="peakforest functionalities" src="<c:url value="/resources/img/about/logo-mth.png" />"> --%>
			
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">What is the PeakForest Database?</h3>
					</div>
					<div class="panel-body">
						The MetaboHUB PeakForest database provides storage and annotation services for <strong>metabolic profils of biological matrix</strong>. 
						<br />Through its web portal, PeakForest is devoted to the high-throughput annotation and de novo identification of metabolites. 
						<br />It relies on the wide range of complementary methods using UPLC-(API)HRMS, GC-QToF, and NMR provided by the MetaboHUB platforms 
						to perform untargeted metabolomic analyses on biofluids (human plasma and urine), 
						tissue samples (eg, tomato fruit) and cell extracts (eg, E. coli and S. cerevisiae). 
						The MS and NMR spectra of a thousand reference compounds along with the corresponding metadata have already been collected.
					</div>
				</div>
				
				<img style="max-width: 100%;" class="" alt="peakforest functionalities" src="<c:url value="/resources/img/about/PeakForest_functionalities.png" />">
				<br>
				
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Contributors</h3>
					</div>
					<div class="panel-body" style="padding: 0px !important;">
						<ul class="list-group">
							<li class="list-group-item">Franck Giacomoni (INRA, Metabolism Exploration Platform) coordinated the project and Etienne Th&eacute;venot (CEA, The MetabolomeIDF) coordinated the MetaboHUB bioinformatic workpackage.</li>
							<li class="list-group-item">Nils Paulhe (INRA, Metabolism Exploration Platform) headed the API and the webApp developments.</li>
							<li class="list-group-item">Daniel Jacob (INRA, Bordeaux Metabolome Platform ), Etienne Th&eacute;venot, Jean-Fran&ccedil;ois Martin (INRA, The MetaToul platform, Toulouse), Nils Paulhe and Franck Giacomoni defined the specifications for the database and developed the PeakForest structure.</li>
							<li class="list-group-item">Nils Paulhe, Claire Lopez (INRA, Post-doctoral fellow), Daniel Jacob, Pierrick Roger-Mele (CEA, The MetabolomeIDF) and Franck Giacomoni worked on the data model.</li>
							<li class="list-group-item">Claire Lopez, St&eacute;phane Bernillon, Catherine Deborde, Annick Moing (INRA, Bordeaux Metabolome Platform ), C&eacute;cile Canlet, Justine Bertrand-Michel, Laurent Debrauwer (INRA, The MetaToul platform, Toulouse), Christophe Junot, Jean-Claude Tabet (CEA, The MetabolomeIDF), Bernard Lyan, Estelle Pujos-Guillot (INRA, Metabolism Exploration Platform) provided their expertise in chemistry, mass spectrometry and nuclear magnetic resonance for the development of PeakForest.</li>
							<li class="list-group-item">Marie-Fran&ccedil;oise Olivier (CEA, The MetabolomeIDF),  Charlotte Joly and Delphine Centeno (INRA, Metabolism Exploration Platform), Marie Tremblay-Franco, C&eacute;cile Canlet and Emilien Janin, Lindsay Peyrigat (INRA, The MetaToul platform, Toulouse),  Catherine Deborde and Vanessa Zhendre (INRA, Bordeaux Metabolome Platform ) compiled and evaluated original data of PeakForest chemical library.</li>
							<li class="list-group-item">Christophe Duperier (INRA, Metabolism Exploration Platform) for computing facilities (databases and web servers).</li>
							<li class="list-group-item">Marie Lefevbre (INRA, Bordeaux Metabolome Platform ) and Daniel Jacob for NMR Peak Matching algorithm and webservices.</li>
							<li class="list-group-item">Marion Landi (INRA, Metabolism Exploration Platform) for BiH Peak Matching tool.</li>
							<li class="list-group-item">Nils Paulhe, Benjamin Merlet, Florence Vison and Fabien Jourdan (INRA, Toxalim Unit) for PeakForest mapping on MetExplore.</li>
							<li class="list-group-item">For the alpha version, beta testers are:  Charlotte Joly, Claire Lopez, Sylvain Emery, C&eacute;cile Canlet, Emilien Janin, Lindsay Peyrigat, C&eacute;cile Cabasson, Julie Pinelli, Alyssa Bouville, L&eacute;a Roch, and Ulli Hohenester.</li>		
						</ul>
					</div>
				</div>
				
<!-- 				<div class="panel panel-default"> -->
<!-- 					<div class="panel-heading"> -->
<!-- 						<h3 class="panel-title">TITLE</h3> -->
<!-- 					</div> -->
<!-- 					<div class="panel-body"> -->
<!-- 						DATA -->
<!-- 					</div> -->
<!-- 				</div> -->
				
<!-- 				<div class="panel panel-default"> -->
<!-- 					<div class="panel-heading"> -->
<!-- 						<h3 class="panel-title">TITLE</h3> -->
<!-- 					</div> -->
<!-- 					<div class="panel-body"> -->
<!-- 						DATA -->
<!-- 					</div> -->
<!-- 				</div> -->
			
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Software and Technologies</h3>
					</div>
					<div class="panel-body">
						The current page is using a <a href="http://getbootstrap.com/" target="_blank">bootstrap</a> (Code licensed under MIT) template provided by 
						<a href="http://startbootstrap.com/sb-admin" target="_blank">Start bootstrap</a> (license Apache 2.0). 
<!-- 						<br /> The spectra analyse and processing use a -->
<!-- 						Galaxy workflow created and provided by MetaboHUB project. -->
						<br />The web-application is based on <a href="http://projects.spring.io/spring-framework/" target="_blank">Spring Framework</a> (Apache License 2.0) 
						and use <a href="http://openbabel.org/" target="_blank">Open Babel</a> (GNU General Public License) to compute and recover compounds chemical properties.
						<br />The molecules 3D display on webpages are powered thanks <a href="http://webglmol.osdn.jp/" target="_blank">GLmol</a> (dual license of LGPL3 or MIT license) and <a href="http://www.jmol.org" target="_blank">JSmol</a> (GNU Lesser General Public License). 
						<br />The basic spectra and data viewers use <a href="http://www.highcharts.com/" target="_blank">HighChart</a> libraries (Creative Commons Attribution-NonCommercial 3.0 License, free for non-commercial website).
						<br />The NMR spectra viewers using raw data are powered thanks "NMR viewer for PeakForest" by Marie Lefebvre and Daniel Jacob (based on <a href="https://bitbucket.org/sbeisken/specktackle/" target="_blank">Specktackle</a>, using <a href="https://cran.r-project.org/" target="_blank">R-Base</a> in back-end).
						<br />The table displayed with spreadsheet-like formatting are powered thanks <a href="http://handsontable.com/" target="_blank">Handsontable</a> (MIT license).
						<hr style="margin-top: 5px; margin-bottom: 5px;" />
							MetExploreViz is a tool to visualize metabolic network. 
							It allows to map "omics" data and to interact with metabolic networks. 
							It is usable as a javascript library via the MetExplore web server or within your website. 
							For further information please refer to <a href="http://metexplore.toulouse.inra.fr/metexploreViz/doc/documentation.php" target="_blank">MetExploreViz documentation</a> 
							and the <a href="https://doi.org/10.1093/bioinformatics/btx588" target="_blank">Bioinformatics publication</a>.
						<br />Powered by the <!-- amazing --> <a href="http://metexplore.toulouse.inra.fr/metexploreViz/doc/team.php" target="_blank">MetExplore Team</a>.
					</div>
				</div>
				
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Partners and supports</h3>
					</div>
					<div class="panel-body">
						<img style="max-width: 250px;" class="" alt="Logo MetaboHUB" src="<c:url value="/resources/img/about/logo-mth.png" />">
						<br />
						<strong>MetaboHUB</strong> is a national infrastructure of metabolomics and fluxomics that provides tools and services to academic research teams 
						and industrial partners in the fields of health, nutrition, agriculture, environment and biotechnology.
						<br />For further informations, please visit <a href="<spring:message code="link.site.metabohub" text="http://metabohub.fr" />" target="_blank">metabohub.fr</a>.
						<br />
						<p>
							<a href="http://www.agence-nationale-recherche.fr/en/project-based-funding-to-advance-french-research" target="_blank"><img src="<c:url value="/resources/img/about/logo-anr.png" />" alt="Logo of Agence Nationale Recherche" title="Agence Nationale Recherche"></a>
							<a href="http://www.enseignementsup-recherche.gouv.fr/" target="_blank"><img src="<c:url value="/resources/img/about/logo-enseignementsup-rercherche.png" />" alt="Logo of Ministère de l'Enseignement Supérieur" title="Ministère de l'Enseignement Supérieur"></a>
							<a href="http://investissement-avenir.gouvernement.fr/" target="_blank"><img src="<c:url value="/resources/img/about/logo-invest-avenir.png" />" alt="Logo of Investissement d'Avenir" title="Investissement d'Avenir"></a>&nbsp;
						</p>
					</div>
					<div class="panel-footer">
						<small>
							PeakForest version ${buildVersion} ; ${buildTimestamp} ; ${buildSHA1} 
						</small>
					</div>
				</div>
<!-- 				<div class="panel panel-default"> -->
<!-- 					<div class="panel-heading"> -->
<!-- 						<h3 class="panel-title">Fork project / Get involved</h3> -->
<!-- 					</div> -->
<!-- 					<div class="panel-body"> -->
<!-- 						Link to source, section about code licenses, etc.. -->
<!-- 					</div> -->
<!-- 				</div> -->
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal"><spring:message code="modal.close" text="Close" /></button>
			</div>
		</div>
	</div>

	<!-- /.modal-dialog -->
</body>
</html>
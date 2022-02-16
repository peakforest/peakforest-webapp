<%@page import="fr.metabohub.peakforest.model.maps.MapManager"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<div class="panel panel-default">
	<div class="panel-heading">
		<h3 class="panel-title">MetExplore Viz</h3>
	</div>
	<div class="panel-body col-lg-12">
		<form id="MEViz__module" class="form-horizontal" onsubmit="return false;" autocomplete="off">
			<!-- 
			<small>
				<i class="fa fa-question-circle" aria-hidden="true"></i> Map a PeakForest metabolite or a metabolite list (from the PeakForest Cart) in a selection of biosources and theirs networks from MetExplore. For each selected network, PeakForest will filter and propose pathways where more than one of your compound is found. 
				<br />If none pathway is shown in the menu, it means that's no compound is mapped in any pathway.
				<br />
			</small>
			-->
			<small>
				<i class="fa fa-question-circle" aria-hidden="true"></i> Powered by <a href="https://metexplore.toulouse.inrae.fr/metexploreViz/doc/index.php" targer="_blank">MetExploreViz</a>!
				<br />
			</small>
			<br />
			<!-- select network -->
			<div class="form-group" >
				<label class="col-md-4 control-label" for="selectbasic">Select your MetExplore Network and BioSource</label>
				<div class="col-md-4">
					<select id="MEViz__biosource" name="MEViz__biosource" class="form-control combobox"></select>
				</div>
			</div>
			<!-- select pathway -->
			<div class="form-group">
				<label class="col-md-4 control-label" for="selectbasic">Select your pathway(s)</label>
				<div id="MEViz__pathwaysTarget" class="col-md-4">
					<select id="MEViz__pathways" class="form-control " disabled="disabled"></select>
				</div>
			</div>
			<!-- validate / reset -->
			<div class="form-group">
				<label class="col-md-4 control-label" for="selectbasic">
					<span class=" pull-right">
						<button id="MEViz__run" disabled="disabled" class="btn btn-sm btn-success "> <i class="fa fa-flag-checkered"></i> Run MetExplore Viz</button>
						<button id="MEViz__reset" class="btn btn-xs btn-warning"> <i class="fa fa-times-circle"></i> Reset </button>
					</span>
				</label>
				<div class="col-md-4">
				</div>
			</div>
			<!-- MetExplore Viz frame -->
			<div id="MEViz__mainFrame" style=""></div>
		</form>
	</div>
</div>
<br />
<script type="text/javascript">
var MEViz__autoLoadCart = true;
$( document ).ready(function() {
	if (document.location.hash == "#MEViz__module") {
		$("#link-me-viz").click();
	}
});	
</script>

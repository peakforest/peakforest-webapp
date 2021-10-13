<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div class="row">
	<ul class="nav nav-tabs" style="margin-bottom: 15px;">
		<li class="active">
			<a href="#add-one-spectrum" data-toggle="tab"><i class="fa fa-bar-chart"></i> Add one Spectrum</a>
		</li>
		<li>
			<a href="#import-spectra-from-file" data-toggle="tab"><i class="fa fa-file-excel-o"></i> Import Spectra from file</a>
		</li>
	</ul>

	<div id="add-spectrum" class="tab-content">
		<div class="tab-pane fade" id="import-spectra-from-file" style="max-width: 1000px;"><jsp:include page="add-n-spectra.jsp" /></div>
		<div class="tab-pane fade  active in" id="add-one-spectrum"><jsp:include page="add-one-spectrum.jsp" /></div>
	</div>
</div>
<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>      
<script src="<c:url value="/resources/js/md5.min.js" />"></script>

<!-- SPECTRA - PREVIEW -->
<div class="modal " id="modalShowSpectra" tabindex="-1" role="dialog" aria-labelledby="modalShowSpectraLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="modalShowSpectraLabel">Modal title</h4>
			</div>
			<div class="modal-body">
				<div class="te"></div>
			</div>
			<div class="modal-footer">
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>
<!-- /.modal SPECTRA -->
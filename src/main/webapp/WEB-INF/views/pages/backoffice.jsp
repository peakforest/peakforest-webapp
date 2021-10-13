<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div class="row">
	<div class="col-lg-12">

		<!-- menu:sart -->
		<ul class="nav nav-tabs" style="margin-bottom: 15px;">
			<li class="active">
				<a href="#server-status" data-toggle="tab">
					<i class="fa fa-tachometer"></i> Server status
				</a>
			</li>
			<li>
				<a href="#tools" data-toggle="tab">
					<i class="fa fa-wrench"></i> Database Tools
				</a>
			</li>
			<li class="dropdown">
				<a class="dropdown-toggle" data-toggle="dropdown" href="#">
					<i class="fa fa-group"></i> Users <span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li>
						<a href="#users-access" data-toggle="tab">Manage Access</a>
					</li>
					<li class="divider"></li>
					<li>
						<a href="#users-add" data-toggle="tab">Add</a>
					</li>
					<li>
						<a href="#users-stats" data-toggle="tab">Statistics</a>
					</li>
				</ul>
			</li>
			<li>
				<a href="#license" data-toggle="tab"> 
					<i class="fa fa-certificate"></i> License
				</a>
			</li>
			<li>
				<a href="#analytics" data-toggle="tab"> 
					<i class="fa fa-line-chart" aria-hidden="true"></i> Analytics
				</a>
			</li>
		</ul>
		<!-- menu:end -->
		
		<!-- main content -->
		<div id="backoffice-mgmt" class="tab-content">
			<div class="tab-pane fade active in" id="server-status">
				loading...
			</div>
			<div class="tab-pane fade" id="tools">
				loading...
			</div>
			<div class="tab-pane fade" id="users-access">
				loading...
			</div>
			<div class="tab-pane fade" id="users-add">
				loading...
			</div>
			<div class="tab-pane fade" id="users-stats">
				loading...
			</div>
			<div class="tab-pane fade" id="license">
				loading...
			</div>
			<div class="tab-pane fade" id="analytics">
				loading...
			</div>
		</div>
	
		<!-- /main content -->
		</div>
		<!-- special js -->
		<!--[if lte IE 8]><script src="<c:url value="/resources/js/excanvas.min.js" />"></script><![endif]-->
		<script type="text/javascript">
		$.get("admin/backoffice-server-status", function( data ) {
			$( "#server-status" ).html( data );
			console.log("users-access: ready!");
		});
		$.get("admin/backoffice-users-access-view", function( data ) {
			$( "#users-access" ).html( data );
			console.log("users-access: ready!");
		});
		$.get("admin/backoffice-add-users-view", function( data ) {
			$( "#users-add" ).html( data );
			console.log("users-add: ready!");
		});
		$.get("admin/backoffice-users-stats", function( data ) {
			$( "#users-stats" ).html( data );
			console.log("users-stats: ready!");
		});
		$.get("admin/backoffice-tools", function( data ) {
			$( "#tools" ).html( data );
			console.log("tools: ready!");
		});
		$.get("admin/backoffice-license", function( data ) {
			$( "#license" ).html( data );
			console.log("license: ready!");
		});
		$.get("admin/backoffice-analytics", function( data ) {
			$( "#analytics" ).html( data );
			console.log("analytics: ready!");
		});
		</script>
</div>
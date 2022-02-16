<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@page import="fr.metabohub.peakforest.security.model.User"%>
<div class="col-lg-12">
	<p></p>
	<div class="table-responsive">
		<table id="usersStats" class="table table-hover tablesorter table-search">
			<thead>
				<tr>
					<th class="header">User type <i class="fa fa-sort"></i></th>
					<th class="header">connected <i class="fa fa-sort"></i></th>
					<th class="header">total <i class="fa fa-sort"></i></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>anonymous</td>
					<td><!-- ${nb_connect_annonymous} -->?</td>
					<td><span style="display: none;">0</span>&infin;</td>
				</tr>
				<tr>
					<td>not validated</td>
					<td>${nb_connect_users_not_val}</td>
					<td>${nb_users_not_val}</td>
				</tr>
				<tr>
					<td>user</td>
					<td>${nb_connect_users}</td>
					<td>${nb_users}</td>
				</tr>
				<tr>
					<td>curator</td>
					<td>${nb_connect_users_curator}</td>
					<td>${nb_users_curator}</td>
				</tr>
				<tr>
					<td>admin</td>
					<td>${nb_connect_users_admin}</td>
					<td>${nb_users_admin}</td>
				</tr>
			</tbody>
			<tbody>
				<tr>
					<td><b>Total</b></td>
					<td><b>${nb_connect_users_tot} (+<!-- ${nb_connect_annonymous} -->?)</b></td>
					<td><b>${nb_users_tot}</b></td>
				</tr>
			</tbody>
		</table>
	</div>
	<p></p>
</div>
<div class="col-lg-12">
	<button id="updateUserStats" class="btn" onclick="updateUserStats()"><i class="fa fa-refresh"></i> Refresh</button>
	 &nbsp; &nbsp; 
	<a href="<spring:message code="peakforest.admin.analytics" text="https://managers.pfem.clermont.inrae.fr/piwik/" />" target="_blank"><i class="fa fa-empire"></i> Piwik</a>
</div>
<script type="text/javascript">
$("#usersStats").tablesorter();

updateUserStats = function() {
	$("#updateUserStats i").addClass("fa-spin");
	$.get("admin/backoffice-users-stats", function( data ) {
		$( "#users-stats" ).html( data );
	});
}


</script>
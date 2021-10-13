<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<div id="" class="col-lg-12">
	<div id="" class="col-lg-6">
		<div class="form-group input-group "><div id="alertAnalyticsManager"></div></div>
		<div class="form-group">
			<label for="comment">Code:</label>
			<textarea class="form-control" rows="5" id="analyticsCode">${analyticsCode}</textarea>
		</div>
		<div class="form-group ">
			<button class="btn btn-success btn-sm" onclick="saveNewAnalytics()"><i class="fa fa-save"></i> Update</button>
		</div>
	</div>
</div>
<script type="text/javascript">
function saveNewAnalytics() {
	$.ajax({ 
		type: "post",
		url: "admin/set-analytics",
		data: "code=" + encodeURIComponent($("#analyticsCode").val()),
		async: false,
// 		data: "query=" + $('#search').val(),
		success: function(ret) {
			if (ret) {
				// display good new	
				var alert = '<div class="alert alert-success alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong>Success!</strong> code updated!';
				alert += ' </div>';
				$("#alertAnalyticsManager").html(alert);
			} else {
				var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
				alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
				alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not set code';
				alert += ' </div>';
				$("#alertAnalyticsManager").html(alert);
			}

		},
		error : function(xhr) {
			subjects = [];
			// TODO alert error xhr.responseText
			console.log(xhr);
			var alert = '<div class="alert alert-danger alert-dismissible" role="alert">';
			alert += '<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only"><spring:message code="alert.close" text="Close" /></span></button>';
			alert += '<strong><spring:message code="alert.strong.warning" text="Warning!" /></strong> could not update code';
			alert += ' </div>';
			$("#alertAnalyticsManager").html(alert);
		}
	});
}
</script>
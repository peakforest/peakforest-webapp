<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<div class="row">
	<div class="col-lg-12">
		<h1>
			404 <small> not found</small>
		</h1>
		<%
			int max = 6;
			int id = (int) (Math.random() * (max - 1)) + 1;
			switch (id) {
			case 1:
				%><img class="image404" alt="404" src="<c:url value="/resources/img/404/404_1.jpg" />"><%
				break;
			case 2:
				%><img class="image404" alt="404" src="<c:url value="/resources/img/404/404_2.jpg" />"><%
				break;
			case 3:
				%><img class="image404" alt="404" src="<c:url value="/resources/img/404/404_3.jpg" />"><%
				break;
			case 4:
				%><img class="image404" alt="404" src="<c:url value="/resources/img/404/404_4.jpg" />"><%
				break;
			case 5:
				%><img class="image404" alt="404" src="<c:url value="/resources/img/404/404_5.jpg" />"><%
				break;
			default:
				%><img class="image404" alt="404" src="<c:url value="/resources/img/404/404_1.jpg" />"><%
				break;
			}
		%>
		

	</div>
</div>
<!-- /.row -->
<script>

</script>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div class="row">
	<div class="col-lg-12">
		<ul class="nav nav-tabs" style="margin-bottom: 15px;">
			<li class="active"><a href="#cart" data-toggle="tab"><i class="fa fa-shopping-cart"></i> Cart</a></li>
			<li>
				<a id="link-me-viz" href="#metexplore-viz" data-toggle="tab">
					<img style="max-width: 15px;" class="" alt="logo ME Viz" src="<c:url value="/resources/img/metexplore_icon.png" />"> 
					MetExplore Viz
				</a>
			</li>
		</ul>
		<div id="div-tools" class="tab-content">
			<div class="tab-pane fade active in" id="cart">
<jsp:include page="tools-cart.jsp" />
			</div>
			<div class="tab-pane fade" id="metexplore-viz">
<jsp:include page="tools-metexplore-viz.jsp" />
			</div>
		</div>
	</div>
</div>
<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/md5.min.js" />"></script>

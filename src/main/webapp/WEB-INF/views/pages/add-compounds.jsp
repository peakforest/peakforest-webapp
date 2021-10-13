<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div class="row">
  <div class="col-lg-12">
    <ul class="nav nav-tabs" style="margin-bottom: 15px;">
      <li class="active"><a href="#add-one-cc" data-toggle="tab"><i class="fa fa-flask"></i> Add one chemical compound</a></li>
      <li><a href="#import-cc-from-file" data-toggle="tab"><i class="fa fa-file-excel-o"></i> Import chemical compounds from file</a></li>
    </ul>
    <div id="add-CC" class="tab-content" style="max-width: 1000px;" >
      <div class="tab-pane fade active in" id="add-one-cc">
<jsp:include page="add-one-compound.jsp" />
      </div>
      <div class="tab-pane fade" id="import-cc-from-file">
<jsp:include page="add-n-compounds.jsp" />
      </div>
    </div>
  </div>
</div>
<script type="text/javascript" src="<c:url value="/resources/jqueryform/2.8/jquery.form.min.js" />"></script>      
<script src="<c:url value="/resources/js/md5.min.js" />"></script>
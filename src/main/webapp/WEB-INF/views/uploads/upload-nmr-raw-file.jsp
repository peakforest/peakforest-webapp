<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
success=${success}
reload=${reload}
files=<c:forEach var="file" items="${files}">${file},</c:forEach>
procFiles=<c:forEach var="file" items="${procFiles}">${file},</c:forEach>
error=${error}
new_raw_file_name=${new_raw_file_name}
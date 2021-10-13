<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div id="demo-rest" style="max-width: 700px;"></div>
<div id="demo-doc-ws" style="max-width: 700px;"></div>

The PeakForest database is available through a REST webservice at the following address:
<a style="fo" href="<spring:message code="peakforest.ws-rest.url" text="" />" target="_blank"><spring:message code="peakforest.ws-rest.show" text="" /></a>
<br>Documentation and demo / sample code are available at <a href="<spring:message code="peakforest.ws-doc.url" text="" />" target="_blank"><spring:message code="peakforest.ws-doc.show" text="" /></a>.
<br />
<br />
<img src="<c:url value="/resources/img/demo-ws.png" />" alt="webservice rest portal" title="REST WebServices" width="1000px;">
<br />
<hr />
Note: you must generate a token in order to request the webservice (require a PeakForest validated account).
<br />
<img src="<c:url value="/resources/img/peakforest_apikey.png" />" alt="webservice token" title="webservice token" style="max-width: 750px;">

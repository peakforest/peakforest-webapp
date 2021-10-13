<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<c:if test="${not ranking_data}">
<title><spring:message code="home.title" text="Peak Forest" /></title>
<meta name="keywords" content="spectral database, mass spectrometry, nmr, lc-ms, gc-ms, chemical, metabolomic, compound, library">
<meta name="description" content="the MetaboHUB's Spectral Database.">
</c:if>
<c:if test="${ranking_data}">
<title>${page_title}</title>
<meta name="keywords" content="${page_keywords}">
<meta name="description" content="${page_description}">
</c:if>
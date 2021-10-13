<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<div>

		<!--JS page mode-->
		<script type="text/javascript">
		if (!(typeof currentChartTab == "undefined")) {
			$.each(currentChartTab, function(index, chart) {
				try { chart.destroy(); } catch (e) {}
			});
		}
//		try { chart.destroy(); } catch (e) {}
		</script>
		
	<ul class="nav nav-tabs" style="margin-bottom: 15px;">
		<c:if test="${first_tab_open =='lc-ms'}">
			<li<c:if test="${first_tab_open =='lc-ms'}"> class="active"</c:if>>
				<a href="#spectrum-mod-lc" data-toggle="tab"> <spring:message code="module.spectra.tag.lcms" text="LC-MS" /> </a>
			</li>
		</c:if>
		<c:if test="${first_tab_open !='lc-ms'}">
			<li class="disabled"><a><spring:message code="module.spectra.tag.lcms" text="LC-MS" /></a></li>
		</c:if>
		
		<c:if test="${first_tab_open =='lc-msms'}">
			<li<c:if test="${first_tab_open =='lc-msms'}"> class="active"</c:if>>
				<a href="#spectrum-mod-lcmsms" data-toggle="tab"> <spring:message code="module.spectra.tag.msms" text="LC-MSMS" /> </a>
			</li>
		</c:if>
		<c:if test="${first_tab_open !='lc-msms'}">
			<c:if test="${not empty spectrum_mass_fragmt_lc}">
				<li><a href="#spectrum-mod-lcmsms" data-toggle="tab"><spring:message code="module.spectra.tag.lcmsms" text="LC-MSMS" /></a></li>
			</c:if>
			<c:if test="${empty spectrum_mass_fragmt_lc}">
				<li class="disabled"><a><spring:message code="module.spectra.tag.lcmsms" text="LC-MSMS" /></a></li>
			</c:if>
		</c:if>
		
		<c:if test="${not empty spectrum_nmr}">
			<li<c:if test="${first_tab_open =='nmr'}"> class="active"</c:if>>
				<a href="#spectrum-mod-nmr" data-toggle="tab"> <spring:message code="module.spectra.tag.nmr" text="NMR" /> </a>
			</li>
		</c:if>
		<c:if test="${empty spectrum_nmr}">
			<li class="disabled"><a><spring:message code="module.spectra.tag.nmr" text="NMR" /></a></li>
		</c:if>
		
		<c:if test="${not empty spectrum_mass_fullscan_gc}">
			<li<c:if test="${first_tab_open =='gc-ms'}"> class="active"</c:if>>
				<a href="#spectrum-mod-gc" data-toggle="tab"> <spring:message code="module.spectra.tag.gcms" text="GC-MS" /> </a>
			</li>
		</c:if>
		<c:if test="${empty spectrum_mass_fullscan_gc}">
			<li class="disabled"><a><spring:message code="module.spectra.tag.gcms" text="GC-MS" /></a></li>
		</c:if>
		<c:if test="${not empty spectrum_mass_fullscan_lc || not empty spectrum_mass_fragmt_lc || not empty spectrum_nmr || not empty spectrum_mass_fullscan_gc}">
			<li>
				<a href="#spectrum-all" data-toggle="tab"> <spring:message code="module.spectra.tag.all" text="All" /> </a>
			</li>
		</c:if>
	</ul>
	<div id="spectrum-mod" class="tab-content">
		<div class="tab-pane fade <c:if test="${first_tab_open =='lc-ms'}">active in</c:if>" id="spectrum-mod-lc">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<c:if test="${not empty spectrum_mass_fullscan_lc}">
							<!-- fullscan LC -->
							<ul class="list-group">
								<c:forEach var="spectrum" items="${spectrum_mass_fullscan_lc}">
									<li class="list-group-item">
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
										/
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
											${fn:escapeXml((spectrum.getMassBankNameHTML()))}
										</a>
										<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
									</li>
								</c:forEach>
							</ul>
						</c:if>
					</td>
				</tr>
			</table>
		</div>
		<div class="tab-pane fade <c:if test="${first_tab_open =='lc-msms'}">active in</c:if>" id="spectrum-mod-lcmsms">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<c:if test="${not empty spectrum_mass_fragmt_lc}">
							<!-- fragmentation LC -->
							<ul class="list-group">
								<c:forEach var="spectrum" items="${spectrum_mass_fragmt_lc}">
									<li class="list-group-item">
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
										/
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
											${fn:escapeXml((spectrum.getMassBankNameHTML()))}
										</a>
										<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
									</li>
								</c:forEach>
							</ul>
						</c:if>
					</td>
				</tr>
			</table>
		</div>
		<div class="tab-pane fade <c:if test="${first_tab_open =='nmr'}">active in</c:if>" id="spectrum-mod-nmr">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<c:if test="${not empty spectrum_nmr}">
							<ul class="list-group">
								<c:forEach var="spectrum" items="${spectrum_nmr}">
									<li class="list-group-item">
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
										/
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
											${fn:escapeXml((spectrum.getMassBankNameHTML()))}
										</a>
										<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
									</li>
								</c:forEach>
							</ul>
						</c:if>
					</td>
				</tr>
			</table>
		</div>
		<div class="tab-pane fade <c:if test="${first_tab_open =='gc-ms'}">active in</c:if>" id="spectrum-mod-gc">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<!--container-->
						<c:if test="${not empty spectrum_mass_fullscan_gc}">
							<!-- fullscan GC -->
							<ul class="list-group">
								<c:forEach var="spectrum" items="${spectrum_mass_fullscan_gc}">
									<li class="list-group-item">
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
										/
										<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
											${fn:escapeXml((spectrum.getMassBankNameHTML()))}
										</a>
										<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
									</li>
								</c:forEach>
							</ul>
						</c:if>
					</td>
				</tr>
			</table>
		</div>
		<!-- new 2.0.1 -->
		<div class="tab-pane fade" id="spectrum-all">
			<!-- display -->
			<table class="table">
				<tr>
					<td>
						<ul class="list-group">
							<c:if test="${not empty spectrum_mass_fullscan_lc}">
								<!-- fullscan LC -->
								<li class="list-group-item"> <spring:message code="module.spectra.tag.lcms" text="LC-MS" /> </li>
								<li class="list-group-item">
									<ul class="list-group">
										<c:forEach var="spectrum" items="${spectrum_mass_fullscan_lc}">
											<li class="list-group-item">
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
												/
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
													${fn:escapeXml((spectrum.getMassBankNameHTML()))}
												</a>
												<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
											</li>
										</c:forEach>
									</ul>
								</li>
							</c:if>
							<c:if test="${not empty spectrum_mass_fragmt_lc}">
								<!-- fragmentation LC -->
								<li class="list-group-item"> <spring:message code="module.spectra.tag.msms" text="LC-MSMS" /> </li>
								<li class="list-group-item">
									<ul class="list-group">
										<c:forEach var="spectrum" items="${spectrum_mass_fragmt_lc}">
											<li class="list-group-item">
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
												/
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
													${fn:escapeXml((spectrum.getMassBankNameHTML()))}
												</a>
												<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
											</li>
										</c:forEach>
									</ul>
								</li>
							</c:if>
							<c:if test="${not empty spectrum_nmr}">
								<!-- NMR -->
								<li class="list-group-item"> <spring:message code="module.spectra.tag.nmr" text="NMR" /> </li>
								<li class="list-group-item">
									<ul class="list-group">
										<c:forEach var="spectrum" items="${spectrum_nmr}">
											<li class="list-group-item">
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
												/
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
													${fn:escapeXml((spectrum.getMassBankNameHTML()))}
												</a>
												<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
											</li>
										</c:forEach>
									</ul>
								</li>
							</c:if>
							<c:if test="${not empty spectrum_mass_fullscan_gc}">
								<!-- fullscan GC -->
								<li class="list-group-item"> <spring:message code="module.spectra.tag.gcms" text="GC-MS" /> </li>
								<li class="list-group-item">
									<ul class="list-group">
										<c:forEach var="spectrum" items="${spectrum_mass_fullscan_gc}">
											<li class="list-group-item">
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}">${spectrum.getPeakForestID()}</a>
												/
												<a href="<spring:message code="peakforest.uri.spectrum" text="https://peakforest.org/" />${spectrum.getPeakForestID()}" class="pforest-spectra-name-${spectrum.getPeakForestID()}">
													${fn:escapeXml((spectrum.getMassBankNameHTML()))}
												</a>
												<a href="show-spectra-modal/${spectrum.getId()}" data-toggle="modal" data-target="#modalShowSpectra"><i class="fa fa-bar-chart-o pull-right"></i></a>
											</li>
										</c:forEach>
									</ul>
								</li>
							</c:if>
						</ul>
					</td>
				</tr>
			</table>
		</div>
		
	</div>

</div>


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
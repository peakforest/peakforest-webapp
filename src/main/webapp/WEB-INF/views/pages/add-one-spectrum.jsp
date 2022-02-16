<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="fr.metabohub.peakforest.utils.PeakForestUtils"%>
<%@ page import="fr.metabohub.peakforest.model.metadata.AnalyticalMatrix"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>
<script src="<c:url value="/resources/js/peakforest/add-one-spectrum.min.js" />"></script>
<div class="panel-group" id="accordion">
	<!-- ############################################################################################################################################# STEP 0: SPECTRUM TYPE -->
	<div class="panel panel-default">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a data-toggle="collapse" data-parent="#accordion" href="#step0">
					Spectrum Type <i id="step0sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step0" class="panel-collapse collapse in">
			<div class="panel-body">
				<button class="btn btn-disabled" disabled="disabled"><i class="fa fa-plus-circle"></i> GC-MS spectrum</button>
				<button class="btn btn-primary" onclick="addOneSpectrum(2);"><i class="fa fa-plus-circle"></i> LC-MS spectrum</button>
				<button class="btn btn-primary" onclick="addOneSpectrum(5);"><i class="fa fa-plus-circle"></i> LC-MSMS spectrum</button>
				<button class="btn btn-primary" onclick="addOneSpectrum(3);"><i class="fa fa-plus-circle"></i> NMR spectrum</button>
				<button class="btn btn-disabled" disabled="disabled"><i class="fa fa-plus-circle"></i> LC-NMR spectrum</button>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 1: SAMPLE -->
	<div id="add1spectrum-sampleData" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep1" data-toggle="collapse" data-parent="#accordion" href="#step1">
					Sample Type <i id="step1sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step1" class="panel-collapse collapse" >
			<div class="panel-body">
				<div class="col-lg-12 opt-nmr" style="display: none;">
					<div class="col-lg-8">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">NMR tube preparation</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">solvent</span> 
									<select id="add1spectrum-sample-nmrSolvent" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">sample pH or sample apparent pH</span> 
									<input id="add1spectrum-sample-nmrpH" type="text" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr" disabled="disabled" placeholder="e.g. 10">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">reference chemical shift indicator</span> 
									<select id="add1spectrum-sample-nmrReferenceChemicalShifIndicatort" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">reference chemical shif indicator <small>(other)</small></span> 
									<input id="add1spectrum-sample-nmrReferenceChemicalShifIndicatortOther" type="text" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr" disabled="disabled" placeholder="e.g. ???">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">reference concentration <small>(mmol/L)</small></span> 
									<input id="add1spectrum-sample-nmrReferenceConcentration" type="text" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional" placeholder="e.g. 0.2">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">lock substance</span> 
									<select id="add1spectrum-sample-nmrLockSubstance" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">lock substance concentration <small>(volumic %)</small></span> 
									<input id="add1spectrum-sample-nmrLockSubstanceConcentration" type="text" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional" placeholder="e.g. 100">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">buffer solution</span> 
									<select id="add1spectrum-sample-nmrBufferSolution" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">buffer solution concentration <small>(mmol/L)</small></span> 
									<input id="add1spectrum-sample-nmrBufferSolutionConcentration" type="text" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional" placeholder="e.g. 150">
								</div>
								<hr />
								<div class="form-group input-group ">
									<span class="input-group-addon">Deuterium Isotopic Labelling <small>(y/n)</small></span> 
									<select id="add1spectrum-sample-nmrIsotopicLabellingD" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional">
										<option value="no" selected="selected">no</option>
										<option value="yes">yes</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Carbon 13 Isotopic Labelling <small>(y/n)</small></span> 
									<select id="add1spectrum-sample-nmrIsotopicLabelling13C" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional">
										<option value="no" selected="selected">no</option>
										<option value="yes">yes</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Nitrogen 15 Isotopic Labelling <small>(y/n)</small></span> 
									<select id="add1spectrum-sample-nmrIsotopicLabelling15N" class="form-control add1spectrum add1spectrum-sampleForm add1spectrum-sampleForm-nmr is-optional">
										<option value="no" selected="selected">no</option>
										<option value="yes">yes</option>
									</select>
								</div>
							</div>
						</div>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<div class="opt-nmr" style="display: none;"><br /></div>
						<div class="panel panel-default">
							<div class="panel-heading">
								<div class="form-group input-group ">
									<span class="input-group-addon">Sample Type</span> 
									<select id="add1spectrum-sample-type" class="form-control add1spectrum add1spectrum-sampleForm is-mandatory">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="compound-ref">Ref. Chemical Compound</option>
										<option value="compound-mix">Mix of Ref. Chemical Compound</option>
										<option value="matrix-ref">Ref. Matrix</option>
										<option value="matrix-bio">Analytical Matrix</option>
									</select>
								</div>
							</div>
							<div class="panel-body">
								<div id="add1spectrum-sample-type-compound-ref" class="add1spectrum-sample-type-panel" style="display:none;">
									<div class="form-group input-group ">
										<span class="input-group-addon">InChIKey</span> 
										<input id="add1spectrum-sample-inchikey" type="text" class="pickChemicalCompound form-control add1spectrum add1spectrum-sampleForm is-mandatory" placeholder="e.g. RYYVLZVUVIJVGH-UHFFFAOYSA-N">
										<span class="input-group-btn">
											<button class="btn btn-default" type="button" onclick="pickChemicalCompound();">
												<i class="fa fa-search"></i>
											</button>
										</span>
									</div>
									<div class="form-group input-group ">
										<span class="input-group-addon">concentration <small>(mmol/L)</small></span> 
										<input id="add1spectrum-sample-concentration" type="text" class="form-control add1spectrum add1spectrum-sampleForm is-optional" placeholder="42">
									</div>
									<div class="form-group input-group opt-ms " style="display: none;">
										<span class="input-group-addon">solvent</span> 
										<select id="add1spectrum-sample-lcmsSolvent" class="form-control add1spectrum add1spectrum-sampleForm is-optional"></select>
									</div>
									<div class="form-group input-group ">
										<span class="input-group-addon">InChI</span> 
										<input id="add1spectrum-sample-inchi" type="text" class="pickChemicalCompound form-control add1spectrum add1spectrum-sampleForm is-optional" placeholder="e.g. InChI=1S/C8H10N4O2/c1-10-4-9-6-5(10)7(13)12(3)8(14)11(6)2/h4H,1-3H3">
									</div>
									<div class="form-group input-group ">
										<span class="input-group-addon">Molecule common name</span> 
										<input id="add1spectrum-sample-commonName" type="text" class="pickChemicalCompound form-control add1spectrum add1spectrum-sampleForm is-optional" placeholder="e.g. Caffeine"><!-- <3 coffee -->
									</div>
								</div>
								<div id="add1spectrum-sample-type-compound-mix" class="add1spectrum-sample-type-panel" style="display:none;">
									<div class="form-group input-group " style="">
										<span class="input-group-addon">solvent</span> 
										<select id="add1spectrum-sample-mixSolvent" class="form-control add1spectrum add1spectrum-sampleForm is-optional">
											<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
											<option value="H2O/ethanol (75/25)">H2O/ethanol (75/25)</option>
											<!-- <option value="H2O/ethanol (75/25)">H2O/ethanol (75/25)</option> -->
										</select>
									</div>
								</div>
								<div id="add1spectrum-sample-type-matrix-ref" class="add1spectrum-sample-type-panel" style="display:none;">
									<div class="form-group input-group " style="">
										<span class="input-group-addon">Matrix Type </span> 
										<select id="add1spectrum-sample-stdMatrix" class="form-control add1spectrum add1spectrum-sampleForm is-mandatory">
											<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										</select>
									</div>
									<div>
										<p id="add1spectrum-sample-type-matrix-ref-help" class="help-block"  style="display: none;">
											<small></small>
										</p>
									</div>
								</div>
								<div id="add1spectrum-sample-type-rcc-added" class="panel panel-default add1spectrum-sample-type-panel" style="display:none;">
									<div class="panel-heading">
										<h3 class="panel-title">Reference compound added</h3>
									</div>
									<div class="panel-body" style="padding: 0px;">
										<div id="container_RCC_ADDED" class="handsontable"></div>
									</div>
								</div>
								<div id="add1spectrum-sample-type-matrix-bio" class="add1spectrum-sample-type-panel" style="display:none;">
									<div class="form-group input-group " style="">
										<span class="input-group-addon">Matrix Type </span> 
										<select id="add1spectrum-sample-bioMatrix" class="form-control add1spectrum add1spectrum-sampleForm is-mandatory">
											<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										</select>
									</div>
									<div>
										<p id="add1spectrum-sample-type-matrix-bio-help" class="help-block" >
											<small></small>
											<small>
												<br />Note: To create a new ontologie, please go to 
												<a target="_blank" href="<spring:message code="link.site.ontologiesframework" text="https://pfem.clermont.inrae.fr/ontologies-framework/" />">ontologies framework online tool</a>, 
												then ask us to refer it into PeakForest.
											</small>
										</p>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="col-lg-4">
						<div id="sample-bonus-display"></div>
					&nbsp;</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<br>
						<button id="btnSwitch-gotoStep2" onclick="switchToStep(2);" class="btn btn-disabled switchStep" disabled="disabled"><i class="fa fa-arrow-circle-down"></i> Next!</button>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 2: CHROMATO -->
	<!-- ############################################################################################################################################# STEP 2.A: CHROMATO LC -->
	<div id="add1spectrum-chromatographyData-LC" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep2-lc" data-toggle="collapse" data-parent="#accordion" href="#step2-lc">
					Liquid Chromatography <i id="step2-lc-sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step2-lc" class="panel-collapse collapse" >
			<div class="panel-body">
				<div class="col-lg-12">
					<div class="col-lg-6">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Chromatography Param.</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">Method</span> 
									<select id="add1spectrum-chromatoLC-method" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory"></select>
								</div>
								<div id="alertBoxSelectTemplate"></div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Column constructor</span> 
									<select id="add1spectrum-chromatoLC-colConstructor" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Column constructor (other)</span> 
									<input id="add1spectrum-chromatoLC-colConstructorOther" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm" disabled="disabled" placeholder="e.g. HAL 9000">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Column name</span> 
									<input id="add1spectrum-chromatoLC-colName" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-optional" placeholder="e.g. UPLC HSS T3">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Column length (mm)</span> 
									<input id="add1spectrum-chromatoLC-colLength" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory" placeholder="e.g. 150">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Column diameter (mm)</span> 
									<input id="add1spectrum-chromatoLC-colDiameter" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory" placeholder="e.g. 2.1">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Particule size (µm)</span> 
									<input id="add1spectrum-chromatoLC-colParticuleSize" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory" placeholder="e.g. 1.8">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Column temperature (°C)</span> 
									<input id="add1spectrum-chromatoLC-colTemperature" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-optional" placeholder="e.g. 30">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">LC mode</span> 
									<select id="add1spectrum-chromatoLC-LCMode" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="gradient">Gradient</option>
										<option value="isocratic">Isocratic</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Separation flow rate (µL/min)</span> 
									<input id="add1spectrum-chromatoLC-separationFlowRate" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-optional" placeholder="e.g. 400">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Separation solvent A</span> 
									<select id="add1spectrum-chromatoLC-separationSolvA" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">pH solvent A (if acqueous solvant)</span> 
									<input id="add1spectrum-chromatoLC-separationSolvApH" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-optional" placeholder="e.g. 7.0">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Separation solvent B</span> 
									<select id="add1spectrum-chromatoLC-separationSolvB" class="form-control add1spectrum add1spectrum-chromatoLCForm is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">pH solvent B (if acqueous solvant)</span> 
									<input id="add1spectrum-chromatoLC-separationSolvBApH" type="text" class="form-control add1spectrum add1spectrum-chromatoLCForm is-optional" placeholder="e.g. 7.0">
								</div>						
							</div>
						</div>
					</div>
					<div class="col-lg-6">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Separation flow gradient</h3>
							</div>
							<div class="panel-body" style="padding: 0px;">
								<div id="container_LC_SFG" class="handsontable"></div>
							</div>
						</div>
					</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<br>
						<button id="btnSwitch-gotoStep3-lc" onclick="switchToStep(3);" class="btn btn-disabled switchStep" disabled="disabled"><i class="fa fa-arrow-circle-down"></i> Next!</button>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 2.B: CHROMATO GC -->
	<div id="add1spectrum-chromatographyData-GC" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep2-gc" data-toggle="collapse" data-parent="#accordion" href="#step2-gc">
					Gaz Chromatography <i id="step2-gc-sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step2-gc" class="panel-collapse collapse" >
			<div class="panel-body">
				
				<div class="col-lg-12">
					<div class="col-lg-6">
						i &lt;3 GC
					</div>
					<div class="col-lg-6">&nbsp;</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<br>
						<button id="btnSwitch-gotoStep3-gc" onclick="switchToStep(3);" class="btn btn-disabled switchStep" disabled="disabled"><i class="fa fa-arrow-circle-down"></i> Next!</button>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 3: ANALYZER -->
	<!-- ############################################################################################################################################# STEP 3.A: ANALYZER NMR -->
	<div id="add1spectrum-analyserData-NMR" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep3-nmr" data-toggle="collapse" data-parent="#accordion" href="#step3-nmr">
					NMR Analyzer <i id="step3-nmr-sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step3-nmr" class="panel-collapse collapse" >
			<div class="panel-body">
				<div class="col-lg-12">
					<div class="col-lg-8">
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Instrument</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">Instrument name</span> 
									<select id="add1spectrum-analyzer-nmr-instrument-name" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Magnetic field strength <small>(MHz)</small></span> 
									<select id="add1spectrum-analyzer-nmr-instrument-magneticFieldStrength" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Software</span> 
									<select id="add1spectrum-analyzer-nmr-instrument-software" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock is-optional"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">NMR probe</span> 
									<select id="add1spectrum-analyzer-nmr-instrument-probe" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock is-mandatory"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Cell or Tube</span> 
									<select id="add1spectrum-analyzer-nmr-instrument-cellOrTube" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock is-mandatory">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="cell">Cell</option>
										<option value="tube">tube</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">NMR tube diameter (mm)</span> 
									<select id="add1spectrum-analyzer-nmr-instrument-tube" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock" disabled="disabled"></select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Flow cell volume (µl)</span> 
									<input id="add1spectrum-analyzer-nmr-instrument-flowCellVolume" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzerNMRForm-lock " disabled="disabled" placeholder="e.g. 60">
								</div>
							</div>
						</div>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-6">
						<br />
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Acquisition</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">programm</span> 
									<select id="add1spectrum-analyzserNMR-programm" class="form-control add1spectrum add1spectrum-analyzerNMRForm is-mandatory add1spectrum-analyzserNMR-programm-peaklist ">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<optgroup label="1D"></optgroup>
										<option value="proton">Proton acquisition</option>
										<option value="noesy-1d">NOESY acquisition</option>
										<option value="cpmg-1d">CCPMG acquisition</option>
										<option value="carbon13-1d">Carbon-13 acquisition</option>
										<optgroup label="2D"></optgroup>
										<option value="JRES-2d">JRES acquisition</option>
										<option value="COSY-2d">COSY acquisition</option>
										<option value="TOCSY-2d">TOCSY acquisition</option>
										<option value="NOESY-2d">NOESY acquisition</option>
										<option value="HSQC-2d">HSQC acquisition</option>
										<option value="HMBC-2d">HMBC acquisition</option>
									</select>
								</div>
								<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
								<div class="form-group input-group input-nmrProg input-nmrProg-all "><!-- all (1d / 2d) -->
									<span class="input-group-addon">Pulse sequence</span> 
									<input id="add1spectrum-analyzserNMR-programm-PULPROG" type="text" class="form-control add1spectrum-analyzserNMR-programm-peaklist add1spectrum add1spectrum-analyzerNMRForm is-mandatory" placeholder="PULPROG">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-all-1d input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC"><!-- all (1d) / all 2d except JRES-->
									<span class="input-group-addon">Pulse angle <small>(°)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-F1" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="F1">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-H input-nmrProg-noesy1d input-nmrProg-cpmg1d input-nmrProg-C13 "><!-- Proton-1D NOESY-1D CPMG-1D Carbon13-1D -->
									<span class="input-group-addon">Number of points</span> 
									<input id="add1spectrum-analyzserNMR-programm-TD" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm is-optional add1spectrum-analyzserNMR-programm-peaklist" placeholder="TD">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-JRES "><!-- COSY TOCSY NOESY HSQC JRES -->
									<span class="input-group-addon">Size of FID <small>(F1)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-TD1" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="TD1">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-JRES "><!-- COSY TOCSY NOESY HSQC JRES  -->
									<span class="input-group-addon">Size of FID <small>(F2)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-TD2" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="TD2">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-all-1d"><!-- all (1d) -->
									<span class="input-group-addon">Number of scans</span> 
									<input id="add1spectrum-analyzserNMR-programm-NS" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="NS">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-JRES input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC"><!-- JRES COSY TOCSY NOESY HSQC HMBC -->
									<span class="input-group-addon">Number of scans <small>(F2)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-NSf2" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="NS">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-JRES "><!-- JRES  -->
									<span class="input-group-addon">Acquisition mode for 2D </span> 
									<input id="add1spectrum-analyzserNMR-programm-aq2d" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC"><!-- COSY TOCSY NOESY HSQC HMBC -->
									<span class="input-group-addon">Acquisition mode for 2D <small>(F1)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-aq2df1" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<!-- <div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-HSQC ">
									<span class="input-group-addon">Acquisition mode for 2D <small>(F2)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-aq2" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div> -->
								<div class="form-group input-group input-nmrProg input-nmrProg-all"><!-- all (1d / 2d) -->
									<span class="input-group-addon">Temperature <small>(K)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-TE" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-mandatory" placeholder="TE">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-all"><!-- all (1d /2d) -->
									<span class="input-group-addon">Relaxation delay D1 <small>(s)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-DS" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="DS">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-NOESY "><!-- NOESY -->
									<span class="input-group-addon">Mixing time D8 <small>(s)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-D8-noesy2d" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="D8">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-H input-nmrProg-noesy1d input-nmrProg-cpmg1d input-nmrProg-C13 "><!-- Proton-1D NOESY-1D CPMG-1D Carbon13-1D -->
									<span class="input-group-addon">SW <small>(ppm)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-SW" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="SW">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-JRES "><!-- JRES -->
									<span class="input-group-addon">SW F1<small>(ppm)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-SWf1" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="SW">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-JRES "><!-- JRES -->
									<span class="input-group-addon">SW F2<small>(ppm)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-SWf2" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="SW">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-noesy1d input-nmrProg-TOCSY "><!-- NOESY-1D TOCSY -->
									<span class="input-group-addon">Mixing time <small>(s)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-D8" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="D8">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-cpmg1d "><!-- CPMG-1D -->
									<span class="input-group-addon">Spin-echo delay <small>(µs)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-spinEchoDelay" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="400">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-cpmg1d "><!-- CPMG-1D -->
									<span class="input-group-addon">Number of loops</span> 
									<input id="add1spectrum-analyzserNMR-programm-numberOfLoops" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="80">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-C13 "><!-- C13 -->
									<span class="input-group-addon">Decoupling type</span> 
									<input id="add1spectrum-analyzserNMR-programm-decouplingType" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="waltz16">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC "><!-- COSY TOCSY HSQC HMBC  -->
									<span class="input-group-addon">SW <small>(ppm)</small> 1H</span> 
									<input id="add1spectrum-analyzserNMR-programm-SW1h" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-HSQC input-nmrProg-HMBC "><!-- HSQC HMBC-->
									<span class="input-group-addon">SW <small>(ppm)</small> 13C</span> 
									<input id="add1spectrum-analyzserNMR-programm-SWc" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-HSQC"><!-- HSQC -->
									<span class="input-group-addon">Decouplage Type</span> 
									<input id="add1spectrum-analyzserNMR-programm-decouplageType" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="D8">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-HSQC "><!-- HSQC -->
									<span class="input-group-addon">JXH <small>(Hz)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-JXH" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-HMBC "><!-- HMBC -->
									<span class="input-group-addon">JXH long range <small>(Hz)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-JXH-lr" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<!-- NUS -->
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC"><!-- COSY TOSCY NOESY HSQC HMBC -->
									<span class="input-group-addon">NUS <small>(Non Uniform Sampling)</small></span> 
									<select id="add1spectrum-analyzserNMR-nus" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="yes">Yes</option>
										<option value="no">No</option>
									</select>
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC"><!-- COSY TOSCY NOESY HSQC HMBC -->
									<span class="input-group-addon">NUS Amount<small>(%)</small></span> 
									<input id="add1spectrum-analyzserNMR-programm-nus-amount" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<div class="form-group input-group input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY input-nmrProg-HSQC input-nmrProg-HMBC"><!-- COSY TOSCY NOESY HSQC HMBC -->
									<span class="input-group-addon">NUS Points</span> 
									<input id="add1spectrum-analyzserNMR-programm-nus-points" type="text" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-peaklist is-optional" placeholder="???">
								</div>
								<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
							</div>
						</div>
					</div>
					<div class="col-lg-6">
						<br />
						<div class="panel panel-default nmr-1dh nmr-1dc" style="display: none;">
							<!-- processing for 1D proton / carbon acquisitions -->
							<div class="panel-heading">
								<h3 class="panel-title">Spectra processing parameters</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">Fourier transform</span> 
									<select id="add1spectrum-analyzer-nmr-processing-fourierTransfo" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled">choose in list&hellip;</option>
										<option selected="selected" value="false">False</option>
										<option value="true">True</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">SI</span> 
									<!-- 16k; 32k; 64k; 128k (1D)-->
									<select id="add1spectrum-analyzer-nmr-processing-si" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="16000">16k</option>
										<option value="32000">32k</option>
										<option value="64000">64k</option>
										<option value="128000">128k</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Line broadening</span> 
									<input id="add1spectrum-analyzer-nmr-processing-lineBroadening" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										Hz
									</span>
								</div>
							</div>
						</div>
						<div class="panel panel-default nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
							<!-- processing for 1D proton / carbon acquisitions -->
							<div class="panel-heading">
								<h3 class="panel-title">Spectra processing parameters</h3>
							</div>
							<div class="panel-body">
								<!-- Fourier transform // ALL -->
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">Fourier transform</span> 
									<select id="add1spectrum-analyzer-nmr-processing-fourierTransfo-2d" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled">choose in list&hellip;</option>
										<option selected="selected" value="false">False</option>
										<option value="true">True</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-jres " style="display: none;">
									<span class="input-group-addon">Tilt</span> 
									<select id="add1spectrum-analyzer-nmr-processing-tilt" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="no">No</option>
										<option value="yes">Yes</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">SI <small>(F1)</small></span> 
									<select id="add1spectrum-analyzer-nmr-processing-SIf1" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="64">64</option>
										<option value="128">128</option>
										<option value="256">256</option>
										<option value="512">512</option>
										<option value="1024">1024</option>
										<option value="2048">2048</option>
										<option value="4096">4096</option>
										<option value="8192">8192</option>
										<option value="16k">16k</option>
										<option value="32k">32k</option>
										<option value="64k">64k</option>
										<option value="128k">128k</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">SI <small>(F2)</small></span> 
									<select id="add1spectrum-analyzer-nmr-processing-SIf2" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="64">64</option>
										<option value="128">128</option>
										<option value="256">256</option>
										<option value="512">512</option>
										<option value="1024">1024</option>
										<option value="2048">2048</option>
										<option value="4096">4096</option>
										<option value="8192">8192</option>
										<option value="16k">16k</option>
										<option value="32k">32k</option>
										<option value="64k">64k</option>
										<option value="128k">128k</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">Window function <small>(F1)</small></span> 
									<select id="add1spectrum-analyzer-nmr-processing-windowFunctionF1" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="no">no</option>
										<option value="EM">EM</option>
										<option value="SINE">SINE</option>
										<option value="QSINE">QSINE</option>
										<option value="GM">GM</option>
										<option value="other">other</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">Window function <small>(F2)</small></span> 
									<select id="add1spectrum-analyzer-nmr-processing-windowFunctionF2" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="no">no</option>
										<option value="EM">EM</option>
										<option value="SINE">SINE</option>
										<option value="QSINE">QSINE</option>
										<option value="GM">GM</option>
										<option value="other">other</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">Line broadening <small>(F1)</small></span> 
									<input id="add1spectrum-analyzer-nmr-processing-lineBroadeningF1" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										Hz
									</span>
								</div>
								<div class="form-group input-group nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">Line broadening <small>(F2)</small></span> 
									<input id="add1spectrum-analyzer-nmr-processing-lineBroadeningF2" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										Hz
									</span>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">SSB <small>(F1)</small></span> 
									<input id="add1spectrum-analyzer-nmr-processing-ssbF1" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										<small>(Only if SINE or QSINE)</small>
									</span>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">SSB <small>(F2)</small></span> 
									<input id="add1spectrum-analyzer-nmr-processing-ssbF2" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										<small>(Only if SINE or QSINE)</small>
									</span>
								</div>
								
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">GB <small>(F1)</small></span> 
									<input id="add1spectrum-analyzer-nmr-processing-gbF1" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										<small>(Only if GM)</small>
									</span>
								</div>
								<div class="form-group input-group nmr-2d-jres nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">GB <small>(F2)</small></span> 
									<input id="add1spectrum-analyzer-nmr-processing-gbF2" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										<small>(Only if GM)</small>
									</span>
								</div>
								<div class="form-group input-group nmr-2d-jres " style="display: none;">
									<span class="input-group-addon">Peak Picking</span> 
									<select id="add1spectrum-analyzer-nmr-processing-peakPicking" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="manual">manual</option>
										<option value="automatic">automatic</option>
									</select>
								</div>
								<div class="form-group input-group nmr-2d-jres " style="display: none;">
									<span class="input-group-addon">Symmetrize</span> 
									<select id="add1spectrum-analyzer-nmr-processing-symmetrize" class="form-control add1spectrum add1spectrum-analyzerNMRForm add1spectrum-analyzserNMR-programm-processing is-optional">
										<option value="" disabled="disabled" selected="selected">choose in list&hellip;</option>
										<option value="no">No</option>
										<option value="yes">Yes</option>
									</select>
								</div>
								<div class="form-group input-group  nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy nmr-2d-hsqc nmr-2d-hmbc" style="display: none;">
									<span class="input-group-addon">NUS processing parameter</span> 
									<input id="add1spectrum-analyzer-nmr-processing-nusProcessingParameter" class="form-control add1spectrum  add1spectrum-analyzerNMRForm  add1spectrum-analyzserNMR-programm-processing is-optional" type="text" placeholder="e.g.: 0.3">
									<span class="input-group-addon">
										<small>???</small>
									</span>
								</div>
							</div>
						</div>
						<div class="panel panel-default">
							<!-- raw file -->
							<div class="panel-heading">
								<h3 class="panel-title">Raw spectra file</h3>
							</div>
							<div class="panel-body">
								<input type="hidden" id="rawFileTmpName" value="">
								<div class="pull-right">
									<br />
									<span id="rawNmrFileUploadContainer"></span>
									<div id="addRawNmrFileFormContent" class="input-group pull-right" style="max-width: 350px;">
										<span class="input-group-btn">
												<span class="btn btn-primary btn-file-nmr-raw btn-file"> Browse&#133;
													<input id="rawNmrFile" type="file" name="file" accept=".zip">
												</span>
												<!-- multiple="" -->
												<input type="hidden" name="ajaxUpload" value="true">
												<input id="raw_file_spectrum_id" name="spectrum_id" type="hidden" value="-1" />
										</span> <input type="text" class="form-control" readonly>
									</div>
									<br />
									<small>
										Add a new &quot;Raw&quot; file. <br />
										You must Zip the directory of you acquisition data to upload it.
									</small>
									<br />
									<br />
								</div>
								<div class="">
								</div>
								<div id="rawNmrFileUploading" class="" style="display:none;" >
									<br />
									<br />
									<img src="<c:url value="/resources/img/ajax-loader-big.gif" />" title="<spring:message code="page.search.results.pleaseWait" text="please wait" />" />
								</div>
								<div id="rawNmrFileUploadResults" class="" style="display:none;" >
								</div>
								<div id="rawNmrFileUploadError" class="" style="max-width: 350px;" ></div>
							</div>
						</div>
					</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<br>
						<button id="btnSwitch-gotoStep4-nmr" onclick="switchToStep(4);" class="btn btn-disabled switchStep" disabled="disabled"><i class="fa fa-arrow-circle-down"></i> Next!</button>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 3.B: ANALYZER MS -->
	<div id="add1spectrum-analyserData-MS" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep3-ms" data-toggle="collapse" data-parent="#accordion" href="#step3-ms">
					MS Analyzer <i id="step3-ms-sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step3-ms" class="panel-collapse collapse" >
			<div class="panel-body">
				<div class="col-lg-12">
					<div class="col-lg-6">
						<br />
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Analyzer</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">Instrument</span> 
									<input id="add1spectrum-analyzer-ms-instrument" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-mandatory" placeholder="e.g. Q-TOF; LTQ - Orbitrap">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Model</span> 
									<input id="add1spectrum-analyzer-ms-model" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. QToF micro (Micromass Waters); XL; Impact II; ...">
								</div>
								<div class="form-group">
									<div class="form-group input-group ">
										<span class="input-group-addon">Ion analyzer Type</span> 
										<input id="add1spectrum-analyzer-ms-ionAnalyzerType" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-mandatory" placeholder="e.g. QTOF; QQQ; ...">
									</div>
									<p class="help-block">
										<small>
											Ion analyzer types are "B", "E", "FT" (include other types using FT like FTICR or Orbitrap), "IT", "Q", "TOF" (e.g.: "QTOF", "QQQ", "EB", "ITFT"); 
											for further informations please refer to <a target="_BLANK" href="<spring:message code="link.site.massbankdoc" text="https://github.com/MassBank/MassBank-web/blob/main/Documentation/MassBankRecordFormat.md#212-record_title" />">MassBank Record documentation</a>.
										</small>
									</p>
								</div>
							</div>
						</div>
					</div><!-- ./col-lg-6 -->
					
					<div class="col-lg-6">
						<br />
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Molecule Ionization</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">Ionization method <small>(POS/NEG)</small></span> 
									<select id="add1spectrum-analyzserMS-ionizationMethod-pos" style="max-width: 50%;" class="form-control add1spectrum add1spectrum-analyzerMSForm is-mandatory one-or-more">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip; (POS)</option>
									</select>
									<select id="add1spectrum-analyzserMS-ionizationMethod-neg" style="max-width: 50%;" class="form-control add1spectrum add1spectrum-analyzerMSForm is-mandatory one-or-more">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip; (NEG)</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Spray (needle) gaz flow <br><small>(arbitrary in Xcalibur, POS/NEG)</small></span> 
									<input id="add1spectrum-analyzserMS-sprayGazFlow-pos" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 40 (POS)">
									<input id="add1spectrum-analyzserMS-sprayGazFlow-neg" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 20 (NEG)">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Vaporizer gaz flow <br><small>(arbitrary in Xcalibur, POS/NEG)</small></span> 
									<input id="add1spectrum-analyzserMS-vaporizerGazFlow-pos" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 10 (POS)">
									<input id="add1spectrum-analyzserMS-vaporizerGazFlow-neg" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 5 (NEG)">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Vaporizer temperature <br><small>(°C, POS/NEG)</small></span> 
									<input id="add1spectrum-analyzserMS-vaporizerTemperature-pos" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 330 (POS)">
									<input id="add1spectrum-analyzserMS-vaporizerTemperature-neg" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 330 (NEG)">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Source gaz flow <br><small>(arbitrary in Xcalibur, POS/NEG)</small></span> 
									<input id="add1spectrum-analyzserMS-sourceGazFlow-pos" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 40 (POS)">
									<input id="add1spectrum-analyzserMS-sourceGazFlow-neg" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 40 (NEG)">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Ion transfer tube temperature <br> Transfer capillary temperature <small>(°C, POS/NEG)</small></span> 
									<input id="add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-pos"  style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 350 (POS)">
									<input id="add1spectrum-analyzserMS-ionTransferTubeTemperatureOrTransferCapillaryTemperature-neg"  style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 350 (NEG)">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">High voltage (ESI) <br> Corona voltage (APCI) <small>(in kV, POS/NEG)</small></span> 
									<input id="add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-pos" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 3.5 (POS)">
									<input id="add1spectrum-analyzserMS-highVoltageOrCoronaVoltage-neg" style="max-width: 50%;" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g. 2.8 (NEG)">
								</div>
							</div>
						</div>
					</div><!-- ./col-lg-6 -->
					
					<div class="col-lg-6 opt-msms">
						<br />
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Ion Storage / Ion Beam</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">Type <small>(storage / beam)</small></span> 
									<select id="add1spectrum-ionTrapBeam-type" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional one-or-more">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="trap">Ion Trap</option>
										<option value="beam">Ion Beam</option>
									</select>
								</div>
								<p class="help-block">
									<small>
										Ion storage: Ion Trap (IT) and ICR.
										<br />Ion beam: Q or H collision Cell (QQQ, QQIT, QQ/TOF, Fusion). 
									</small>
								</p>
								<div class="form-group input-group ">
									<span class="input-group-addon">Gas </span> 
									<select id="add1spectrum-ionTrapBeam-ionGas" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional ">
										<option value="He">He</option>
										<option value="N2">N<sub>2</sub></option>
										<option value="Ar">Ar</option>
									</select>
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">Gas pressure</span> 
									<input id="add1spectrum-ionTrapBeam-ionGasPressureValue" type="text" style="max-width: 50%;" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional " />
									<select id="add1spectrum-ionTrapBeam-ionGasPressureUnit" style="max-width: 50%;" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional ">
										<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
										<option value="mbar" >mbar</option>
										<option value="au" >a.u.</option>
									</select>
								</div>
								<div class="form-group input-group add1spectrum-ionTrap">
									<span class="input-group-addon">Frequency Shift <small>(KHz)</small></span> 
									<input id="add1spectrum-ionTrapBeam-ionFrequencyShift" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g.: ...">
								</div>
								<div class="form-group input-group add1spectrum-ionTrap">
									<span class="input-group-addon">Ion Number <small>(AGC or ICC)</small></span> 
									<input id="add1spectrum-ionTrapBeam-ionNumber" type="text" class="form-control add1spectrum add1spectrum-analyzerMSForm is-optional" placeholder="e.g.: ...">
								</div>
							</div>
						</div>
					</div><!-- ./col-lg-6 -->
					
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<br>
						<button id="btnSwitch-gotoStep4-ms" onclick="switchToStep(4);" class="btn btn-disabled switchStep" disabled="disabled"><i class="fa fa-arrow-circle-down"></i> Next!</button>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 4: PEAKS DATA -->
	<!-- ############################################################################################################################################# STEP 4.A: NMR PEAKS DATA -->
	<div id="add1spectrum-peaksData-NMR" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep4-nmr" data-toggle="collapse" data-parent="#accordion" href="#step4-nmr">
					NMR Peaks <i id="step4-nmr-sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step4-nmr" class="panel-collapse collapse" >
			<div class="col-lg-12 nmr-1dc" style="display:none;">
				<div class="panel-body">
					<ul class="nav nav-tabs" style="margin-bottom: 15px;">
						<li class="active"><a id="link-spectrum-peaklist-nmr-13c" href="#spectrum-peaklist-nmr-13c" data-toggle="tab"><i class="fa fa-table"></i> Peak List</a></li>
						<li class=""><a id="link-spectrum-preview-nmr" href="#spectrum-preview-nmr-13c" onclick="updateNMRspectraViewer13c()" data-toggle="tab"><i class="fa fa-bar-chart-o fa-flip-horizontal"></i> Spectrum Preview</a></li>
					</ul>
					<div id="spectrum-signal-data-13c" class="tab-content" style="">
						<div class="tab-pane fade active in" id="spectrum-peaklist-nmr-13c">
							<div class="panel panel-default input-nmrProg input-nmrProg-C13" style="display: none;">
								<div class="panel-heading">
									<h3 class="panel-title">carbon</h3>
								</div>
								<div class="panel-body" style="padding: 0px;">
									<div id="container_NMR_C_Peaks" class="handsontable"></div>
								</div>
							</div>
							<div class="panel panel-default input-nmrProg input-nmrProg-C13" style="display: none;">
								<div class="panel-heading">
									<h3 class="panel-title">multiplet (if C-H and/or C-C coupling) <small>J: use "," as separator; range: [ppm1 .. ppm2] </small></h3>
								</div>
								<div class="panel-body" style="padding: 0px;">
									<div id="container_NMR_C_Multi_Peaks" class="handsontable"></div>
								</div>
							</div>
						</div>
						<div class="tab-pane fade" id="spectrum-preview-nmr-13c">
							<!-- PREVIEW -->
							<div id="containter-nmr-spectrum-preview-13c" style="width: 80%;"></div>
							</div>
							<script type="text/javascript">

							</script>
						</div>
					</div>
			
			</div>
			<div class="col-lg-12 nmr-1dh" style="display:none;">
				<div class="panel-body">
					
					<ul class="nav nav-tabs" style="margin-bottom: 15px;">
						<li class="active"><a id="link-spectrum-peaklist-nmr" href="#spectrum-peaklist-nmr" data-toggle="tab"><i class="fa fa-table"></i> Peak List</a></li>
						<li class=""><a id="link-spectrum-preview-nmr" href="#spectrum-preview-nmr" onclick="updateNMRspectraViewer()" data-toggle="tab"><i class="fa fa-bar-chart-o fa-flip-horizontal"></i> Spectrum Preview</a></li>
					</ul>
					<div id="spectrum-signal-data" class="tab-content" style="">
						<div class="tab-pane fade active in" id="spectrum-peaklist-nmr">
							<div class="panel panel-default input-nmrProg input-nmrProg-H input-nmrProg-noesy1d input-nmrProg-cpmg1d" style="display: none;">
								<div class="panel-heading">
									<h3 class="panel-title">proton nmr peaks</h3>
								</div>
								<div class="panel-body" style="padding: 0px;">
									<div id="container_NMR_H_Peaks" class="handsontable"></div>
								</div>
							</div>
							<div class="panel panel-default input-nmrProg input-nmrProg-H input-nmrProg-noesy1d input-nmrProg-cpmg1d" style="display: none;">
								<div class="panel-heading">
									<h3 class="panel-title">proton nmr peaks + sat</h3>
								</div>
								<div class="panel-body" style="padding: 0px;">
									<div id="container_NMR_Hsat_Peaks" class="handsontable"></div>
								</div>
							</div>
							<div class="panel panel-default input-nmrProg input-nmrProg-H input-nmrProg-noesy1d input-nmrProg-cpmg1d" style="display: none;">
								<div class="panel-heading">
									<h3 class="panel-title">multiplet <small>J: use "," as separator; range: [ppm1 .. ppm2] </small></h3>
								</div>
								<div class="panel-body" style="padding: 0px;">
									<div id="container_NMR_Multi_Peaks" class="handsontable"></div>
								</div>
							</div>
						</div>
						<div class="tab-pane fade" id="spectrum-preview-nmr">
							<!-- PREVIEW -->
							<div id="containter-nmr-spectrum-preview" style="width: 80%;"></div>
						</div>
					</div>
				</div>
			</div>
			<div class="col-lg-12 nmr-2d-hsqc nmr-2d-hmbc" style="display:none;">
				<div class="panel-body">
					<div class="panel panel-default input-nmrProg input-nmrProg-HSQC input-nmrProg-HMBC" style="display: none;">
						<div class="panel-heading">
							<h3 class="panel-title nmr-2d-hsqc">HSQC</h3>
							<h3 class="panel-title nmr-2d-hmbc">HMBC</h3>
						</div>
						<div class="panel-body" style="padding: 0px;">
							<div id="container_NMR_2DHC_Peaks" class="handsontable"></div>
						</div>
					</div>
				</div>
			</div>
			<div class="col-lg-12 nmr-2d-cosy nmr-2d-tocsy nmr-2d-noesy" style="display:none;">
				<div class="panel-body">
					<div class="panel panel-default input-nmrProg input-nmrProg-COSY input-nmrProg-TOCSY input-nmrProg-NOESY" style="display: none;">
						<div class="panel-heading">
							<h3 class="panel-title nmr-2d-cosy">COSY</h3>
							<h3 class="panel-title nmr-2d-tocsy">TOCSY</h3>
							<h3 class="panel-title nmr-2d-noesy">NOESY</h3>
						</div>
						<div class="panel-body" style="padding: 0px;">
							<div id="container_NMR_2DHH_Peaks" class="handsontable"></div>
						</div>
					</div>
				</div>
			</div>
			<div class="col-lg-12 nmr-2d-jres" style="display:none;">
				<div class="panel-body">
					<div class="panel panel-default input-nmrProg input-nmrProg-JRES" style="display: none;">
						<div class="panel-heading">
							<h3 class="panel-title ">JRES</h3>
						</div>
						<div class="panel-body" style="padding: 0px;">
							<div id="container_NMR_JRES_Peaks" class="handsontable"></div>
						</div>
					</div>
				</div>
			</div>
			<div class="col-lg-12">
				<div class="col-lg-8">
					<br>
					<button id="btnSwitch-gotoStep5-nmr" onclick="switchToStep(5);" class="btn btn-primary switchStep" ><i class="fa fa-arrow-circle-down"></i> Next!</button>
					<br>
					<br>
				</div>
				<div class="col-lg-4">&nbsp;</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 4.B: MS PEAKS DATA -->
	<div id="add1spectrum-peaksData-MS" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep4-ms" data-toggle="collapse" data-parent="#accordion" href="#step4-ms">
					MS Peaks <i id="step4-ms-sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step4-ms" class="panel-collapse collapse" >
			<div class="panel-body">
				<div class="col-lg-12">
					<div class="form-group input-group col-lg-3">
						<span class="input-group-addon">scan type</span> 
						<select  style="width: 150px;" id="add1spectrum-peaksMS-msLevel" class="form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm-peaklist-reset add1spectrum-peaksMSForm is-mandatory">
							<option value=""  disabled="disabled">choose in list&hellip;</option>
							<option value="ms" selected="selected">ms</option>
							<option class="enable-if-msms" value="ms2" disabled="disabled">ms2</option>
							<option class="enable-if-msms" value="ms3" disabled="disabled">ms3</option>
						</select>
					</div>
					<div class="form-group input-group col-lg-3">
						<span class="input-group-addon">polarity</span> 
						<select  style="width: 150px;" id="add1spectrum-peaksMS-polarity" class="form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm-peaklist-reset add1spectrum-peaksMSForm is-mandatory">
							<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
							<option value="positive" disabled="disabled">positive</option>
							<option value="negative" disabled="disabled">negative</option>
						</select>
					</div>
					<div class="form-group input-group col-lg-3">
						<span class="input-group-addon">resolution</span> 
						<select  style="width: 150px;" id="add1spectrum-peaksMS-resolution" class="form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm-peaklist-reset add1spectrum-peaksMSForm is-mandatory">
							<option value="" selected="selected" disabled="disabled">choose in list&hellip;</option>
							<option value="low">low</option>
							<option value="high">high</option>
						</select>
					</div>
					<div class="form-group input-group col-lg-3">
						<span class="input-group-addon">curation</span> 
						<select  style="width: 150px;" id="add1spectrum-peaksMS-curation" class="form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm-peaklist-reset add1spectrum-peaksMSForm is-optional">
							<option value="no_curation" selected="selected">no curation</option>
							<option value="peaks_RI_sup_1percent">Peaks RI > 1%</option>
							<option value="top_50_peaks">Top 50 peaks</option>
							<option value="top_20_peaks">Top 20 peaks</option>
							<option value="top_10_peaks">Top 10 peaks</option>
							<option value="similar_chromatographic_profile">Similar chromatographic profile</option>
						</select>
					</div>
				</div>
				<br />
				<div class="col-lg-12 opt-msms">
					
					<hr />
					
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">precursor spectrum</span> 
						<select style="width: 150px;" id="add1spectrum-peaksMS-msPrecursor" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm-peaklist-reset add1spectrum-peaksMSForm is-optional">
							<option value=""  disabled="disabled">choose in list&hellip;</option>
						</select>
					</div>
					
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Precursor ion <i class="fa fa-question-circle" title="2 digits of precision."></i> <small>(M/Z)</small></span> 
						<input id="add1spectrum-peaksMS-msPrecursorIon" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional add1spectrum-peaksMSForm-peaklist-reset" placeholder="e.g. 123.45">
					</div>

					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Isolation mode <i class="fa fa-question-circle" title="IT / Q / TOF / ICR"></i></span> 
<!-- 						<input id="add1spectrum-peaksMS-isolationMode" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional add1spectrum-peaksMSForm-peaklist-reset" placeholder="e.g. ..."> -->
						<select id="add1spectrum-peaksMS-isolationMode" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm is-optional add1spectrum-peaksMSForm-peaklist-reset">
							<option value=""  disabled="disabled">choose in list&hellip;</option>
							<option value="IT">IT</option>
							<option value="Q">Q</option>
							<option value="TOF">TOF</option>
							<option value="ICR">ICR</option>
						</select>
						
					</div>
					
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Isolation window <i class="fa fa-question-circle" title="(+ / - value)"></i></span> 
						<input id="add1spectrum-peaksMS-isolationWindow" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional add1spectrum-peaksMSForm-peaklist-reset" placeholder="e.g. ...">
					</div>
					
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">qz isolation / activation <i class="fa fa-question-circle" title="if IT"></i> <small>(no unit)</small></span> 
						<input id="add1spectrum-peaksMS-qzIsolation" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional add1spectrum-peaksMSForm-peaklist-reset" placeholder="e.g. ...">
					</div>
					
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Activation time <i class="fa fa-question-circle" title="if FT-ICR (SORI-CID) or IT"></i> <small>(ms)</small></span> 
						<input id="add1spectrum-peaksMS-activationTime" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional add1spectrum-peaksMSForm-peaklist-reset" placeholder="e.g. ...">
					</div>
					
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Mode <i class="fa fa-question-circle" title="HCD / CID / ECD /ETD"></i></span> 
<!-- 						<input id="add1spectrum-peaksMS-mode" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional add1spectrum-peaksMSForm-peaklist-reset" placeholder="e.g. ..."> -->
						<select id="add1spectrum-peaksMS-mode"" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist add1spectrum-peaksMSForm is-optional ">
							<option value=""  disabled="disabled">choose in list&hellip;</option>
							<option value="HCD">HCD</option>
							<option value="CID">CID</option>
							<option value="ECD">ECD</option>
							<option value="ETD">ETD</option>
						</select>
					</div>

					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Frag. energy <i class="fa fa-question-circle" title="without unit"></i> </span> 
						<input id="add1spectrum-peaksMS-frag-nrj" type="text" class="disabled-if-ms-in-msms form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional" placeholder="e.g. ...">
					</div>
					
				</div>
				<div class="col-lg-12">
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">Resolution FWHM <small>(resolution@mass)</small></span> 
						<input id="add1spectrum-analyzer-ms-resolutionFWHM" type="text" class="form-control add1spectrum add1spectrum-peaksMSForm-peaklist is-optional" placeholder="e.g. 6500@1000">
					</div>
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">m/z range <small>(ppm) from / to</small></span> 
						<input style="width: 100px;" id="add1spectrum-peaksMS-rangeFrom" type="text" class="form-control add1spectrum-peaksMSForm-peaklist add1spectrum  is-mandatory" placeholder="50">
						<input style="width: 100px;" id="add1spectrum-peaksMS-rangeTo" type="text" class="form-control add1spectrum-peaksMSForm-peaklist add1spectrum  is-mandatory" placeholder="500">
					</div>
<!-- 					<div class="form-group input-group "> -->
<!-- 						<span class="input-group-addon">m/z range to</span>  -->
<!-- 						<input style="width: 100px;" id="add1spectrum-peaksMS-rangeTo" type="text" class="form-control add1spectrum  is-mandatory" placeholder="500"> -->
<!-- 					</div> -->
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">retention time (min) <small>from / to</small></span> 
						<input style="width: 100px;" id="add1spectrum-peaksMS-rtMinFrom" type="text" class="form-control add1spectrum-peaksMSForm-peaklist add1spectrum  is-mandatory" placeholder="0.9">
						<input style="width: 100px;" id="add1spectrum-peaksMS-rtMinTo" type="text" class="form-control add1spectrum-peaksMSForm-peaklist add1spectrum  is-mandatory" placeholder="1.4">
					</div>
				</div>
				<div class="col-lg-12">
<!-- 					<div class="form-group input-group "> -->
<!-- 						<span class="input-group-addon">retention time (min) to</span>  -->
<!-- 						<input style="width: 100px;" id="add1spectrum-peaksMS-rtMinTo" type="text" class="form-control add1spectrum  is-mandatory" placeholder="1.4"> -->
<!-- 					</div> -->
					<div class="form-group input-group col-lg-4">
						<span class="input-group-addon">retention time (% solvant) <small>from / to</small></span> 
						<input style="width: 100px;" id="add1spectrum-peaksMS-rtSolvFrom" type="text" class="form-control add1spectrum-peaksMSForm-peaklist add1spectrum  is-optional" placeholder="??">
						<input style="width: 100px;" id="add1spectrum-peaksMS-rtSolvTo" type="text" class="form-control add1spectrum-peaksMSForm-peaklist add1spectrum  is-optional" placeholder="??">
					</div>
<!-- 					<div class="form-group input-group "> -->
<!-- 						<span class="input-group-addon">retention time (% solvant) to</span>  -->
<!-- 						<input style="width: 100px;" id="add1spectrum-peaksMS-rtSolvTo" type="text" class="form-control add1spectrum  is-mandatory" placeholder="??"> -->
<!-- 					</div> -->
					<div class="col-lg-4">&nbsp;</div>	
				</div>
				<div class="col-lg-12">
					<div class="col-lg-11">
						<br>
						<ul class="nav nav-tabs" style="margin-bottom: 15px;">
							<li class="active"><a id="link-spectrum-peaklist-lcms" href="#spectrum-peaklist-lcms" data-toggle="tab"><i class="fa fa-table"></i> Peak List</a></li>
							<li class=""><a id="link-spectrum-preview-lcms" href="#spectrum-preview-lcms" onclick="updateLCMSspectraViewer()" data-toggle="tab"><i class="fa fa-bar-chart-o"></i> Spectrum Preview</a></li>
						</ul>
						<div id="spectrum-signal-data-lcms" class="tab-content" style="">
							<div class="tab-pane fade active in" id="spectrum-peaklist-lcms">
								<div class="panel-body" style="padding: 0px;">
									<div id="container_MS_Peaks" class="handsontable"></div>
								</div>
							</div>
							<div class="tab-pane fade" id="spectrum-preview-lcms">
								<!-- PREVIEW -->
								<div id="containter-lcms-spectrum-preview" style="width: 80%;"></div>
							</div>
						</div>
					</div>
					<div class="col-lg-1"></div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<button id="btnSwitch-gotoStep5-ms" onclick="switchToStep(5);" class="btn btn-primary switchStep"><i class="fa fa-arrow-circle-down"></i> Next!</button>
						<br>
						<br>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
	<!-- ############################################################################################################################################# STEP 5: OTHER DATA -->
	<div id="add1spectrum-otherData" class="panel panel-default" style="display: none;">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a id="linkActivateStep5" data-toggle="collapse" data-parent="#accordion" href="#step5">
					Other <i id="step5sign" class="fa fa-question-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step5" class="panel-collapse collapse" >
			<div class="panel-body">
				<div class="col-lg-12">
					<div class="col-lg-6">
						<!-- ######################################################## -->
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Ownership</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">data author(s)</span> 
									<input id="add1spectrum-other-author" type="text" class="form-control add1spectrum add1spectrum-otherForm is-mandatory" placeholder="enter your lab. / plateforme name" value="">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">data validator(s)</span> 
									<input id="add1spectrum-other-validator" type="text" class="form-control add1spectrum add1spectrum-otherForm is-optional" placeholder="name of the personne who checked all data in this file">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">acquisition date</span> 
									<%
 										DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
 																Date date = new Date();
 									%>
									<input id="add1spectrum-other-date" data-date-format="yyyy-mm-dd"  type="text" class="form-control add1spectrum  add1spectrum-otherForm datepicker is-optional" value="" placeholder="<%=dateFormat.format(date)%>">
								</div>								
								<div class="form-group input-group ">
									<span class="input-group-addon">data ownership</span> 
									<input id="add1spectrum-other-owner" type="text" class="form-control add1spectrum add1spectrum-otherForm is-optional" placeholder="enter your lab. / plateforme name &amp; sample provider;">
								</div>
							</div>
						</div>
						<!-- ######################################################## -->
					</div>
					<div class="col-lg-6">
						<!-- ######################################################## -->
						<div class="panel panel-default">
							<div class="panel-heading">
								<h3 class="panel-title">Raw File</h3>
							</div>
							<div class="panel-body">
								<div class="form-group input-group ">
									<span class="input-group-addon">raw file name</span> 
									<input id="add1spectrum-other-fileName" type="text" class="form-control add1spectrum add1spectrum-otherForm is-optional" placeholder="needed to retrieve file later">
								</div>
								<div class="form-group input-group ">
									<span class="input-group-addon">raw file size (Ko)</span> 
									<input id="add1spectrum-other-fileSize" type="text" class="form-control add1spectrum add1spectrum-otherForm is-optional" placeholder="optional, to check if the file is correct">
								</div>
							</div>
						</div>
						<!-- ######################################################## -->
					</div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<br>
						<button id="btnSwitch-gotoStep6" onclick="switchToStep(6);" class="btn btn-disabled switchStep" disabled="disabled"><i class="fa fa-arrow-circle-right"></i> Submit!</button>
						<button id="btnSwitch-gotoStep7" onclick="switchToStep(7);" class="btn btn-disabled switchStep"><i class="fa fa fa-file-excel-o"></i> Dump in XLSM file</button>
						<a id="btnDownloadDumpForm" href="." target="#" class="btn btn-success" style="display: none;"></a>
						<span id="import1SpectrumLoadingBare" style="display: none;"><img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait"></span>
						<span id="import1SpectrumResults" style="display: none;">
							<button id="btnSwitch-view" data-toggle="modal" data-target="#modalShowSpectra" class="btn btn-success"><i class="fa fa-eye"></i> View spectrum</button>
							<button id="btnSwitch-returntoStep3" onclick="switchToStep(3);" class="btn btn-primary"><i class="fa fa-arrow-circle-up"></i> Add new peaklist!</button>
						</span>
					</div>
					<div class="col-lg-4"><br><br><br></div>
				</div>
				<div class="col-lg-12">
					<div class="col-lg-8">
						<div id="alertBoxSubmitSpectrum" class="col-lg-6"></div>
					</div>
					<div class="col-lg-4">&nbsp;</div>
				</div>
			</div>
		</div>
	</div>
</div><!-- /id="accordion" -->
<script src="<c:url value="/resources/handsontable/dist/handsontable.full.min.js" />"></script>
<script type="text/javascript">
var fitlerSearchLoadlCpd = <%=PeakForestUtils.SEARCH_COMPOUND_CHEMICAL_NAME%>;
//<% if (request.getParameter("inchikey")!=null && !request.getParameter("inchikey").equals("")) { %>
var inchikey = '<%=request.getParameter("inchikey") %>';
//<% } else { %>
var inchikey = null;
//<% } %>
</script>
<link rel="stylesheet" media="screen" href="<c:url value="/resources/handsontable/dist/handsontable.full.min.css" />">
<link rel="stylesheet" media="screen" href="<c:url value="/resources/handsontable/bootstrap/handsontable.bootstrap.min.css" />">
<div style="display:none;">
	<form id="rawNmrFileUploadForm" action="upload-nmr-raw-file" method="POST" enctype="multipart/form-data" class="cleanform" onsubmit="return checkUploadRawNmrFileForm()">
	</form>
</div>
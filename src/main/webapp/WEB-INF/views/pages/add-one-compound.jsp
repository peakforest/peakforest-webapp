<%@page import="fr.metabohub.peakforest.utils.Utils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page session="false"%>

<div id="alertBoxAddOneCC" style="max-width: 750px;"></div>
<div class="panel-group" id="accordion">
	<div class="panel panel-default">
		<div class="panel-heading panel-success">
			<h4 class="panel-title">
				<a data-toggle="collapse" data-parent="#accordion" href="#step1">
					step 1: retrieve from databases <i id="step1sign" class="fa fa-check-circle"></i>
				</a>
			</h4>
		</div>
		<div id="step1" class="panel-collapse collapse in">
			<div class="panel-body">
				<!--  ++++++++++++++++++++++++++++ start import one CC STEP 1  -->
				<!-- Select Basic -->
				<div class="form-group">
					<label>Select basic data type</label> 
					<select id="add-one-cc-s1-type" class="form-control"
						onchange="changeNextPlaceholder(this);">
						<option value="<%= Utils.SEARCH_COMPOUND_INCHIKEY %>">InChIKey</option>
						<option value="<%= Utils.SEARCH_COMPOUND_MONOISOTOPIC_MASS %>">Monoisotopic Mass</option>
						<option value="<%= Utils.SEARCH_COMPOUND_AVERAGE_MASS %>">Average Mass</option>
						<option value="<%= Utils.SEARCH_COMPOUND_FORMULA %>">Formula</option>
						<option value="<%= Utils.SEARCH_COMPOUND_CHEMICAL_NAME %>">Chemical Name</option>
						<option value="<%= Utils.SEARCH_COMPOUND_INCHI %>">InChI</option>
					</select>
				</div>
				<!-- Prepended text-->
				<div class="form-group">
					<label>Value of the data entered below</label>
					<div class="form-group input-group">
						<input id="add-one-cc-s1-value" class="form-control" placeholder="e.g. RYYVLZVUVIJVGH-UHFFFAOYSA-N" type="text" <% 
								if (request.getParameter("inchikey") != null) {
									out.print("value=\""+request.getParameter("inchikey")+"\"");
								}
						%>>
						<span class="input-group-btn">
							<button class="btn btn-default" type="button"
								onclick="searchLocalCompound();">
								<i class="fa fa-search"></i>
							</button>
						</span>
					</div>
					<div style="height:300px;"></div>
				</div>

				<!--  ++++++++++++++++++++++++++++ end import one CC STEP 1  -->
			</div>
		</div>
	</div>
	<div id="divStep2" class="panel panel-default" style="display: none">
		<div class="panel-heading">
			<h4 class="panel-title">
				<a id="linkActivateStep2" data-toggle="collapse"
					data-parent="#accordion" href="#step2"> <!----> step 2: select
					compound to add <i id="step2sign"
					class="fa fa-exclamation-triangle"></i>
				</a>
			</h4>
		</div>
		<div id="step2" class="panel-collapse collapse">
			<div class="panel-body">
				<!--  ++++++++++++++++++++++++++++ start import one CC STEP 2  -->
				<div id="loading-1-2" style="display: none;">
					<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
				</div>

				<div id="ok-step-1" style="display: none;"></div>
			</div>
		</div>
	</div>
	<div id="divStep3" class="panel panel-default" style="display: none">
		<div class="panel-heading">
			<h4 class="panel-title">
				<a id="linkActivateStep3" data-toggle="collapse"
					data-parent="#accordion" href="#step3"> step 3: validate / add data <i id="step3sign" class="fa fa-exclamation-triangle"></i>
				</a>
			</h4>
		</div>
		<div id="step3" class="panel-collapse collapse">
			<div class="panel-body">

				<div id="loading-2-3" style="display: none;">
					<img src="<c:url value="/resources/img/ajax-loader.gif" />" title="please wait" />
				</div>

				<div id="ok-step-2" style="display: none;"></div>
				
			</div>
		</div>
	</div>
	<script>
		$('#add-one-cc-s1-value').bind('keypress', function(e) {
			var code = e.keyCode || e.which;
			if (code == 13) {
				searchLocalCompound();
			}
		});

		searchLocalCompound = function() {
			$("#ok-step-1").hide();
			$("#linkActivateStep2").trigger('click');
			$("#loading-1-2").show();
			$("#linkActivateStep2").parent().parent().css("color", "#3a87ad");
			$("#linkActivateStep2").parent().parent().css("background-color", "#d9edf7");
			$("#step2sign").removeClass("fa-exclamation-triangle fa-check-circle fa-spinner fa-spin fa-times-circle");
			$("#step2sign").addClass("fa-spinner fa-spin");
			$("#divStep2").show();
			$("#divStep3").hide();
			$.ajax({ 
				type: "post",
				url: "add-one-compound-search",
// 				dataType: "html",
				async: true,
				data: "query=" + $('#add-one-cc-s1-value').val() + "&filter=" +$("#add-one-cc-s1-type").val(),
				success: function(data) {
					console.log(data);
					$("#ok-step-1").html(data);
					// show div
					$("#linkActivateStep2").parent().parent().css("color", "#333");
					$("#linkActivateStep2").parent().parent().css("background-color", "#f5f5f5");
					$("#loading-1-2").hide();
					$("#ok-step-1").show();
					$("#step2sign").removeClass("fa-spinner fa-spin");
					$("#step2sign").addClass("fa-check-circle");
					if ($('#deepSearchMessage').length == 0) {
						location.href = "home";
					}
				},
				error : function(xhr) {
					// log
					console.log(xhr);
					// error
					$("#ok-step-1").html("Error: could not process request.");
					// show div
					$("#linkActivateStep2").parent().parent().css("color", "#333");
					$("#linkActivateStep2").parent().parent().css("background-color", "#f2dede");
					$("#loading-1-2").hide();
					$("#ok-step-1").show();
					$("#step2sign").removeClass("fa-spinner fa-spin");
					$("#step2sign").addClass("fa-times-circle");
				}
			});
		}
/////////////////////////////////////////////////////////////////////////////////////////
loadCompoundDetails = function(id, type) {
	$("#ok-step-2").hide();
	$("#linkActivateStep3").trigger('click');
	$("#loading-2-3").show();
	$("#linkActivateStep3").parent().parent().css("color","#3a87ad");
	$("#linkActivateStep3").parent().parent().css("background-color","#d9edf7");
	$("#step3sign").removeClass("fa-exclamation-triangle fa-check-circle fa-spinner fa-spin fa-times-circle");
	$("#step3sign").addClass("fa-spinner fa-spin");
	$("#divStep3").show();
	
	$.ajax({ 
		type: "post",
		url: "add-one-compound-load",
//			dataType: "html",
		async: true,
		data: "id=" + id + "&type=" + type,
		success: function(data) {
			console.log(data);
			$("#ok-step-2").html(data);
			// show div
		    $("#loading-2-3").hide();
		    $("#ok-step-2").show();
		    $("#linkActivateStep3").parent().parent().css("color","#333");
		    $("#linkActivateStep3").parent().parent().css("background-color","#f5f5f5");
		    $("#step3sign").removeClass("fa-spinner fa-spin");
		    $("#step3sign").addClass("fa-check-circle");
		},
		error: function(xhr) {
			// log
			console.log(xhr);
			// error
			$("#ok-step-2").html("Error: could not process request.");
			// show div
			$("#linkActivateStep3").parent().parent().css("color", "#333");
			$("#linkActivateStep3").parent().parent().css("background-color", "#f2dede");
			$("#loading-2-3").hide();
			$("#ok-step-2").show();
			$("#step3sign").removeClass("fa-spinner fa-spin");
			$("#step3sign").addClass("fa-times-circle");
		}
	});


}
/////////////////////////////////////////////////////////////////////////////////////////
		// form add chemical compound
		changeNextPlaceholder = function(elem) {
			switch ($(elem).val()) {
			case "<%= Utils.SEARCH_COMPOUND_INCHIKEY %>":
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. RYYVLZVUVIJVGH-UHFFFAOYSA-N");
				break;
			case "<%= Utils.SEARCH_COMPOUND_MONOISOTOPIC_MASS %>":
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. 194.0804");
				break;
			case "<%= Utils.SEARCH_COMPOUND_AVERAGE_MASS %>":
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. 194.1906");
				break;
			case "<%= Utils.SEARCH_COMPOUND_FORMULA %>":
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. C8H10N4O2");
				break;
			case "<%= Utils.SEARCH_COMPOUND_CHEMICAL_NAME %>":
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. Caffeine");
				break;
			case "<%= Utils.SEARCH_COMPOUND_INCHI %>":
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. InChI=1S/C8H10N4O2/c1-10-4-9-6-5(10)7(13)12(3)8(14)11(6)2/h4H,1-3H3");
				break;
			default:
				$('#add-one-cc-s1-value').attr("placeholder", "e.g. xxx");
			}
		}
/////////////////////////////////////////////////////////////////////////////////////////
	// autocomplete
	var subjects = [];
// 	$('#search').typeahead({source: subjects});
	$('#add-one-cc-s1-value').typeahead({
		source: function (query, process) {
	        return searchAjax();
	    }
	});
	searchAjax = function () {
		var results = [];
		var rawQuery = $('#add-one-cc-s1-value').val();
		if (rawQuery.length > 2) {
			$.ajax({ 
					type: "post",
					url: "search",
					dataType: "json",
					async: false,
					data: "query=" + $('#add-one-cc-s1-value').val(),
					// TODO add filter search compound / compound name / mass / ...
					success: function(json) {
						if (json.success) {
							// names
							$.each(json.compoundNames, function(){
								results.push(this.name);
							}); 
							// TODO  compounds: Array[0],
							$.each(json.compounds, function(){
								if (this.inChIKey.indexOf(rawQuery))
									results.push(this.inChIKey);
							});
						}
// 					console.log(json);
				},
				error : function(xhr) {
					subjects = [];
					// TODO alert error xhr.responseText
					console.log(xhr);
				}
			});
		}
		return results;
	};
/////////////////////////////////////////////////////////////////////////////////////////
	</script>
</div>
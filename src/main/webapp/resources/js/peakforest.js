/////////////////////////////////////////////////////////////////////////////////////////
// resize
$(window).resize(function() {
  resizeMainPanel();
});
setTimeout(function() {
  resizeMainPanel();
},50);
resizeMainPanel=function(){
	var diff_screen = 230;
	var search = $(location).attr('search');
	// search
	try{
		if (search.indexOf("search") >= 0) {
			if (isCompoundEntityOpen) {
				$("#search-results").height($(window).height()-diff_screen);
				$("#search-results").css("overflow","auto");
				var diff_screen = 190;
				$("#entityBody").height($(window).height()-diff_screen);
				$("#entityBody").css("overflow","auto");
				$("#search-results").css("overflow","hidden");
				searchResultsHeight = $('#search-results').height();
				$('#search-results').removeAttr('style');
			} else {
				$("#search-results").height($(window).height()-diff_screen);
				$("#search-results").css("overflow","auto");
			}
		} else if ($(search).length==0) {
//			$("#search-results").height($(window).height()-diff_screen);
//			$("#search-results").css("overflow","auto");
		} 
	} catch(e){}  
};
/////////////////////////////////////////////////////////////////////////////////////////
// $(document).ready(function() {
//   // Support for AJAX loaded modal window.
//   // Focuses on first input textbox after it loads the window.
//   $('[data-toggle="modal"]').click(function(e) {
//     e.preventDefault();
//     var url = $(this).attr('href');
//     if (url.indexOf('#') == 0) {
//       $(url).modal('open');
//     } else {
//     $.get(url, function(data) {
//       $('<div class="modal hide fade">' + data + '</div>').modal();
//     }).success(function() { $('input:text:visible:first').focus(); });
//     }
//   });
//   // file upload
// //   $('input[type=file]').bootstrapFileInput();
// //   $('.file-inputs').bootstrapFileInput();
// });

/////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
// search
//$(document).ready(function() {
//  var subjects = ['D-(+)-Raffinose pentahydrate','4-Aminobenzoic acid','Cyclic adenosine diphosphate-ribose','(R)-Mevalonic acid sodium salt','L-Norleucine','Theobromine','4-Methylhippuric acid','3-Aminopyridine-4-carboxylic acid','2,2-Dimethylglutaric acid','3,3-Dimethylglutaric acid','4-Pyridylacetic acid hydrochloride','3-METHYLADIPIC ACID'];   
//  $('#search').typeahead({source: subjects});
//});
// $('.typeahead').typeahead();
/////////////////////////////////////////////////////////////////////////////////////////
// slider
$(function() {
    //for jsfiddle so its mobile friendly.
    $('head').append('<meta name="viewport" content="width=device-width, initial-scale=1" />');
    //var $alert = $($(".alert")[0]);
    var $p = $($(".progress")[0]);
//     var $b = $($("[type='submit']")[0]);
    //var $d = $("#btn_enabled");
    var $t = $("#progress-value");
    $p.on("sliderchange", function (e, result) {
        //$alert.html("action: " + result.action + ", value: " + result.value + " Da");
	$t.val(result.value);
    });
    $p.on("slidercomplete", function (e, result) {
        console.log('slider completed!');
    });
//     $b.on('click', function (e) {
//         var value = parseFloat($t.val());
//         $p.slider("option", "now", value);
//         return false;
//     });
//     $d.on('click', function () {
//         if (!$d.hasClass('active')) {
//             $d.text('Disabled ');
//             $p.slider("option", "disabled", true);
//         } else {
//             $d.text('Enabled');
//             $p.slider("option", "disabled", false);
//         }
//     });
    $t.on('change', function() {
        var value = parseFloat($t.val());
        $p.slider("option", "now", value);
        return false;
    });
});
/////////////////////////////////////////////////////////////////////////////////////////
// custum bootstrap
$(document).ready(function(){
  //$('.combobox').combobox();
  //$(".combobox").height(25);
  $('.selectpicker').selectpicker();
});
/////////////////////////////////////////////////////////////////////////////////////////
//datepicker
$(document).ready(function(){
	$('.datepicker').datepicker();
});
/////////////////////////////////////////////////////////////////////////////////////////
// accordion fix bug
// $('#accordion').on('show.bs.collapse', function () {
//     $('#accordion .in').collapse('hide');
// });
/////////////////////////////////////////////////////////////////////////////////////////
// ajax modalbox
// $(document).ready(function() {
//   // Support for AJAX loaded modal window.
//   // Focuses on first input textbox after it loads the window.
//   $('[data-toggle="modal"]').click(function(e) {
//     e.preventDefault();
//     var url = $(this).attr('href');
//     if (url.indexOf('#') == 0) {
//       $(url).modal('open');
//     } else {
//       $.get(url, function(data) {
// 	$('<div class="modal hide fade">' + data + '</div>').modal();
//       }).success(function() { $('input:text:visible:first').focus(); });
//     }
//   });
// });
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// tabs
// $('#tabAddCompound a').click(function (e) {
//   e.preventDefault()
//   $(this).tab('show')
// });
// $('#tabAddCompound a:first').tab('show')
/////////////////////////////////////////////////////////////////////////////////////////
/**
 * Round a number 
 */
function roundNumber(num, dec) {
	var max = 1;
	for (var i = 0; i < dec; i++)
		max = max * 10;
	return Math.round(num * max) / max;
}
/////////////////////////////////////////////////////////////////////////////////////////
// overwrite default alert function (convert html message in text message, support utf-8)
(function() {
	var _alert = window.alert; 
	window.alert = function(str) {
		try {
			if (typeof str === "string")
				str = $.parseHTML(str)[0].data;
			if(console) 
				console.log(str);
			_alert(str);
		} catch(e) {}
	};
})();
/////////////////////////////////////////////////////////////////////////////////////////
$( document ).ready(function() {
	var r = ''; r+= '@';
	$('#linkcontact').attr('href','mailto:contact' + r + 'peakforest.org?subject=%5Babout%20peakforest%20webapp%5D');
	$(".pf-autofocus").focus(function() { $(this).select(); } );
});
/////////////////////////////////////////////////////////////////////////////////////////
function loadSpectrumNMRPro (div, id, label, scriptsURL, jsonURL) {
	label = encodeURI ($($.parseHTML( label )[0]).text());
	jQuery = jQuery.noConflict();
	jQuery.when( 
			jQuery.getScript( scriptsURL + "d3.v3.min.js" ),
			jQuery.getScript( scriptsURL + "specdraw.js" ),
			jQuery.Deferred(function( deferred ){
			jQuery( deferred.resolve );
	})).done(function(){
		//place your code here, the scripts are all loaded
		jQuery('#'+div).empty();
		var spec_app = specdraw.App().data(jsonURL + '/'+id+'?label=' + label); // 
		d3.select('#'+div).call(spec_app);
	    delete Array.prototype.subset;
	    delete Array.prototype.rotate;
	    delete Array.prototype.rotateTo;
	    delete Array.prototype.whichMax;
	    delete Array.prototype.cumsum;
	});
    $ = jQuery.noConflict();
};
/////////////////////////////////////////////////////////////////////////////////////////
function computeDisplayCpdInCartList() {
	$.each($(".btn-cpd-cart"), function() {
		var id = Number((($(this).attr("onclick")).replace("addRemoveCpdFromCart(","").replace(")","")));
		testIfCpdInCurrentCart(id)
	});
}
function addRemoveCpdFromCart(id) {
	id = Number(id);
	//$("#addRemoveCpd"+id).removeClass("fa-plus-circle").addClass("fa-times-circle");
	if ($(".addRemoveCpd"+id).hasClass("fa-plus-circle")) {
		// add
		addCpdInCart(id);
	} else {
		// remove
		removeCpdFromCart(id);
	}
}
function removeCpdFromCart(id){
	$.ajax({
		type: "POST",
		url: "remove-cpd-from-cart/" + id,
		dataType: 'json',
		async: false,
		success: function(data) {
			if(data) { 
				// cpd sheet + tools
				testIfCpdInCurrentCart(id);
			} else {
				// cpd sheet
				$("#removeCpdFromCart").parent().hide();
			}
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
// test
function testIfCpdInCurrentCart(id) {
	$.ajax({
		type: "GET",
		url: "is-cpd-in-cart/" + id,
		dataType: 'json',
		async: false,
		success: function(data) { 
			if(data) { 
				// cpd sheet
				$("#removeCpdFromCart").show();
				$("#removeCpdFromCart"+id).show();
				$("#addCpdInCart").hide();
				$("#addCpdInCart"+id).hide();
				// search
				$(".addRemoveCpd"+id).removeClass("fa-plus-circle").addClass("fa-times-circle");
				$(".addRemoveCpd"+id).parent().removeClass("btn-success");
				$(".addRemoveCpd"+id).parent().addClass("btn-danger");
			} else {
				// cpd sheet
				$("#removeCpdFromCart").hide();
				$("#addCpdInCart").show();
				$("#removeCpdFromCart"+id).hide();
				$("#addCpdInCart"+id).show();
				// search
				$(".addRemoveCpd"+id).removeClass("fa-times-circle").addClass("fa-plus-circle");
				$(".addRemoveCpd"+id).parent().removeClass("btn-danger")
				$(".addRemoveCpd"+id).parent().addClass("btn-success");
			}
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
function addCpdInCart(id){
	$.ajax({
		type: "POST",
		url: "add-cpd-in-cart/" + id,
		dataType: 'json',
		async: false,
		success: function(data) {
			if(data) { 
				testIfCpdInCurrentCart(id);
			} else {
				$("#removeCpdFromCart").parent().hide();
			}
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
function updateCart() {
	$.ajax({
		type: "get",
		url: "get-cpd-from-cart",
		dataType: 'json',
		async: false,
		success: function(data) { console.log(data)
			if(data.length == 0) { 
				$("#noCpdInCart").show();
				$("#cpdInCart").hide();
			} else {
				$("#compoundCartTableBody").empty();
				$("#noCpdInCart").hide();
				$("#cpdInCart").show();
				var compoundsDataTmp = [];
				$.each(data, function() {
					var nameBestScore = this.mainName;
					var rawFromula = this.formula;
					var formatedFormula = rawFromula + "";
					try {
						$.each($.unique( rawFromula.match(/\d/g)), function (keyF, valF) {
							var re = new RegExp(valF,"g");
							formatedFormula = formatedFormula.replace(re, "<sub>" + valF + "</sub>");
						});
						formatedFormula = formatedFormula.replace("</sub><sub>", "");
					} catch (e) {}
					var type = "?";
					if (this.hasOwnProperty("parent")) 
						type = "chemical";
					if (this.hasOwnProperty("children"))
						type = "generic";
					var hasSpectra = this.containSpectra;
					var object = { 
						name : nameBestScore, 
						id : this.id, 
						formula: formatedFormula,
						exactMass: roundNumber(this.monoisotopicMass,7),
						molWeight: roundNumber(this.averageMass,7),
						inchikey: this.inChIKey,
						type: type,
						spectra: hasSpectra,
						pfID: this.pfID
					};
					compoundsDataTmp.push(object);
				});
				$("#templateCompounds").tmpl(compoundsDataTmp).appendTo("#compoundCartTableBody");
				$.each($(".compoundFormula"), function(id, elem) {
					$(elem).html($(elem).text());
				});
			}
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
function cleanCpdInCart(){
	$.ajax({
		type: "POST",
		url: "clear-cpd-in-cart",
		dataType: 'json',
		async: false,
		success: function(data) {
			updateCart();
//			if(data) { 
//			} else {
//			}
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
function saveCpdCartAsJsonFile() {
	$.ajax({
		type: "GET",
		url: "get-cpd-in-cart.json",
		dataType: 'json',
		async: false,
		success: function(data) {
//			uriContent = "data:application/octet-stream," + (data);
//			newWindow = window.open(uriContent, 'peakforest-compounds.json');
			downloadJson('peakforest-compounds.json', data)
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
function loadCpdCartFromJsonFile(newList) {
	$.ajax({
		type: "POST",
		url: "load-cpd-in-cart",
//		data: newList,
		contentType: 'application/json',
		data: JSON.stringify(newList),
		dataType: 'json',
		async: false,
		success: function(data) {
			updateCart();
		}, 
		error : function(data) {
			console.log(data);
		}
	});
}
function downloadJson(filename, data) {
    var pom = document.createElement('a');
    var json = JSON.stringify(data);
    var blob = new Blob([json], {type: "application/json"});
    var url  = URL.createObjectURL(blob);
    pom.setAttribute('href', url);
    pom.setAttribute('download', filename);
    if (document.createEvent) {
        var event = document.createEvent('MouseEvents');
        event.initEvent('click', true, true);
        pom.dispatchEvent(event);
    }
    else {
        pom.click();
    }
}
/////////////////////////////////////////////////////////////////////////////////////////
// MetExplore Viz - (C) INRA 2017
$(document).ready(function(){
	if ($("#MEViz__biosource").length ===1) {
		$.getJSON("json/metexplore-biosources-list.json", function(data) {
			$("#MEViz__biosource").empty();
			$("#MEViz__biosource").append('<option disabled selected ></option>');
			$.each(data, function() {
				if (this.name !== undefined) {
					$("#MEViz__biosource").append('<option value="' + this.id + '">'+ this.name + '</option>');
				}
			});
			$("#MEViz__biosource").combobox();
		});
		$("#MEViz__biosource").on("change", function() {
			// load cpd
			var extraParam = getMEVizExtraParam(false);
			var inchikeys = [];
			if ($("#MEViz__loadCart_Y").is(":checked") || MEViz__autoLoadCart) 
				inchikeys = loadMEVizCart();
			//  fetch list bio source on the fly
			var biosource = Number( $("input[name='MEViz__biosource']").val());
			if (biosource != 0) {
				$.ajax({
					type: "GET",
					url: "get-pathways",
					data: "biosource="+ biosource + extraParam,
					dataType: 'json',
					async: false,
					success: function(data) {
						console.log(data);
						initSelectPathways(biosource, data, inchikeys);
					}, 
					error : function(data) {
						console.log(data);
					}
				});
			}
		});
		$("#MEViz__run").on("click", function() {
			$("#MEViz__pathwaysTarget").attr("disabled", true);
			$("#MEViz__mainFrame").children().remove();
			$("#MEViz__mainFrame").css("height","600px");
			$("#MEViz__mainFrame").css("width","100%");
			$("#MEViz__mainFrame").css("min-width","700px");
			$("#MEViz__mainFrame").html("loading...");
			// check cart
			var extraParam = getMEVizExtraParam(true);
			// RUN!!!
			var biosource = Number( $("input[name='MEViz__biosource']").val());
			$.ajax({
				type: "GET",
				url: "get-graph/"+biosource,
				data: "pathways="+ $("#MEViz__pathways").val() + extraParam,
				dataType: 'json',
				async: false,
				success: function(myJsonString) {
					$("#MEViz__mainFrame").html("");
					MetExploreViz.initFrame("MEViz__mainFrame");
					MetExploreViz.onloadMetExploreViz(function(){
						metExploreViz.GraphPanel.refreshPanel(JSON.stringify(myJsonString), function(){
							metExploreViz.onloadSession(function(){
								if (myJsonString.hasOwnProperty('mappingdata')) {
									metExploreViz.GraphMapping.mapNodes("PeakForest_MappingInChIKey");
								}
								if (myJsonString.hasOwnProperty('mappingInChIKeys')) {
									$.each(myJsonString['mappingInChIKeys'], function(k0,v0){
										$.each(v0,function(k1,v1){
											metExploreViz.GraphNode.selectNodeFromGrid(v1);
										});
									})
								}
						    }); 
						});
					});
					// lock form
					$("#MEViz__module input").attr("disabled", true);
					$("#MEViz__pathwaysTarget button").attr("disabled", true);
					$("#MEViz__run").attr("disabled", true);
				}, 
				error : function(data) {
					console.log(data);
					$("#MEViz__mainFrame").html("Error: sorry, MetExplore Viz could not process a selected pathway");
					// lock form
					$("#MEViz__module input").attr("disabled", true);
					$("#MEViz__pathwaysTarget button").attr("disabled", true);
					$("#MEViz__run").attr("disabled", true);
				}
			});
		});
		$("#MEViz__loadCart").on("click", function() {
			loadMEVizCart();
		});
		var countMEVizResets = 0;
		$("#MEViz__reset").on("click", function() {
			countMEVizResets++;
			if (countMEVizResets > 2) {
				if (confirm("Reload this browser page in order to reset MetExplore Viz old graphs?")) {
					document.location.hash = "#MEViz__module";
					document.location.reload();
				}
			}
			$("#MEViz__biosource").val('').attr("disabled", false);
			$("#MEViz__biosource").parent().find(".fa-remove").click()
			
			$("#MEViz__pathwaysTarget").html('<select id="MEViz__pathways" class="form-control " disabled></select>');
			
			$("#MEViz__mainFrame").children().remove();
			$("#MEViz__mainFrame").html("");
			$("#MEViz__mainFrame").css("height", "0px");
			$("#MEViz__mainFrame").css("width", "0%");
			$("#MEViz__mainFrame").css("min-width", "0px");
			
			// unlock
			$("#MEViz__module input").attr("disabled", false);
			$("#MEViz__pathwaysTarget button").attr("disabled", false);
			
			$("#MEViz__run").attr("disabled", true);
			$("#MEViz__loadCart").attr("disabled", true);
			//
			$("#MEViz__loadCart_Y").prop("checked", false);
			$("#MEViz__loadCart_N").prop("checked", true);
		});
	}
});
/**
 * Get ME Viz extra params
 * @param forceLoadCart true to load cart cpd
 * @returns more GET or POST params for the query
 */
function getMEVizExtraParam(forceLoadCart) {
	var listInChIKeys = [];
	var extraParam = "";
	try {
		if(currentMolInChIKey !== undefined && currentMolInChIKey !== null && currentMolInChIKey != "") { 
			listInChIKeys.push(currentMolInChIKey);
		}
	} catch (e){}
	// load cart IF (opt is checked and not in force mode (~> in cpd sheet, do not load cart for pathways list)) 
	// OR IF (autoload cart (~> PForest tools sheet) )
	if (($("#MEViz__loadCart_Y").is(":checked") && forceLoadCart ) || MEViz__autoLoadCart) {
		// current cart
		listInChIKeys.push.apply(listInChIKeys, loadMEVizCart())
	}
	if (listInChIKeys.lenght != 0) {
		extraParam += "&inchikeys=" + listInChIKeys;
	}
	return extraParam;
}
/**
 * 
 * @returns
 */
function loadMEVizCart() {
	var listInChIKeys = [];
	$.ajax({
		type: "get",
		url: "get-cpd-from-cart",
		dataType: 'json',
		async: false,
		success: function(data) { 
			if(data.length == 0) { 
			} else {
				$.each(data, function() {
					listInChIKeys.push(this.inChIKey);
				});
								
			}
		}, 
		error : function(data) {
			console.log(data);
		}
	});
	return listInChIKeys;
}
/**
 */
function initSelectPathways(idBiosource, pathways, inchikeys) {
	$("#MEViz__biosource").attr("disabled", true);
	$("#MEViz__pathwaysTarget").html('<select id="MEViz__pathways" class="form-control " multiple=""></select>');
	//$("#MEViz__pathways").append('<option disabled selected ></option>');
	$.each(pathways, function() {
		if (this.name !== undefined) {
			var extraString = "";
			//if (inchikeys.length != 0) {
			if (this.hasOwnProperty('mappedMetabolite')) {
				extraString += " <small>(nb mapped:"+this.mappedMetabolite+")</small>";//"/"+ inchikeys.length+
			}
			$("#MEViz__pathways").append('<option value="' + this.id + '">'+ this.name + extraString + '</option>');
		}
	});
	$("#MEViz__pathways").multiselect({
            enableFiltering: true,
            enableCaseInsensitiveFiltering: true,
            filterPlaceholder: 'Enter pathway...'
	});
	// onchange unlock build network
	$("#MEViz__pathways").on("change", function() {
		$("#MEViz__run").attr("disabled", false);
	});
	$(".multiselect-container.dropdown-menu").css("overflow-x","scroll")
	$(".multiselect-container.dropdown-menu").css("max-height","200px")
}

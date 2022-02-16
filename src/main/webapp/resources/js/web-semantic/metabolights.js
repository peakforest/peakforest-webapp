function listMetabolightsStudies(chebiid) {
	// init
	const config = SWDiscoveryConfiguration.setConfigString(`
{
    "sources" : [{
        "id"  : "metabolights",
        "url" : "https://metabolights.semantic-metabolomics.fr/sparql"
    }]
}
	`);
	let query = new SWDiscovery(config);
	// let chebiid = "CHEBI:4167";
	chebiid = chebiid + "";
	chebiid = chebiid.toLowerCase().indexOf("chebi") < 0 ? "CHEBI:" + chebiid : chebiid;
	let chebi = chebiid.replace( ':' , '_');
	let r = SWDiscovery(config).something()
				.set("http://purl.obolibrary.org/obo/" + chebi)
				.isObjectOf("https://www.ebi.ac.uk/metabolights/property#Xref","study")
				.filter.contains("MTBLS")
				.focus("study")
				.datatype("http://www.w3.org/2000/01/rdf-schema#label","label")
				.datatype("https://www.ebi.ac.uk/metabolights/property#technology_type","technology_type")
				.datatype("https://www.ebi.ac.uk/metabolights/property#comment","comment")
				.datatype("https://www.ebi.ac.uk/metabolights/property#instrument_platform","instrument_platform")
				.datatype("https://www.ebi.ac.uk/metabolights/property#Organism_Part","Organism_Part")
				.datatype("https://www.ebi.ac.uk/metabolights/property#study_design","study_design")
				.datatype("https://www.ebi.ac.uk/metabolights/property#study_factor","study_factor")
				.datatype("https://www.ebi.ac.uk/metabolights/property#organism","organism")
//				.datatype("https://www.ebi.ac.uk/metabolights/property#omics_type","omics_type")
//				.datatype("https://www.ebi.ac.uk/metabolights/property#publication","publication")
//				.datatype("https://www.ebi.ac.uk/metabolights/property#author","author")
				.select("study", "label", "technology_type", "comment", "instrument_platform",
						"Organism_Part", "study_design", "study_factor", "organism"); // "omics_type", "publication",
	// run
	r.commit().raw().then((response) => {
        let strData = "";
		for (let i = 0; i < response.results.bindings.length; i++) {
			let study               = response.results.bindings[i]["study"].value;
			let label               = response.results.datatypes["label"][study][0].value;
			let technology_type     = response.results.datatypes["technology_type"][study][0].value
			let comment             = response.results.datatypes["comment"][study][0].value;
			let instrument_platform = response.results.datatypes["instrument_platform"][study][0].value;
			let organism_part       = response.results.datatypes["Organism_Part"][study][0].value;
			let organism            = "";
			if (Object.prototype.hasOwnProperty.call(response.results.datatypes["organism"], study)) {
				organism            = response.results.datatypes["organism"][study][0].value;
			}
			let study_design        = "";
			if (Object.prototype.hasOwnProperty.call(response.results.datatypes["study_design"], study)) {
				study_design        = response.results.datatypes["study_design"][study][0].value;
			}
			let study_factor        = "";
			if (Object.prototype.hasOwnProperty.call(response.results.datatypes["study_factor"], study)) {
				study_factor        = response.results.datatypes["study_factor"][study][0].value;
			}
			// console.log(label, "=>", study, "; ", comment);
			comment = $.parseHTML(comment); //parseHTML return HTMLCollection
			comment = $(comment).text(); //use $() to get .text() method
			// new line
			strData += '<li class="list-group-item">' + 
				'<a href="' + study + '" target="_blank"><i class="fa fa-link"></i></a> ' + 
				'<span class="mtbls-technology-type">' + technology_type + '</span> ' +
				'<span class="mtbls-label" title="' + comment + '"> ' + label + '</span> ';
			// organism part
			if (organism_part !== "") { 
				strData += '<span class="mtbls-organism_part"> ' + organism_part + '</span> ';
			}
			// organism
			if (organism !== "") {
				let shortOrga = organism.replace('http://purl.obolibrary.org/obo/NCBITaxon_', '');
				strData += '<a class="mtbls-organism" href="' + organism + '" target="_blank">NCBITaxon:' + shortOrga + '</a> ';
			}
			// study_design
			if (study_design !== "") { 
				strData += '<span class="mtbls-keyword">' + study_design + '</span> ';
			}
			// study_design
			if (study_factor !== "") { 
				strData += '<span class="mtbls-keyword">' + study_factor + '</span> ';
			}
			strData += '<span class="mtbls-keyword">' + instrument_platform + '</span> ' +
				'</li>';
		}		
		// display or hide
		if (strData !== "") {
			document.getElementById('cardSheet_metabolights').innerHTML=('<ul class="list-group">'+strData+'</ul>');
		} else {
			$('#panel-metabolights-studies').hide();
		}
	});
}


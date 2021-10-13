/**
 * Custome chart.
 * 
 * @author Marie Lefebvre
 * @constructor
 */
var renderChartM = "#stgraph";
var renderChartS = "#stgraph";
//var listSpectra = "#spectraList";
urlS = "nmr-viewer-converter";
urlM = "nmr-viewer-converter";
var chart;                                      // initiate chart
var Rarray;                                     // initiate spetra to remove (only for multiple
$(renderChartM).empty();                        // clear DOM child elements
$(renderChartS).empty();  

///*
//* Function to get values of selected spectra
//*
//* @returns list of spectra "id,sample,pdata"
//*/
//function getVal () {
//    listValue = $(listSpectra).val() || [];
//    return(listValue);
//};
//
///*
//* Show the multiple charts environment
//*/
//function nmrMultiple () {
//    var Rarray;                                 // data to remove of the chart
//    $(renderChartM).empty();
//    if ( $(listSpectra) != null ) {
//        $(listSpectra).show();                   // show list of spectra
//    }
//    listValue = getVal();                       // get value of selected spectra
//    nmrChart(listValue);
//};

/*
* Load structure of chart for multiple spectra
*
* value {array} name, sample number and pdata number of the selected spectrum
*/
function nmrChart (listSpectra) {
    chart = st.chart
        .nmr()                                  // chart type
        .legend(true)                           // spectra name and title
        .xlabel("ppm")
        .labels(true)                           // show intensity value
        .margins([20, 200, 60, 20]);            // top-right-bottom-left
    chart.render(renderChartM);                   // render chart to id "stgraph"
    Rarray = loadChart(0, listSpectra);
};


/*
* Function describing structure of chart
*
* value {array} name, sample number and pdata number of the selected spectrum 
*/
function nmrSingle (value, idDiv, idCpd, spectrumTitle) {
//    if ( $(listSpectra) != null ) {
//        $(listSpectra).hide();                  // Hide list of multiple spectra    
//    }
	var renderChartTmp = renderChartS + "" + idDiv + "" + idCpd;
    $(renderChartTmp).empty();
    value = value.split(",")[0];
    chart = st.chart
        .nmr()                                  // chart type
        .legend(true)                           // spectra name and title
        .xlabel("ppm")
        .labels(true)                           // show intensity value
        .margins([20, 200, 60, 20]);            // top-right-bottom-left
    chart.render(renderChartTmp);                 // render chart to id "stgraph"
    // 1 refere to single type and value is the spectrum id
    loadChart(1, value, null, spectrumTitle);
};

/*
* Sends a request to read raw data & loads result
*
* x {number} type of case
* id {list} name of spectra to load
* y {number} for multiple spectra case, 0 initial load, 1 existing data
* In multiple spectra case @returns spectra loaded
*/
function loadChart(x, info, y, spectrumTitle) {
    y = y || 0;                                 // default value of y
    switch (x) {
//        case 0:                                 // NMR Multiple
//            if (y == 1) {
//                info = $(info).val() || [];
//                Rarray.remove();
//            };
//            var array = st.data.array()                 // data type (array)
//                .xlimits(["xMin", "xMax"])              // json reference
//                .ylimits(["yMin", "yMax"])              // json reference
//                .y("data")                              // one dimensional array
//                .title("id");
//            chart.load(array);                          // load structure
//            $.each(info, function(index, value) {       //each selected spectra
//                id = value.split(",")[0] || value;
//                sample = value.split(",")[1] || 1;
//                pdata = value.split(",")[2] || 1;
//                POST = {
//                    "type": "multiple",
//                    "id": id,
//                    "sample": sample,
//                    "pdata": pdata
//                };
//                sendData = JSON.stringify(POST);
//                console.log(sendData);
//                st.parser.raw(sendData, urlM, function (raw) {
//                    array.add(JSON.parse(raw));             // add data to chart
//                });
//            });
//            Rarray = array;
//            break;
        case 1:                                 // NMR single
            var array = st.data.array()         // data type (array)
                .xlimits(["xMin", "xMax"])
                .ylimits(["yMin", "yMax"])
                .y("data")                      // one dimensional array
                .title("id");
            chart.load(array);
            id = info.split(",")[0];            // separates values
            sample = info.split(",")[1] || -1;
            pdata = info.split(",")[2] || 1;
            POST = {
                "type": "single",
                "id": id,
                "sample": sample,
                "pdata": pdata
            };
            sendData = JSON.stringify(POST);
            st.parser.raw(sendData, urlS, function (raw) {
            	console.log ("data fetched!")
            	raw.id = spectrumTitle;
                array.add((raw));             // add data to chart
            });
            break;
    };
    if (typeof Rarray !== "undefined") {
        // for multiple chart return data to remove for the next step
        return(Rarray);
    };
};
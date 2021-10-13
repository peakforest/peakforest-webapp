// demonstration of SpeckTackle charts
var chart;

function ms (x) {                          // MS stub
    $("#stgraph").empty();                 // clear DOM child elements
    $("#adddata").removeAttr("disabled")   // enable "Add Data" button
        .attr("onclick","load(" + x + ")");// point to data loader
        
    chart = st.chart                    // create a new MS chart
        .ms()                           // chart type
        .legend(true)                   // options
        .xlabel("m/z")
        .ylabel("Abundance")
        .labels(true)
        .margins([80, 80, 80, 120]);
    chart.render("#stgraph");           // render chart to id "stgraph"
};

function nmr (x) {                       // NMR stub
    $("#stgraph").empty();
    $("#adddata").removeAttr("disabled")
        .attr("onclick","load(" + x + ")");
        
    chart = st.chart
        .nmr()
        .legend(true)
        .title("NMR")
        .xlabel("ppm")
        .labels(true)
        .margins([80, 80, 80, 80]);
    chart.render("#stgraph");
};

function nmr2d () {                     // NMR 2D stub
    $("#stgraph").empty();
    $("#adddata").removeAttr("disabled")
        .attr("onclick","load(2)");
    chart = st.chart
        .nmr2d()
        .xlabel("Chemical Shift (ppm)")
        .ylabel("Chemical Shift (ppm)")
        .margins([80, 120, 80, 80]);
    chart.render("#stgraph");
};

function series () {                    // Chromatogram stub
    $("#stgraph").empty();
    $("#adddata").removeAttr("disabled")
        .attr("onclick","load(3)");
        
    chart = st.chart
        .series()
        .legend(true)
        .labels(true)
        .xlabel("Time [s]")
        .ylabel("Abundance")
        .title("Chromatogram")
        .margins([80, 80, 80, 120]);
    chart.render("#stgraph");
};

function irjdx () {                     // IR (JDX) stub
    $("#stgraph").empty();
    $("#adddata").removeAttr("disabled")
        .attr("onclick","load(4)");
        
    chart = st.chart
        .ir()
        .legend(true)
        .xlabel("1/cm")
        .ylabel("Transmittance")
        .labels(true)
        .title("Infrared Spectrum")
        .margins([80, 120, 80, 120]);
    chart.render("#stgraph");
};

function uvvisjdx () {                 // UV/VIS (JDX) stub
    $("#stgraph").empty();
    $("#adddata").removeAttr("disabled")
        .attr("onclick","load(5)");
        
    chart = st.chart
        .series()
        .legend(true)
        .xreverse(true)
        .xlabel("Wavelength [nm]")
        .ylabel("Absorbance")
        .title("UV/VIS Spectrum")
        .margins([80, 120, 80, 120]);
    chart.render("#stgraph");
};

function load (x) {                        // load chart data
    switch (x) {
        case 0:                            // MS
            var set = st.data.set()        // data type (set)
                .ylimits([0, 1100])        // y-axis limits
                .x("peaks.mz")             // x-accessor
                .y("peaks.intensity")      // y-accessor
                .title("spectrumId");      // id-accessor
                
            // annotation structure
            set.annotationColumn(st.annotation.ANNOTATION, "Ticks");
            set.annotationColumn(st.annotation.TOOLTIP, "Origin");
            set.annotationColumn(st.annotation.TOOLTIP_MOL, "Ion");
            set.annotationColumn(st.annotation.TOOLTIP_MOL, "Frag");
            
            chart.load(set);               // bind the data set
            set.add([                      // input array
                "resources/data1.json",
                "resources/data2.json",
                "resources/data3.json"
            ], [                           // input annotation array
                "resources/data1_anno.json",
                "",
                ""
            ]);
            
            break;
        case 1:                             // NMR
            var array = st.data.array()     // data type (array)
                .xlimits(["xMin", "xMax"])
                .ylimits(["yMin", "yMax"])
                .y("data")                  // one dimensional array
                //.title("id");
            chart.load(array);   
            array.add([
                "resources/nmr1.json",
                "resources/nmr2.json"
                //"resources/nmr3.json"
                //"resources/nmr4.json"
            ]);
            break;  
        case 2:                             // NMR 2D
            var set = st.data.set()
                .x("data.x")
                .y("data.y");
            chart.load(set);
            set.add("resources/nmr2d.json");
            break;
        case 3:                             // Chromatogram
            var set = st.data.set()
                .x("peaks.mz")
                .y("peaks.intensity")
                .title("spectrumId");
            chart.load(set);
            set.add([
                "resources/data1.json",
                "resources/data2.json",
                "resources/data3.json"
            ]);
            break;
        case 4:                             // IR (JDX)
            var array = st.data.array()
                .xlimits(["FIRSTX", "LASTX"])
                .ylimits(["MINY", "MAXY"])
                .y("XYDATA")
                .title("TITLE");
            
            // annotation structure
            array.annotationColumn(st.annotation.ANNOTATION, "Ticks");
            array.annotationColumn(st.annotation.TOOLTIP, "Comment");
            
            chart.load(array);
            st.parser.jdx("resources/ir.jdx", function (jdx) {
                array.add(
                    jdx, 
                    [[
                        ["a-series", 294, "*", "See Reference"],
                        ["a-series", 687, "C=O", "See Reference"],
                        ["a-series", 1284, "O-H stretch?", "See Reference"]
                    ]]);
            });
            break;
        case 5:                             // UV/VIS (JDX)
            var array = st.data.array()
                .xlimits(["LASTX", "FIRSTX"])
                .ylimits(["MAXY", "MINY"])
                .y("XYDATA")
                .title("TITLE");
            chart.load(array);
            st.parser.jdx("resources/uvvis.jdx", function (jdx) {
                array.add(jdx);
            });
            break;
        case 6:                            // MS
            var set = st.data.set()        
                .ylimits([0, 1000])        
                .x("peaks.mz")             
                .y("peaks.intensity")      
                .title("spectrumId");      
                
            chart.load(set);               
            set.add([                      
                "resources/single_point_1.json"
            ]);
            break;
        case 7:                             // NMR
            var array = st.data.array()
                .xlimits(["xMin", "xMax"])
                .y("data")
                .title("id");
            chart.load(array);   
            array.add([
                "resources/single_point_2.json"
            ]);
            break;
        case 8:                             // difference chart
            var set = st.data.set() 
                .x("data.x")             
                .y("data.y")      
                .title("id");      
                
            chart.load(set);               
            set.add([                      
                "resources/difference.json"
            ]);
            break;
        case 9:                             // spectral match
            var set = st.data.set() 
                .x("peaks.mz")             
                .y("peaks.intensity")      
                .title("spectrumId");      
                
            chart.load(set);               
            set.add([                      
                "resources/data3.json",
                "resources/data3_inv.json"
            ]);
            break;
        case 10:                            // PRIDE
            var set = st.data.set() 
                .xlimits(["mzRangeStart", "mzRangeStop"])
                .x("mzArray")             
                .y("intenArray")      
                .title("spectrumId");      
            
            // annotation structure
            set.annotationColumn(st.annotation.ANNOTATION, "Series");
            
            chart.load(set);               
            set.add([                      
                "resources/pride.json"
            ], [
                "resources/pride_anno.json"
            ]);
            break;
    };
    $("#adddata").attr("disabled","disabled");
};

function dynamicms () {                     // dynamic MS stub
    ms();
    $("#adddata").attr("disabled","disabled");
    var counter = 0;
    var data = [
        "resources/data1.json",
        "resources/data2.json",
        "resources/data3.json"
    ]
    var set = st.data.set()
        .ylimits([0, 1000])
        .x("peaks.mz")
        .y("peaks.intensity")
        .title("spectrumId");
    chart.load(set);
    setTimeout(function iter() {
        if (counter === 6) {
            $("#dynamicload").html('');
            return;
        }
        if (counter < 3) {
            $("#dynamicload").html("Loading: " + data[counter]);
            set.add(data[counter]);
        } else {
            $("#dynamicload").html("Removing: " + data[counter - 3]);
            set.remove(0);
        }
        counter += 1;
        setTimeout(iter, 1000);
    }, 1000);
};

function dynamicnmr () {            // dynamic NMR stub
    nmr();
    $("#adddata").attr("disabled","disabled");
    var counter = 0;
    var data = [
        "resources/nmr1.json",
        "resources/nmr2.json",
        "resources/nmr3.json"
    ];
    var array = st.data.array()     // data type (array)
        .xlimits(["xMin", "xMax"])
        .ylimits(["yMin", "yMax"])
        .y("data")                  // array is one dimensional
        .title("id");
    chart.load(array);
    setTimeout(function iter() {
        if (counter === 6) {
            $("#dynamicload").html('');
            return;
        }
        if (counter < 3) {
            $("#dynamicload").html("Loading: " + data[counter]);
            array.add(data[counter]);
        } else {
            $("#dynamicload").html("Removing: " + data[counter - 2]);
            array.remove(0);
        }
        counter += 1;
        setTimeout(iter, 1000);
    }, 1000);
};

function multiplecharts () {        // multiple charts stub
    $("#stgraph").css("display", "none");
    $("#stgraphm1").empty();
    $("#stgraphm2").empty();
    $("#stgraphm3").empty();
    var chart1 = st.chart
        .ms()
        .legend(true)
        .xlabel("m/z")
        .ylabel("Abundance")
        .title("Mass Spectrum")
        .margins([80, 80, 80, 120]);
    var chart2 = st.chart
        .series()
        .legend(true)
        .xlabel("Time [s]")
        .ylabel("Abundance")
        .title("Chromatogram")
        .margins([80, 80, 80, 120]);
    var chart3 = st.chart
        .nmr()
        .legend(true)
        .title("NMR")
        .xlabel("ppm")
        .margins([80, 80, 80, 80]);
    chart1.render("#stgraphm1");
    chart2.render("#stgraphm2");
    chart3.render("#stgraphm3");
    var set1 = st.data.set()
        .ylimits([0, 1000])
        .x("peaks.mz")
        .y("peaks.intensity")
        .title("spectrumId");
    var set2 = st.data.set()
        .ylimits([0, 1000])
        .x("peaks.mz")
        .y("peaks.intensity")
        .title("spectrumId");
    var set3 = st.data.set()
        .ylimits([0, 1000])
        .x("peaks.mz")
        .y("peaks.intensity")
        .title("spectrumId");
    chart1.load(set1);
    chart2.load(set2);
    chart3.load(set3);
    var data = [
        "resources/data1.json",
        "resources/data2.json",
        "resources/data3.json"
    ];
    set1.add(data);
    set2.add(data);
    set3.add(data);
};
import "parser";

/**
 * Incomplete rudimentary JCAMP-DX parser for PAC compressed files and 
 * arrays of type ##XYDATA= (X++(Y..Y)).
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @deprecated
 * @param {string} url A url to the JCAMP-DX file
 * @param {function} callback A callback function
 */
st.parser.jdx = function (url, callback) {
    // d3 AJAX request to resolve the URL
    d3.text(url, function (jdx) {
        // essential key definitions
        var LABEL = '##',
            END = 'END',
            XYDATA = 'XYDATA',
            YTABLE = '(X++(Y..Y))',
            //XFACTOR = 'XFACTOR',
            YFACTOR = 'YFACTOR',
            FIRSTX = 'FIRSTX',
            LASTX = 'LASTX';
            //NPOINTS = 'NPOINTS';
        
        // the data store
        var objs = [];
        // tmp helper objects
        var obj = {},
            data = false,
            points = [];
        // tmp helper objects
        var pair,
            key,
            pkey,
            value;
    
        // split input text into separate lines
        var lines = jdx.split(/\r\n|\r|\n/g);
        // iterate over all lines
        for (var i in lines) {
            var line = lines[i];
            if (line.indexOf(LABEL) === 0) {
                pair = line.split(/=\s(.*)/); // split key-value pair
                if (pair.length < 2) {        // sanity check
                    continue;
                }
                key = pair[0].slice(2);                     // parse key
                value = pair[1].split(/\$\$(.*)/)[0].trim();// parse value
                if (key === XYDATA && value === YTABLE) {
                    data = true; // boolean flag whether this is a data table
                } else if (key === END) {
                    if (data) {  // clean up after a data table has been parsed
                        if (parseFloat(obj[FIRSTX]) > 
                            parseFloat(obj[LASTX])) {
                            points.reverse();
                        }
                        obj[pkey] = points;
                        objs.push(obj);
                        // reset
                        obj = {};
                        data = false;
                        points = [];
                    }
                    data = false;
                } else {
                    obj[key] = value;
                }
                pkey = key;
            } else if (data) {
                //var deltax = (obj[LASTX] - obj[FIRSTX]) / (obj[NPOINTS] - 1);
                var entries = line.match(/(\+|-)*\d+\.*\d*/g);
                //var x = obj[XFACTOR] * entries[0];
                for (var j = 1; j < entries.length; j++) {
                    //x += (j - 1) * deltax;
                    var y = obj[YFACTOR] * entries[j];
                    points.push(y);
                }
            }
        }
        callback(objs);
    });
};
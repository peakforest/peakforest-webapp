import "../util/domain";
import "data";

/**
 * Model of a one dimensional data array with y values.
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @extends st.data.data
 * @returns {object} a data structure of type 'set'
 */
st.data.array = function () {
    // base data structure to be extended
    var array = data();
    
    /**
     * Gets the unbinned data array for the current chart.
     *
     * @param {number} width The chart width
     * @param {function} xscale The d3 x axis scale
     * @returns {object[]} the unbinned data array
     */
    array.get = function (width, xscale) {
        // global data container for all series
        var rawbinned = [];
        // define domain extrema in x
        var ext = [
            xscale.invert(0),
            xscale.invert(width)
        ];
        // arrange based on x-axis direction
        ext = st.util.domain(xscale, ext);
        // iterate over all series
        for (var i in this.raw.series) {
            // get the current series
            var series = this.raw.series[i];
            // get the number of data points
            var serieslength = series.data.length;
            // calculate the step size in x for the series
            var seriesstep = (series.xlim[1] - series.xlim[0]) / serieslength;
            // get the size array: [domain min, domain max, nbins]
            var tmp = series.size;
            // local data container for binned series
            var binned = [];
            
            // reverse min limit to include unrendered data points if required
            while (series.size[0] > 0) {
                var x = series.size[0] * seriesstep + series.xlim[0];
                if (x < ext[0]) {
                    break;
                }
                series.size[0] -= 1;
            }
            // forward max limit to include unrendered data points if required
            while (series.size[1] < serieslength) {
                var x = series.size[1] * seriesstep + series.xlim[0];
                if (x > ext[1]) {
                    break;
                }
                series.size[1] += 1;
            }
            
            // iterate over all data points
            for (var j = series.size[0]; j < series.size[1]; j++) {
                // calculate the x value for the current index
                var x = j * seriesstep + series.xlim[0];
                // skip irrelevant data points
                if (x < ext[0]) {
                    tmp[0] = j;
                    continue;
                } else if (x > ext[1]) {
                    tmp[1] = j;
                    break;
                }
                
                // get the current y value
                var ys = series.data[j];
                // build the data point
                var dp = {
                    x: x
                };
                dp[series.accs[1]] = ys;
                binned.push(dp);
            }
            // assign the current data size array to its series
            series.size = tmp;
            // add the unbinned array to the global container
            rawbinned.push(binned);
        }
        return rawbinned;
    };
    
    /**
     * Gets the binned data array for the current chart.
     *
     * @param {number} width The chart width
     * @param {function} xscale The d3 x axis scale
     * @param {boolean} invert Whether to bin using min instead of max
     * @returns {object[]} the binned data array
     */
    array.bin = function (width, xscale, invert) {
        // global data container for all series
        var rawbinned = [];
        // define domain extrema in x
        var ext = [
            xscale.invert(0),
            xscale.invert(width)
        ];
        // arrange based on x-axis direction
        ext = st.util.domain(xscale, ext);
        // define bin width in px
        var binWidth = 1;
        
        // find global max number of bins
        var gnbins = 0;
        // iterate over all series
        for (var i in this.raw.series) {
            // get the series
            var tmp = this.raw.series[i].size;
            // if (tmp[2] === 0) { // whether nbins is already initialised
                tmp[2] = Math.ceil(width / binWidth);
            // }
            // check if tmp nbins is greather than the current global nbins
            if (gnbins < tmp[2]) {
                gnbins = tmp[2];
            }
        }
        
        // calculate the bin step size
        var step = Math.abs(ext[1] - ext[0]) / (gnbins - 1);
        
        // iterate over all series
        for (var i in this.raw.series) {
            // get the series
            var series = this.raw.series[i];
            // get the number of data points in this series
            var serieslength = series.data.length;
            // calculate the step size in x for the series
            var seriesstep = (series.xlim[1] - series.xlim[0]) / serieslength;
            // get the size array: [domain min, domain max, nbins]
            var tmp = series.size;
            // local data container for binned series
            var binned = [];
            // counter to shorten the data array if applicable
            var cor = 0;
            
            // reverse min limit to include unrendered data points if required
            while (series.size[0] > 0) {
                var x = series.size[0] * seriesstep + series.xlim[0];
                if (x < ext[0]) {
                    break;
                }
                series.size[0] -= 1;
            }
            // forward max limit to include unrendered data points if required
            while (series.size[1] < serieslength) {
                var x = series.size[1] * seriesstep + series.xlim[0];
                if (x > ext[1]) {
                    break;
                }
                series.size[1] += 1;
            }
            
            // iterate over all data points
            for (var j = series.size[0]; j < series.size[1]; j++) {
                // calculate the x value for the current index
                var x = j * seriesstep + series.xlim[0];
                // skip irrelevant data points
                if (x < ext[0]) {
                    tmp[0] = j;
                    continue;
                } else if (x > ext[1]) {
                    tmp[1] = j;
                    break;
                }
                
                // get the target bin
                var bin = Math.floor((x - ext[0]) / step);
                // get the current data point in the bin
                var dpb = binned[bin - cor];
                // get the data point to be added to the bin
                var ys = series.data[j];
                // if the bin is already populated with a data point...
                if (dpb) {
                    // a) ...bin by minimum
                    if (invert) {
                        if (dpb[series.accs[1]] < ys) {
                            binned[bin - cor] = dpb;
                        } else {
                            var dp = { 
                                x: x
                            };
                            dp[series.accs[1]] = ys;
                            var tmpdp = binned[bin - cor];
                            if (tmpdp.annos) {
                                dp.annos = binned[bin - cor].annos;
                            }
                            binned[bin - cor] = dp;
                        }
                    // b) ...bin by maximum
                    } else {
                        if (Math.abs(dpb[series.accs[1]]) > Math.abs(ys)) {
                            binned[bin - cor] = dpb;
                        } else {
                            var dp = { 
                                x: x
                            };
                            dp[series.accs[1]] = ys;
                            var tmpdp = binned[bin - cor];
                            if (tmpdp.annos) {
                                dp.annos = tmpdp.annos;
                            }
                            binned[bin - cor] = dp;
                        }
                    }
                // ...add the current data point to the unpopulated bin
                } else {
                    cor = bin - binned.length;
                    binned[bin - cor] = { 
                            x: x
                    };
                    binned[bin - cor][series.accs[1]] = ys;
                }
                
                // assign annotations
                if (series.annos && Object.keys(series.annos).length) {
                    if (j in series.annos && !binned[bin - cor].annos) {
                        var refpoint = binned[bin - cor];
                        var ref = series.annos[j];
                        // get the annotation group
                        var refgroup = ref[0];
                        if (!(refgroup in this.raw.annoGroups)) {
                            this.raw.annoGroups[refgroup] = 0;
                        }
                        // add annotation hash to the data point
                        if (!refpoint.annos) {
                            refpoint.annos = {};
                        }
                        // add group to the annotation hash
                        var dpannos = refpoint.annos;
                        if (!(refgroup in dpannos)) {
                            dpannos[refgroup] = {};
                        }
                        var annosgroup = dpannos[refgroup];
                        
                        // iterate over each element of the annotation record
                        for (var k = 0; k < ref.length; k++) {
                            var reftype = this.opts.annoTypes[k];
                            var val = ref[k + 2];
                            if (reftype === st.annotation.ANNOTATION) {
                                annosgroup.annotation = val;
                            } else if (reftype === st.annotation.TOOLTIP) {
                                if (!annosgroup.tooltip) {
                                    annosgroup.tooltip = {};
                                }
                                annosgroup.tooltip[this.opts.annoTexts[k]] = val;
                            } else if (reftype === st.annotation.TOOLTIP_MOL) {
                                if (val !== '') {
                                    if (!annosgroup.tooltipmol) {
                                        annosgroup.tooltipmol = {};
                                    }
                                    annosgroup.tooltipmol[
                                        this.opts.annoTexts[k]] = val;
                                }
                            }
                        }
                        binned[bin - cor] = refpoint;
                    }
                }
            }
            // correct the local nbins value if the array could be shortened
            if (cor > 0) {
                tmp[2] = binned.length;
            }
            // assign the current data size array to its series
            series.size = tmp;
            // add the binned array to the global container
            rawbinned.push(binned);
        }
        return rawbinned;
    };
    
    /**
     * Function parsing the input data (and annotations).
     *
     * @param {string[]} json The raw data series
     * @param {string[]} json2 The raw annotation data
     * @param {object} set The target data set
     */
    array.seriesfetch = function (json, json2) {
        var id = st.util.hashcode((new Date().getTime() * Math.random()) + '');
        id = 'st' + id;                       // model id
        var title = json[this.opts.title];   // model title
        var xlim = [];                  // model x limits
        var ylim = [];                  // model y limits
        var size = [];                  // model size: min, max, nBins
        var xacc = 'x';                 // model x accessor
        var yacc = this.opts.y;        // model y accessor

        if (!title || title.length === 0) {
            title = id;
        }
        
        if (id in this.raw.ids) {
            console.log("SpeckTackle: Non unique identifier: " + id);
            return;
        }
        
        var data = (yacc === '') ? json : json[yacc]; // resolve accessor stub
        // resolve limits
        xlim = fetch_limits(data, json, this.opts.xlimits, xacc);
        ylim = fetch_limits(data, json, this.opts.ylimits);
        size = [0, data.length, 0];
        
        // assign annotations
        var annos = {};
        if (json2) {
            var annolength = this.opts.annoTypes.length;
            // iterate over each annotation record
            for (var i in json2) {
                // ignore annotation record if of invalid length
                if (json2[i].length - 2 !== annolength) {
                    continue;
                }
                // get the annotation reference index
                var refpos = json2[i][1];
                if (refpos < size[1]) {
                    annos[refpos] = json2[i];
                }
            }
        }
        
        // replace global limits if required
        if (xlim[0] < this.raw.gxlim[0]) {
            this.raw.gxlim[0] = xlim[0];
        }
        if (ylim[0] < this.raw.gylim[0]) {
            this.raw.gylim[0] = ylim[0];
        }
        if (xlim[1] > this.raw.gxlim[1]) {
            this.raw.gxlim[1] = xlim[1];
        }
        if (ylim[1] > this.raw.gylim[1]) {
            this.raw.gylim[1] = ylim[1];
        }

        this.raw.ids[id] = true;    

        // add series as raw entry
        this.raw.series.push({
            id: id,        
            title: title,
            xlim: xlim,
            ylim: ylim,
            accs: [xacc, yacc],
            size: size,
            annos: annos,
            data: data,
            x: function (i) {
                return i; // return i by default
            },
            y: function (i) {
                return this.data[i][this.accs[1]];
            }
        });
    };
    
    return array;
};
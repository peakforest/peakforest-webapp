import "../util/compare";
import "../util/domain";
import "../util/hashcode";
import "data";

/**
 * Model of a two dimensional data set with x and y values.
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @extends st.data.data
 * @returns {object} a data structure of type 'set'
 */
st.data.set = function () {
    // base data structure to be extended
    var set = data();
    
    /**
     * Sets the x data accessor.
     *
     * @param {string} x A x data accessor
     * @returns {object} the data object
     */
    set.x = function (x) {
        if (x && typeof x === 'string') {
            this.opts.x = x;
        } else {
            console.log('Invalid y accessor option.');
        }
        return this;
    };
    
    /**
     * Gets the unbinned data array for the current chart.
     *
     * @param {number} width The chart width
     * @param {function} xscale The d3 x axis scale
     * @returns {object[]} the unbinned data array
     */
    set.get = function (width, xscale) {
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
            var series = this.raw.series[i];
            var binned = [];
            // iterate over the current series...
            for (var j in series.data) {
                var x = series.x(j);
                //...and select data points within the domain extrema
                if (x >= ext[0] && x <= ext[1]) {
                    binned.push(series.data[j]);
                }
            }
            // add the filtered series to the global data container
            rawbinned.push(binned);
        }
        // return the global data container
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
    set.bin = function (width, xscale, invert) {
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
        var binWidth = 1
        
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
            // get the size array: [domain min, domain max, nbins]
            var tmp = series.size;
            // local data container for binned series
            var binned = [];
            // counter to shorten the data array if applicable
            var cor = 0;
            
            // reverse min limit to include unrendered data points if required
            while (tmp[0] > 0) {
                var x = series.x(tmp[0]);
                if (x < ext[0]) {
                    break;
                }
                tmp[0] -= 1;
            }
            // forward max limit to include unrendered data points if required
            while (tmp[1] < serieslength) {
                var x = series.x(tmp[1]);
                if (x > ext[1]) {
                    break;
                }
                tmp[1] += 1;
            }
            
            // iterate over all data points within the min/max domain limits
            for (var j = tmp[0]; j < tmp[1]; j++) {
                var x = series.x(j);
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
                var dps = series.data[j];
                // if the bin is already populated with a data point...
                if (dpb) {
                    // a) ...bin by minimum
                    if (invert) {
                        if (dpb[series.accs[1]] < dps[series.accs[1]]) {
                            binned[bin - cor] = dpb;
                        } else {
                            if (dpb.annos && !dps.annos) {
                                dps.annos = dpb.annos;
                            }
                            binned[bin - cor] = dps;
                        }   
                    // b) ...bin by maximum
                    } else {
                        if (Math.abs(dpb[series.accs[1]]) > 
                            Math.abs(dps[series.accs[1]])) {
                            binned[bin - cor] = dpb;
                        } else {
                            if (dpb.annos && !dps.annos) {
                                dps.annos = dpb.annos;
                            }
                            binned[bin - cor] = dps;
                        }
                    }
                // ...add the current data point to the unpopulated bin
                } else {
                    cor = bin - binned.length;
                    binned[bin - cor] = dps;
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
    set.seriesfetch = function (json, json2) {
        var id = st.util.hashcode((new Date().getTime() * Math.random()) + '');
        id = 'st' + id;                     // series id
        var title = json[set.opts.title];   // series title
        var xlim = [];                  // series x limits
        var ylim = [];                  // series y limits
        var size = [];                  // series size: min, max, nBins
        var xacc = this.opts.x;          // series x accessor
        var yacc = this.opts.y;          // series y accessor
        
        if (!title || title.length === 0) {
            title = id;
        }
        
        if (id in this.raw.ids) {
            console.log("SpeckTackle: Non unique identifier: " + id);
            return;
        }
        
        var acc = ''; // resolve accessor stub
        if (xacc.lastIndexOf('.') !== -1) {
            acc = xacc.substr(0, xacc.lastIndexOf('.'))
            xacc = xacc.substr(xacc.lastIndexOf('.') + 1)
            yacc = yacc.substr(yacc.lastIndexOf('.') + 1)
        }

        // coerce two arrays into an array of objects 
        var data = (acc === '') ? json : json[acc];
        if (!(data instanceof Array)) {
            var grouped = [];
            for (var i in data[xacc]) {
                var ob = {};
                ob[xacc] = data[xacc][i];
                ob[yacc] = data[yacc][i];
                grouped.push(ob);
            }
            data = grouped;
        }
        
        
        // resolve limits
        xlim = fetch_limits(data, json, this.opts.xlimits, xacc);
        ylim = fetch_limits(data, json, this.opts.ylimits, yacc);
        size = [0, data.length, 0];
        
        // assign annotations
        if (json2) {
            // sort the data set
            data.sort(st.util.compare(xacc));
            // define bisector for value lookup
            var bisector = d3.bisector(function (d) {
                return d[xacc];
            }).left;
            var annolength = this.opts.annoTypes.length;
            // iterate over each annotation record
            for (var i in json2) {
                // ignore annotation record if of invalid length
                if (json2[i].length - 2 !== annolength) {
                    continue;
                }
                // get the annotation group
                var refgroup = json2[i][0];
                if (!(refgroup in this.raw.annoGroups)) {
                    this.raw.annoGroups[refgroup] = 0;
                }
                // get the annotation reference value
                var ref = json2[i][1];
                // find the data point in the data series
                var refpos = bisector(data, ref);
                if (refpos !== -1 && ref === data[refpos][xacc]) {
                    var refpoint = data[refpos];
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
                    for (var j = 0; j < annolength; j++) {
                        var reftype = this.opts.annoTypes[j];
                        var val = json2[i][j + 2];
                        if (reftype === st.annotation.ANNOTATION) {
                            annosgroup.annotation = val;
                        } else if (reftype === st.annotation.TOOLTIP) {
                            if (!annosgroup.tooltip) {
                                annosgroup.tooltip = {};
                            }
                            annosgroup.tooltip[this.opts.annoTexts[j]] = val;
                        } else if (reftype === st.annotation.TOOLTIP_MOL) {
                            if (val !== '') {
                                if (!annosgroup.tooltipmol) {
                                    annosgroup.tooltipmol = {};
                                }
                                annosgroup.tooltipmol[
                                    this.opts.annoTexts[j]] = val;
                            }
                        }
                    }
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
            data: data,
            x: function (i) { // x accessor function
                return this.data[i][this.accs[0]];
            },
            y: function (i) {   // y accessor function
                return this.data[i][this.accs[1]];
            }
        });
    };
    
    return set;
};
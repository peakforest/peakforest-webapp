/**
 * Default data object. Custom data objects should extend this data stub. 
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @returns {object} the default data object
 */
st.data = {};

/**
 * Builds the default data object that serves as base for custom data objects.
 * 
 * @constructor
 * @returns {object} the default data object
 */
function data () {
    return {
        opts: { // data options
            title: '',
            src: [],    // JSON URLs or JSON data
            anno: [],   // JSON URLs or JSON data
            x: 'x',     // x accessor
            y: 'y',     // y accessor
            xlimits: [],// x axis limits: min, max
            ylimits: [],// y axis limits: min, max
            annoTypes: [],  // annotation types (see st.annotation)
            annoTexts: []   // annotation titles (string)
        },
        
        raw: {          // global variables summarising the data set
            gxlim: [ Number.MAX_VALUE, Number.MIN_VALUE], // global x limits
            gylim: [ Number.MAX_VALUE, Number.MIN_VALUE], // global y limits
            ids: {},    // identifier hash set of all series in the data set
            series: [], // all series in the data set (array of series)
            minima: 0,      // whether minimum binned is to be applied 
            annoGroups: {}  // annotation groups (string)
        },
        
        /**
         * Sets the title accessor.
         *
         * @param {string} x A title accessor
         * @returns {object} the data object
         */
        title: function (x) {
            if (x && typeof x === 'string') {
                this.opts.title = x;
            } else {
                console.log('Invalid title option.');
            }
            return this;
        },
        
        /**
         * Sets the y accessor.
         *
         * @param {string} y A y data accessor
         * @returns {object} the data object
         */
        y: function (y) {
            if (y && typeof y === 'string') {
                this.opts.y = y;
            } else {
                console.log('Invalid y accessor option.');
            }
            return this;
        },
        
        /**
         * Sets the x domain limits.
         *
         * @param {number[]} limits A two element array of min and max limits
         * @returns {object} the data object
         */
        xlimits: function (x) {
            if (x && x instanceof Array) {
                this.opts.xlimits = x;
            } else {
                console.log('Invalid x domain limits.');
            }
            return this;
        },
        
        /**
         * Sets the y domain limits.
         *
         * @param {number[]} limits A two element array of min and max limits
         * @returns the data object
         */
        ylimits: function (x) {
            if (x && x instanceof Array) {
                this.opts.ylimits = x;
            } else {
                console.log('Invalid y domain limits.');
            }
            return this;
        },
            
        /**
         * Sets the data source option.
         *
         * @param {string|string[]} datarefs An URL (array) or JSON data (array)
         * @param {string|string[]} annorefs An URL (array) or JSON data (array)
         * @returns {object} the data object
         */
        add: function (datarefs, annorefs) {
            if (datarefs instanceof Array) {
                if (!annorefs || annorefs instanceof Array) {
                    this.opts.src.push.apply(this.opts.src, datarefs);
                    this.opts.anno.push.apply(this.opts.anno, annorefs);
                } else {
                    console.log('Raw data and annotation data must be ' +
                        'of the same type.');
                }
            } else {
                this.opts.src.push(datarefs);
                this.opts.anno.push(annorefs);
            }
        },
        
        /**
         * Defines elements of the annotation data structure.
         *
         * @param {string} type Type of st.annotation
         * @param {string} text Title of the annotation
         */
        annotationColumn: function (type, text) {
            if (type.toUpperCase() in st.annotation) {
                this.opts.annoTypes.push(type);
                this.opts.annoTexts.push(text);
            } else {
                console.log('Unknown annotation type: ' + type);
            }
        },

        /**
         * Removes a data series by its identifier or index.
         *
         * @param {string[]|number[]} x The indices or identifiers to remove
         * @returns {string[]} an array of removed identifiers
         */
        remove: function (x) {
            // array to collect identifiers of removed series
            var ids = [];
                   
            // if no argument is given, clear the chart
            if (!x && x !== 0) {
                // collect all identifiers
                for (var i in this.raw.ids) {
                    ids.push(i);
                }
                
                // reset the identifier set and the global 'raw' container
                this.raw.ids = {};
                this.raw.series = [];
                this.raw.gxlim = [ Number.MAX_VALUE, Number.MIN_VALUE];
                this.raw.gylim = [ Number.MAX_VALUE, Number.MIN_VALUE];
                
                // return the collected identifiers
                return ids;
            }
            
            // turn a single identifier into an array of identifiers
            if (!(x instanceof Array)) {
                x = [ x ];
            } else {
                x.sort();
            }
            
            // iterate over the array of identifiers to remove
            for (i in x) {
                var xid = x[i];
                // check whether the identifier is a string...
                if (isNaN(xid)) {
                    // find the identifier in the data set and delete it
                    for (var i in this.raw.series) {
                        if (this.raw.series[i].id === xid) {
                            this.raw.series.splice(i, 1);
                            ids.push(this.raw.ids[xid]);
                            delete this.raw.ids[xid];
                            break;
                        }
                    }
                // ...or a number, in which case its an index
                } else {
                    // sanity check for the index (track removed entries)
                    if (xid - i < this.raw.series.length) {
                        var spliced = this.raw.series.splice(xid - i, 1);
                        ids.push(spliced[0].id);
                        delete this.raw.ids[spliced[0].id];
                    }
                }
            }
            // reset the global domain limits
            if (this.raw.series.length === 0) {
                this.raw.gxlim = [ Number.MAX_VALUE, Number.MIN_VALUE];
                this.raw.gylim = [ Number.MAX_VALUE, Number.MIN_VALUE];
            }
            
            // return the collected identifiers
            return ids;
        },
        
        /**
         * Gets the id of a data series at a given index.
         *
         * @param {number} index A data series index 
         * @returns {string} the identifier of the data series
         */
        id: function (index) {
            return this.raw.series[index].id;
        },
        
        /**
         * Gets the title of a data series at a given index.
         *
         * @param {number} index A data series index 
         * @returns {string} the title of the data series
         */
        titleat: function (index) {
            return this.raw.series[index].title;
        },
        
        /**
         * Gets the x and y accessors for a data series at a given index.
         *
         * @param {number} index A data series index 
         * @returns the x and y accessors of the data series`
         */
        accs: function (index) {
            return this.raw.series[index].accs;
        },
        
        /**
         * Pushes the source values currently in the source option into 
         * the raw data array and sets the global data options.
         *
         * @param {function} callback A callback function
         */
        push: function (callback) {
            // self-reference for nested functions
            var data = this;
            // array for XHR promises
            var deferreds = [];
            // iterate over the source values
            for (var i in this.opts.src) {
                // check whether source value is a data object
                // the corresponding annotation reference is assumed to be a 
                // data object as well in that case
                if (typeof this.opts.src[i] !== 'string') {
                    this.fetch(this.opts.src[i], this.opts.anno[i]);
                } else { // resolve the URLs and save the promises
                    deferreds.push(this.fetch(
                        this.opts.src[i], this.opts.anno[i]));
                }
            }
            // wait until all promises are fulfilled
            $.when.apply($, deferreds).done(function () {
                if (!data.opts.src.length) {
                    return;
                }
                
                // clear the source buffers
                data.opts.src = [];
                data.opts.anno = [];
                
                // special case: single value data sets:
                // expand X and Y range by 1%
                if (data.raw.gxlim[0] === data.raw.gxlim[1]) {
                    data.raw.gxlim[0] -= data.raw.gxlim[0] / 100.0;
                    data.raw.gxlim[1] += data.raw.gxlim[1] / 100.0;
                }
                if (data.raw.gylim[0] === data.raw.gylim[1]) {
                    data.raw.gylim[0] -= data.raw.gylim[0] / 100.0;
                    data.raw.gylim[1] += data.raw.gylim[1] / 100.0;
                }
                callback();
            });
        },
        
        /**
         * Fetches the data series and adds it as raw entry.
         *
         * @param {string|object} src A data source
         * @param {string|object} anno An annotation source
         */
        fetch: function (src, anno) {
            // self-reference for nested functions
            var set = this;
            // the XHR promise
            var jqxhr = null;
            // 1) input series referenced by a URL
            if (typeof src === 'string') {
                // 1a) input annotations referenced by a URL
                if (typeof anno === 'string' && anno) {
                    jqxhr = $.when(
                        $.get(src),
                        $.get(anno)
                    )
                    .fail(function() {
                        console.log('Fetch failed for: ' + src + '\n' + anno);
                    })
                    .then(function(json, json2) {
                        if (typeof json === 'string') {
                            json = $.parseJSON(json);
                        }
                        // assumption: series and anno structure are identical
                        if (json[0] instanceof Array) {
                            for (var i in json[0]) {
                                set.seriesfetch(json[0][i], json2[0][i]);
                            }
                        } else {
                            set.seriesfetch(json[0], json2[0]);
                        }
                    });
                // 1b) input annotations provided as data array (or missing)
                } else {
                    jqxhr = $.when(
                        $.get(src)
                    )
                    .fail(function() {
                        console.log('Fetch failed for: ' + src);
                    })
                    .then(function(json) {
                        if (typeof json === 'string') {
                            json = $.parseJSON(json);
                        }
                        // assumption: series and anno structure are identical
                        if (json instanceof Array) {
                            if (!anno) {
                                anno = [];
                            }
                            for (var i in json) {
                                set.seriesfetch(json[i], anno[i]);
                            }
                        } else {
                            set.seriesfetch(json, anno);
                        }
                    });
                }
            // 2) input series provided as data array
            } else {
                // 2a) input annotations referenced by a URL
                if (typeof anno === 'string' && anno) {
                    jqxhr = $.when(
                        $.get(anno)
                    )
                    .fail(function() {
                        console.log('Fetch failed for: ' + anno);
                    })
                    .then(function(json) {
                        // assumption: series and anno structure are identical
                        if (src instanceof Array) {
                            if (!anno) {
                                anno = [];
                            }
                            for (var i in src) {
                                set.seriesfetch(src[i], json[i]);
                            }
                        } else {
                            set.seriesfetch(src, json);
                        }
                    });
                } else {
                    // 1b) input annotations provided as data array (or missing)
                    if (src instanceof Array) {
                        for (var i in src) {
                            set.seriesfetch(src[i], anno[i]);
                        }
                    } else {
                        set.seriesfetch(src, anno);
                    }
                }
            }
            return jqxhr;
        },
        
        /**
         * Resets all global options.
         */
        reset: function () {
            for (var i in this.raw.series) {
                var series = this.raw.series[i];
                series.size = [
                    0,
                    series.data.length,
                    0
                ];
            }
        }
    };
}

/**
 * Function resovling axis limits based on whether key values, numeric values,
 * or no input values are provided.
 * 
 * @params {object} series The data array
 * @params {object} json The complete data series
 * @params {number[]} limits The min/max array
 * @params {string} acc The data accessor
 * @returns {number[]} the axis min/max limts
 */
function fetch_limits (series, json, limits, acc) {
    var lim = [];
    // sanity check
    if (limits.length === 2) {
        // both variables are accessors
        if (isNaN(limits[0]) && isNaN(limits[1])) {
            lim = [
                json[limits[0]],
                json[limits[1]]
            ];
        // both variables are constants
        } else if (typeof limits[0] === 'number' 
                && typeof limits[1] === 'number') {
            lim = [
                limits[0],
                limits[1]
            ];
        } else {
            // typically a one dimensional array: search
            if (!acc || acc === '') {
                lim = d3.extent(series);
            // typically a set: search
            } else {
                lim = d3.extent(series, function (d) {
                    return d[acc];
                });
            }   
        }
    // sanity violation: search
    } else {
        if (!acc || acc === '') {
            lim = d3.extent(series);
        } else {
            lim = d3.extent(series, function (d) {
                return d[acc];
            });
        }
    }
    lim[0] = parseFloat(lim[0]);
    lim[1] = parseFloat(lim[1]);
    return lim;
}


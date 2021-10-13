import "../util/domain";
import "../util/mol2svg";
import "../util/spinner";
import "../util/colors";
import "../data/array";
import "../data/set";
import "../data/data";

/**
 * Base chart to be extended by custom charts.
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @returns {object} the base chart
 */
st.chart = {};

/**
 * Builds the base chart object that serves as base for custom charts.
 * 
 * @constructor
 * @returns {object} the base chart
 */
function chart () {
    return {
        opts: { // chart options
            title: '',          // chart title
            xlabel: '',         // chart x-axis label
            ylabel: '',         // chart y-axis label
            xreverse: false,    // whether to reverse the x-axis
            yreverse: false,    // whether to reverse the y-axis
            legend: false,      // whether to display the legend
            labels: false,      // whether to display signal labels
            margins: [80, 80, 80, 120]  // canvas margins: t, r, b, l
        },
        
        // internal data binding: references the data set
        data: null,
        // internal timeout object for async. requests
        timeout: null,
        // internal color chooser
        colors: st.util.colors(),
        // SDfile SVG renderer object set for an output of 250 px by 250 px
        mol2svg: st.util.mol2svg(250, 250),
        
        /**
         * Sets the chart title option.
         *
         * @param {string} title A chart title 
         * @returns {object} the base chart
         */
        title: function (title) {
            if (title && typeof title === 'string') {
                this.opts.title = title;
            } else {
                console.log('Invalid title option.');
            }
            
            return this;
        },
        
        /**
         * Sets the chart x-axis label option.
         *
         * @param {string} xlabel A x-axis label
         * @returns {object} the base chart
         */
        xlabel: function (xlabel) {
            if (xlabel && typeof xlabel === 'string') {
                this.opts.xlabel = xlabel;
            } else {
                console.log('Invalid x-axis label option.');
            }
            return this;
        },
        
        /**
         * Sets the chart y-axis label option.
         *
         * @param {string} ylabel A y-axis label
         * @returns {object} the base chart
         */
        ylabel: function (ylabel) {
            if (ylabel && typeof ylabel === 'string') {
                this.opts.ylabel = ylabel;
            } else {
                console.log('Invalid y-axis label option.');
            }
            return this;
        },
        
        /**
         * Sets whether to reverse the x-axis.
         *
         * @param {boolean} reverse Whether to reverse the x-axis
         * @returns {object} the base chart
         */
        xreverse: function (reverse) {
            if (reverse && typeof reverse === 'boolean') {
                this.opts.xreverse = reverse;
            } else {
                console.log('Invalid x-axis reverse option.');
            }
            return this;
        },
        
        /**
         * Sets whether to reverse the y-axis.
         *
         * @param {boolean} reverse Whether to reverse the y-axis
         * @returns {object} the base chart
         */
        yreverse: function (reverse) {
            if (reverse && typeof reverse === 'boolean') {
                this.opts.yreverse = reverse;
            } else {
                console.log('Invalid y-axis reverse option.');
            }
            return this;
        },
        
        /**
         * Sets whether to display the legend.
         *
         * @param {boolean} display Whether to display the legend
         * @returns {object} the base chart
         */
        legend: function (display) {
            if (display && typeof display === 'boolean') {
                this.opts.legend = display;
            } else {
                console.log('Invalid legend option.');
            }
            return this;
        },
        
        /**
         * Sets whether to display labels.
         *
         * @param {boolean} display Whether to display labels
         * @returns {object} the base chart
         */
        labels: function (display) {
            if (display && typeof display === 'boolean') {
                this.opts.labels = display;
            } else {
                console.log('Invalid labels option.');
            }
            return this;
        },
        
        /**
         * Sets the chart margins.
         *
         * @param {int[]} margs The margins: top, right, bottom, left
         * @returns {object} the base chart
         */
        margins: function (margs) {
            if (margs && margs instanceof Array && margs.length === 4) {
               this.opts.margins = margs;
            } else {
                console.log('Invalid margins array.');
            }
            return this;
        },
        
        /**
         * Renders the base chart to the target div.
         *
         * <div id="stgraph" class="stgraph">
         *
         * |-----------------------------------|
         * |Panel                              |
         * |   |----------------------| Legend |
         * |   |Canvas                |  s1    |
         * |   |        ..            |  s2    |
         * |   |      .    .          |        |
         * |   |     .     .          |        |
         * |   |    .       ..        |        |
         * |   |  ..          ...     |        |
         * |   |----------------------|        |
         * |                                   |
         * |-----------------------------------|
         * 
         * </div>
         *
         * @params {string} x The id of the div
         */
        render: function (x) {
            // reference id of the div
            this.target = x;
            // get margin option...
            var margins = this.opts.margins;
            // ...calculate width and height of the canvas inside the panel
            this.width = $(x).width() - margins[1] - margins[3];
            this.height = $(x).height() - margins[0] - margins[2];

            // sanity check
            if (this.width <= 0) {
                console.log('Invalid chart width: ' + this.width);
                return;
            } else if (this.height <= 0) {
                console.log('Invalid chart height: ' + this.height);
                return;
            }
        
            // self-reference for nested functions
            var chart = this;
            
            // create the panel SVG element and define the base zoom behavior
            this.panel = d3.select(x)
                .append('svg:svg')
                .attr('class', 'st-base')
                .attr('width', this.width + margins[1] + margins[3])
                .attr('height', this.height + margins[0] + margins[2])
                .on('mousedown.zoom', function () { // --- mouse options ---
                    chart.mouseDown(this);
                })
                .on('mousemove.zoom', function () { // --- mouse options ---
                    chart.mouseMove(this);
                })
                .on('mouseup.zoom', function () {   // --- mouse options ---
                    chart.mouseUp();
                })
                .on('mouseout', function() {        // --- mouse options ---
                    chart.mouseOut(this);
                })
                .on('dblclick.zoom', function () {  // --- mouse options ---
                    chart.mouseDbl(this);
                });
                
            // append the chart canvas as group within the chart panel
            this.canvas = this.panel
                .append('svg:g')
                .attr('transform', 'translate(' + 
                    margins[3] + ',' + margins[0] + ')');

            // add the SVG clip path on top of the canvas
            this.canvas.append('svg:clipPath')
                .attr('id', 'clip-' + this.target)
                .append('svg:rect')
                .attr('x', 0)
                .attr('y', 0)
                .attr('width', this.width)
                .attr('height', this.height);

            // add a hidden selection rectangle
            this.selection = this.canvas.append('svg:rect')
                .attr('class', 'st-selection')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .attr('x', 0)
                .attr('y', 0)
                .attr('width', 0)
                .attr('height', 0)
                .style('pointer-events', 'none')
                .attr('display', 'none');

            // scale object with initial d3 x- and y-scale functions
            this.scales = {};
            if (this.opts.xreverse) {   // check whether axis is reversed...
                this.scales.x = d3.scale.linear()
                    .domain([1, 0])      // ...invert the x-domain limits
                    .range([0, this.width])
            } else {
                this.scales.x = d3.scale.linear()
                    .domain([0, 1])
                    .range([0, this.width])
            }
            if (this.opts.yreverse) {   // check whether axis is reversed...
                this.scales.y = d3.scale.linear()
                    .domain([1, 0])      // ...invert the y-domain limits
                    .range([this.height, 0])
            } else {
                this.scales.y = d3.scale.linear()
                    .domain([0, 1])
                    .range([this.height, 0])
            }
            
            // check if the tooltip div exists already...
            if (!$('#st-tooltips').length) {
                // add a hidden div that serves as tooltip
                this.tooltips = d3.select('body').append('div')
                    .attr('width', $(x).width())
                    .attr('height', $(x).height())
                    .style('pointer-events', 'none')
                    .attr('id', 'st-tooltips')
                    .style('position', 'absolute')
                    .style('opacity', 0);
                // split the tooltip div into a key-value pair section for
                // annotations of type st.annotation.TOOLTIP...
                this.tooltips.append('div')
                    .attr('id', 'tooltips-meta')
                    .style('height', '50%')
                    .style('width', '100%');
                // ...and a section for molecules resolved through URLs pointing
                // to SDfiles for annotations of type st.annotation.TOOLTIP_MOL
                this.tooltips.append('div')
                    .attr('id', 'tooltips-mol')
                    .style('height', '50%')
                    .style('width', '100%');
            } else { // ...reference the tooltip div if it exists
                this.tooltips = d3.select('#st-tooltips');
            }
            
            // implement custom behavior if defined in the extension
            if (typeof this.behavior == 'function') {
                this.behavior();
            }
            
            // define and render the x- and y-axis
            this.renderAxes();
            
            // draw the title
            if (this.opts.title && this.opts.title.length !== 0) {
                if (margins[0] < 20) {
                    console.log('Not enough space for chart title: ' + 
                        'increase top margin (min 20)');
                } else {
                    this.panel.append('text')
                        .attr('class', 'st-title')
                        .attr('x', margins[3] + (this.width / 2))
                        .attr('y', margins[0] * 0.75)
                        .attr('text-anchor', 'middle')
                        .attr('font-size', 'large')
                        .text(this.opts.title)
                }
            }
            
            // draw the options
            if (this.opts.labels) {
                if (margins[1] < 60) {
                    console.log('Not enough space for label option: ' + 
                        'increase right margin (min 60)');
                    return;
                }
                // create a new group element for the label option
                var labels = this.canvas.append('g')
                    .attr('id', 'st-options');
                
                // append the options title
                labels.append('text')      
                    .attr('x', this.width)
                    .attr('y', this.height - (this.height / 4))
                    .text('Options');
                
                // append the label
                var labelopt = labels.append('g');
                labelopt.append('svg:circle')
                    .attr('cx', this.width + 5)
                    .attr('cy', this.height - (this.height / 5))
                    .attr('r', 2)
                    .style('fill', '#333333')
                    .style('stroke', '#333333');
                 // append the label text
                labelopt.append('text')      
                    .attr('x', this.width + 12)
                    .attr('y', this.height - (this.height / 5) + 2)
                    .text('Labels')
                    .attr('id', 'st-label')
                    .style('cursor', 'pointer');
                // define option highlight on mouse down events
                labelopt.on('mousedown', function() { 
                    // switch the font-weight using the stroke attribute
                    var label = d3.select(this);
                    if (label.style('stroke') === 'none') {
                        label.style('stroke', '#333333');
                    } else {
                        label.style('stroke', 'none');
                    }
                    draw(chart);
                })
            }
        },
        
        /**
         * Defines and renders the x- and y-axis (direction, tick marks, etc.).
         * Axes follow standard cartesian coordinate conventions.
         */
        renderAxes: function () {
            var margins = this.opts.margins;
            // format numbers to four decimals: 1.2345678 to 1.2346
            var xFormat = d3.format('.4g');
            // format numbers to two decimals: 1.2345678 to 1.23
            var yFormat= d3.format(',.2g');
            
            this.xaxis = d3.svg.axis()  // define the x-axis
                .scale(this.scales.x)
                .ticks(6)
                .tickSubdivide(true)
                .tickFormat(xFormat)
                .orient('bottom');
            this.yaxis = d3.svg.axis()  // define the y-axis
                .scale(this.scales.y)
                .ticks(4)
                .tickFormat(yFormat)
                .orient('left');

            this.canvas.append('svg:g') // draw the x-axis
                .attr('class', 'st-xaxis')
                .attr('transform', 'translate(0,' + this.height + ')')
                .call(this.xaxis);
            this.canvas.append('svg:g') // draw the y-axis
                .attr('class', 'st-yaxis')
                .attr('transform', 'translate(-25, 0)')
                .call(this.yaxis);

            if (this.opts.xlabel !== '') {  // draw x-label if defined
                this.panel.select('.st-xaxis').append('text')
                    .text(this.opts.xlabel)
                    .attr('text-anchor', 'middle')
                    .attr('x', this.width / 2)
                    .attr('y', margins[2] / 2);
            }
            if (this.opts.ylabel !== '') {  // draw y-label if defined
                this.panel.select('.st-yaxis').append('text')
                    .text(this.opts.ylabel)
                    .attr('transform', 'rotate (-90)')
                    .attr('text-anchor', 'middle')
                    .attr('x', 0 - this.height / 2)
                    .attr('y', 0 - margins[3] / 2);
            }
        },
        
        /**
         * Adds signal labels to the chart.
         *
         * @param {object[]} data The drawn data object
         */
        renderlabels: function (data) {
            if (!this.opts.labels) {
                return;
            }
        
            var label = this.panel.select('#st-label');
            if (label.style('stroke') === 'none' || !this.data) {
                // remove current SVG elements of the series's class
                this.canvas.selectAll('.st-labels').remove();
                return;
            }
            
            // define domain extrema in x
            var ext = [
                this.scales.x.invert(0),
                this.scales.x.invert(this.width)
            ];
            // arrange based on x-axis direction
            ext = st.util.domain(this.scales.x, ext);
            // define bin width in px
            var binwidth = 50;
            // the maximum number of bins
            var nbins = Math.ceil(this.width / binwidth);
            // the domain step size
            var step = Math.abs(ext[1] - ext[0]) / (nbins - 1);
            // local data container for labels
            var bins = [];
            
            // format numbers to two decimals: 1.2345678 to 1.23
            var format = d3.format('.2f');
            
            // define label position and label binning behavior based on
            // whether the data was binned by min or max
            var binfunc;
            var yoffset;
            if (this.data.raw.minima) {
                yoffset = 10;
                binfunc = function (y1, y2) {
                    return y1 > y2;
                };
            } else {
                yoffset = -5;
                binfunc = function (y1, y2) {
                    return y1 < y2;
                };
            }
            // keep track of the number of points
            // to calculate the averagey value
            var n = 0;
            var avg = 0;
            // iterate over all data series
            for (var i = 0; i < data.length; i++) {
                // get the series data set
                var series = data[i];  
                // get the series data accessors
                var accs = this.data.accs(i);
                // keep track of the last visited data point
                var lastdp = series[0];
                n = n + series.length;
                for (var j = 1; j < series.length; j++) {
                    var curdp = series[j];
                    var x = lastdp[accs[0]];
                    var y = lastdp[accs[1]];
                    var avg = avg + y;
                    if (binfunc(curdp[accs[1]], y)) {
                        // get the target bin
                        var bin = Math.floor((x - ext[0]) / step);
                        // get the current data point in the bin
                        var dpb = bins[bin];
                        // if the bin is already populated with a data point...
                        if (dpb) {
                            if (binfunc(dpb[accs[1]], y)) {
                                bins[bin] = lastdp;
                            }
                        // ...add the current data point to the unpopulated bin
                        } else {
                            bins[bin] = lastdp;
                        }
                    }
                    lastdp = curdp;
                }
            }
            // get average
            avg = avg / n;
            
            // remove current SVG elements of the series's class
            this.canvas.selectAll('.st-labels').remove();
            var g = this.canvas.append('g')
                .attr('class', 'st-labels')
                .attr('text-anchor', 'middle');
            var pxinv = 0;
            var pyinv = 0;
            for (var i in bins) {
                if (bins[i] && binfunc(avg, bins[i][accs[1]])) {
                    var x = bins[i][accs[0]];
                    // get the chart coordinate values for the data point
                    var xinv = this.scales.x(x);
                    var yinv = this.scales.y(bins[i][accs[1]]);
                    if (Math.abs(xinv - pxinv) < 20 &&
                        Math.abs(yinv - pyinv) < 20) {
                        pxinv = xinv;
                        pyinv = yinv;
                        continue;
                    }
                    pxinv = xinv;
                    pyinv = yinv;
                    // append the SVG text elements
                    var fill = '#333333'
                    if (yinv < 0) {
                        yinv = 0;
                        fill = 'gray';
                    }
                    g.append('text')
                        .attr('x', xinv)
                        .attr('y', yinv + yoffset)
                        .style('fill', fill)
                        .text(format(x));
                }
            }
        },
        
        /**
         * Adds annotation group accessors to the chart.
         */
        rendergroups: function () {
            if (Object.keys(this.data.raw.annoGroups).length === 0) {
                return;
            }
            
            // self-reference for nested functions
            var chart = this;
            var labels = this.canvas.select('#st-options');
            var yoffset = 0;
            if (labels[0][0] === null) {
                // create a new group element for the label option
                labels = this.canvas.append('g')
                    .attr('id', 'st-options');
                // append the options title
                labels.append('text')      
                    .attr('x', this.width)
                    .attr('y', this.height - (this.height / 4))
                    .text('Options');
            } else {
                // currently only a single option is in use
                yoffset = 15;
            }
            
            // append the label
            var labelopt = labels.append('g');
            labelopt.append('svg:circle')
                .attr('cx', this.width + 5)
                .attr('cy', this.height - (this.height / 5) + yoffset)
                .attr('r', 2)
                .style('fill', '#333333')
                .style('stroke', '#333333');
             // append the label text
            labelopt.append('text')      
                .attr('x', this.width + 12)
                .attr('y', this.height - (this.height / 5) + 2 + yoffset)
                .text('Groups')
                .attr('id', 'st-groups')
                .style('cursor', 'pointer');
            // define action on mouse up events
            labelopt.on('mouseup', function() {
                // switch the font-weight using the stroke attribute
                var label = d3.select(this);
                if (label.style('stroke') === 'none') {
                    // highlight the selected option
                    label.style('stroke', '#333333');
                    // create the popup div
                    var popup = d3.select(chart.target).append('div')
                        .attr('id', 'st-popup')
                        .style('left', d3.event.pageX + 5 + 'px')
                        .style('top', d3.event.pageY + 5 + 'px')
                        .style('opacity', 0.9)
                        .style('background-color', 'white');
                    var keys = [];
                    // populate the keys array...
                    for (var key in chart.data.raw.annoGroups) {
                        keys.push(key);
                    }
                    // ...and add to the popup div
                    popup.append('ul')
                        .selectAll('li').data(keys).enter()
                        .append('li')
                        .style('display', 'block')
                        .style('cursor', 'pointer')
                        .html(function(d) { 
                            if (chart.data.raw.annoGroups[d]) {
                                return '<strong>' + d + '</strong>';
                            } 
                            return d;
                        })
                        // action on key selection
                        .on('mousedown', function(d) { 
                            // flag the selected key, reset all others
                            for (key in chart.data.raw.annoGroups) {
                                if (key == d && !chart.data.raw.annoGroups[d]) {
                                    chart.data.raw.annoGroups[d] = 1;
                                } else {
                                    chart.data.raw.annoGroups[key] = 0;
                                }
                            }
                            // reset the chart
                            chart.mouseDbl();
                            // reset the option
                            label.style('stroke', 'none');
                            $('#st-popup').remove();
                        });   
                } else {
                    // reset the option
                    label.style('stroke', 'none');
                    $('#st-popup').remove();
                }
            });   
        },
        
        /**
         * Defines the default zoom action for mouse down events.
         * 
         * @param {object} event A mouse event
         */
        mouseDown: function (event) {
            var p = d3.mouse(event);            // get the mouse position
            var left = this.opts.margins[3];
            var top = this.opts.margins[0];
            this.panel.select('.st-selection')  // set the selection rectangle
                .attr('x', p[0] - left)         // to the mouse position on
                .attr('xs', p[0] - left)        // the canvas and make the sel-
                .attr('y', p[1] - top)          // ection rectangle visible
                .attr('ys', p[1] - top)
                .attr('width', 1)
                .attr('height', 1)
                .attr('display', 'inline');
        },

        /**
         * Defines the default zoom action for mouse move events.
         * 
         * @param {object} event A mouse event
         */
        mouseMove: function (event) {
            // get the selection rectangle
            var s = this.panel.select('.st-selection')
            if (s.attr('display') === 'inline') { // proceed only if visible
                // get the corected mouse position on the canvas
                var pointerX = d3.mouse(event)[0] - this.opts.margins[3],
                    pointerY = d3.mouse(event)[1] - this.opts.margins[0],
                    // get the width and height of the selection rectangle
                    anchorWidth = parseInt(s.attr('width'), 10),
                    anchorHeight = parseInt(s.attr('height'), 10),
                    // get the distance between the selection rectangle start
                    // coordinates and the corrected mouse position
                    pointerMoveX = pointerX - parseInt(s.attr('x'), 10),
                    pointerMoveY = pointerY - parseInt(s.attr('y'), 10),
                    // get the original start coordinates of the rectangle
                    anchorXS = parseInt(s.attr('xs'), 10),
                    anchorYS = parseInt(s.attr('ys'), 10);
                
                // update the selection rectangle...
                if ((pointerMoveX < 0 && pointerMoveY < 0) // ...quadrant II
                    || (pointerMoveX * 2 < anchorWidth
                    && pointerMoveY * 2 < anchorHeight)) {
                    s.attr('x', pointerX);
                    s.attr('width', anchorXS - pointerX);
                    s.attr('y', pointerY);
                    s.attr('height', anchorYS - pointerY);
                } else if (pointerMoveX < 0                 // ...quadrant I
                    || (pointerMoveX * 2 < anchorWidth)) {
                    s.attr('x', pointerX);
                    s.attr('width', anchorXS - pointerX);
                    s.attr('height', pointerMoveY);
                } else if (pointerMoveY < 0                 // ...quadrant I
                    || (pointerMoveY * 2 < anchorHeight)) {
                    s.attr('y', pointerY);
                    s.attr('height', anchorYS - pointerY);
                    s.attr('width', pointerMoveX);
                } else {                                    // ...quadrant IV
                    s.attr('width', pointerMoveX);
                    s.attr('height', pointerMoveY);
                }
            }
        },

        /**
         * Defines the default zoom action for mouse up events.
         */
        mouseUp: function () {
            // px threshold for selections
            var tolerance = 5; 
            // get the selection rectangle
            var selection = this.panel.select('.st-selection');
            
            // check if the px threshold has been exceeded in x and y
            if (parseInt(selection.attr('width')) > tolerance
                && parseInt(selection.attr('height')) > tolerance) {
                // get the start coordinates of the rectangle
                var x = parseFloat(selection.attr('x'));
                var y = parseFloat(selection.attr('y'));
                // get the width and height of the selection rectangle
                var width = parseFloat(selection.attr('width'));
                var height = parseFloat(selection.attr('height'));
                
                // convert the width and height to the domain range
                width = this.scales.x.invert(x + width);
                height = this.scales.y.invert(y + height);
                // convert the start coordinates to the domain range
                x = this.scales.x.invert(x);
                y = this.scales.y.invert(y);

                if (this.data) { // only act on loaded data
                    var minheight = this.data.raw.gylim[0];
                    if (height < minheight) { // sanity check
                        height = minheight;
                    }
                }

                // rescale the x and y domain based on the new values
                this.scales.x.domain([x, width]).nice();
                this.scales.y.domain([height, y]).nice();
                
                // clean up: hide the selection rectangle
                selection.attr('display', 'none');
                // clean up: re-draw the x- and y-axis
                this.canvas.select('.st-xaxis').call(this.xaxis);
                this.canvas.select('.st-yaxis').call(this.yaxis);
                // clean up: re-draw the data set
                draw(this);
            } else {
                // hide the selection rectangle
                selection.attr('display', 'none');
            }
        },
        
        /**
         * Defines the default zoom action for mouse out events.
         */
        mouseOut: function(event) {
            // get the selection rectangle
            var selection = this.panel.select('.st-selection');
            // get the mouse position
            var pointerX = d3.mouse(event)[0],
                pointerY = d3.mouse(event)[1];
            
            // hide the selection rectangle if the
            // mouse has left the panel of the chart
            if (pointerX < 0 || pointerY < 0 ||
                pointerX > $(this.target).width() ||
                pointerY > $(this.target).height()) {
                    selection.attr('display', 'none');
            }
        },

        /**
         * Defines the default zoom action for mouse double-click events.
         *
         * @param {object} event A mouse event
         */
        mouseDbl: function (event) {
            if (event) {
                // get the corected mouse position on the canvas
                var pointerX = d3.mouse(event)[0] - this.opts.margins[3],
                    pointerY = d3.mouse(event)[1] - this.opts.margins[0];
                // abort if event happened outside the canvas
                if (pointerX < 0 || pointerX > this.width ||
                    pointerY < 0 || pointerY > this.height) {
                        return;
                }
            }
        
            if (this.data === null) {   // default for empty charts
                var xdom = st.util.domain(this.scales.x, [0, 1]);
                var ydom = st.util.domain(this.scales.y, [0, 1]);
                this.scales.x.domain(xdom).nice();
                this.scales.y.domain(ydom).nice();
                this.canvas.select('.st-xaxis').call(this.xaxis);
                this.canvas.select('.st-yaxis').call(this.yaxis);
                return;
            }
            
            // reset the global x and y domain limits
            var gxlim = st.util.domain(this.scales.x, this.data.raw.gxlim);
            var gylim = st.util.domain(this.scales.y, this.data.raw.gylim);
            // rescale the x and y domains
            this.scales.x.domain(gxlim).nice();
            this.scales.y.domain(gylim).nice();
            // re-draw the x- and y-axis
            this.canvas.select('.st-xaxis').call(this.xaxis);
            this.canvas.select('.st-yaxis').call(this.yaxis);
            // re-draw the data set
            this.data.reset();
            draw(this);
        },
        
        /**
         * Defines the default tooltip action for mouse over events.
         * 
         * @param {object} event A mouse event
         * @param {object} d A series data point
         * @param {string[]} accs A series data point accessor array
         * @param {string} group An annotation group if any
         */
        mouseOverAction: function (event, d, accs, group) {
            this.tooltips   // show the tooltip
                .style('display', 'inline');
            this.tooltips   // fade in the tooltip
                .transition()
                .duration(300)
                .style('opacity', 0.9);
            // format numbers to two decimals: 1.2345678 to 1.23
            var format = d3.format('.2f');
            // get the mouse position of the event on the panel
            // var pointer = d3.mouse(event);
            // get the translated transformation matrix...
            // var matrix = event.getScreenCTM()
            //    .translate(+pointer[0], +pointer[1]);
            // ...to adjust the x- and y-position of the tooltip
            this.tooltips
                // (window.pageXOffset + matrix.e + 10)
                // (window.pageYOffset + matrix.f - 10)
                // .style('left', d3.event.clientX + 10 + 'px')
                // .style('top', d3.event.clientY - 10 + 'px')
                .style('left', d3.event.pageX + 10 + 'px')
                .style('top', d3.event.pageY - 10 + 'px')
                .style('opacity', 0.9)
                .style('border', 'dashed')
                .style('border-width', '1px')
                .style('padding', '3px')
                .style('border-radius', '10px')
                .style('z-index', '10')
                .style('background-color', 'white');
            var x = format(d[accs[0]]); // format the x value
            var y = format(d[accs[1]]); // format the y value
            // add the x and y value to the tooltip HTML
            d3.selectAll('#tooltips-meta').html(
                this.opts.xlabel + ': ' + 
                x + '<br/>' + this.opts.ylabel + ': ' + y + '<br/>'
            );
            // self-reference for nested functions
            var chart = this;
            // check whether tooltips are assigned to the series point
            if (group && group !== '' && d.annos) {
                if (!(group in d.annos)) {
                    return;
                }
                var groupannos = d.annos[group];
                // copy the tooltip-meta sub-div 
                var tooltip = d3.selectAll('#tooltips-meta').html();
                // add the tooltip key-value pairs to the tooltip HTML
                for (var key in groupannos.tooltip) {
                    tooltip += key + ': ' + groupannos.tooltip[key] + '<br/>';
                }
                // add the HTML string to the tooltip
                d3.selectAll('#tooltips-meta').html(tooltip + '<br/>');
                if (!groupannos.tooltipmol) {
                    return;
                }
                // initiate the spinner on the tooltip-mol sub-div 
                var spinner = st.util.spinner('#tooltips-meta');
                // wait 500 ms before XHR is executed
                this.timeout = setTimeout(function () {
                    // array for mol2svg XHR promises
                    var deferreds = [];
                    // hide the tooltip-mol sub-div until
                    // all promises are fulfilled
                    d3.selectAll('#tooltips-mol')
                        .style('display', 'none');
                    // resolve all SDfile URLs one by one 
                    for (var molkey in groupannos.tooltipmol) {
                        var moldivid = '#tooltips-mol-' + molkey;
                        d3.selectAll('#tooltips-mol')
                            .append('div')
                            .attr('id', 'tooltips-mol-' + molkey)
                            .style('float', 'left')
                            .style('height', '100%')
                            .style('width', '50%');
                        // draw to the tooltip-mol sub-div and assign a title
                        d3.selectAll(moldivid).html(
                            '<em>' + molkey + '</em><br/>'
                        );
                        var jqxhr = chart.mol2svg.draw(
                            groupannos.tooltipmol[molkey], moldivid);
                        deferreds.push(jqxhr);
                    }
                    // wait until all XHR promises are finished
                    $.when.apply($, deferreds).done(function () {
                        // hide the spinner
                        spinner.css('display', 'none');
                        // make the tooltip-mol sub-div visible
                        d3.selectAll('#tooltips-mol')
                            .style('display', 'inline');
                    })
                    .fail(function () {
                        // hide the spinner
                        spinner.css('display', 'none');
                    });
                }, 500);
            } else {
                // clear the tooltip-mol sub-div 
                d3.selectAll('#tooltips-mol').html('');
            }
        },
        
        /**
         * Defines the default tooltip action for mouse out events.
         */
        mouseOutAction: function () {
            // clear any timeout from an async. request
            clearTimeout(this.timeout);
            // clear the tooltip-mol sub-div 
            d3.selectAll('#tooltips-mol').html('');
            this.tooltips   // fade the tooltip
                .transition()
                .duration(300)
                .style('opacity', 0);
            this.tooltips   // hide the tooltip
                .style('display', 'none');
        },
        
        /**
         * Draws the chart legend in the top right corner.
         */
        renderLegend: function () {
            // remove the current legend
            d3.select(this.target).select('.st-legend').remove();
            // build a new div container for the legend 
            var legend = d3.select(this.target).append('div')
                .attr('class', 'st-legend')
                .style('top', -(this.height + this.opts.margins[2]) + 'px')
                .style('left', this.width + this.opts.margins[3] + 'px')
                .style('width', this.opts.margins[1] + 'px')
                .style('height', (this.height / 2) - 30 + 'px')
                .style('position', 'relative');                 
            // inner div with 'hidden' scroll bars        
            legend = legend.append('div')
                .style('position', 'absolute')
                .style('overflow', 'scroll')
                .style('top', 0 + 'px')
                .style('left', 0 + 'px')
                .style('width', this.opts.margins[1] + 30 + 'px')
                .style('bottom', -30 + 'px');

            // self-reference for nested functions
            var colors = this.colors;
            // self-reference for nested functions
            var chart = this;
            // get the length (no. of items) of the new legend
            var length = this.data.raw.series.length;
            // create a svg container
            var lg = legend.append('svg:svg')
                .attr('height', length * 20 + 'px');
            
            // iterate over all data series
            for (var i = 0; i < length; i++) {
                // get the series identifier
                var id = this.data.raw.series[i].id;
                // get the series title
                var title = this.data.raw.series[i].title;
                 // create a new group element for the data series records
                var llg = lg.append('g')
                    .attr('stid', id)
                    .style('cursor', 'pointer');
                
                // create a new group element for each series
                llg.append('svg:rect')   // append the legend symbol
                    .attr('x', 5)
                    .attr('y', function () { return i * 20; })
                    .attr('width', 10)
                    .attr('height', 10)
                    .style('fill', function () { return colors.get(id); });
                llg.append('text')       // append the data series's legend text
                    .attr('x', 20)
                    .attr('y', function () { return i * 20 + 9; })
                    .text(function () {
                        return title;
                    });
                // define series highlights on mouse over events
                llg.on('mouseover', function() { 
                    // select the series
                    d3.select(this).style('fill', 'red');
                    var selectid = d3.select(this).attr('stid');
                    // highlight the selected series
                    chart.canvas.selectAll('.' + selectid)
                        .style('stroke-width', 2);
                    // fade all other series
                    for (var dataid in chart.data.raw.ids) {
                        if (dataid !== selectid) {
                            chart.canvas.selectAll('.' + dataid)
                                .style('opacity', 0.1);
                        }
                    }
                })
                // define series highlight removal on mouse out events
                llg.on('mouseout', function() {
                    // select the series
                    d3.select(this).style('fill', 'black');
                    var selectid = d3.select(this).attr('stid');
                    // reset the selected series
                    chart.canvas.selectAll('.' + selectid)
                        .style('stroke-width', 1);
                    // reset all other series
                    for (var dataid in chart.data.raw.ids) {
                        if (dataid !== selectid) {
                            chart.canvas.selectAll('.' + dataid)
                                .style('opacity', 1);
                        }
                    }
                })
            }
        },
        
        /**
         * Loads and binds the data set to the chart.
         *
         * @param {object} data A data set
         */
        load: function (data) {
            // sanity check
            if (!data) {
                console.log('Missing data object.');
                return;
            } else if (typeof data.push !== 'function' ||
                typeof data.add !== 'function' ||
                typeof data.remove !== 'function') {
                console.log('Invalid data object.');
                return;
            }
            
            var chart = this;       // self-reference for nested functions
            this.data = data;       // associate with the chart
            var oldadd = data.add;  // copy of the old function
            data.add = function() { // redefine
                try {
                    oldadd.apply(this, arguments);   // execute old copy
                    chart.data.push(function () {    // define callback
                        chart.xscale();              // rescale x
                        chart.yscale();              // rescale y
                        chart.canvas.select('.st-xaxis')
                            .call(chart.xaxis);     // draw the x-axis
                        chart.canvas.select('.st-yaxis')
                            .call(chart.yaxis);     // draw the y-axis
                        draw(chart);
                        chart.rendergroups();           // draw the anno groups
                        if (chart.opts.legend) {
                            chart.renderLegend();   // draw the legend
                        }
                    });
                } catch (err) {
                    console.log('Data load failed: ' + err);
                }
            };
            var oldremove = data.remove;    // copy of the old function
            data.remove = function() {      // redefine
                var ids = oldremove.apply(this, arguments); // execute old copy
                // iterate over the identifiers of the removed series
                for (var i in ids) {
                    // remove color entries
                    chart.colors.remove(ids[i]);
                    // remove associated SVG elements from the canvas
                    chart.canvas.selectAll('.' + ids[i]).remove();
                }
                if (chart.opts.legend) {
                    chart.renderLegend(); // redraw the legend
                }
            };
        }
    };
};

/**
 * Draws the chart and signal labels.
 *
 * @param {object} chart A chart object
 */
function draw (chart) {
    if (typeof chart.renderdata == 'function' && 
        typeof chart.renderlabels == 'function' &&
        chart.data !== null) {
        try {
            // inefficient: store binned data?
            var data = chart.renderdata(); // draw the data set
            chart.renderlabels(data);      // draw the labels
        } catch (err) {
            chart.data.remove();
            console.log('Error rendering the data: ' + err);
        }
    }
}
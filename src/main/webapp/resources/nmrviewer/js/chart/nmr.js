import "chart";

/**
 * Default chart for NMR spectra. 
 * 
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @extends st.chart.chart
 * @returns the NMR chart
 */
st.chart.nmr = function () {
    var nmr = chart(); // create and extend base chart
    
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
    nmr.render = function (x) {
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

        // scale object with initial d3 x- and y-scale functions
        this.scales = { 
            x: d3.scale.linear()
                .domain([1, 0]) // invert the x-domain limits
                .range([0, this.width]),
            y: d3.scale.linear()
                .range([this.height, 0])
        };
        
        // create the panel SVG element and define the base zoom behavior
        this.panel = d3.select(x)
            .append('svg:svg')
            .attr('class', 'st-base')
            .attr('width', this.width + margins[1] + margins[3])
            .attr('height', this.height + margins[0] + margins[2]);
        // define the base zoom behavior
        init_mouse(chart);
         
        // append the chart canvas as group within the chart panel
        this.canvas = this.panel
            .append('svg:g')
            .attr('transform', 'translate(' + margins[3] + ',' + margins[0] + ')');

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
        
        return this;
    };
    
    /**
     * Rescales the x domain.
     */
    nmr.xscale = function () {
        this.scales.x
            .domain([
                this.data.raw.gxlim[1],
                this.data.raw.gxlim[0]
            ])
            .nice();
    };
    
    /**
     * Rescales the y domain.
     */
    nmr.yscale = function () {
        this.scales.y
            .domain(this.data.raw.gylim);
    };
    
    /**
     * Defines and renders the x-axis (direction, tick marks, etc.).
     * Axes follow standard cartesian coordinate conventions.
     */
    nmr.renderAxes = function () {
        var margins = this.opts.margins;
        // format numbers to four decimals: 1.2345678 to 1.2346
        var xFormat = d3.format('.4g');
        
        this.xaxis = d3.svg.axis()  // define the x-axis
            .scale(this.scales.x)
            .ticks(6)
            .tickSubdivide(true)
            .tickFormat(xFormat)
            .orient('bottom');

        this.canvas.append('svg:g') // draw the x-axis
            .attr('class', 'st-xaxis')
            .attr('transform', 'translate(0,' + this.height + ')')
            .call(this.xaxis);

        if (this.opts.xlabel !== '') {   // draw x-label if defined
            this.panel.select('.st-xaxis').append('text')
                .text(this.opts.xlabel)
                .attr('text-anchor', 'middle')
                .attr('x', this.width / 2)
                .attr('y', margins[2] / 2);
        }
    };
    
    /**
     * Defines the default zoom action for mouse down events.
     * 
     * @param {object} event A mouse event
     */
    nmr.mouseDown = function (event) {
        var p = d3.mouse(event);
        var left = this.opts.margins[3];
        this.panel.select('.st-selection')  // set the selection rectangle
            .attr('x', p[0] - left)         // to the mouse position on
            .attr('xs', p[0] - left)        // the canvas and make the sel-
            .attr('width', 1)               // ection rectangle visible
            .attr('height', this.height)
            .attr('display', 'inline');
    };
    
    /**
     * Defines the default zoom action for mouse move events.
     * 
     * @param {object} event A mouse event
     */
    nmr.mouseMove = function (event) {
        // get the selection rectangle
        var s = this.panel.select('.st-selection')
        if (s.attr('display') === 'inline') { // proceed only if visible
            // get the corected mouse position (x) on the canvas
            var pointerX = d3.mouse(event)[0] - this.opts.margins[3],
                // get the width of the selection rectangle
                anchorWidth = parseInt(s.attr('width'), 10),
                // get the distance between the selection rectangle start
                // coordinates and the corrected mouse position in x
                pointerMoveX = pointerX - parseInt(s.attr('x'), 10),
                // get the original start coordinates of the rectangle
                anchorXS = parseInt(s.attr('xs'), 10);
             
            // update the selection rectangle
            if (pointerMoveX < 1 && (pointerMoveX * 2) < anchorWidth) {
                s.attr('x', pointerX);
                s.attr('width', anchorXS - pointerX);
            } else {
                s.attr('width', pointerMoveX);
            }
        }
    };

    /**
     * Defines the default zoom action for mouse up events.
     */
    nmr.mouseUp = function () {
        // px threshold for selections
        var tolerance = 5;
        // get the selection rectangle
        var selection = this.panel.select('.st-selection');
        
        // check if the px threshold has been exceeded in x
        if (parseInt(selection.attr('width')) > tolerance) {
            // get the x start coordinate of the rectangle
            var x = parseFloat(selection.attr('x'));
            // get the width of the selection rectangle
            var width = parseFloat(selection.attr('width'));

            // convert the width to the domain range
            width = this.scales.x.invert(x + width);
            // convert the x start coordinate to the domain range
            x = this.scales.x.invert(x);
            
            // rescale the x domain based on the new values
            this.scales.x.domain([x, width]).nice();

            // clean up: hide the selection rectangle
            selection.attr('display', 'none');
            // clean up: re-draw the x-axis
            this.canvas.select('.st-xaxis').call(this.xaxis);
            // clean up: re-draw the data set
            draw(this);
        } else {
            // hide the selection rectangle
            selection.attr('display', 'none');
        }
    };
    
    /**
     * Defines the default zoom action for mouse double-click events.
     */
    nmr.mouseDbl = function (event) {
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
            this.scales.x.domain([1, 0]).nice();
            this.scales.y.domain([0, 1]).nice();
            this.canvas.select('.st-xaxis').call(this.xaxis);
            return;
        }
    
        // rescale the x and y domains
        this.scales.x.domain([
            this.data.raw.gxlim[1],
            this.data.raw.gxlim[0]
        ]).nice();
        this.scales.y.domain(this.data.raw.gylim);
        // re-draw the x-axis
        this.canvas.select('.st-xaxis').call(this.xaxis);
        // re-draw the data set
        draw(this);
    };
    
    /**
     * Loads and binds the data set to the chart.
     *
     * @param {object} data A data set
     */
    nmr.load = function (data) {
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
            oldadd.apply(this, arguments);  // execute old copy
            chart.data.push(function () {   // define callback
                chart.xscale();             // rescale x
                chart.yscale();             // rescale y
                init_mouse(chart);          // re-initialise the mouse behavior      
                chart.canvas.select('.st-xaxis')
                    .call(chart.xaxis);     // draw the x-axis   
                draw(chart);
                chart.rendergroups();           // draw the anno groups
                if (chart.opts.legend) {
                    chart.renderLegend();   // draw the legend
                }
            });
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
    };
    
    /**
     * Renders the data.
     *
     * @returns {object} the binned data set for the current x-axis scale
     */
    nmr.renderdata = function () {
        // get the binned data set for the current x-axis scale
        var data = this.data.bin(this.width, this.scales.x);
        // get annotation group
        var group = '';
        for (var key in this.data.raw.annoGroups) {
            if (this.data.raw.annoGroups[key]) {
                group = key;
                break;
            }
        }    
        // self-reference for nested functions
        var chart = this;
        
        // iterate over all data series
        for (var i = 0; i < data.length; i++) {
            var series = data[i];           // get the series data
            var id = this.data.id(i);       // get the series identifier
            var accs = this.data.accs(i);   // get the series data accessors
            
            // define how the continuous line should be drawn
            var line = d3.svg.line()
                .x(function (d) {
                    return chart.scales.x(d[accs[0]]);
                })
                .y(function (d) {
                    return chart.scales.y(d[accs[1]]);
                });
                
            // remove current SVG elements of the series's class
            this.canvas.selectAll('.' + id).remove();
            // create a new group for SVG elements of this series
            var g = this.canvas.append('g')
                .attr('class', id);
            
            // add a continuous line for each series
            g.append('svg:path')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .style('stroke', this.colors.get(id))
                .style('fill', 'none')
                .style('stroke-width', 1)
                .attr('d', line(series));
            g.data(series).each(function(d) {      // address each point
                    if (d.annos) {  // check for on-canvas annotations...
                        if (!(group in d.annos)) {
                            return;
                        }
                        g.append('text') // ...append a SVG text element
                            .attr('class', id + '.anno')
                            .attr('x', chart.scales.x(d[accs[0]]))
                            .attr('y', chart.scales.y(d[accs[1]]) - 5)
                            .attr('text-anchor', 'middle')
                            .attr('font-size', 'small')
                            .attr('fill', color)
                            .text(d.annos[group].annotation);
                    }
                });
        }
        return data;
    };
    
    return nmr;
};

/**
 * Defines the base zoom behavior.
 *
 * @param {object} chart A chart object
 */
function init_mouse (chart) {
    var mousewheel = d3.behavior.zoom() // the mouse wheel zoom behavior
        .y(chart.scales.y)
        .center([0, chart.scales.y(0)])
        .on("zoom", function() {
            draw(chart);
        });
    chart.panel.call(mousewheel)
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
        })
}
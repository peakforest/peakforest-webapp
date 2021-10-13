import "chart";

/**
 * Default chart for 2D NMR spectra. 
 * 
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @extends st.chart.chart
 * @returns {object} the 2D NMR chart
 */
st.chart.nmr2d = function () {
    var nmr2d = chart(); // create and extend base chart
    
    /**
     * Rescales the x domain.
     */
    nmr2d.xscale = function () {
        this.scales.x
            .domain([   // invert the x-domain limits
                this.data.raw.gxlim[1],
                this.data.raw.gxlim[0]
            ])
            .nice();
    };
    
    /**
     * Rescales the y domain.
     */
    nmr2d.yscale = function () {
        this.scales.y
            .domain([
                this.data.raw.gylim[1],
                this.data.raw.gylim[0]
            ])
            .nice();
    };
    
    /**
     * Insertion point for custom behavior.
     */
    nmr2d.behavior = function () {
        // invert the x- and y-domain limits for initial chart setup
        this.scales.x.domain([1, 0]);
        this.scales.y.domain([1, 0]);
        
        // append rectangle of width 1 to serve as ruler in x
        var selX = this.canvas.append('svg:rect')
            .attr('class', 'st-selection')
            .attr('y', 0)
            .attr('width', 1)
            .attr('height', this.height)
            .style('pointer-events', 'none')
            .attr('visibility', 'hidden');
        // append rectangle of width 1 to serve as ruler in y
        var selY = this.canvas.append('svg:rect')
            .attr('class', 'st-selection')
            .attr('x', 0)
            .attr('width', this.width)
            .attr('height', 1)
            .style('pointer-events', 'none')
            .attr('visibility', 'hidden');
            
        // self-reference for nested functions
        var that = this;
        // define axis ruler actions for mouse move events
        d3.select('.st-base').on('mousemove', function () {
            // get the corrected mouse position on the canvas
            var pointerX = d3.mouse(this)[0] - that.opts.margins[3];
            var pointerY = d3.mouse(this)[1] - that.opts.margins[0];
            // whether the mouse event is outside the canvas...
            if (pointerX < 0 || pointerX > that.width
                || pointerY < 0 || pointerY > that.height) {
                selX.attr('visibility', 'hidden');
                selY.attr('visibility', 'hidden');
            // ...or inside the canvas: set rulers visible
            } else {
                selX.attr('x', pointerX);
                selY.attr('y', pointerY);
                selX.attr('visibility', 'visible');
                selY.attr('visibility', 'visible');
            }
            }) // append invisible rectangle to capture ruler events
            .append('svg:rect')
            .attr('class', 'st-mouse-capture')
            .style('visibility', 'hidden')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', this.width)
            .attr('height', this.height);
    };
    /**
     * Defines and renders the x- and y-axis (direction, tick marks, etc.).
     * Axes follow standard cartesian coordinate conventions.
     */
    nmr2d.renderAxes = function () {
        var margins = this.opts.margins;
        // format numbers to three decimals: 1.2345678 to 1.235
        var xFormat = d3.format('.3g');
        
        this.xaxis = d3.svg.axis()  // define the x-axis
            .scale(this.scales.x)
            .ticks(6)
            .tickSubdivide(true)
            .tickFormat(xFormat)
            .tickSize(-this.height)
            .tickPadding(5)
            .orient('bottom');
        this.yaxis = d3.svg.axis()  // define the y-axis
            .scale(this.scales.y)
            .ticks(6)
            .tickFormat(xFormat)
            .tickSize(-this.width)
            .tickPadding(5)
            .orient('right');

        this.canvas.append('svg:g') // draw the x-axis
            .attr('class', 'st-xaxis')
            .attr('transform', 'translate(0,' + this.height + ')')
            .call(this.xaxis);
        this.canvas.append('svg:g') // draw the y-axis
            .attr('class', 'st-yaxis')
            .attr('transform', 'translate(' + this.width + ',0)')
            .call(this.yaxis);

        if (this.opts.xlabel !== '') {  // draw x-label if defined
            d3.select('.st-xaxis').append('text')
                .text(this.opts.xlabel)
                .attr('text-anchor', 'middle')
                .attr('x', this.width / 2)
                .attr('y', margins[2] / 2);
        }
        if (this.opts.ylabel !== '') {  // draw y-label if defined
            d3.select('.st-yaxis').append('text')
                .text(this.opts.ylabel)
                .attr('transform', 'rotate (-90)')
                .attr('text-anchor', 'middle')
                .attr('x', 0 - this.height / 2)
                .attr('y', margins[1] / 2);
        }
    };
    
    /**
     * Renders the data.
     */
    nmr2d.renderdata = function () {
        // get the unbinned data set for the current x-axis scale
        var data = this.data.get(this.width, this.scales.x);
        // self-reference for nested functions
        var chart = this;
        // iterate over all data series
        for (var i = 0; i < data.length; i++) {
            var series = data[i];           // get the series data
            var id = this.data.id(i);       // get the series identifier
            var accs = this.data.accs(i);   // get the series data accessors
            
            // remove current SVG elements of the series's class
            this.canvas.selectAll('.' + id).remove();
            // create a new group for SVG elements of this series
            var g = this.canvas.append('g')
                .attr('class', id);
            
            // add circles for each series
            g.selectAll('.' + id + '.circle').data(series)
                .enter()
                .append('svg:circle')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .style('fill', this.colors.get(id))
                .style('stroke', this.colors.get(id))
                .attr("r", 3)
                .attr("cx", function (d) { 
                    return chart.scales.x(d[accs[0]]) 
                })
                .attr("cy", function (d) { 
                    return chart.scales.y(d[accs[1]]) 
                })
            // define point mouse-over behavior
            .on('mouseover', function (d) {
                // call default action
                chart.mouseOverAction(this, d, accs);
            })
            // define point mouse-out behavior
            .on('mouseout', function () {
                // call default action
                chart.mouseOutAction();
            });
        }
    };
    
    return nmr2d;
};
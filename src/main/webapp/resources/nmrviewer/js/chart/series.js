import "chart";

/**
 * Default chart for continuous data (Chromatograms, UV/VIS, etc.). 
 * 
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @extends st.chart.chart
 * @returns {object} the continuous data chart
 */
st.chart.series = function () {
    var series = chart(); // create and extend base chart
    
    /**
     * Rescales the x domain.
     */
    series.xscale = function () {
        var array = this.data.raw.gxlim; // get global x-domain limits
        if (this.opts.xreverse) {        // check whether axis is reversed...
            array = [                    // ...invert the x-domain limits
                array[1],
                array[0]
            ];
        }
        
        this.scales.x
            .domain(array)
            .nice();
    };
    
    /**
     * Rescales the y domain.
     */
    series.yscale = function () {
        this.scales.y
            .domain(this.data.raw.gylim)
            .nice();
    };
    
    /**
     * Insertion point for custom behavior.
     */
    series.behavior = function () {
        // define a text label for selected x values in the top left corner
        this.xpointer = this.panel.append('text')
            .attr('x', this.opts.margins[3])
            .attr('y', this.opts.margins[0])
            .attr('font-size', 'x-small')
            .text('');
            
        // self-reference for nested functions
        var chart = this;
        // format numbers to four decimals: 1.2345678 to 1.2346
        var xFormat = d3.format('.4g');
        // initialise the data set reference
        this.plotted = [];
        
        // define global mouse-move behavior on the panel
        this.panel.on('mousemove', function () {
            // get the mouse position on the x scale
            var mousex = d3.mouse(this)[0] - chart.opts.margins[3];
            // get the mouse position on the x domain
            var plotx = chart.scales.x.invert(mousex);
            // get the series x domain limits
            var plotdomain = chart.scales.x.domain();
            
            if (chart.opts.xreverse) {      // check whether axis is reversed...
                var within = function () {  // ...define boundary function this
                    return plotx < plotdomain[0] && plotx >= plotdomain[1];
                }
            } else {                        
                var within = function () {  // ...or that way
                    return plotx >= plotdomain[0] && plotx < plotdomain[1];
                }
            }
            
            // check whether the mouse pointer event is within the canvas
            if (within()) {
                // set text label value to the current formatted x value
                chart.xpointer.text('x = ' + xFormat(plotx));
                
                // iterate over all data series and update the point trackers
                for (var i = 0; i < chart.plotted.length; i++) {
                    // get the series data accessors
                    var accs = chart.data.accs(i);
                    // define the series bisector function for x values
                    var bisector = d3.bisector(function (d) {
                        return d[accs[0]];
                    }).left;
                    // get the closest x index to the left 
                    // of the mouse position in the x domain
                    var j = bisector(chart.plotted[i], plotx);
                    if (j > chart.plotted[i].length - 1) { // boundary check
                        j = chart.plotted[i].length - 1;
                    }
                    // get the closest x value based on the retrieved index
                    var dp = chart.plotted[i][j];
                    if (dp) { // if defined
                        // get the mouse position on the y scale
                        var ploty = chart.scales.y(dp[accs[1]]);
                        if (ploty < 0) {    // boundary check on chart ceiling
                            ploty = 0;
                        } else if (ploty > chart.height) { // boundary check...
                            ploty = chart.height;          // ...on chart floor
                        }
                        // update the point tracker with x and y
                        chart.canvas.select('.' + chart.data.id(i) + 'focus')
                            .attr('display', 'inline')
                            .attr('transform', 'translate(' + 
                            chart.scales.x(dp[accs[0]]) + ',' + 
                             ploty + ')');
                    }
                }
            } else { // the mouse pointer event is outside the canvas...
                chart.xpointer.text(''); // ...reset the text label value
                // and hide all point trackers for each series in the data set
                for (var i = 0; i < chart.plotted.length; i++) { 
                    chart.canvas.select('.' + chart.data.id(i) + 'focus')
                        .attr('display', 'none');
                }
            }
        });
    };
    
    /**
     * Renders the data.
     *
     * @returns {object} the binned data set for the current x-axis scale
     */
    series.renderdata = function () {
        // get the binned data set for the current x-axis scale
        var data = this.data.bin(this.width, this.scales.x);
        // reference the data set for use in series.behavior
        this.plotted = data;
        // self-reference for nested functions
        var chart = this;
        // iterate over all data series
        for (var i = 0; i < data.length; i++) {
            var series = data[i];           // get the series data
            var id = this.data.id(i);       // get the series identifier
            var accs = this.data.accs(i);   // get the series data accessors
            var color = this.colors.get(id);// get the series color
            
            // define how the continuous line should be drawn
            var line = d3.svg.line()        
                .interpolate('cardinal-open') // use an open cardinal spline
                .x(function (d) {
                    return chart.scales.x(d[accs[0]]);  // x1 = x1
                })
                .y(function (d) {
                    return chart.scales.y(d[accs[1]]);  // y1 = f(x1)
                });
                
            // remove current SVG elements of the series's class
            this.canvas.selectAll('.' + id).remove();
            // create a new group for SVG elements of this series
            var g = this.canvas.append('g')
                .attr('class', id);
            
            // add a continuous line for each series
            g.append('svg:path')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .style('stroke', color)
                .style('fill', 'none')
                .style('stroke-width', 1)
                .attr('d', line(series));
            // add a single hidden circle element for point tracking
            g.append('svg:circle')
                .attr('class', id + 'focus')
                .style('stroke', color)
                .style('fill', 'none')
                .attr('r', 3)
                .attr('cx', 0)
                .attr('cy', 0)
                .attr('display', 'none')
            // add hidden circle elements for highlighting
            g.selectAll('.' + id + '.circle').data(series)
                .enter()
                .append('svg:circle')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .style('fill', color)
                .style('stroke', color)
                .attr("opacity", 0)
                .attr("r", 3)
                .attr("cx", function (d) { 
                    return chart.scales.x(d[accs[0]]) 
                })
                .attr("cy", function (d) { 
                    return chart.scales.y(d[accs[1]]) 
                })
            // define point mouse-over behavior
            .on('mouseover', function (d) {
                // highlight the selected circle
                d3.select(this).attr('opacity', 0.8);
                // call default action
                chart.mouseOverAction(this, d, accs);
            })
            // define point mouse-out behavior
            .on('mouseout', function () {
                // remove the highlight for the selected circle
                d3.select(this).attr('opacity', '0');
                // call default action
                chart.mouseOutAction();
            });
        }
        return data;
    };
    
    return series;
};
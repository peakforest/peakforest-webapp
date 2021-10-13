import "chart";

/**
 * Default chart for mass spectrometry spectra.
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @extends st.chart.chart
 * @returns {object} the mass spectrometry chart
 */
st.chart.ms = function () {
    var ms = chart(); // create and extend base chart
    
    /**
     * Rescales the x domain.
     */
    ms.xscale = function () {
        this.scales.x
            .domain(this.data.raw.gxlim)
            .nice();
    };
    
    /**
     * Rescales the y domain.
     */
    ms.yscale = function () {
        this.scales.y
            .domain(this.data.raw.gylim)
            .nice();
    };
    
    /**
     * Insertion point for custom behavior.
     */
    ms.behavior = function () {
        // nothing to do
    };
    
    /**
     * Renders the data: defines how data points are drawn onto the canvas.
     *
     * @returns {object} the binned data set for the current x-axis scale
     */
    ms.renderdata = function () {
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
            var series = data[i];           // get the series data set
            var id = this.data.id(i);       // get the series identifier
            var accs = this.data.accs(i);   // get the series data accessors
            var color = chart.colors.get(id)// get the series color
            
            // remove current SVG elements of the series's class
            this.canvas.selectAll('.' + id).remove();
            // create a new group for SVG elements of this series
            var g = this.canvas.append('g')
                .attr('class', id);
                
            // add 'signal spikes' (lines) for each point in the data set
            g.selectAll('.' + id + '.line').data(series)
                .enter()
                .append('svg:line')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .attr('x1', function (d) { 
                    return chart.scales.x(d[accs[0]]);  // x1 = x1
                })
                .attr('y1', function (d) { 
                    return chart.scales.y(d[accs[1]]);  // y1 = f(x1)
                })
                .attr('x2', function (d) { 
                    return chart.scales.x(d[accs[0]]);  // x2 = x1
                })
                .attr('y2', chart.scales.y(0))          // y2 = 0
                .style('stroke', color)  // color by id
                .each(function(d) {      // address each point
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
                })
            // define point mouse-over behavior
            .on('mouseover', function (d) {
                // highlight the selected 'signal spike'
                d3.select(this).attr('stroke-width', 2);
                // call default action
                chart.mouseOverAction(this, d, accs, group);
            })
            // define point mouse-out behavior
            .on('mouseout', function () {
                // remove the highlight for the selected 'signal spike'
                d3.select(this).attr('stroke-width', null);
                // call default action
                chart.mouseOutAction();
            });
        }
        
        // remove current zero line element
        this.canvas.selectAll('.zeroline').remove();
        // check if the global y domain limit is lower than 0...
        if (this.data.raw.gylim[0] < 0) {
            // ...append a zero line element
            this.canvas.append('svg:line')
                .attr('class', 'zeroline')
                .attr('clip-path', 'url(#clip-' + this.target + ')')
                .attr('x1', this.scales.x(this.data.raw.gxlim[0]))
                .attr('y1', this.scales.y(0))
                .attr('x2', this.scales.x(this.data.raw.gxlim[1]))
                .attr('y2', this.scales.y(0))
                .style('stroke', '#333333');
        }
        return data;
    };
    
    return ms;
};
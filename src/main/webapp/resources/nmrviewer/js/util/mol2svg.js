import "cache";
import "util";

/**
 * SVG molecule renderer for MDL Molfiles. The header block and 
 * connection table are loosely parsed according to Elsevier MDL's V2000
 * format.
 * 
 * The molecule title is taken from the header block.
 * 
 * The two dimensional coordinates, symbol, charge, and mass difference
 * information is extracted from the atom block. 
 * 
 * Connectivity and stereo information is extracted from the bond block.
 * Single, double, and triple bonds as well as symbols for wedge, hash,
 * and wiggly bonds are supported.
 * 
 * The renderer uses the CPK coloring convention.
 *
 * Initializes the renderer setting the width and height of 
 * the viewport. The width and height should include a margin 
 * of 10 px, which is applied all around by default.
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @param {number} width A width of the viewport
 * @param {number} height A height of the viewport
 * @returns {object} object literal with a draw property
 */
st.util.mol2svg = function (width, height) {

    var w = width || 200,   // width of the panel
        h = height || 200,  // height of the panel
        x = null,           // linear d3 x scale function
        y = null,           // linear d3 y scale function
        avgL = 0,   // scaled average bond length (for font size scaling)
        cache = st.util.cache();

    /**
     * Loads the molfile data asynchronously, parses the file and 
     * creates the SVG. The SVG is appended to the element of the 
     * given identifier.    
     * 
     * @param {string} molfile A URL of the MDL molfile (REST web service)
     * @param {string} id An identifier of the element 
     * @returns {object} a XHR promise
     */
    var draw = function (molfile, id) {
        var jqxhr;
        var el = d3.select(id);
        var cacheKey = cache.getKey(molfile);
        if (cache.exists(cacheKey)) {
            var text = cache.get(cacheKey);
            parse(text, el);
        } else {
            jqxhr = $.when(
                $.get(molfile)
            )
            .fail(function() {
                console.log('Request failed for: ' + molfile);
            })
            .then(function(text) {
                cache.add(cacheKey, text);
                try {
                    parse(text, el);
                } catch (err) {
                    console.log('Mol2Svg Error:' + err);
                    el.html('');
                }
            });
        }
        return jqxhr;
    };

    /**
     * Parses the molfile, extracting the molecule title from the 
     * header block, two dimensional coordinates, symbol, charge, 
     * and mass difference information extracted from the atom block,
     * connectivity and stereo information from the bond block.
     *
     * @param {string} molfile A URL to the MDL molfile (REST web service)
     * @param {string} id An element identifier
     */
    var parse = function (molfile, el) {
        var lines = molfile.split(/\r\n|\n/),
            // title = lines[1],
            counter = lines[3].match(/\d+/g),
            nAtoms = parseFloat(counter[0]),
            nBonds = parseFloat(counter[1]);

        var atoms = atomBlock(lines, nAtoms),           // get all atoms
            bonds = bondBlock(lines, nAtoms, nBonds);   // get all bonds
        propsBlock(lines, atoms, nAtoms + nBonds);      // get properties

        var graph = initSvg(atoms, el);                 // layout SVG
        drawBonds(atoms, bonds, graph);
        drawAtoms(atoms, avgL, graph);
    };

    /**
     * Parses the atom block line by line.
     *
     * @param {string[]} lines A molfile line array
     * @param {number} nAtoms The total number of atoms
     * @returns {object[]} associative array of atom objects
     */
    var atomBlock = function (lines, nAtoms) {
        var atoms = [];
        var offset = 4; // the first three lines belong to the header block
        for (var i = offset; i < nAtoms + offset; i++) {
            var atom = lines[i].match(/-*\d+\.\d+|\w+/g);
            atoms.push({
                x: parseFloat(atom[0]),
                y: parseFloat(atom[1]),
                symbol: atom[3],
                mass: 0,    // deprecated
                charge: 0   // deprecated
            });
        }
        return atoms;
    };

    /**
     * Parses the bond block line by line.
     * 
     * @param {string[]} lines A molfile line array
     * @param {number} nAtoms The total number of atoms
     * @param {number} nBonds The total number of bonds
     * @returns {object[]} associative array of bond objects
     */
    var bondBlock = function (lines, nAtoms, nBonds) {
        var bonds = [];
        var offset = 4; // the first three lines belong to the header block
        for (var j = nAtoms + offset; j < nAtoms + nBonds + offset; j++) {
            var bond = lines[j].match(/\d+/g);
            bonds.push({
                // adjust to '0', atom counter starts at '1'
                a1: parseInt(bond[0]) - 1,  
                a2: parseInt(bond[1]) - 1,
                // values 1, 2, 3
                order: parseInt(bond[2]),
                // values 0 (plain),1 (wedge),4 (wiggly),6 (hash)                
                stereo: parseInt(bond[3])
            });
        }
        return bonds;
    };

    /**
     * Parses the properties block line by line.
     * 
     * @param {string[]} lines A molfile line array
     * @param {object[]} atoms An array of atom objects
     * @param {number} nAtomsBonds The total number of atoms and bonds
     */
    var propsBlock = function (lines, atoms, nAtomsBonds) {
        var offset = 4; // the first three lines belong to the header block
        for (var k = nAtomsBonds + offset; k < lines.length; k++) {
            if (lines[k].indexOf('M  ISO') !== -1) {
                var props = lines[k].match(/-*\d+/g);
                for (var l = 0, m = 1; l < props[0]; l++, m += 2) {
                    atoms[props[m] - 1].mass = parseInt(props[m + 1], 10);
                }
            } else if (lines[k].indexOf('M  CHG') !== -1) {
                var props = lines[k].match(/-*\d+/g);
                for (var l = 0, m = 1; l < props[0]; l++, m += 2) {
                    atoms[props[m] - 1].charge = parseInt(props[m + 1], 10);
                }
            }
        }
    };

    /**
     * Initializes the viewport and appends it to the element identified
     * by the given identifier. The linear d3 x- and y-scales are set 
     * to translate from the viewport coordinates to the mol coordinates.
     * 
     * @param {object[]} atoms An array of atom objects
     * @param {string} id An element identifier
     * @returns {object} the initialized SVG element
     */
    var initSvg = function (atoms, el) {
        // x minimum and maximum
        var xExtrema = d3.extent(atoms, function (atom) {
            return atom.x;
        });
        // y minimum and maximum
        var yExtrema = d3.extent(atoms, function (atom) { 
            return atom.y;
        });

        // dimensions of molecule graph
        var m = [20, 20, 20, 20];   // margins
        var wp = w - m[1] - m[3];   // width
        var hp = h - m[0] - m[2];   // height

        // maintain aspect ratio: divide/multiply height/width by the ratio (r)
        var r = (xExtrema[1] - xExtrema[0]) / (yExtrema[1] - yExtrema[0]);
        if (r > 1) {
            hp /= r;
        } else {
            wp *= r;
        }

        // X scale will fit all values within pixels 0-w
        x = d3.scale.linear().domain([xExtrema[0], xExtrema[1]]).range([0, wp]);
        // Y scale will fit all values within pixels h-0
        y = d3.scale.linear().domain([yExtrema[0], yExtrema[1]]).range([hp, 0]);

        // add an SVG element with the desired dimensions
        // and margin and center the drawing area
        var graph = el.append('svg:svg')
            .attr('width', wp + m[1] + m[3])
            .attr('height', hp + m[0] + m[2])
            .append('svg:g')
            .attr('transform', 'translate(' + m[3] + ',' + m[0] + ')');

        return graph;
    };

    /**
     * Draws the bonds onto the SVG element. Note that the bonds are drawn
     * first before anything else is added.
     * 
     * @param {object[]} atoms An array of atom objects
     * @param {object[]} bonds An array of bond objects
     * @param {object} graph A SVG element
     */
    var drawBonds = function (atoms, bonds, graph) {
        for (var i = 0; i < bonds.length; i++) {
            var a1 = atoms[bonds[i].a1],
                a2 = atoms[bonds[i].a2];

            // apply backing by calculating the unit vector and
            // subsequent scaling: shortens the drawn bond
            var dox = a2.x - a1.x,
                doy = a2.y - a1.y,
                l = Math.sqrt(dox * dox + doy * doy),
                dx = (dox / l) * (0.2),
                dy = (doy / l) * (0.2);

            // get adjusted x and y coordinates
            var x1 = a1.x + dx,
                y1 = a1.y + dy,
                x2 = a2.x - dx,
                y2 = a2.y - dy;

            // update average bond length for font scaling
            avgL += distance(x(x1), y(y1), x(x2), y(y2));

            var off,    // offset factor for stereo bonds
                xOff,   // total offset in x
                yOff,   // total offset in y
                xyData = []; // two dimensional data array
            if (bonds[i].order === 1) {                 // single bond
                if (bonds[i].stereo === 1) {            // single wedge bond
                    var length = distance(x1, y1, x2, y2);
                    off = 0.1;
                    xOff = off * (y2 - y1) / length;
                    yOff = off * (x1 - x2) / length;
                    xyData = [
                        [x1, y1],
                        [x2 + xOff, y2 + yOff],
                        [x2 - xOff, y2 - yOff]
                    ];
                    graph.append('svg:path')
                        .style('fill', 'black')
                        .style('stroke-width', 1)
                        .attr('d', wedgeBond(xyData));
                } else if (bonds[i].stereo === 6) {     // single hash bond
                    off = 0.2;
                    xOff = off * (y2 - y1) / l;
                    yOff = off * (x1 - x2) / l;
                    var dxx1 = x2 + xOff - x1,
                        dyy1 = y2 + yOff - y1,
                        dxx2 = x2 - xOff - x1,
                        dyy2 = y2 - yOff - y1;
                    for (var j = 0.05; j <= 1; j += 0.15) {
                        xyData.push(
                            [x1 + dxx1 * j, y1 + dyy1 * j],
                            [x1 + dxx2 * j, y1 + dyy2 * j]
                            );
                    }

                    graph.append('svg:path')
                        .style('fill', 'none')
                        .style('stroke-width', 1)
                        .attr('d', hashBond(xyData))
                        .attr('stroke', 'black');
                } else if (bonds[i].stereo === 4) {     // single wiggly bond
                    off = 0.2;
                    xOff = off * (y2 - y1) / l;
                    yOff = off * (x1 - x2) / l;
                    var dxx1 = x2 + xOff - x1,
                        dyy1 = y2 + yOff - y1,
                        dxx2 = x2 - xOff - x1,
                        dyy2 = y2 - yOff - y1;
                    for (var j = 0.05; j <= 1; j += 0.1) {
                        if (xyData.length % 2 === 0) {
                            xyData.push(
                                [x1 + dxx1 * j, y1 + dyy1 * j]
                                );
                        } else {
                            xyData.push(
                                [x1 + dxx2 * j, y1 + dyy2 * j]
                                );
                        }
                    }

                    graph.append('svg:path')
                        .attr('d', wigglyBond(xyData))
                        .attr('fill', 'none')
                        .style('stroke-width', 1)
                        .attr('stroke', 'black');
                } else {                                // single plain bond
                    xyData = [
                        [x1, y1], [x2, y2]
                    ];
                    graph.append('svg:path')
                        .attr('d', plainBond(xyData))
                        .attr('stroke-width', '1')
                        .attr('stroke-linecap', 'round')
                        .attr('stroke-linejoin', 'round')
                        .attr('stroke', 'black');
                }
            } else if (bonds[i].order === 2) {          // double bond
                off = 0.1;
                xOff = off * (y2 - y1) / l;
                yOff = off * (x1 - x2) / l;
                xyData = [
                    [x1 + xOff, y1 + yOff], [x2 + xOff, y2 + yOff],
                    [x1 - xOff, y1 - yOff], [x2 - xOff, y2 - yOff]
                ];
                graph.append('svg:path').attr('d', plainBond(xyData))
                    .attr('stroke-width', '1')
                    .style('fill', 'none')
                    .attr('stroke-linecap', 'round')
                    .attr('stroke-linejoin', 'round')
                    .attr('stroke', 'black');
            } else if (bonds[i].order === 3) {          // triple bond
                off = 0.15;
                xOff = off * (y2 - y1) / l;
                yOff = off * (x1 - x2) / l;
                xyData = [
                    [x1, y1], [x2, y2],
                    [x1 + xOff, y1 + yOff], [x2 + xOff, y2 + yOff],
                    [x1 - xOff, y1 - yOff], [x2 - xOff, y2 - yOff]
                ];
                graph.append('svg:path')
                    .attr('d', plainBond(xyData))
                    .attr('stroke-width', '1')
                    .attr('stroke-linecap', 'round')
                    .attr('stroke-linejoin', 'round')
                    .attr('stroke', 'black');
            }
        }
        avgL /= bonds.length; // get average bond length
    };

    /**
     * Draws the atoms onto the SVG element. Note that the atoms are drawn
     * on top of the bonds.
     * 
     * @param {object[]} atoms An array of atom objects
     * @param {number} avgL An average bond length
     * @param {object} graph A SVG element
     */
    var drawAtoms = function (atoms, avgL, graph) {
        for (var i = 0; i < atoms.length; i++) {
            var atom = atoms[i];
            var atomCol = d3.rgb(atomColor[atom.symbol]);
            var g = graph.append('svg:g')
                .attr('transform', 'translate(' + 
                    x(atom.x) + ',' + y(atom.y) + ')');
            // draw a circle underneath the text
            g.append('svg:circle')
                // hack: magic number for scaling
                .attr('r', Math.ceil(avgL / 3))
                .attr('fill', 'white')
                .attr('opacity', '1');
            // draw the text string
            g.append('text')                                
                // hack: magic number for scaling
                .attr('dy', Math.ceil(avgL / 4.5))          
                .attr('text-anchor', 'middle')
                .attr('font-family', 'sans-serif')
                // hack: magic number for scaling
                .attr('font-size', Math.ceil(avgL / 1.5))   
                .attr('fill', atomCol)
                .text(atom.symbol);

            if (atom.charge !== 0) {
                var c = atom.charge;
                if (c < 0) {
                    c = (c === -1) ? '-' : (c + '-');
                } else {
                    c = (c === +1) ? '+' : (c + '+');
                }
                g.append('text')
                    .attr('dx', +1 * Math.ceil(avgL / 3))
                    .attr('dy', -1 * Math.ceil(avgL / 4.5))
                    .attr('text-anchor', 'left')
                    .attr('font-family', 'sans-serif')
                    // hack: magic number for scaling (half of symbol size)
                    .attr('fill', atomCol)
                    .attr('font-size', Math.ceil(avgL / 3)) 
                    .text(c);
            }

            if (atom.mass !== 0) {
                g.append('text')
                    .attr('dx', -2 * Math.ceil(avgL / 3))
                    .attr('dy', -1 * Math.ceil(avgL / 4.5))
                    .attr('text-anchor', 'left')
                    .attr('font-family', 'sans-serif')
                    // hack: magic number for scaling (half of symbol size)
                    .attr('font-size', Math.ceil(avgL / 3)) 
                    .attr('fill', atomCol)
                    .text(atom.mass);
            }
        }
    };

    /**
     * Calculates the Euclidean distance between two points.
     * 
     * @param {number} x1 A x value of first point
     * @param {number} y1 A y value of first point
     * @param {number} x2 A x value of second point
     * @param {number} y2 A y value of second point
     * @returns {number} the Euclidean distance
     */
    var distance = function (x1, y1, x2, y2) {
        return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    };

    /**
     * d3 line function using the SVG path mini language to draw a plain bond.
     */
    var plainBond = d3.svg.line()
        .interpolate(function (points) {
            var path = points[0][0] + ',' + points[0][1];
            for (var i = 1; i < points.length; i++) {
                if (i % 2 === 0) {
                    path += 'M' + points[i][0] + ',' + points[i][1];
                } else {
                    path += 'L' + points[i][0] + ',' + points[i][1];
                }
            }
            return path;
        })
        .x(function (d) {
            return x(d[0]);
        })
        .y(function (d) {
            return y(d[1]);
        });

    /**
     * d3 line function using the SVG path mini language to draw a wedge bond.
     */
    var wedgeBond = d3.svg.line()
        .x(function (d) {
            return x(d[0]);
        })
        .y(function (d) {
            return y(d[1]);
        });

    /**
     * d3 line function using the SVG path mini language to draw a hash bond.
     */
    var hashBond = d3.svg.line()
        .interpolate(function (points) {
            var path = points[0][0] + ',' + points[0][1];
            for (var i = 1; i < points.length; i++) {
                if (i % 2 === 0) {
                    path += 'M' + points[i][0] + ',' + points[i][1];
                } else {
                    path += 'L' + points[i][0] + ',' + points[i][1];
                }
            }
            return path;
        })
        .x(function (d) {
            return x(d[0]);
        })
        .y(function (d) {
            return y(d[1]);
        });

    /**
     * d3 line function using the SVG path mini language to draw a wiggly bond.
     */
    var wigglyBond = d3.svg.line()
        .interpolate('cardinal')
        .x(function (d) {
            return x(d[0]);
        })
        .y(function (d) {
            return y(d[1]);
        });

    /*
     * Atom properties containing the CPK color values.
     */
    var atomColor = {
        H: '#000000',
        He: '#FFC0CB',
        Li: '#B22222',
        B: '#00FF00',
        C: '#000000',
        N: '#8F8FFF',
        O: '#F00000',
        F: '#DAA520',
        Na: '#0000FF',
        Mg: '#228B22',
        Al: '#808090',
        Si: '#DAA520',
        P: '#FFA500',
        S: '#FFC832',
        Cl: '#00FF00',
        Ca: '#808090',
        Ti: '#808090',
        Cr: '#808090',
        Mn: '#808090',
        Fe: '#FFA500',
        Ni: '#A52A2A',
        Cu: '#A52A2A',
        Zn: '#A52A2A',
        Br: '#A52A2A',
        Ag: '#808090',
        I: '#A020F0',
        Ba: '#FFA500',
        Au: '#DAA520'
    };

    // reference visible (public) functions as properties
    return {
        draw: draw
    };
};

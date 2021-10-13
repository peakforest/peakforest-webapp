import "util";

/**
 * Builds a compare function to sort an array of objects.
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @param {string} xacc An x value accessor
 * @return {object} the compare function
 */
st.util.compare = function (xacc) {
    var compare = function (a, b) {
        if (a[xacc] < b[xacc]) {
            return -1;
        }
        if (a[xacc] > b[xacc]) {
            return 1;
        }
        return 0;
    };
    return compare;
};
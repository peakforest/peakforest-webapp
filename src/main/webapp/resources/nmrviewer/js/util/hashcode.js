import "util";

/**
 * Simple hash code generator for strings.
 * 
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @param {string} str A string to be hashed
 * @returns {number} the hashed string
 */
st.util.hashcode = function (str) {
    var hash = 0, i, chr, len;
    if (str.length == 0) return hash;
    for (i = 0, len = str.length; i < len; i++) {
        chr = str.charCodeAt(i);
        hash = ((hash << 5) - hash) + chr;
        hash |= 0; // convert to 32bit integer
    }
    return hash;
};

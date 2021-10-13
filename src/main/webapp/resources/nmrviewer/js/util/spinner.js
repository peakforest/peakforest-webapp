import "util";

/**
 * Helper function to create divs for the spinner animation (defined in css).
 *
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @constructor
 * @param {string} el An element identifier to append the spinner to
 * @return {object} the spinner element
 */
st.util.spinner = function (el) {
    if ($('.st-spinner').length) { // singleton
        return $('.st-spinner');
    }
    // append the sub-divs to the spinner element
    $(el).append('<div class="st-spinner">' +
        '<div class="st-bounce1"></div>' + 
        '<div class="st-bounce2"></div>' +
        '<div class="st-bounce3"></div>' +
        '</div>');
        
    return $('.st-spinner');
};

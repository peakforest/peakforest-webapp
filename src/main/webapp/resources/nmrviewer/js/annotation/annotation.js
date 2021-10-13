/**
 * Enum for annotation types.
 * 
 * @author Stephan Beisken <beisken@ebi.ac.uk>
 * @enum {string}
 */
st.annotation = {
    TOOLTIP: 'tooltip',         // tooltip text, plain text key value pairs
    TOOLTIP_MOL: 'tooltip_mol', // tooltip molecule, resolves URLs to SDfiles
    ANNOTATION: 'annotation',   // canvas annotation, drawn onto the canvas
    ANNOTATION_COLOR: 'annotation_color' // canvas annotation color
};
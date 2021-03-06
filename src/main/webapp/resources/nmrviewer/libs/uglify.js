var fs = require("fs"),
    uglify = require("uglify-js");

var filename = process.argv[2],
    toplevel = uglify.parse(fs.readFileSync(filename, "utf8"), {filename: filename}),
    output = uglify.OutputStream({ascii_only: true}),
    compressor = uglify.Compressor(true),
    warn = uglify.AST_Node.warn;

uglify.AST_Node.warn = function(s, o) {
    if (o.msg === "Accidental global?" && o.name === "st" && o.line === 1 && !o.col) return;
    warn.apply(this, arguments);
};

toplevel.figure_out_scope();
toplevel.scope_warnings({
    undeclared: false,
    unreferenced: false,
    assign_to_global: true,
    func_arguments: false,
    nested_defuns: false,
    eval: false
});

toplevel = toplevel.transform(compressor);

toplevel.figure_out_scope();
toplevel.compute_char_frequency(true);
toplevel.mangle_names(true);
toplevel.print(output);

require("util").print(output.get());
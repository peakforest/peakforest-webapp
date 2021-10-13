if (typeof define === 'function' && define.amd) {
    define(st);
} else if (typeof module === 'object' && module.exports) {
    module.exports = st;
} else {
    this.st = st;
}
}();
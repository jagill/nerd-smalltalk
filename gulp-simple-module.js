var through     = require('through2'),
    gutil       = require('gulp-util'),
    PluginError = gutil.PluginError;

/**
 * Allows the creation of a simple gulp through-stream that
 * maps the incoming vinyl file via the supplied fn.
 *
 * @param name (Optional) Name of module, for debugging purposes.
 * @param fn Function to map vinyl objects.
 */
module.exports = function (name, fn) {
  if (typeof name === 'function' ) {
    fn = name;
    name = 'Simple Module';
  }

  return through.obj(function (file, enc, cb) {
    if (file.isNull()) {
      this.push(file);
      return cb();
    }

    if (file.isStream()) {
      this.emit(
        'error',
        new gutil.PluginError(name, 'Streaming not supported')
      );
    }

    file = fn(file)
    this.push(file);
    cb();
  });
};

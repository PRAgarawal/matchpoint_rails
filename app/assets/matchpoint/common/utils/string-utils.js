String.prototype.endsWith = function (suffix, isCaseSensitive) {
  if (isCaseSensitive) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
  } else {
    return this.toLowerCase().indexOf(suffix.toLowerCase(), this.length - suffix.length) !== -1;
  }
};

String.prototype.startsWith = function (prefix) {
  return this.indexOf(prefix) == 0;
};

String.prototype.ellipsify = function (cutOffLength) {
  if (cutOffLength >= this.length) {
    return this;
  }
  return this.substr(0, cutOffLength) + "...";
};

var SNAKE_CASE_REGEXP = /[A-Z]/g;
String.prototype.snake_case = function (separator) {
  separator = separator || '_';
  return this.replace(SNAKE_CASE_REGEXP, function (letter, pos) {
    return (pos ? separator : '') + letter.toLowerCase();
  });
};

var CONNECTING_CHAR_REGEXP = /[\-_\s][a-zA-Z]/g;
/**
 * Convert a string to its titleized version.
 * Ex: "Project_title".titleize() -> "Project Title"
 *     "projectTitle".titleize() -> "Project Title"
 *
 * @returns titleized string
 */
String.prototype.titleize = function () {
  if (this.length > 0) {
    this[0].toUpperCase();
  }

  var titleString = this.replace(SNAKE_CASE_REGEXP, function (letter, pos) {
    return (pos ? ' ' : '') + letter;
  });

  titleString = titleString.replace(CONNECTING_CHAR_REGEXP, function (pair, pos) {
    return ' ' + pair[1].toUpperCase();
  });

  return titleString.trim();
};

var EMAIL_REGEXP = /\S+@\S+\.\S+/i;

String.prototype.is_email = function() {
  return this.match(EMAIL_REGEXP) !== null;
};

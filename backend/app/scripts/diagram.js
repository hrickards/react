var page = require("webpage").create(), system = require('system');
page.open(system.args[1]);
page.onLoadFinished = function(status) {
  page.clipRect = page.evaluate(function() {
    return document.getElementsByClassName('diagram')[0].getBoundingClientRect();
  });
  page.render(system.args[2]);
  phantom.exit();
};

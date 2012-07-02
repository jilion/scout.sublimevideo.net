var page = require('webpage').create()
var fs = require('fs');
var MAX_EXECUTION_TIME = 20000; // 20 seconds
var GRACE_RENDER_TIME  = 7000; // 7 seconds
var address, output, size, call = '';

if (phantom.args.length < 2 || phantom.args.length > 3) {
  console.log('Wrong number of args: ' + phantom.args);
  phantom.exit(0);
}

try {
  address = phantom.args[0];
  output  = phantom.args[1];
  page.viewportSize = { width: 1100, height: 825 };
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2'
  page.settings.userName = 'foo'
  page.settings.password = 'bar'
  // page.customHeaders = {
  //   'Referer' : address
  // };

  page.onAlert = function (msg) {
    console.log(msg);
  }

  page.onError = function (msg, trace) {
    console.log(msg);
    trace.forEach(function(item) {
      console.log('  ', item.file, ':', item.line);
    })
  }

  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('Unable to load: ' + address);
      page.release();
      phantom.exit(1);
    } else {
      page.evaluate(function() {
        if (document.defaultView.getComputedStyle(document.body).backgroundColor == "rgba(0, 0, 0, 0)") {
          document.body.style.backgroundColor = 'white';
        }
      });

      window.setTimeout(function () {
        page.render(output);
        page.release();
        phantom.exit(0);
      }, GRACE_RENDER_TIME);
    }
  });
} finally { // Worst-case scenario
  setTimeout(function() {
    console.log("Max execution time " + Math.round(MAX_EXECUTION_TIME) + " seconds exceeded");
    phantom.exit(1);
  }, MAX_EXECUTION_TIME);
}

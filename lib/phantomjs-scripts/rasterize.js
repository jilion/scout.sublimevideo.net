var page = require('webpage').create()
var fs = require('fs');
var MAX_EXECUTION_TIME = 60000; // 60 seconds
var GRACE_RENDER_TIME  = 15000; // 15 seconds
var address, output, size, call = '';

if (phantom.args.length < 2 || phantom.args.length > 3) {
  console.log('Wrong number of args: ' + phantom.args);
  page.release();
  phantom.exit(0);
}

try {
  address = phantom.args[0];
  output  = phantom.args[1];
  page.viewportSize = { width: 1100, height: 825 };
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2'

  page.onAlert = function (msg) {
  }

  page.onError = function (msg, trace) {
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
    page.release();
    phantom.exit(1);
  }, MAX_EXECUTION_TIME);
}

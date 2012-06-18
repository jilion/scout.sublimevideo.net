var page = require('webpage').create(), address, output, size;

if (phantom.args.length < 2 || phantom.args.length > 3) {
  console.log('Usage: rasterize.js URL filename');
  phantom.exit();
} else {
  address = phantom.args[0];
  output  = phantom.args[1];
  page.viewportSize = { width: 1100, height: 825 };
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2'
  // page.customHeaders = {
  //   'Referer' : address
  // };

  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('Unable to load the address!');
      phantom.exit();
    } else {
      page.evaluate(function() {
        if (document.defaultView.getComputedStyle(document.body).backgroundColor == "rgba(0, 0, 0, 0)") {
          document.body.style.backgroundColor = 'white';
        }
      });

      console.log('Loaded...');
      window.setTimeout(function () {
        console.log('Screenshot!');
        page.render(output);
        phantom.exit();
      }, 200);
    }
  });
}

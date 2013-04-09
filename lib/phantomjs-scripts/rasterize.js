var page = require('webpage').create()
var fs = require('fs');
var MAX_EXECUTION_TIME = 60000; // 60 seconds
var GRACE_RENDER_TIME  = 15000; // 15 seconds
var address, output, size, call = '';
var pr0nKeywords = [
  { word: 'porn', coeff: 1 },
  { word: 'pr0n', coeff: 1 },
  { word: 'boobs', coeff: 1 },
  { word: 'sex', coeff: 1 },
  { word: 'sexy', coeff: 1 },
  { word: 'girlfriend', coeff: 0.8 },
  { word: 'hentai', coeff: 1 },
  { word: 'bukkake', coeff: 1 },
  { word: 'bdsm', coeff: 1 },
  { word: 'pov', coeff: 0.8 },
  { word: 'teen', coeff: 0.9 },
  { word: 'gay', coeff: 0.8 },
  { word: 'pussy', coeff: 1 },
  { word: 'nude', coeff: 1 },
  { word: 'nudism', coeff: 1 },
  { word: 'naked', coeff: 1 },
  { word: 'breast', coeff: 0.9 },
  { word: 'cock', coeff: 1 },
  { word: 'dick', coeff: 1 },
  { word: 'erotic', coeff: 1 },
  { word: 'virgin', coeff: 1 },
  { word: 'amateure', coeff: 1 },
  { word: 'mature', coeff: 1 },
  { word: 'cumming', coeff: 1 },
  { word: 'facial', coeff: 0.8 },
  { word: 'horny', coeff: 1 },
  { word: 'orgasm', coeff: 1 },
  { word: 'wife', coeff: 0.8 },
  { word: 'anal', coeff: 1 },
  { word: 'fetish', coeff: 1 },
  { word: 'chick', coeff: 1 },
  { word: 'ebony', coeff: 0.9 }
]

if (phantom.args.length < 2 || phantom.args.length > 4) {
  console.log('Wrong number of args: ' + phantom.args);
  page.release();
  phantom.exit(0);
}

try {
  address     = phantom.args[0];
  output      = phantom.args[1];
  safe_status = phantom.args[2];
  page.viewportSize = { width: 1100, height: 825 };
  page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2'

  page.onAlert = function (msg) {
  };

  page.onError = function (msg, trace) {
  };

  page.onConsoleMessage = function (msg) {
    console.log(msg);
  };

  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('Unable to load: ' + address);
      page.release();
      phantom.exit(1);
    } else {
      if (safe_status !== 'safe') {
        var pornKeywordsCount = countPornKeywords(page);

        if (pornKeywordsCount >= 9) {
          console.log('Pr0n detected!');
          phantom.exit(2); // PORN DETECTED!
        }
      }

      // Setting default background color to white if it is transparent
      if (document.defaultView.getComputedStyle(document.body).backgroundColor == "rgba(0, 0, 0, 0)") {
        document.body.style.backgroundColor = 'white';
      }

      window.setTimeout(function () {
        page.render(output);
        page.release();
        phantom.exit(0);
      }, GRACE_RENDER_TIME);
    }
  });
} finally { // Worst-case scenario
  setTimeout(function() {
    console.log("Max execution time " + Math.round(MAX_EXECUTION_TIME) + " milliseconds exceeded");
    page.release();
    phantom.exit(1);
  }, MAX_EXECUTION_TIME);
}

function countPornKeywords(page) {
  var html = page.evaluate(function () { return document.head.innerHTML + document.body.innerHTML });

  var pornRegex = new RegExp('(?:\\W|^)(' + pornRegexKeywords() + ')(?:\\W|$)', 'gi');
  var pornKeywordsCount = countPornKeywordsWithCoefficent(pornRegex, html);

  if (pornKeywordsCount > 0) {
    console.log(pornKeywordsCount + ' porn keywords found!');
  }

  return pornKeywordsCount;
}

function pornRegexKeywords() {
  var pornRegexKeywordsArray = [];
  for (var i = pr0nKeywords.length - 1; i >= 0; i--) {
    pornRegexKeywordsArray.push(pr0nKeywords[i].word);
  };

  return pornRegexKeywordsArray.join('|');
}

function countPornKeywordsWithCoefficent(regex, string) {
  var count = 0;
  var keywordsFound;
  var keywords = [];
  // console.log(regex);
  // console.log(string);
  // console.log(regex.exec(string));
  while ((keywordsFound = regex.exec(string)) !== null) {
    for (var i = pr0nKeywords.length - 1; i >= 0; i--) {
      if (pr0nKeywords[i].word == keywordsFound[1]) {
        count += pr0nKeywords[i].coeff;
        keywords.push(keywordsFound[1]);
      }
    };
  }
  console.log('Porn keywords:' + keywords);
  return count;
}
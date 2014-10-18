/*
* My Internet Color
* a piece by @gleuch <http://gleu.ch>
* (c)2014, all rights reserved
*
* -----------------------------------------------------------------------------
*
* Extension background script
* - listens to completed web requests, check blacklist, & ping server with url.
*
*/


var MyInternetColor = function() {
  // todo, use localstorage to store urls
  this.started = false;
  this.start();
};

// Add webRequest onComplete listener. 
MyInternetColor.prototype.start = function() {
  var _t = this;

  if (_t.started) return;

  // Listen only for completed web pages from main_frame (parent level). This does not listen for changes in history caused by push/pop/replaceState.
  chrome.webRequest.onCompleted.addListener(function(obj) {
    if (_t.isValidRequest(obj.url, obj.ip)) {
      _t.addToHistory(obj.url);
    }
    return {};
  },
  {
    types: ["main_frame"],
    urls: ["<all_urls>"]
  },
  []);

  _t.started = true;
};

// Send info to server. Easiest is to call as image.
MyInternetColor.prototype.addToHistory = function(url) {
  var img = new Image();
  img.onError = function() {
    console.log('Unable to touch ' + this.src);
  };
  img.src = 'http://localhost:2000/?url=' + this.encodeUrl(url);

};

// UTF-8 safe URI encoding
MyInternetColor.prototype.encodeUrl = function(str) {
  return window.btoa(encodeURIComponent(escape(str)));
};

// Check URL and ip address against blacklisted sites/ips
MyInternetColor.prototype.isValidRequest = function(url,ip) {
  // Is request to self or not an http/https request?
  if (ip == "::1" || ip == '127.0.0.1' || url.match(/^(?!http)/)) return false;

  // Is url matched against any blacklisted url formats?
  for (var i=0; i < this.blacklistUrls.length; i++) {
    if (url.match(this.blacklistUrls[i])) return false;
  }

  // Must be valid if we got this far.
  return true;
};

MyInternetColor.prototype.blacklistUrls = [
  // chrome:about, default start page
  /^http(s)?\:\/\/(www\.)?google\.com\/(_\/chrome\/newtab|webhp)/i,

  // because i do web dev, skip over these pages, as not really "browsing"
  /^http(s)?:\/\/([a-z0-9\.\-]+)?(localhost|.*\.dev)(\:\d+)?\//i
];


// Start it up!
this.myInternetColor = new MyInternetColor();




// kthxbye!
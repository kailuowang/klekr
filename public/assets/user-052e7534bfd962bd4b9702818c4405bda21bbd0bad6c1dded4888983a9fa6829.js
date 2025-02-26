(function() {
  window.klekr = window.klekr || {};

  window.klekr.Global = window.klekr.Global || {};

  window.klekr.Slideshow = window.klekr.Slideshow || {};

  window.klekr.Sources = window.klekr.Sources || {};

  window.klekr.User = window.klekr.User || {};

  window.Events = window.Events || {
    trigger: function(eventName, data) {
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log("Event triggered: " + eventName) : void 0 : void 0;
    },
    bind: function(eventName, callback) {
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log("Event bound: " + eventName) : void 0 : void 0;
    }
  };

  (function() {
    var userAgent;
    if (typeof jQuery !== 'undefined' && !jQuery.browser) {
      jQuery.browser = {};
      userAgent = navigator.userAgent.toLowerCase();
      jQuery.browser.mozilla = /mozilla/.test(userAgent) && !/webkit/.test(userAgent);
      jQuery.browser.webkit = /webkit/.test(userAgent);
      jQuery.browser.opera = /opera/.test(userAgent);
      return jQuery.browser.msie = /msie/.test(userAgent) || /trident/.test(userAgent);
    }
  })();

}).call(this);

// User-related JavaScript
// Note: No user-specific scripts are included at this time;

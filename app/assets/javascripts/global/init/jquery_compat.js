// jQuery compatibility layer for older jQuery plugins
// This adds back methods that were removed in newer jQuery versions
// so that older plugins continue to work

(function($) {
  // Add back the .live() method which was deprecated in jQuery 1.7 and removed in 1.9
  if (!$.fn.live) {
    $.fn.live = function(types, data, fn) {
      $(this.context).on(types, this.selector, data, fn);
      return this;
    };
  }

  // Add back the .die() method which was also removed
  if (!$.fn.die) {
    $.fn.die = function(types, fn) {
      $(this.context).off(types, this.selector || '**', fn);
      return this;
    };
  }

  // Add back browser detection
  if (!$.browser) {
    $.browser = {};
    $.browser.mozilla = /mozilla/.test(navigator.userAgent.toLowerCase()) && !/webkit/.test(navigator.userAgent.toLowerCase());
    $.browser.webkit = /webkit/.test(navigator.userAgent.toLowerCase());
    $.browser.opera = /opera/.test(navigator.userAgent.toLowerCase());
    $.browser.msie = /msie/.test(navigator.userAgent.toLowerCase()) || /trident/.test(navigator.userAgent.toLowerCase());
  }

  // Add a migration layer for .attr() on boolean properties (like checked, selected, etc.)
  var oldAttr = $.fn.attr;
  if (oldAttr) {
    var boolAttrs = ['checked', 'selected', 'disabled', 'readonly'];
    
    $.fn.attr = function(name, value) {
      if (typeof name === 'string' && boolAttrs.indexOf(name) >= 0 && (value === true || value === false)) {
        return this.prop(name, value);
      }
      return oldAttr.apply(this, arguments);
    };
  }

  // Log a message to indicate this compatibility layer is active
  if (window.console && console.info) {
    console.info("jQuery compatibility layer loaded");
  }
})(jQuery);
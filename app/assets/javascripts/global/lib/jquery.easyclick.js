/**
 * jQuery plugin for easy click handling
 * Provides a lightweight wrapper around the click event handler
 * that handles return values properly and prevents default behavior
 */
(($) => {
  /**
   * Enhanced click handler
   * @param {Function} handler - Click event handler function
   * @returns {jQuery} The jQuery object for chaining
   */
  $.fn.click_ = function(handler) {
    return this.each(function() {
      const element = $(this);
      element.bind('click', (e) => {
        const retVal = handler(e);
        return retVal === true;
      });
    });
  };
})(jQuery);
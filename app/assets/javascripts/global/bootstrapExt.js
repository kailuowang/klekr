/**
 * Extension for Bootstrap popovers with custom attributes
 */

/**
 * jQuery extension for enhanced popovers
 * Reads configuration from data attributes:
 * - data-popover: Placement direction
 * - data-popover-top-offset: Custom top offset
 * - data-popover-left-offset: Custom left offset
 * @returns {jQuery} The jQuery object for chaining
 */
$.fn.popover_ext = function() {
  return this.each(function() {
    const element = $(this);
    element.popover({
      offset: 5,
      placement: element.attr("data-popover"),
      topOffset: element.attr("data-popover-top-offset"),
      leftOffset: element.attr("data-popover-left-offset")
    });
  });
};

// Initialize popovers on document ready
$(function() {
  $(".has-popover[data-popover]").popover_ext();
});
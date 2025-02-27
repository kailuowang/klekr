/**
 * Extensions for Bootstrap components
 */

/**
 * Enhanced popover functionality that reads configuration from data attributes
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

// Apply popover functionality to elements with the appropriate classes and data attributes
$(function() {
  $(".has-popover[data-popover]").popover_ext();
});
/**
 * jQuery easyclick plugin
 * Provides a click_ method that handles return values correctly
 */
(($ = jQuery) => {
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
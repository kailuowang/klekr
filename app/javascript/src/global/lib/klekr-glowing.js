
!function( $ ){

  $(function () {
    $('.glow[data-glowing]').glowing();
  });

  /* glowing PLUGIN DEFINITION
   * ========================== */

  $.fn.glowing = function () {
    return this.each(function () {
      $(this).addClass('glow-transition')
      var self = $(this);
      var toggleGlowing = function(){
        self.toggleClass('glow')
      }
      var glowingId = setInterval(toggleGlowing, self.attr('data-glowing'));
      self.attr('data-glowing-id', glowingId)
      self.bind('mouseenter', function(){
        var intervalId = $(this).attr('data-glowing-id');
        if(intervalId){
          clearInterval(intervalId);
          $(this).removeAttr('data-glowing-id')
          $(this).removeClass('glow');
        }
      });
    })
  }

}( window.jQuery || window.ender );
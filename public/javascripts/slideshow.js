function preload(arrayOfImages) {
  $(arrayOfImages).each(function() {
    img = new Image();
    img.src = this;
  });
}




$(document).ready(function() {

  function show(image){
    $('#loading').hide();
    ensure_display(image);
    image.show();
  }

  function ensure_display(image){
    if(image.height() <= 400 && image.width() <= 550 && image.attr('src') === largeUrl) {
      image.attr('src', mediumUrl)
    }
  }

  $('#picture').load(function() {
    var image = $(this);
    var isShowing = image.is(":visible");

    if(isShowing){return;}

    if(image.width() == 0 && image.height() == 0)
    {
      image.attr('src', image.attr('src') + new Date().getTime() );
      return;
    }

    var imageTooHigh = image.height() * 1.6 > windowSize;


    var isLargeSize = image.attr('src') === largeUrl;


    if ( !imageTooHigh  && !isLargeSize ){
      image.attr('src', largeUrl);
      show(image);

      image.load(function(){
        preload(next3images);
      });
    }else{
      show(image);
      preload(next3images);
    }


  });

  var next = function(){
    window.location = $('#next').attr('href');
  };

  var back = function(){
    history.back()
  };

  $('#right').click(next);

  $('#left').click(back);

  $('#fave').click(function(){
    $('#faveWaiting').show();
    $('#fave').hide();
  });

  $('#fave').bind("ajax:success", function(){
    $('#fave').hide();
    $('#faveWaiting').hide();
    $('#favedText').show();
  });

  $(document).bind('keydown', 'space', next);
  $(document).bind('keydown', 'n', next);
  $(document).bind('keydown', 'b', back);
  $(document).bind('keydown', 'f', function(){
      $('#fave').click();
  });

});

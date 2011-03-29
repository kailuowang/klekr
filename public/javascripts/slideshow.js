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
    image = $(this);
    isShowing = image.is(":visible");

    if(isShowing){return;}

    if(image.width() == 0 && image.height() == 0)
    {
      image.attr('src', image.attr('src') + new Date().getTime() );
      return;
    }

    imageTooHigh = image.height() * 1.6 > windowSize;


    isLargeSize = image.attr('src') === largeUrl;


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

  $('#right').click(next);

  $('#left').click(function(){
     history.back()
  });


  $(document).bind('keydown', 'space', next);
  $(document).bind('keydown', 'f', function(){
      $('#fave').click();
  });

});

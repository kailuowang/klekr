function preload(arrayOfImages) {
  $(arrayOfImages).each(function() {
    img = new Image();
    img.src = this;
  });
}


$(document).ready(function() {
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


    isLargeSize = image.attr('src') == largeUrl;


    if ( !imageTooHigh  && !isLargeSize ){
      image.attr('src', largeUrl);
    }

    image.show();
    preload(next3images);
  });


  $('#right').click(function(){
      window.location = $('#next').attr('href')
  });

  $('#left').click(function(){
      window.location = $('#previous').attr('href')
  });

});
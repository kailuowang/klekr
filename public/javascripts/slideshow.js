function preload(arrayOfImages) {
  $(arrayOfImages).each(function() {
    img = new Image();
    img.src = this;
  });
}


$(document).ready(function() {
  $('#picture').load(function() {
    pic = this;
    image = $(pic);
    isShowing = image.is(":visible");
//    emptyImage = pic.width == 500 && pic.height == 375;
    if(isShowing){return;}

    if(image.width() == 0 && image.height() == 0)
    {
      image.src(image.src());
      return;
    }
    imageTooHigh = pic.height * 1.6 > windowSize;
    isLargeSize = pic.src == largeUrl;

    if ( !imageTooHigh  && !isLargeSize ) {
      pic.src = largeUrl;
    }
    image.show();
    preload(next3images);
  });




});
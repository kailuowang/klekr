function preload(arrayOfImages) {
  $(arrayOfImages).each(function() {
    img = new Image();
    img.src = this;
  });
}


$(document).ready(function() {
  $('#picture').load(function() {
    pic = this;
    emptyImage = pic.width == 500 && pic.height == 375;
    imageTooHigh = pic.height > windowSize;
    isMediumSize = pic.src == mediumUrl;

    if ( ( emptyImage || imageTooHigh ) && !isMediumSize ) {
      pic.src = mediumUrl;
    }
  });


  preload(next3images);

});
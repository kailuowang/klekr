function preload(arrayOfImages) {
    $j(arrayOfImages).each(function() {
        img = new Image();
        img.src = this;
    });
}



$j(document).ready(function() {
    pic = $j('#picture')[0];
    if((pic.width == 500 && pic.height == 375) || pic.height > $j(window).height()){
       pic.src = medium_url;
    }


    preload(next3images);

});

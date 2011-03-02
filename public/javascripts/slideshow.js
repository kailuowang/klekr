function preload(arrayOfImages) {
    $j(arrayOfImages).each(function() {
        img = new Image()
        img.src = this;
    });
}

var next3images = [];

$j(document).ready(function() {

    preload(next3images);
});

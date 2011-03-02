function preload(arrayOfImages) {
    $j(arrayOfImages).each(function() {
        $j('<img/>')[0].src = this;

    });
}

var next3images = [];

$j(document).ready(function() {

    preload(next3images);
});

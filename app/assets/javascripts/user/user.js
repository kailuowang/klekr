$(document).ready(function() {
  $(document).bind('keydown', 's', function() {
    window.location = $('#slide').attr('href');
  });
});
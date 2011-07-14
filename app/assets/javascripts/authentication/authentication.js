
$(document).ready(function() {
  $(function() {
     var seconds = 5;
     setTimeout(redirectCountdown, 1000);

     function redirectCountdown() {
        seconds--;
        if (seconds > 0) {
           $("#countdown").text(seconds);
           setTimeout(redirectCountdown, 1000);
        }
     }
  });
});


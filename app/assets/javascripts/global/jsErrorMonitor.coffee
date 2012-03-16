window.onerror = (msg) ->
  $("body").attr("data-JSError",msg);

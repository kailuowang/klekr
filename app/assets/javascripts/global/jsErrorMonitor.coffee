window.onerror = (msg, file, line) ->
  $("body").attr("data-JSError",msg);
  klekr.Global.broadcaster.trigger 'javascript:error', [msg, file, line]
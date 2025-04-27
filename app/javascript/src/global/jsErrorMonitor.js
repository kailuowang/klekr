/**
 * Global error handler for JavaScript errors
 */
window.onerror = (msg, file, line) => {
  document.querySelector("body").setAttribute("data-JSError", msg);
  
  // Notify via broadcaster if available
  if (window.klekr && window.klekr.Global && window.klekr.Global.broadcaster) {
    klekr.Global.broadcaster.trigger('javascript:error', [msg, file, line]);
  }
};
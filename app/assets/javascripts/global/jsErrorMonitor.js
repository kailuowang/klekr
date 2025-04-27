import { broadcaster } from './broadcaster';

/**
 * Global JavaScript error monitor
 * Captures unhandled errors and broadcasts them through the event system
 */

/**
 * Global error handler
 * @param {string} msg - Error message
 * @param {string} file - File where the error occurred
 * @param {number} line - Line number where the error occurred
 */
window.onerror = (msg, file, line) => {
  // Store error in DOM for debugging
  $("body").attr("data-JSError", msg);
  
  // Broadcast error through the event system
  broadcaster.trigger('javascript:error', [msg, file, line]);
};
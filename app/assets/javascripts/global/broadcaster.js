/**
 * Event broadcaster for application-wide event handling
 * @extends Events
 */
class Broadcaster extends Events {
  // No custom functionality needed at this point
}

// Create the global broadcaster instance
const broadcaster = new Broadcaster();

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.Broadcaster = Broadcaster;
window.klekr.Global = window.klekr.Global || {};
window.klekr.Global.broadcaster = broadcaster;

export { broadcaster, Broadcaster };
export default broadcaster;
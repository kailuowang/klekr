/**
 * Broadcaster class for handling global events
 * @extends Events
 */
import Events from './events.js';

// Create namespace if it doesn't exist
window.klekr = window.klekr || {};

/**
 * Provides a global event bus for application-wide communication
 * @extends Events
 */
class Broadcaster extends Events {
  /**
   * Creates a new Broadcaster instance
   */
  constructor() {
    super();
  }
}

// Create a singleton instance
const broadcaster = new Broadcaster();

// Export to global namespace for compatibility
window.klekr.Broadcaster = Broadcaster;
window.klekr.Global = window.klekr.Global || {};
window.klekr.Global.broadcaster = broadcaster;

// Export for ES modules
export { broadcaster, Broadcaster };
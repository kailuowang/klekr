/**
 * Events base class
 * A simple events implementation for inheritance or mixing into other classes
 */
class Events {
  constructor() {
    this._events = {};
    this.on = this.on.bind(this);
    this.trigger = this.trigger.bind(this);
    this.off = this.off.bind(this);
  }

  /**
   * Register an event handler
   * @param {string} event - Event name
   * @param {function} callback - Event handler function
   * @returns {this} - Returns self for chaining
   */
  on(event, callback) {
    if (!this._events[event]) {
      this._events[event] = [];
    }
    this._events[event].push(callback);
    return this;
  }

  /**
   * Unregister an event handler
   * @param {string} event - Event name
   * @param {function} [callback] - Event handler function (if omitted, all handlers for the event are removed)
   * @returns {this} - Returns self for chaining
   */
  off(event, callback) {
    if (!this._events[event]) return this;

    if (!callback) {
      delete this._events[event];
    } else {
      this._events[event] = this._events[event].filter(cb => cb !== callback);
    }
    return this;
  }

  /**
   * Trigger an event
   * @param {string} event - Event name
   * @param {...any} args - Arguments to pass to the event handlers
   * @returns {this} - Returns self for chaining 
   */
  trigger(event, ...args) {
    if (!this._events[event]) return this;

    for (const callback of this._events[event]) {
      callback(...args);
    }
    return this;
  }
}

// Export to global namespace for compatibility with existing code
window.Events = Events;

export default Events;
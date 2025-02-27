/**
 * ScrollControl Component
 * Handles mouse wheel scrolling for navigating pictures
 */
import Events from '../src/global/events.js';

class ScrollControl extends Events {
  /**
   * Create a ScrollControl
   * @param {Function} canScroll - Function that returns whether scrolling is possible
   */
  constructor(canScroll) {
    super();
    this.canScroll = canScroll;
    
    // Initialize state
    this.reset();
    
    // Set up scroll handler
    const onScroll = _.throttle(this._onScroll.bind(this), 50);
    
    if (window.addEventListener) {
      document.addEventListener("DOMMouseScroll", onScroll, false);
    }
    document.onmousewheel = onScroll;
    
    // Bind methods
    this.reset = this.reset.bind(this);
    this._onScroll = this._onScroll.bind(this);
    this._move = this._move.bind(this);
    this._overThreshod = this._overThreshod.bind(this);
    this._getDelta = this._getDelta.bind(this);
    this._jump = this._jump.bind(this);
    this._triggerJumpEvent = this._triggerJumpEvent.bind(this);
  }

  /**
   * Reset the scroll position
   */
  reset() {
    this.position = 0;
  }

  /**
   * Handle scroll event
   * @param {Event} e - The scroll event
   * @private
   */
  _onScroll(e) {
    const event = e || window.event;
    const delta = this._getDelta(event);
    
    if (this.canScroll(delta < 0)) {
      this._move(delta);
    }
  }

  /**
   * Move the scroll position
   * @param {number} delta - The scroll delta
   * @private
   */
  _move(delta) {
    // Fix for rare NaN case
    if (isNaN(this.position)) {
      this.position = 0;
    }
    
    const oldPosition = this.position;
    this.position += delta;
    const overThreshod = this._overThreshod();
    
    if (overThreshod) {
      this.position = this.position > 0 ? 5 : -5;
    }
    
    if (this.position !== oldPosition) {
      this.trigger('move', this.position);
    }
    
    if (overThreshod) {
      this._jump();
    }
  }

  /**
   * Check if scroll has passed threshold
   * @returns {boolean} - True if passed threshold
   * @private
   */
  _overThreshod() {
    return Math.abs(this.position) >= 5;
  }

  /**
   * Get delta from scroll event
   * @param {Event} event - The scroll event
   * @returns {number} - The scroll delta
   * @private
   */
  _getDelta(event) {
    if (event.wheelDelta) {
      return -event.wheelDelta / 60;
    } else if (event.detail) {
      return event.detail / 2;
    }
    return 0;
  }

  /**
   * Jump to next/previous
   * @private
   */
  _jump() {
    if (!this._jumpFunc) {
      this._jumpFunc = _.throttle(this._triggerJumpEvent, 500);
    }
    this._jumpFunc();
  }

  /**
   * Trigger jump event
   * @private
   */
  _triggerJumpEvent() {
    if (this._overThreshod()) {
      this.trigger('jump', this.position < 0);
      this.reset();
    }
  }
}

// Export to namespace
window.klekr = window.klekr || {};
window.klekr.ScrollControl = ScrollControl;

export default ScrollControl;
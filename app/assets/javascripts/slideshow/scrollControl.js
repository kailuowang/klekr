import { Events } from '../global/backboneHelper';

/**
 * Controls scrolling behavior in the gallery
 * @extends Events
 */
class ScrollControl extends Events {
  /**
   * Creates a new ScrollControl
   * @param {Function} canScroll - Function that determines if scrolling is allowed
   */
  constructor(canScroll) {
    super();
    this.canScroll = canScroll;
    this.reset();
    
    const onScroll = _.throttle(this._onScroll, 50);
    
    if (window.addEventListener) {
      document.addEventListener("DOMMouseScroll", onScroll, false);
    }
    document.onmousewheel = onScroll;
  }

  /**
   * Resets the scroll position
   */
  reset = () => {
    this.position = 0;
  }

  /**
   * Handles scroll events
   * @param {Event} e - The scroll event
   * @private
   */
  _onScroll = (e) => {
    const event = e || window.event;
    const delta = this._getDelta(event);
    const towardsLeft = delta < 0;
    
    if (this.canScroll(towardsLeft)) {
      this._move(delta);
    }
  }

  /**
   * Moves the scroll position
   * @param {number} delta - The amount to move
   * @private
   */
  _move = (delta) => {
    // Fix for position being NaN in rare cases
    if (isNaN(this.position)) {
      this.position = 0;
    }
    
    const oldPosition = this.position;
    this.position += delta;
    const overThreshold = this._overThreshold();

    if (overThreshold) {
      this.position = (this.position > 0) ? 5 : -5;
    }

    if (this.position !== oldPosition) {
      this.trigger('move', this.position);
    }

    if (overThreshold) {
      this._jump();
    }
  }

  /**
   * Checks if scroll position is over the threshold
   * @returns {boolean} Whether over threshold
   * @private
   */
  _overThreshold = () => {
    return Math.abs(this.position) >= 5;
  }

  /**
   * Gets the delta from scroll event
   * @param {Event} event - The scroll event
   * @returns {number} The scroll delta
   * @private
   */
  _getDelta = (event) => {
    if (event.wheelDelta) {
      return -event.wheelDelta / 60;
    } else if (event.detail) {
      return event.detail / 2;
    }
    return 0;
  }

  /**
   * Triggers jump events when threshold is passed
   * @private
   */
  _jump = () => {
    if (!this.jumpFunc) {
      this.jumpFunc = _.throttle(this._triggerJumpEvent, 500);
    }
    this.jumpFunc();
  }

  /**
   * Triggers the jump event
   * @private
   */
  _triggerJumpEvent = () => {
    if (this._overThreshold()) {
      this.trigger('jump', this.position < 0);
      this.reset();
    }
  }
}

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.ScrollControl = ScrollControl;

export default ScrollControl;
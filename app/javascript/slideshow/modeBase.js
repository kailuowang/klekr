/**
 * Base class for gallery modes (Slide and Grid)
 * Provides common functionality for gallery navigation modes
 */
import Events from '../src/global/events.js';

class ModeBase extends Events {
  constructor(name) {
    super();
    this.name = name;
    
    // Bind methods
    this.active = this.active.bind(this);
    this.shortcuts = this.shortcuts.bind(this);
    this.on = this.on.bind(this);
    this.off = this.off.bind(this);
    this.goToIndex = this.goToIndex.bind(this);
    this.canScroll = this.canScroll.bind(this);
    this.forwardable = this.forwardable.bind(this);
    this.backwardable = this.backwardable.bind(this);
    this.scroll = this.scroll.bind(this);
    this._createShortcuts = this._createShortcuts.bind(this);
    this._createShortcut = this._createShortcut.bind(this);
    this._extraHashInfo = this._extraHashInfo.bind(this);
    
    // Initialize shortcuts
    keyShortcuts.addShortcuts(this.shortcuts());
  }

  /**
   * Check if this mode is currently active
   * @returns {boolean} - True if this mode is active
   */
  active() {
    return gallery.currentMode === this && !gallery.isEmpty();
  }

  /**
   * Get shortcuts for this mode
   * @returns {Array} - Keyboard shortcuts
   */
  shortcuts() {
    if (!this._shortcuts) {
      this._shortcuts = this._createShortcuts();
    }
    return this._shortcuts;
  }

  /**
   * Activate this mode
   */
  on() {
    this.view().switchVisible(true);
    this.trigger('on');
  }

  /**
   * Deactivate this mode
   */
  off() {
    this.view().switchVisible(false);
    this.trigger('off');
  }

  /**
   * Navigate to a specific index
   * @param {number} index - The index to go to
   */
  goToIndex(index) {
    window.location = '#' + `${this.name}-${index}${this._extraHashInfo(index)}`;
  }

  /**
   * Check if scrolling is possible in the given direction
   * @param {boolean} towardsLeft - True for left scroll, false for right
   * @returns {boolean} - Whether scrolling is possible
   */
  canScroll(towardsLeft) {
    if (towardsLeft) {
      return this.backwardable();
    } else {
      return this.forwardable();
    }
  }

  /**
   * Check if forward navigation is possible
   * @returns {boolean} - True if can move forward
   */
  forwardable() {
    return (!this.atTheLast() || gallery.isLoading()) && !gallery.isEmpty();
  }

  /**
   * Check if backward navigation is possible
   * @returns {boolean} - True if can move backward
   */
  backwardable() {
    return !this.atTheBegining();
  }

  /**
   * Scroll in the given direction
   * @param {boolean} towardsLeft - True for left scroll, false for right
   */
  scroll(towardsLeft) {
    if (towardsLeft) {
      this.navigateToPrevious();
    } else {
      this.navigateToNext();
    }
  }

  /**
   * Create keyboard shortcuts based on settings
   * @private
   * @returns {Array} - Array of keyboard shortcuts
   */
  _createShortcuts() {
    return this.shortcutsSettings().map(setting => this._createShortcut(setting));
  }

  /**
   * Create a single keyboard shortcut
   * @private
   * @param {Array} setting - The shortcut setting [key, handler, description]
   * @returns {KeyShortcut} - The created shortcut
   */
  _createShortcut(setting) {
    return new KeyShortcut(
      setting[0], 
      setting[1], 
      setting[2], 
      () => this.active() && !ViewBase.showingPopup
    );
  }

  /**
   * Get extra hash info for the URL (to be overridden)
   * @private
   * @returns {string} - Extra hash info
   */
  _extraHashInfo() {
    return '';
  }
}

// Export to global namespace
window.ModeBase = ModeBase;

export default ModeBase;
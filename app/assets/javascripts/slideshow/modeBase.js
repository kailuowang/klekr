import { Events } from '../global/backboneHelper';
import KeyShortcut from './keyShortcuts';
import ViewBase from '../global/viewBase';

/**
 * Base class for gallery view modes
 * @extends Events
 */
class ModeBase extends Events {
  /**
   * Creates a new ModeBase
   * @param {string} name - The name of the mode
   */
  constructor(name) {
    super();
    this.name = name;
    window.keyShortcuts.addShortcuts(this.shortcuts());
  }

  /**
   * Checks if this mode is active
   * @returns {boolean} Whether the mode is active
   */
  active = () => {
    return window.gallery.currentMode === this && !window.gallery.isEmpty();
  }

  /**
   * Gets keyboard shortcuts for this mode
   * @returns {Array<KeyShortcut>} The shortcuts
   */
  shortcuts = () => {
    if (!this._shortcuts) {
      this._shortcuts = this._createShortcuts();
    }
    return this._shortcuts;
  }

  /**
   * Activates this mode
   */
  on = () => {
    this.view().switchVisible(true);
    this.trigger('on');
  }

  /**
   * Deactivates this mode
   */
  off = () => {
    this.view().switchVisible(false);
    this.trigger('off');
  }

  /**
   * Navigates to a specific index
   * @param {number} index - The index to navigate to
   */
  goToIndex = (index) => {
    window.location = `#${this.name}-${index}${this._extraHashInfo(index)}`;
  }

  /**
   * Checks if scrolling is possible in the specified direction
   * @param {boolean} towardsLeft - Whether scrolling towards left
   * @returns {boolean} Whether scrolling is possible
   */
  canScroll = (towardsLeft) => {
    if (towardsLeft) {
      return this.backwardable();
    } else {
      return this.forwardable();
    }
  }

  /**
   * Checks if forward navigation is possible
   * @returns {boolean} Whether forward navigation is possible
   */
  forwardable = () => {
    return (!this.atTheLast() || window.gallery.isLoading()) && !window.gallery.isEmpty();
  }

  /**
   * Checks if backward navigation is possible
   * @returns {boolean} Whether backward navigation is possible
   */
  backwardable = () => {
    return !this.atTheBegining();
  }

  /**
   * Scrolls in the specified direction
   * @param {boolean} towardsLeft - Whether to scroll towards left
   */
  scroll = (towardsLeft) => {
    if (towardsLeft) {
      this.navigateToPrevious();
    } else {
      this.navigateToNext();
    }
  }

  /**
   * Creates shortcuts for this mode
   * @returns {Array<KeyShortcut>} Created shortcuts
   * @private
   */
  _createShortcuts = () => {
    return this.shortcutsSettings().map(setting => this._createShortcut(setting));
  }

  /**
   * Creates a keyboard shortcut
   * @param {Array} setting - Shortcut settings
   * @returns {KeyShortcut} Created shortcut
   * @private
   */
  _createShortcut = (setting) => {
    return new KeyShortcut(
      setting[0], 
      setting[1], 
      setting[2], 
      () => this.active() && !ViewBase.showingPopup
    );
  }

  /**
   * Gets extra hash information for URLs
   * @returns {string} Extra hash information
   * @private
   */
  _extraHashInfo = () => {
    return '';
  }

  /**
   * Gets the view for this mode - to be implemented by subclasses
   * @abstract
   * @returns {Object} The view
   */
  view() {
    throw new Error('Subclass must implement view method');
  }

  /**
   * Checks if at the beginning - to be implemented by subclasses
   * @abstract
   * @returns {boolean} Whether at the beginning
   */
  atTheBegining() {
    throw new Error('Subclass must implement atTheBegining method');
  }

  /**
   * Checks if at the end - to be implemented by subclasses
   * @abstract
   * @returns {boolean} Whether at the end
   */
  atTheLast() {
    throw new Error('Subclass must implement atTheLast method');
  }

  /**
   * Navigate to the next item - to be implemented by subclasses
   * @abstract
   */
  navigateToNext() {
    throw new Error('Subclass must implement navigateToNext method');
  }

  /**
   * Navigate to the previous item - to be implemented by subclasses
   * @abstract
   */
  navigateToPrevious() {
    throw new Error('Subclass must implement navigateToPrevious method');
  }

  /**
   * Gets shortcut settings - to be implemented by subclasses
   * @abstract
   * @returns {Array} Shortcut settings
   */
  shortcutsSettings() {
    throw new Error('Subclass must implement shortcutsSettings method');
  }
}

// Export for global access (compatibility with existing code)
window.ModeBase = ModeBase;

export default ModeBase;
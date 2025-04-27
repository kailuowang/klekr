/**
 * KeyShortcuts Component
 * Manages keyboard shortcuts for the application
 */
import ViewBase from '../src/global/viewBase.js';
import KeyShortcut from './keyShortcut.js';

class KeyShortcuts extends ViewBase {
  constructor() {
    super();
    
    this.shortcuts = [];
    this._popup = $('#keyShortcuts');
    this._registerHelpPopup();
    this.helpList = $('#shortcuts');
    
    // Add default shortcuts
    this.addShortcuts(new KeyShortcut('k', this._popupHelp.bind(this), 'Show all keyboard shortcuts', this._canShowHelp.bind(this)));
    this.addShortcuts(new KeyShortcut('w', this.toggleFullScreen, 'Go to full screen mode', () => fullScreenApi.supportsFullScreen));
    
    // Bind methods
    this.disable = this.disable.bind(this);
    this.enable = this.enable.bind(this);
    this.addShortcuts = this.addShortcuts.bind(this);
    this._registerClearLock = this._registerClearLock.bind(this);
    this._updateKeys = this._updateKeys.bind(this);
    this._bindKey = this._bindKey.bind(this);
    this._unbindKey = this._unbindKey.bind(this);
    this._registerHelpPopup = this._registerHelpPopup.bind(this);
    this._popupHelp = this._popupHelp.bind(this);
    this._canShowHelp = this._canShowHelp.bind(this);
    this._updateHelp = this._updateHelp.bind(this);
    this._clearLock = this._clearLock.bind(this);
  }

  /**
   * Disable all shortcuts
   */
  disable() {
    $(document).unbind('keydown', this._clearLock);
    this._updateKeys(this._unbindKey);
  }

  /**
   * Enable all shortcuts
   */
  enable() {
    this._updateKeys(this._bindKey);
    
    for (const shortcut of this.shortcuts) {
      this._registerClearLock(shortcut);
    }
  }

  /**
   * Add shortcuts
   * @param {KeyShortcut|Array} shortcuts - Shortcut(s) to add
   */
  addShortcuts(shortcuts) {
    this.disable();
    this.shortcuts = this.shortcuts.concat(shortcuts);
    this.enable();
  }

  /**
   * Register clear lock for a shortcut
   * @param {KeyShortcut} shortcut - The shortcut
   * @private
   */
  _registerClearLock(shortcut) {
    this._bindKey(shortcut, this._clearLock);
  }

  /**
   * Update all shortcuts with an action
   * @param {Function} action - The action to perform
   * @private
   */
  _updateKeys(action) {
    for (const shortcut of this.shortcuts) {
      action(shortcut);
    }
  }

  /**
   * Bind a shortcut to a key
   * @param {KeyShortcut} shortcut - The shortcut
   * @param {Function} toBind - The function to bind (defaults to shortcut's handler)
   * @private
   */
  _bindKey(shortcut, toBind = shortcut.onKeydown) {
    for (const key of shortcut.keys) {
      $(document).bind('keydown', key, toBind);
    }
  }

  /**
   * Unbind a shortcut
   * @param {KeyShortcut} shortcut - The shortcut to unbind
   * @private
   */
  _unbindKey(shortcut) {
    $(document).unbind('keydown', shortcut.onKeydown);
  }

  /**
   * Register help popup
   * @private
   */
  _registerHelpPopup() {
    $('#keyShortcutsLink').click_(this._popupHelp);
    this._popup.find('#close').click_(() => {
      this.closePopup(this._popup);
    });
  }

  /**
   * Show the help popup
   * @private
   */
  _popupHelp() {
    this._updateHelp();
    this.popup(this._popup);
  }

  /**
   * Check if help can be shown
   * @returns {boolean} - True if help can be shown
   * @private
   */
  _canShowHelp() {
    return !this.showing(this._popup);
  }

  /**
   * Update the help display
   * @private
   */
  _updateHelp() {
    this.helpList.empty();
    
    for (const shortcut of this.shortcuts) {
      if (shortcut.enable()) {
        this.helpList.append(
          $('<li>').html(shortcut.text())
        );
      }
    }
  }

  /**
   * Clear the key lock
   * @private
   */
  _clearLock() {
    this.locked = false;
  }
}

// Export to global namespace
window.KeyShortcuts = KeyShortcuts;

export default KeyShortcuts;
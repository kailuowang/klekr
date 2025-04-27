import ViewBase from '../global/viewBase';

/**
 * Represents a single keyboard shortcut
 */
class KeyShortcut {
  /**
   * Creates a new KeyShortcut
   * @param {string|Array<string>} keys - Key(s) that trigger the shortcut
   * @param {Function} func - Function to execute
   * @param {string} desc - Description of the shortcut
   * @param {Function} enable - Function that determines if shortcut is enabled
   */
  constructor(keys, func, desc, enable = () => true) {
    this.keys = keys instanceof Array ? keys : [keys];
    this._func = func;
    this.desc = desc;
    this.enable = enable;
  }

  /**
   * Gets the HTML text representation of the shortcut
   * @returns {string} HTML for displaying the shortcut
   */
  text = () => {
    const keysStrings = this.keys.map(key => this._keyDisplay(key));
    return `${keysStrings.join(', ')} <span class='key-desc'>${this.desc}</span>`;
  }

  /**
   * Formats a key for display
   * @param {string} stringKey - Key to format
   * @returns {string} Formatted key HTML
   * @private
   */
  _keyDisplay = (stringKey) => {
    const keyWithDirection = stringKey
      .replace('up', '↑')
      .replace('down', '↓')
      .replace('left', '←')
      .replace('right', '→');
    return `<span class='key-name'>${keyWithDirection}</span>`;
  }

  /**
   * Handles key down event
   * @param {Event} e - Key event
   */
  onKeydown = (e) => {
    if (!window.keyShortcuts.locked) {
      if (this.enable()) {
        this._func(e);
        window.keyShortcuts.locked = true;
      }
    }
  }
}

/**
 * Manages keyboard shortcuts
 * @extends ViewBase
 */
class KeyShortcuts extends ViewBase {
  /**
   * Creates a new KeyShortcuts manager
   */
  constructor() {
    super();
    this.shortcuts = [];
    this._popup = $('#keyShortcuts');
    this._registerHelpPopup();
    this.helpList = $('#shortcuts');
    this.locked = false;
    
    this.addShortcuts(
      new KeyShortcut('k', this._popupHelp, 'Show all keyboard shortcuts', this._canShowHelp)
    );
    this.addShortcuts(
      new KeyShortcut('w', this.toggleFullScreen, 'Go to full screen mode', () => fullScreenApi.supportsFullScreen)
    );
  }

  /**
   * Disables all shortcuts
   */
  disable = () => {
    $(document).unbind('keydown', this._clearLock);
    this._updateKeys(this._unbindKey);
  }

  /**
   * Enables all shortcuts
   */
  enable = () => {
    this._updateKeys(this._bindKey);
    this.shortcuts.forEach(shortcut => {
      this._registerClearLock(shortcut);
    });
  }

  /**
   * Adds shortcuts to the manager
   * @param {KeyShortcut|Array<KeyShortcut>} shortcuts - Shortcuts to add
   */
  addShortcuts = (shortcuts) => {
    this.disable();
    this.shortcuts = this.shortcuts.concat(shortcuts);
    this.enable();
  }

  /**
   * Registers clear lock handler for a shortcut
   * @param {KeyShortcut} shortcut - Shortcut to register
   * @private
   */
  _registerClearLock = (shortcut) => {
    this._bindKey(shortcut, this._clearLock);
  }

  /**
   * Updates all shortcuts with an action
   * @param {Function} action - Action to perform on shortcuts
   * @private
   */
  _updateKeys = (action) => {
    this.shortcuts.forEach(shortcut => {
      action(shortcut);
    });
  }

  /**
   * Binds a shortcut to keyboard events
   * @param {KeyShortcut} shortcut - Shortcut to bind
   * @param {Function} toBind - Function to bind
   * @private
   */
  _bindKey = (shortcut, toBind = shortcut.onKeydown) => {
    shortcut.keys.forEach(key => {
      $(document).bind('keydown', key, toBind);
    });
  }

  /**
   * Unbinds a shortcut from keyboard events
   * @param {KeyShortcut} shortcut - Shortcut to unbind
   * @private
   */
  _unbindKey = (shortcut) => {
    $(document).unbind('keydown', shortcut.onKeydown);
  }

  /**
   * Registers event handlers for the help popup
   * @private
   */
  _registerHelpPopup = () => {
    $('#keyShortcutsLink').click_(this._popupHelp);
    this._popup.find('#close').click_(() => {
      this.closePopup(this._popup);
    });
  }

  /**
   * Shows the help popup
   * @private
   */
  _popupHelp = () => {
    this._updateHelp();
    this.popup(this._popup);
  }

  /**
   * Checks if help can be shown
   * @returns {boolean} Whether help can be shown
   * @private
   */
  _canShowHelp = () => {
    return !this.showing(this._popup);
  }

  /**
   * Updates the help list with current shortcuts
   * @private
   */
  _updateHelp = () => {
    this.helpList.empty();
    this.shortcuts.forEach(shortcut => {
      if (shortcut.enable()) {
        this.helpList.append(
          $('<li>').html(shortcut.text())
        );
      }
    });
  }

  /**
   * Clears the key lock
   * @private
   */
  _clearLock = () => {
    this.locked = false;
  }
}

// Export for global access (compatibility with existing code)
window.KeyShortcut = KeyShortcut;
window.KeyShortcuts = KeyShortcuts;

// Initialize on document ready
$(() => {
  window.keyShortcuts = new KeyShortcuts();
});

export { KeyShortcuts, KeyShortcut };
export default KeyShortcut;
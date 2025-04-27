/**
 * KeyShortcut Class
 * Handles a single keyboard shortcut definition
 */

class KeyShortcut {
  /**
   * Create a new keyboard shortcut
   * @param {string|Array} keys - Key or keys to trigger the shortcut
   * @param {Function} func - Function to execute
   * @param {string} desc - Description of the shortcut
   * @param {Function} enable - Function that returns whether the shortcut is enabled
   */
  constructor(keys, func, desc, enable = () => true) {
    this._func = func;
    this.desc = desc;
    this.enable = enable;
    
    // Ensure keys is an array
    if (!Array.isArray(keys)) {
      this.keys = [keys];
    } else {
      this.keys = keys;
    }
    
    // Bind methods
    this.text = this.text.bind(this);
    this._keyDisplay = this._keyDisplay.bind(this);
    this.onKeydown = this.onKeydown.bind(this);
  }

  /**
   * Get the text representation of the shortcut
   * @returns {string} - HTML string with shortcut description
   */
  text() {
    const keysStrings = this.keys.map(key => this._keyDisplay(key));
    return `${keysStrings.join(', ')} <span class='key-desc'>${this.desc}</span>`;
  }

  /**
   * Format a key for display
   * @param {string} stringKey - The key to format
   * @returns {string} - Formatted HTML string
   * @private
   */
  _keyDisplay(stringKey) {
    // Replace directional arrows with unicode symbols
    const keyWithDirection = stringKey
      .replace('up', '↑')
      .replace('down', '↓')
      .replace('left', '←')
      .replace('right', '→');
    
    return `<span class='key-name'>${keyWithDirection}</span>`;
  }

  /**
   * Handle key down event
   * @param {Event} e - The keydown event
   */
  onKeydown(e) {
    // Ensure only one action is fired per keystroke
    if (!keyShortcuts.locked) {
      if (this.enable()) {
        this._func(e);
        keyShortcuts.locked = true;
      }
    }
  }
}

// Export to global namespace
window.KeyShortcut = KeyShortcut;

export default KeyShortcut;
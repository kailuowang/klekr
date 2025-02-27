/**
 * UserInfo module for managing user information display
 */
import ViewBase from './viewBase.js';

// Create namespace if it doesn't exist
window.klekr = window.klekr || {};

/**
 * Manages user information display in the UI
 * @extends ViewBase
 */
class UserInfo extends ViewBase {
  constructor() {
    super();
    
    // Bind methods
    this.init = this.init.bind(this);
    this._updateFave = this._updateFave.bind(this);
    this._updateNewPictures = this._updateNewPictures.bind(this);
    
    // Set up event listeners
    klekr.Global.broadcaster.bind('picture:faved', () => this._updateFave(1));
    klekr.Global.broadcaster.bind('picture:unfaved', () => this._updateFave(-1));
    klekr.Global.broadcaster.bind('picture:viewed', this._updateNewPictures);
    
    // Cache DOM elements
    this.favedCountLink = $('#user-dropdown #faved-count-link');
    this.newPicturesCountLink = $('#user-dropdown #new-pictures-count-link');
    this.sourcesLink = $('#user-dropdown #sources-link');
  }

  init() {
    klekr.Global.server.get(info_collector_path({id: 'current'}), {}, (data) => {
      this.favedCountLink.text(data.collection);
      this.newPicturesCountLink.text(data.pictures);
      this.sourcesLink.text(data.sources);
      $('#user-dropdown #detail').show();
    });
  }

  _updateFave(num) {
    if (this.favedCountLink) {
      const favedCount = parseInt(this.favedCountLink.text());
      this.favedCountLink.text(favedCount + num);
    }
  }

  _updateNewPictures() {
    const count = parseInt(this.newPicturesCountLink.text());
    this.newPicturesCountLink.text(count - 1);
  }
}

// Create singleton instance
const userInfo = new UserInfo();
const currentCollector = window.klekr.Global?.currentCollector;

// Export to global namespace for compatibility
window.klekr.UserInfo = UserInfo;
window.klekr.Global = window.klekr.Global || {};
window.klekr.Global.userInfo = userInfo;

// Initialize when window loads
$(window).load(function() {
  if (window.klekr.Global && window.klekr.Global.currentCollector) {
    setTimeout(function() {
      userInfo.init();
    }, 2000);
  }
});

// Export for ES modules
export { userInfo, UserInfo, currentCollector };
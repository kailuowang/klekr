import ViewBase from './viewBase';
import { broadcaster } from './broadcaster';
import { server } from './server';

/**
 * User information handler
 * @extends ViewBase
 */
class UserInfo extends ViewBase {
  /**
   * Creates a new UserInfo instance
   */
  constructor() {
    super();
    broadcaster.bind('picture:faved', () => this._updateFave(1));
    broadcaster.bind('picture:unfaved', () => this._updateFave(-1));
    broadcaster.bind('picture:viewed', this._updateNewPictures);
    
    this.favedCountLink = $('#user-dropdown #faved-count-link');
    this.newPicturesCountLink = $('#user-dropdown #new-pictures-count-link');
    this.sourcesLink = $('#user-dropdown #sources-link');
  }

  /**
   * Initializes user information
   */
  init = () => {
    server.get(
      info_collector_path({id: 'current'}), 
      {}, 
      (data) => {
        this.favedCountLink.text(data.collection);
        this.newPicturesCountLink.text(data.pictures);
        this.sourcesLink.text(data.sources);
        $('#user-dropdown #detail').show();
      }
    );
  }

  /**
   * Updates faved count
   * @param {number} num - Amount to change fave count by
   * @private
   */
  _updateFave = (num) => {
    if (this.favedCountLink) {
      const favedCount = parseInt(this.favedCountLink.text());
      this.favedCountLink.text(favedCount + num);
    }
  }

  /**
   * Updates new pictures count
   * @private
   */
  _updateNewPictures = () => {
    const count = parseInt(this.newPicturesCountLink.text());
    this.newPicturesCountLink.text(count - 1);
  }
}

// Initialize on window load
$(window).load(() => {
  if (window.klekr && window.klekr.Global && window.klekr.Global.currentCollector) {
    setTimeout(() => {
      new UserInfo().init();
    }, 2000);
  }
});

// Reference to the current collector
export const currentCollector = window.klekr?.Global?.currentCollector;

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.UserInfo = UserInfo;

export { UserInfo };
export default UserInfo;
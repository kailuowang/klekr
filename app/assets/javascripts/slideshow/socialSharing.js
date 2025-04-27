/**
 * Social Sharing Component
 * Handles sharing functionality for pictures
 */
import ViewBase from '../src/global/viewBase.js';

class SocialSharing extends ViewBase {
  /**
   * Create a SocialSharing component
   * @param {string} path - The path to share
   * @param {Object} params - Query parameters to include
   */
  constructor(path, params = {}) {
    super();
    this.path = path;
    this.params = params;
    
    // Find share link
    if (!this._shareLink) {
      this._shareLink = $('#top-banner-left .addthis_toolbox[data-dynamic-url="true"]');
    }
    
    // Set up if available
    if (this.updatable()) {
      this.update();
      $(window).bind('hashchange', this.update);
    }
    
    // Bind methods
    this.updatable = this.updatable.bind(this);
    this.update = this.update.bind(this);
    this._url = this._url.bind(this);
  }

  /**
   * Check if sharing can be updated
   * @returns {boolean} - True if updatable
   */
  updatable() {
    return this._shareLink.length > 0;
  }

  /**
   * Update the share links
   */
  update() {
    if (this.updatable()) {
      const url = this._url();
      this._shareLink.attr({'addthis:url': url});
      
      // Only reload if addthis is already loaded
      if (typeof addthis !== 'undefined') {
        addthis.update('share', 'url', url);
      }
    }
  }

  /**
   * Get the URL to share
   * @returns {string} - The URL
   * @private
   */
  _url() {
    const search = _.isEmpty(this.params) ? '' : '?' + $.param(this.params);
    return window.location.hostname + `${this.path}${search}#${$.param.fragment()}`;
  }
}

// Export to namespace
window.klekr = window.klekr || {};
window.klekr.SocialSharing = SocialSharing;

export default SocialSharing;
/**
 * Gallery Control Panel Component
 * Handles the control panel for gallery settings and operations
 */
import ViewBase from '../src/global/viewBase.js';

class GalleryControlPanel extends ViewBase {
  /**
   * Create a gallery control panel
   * @param {Gallery} gallery - The gallery to control
   */
  constructor(gallery) {
    super();
    this.gallery = gallery;
    
    // Initialize DOM elements
    this.optionButton = $('.gallery-option');
    this.panel = $('#slide-options');
    this.loadingIndicator = this.panel.find('#loading');
    this.downloadButton = $('#download-pictures');
    
    // Set up event handlers
    this.optionButton.click(() => this.panel.toggle());
    this.panel.find('.close-btn').click_(() => this.panel.hide());
    this.downloadButton.click_(this._downloadPictures);
    
    // Initialize collapsible panel
    new CollapsiblePanel(
      $('#under-the-hood-panel'), 
      $('#under-the-hood'), 
      ['Go Offline ▼', 'Hide ▲']
    );
    
    // Set up broadcasters
    klekr.Global.broadcaster.on('picture:fully-ready', this._updateGalleryInfo.bind(this));
    klekr.Global.broadcaster.on('picture:viewed', this._updateGalleryInfo.bind(this));
    
    // Gallery event handlers
    this.gallery.on('idle', this._showDownloadButton.bind(this));
    
    // Update connection status
    this._updateConnectionStatus();
    klekr.Global.server.on('connection-status-changed', this._updateConnectionStatus.bind(this));
    
    // Bind methods
    this._downloadPictures = this._downloadPictures.bind(this);
    this._showDownloadButton = this._showDownloadButton.bind(this);
    this._updateGalleryInfo = this._updateGalleryInfo.bind(this);
    this._updateConnectionStatus = this._updateConnectionStatus.bind(this);
  }

  /**
   * Download more pictures
   * @private
   */
  _downloadPictures() {
    this.gallery.increaseCacheSize(20);
    this.loadingIndicator.show();
    this.downloadButton.hide();
  }

  /**
   * Show the download button
   * @private
   */
  _showDownloadButton() {
    this._updateGalleryInfo();
    this.loadingIndicator.hide();
    this.downloadButton.show();
  }

  /**
   * Update gallery information display
   * @private
   */
  _updateGalleryInfo() {
    // Initialize labels if needed
    if (!this.numLabel) {
      this.numLabel = $('#num-of-pics-in-cache');
    }
    
    if (!this.numNewLabel) {
      this.numNewLabel = $('#num-of-new-pics-in-cache');
    }
    
    if (!this.numDownloadingLabel) {
      this.numDownloadingLabel = $('#num-of-downloading-pics');
    }
    
    // Update display
    const numOfReadyPictures = this.gallery.readyPictures().length;
    this.numNewLabel.text(this.gallery.readyNewPictures().length);
    this.numLabel.text(numOfReadyPictures);
    
    const downloading = this.gallery.size() - numOfReadyPictures;
    this.numDownloadingLabel.text(downloading);
    
    // Show/hide downloading info
    if (!this.downloadingInfo) {
      this.downloadingInfo = $('#downloading-info');
    }
    this.setVisible(this.downloadingInfo, downloading > 0);
  }

  /**
   * Update connection status display
   * @private
   */
  _updateConnectionStatus() {
    if (!this.statusLabel) {
      this.statusLabel = this.panel.find('#connection-status-label');
    }
    
    const online = klekr.Global.server.onLine();
    const status = online ? 'Online' : 'Offline';
    this.statusLabel.text(status);
    this.setVisible(this.downloadButton, online);
  }
}

// Export to global namespace
window.GalleryControlPanel = GalleryControlPanel;

export default GalleryControlPanel;
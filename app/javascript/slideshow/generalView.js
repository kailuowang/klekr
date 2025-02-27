/**
 * General View Component
 * Handles the general layout and navigation UI
 */
import ViewBase from '../src/global/viewBase.js';

class GeneralView extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
    this._leftArrow = $('#leftArrow');
    this._rightArrow = $('#rightArrow');
    this._indicator = $('#indicator');
    this._indicatorPanel = $('#mode-indicator');
    this.bottomLeft = $('#bottomLeft');
    this.socialSharing = new klekr.SocialSharing(exhibit_slideshow_path());
    
    // Bind methods
    this.initLayout = this.initLayout.bind(this);
    this.updateNavigation = this.updateNavigation.bind(this);
    this.updateModeIndicator = this.updateModeIndicator.bind(this);
    this.showEmptyGalleryMessage = this.showEmptyGalleryMessage.bind(this);
    this.updateShareLink = this.updateShareLink.bind(this);
    this.inidicateScroll = this.inidicateScroll.bind(this);
    this._resetScorllIndication = this._resetScorllIndication.bind(this);
    this._updateDimensions = this._updateDimensions.bind(this);
    this._adjustArrowsPosition = this._adjustArrowsPosition.bind(this);
    this._adjustFrames = this._adjustFrames.bind(this);
    this._initFullScreenButton = this._initFullScreenButton.bind(this);
    this._updateFullScreenButton = this._updateFullScreenButton.bind(this);
    this._updateFullScreenLayout = this._updateFullScreenLayout.bind(this);
    this._isFullScreenMobile = this._isFullScreenMobile.bind(this);
    
    // Initialize
    this._initFullScreenButton();
    $(window).resize(_.debounce(this.initLayout, 500));
    this.initLayout();
  }

  /**
   * Initialize the layout
   * Updates dimensions and adjusts UI elements
   */
  initLayout() {
    if (this._updateDimensions()) {
      this._adjustArrowsPosition();
      this._adjustFrames();
      this._updateFullScreenButton();
      this._updateFullScreenLayout();
      this.trigger('layout-changed');
    }
  }

  /**
   * Update the navigation controls
   * @param {boolean} forwardable - Whether forward navigation is available
   * @param {boolean} backwardable - Whether backward navigation is available
   */
  updateNavigation(forwardable, backwardable) {
    $('.side-nav').show();
    this.fadeInOut(this._leftArrow, backwardable);
    this.fadeInOut(this._rightArrow, forwardable);
    this._resetScorllIndication();
  }

  /**
   * Update the mode indicator
   * @param {boolean} toGrid - Whether in grid mode
   */
  updateModeIndicator(toGrid) {
    this._indicatorPanel.show();
    this._indicatorPanel.attr('title', toGrid ? 'Show Picture' : 'Show Grid');
    const position = toGrid ? 26 : 0;
    this._indicator.css('left', `${position}px`);
  }

  /**
   * Set up toggle mode click handler
   * @param {Function} listener - The click handler
   */
  toggleModeClick(listener) {
    this._indicatorPanel.click(listener);
  }

  /**
   * Set up next click handler
   * @param {Function} listener - The click handler
   */
  nextClick(listener) {
    $('#right').click(listener);
  }

  /**
   * Show the empty gallery message
   */
  showEmptyGalleryMessage() {
    $('#empty-gallery-message').show();
  }

  /**
   * Set up previous click handler
   * @param {Function} listener - The click handler
   */
  previousClick(listener) {
    $('#left').click(listener);
  }

  /**
   * Update the share link
   * @param {Object} filterSettings - Filter settings to include in the share
   */
  updateShareLink(filterSettings = {}) {
    if (this.socialSharing.updatable()) {
      this.socialSharing.path = exhibit_slideshow_path();
      this.socialSharing.params = _.extend(
        { collector_id: klekr.Global.currentCollector.id },
        filterSettings
      );
      this.socialSharing.update();
    }
  }

  /**
   * Indicate scroll position
   * @param {number} position - The scroll position
   */
  inidicateScroll(position) {
    let leftPadding = 10;
    let rightPadding = 10;
    const offset = position * 2;
    
    if (offset < 0) {
      leftPadding = 10 + offset;
    } else {
      rightPadding = 10 - offset;
    }
    
    this._leftArrow.css('padding-left', leftPadding + 'px');
    this._rightArrow.css('padding-right', rightPadding + 'px');
  }

  /**
   * Reset scroll indication
   * @private
   */
  _resetScorllIndication() {
    this.inidicateScroll(0);
  }

  /**
   * Update display dimensions
   * @private
   * @returns {boolean} - Whether dimensions have changed
   */
  _updateDimensions() {
    const [newWidth, newHeight] = this.windowDimension();
    const heightReserve = this._isFullScreenMobile() ? 0 : 93;
    
    // Check if dimensions have changed
    if (this.windowWidth !== newWidth || this.windowHeight !== newHeight) {
      [this.windowWidth, this.windowHeight] = [newWidth, newHeight];
      [this.displayWidth, this.displayHeight] = [this.windowWidth - 80, this.windowHeight - heightReserve];
      return true;
    }
    
    return false;
  }

  /**
   * Adjust arrow positions
   * @private
   */
  _adjustArrowsPosition() {
    const sideArrowHeight = (this.displayHeight - 150) + 'px';
    this._leftArrow.css('line-height', sideArrowHeight);
    this._rightArrow.css('line-height', sideArrowHeight);
  }

  /**
   * Adjust frame positions
   * @private
   */
  _adjustFrames() {
    const bottomOffset = this.displayHeight + 51;
    $('#bottom-banner').css('top', (bottomOffset + 10) + 'px');
    const topLeftWidth = this.windowWidth / 2 + 40;
    $('#top-banner-left').css('max-width', topLeftWidth + 'px');
  }

  /**
   * Initialize the full screen button
   * @private
   */
  _initFullScreenButton() {
    if (!this._fullScreenButton) {
      this._fullScreenButton = $('#full-screen-button');
    }
    
    if (fullScreenApi.supportsFullScreen) {
      this._fullScreenButton.show();
      this._fullScreenButton.click(this.toggleFullScreen);
    }
  }

  /**
   * Update the full screen button text
   * @private
   */
  _updateFullScreenButton() {
    const newTitle = fullScreenApi.isFullScreen() 
      ? 'Exit full screen' 
      : 'Full screen (recommended)';
    this._fullScreenButton.attr('title', newTitle);
  }

  /**
   * Update layout for full screen mode
   * @private
   */
  _updateFullScreenLayout() {
    const isFullScreenMobile = this._isFullScreenMobile();
    const pictureAreaTop = isFullScreenMobile ? "0px" : "60px";
    const bottomLeftBottom = isFullScreenMobile ? "5px" : "10px";
    
    $("#slide #pictureArea").css("top", pictureAreaTop);
    $(".fullscreen-hidden").toggleClass("fullscreen", isFullScreenMobile);
    $("#bottomLeft").css("bottom", bottomLeftBottom);
  }

  /**
   * Check if in full screen mobile mode
   * @private
   * @returns {boolean} - Whether in full screen on mobile
   */
  _isFullScreenMobile() {
    return fullScreenApi.isFullScreen() && this.isMobile();
  }
}

// Export to global namespace for compatibility
window.GeneralView = GeneralView;

export default GeneralView;
/**
 * Slideview Component
 * Handles the single picture view in slideshow mode
 */
import ViewBase from '../src/global/viewBase.js';

class Slideview extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
    this.mainImg = $('#picture');
    this.pictureArea = $('#pictureArea');
    this.slide = $('#slide');
    this.bottomLeft = $('#bottomLeft');
    this.label = new PictureLabel();
    
    // Adjust layout and set up handlers
    this._adjustImageFrame();
    generalView.on('layout-changed', this._adjustImageFrame.bind(this));
    klekr.Global.broadcaster.on('picture:data-updated', this._pictureUpdated.bind(this));
    this.mainImg.load(this._checkImage.bind(this));
    this.mainImg.error(this._checkImage.bind(this));
    
    // Bind methods
    this.display = this.display.bind(this);
    this._pictureUpdated = this._pictureUpdated.bind(this);
    this._fadeInto = this._fadeInto.bind(this);
    this.update = this.update.bind(this);
    this.isShowing = this.isShowing.bind(this);
    this._checkImage = this._checkImage.bind(this);
    this.displayLabel = this.displayLabel.bind(this);
    this._updateLabel = this._updateLabel.bind(this);
    this.pictureClick = this.pictureClick.bind(this);
    this.gotoOwner = this.gotoOwner.bind(this);
    this._adjustImageFrame = this._adjustImageFrame.bind(this);
    this.switchVisible = this.switchVisible.bind(this);
  }

  /**
   * Display a picture
   * @param {Picture} picture - The picture to display
   */
  display(picture) {
    this.picture = picture;
    
    if (this.showing(this.pictureArea)) {
      this.fadeInOut(this.pictureArea, false, () => {
        this._fadeInto();
      });
    } else {
      this._fadeInto();
    }
    
    generalView.updateModeIndicator(false);
  }

  /**
   * Handle picture data updates
   * @param {Picture} picture - The updated picture
   * @private
   */
  _pictureUpdated(picture) {
    if (this.picture && picture.id === this.picture.id) {
      this.update();
    }
  }

  /**
   * Fade in to show the picture
   * @private
   */
  _fadeInto() {
    this.update();
    this.fadeInOut(this.pictureArea, true);
  }

  /**
   * Update the displayed picture
   */
  update() {
    if (this.mainImg.attr('src') !== this.picture.url()) {
      this.mainImg.attr('src', this.picture.url());
    }
    this.mainImg.attr('data-pic-id', this.picture.id);
    this._updateLabel();
  }

  /**
   * Check if the view is showing
   * @returns {boolean} - True if showing
   */
  isShowing() {
    return this.showing(this.mainImg);
  }

  /**
   * Check the loaded image
   * @private
   */
  _checkImage() {
    if (this.picture) {
      this.picture.checkLargeVersionInvalid(this.mainImg[0]);
    }
  }

  /**
   * Display just the label
   */
  displayLabel() {
    if (this.showing(this.pictureArea)) {
      this.fadeInOut(this.pictureArea, false);
    }
    this._updateLabel();
  }

  /**
   * Update the picture label
   * @private
   */
  _updateLabel() {
    this.label.show(this.picture);
  }

  /**
   * Set up picture click handler
   * @param {Function} callback - The click handler
   */
  pictureClick(callback) {
    this.mainImg.click(callback);
  }

  /**
   * Go to the photographer's page
   * @param {boolean} newTab - True to open in a new tab
   */
  gotoOwner(newTab) {
    const ownerUrl = this.label.artistLink.attr('href');
    if (newTab) {
      window.open(ownerUrl, '_blank');
    } else {
      window.location = ownerUrl;
    }
  }

  /**
   * Adjust the image frame dimensions
   * @private
   */
  _adjustImageFrame() {
    const displayHeight = generalView.displayHeight;
    $('#imageFrameInner').css('height', (displayHeight - 40) + 'px');
  }

  /**
   * Switch visibility of slideview
   * @param {boolean} showing - True to show, false to hide
   */
  switchVisible(showing) {
    if (!this.favePanel) {
      this.favePanel = $('#fave-panel');
    }
    
    this.setVisible(this.favePanel, showing);
    this.setVisible(this.slide, showing);
    
    if (!showing) {
      this.setVisible(this.pictureArea, false);
    }
    
    if (showing) {
      this.label.show();
    } else {
      this.label.hide();
    }
  }
}

// Export to global namespace
window.Slideview = Slideview;

export default Slideview;
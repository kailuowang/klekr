import ViewBase from '../global/viewBase';
import PictureLabel from './pictureLabel';

/**
 * View for displaying individual slides
 * @extends ViewBase
 */
class Slideview extends ViewBase {
  /**
   * Creates a new Slideview instance
   */
  constructor() {
    super();
    this.mainImg = $('#picture');
    this.pictureArea = $('#pictureArea');
    this.slide = $('#slide');
    this.bottomLeft = $('#bottomLeft');
    this.label = new PictureLabel();
    this._adjustImageFrame();
    window.generalView.bind('layout-changed', this._adjustImageFrame);
    klekr.Global.broadcaster.bind('picture:data-updated', this._pictureUpdated);
    this.mainImg.load(this._checkImage);
    this.mainImg.error(this._checkImage);
  }

  /**
   * Displays a picture
   * @param {Object} picture - The picture to display
   */
  display = (picture) => {
    this.picture = picture;
    if (this.showing(this.pictureArea)) {
      this.fadeInOut(this.pictureArea, false, () => {
        this._fadeInto();
      });
    } else {
      this._fadeInto();
    }
    window.generalView.updateModeIndicator(false);
  }

  /**
   * Updates the view when picture data is updated
   * @param {Object} picture - The updated picture
   * @private
   */
  _pictureUpdated = (picture) => {
    if (this.picture && picture.id === this.picture.id) {
      this.update();
    }
  }

  /**
   * Fades the current picture into view
   * @private
   */
  _fadeInto = () => {
    this.update();
    this.fadeInOut(this.pictureArea, true);
  }

  /**
   * Updates the view with current picture data
   */
  update() {
    if (this.mainImg.attr('src') !== this.picture.url()) {
      this.mainImg.attr('src', this.picture.url());
    }
    this.mainImg.attr('data-pic-id', this.picture.id);
    this._updateLabel();
  }

  /**
   * Checks if the picture is showing
   * @returns {boolean} Whether the picture is showing
   */
  isShowing = () => {
    return this.showing(this.mainImg);
  }

  /**
   * Checks the image for validity
   * @private
   */
  _checkImage = () => {
    if (this.picture) {
      this.picture.checkLargeVersionInvalid(this.mainImg[0]);
    }
  }

  /**
   * Displays only the label for the picture
   */
  displayLabel = () => {
    if (this.showing(this.pictureArea)) {
      this.fadeInOut(this.pictureArea, false);
    }
    this._updateLabel();
  }

  /**
   * Updates the label for the current picture
   * @private
   */
  _updateLabel = () => {
    this.label.show(this.picture);
  }

  /**
   * Sets click handler for the picture
   * @param {Function} callback - The click handler
   */
  pictureClick = (callback) => {
    this.mainImg.click(callback);
  }

  /**
   * Navigates to the picture owner's page
   * @param {boolean} newTab - Whether to open in a new tab
   */
  gotoOwner = (newTab) => {
    const ownerUrl = this.label.artistLink.attr('href');
    if (newTab) {
      window.open(ownerUrl, '_blank');
    } else {
      window.location = ownerUrl;
    }
  }

  /**
   * Adjusts the image frame dimensions
   * @private
   */
  _adjustImageFrame = () => {
    const displayHeight = window.generalView.displayHeight;
    $('#imageFrameInner').css('height', (displayHeight - 40) + 'px');
  }

  /**
   * Switches visibility of the view
   * @param {boolean} showing - Whether the view should be visible
   */
  switchVisible = (showing) => {
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

// Export for global access (compatibility with existing code)
window.Slideview = Slideview;

export default Slideview;
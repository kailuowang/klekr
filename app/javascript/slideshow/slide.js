/**
 * Slide Mode Component
 * Handles single picture display mode in the gallery
 */
import ModeBase from './modeBase.js';

class Slide extends ModeBase {
  constructor() {
    super('slide');
    
    // Initialize state
    this.reset();
    
    // Initialize components
    this.favePanel = new FavePanel();
    
    // Set up event handlers
    slideview.pictureClick(this.backToGrid.bind(this));
    generalView.on('layout-changed', this._redisplayPicture.bind(this));
    
    // Bind methods
    this.reset = this.reset.bind(this);
    this.currentPicture = this.currentPicture.bind(this);
    this.navigateToNext = this.navigateToNext.bind(this);
    this.navigateToPrevious = this.navigateToPrevious.bind(this);
    this.atTheLast = this.atTheLast.bind(this);
    this.atTheBegining = this.atTheBegining.bind(this);
    this.currentProgress = this.currentProgress.bind(this);
    this.updateProgress = this.updateProgress.bind(this);
    this.backToGrid = this.backToGrid.bind(this);
    this.view = this.view.bind(this);
    this.shortcutsSettings = this.shortcutsSettings.bind(this);
    this._monitorPictureReady = this._monitorPictureReady.bind(this);
    this._redisplayPicture = this._redisplayPicture.bind(this);
    this._extraHashInfo = this._extraHashInfo.bind(this);
    this._displayCurrentPicture = this._displayCurrentPicture.bind(this);
  }

  /**
   * Reset the slide state
   */
  reset() {
    this.currentIndex = 0;
  }

  /**
   * Get the current picture
   * @returns {Picture} - The current picture
   */
  currentPicture() {
    return gallery.pictures[this.currentIndex];
  }

  /**
   * Navigate to the next picture
   * @param {Object} commander - The commander object (optional)
   */
  navigateToNext(commander) {
    this.currentPicture().getViewed();
    
    if (!this.atTheLast()) {
      this.goToIndex(this.currentIndex + 1);
      this.trigger('progressed');
      this.trigger('command-to-navigate', commander);
    }
  }

  /**
   * Navigate to the previous picture
   * @param {Object} commander - The commander object (optional)
   */
  navigateToPrevious(commander) {
    if (!this.atTheBegining()) {
      this.goToIndex(this.currentIndex - 1);
      this.trigger('command-to-navigate', commander);
    }
  }

  /**
   * Check if at the last picture
   * @returns {boolean} - True if at the last picture
   */
  atTheLast() {
    return this.currentIndex === gallery.size() - 1;
  }

  /**
   * Check if at the first picture
   * @returns {boolean} - True if at the first picture
   */
  atTheBegining() {
    return this.currentIndex === 0;
  }

  /**
   * Get the current progress index
   * @returns {number} - The current index
   */
  currentProgress() {
    return this.currentIndex;
  }

  /**
   * Update the progress and display
   * @param {number} progress - The new progress index
   */
  updateProgress(progress) {
    this.currentIndex = progress;
    this._displayCurrentPicture();
  }

  /**
   * Go back to grid mode
   */
  backToGrid() {
    this.currentPicture().getViewed();
    gallery.toggleMode();
  }

  /**
   * Get the view associated with this mode
   * @returns {Object} - The view
   */
  view() {
    return slideview;
  }

  /**
   * Get keyboard shortcut settings
   * @returns {Array} - Keyboard shortcuts settings
   */
  shortcutsSettings() {
    return [
      [['right', 'space'], this.navigateToNext, 'Next picture'],
      ['left', this.navigateToPrevious, 'Previous picture'],
      ['o', slideview.gotoOwner, "Go to photographer's page"],
      ['shift+o', (() => slideview.gotoOwner(true)), "Open photographer's page in new tab"],
      [['g', 'return', 'up'], this.backToGrid, "Go to grid mode"],
      ['l', slideview.label.expand, "Expand picture label"]
    ];
  }

  /**
   * Monitor when a picture becomes ready
   * @param {Picture} picture - The picture to monitor
   * @private
   */
  _monitorPictureReady(picture) {
    picture.on('size-ready', (pic) => {
      if (pic.id === this.currentPicture().id) {
        slideview.display(pic);
      }
    });
  }

  /**
   * Redisplay the current picture (e.g. after layout change)
   * @private
   */
  _redisplayPicture() {
    if (this.active()) {
      const picture = this.currentPicture();
      if (picture && picture.sizeReady) {
        picture.calculateFitVersion();
        slideview.update();
      }
    }
  }

  /**
   * Get extra hash info for the URL
   * @param {number} index - The index
   * @returns {string} - Extra hash info
   * @private
   */
  _extraHashInfo(index) {
    return "-" + gallery.pictures[index].id;
  }

  /**
   * Display the current picture
   * @private
   */
  _displayCurrentPicture() {
    const picture = this.currentPicture();
    
    if (picture.sizeReady) {
      picture.calculateFitVersion();
      slideview.display(picture);
    } else {
      slideview.displayLabel(picture);
      this._monitorPictureReady(picture);
    }
    
    this.favePanel.updateWith(picture);
    this.trigger('progress-changed');
  }
}

// Export to global namespace
window.Slide = Slide;

export default Slide;
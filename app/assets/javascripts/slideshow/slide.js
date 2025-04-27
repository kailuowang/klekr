import ModeBase from './modeBase';
import FavePanel from './favePanel';

/**
 * Slide mode for the gallery
 * @extends ModeBase
 */
class Slide extends ModeBase {
  /**
   * Creates a new Slide instance
   */
  constructor() {
    this.reset();
    this.favePanel = new FavePanel();
    window.slideview.pictureClick(this.backToGrid);
    window.generalView.bind('layout-changed', this._redisplayPicture);
    super('slide');
  }

  /**
   * Resets the slide mode
   */
  reset = () => {
    this.currentIndex = 0;
  }

  /**
   * Gets the current picture
   * @returns {Object} The current picture
   */
  currentPicture = () => {
    return window.gallery.pictures[this.currentIndex];
  }

  /**
   * Navigates to the next picture
   * @param {string} commander - The source of the command
   */
  navigateToNext = (commander) => {
    this.currentPicture().getViewed();
    if (!this.atTheLast()) {
      this.goToIndex((this.currentIndex + 1));
      this.trigger('progressed');
      this.trigger('command-to-navigate', commander);
    }
  }

  /**
   * Navigates to the previous picture
   * @param {string} commander - The source of the command
   */
  navigateToPrevious = (commander) => {
    if (!this.atTheBegining()) {
      this.goToIndex((this.currentIndex - 1));
      this.trigger('command-to-navigate', commander);
    }
  }

  /**
   * Checks if at the last picture
   * @returns {boolean} Whether at the last picture
   */
  atTheLast = () => {
    return this.currentIndex === window.gallery.size() - 1;
  }

  /**
   * Checks if at the first picture
   * @returns {boolean} Whether at the first picture
   */
  atTheBegining = () => {
    return this.currentIndex === 0;
  }

  /**
   * Gets the current progress (index)
   * @returns {number} The current index
   */
  currentProgress = () => {
    return this.currentIndex;
  }

  /**
   * Updates the progress (index)
   * @param {number} progress - The new index
   */
  updateProgress = (progress) => {
    this.currentIndex = progress;
    this._displayCurrentPicture();
  }

  /**
   * Returns to grid mode
   */
  backToGrid = () => {
    this.currentPicture().getViewed();
    window.gallery.toggleMode();
  }

  /**
   * Gets the view for this mode
   * @returns {Object} The slideview
   */
  view() {
    return window.slideview;
  }

  /**
   * Gets shortcut settings for this mode
   * @returns {Array} Shortcut settings
   */
  shortcutsSettings() {
    return [
      [['right', 'space'], this.navigateToNext, 'Next picture'],
      ['left', this.navigateToPrevious, 'Previous picture'],
      ['o', window.slideview.gotoOwner, "Go to photographer's page"],
      ['shift+o', (() => window.slideview.gotoOwner(true)), "Open photographer's page in new tab"],
      [['g', 'return', 'up'], this.backToGrid, "Go to grid mode"],
      ['l', window.slideview.label.expand, "Expand picture label"]
    ];
  }

  /**
   * Monitors when a picture is ready to display
   * @param {Object} picture - The picture to monitor
   * @private
   */
  _monitorPictureReady = (picture) => {
    picture.bind('size-ready', (pic) => {
      if (pic.id === this.currentPicture().id) {
        window.slideview.display(pic);
      }
    });
  }

  /**
   * Redisplays the current picture (typically after layout changes)
   * @private
   */
  _redisplayPicture = () => {
    if (this.active()) {
      const picture = this.currentPicture();
      if (picture && picture.sizeReady) {
        picture.calculateFitVersion();
        window.slideview.update();
      }
    }
  }

  /**
   * Gets extra hash information for URLs
   * @param {number} index - The index
   * @returns {string} Extra hash information
   * @private
   */
  _extraHashInfo = (index) => {
    return "-" + window.gallery.pictures[index].id;
  }

  /**
   * Displays the current picture
   * @private
   */
  _displayCurrentPicture = () => {
    const picture = this.currentPicture();
    if (picture.sizeReady) {
      picture.calculateFitVersion();
      window.slideview.display(picture);
    } else {
      window.slideview.displayLabel(picture);
      this._monitorPictureReady(picture);
    }
    this.favePanel.updateWith(picture);
    this.trigger('progress-changed');
  }
}

// Export for global access (compatibility with existing code)
window.Slide = Slide;

export default Slide;
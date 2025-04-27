import ModeBase from './modeBase';
import { PictureUtil } from './picture';

/**
 * Grid view mode
 * @extends ModeBase
 */
class Grid extends ModeBase {
  /**
   * Creates a new Grid mode
   */
  constructor() {
    super('grid');
    this.reset();
    window.generalView.bind('layout-changed', this._onLayoutChange);
  }

  /**
   * Resets the grid state
   */
  reset = () => {
    this.selectedIndex = 0;
    this.picturesLoaded = false;
  }

  /**
   * Initializes the grid
   * @param {Gallery} gallery - The gallery instance
   */
  init = (gallery) => {
    gallery.bind('new-pictures-added', (pictures) => {
      pictures.forEach(pic => {
        pic.bind('clicked', this._onPictureSelect);
      });
    });
    
    gallery.bind('pre-reset', () => window.gridview.showLoading());
    gallery.bind('gallery-pictures-changed', this._tryCompleteCurrentPage);
  }

  /**
   * Clears the grid
   */
  clear = () => {
    this.reset();
    this._loadGridview();
  }

  /**
   * Checks if at the last picture
   * @returns {boolean} Whether at the last picture
   */
  atTheLast = () => {
    const [pageStart, pageEnd] = this._currentPageRange();
    return pageEnd === window.gallery.size() - 1;
  }

  /**
   * Checks if at the first picture
   * @returns {boolean} Whether at the first picture
   */
  atTheBegining = () => {
    const [pageStart, pageEnd] = this._currentPageRange();
    return pageStart === 0;
  }

  /**
   * Gets the selected picture
   * @returns {Picture} The selected picture
   */
  selectedPicture = () => {
    return window.gallery.pictures[this.selectedIndex];
  }

  /**
   * Gets the view for this mode
   * @returns {Object} The view
   */
  view() {
    return window.gridview;
  }

  /**
   * Gets the current progress
   * @returns {number} Current progress
   */
  currentProgress = () => {
    return this.selectedIndex;
  }

  /**
   * Updates the progress
   * @param {number} progress - New progress value
   */
  updateProgress = (progress) => {
    const reloadRequired = !this.picturesLoaded || this._isDifferentPage(progress);
    this.selectedIndex = progress;
    
    if (reloadRequired) {
      this._loadGridview();
    } else {
      this._updateHighlight();
    }
  }

  /**
   * Navigates to the next page
   */
  navigateToNext = () => {
    this._markCurrentPageAsViewed();
    
    if (!this._pageIncomplete()) {
      const [pageStart, pageEnd] = this._currentPageRange();
      const newIndex = pageEnd + 1;
      
      if (newIndex < window.gallery.size()) {
        this._changePage(newIndex);
        this.trigger('progressed');
      } else if (window.gallery.isLoading()) {
        window.gridview.showLoading();
        window.gallery.bind('gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady);
      }
    }
  }

  /**
   * Navigates to the previous page
   */
  navigateToPrevious = () => {
    if (!this.atTheBegining()) {
      const [pageStart, pageEnd] = this._currentPageRange();
      this._changePage(pageStart - 1);
    }
  }

  /**
   * Switches to slide mode
   */
  switchToSlide = () => {
    this.goToIndex(this.selectedIndex); // Simply to update history
    window.gallery.toggleMode();
  }

  /**
   * Moves selection up
   */
  moveUp = () => {
    this._tryMoveTo(this.selectedIndex - window.gridview.columns);
  }

  /**
   * Moves selection down
   */
  moveDown = () => {
    this._tryMoveTo(this.selectedIndex + window.gridview.columns);
  }

  /**
   * Moves selection left
   */
  moveLeft = () => {
    this._tryMoveTo(this.selectedIndex - 1, this.navigateToPrevious);
  }

  /**
   * Moves selection right
   */
  moveRight = () => {
    this._tryMoveTo(this.selectedIndex + 1, this.navigateToNext);
  }

  /**
   * Gets keyboard shortcut settings
   * @returns {Array} Shortcut settings
   */
  shortcutsSettings = () => {
    return [
      ['up', this.moveUp, 'Move up'],
      ['right', this.moveRight, 'Move right'],
      ['down', this.moveDown, 'Move down'],
      ['left', this.moveLeft, 'Move left'],
      [['pagedown', 'shift+right'], this.navigateToNext, 'Next page'],
      [['pageup', 'shift+left'], this.navigateToPrevious, 'Previous page'],
      [['return', 'space'], this.switchToSlide, "Go to the selected picture"]
    ];
  }

  /**
   * Loads the grid view with current page pictures
   * @private
   */
  _loadGridview = () => {
    const pictures = this._currentPageOfPictures();
    window.gridview.loadPictures(pictures);
    this.picturesLoaded = true;
    this._updateHighlight();
    this.trigger('progress-changed');
  }

  /**
   * Navigates to the next page when pictures are ready
   * @private
   */
  _navigateToNextPageWhenPicturesReady = () => {
    window.gallery.unbind('gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady);
    
    if (!this.atTheLast()) {
      this.navigateToNext();
    } else {
      this._loadGridview();
    }
  }

  /**
   * Tries to complete the current page if incomplete
   * @private
   */
  _tryCompleteCurrentPage = () => {
    if (this._pageIncomplete()) {
      this._loadGridview();
    }
  }

  /**
   * Changes to a page containing the specified index
   * @param {number} newIndex - Index to navigate to
   * @private
   */
  _changePage = (newIndex) => {
    if (newIndex >= 0 && newIndex < window.gallery.size()) {
      this.goToIndex(newIndex);
    }
  }

  /**
   * Tries to move selection to a new index
   * @param {number} newIndex - Index to move to
   * @param {Function} alternative - Alternative action if move fails
   * @private
   */
  _tryMoveTo = (newIndex, alternative) => {
    const [pageStart, pageEnd] = this._currentPageRange();
    
    if (newIndex >= pageStart && newIndex < pageStart + window.gridview.currentSize()) {
      this.selectedIndex = newIndex;
      this._updateHighlight();
    } else if (alternative) {
      alternative();
    }
  }

  /**
   * Updates the highlighted picture
   * @private
   */
  _updateHighlight = () => {
    if (this._currentPageOfPictures().length > 0) {
      window.gridview.highlightPicture(this.selectedPicture());
    }
  }

  /**
   * Gets the current page range
   * @returns {Array<number>} Start and end indices of current page
   * @private
   */
  _currentPageRange = () => {
    const positionInPage = this.selectedIndex % window.gridview.size;
    const pageStart = this.selectedIndex - positionInPage;
    const pageEnd = Math.min(pageStart + window.gridview.size - 1, window.gallery.size() - 1);
    
    return [pageStart, pageEnd];
  }

  /**
   * Checks if a progress value is on a different page
   * @param {number} progress - Progress value to check
   * @returns {boolean} Whether on a different page
   * @private
   */
  _isDifferentPage = (progress) => {
    const [pageStart, pageEnd] = this._currentPageRange();
    return progress < pageStart || progress > pageEnd;
  }

  /**
   * Handles picture selection
   * @param {Picture} picture - Selected picture
   * @private
   */
  _onPictureSelect = (picture) => {
    this.selectedIndex = picture.index;
    this.switchToSlide();
  }

  /**
   * Checks if the current page is incomplete
   * @returns {boolean} Whether the page is incomplete
   * @private
   */
  _pageIncomplete = () => {
    return window.gridview.currentSize() < window.gridview.size;
  }

  /**
   * Marks all pictures on the current page as viewed
   * @private
   */
  _markCurrentPageAsViewed = () => {
    const pictureUtil = new PictureUtil();
    pictureUtil.allGetViewed(this._currentPageOfPictures());
  }

  /**
   * Handles layout changes
   * @private
   */
  _onLayoutChange = () => {
    const originalRows = window.gridview.rows;
    const originalColumns = window.gridview.columns;
    
    window.gridview.initLayout();
    
    if (originalRows !== window.gridview.rows || originalColumns !== window.gridview.columns) {
      this._loadGridview();
    }
  }

  /**
   * Gets pictures on the current page
   * @returns {Array<Picture>} Pictures on current page
   * @private
   */
  _currentPageOfPictures = () => {
    const [pageStart, pageEnd] = this._currentPageRange();
    return window.gallery.pictures.slice(pageStart, pageEnd + 1);
  }
}

// Export for global access (compatibility with existing code)
window.Grid = Grid;

export default Grid;
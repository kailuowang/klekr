/**
 * Grid Mode Component
 * Handles grid display mode in the gallery
 */
import ModeBase from './modeBase.js';

class Grid extends ModeBase {
  constructor() {
    super('grid');
    
    // Initialize state
    this.reset();
    
    // Set up event handlers
    generalView.on('layout-changed', this._onLayoutChange.bind(this));
    
    // Bind methods
    this.reset = this.reset.bind(this);
    this.init = this.init.bind(this);
    this.clear = this.clear.bind(this);
    this.atTheLast = this.atTheLast.bind(this);
    this.atTheBegining = this.atTheBegining.bind(this);
    this.selectedPicture = this.selectedPicture.bind(this);
    this.view = this.view.bind(this);
    this.currentProgress = this.currentProgress.bind(this);
    this.updateProgress = this.updateProgress.bind(this);
    this.navigateToNext = this.navigateToNext.bind(this);
    this.navigateToPrevious = this.navigateToPrevious.bind(this);
    this.switchToSlide = this.switchToSlide.bind(this);
    this.moveUp = this.moveUp.bind(this);
    this.moveDown = this.moveDown.bind(this);
    this.moveLeft = this.moveLeft.bind(this);
    this.moveRight = this.moveRight.bind(this);
    this.shortcutsSettings = this.shortcutsSettings.bind(this);
    this._loadGridview = this._loadGridview.bind(this);
    this._navigateToNextPageWhenPicturesReady = this._navigateToNextPageWhenPicturesReady.bind(this);
    this._tryCompleteCurrentPage = this._tryCompleteCurrentPage.bind(this);
    this._changePage = this._changePage.bind(this);
    this._tryMoveTo = this._tryMoveTo.bind(this);
    this._updateHighlight = this._updateHighlight.bind(this);
    this._currentPageRange = this._currentPageRange.bind(this);
    this._isDifferentPage = this._isDifferentPage.bind(this);
    this._onPictureSelect = this._onPictureSelect.bind(this);
    this._pageIncomplete = this._pageIncomplete.bind(this);
    this._markCurrentPageAsViewed = this._markCurrentPageAsViewed.bind(this);
    this._onLayoutChange = this._onLayoutChange.bind(this);
    this._currentPageOfPictures = this._currentPageOfPictures.bind(this);
  }

  /**
   * Reset the grid state
   */
  reset() {
    this.selectedIndex = 0;
    this.picturesLoaded = false;
  }

  /**
   * Initialize with the gallery
   * @param {Gallery} gallery - The gallery
   */
  init(gallery) {
    gallery.on('new-pictures-added', (pictures) => {
      for (const pic of pictures) {
        pic.on('clicked', this._onPictureSelect);
      }
    });
    
    gallery.on('pre-reset', () => gridview.showLoading());
    gallery.on('gallery-pictures-changed', this._tryCompleteCurrentPage);
  }

  /**
   * Clear the grid
   */
  clear() {
    this.reset();
    this._loadGridview();
  }

  /**
   * Check if at the last page
   * @returns {boolean} - True if at the last page
   */
  atTheLast() {
    const [pageStart, pageEnd] = this._currentPageRange();
    return pageEnd === gallery.size() - 1;
  }

  /**
   * Check if at the first page
   * @returns {boolean} - True if at the beginning
   */
  atTheBegining() {
    const [pageStart, pageEnd] = this._currentPageRange();
    return pageStart === 0;
  }

  /**
   * Get the selected picture
   * @returns {Picture} - The selected picture
   */
  selectedPicture() {
    return gallery.pictures[this.selectedIndex];
  }

  /**
   * Get the view
   * @returns {Object} - The view
   */
  view() {
    return gridview;
  }

  /**
   * Get the current progress
   * @returns {number} - The current index
   */
  currentProgress() {
    return this.selectedIndex;
  }

  /**
   * Update the progress
   * @param {number} progress - The new progress index
   */
  updateProgress(progress) {
    const reloadRequired = !this.picturesLoaded || this._isDifferentPage(progress);
    this.selectedIndex = progress;
    
    if (reloadRequired) {
      this._loadGridview();
    } else {
      this._updateHighlight();
    }
  }

  /**
   * Navigate to the next page
   */
  navigateToNext() {
    this._markCurrentPageAsViewed();
    
    if (!this._pageIncomplete()) {
      const [pageStart, pageEnd] = this._currentPageRange();
      const newIndex = pageEnd + 1;
      
      if (newIndex < gallery.size()) {
        this._changePage(newIndex);
        this.trigger('progressed');
      } else if (gallery.isLoading()) {
        gridview.showLoading();
        gallery.on('gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady);
      }
    }
  }

  /**
   * Navigate to the previous page
   */
  navigateToPrevious() {
    if (!this.atTheBegining()) {
      const [pageStart, pageEnd] = this._currentPageRange();
      this._changePage(pageStart - 1);
    }
  }

  /**
   * Switch to slide mode
   */
  switchToSlide() {
    this.goToIndex(this.selectedIndex); // simply to update history
    gallery.toggleMode();
  }

  /**
   * Move the selection up
   */
  moveUp() {
    this._tryMoveTo(this.selectedIndex - gridview.columns);
  }

  /**
   * Move the selection down
   */
  moveDown() {
    this._tryMoveTo(this.selectedIndex + gridview.columns);
  }

  /**
   * Move the selection left
   */
  moveLeft() {
    this._tryMoveTo(this.selectedIndex - 1, this.navigateToPrevious);
  }

  /**
   * Move the selection right
   */
  moveRight() {
    this._tryMoveTo(this.selectedIndex + 1, this.navigateToNext);
  }

  /**
   * Get keyboard shortcut settings
   * @returns {Array} - Keyboard shortcuts settings
   */
  shortcutsSettings() {
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
   * Load pictures into the grid view
   * @private
   */
  _loadGridview() {
    const pictures = this._currentPageOfPictures();
    gridview.loadPictures(pictures);
    this.picturesLoaded = true;
    this._updateHighlight();
    this.trigger('progress-changed');
  }

  /**
   * Navigate to the next page when pictures are ready
   * @private
   */
  _navigateToNextPageWhenPicturesReady() {
    gallery.off('gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady);
    
    if (!this.atTheLast()) {
      this.navigateToNext();
    } else {
      this._loadGridview();
    }
  }

  /**
   * Try to complete the current page
   * @private
   */
  _tryCompleteCurrentPage() {
    if (this._pageIncomplete()) {
      this._loadGridview();
    }
  }

  /**
   * Change to a new page
   * @param {number} newIndex - The new index
   * @private
   */
  _changePage(newIndex) {
    if (newIndex >= 0 && newIndex < gallery.size()) {
      this.goToIndex(newIndex);
    }
  }

  /**
   * Try to move to a new position in the grid
   * @param {number} newIndex - The new index
   * @param {Function} alternative - Alternative function if can't move
   * @private
   */
  _tryMoveTo(newIndex, alternative) {
    const [pageStart, pageEnd] = this._currentPageRange();
    
    if (newIndex >= pageStart && newIndex < pageStart + gridview.currentSize()) {
      this.selectedIndex = newIndex;
      this._updateHighlight();
    } else if (alternative) {
      alternative();
    }
  }

  /**
   * Update the highlight on the selected picture
   * @private
   */
  _updateHighlight() {
    if (this._currentPageOfPictures().length > 0) {
      gridview.highlightPicture(this.selectedPicture());
    }
  }

  /**
   * Get the current page range
   * @returns {Array} - [pageStart, pageEnd]
   * @private
   */
  _currentPageRange() {
    const positionInPage = this.selectedIndex % gridview.size;
    const pageStart = this.selectedIndex - positionInPage;
    const pageEnd = Math.min(pageStart + gridview.size - 1, gallery.size() - 1);
    return [pageStart, pageEnd];
  }

  /**
   * Check if a progress value is on a different page
   * @param {number} progress - The progress value
   * @returns {boolean} - True if on a different page
   * @private
   */
  _isDifferentPage(progress) {
    const [pageStart, pageEnd] = this._currentPageRange();
    return progress < pageStart || progress > pageEnd;
  }

  /**
   * Handle picture selection
   * @param {Picture} picture - The selected picture
   * @private
   */
  _onPictureSelect(picture) {
    this.selectedIndex = picture.index;
    this.switchToSlide();
  }

  /**
   * Check if the current page is incomplete
   * @returns {boolean} - True if incomplete
   * @private
   */
  _pageIncomplete() {
    return gridview.currentSize() < gridview.size;
  }

  /**
   * Mark all pictures on the current page as viewed
   * @private
   */
  _markCurrentPageAsViewed() {
    new klekr.PictureUtil().allGetViewed(this._currentPageOfPictures());
  }

  /**
   * Handle layout changes
   * @private
   */
  _onLayoutChange() {
    const [originalRows, originalColumns] = [gridview.rows, gridview.columns];
    gridview.initLayout();
    
    if (originalRows !== gridview.rows || originalColumns !== gridview.columns) {
      this._loadGridview();
    }
  }

  /**
   * Get the pictures on the current page
   * @returns {Array} - The pictures
   * @private
   */
  _currentPageOfPictures() {
    const [pageStart, pageEnd] = this._currentPageRange();
    return gallery.pictures.slice(pageStart, pageEnd + 1);
  }
}

// Export to global namespace
window.Grid = Grid;

export default Grid;
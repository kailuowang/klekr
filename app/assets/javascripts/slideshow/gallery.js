import { Events } from '../global/backboneHelper';
import { PictureUtil } from './picture';
import Grid from './grid';
import Slide from './slide';
import PicturePreloader from './picturePreloader';
import PictureRetrieverByOffset from './pictureRetrieverByOffset';
import PictureRetrieverByPage from './pictureRetrieverByPage';
import ScrollControl from './scrollControl';
import AutoPlay from './autoPlay';

/**
 * Main gallery controller that manages pictures and view modes
 * @extends Events
 */
class Gallery extends Events {
  /**
   * Creates a new Gallery instance
   */
  constructor() {
    super();
    this.cacheSize = klekr.Global.defaultGalleryCacheSize || 5;
    this.modes = [new Grid(), new Slide()];
    [this.grid, this.slide] = this.modes;
    
    for (const mode of this.modes) {
      mode.bind('progressed', this._ensurePictureCache);
      mode.bind('progress-changed', this._progressChanged);
    }
    
    this.currentMode = (typeof __gridMode__ !== 'undefined') ? this.grid : this.slide;
    this._updateModeIndicatorInView();
    this.advanceByProgress = __advance_by_progress__; // vs progress by paging
    this.picturePreloader = new PicturePreloader(this);
    
    window.generalView.nextClick(() => this.currentMode.navigateToNext?.());
    window.generalView.previousClick(() => this.currentMode.navigateToPrevious?.());
    window.generalView.toggleModeClick(this.toggleMode);
    
    this.filters = new window.GalleryFilters();
    window.generalView.updateShareLink(this.filters.filterSettings());
    this.filters.bind('changed', this._reinitToGrid);
    this.filters.bind('changed', window.generalView.updateShareLink);
    
    this.autoPlay = new AutoPlay(this.slide);
    this._registerScrollControl();
    new window.GalleryControlPanel(this);
    this._listenHashChange();
    window.generalView.bind('layout-changed', this._preloadOnLayoutChange);
    this.registerTouch();
  }

  /**
   * Registers touch event handlers
   */
  registerTouch = () => {
    $(window).on("swipeleft", () => this.currentMode.navigateToNext());
    $(window).on("swiperight", () => this.currentMode.navigateToPrevious());
  }

  /**
   * Initializes the gallery
   */
  init = () => {
    const [, , requestedPicId] = this._infoFromHash();
    this._reset(requestedPicId);
    this.grid.init(this);
  }

  /**
   * Gets the number of pictures in the gallery
   * @returns {number} Number of pictures
   */
  size = () => {
    return this.pictures ? this.pictures.length : 0;
  }

  /**
   * Checks if the gallery is empty
   * @returns {boolean} Whether the gallery is empty
   */
  isEmpty = () => {
    return this.size() === 0;
  }

  /**
   * Gets the current picture
   * @returns {Object} The current picture
   */
  currentPicture = () => {
    return this.pictures[this._currentProgress()];
  }

  /**
   * Gets the current page number
   * @returns {number} The current page
   */
  currentPage = () => {
    const cp = this.currentPicture();
    if (cp) {
      return this.pageOf(cp);
    } else {
      return 1;
    }
  }

  /**
   * Increases the cache size
   * @param {number} pages - Number of pages to add
   */
  increaseCacheSize = (pages) => {
    this.cacheSize += pages;
    this._ensurePictureCache();
  }

  /**
   * Gets the number of unseen pictures to advance
   * @returns {number} Number of unseen pictures
   */
  advanceOffset = () => {
    return this._unseenPictures().length;
  }

  /**
   * Gets the page number for a picture
   * @param {Object} picture - The picture
   * @returns {number} Page number
   */
  pageOf = (picture) => {
    return Math.floor(picture.index / this.pageSize());
  }

  /**
   * Checks if in grid mode
   * @returns {boolean} Whether in grid mode
   */
  inGrid = () => {
    return this.currentMode === this.grid;
  }

  /**
   * Toggles between grid and slide modes
   */
  toggleMode = () => {
    this._alternativeMode().goToIndex(this._currentProgress());
  }

  /**
   * Gets the page size
   * @returns {number} Page size
   */
  pageSize = () => {
    return window.gridview.size;
  }

  /**
   * Checks if pictures are being loaded
   * @returns {boolean} Whether loading
   */
  isLoading = () => {
    return this.retriever && this.retriever.busy();
  }

  /**
   * Retrieves more pictures
   * @param {number} pages - Number of pages to retrieve
   * @private
   */
  _retrieveMorePictures = (pages = 1) => {
    this.retriever.retrieve(pages);
  }

  /**
   * Resets the gallery
   * @param {string} requestedPicId - Optional picture ID to load
   * @private
   */
  _reset = (requestedPicId) => {
    if (requestedPicId) {
      this.currentMode = this.slide;
    }
    this.trigger('pre-reset');
    this._resetRetriever();
    window.location.hash = '';
    this.autoPlay.pause();
    this.allPicturesRetrieved = false;
    this.blank = true;
    this.picturePreloader.clear();
    this.pictures = [];
    this._alternativeMode().off();
    
    for (const m of this.modes) {
      m.reset();
    }
    
    this.picturePreloader.start();
    
    if (requestedPicId) {
      this.retriever.retrievePic(requestedPicId);
    }
    this._ensurePictureCache();
  }

  /**
   * Resets the picture retriever
   * @private
   */
  _resetRetriever = () => {
    if (this.retriever) {
      this.retriever.reset();
      this.retriever.unbind('batch-retrieved');
      this.retriever.unbind('done-retrieving');
    }

    this.retriever = this._createPictureRetriever();
    this.retriever.bind('batch-retrieved', this._addPictures);
    this.retriever.bind('done-retrieving', this._onRetrieverFinished);
  }

  /**
   * Sets up hash change listener
   * @private
   */
  _listenHashChange = () => {
    $(window).bind('hashchange', (e) => {
      const [mode, index] = this._infoFromHash();
      if (mode && index) {
        this._updateModeAndLocation(mode, index);
      }
    });
  }

  /**
   * Updates the mode and location based on URL hash
   * @param {string} mode - Mode name
   * @param {string} index - Index value
   * @private
   */
  _updateModeAndLocation = (mode, index) => {
    const newIndex = Math.min(parseInt(index), this.size() - 1);
    const newMode = this[mode];
    const modeChanged = newMode !== this.currentMode;
    
    if (modeChanged) {
      this.currentMode.off();
      this.currentMode = newMode;
      this.currentMode.on();
      this._updateModeIndicatorInView();
      this._updateProgressInView();
    }
    
    if (newIndex !== this._currentProgress() || this.blank || modeChanged) {
      this.blank = false;
      this.currentMode.updateProgress(newIndex);
    }
  }

  /**
   * Gets mode and index info from URL hash
   * @returns {Array} Mode and index info
   * @private
   */
  _infoFromHash = () => {
    const hash = $.param.fragment();
    if (hash.length > 0) {
      return hash.split('-');
    } else {
      return [];
    }
  }

  /**
   * Handles progress changes
   * @private
   */
  _progressChanged = () => {
    this._updateProgressInView();
    this.picturePreloader.rePrioritize();
  }

  /**
   * Updates the progress in the view
   * @private
   */
  _updateProgressInView = () => {
    window.generalView.updateNavigation(
      this.currentMode.forwardable(),
      this.currentMode.backwardable()
    );
    
    if (this.scrollControl && this.scrollControl.reset) {
      this.scrollControl.reset();
    }
  }

  /**
   * Gets the alternative mode
   * @returns {Object} Alternative mode
   * @private
   */
  _alternativeMode = () => {
    return (this.currentMode === this.grid) ? this.slide : this.grid;
  }

  /**
   * Handles when more pictures are ready
   * @private
   */
  _morePicturesReady = () => {
    if (this.blank) {
      this._firstBatchOfPicturesReady();
    } else {
      this.trigger('gallery-pictures-changed');
    }
  }

  /**
   * Handles when the first batch of pictures is ready
   * @private
   */
  _firstBatchOfPicturesReady = () => {
    this.currentMode.on();
    this.currentMode.goToIndex(0);
  }

  /**
   * Creates a picture retriever based on settings
   * @returns {Object} Picture retriever
   * @private
   */
  _createPictureRetriever = () => {
    if (this.advanceByProgress) {
      let offsetFn;
      if (!this.filters.filterSettings().viewed) {
        offsetFn = this.advanceOffset;
      }
      return new PictureRetrieverByOffset(this._filterOpts, this.pageSize(), __morePicturesPath__, offsetFn);
    } else {
      return new PictureRetrieverByPage(this._filterOpts, this.pageSize(), __morePicturesPath__);
    }
  }

  /**
   * Updates the mode indicator in the view
   * @private
   */
  _updateModeIndicatorInView = () => {
    window.generalView.updateModeIndicator(this.inGrid());
  }

  /**
   * Ensures the picture cache has enough pictures
   * @private
   */
  _ensurePictureCache = () => {
    if (!this.isLoading()) {
      const needMoreForCache = this.pictures.length - this._currentProgress() < (this.cacheSize * this.pageSize());
      if (needMoreForCache && !this.allPicturesRetrieved) {
        this._retrieveMorePictures();
      } else {
        this.trigger('idle');
      }
    }
  }

  /**
   * Handles when retriever finishes getting pictures
   * @param {number} numOfRetrieved - Number of pictures retrieved
   * @private
   */
  _onRetrieverFinished = (numOfRetrieved) => {
    if (this.isEmpty()) {
      this._emptyGallery();
    } else if (numOfRetrieved > 0) {
      this._ensurePictureCache();
    } else if (numOfRetrieved === 0) {
      this.allPicturesRetrieved = true;
      this.trigger('gallery-pictures-changed');
    }
    this._updateProgressInView();
  }

  /**
   * Handles empty gallery state
   * @private
   */
  _emptyGallery = () => {
    if (this.currentMode.clear) {
      this.currentMode.clear();
    }
    
    if (!this.filters.hasActiveFilter()) {
      this.currentMode.off();
      window.generalView.showEmptyGalleryMessage();
    }
  }

  /**
   * Reinitializes to grid mode
   * @private
   */
  _reinitToGrid = () => {
    this.currentMode = this.grid;
    this._reset();
  }

  /**
   * Gets filter options for picture retrieval
   * @returns {Object} Filter options
   * @private
   */
  _filterOpts = () => {
    const filterSettings = this.filters.filterSettings();
    return _.tap({}, (opts) => {
      if (filterSettings.rating) opts.min_rating = filterSettings.rating;
      if (filterSettings.faveDate) opts.faved_date = filterSettings.faveDate;
      if (filterSettings.faveDateAfter) opts.faved_date_after = filterSettings.faveDateAfter;
      if (filterSettings.type) opts.type = filterSettings.type;
      opts.viewed = filterSettings.viewed;
    });
  }

  /**
   * Adds new pictures to the gallery
   * @param {Array} newPictures - New pictures to add
   * @private
   */
  _addPictures = (newPictures) => {
    const startPosition = this.pictures.length;
    const addedPictures = new PictureUtil().uniqConcat(this.pictures, newPictures);
    
    if (addedPictures.length > 0) {
      let currentIndex = startPosition;
      for (const newPic of addedPictures) {
        newPic.index = currentIndex++;
      }
      
      this.picturePreloader.preload(addedPictures);
      this.trigger('new-pictures-added', addedPictures);
      this._morePicturesReady();
    }
  }

  /**
   * Handles layout changes to preload pictures
   * @private
   */
  _preloadOnLayoutChange = () => {
    const picturesToReload = _(this.pictures).filter((picture) => {
      return picture.sizeReady && !picture.data.viewed;
    });
    this.picturePreloader.preload(picturesToReload);
  }

  /**
   * Gets unseen pictures
   * @returns {Array} Unseen pictures
   * @private
   */
  _unseenPictures = () => {
    return this.pictures.filter(p => !p.data.viewed);
  }

  /**
   * Gets the current progress index
   * @returns {number} Current progress
   * @private
   */
  _currentProgress = () => {
    return this.currentMode.currentProgress();
  }

  /**
   * Gets pictures that are ready to display
   * @returns {Array} Ready pictures
   */
  readyPictures = () => {
    return _(this.pictures).select(p => p.ready);
  }

  /**
   * Gets new pictures that are ready to display
   * @returns {Array} Ready new pictures
   */
  readyNewPictures = () => {
    return _(this.pictures).select(p => p.ready && !p.data.viewed);
  }

  /**
   * Registers scroll control
   * @private
   */
  _registerScrollControl = () => {
    this.scrollControl = new ScrollControl((towardsLeft) => this.currentMode.canScroll(towardsLeft));
    
    this.scrollControl.bind('jump', (towardsLeft) => {
      this.currentMode.scroll(towardsLeft);
    });
    
    this.scrollControl.bind('move', window.generalView.inidicateScroll);
  }

  /**
   * Outputs debug information about the gallery
   */
  report = () => {
    console.debug("cache size: " + this.cacheSize);
    console.debug("pictures in cache: " + this.pictures.length);
    console.debug("pictures preloaded: " + this.readyPictures().length);
    console.debug("current flickr page: " + this.pageToRetrieve);
    console.debug("page size: " + window.gridview.size);
    console.debug("pictures size: " + this.pictures.length);
    console.debug("current progress: " + this._currentProgress());
  }
}

// Document ready initialization
$(document).ready(() => {
  window.keyShortcuts = new window.KeyShortcuts();
  window.generalView = new window.GeneralView();
  window.slideview = new window.Slideview();
  window.gridview = new window.Gridview();
  window.gallery = new Gallery();
  new window.StreamPanel();
});

// Mobile initialization
$(document).bind("mobileinit", () => {
  $.event.special.swipe.horizontalDistanceThreshold = 10;
  $.event.special.swipe.verticalDistanceThreshold = 300;
  $.event.special.swipe.durationThreshold = 2000;
});

// Window load initialization
$(window).load(() => {
  window.gallery.init();
});

// Export for global access (compatibility with existing code)
window.Gallery = Gallery;

export default Gallery;
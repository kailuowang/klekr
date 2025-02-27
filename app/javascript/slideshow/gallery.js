/**
 * Gallery Component
 * Manages the display and interaction with the picture gallery
 */
import Events from '../src/global/events.js';
import './galleryFilters.js';
import './picturePreloader.js';

class Gallery extends Events {
  constructor() {
    super();
    
    // Initialize properties
    this.cacheSize = klekr.Global.defaultGalleryCacheSize || 5;
    [this.grid, this.slide] = this.modes = [new Grid(), new Slide()];
    
    // Set up mode event listeners
    for (const mode of this.modes) {
      mode.on('progressed', this._ensurePictureCache.bind(this));
      mode.on('progress-changed', this._progressChanged.bind(this));
    }
    
    // Set initial mode
    this.currentMode = (typeof __gridMode__ !== 'undefined') ? this.grid : this.slide;
    this._updateModeIndicatorInView();
    
    // Set advance mode
    this.advanceByProgress = (typeof __advance_by_progress__ !== 'undefined') ? __advance_by_progress__ : false;
    
    // Initialize preloader
    this.picturePreloader = new PicturePreloader(this);
    
    // Set up navigation handlers
    generalView.nextClick(() => {
      if (this.currentMode.navigateToNext) this.currentMode.navigateToNext();
    });
    
    generalView.previousClick(() => {
      if (this.currentMode.navigateToPrevious) this.currentMode.navigateToPrevious();
    });
    
    generalView.toggleModeClick(this.toggleMode.bind(this));
    
    // Initialize filters
    this.filters = new GalleryFilters();
    generalView.updateShareLink(this.filters.filterSettings());
    this.filters.on('changed', this._reinitToGrid.bind(this));
    this.filters.on('changed', generalView.updateShareLink);
    
    // Set up components
    this.autoPlay = new AutoPlay(this.slide);
    this._registerScrollControl();
    new GalleryControlPanel(this);
    this._listenHashChange();
    
    // Set up layout change handler
    generalView.on('layout-changed', this._preloadOnLayoutChange.bind(this));
    
    // Register touch events
    this.registerTouch();
    
    // Bind methods
    this.registerTouch = this.registerTouch.bind(this);
    this.init = this.init.bind(this);
    this.size = this.size.bind(this);
    this.isEmpty = this.isEmpty.bind(this);
    this.currentPicture = this.currentPicture.bind(this);
    this.currentPage = this.currentPage.bind(this);
    this.increaseCacheSize = this.increaseCacheSize.bind(this);
    this.advanceOffset = this.advanceOffset.bind(this);
    this.pageOf = this.pageOf.bind(this);
    this.inGrid = this.inGrid.bind(this);
    this.toggleMode = this.toggleMode.bind(this);
    this.pageSize = this.pageSize.bind(this);
    this.isLoading = this.isLoading.bind(this);
    this._retrieveMorePictures = this._retrieveMorePictures.bind(this);
    this._reset = this._reset.bind(this);
    this._resetRetriever = this._resetRetriever.bind(this);
    this._listenHashChange = this._listenHashChange.bind(this);
    this._updateModeAndLocation = this._updateModeAndLocation.bind(this);
    this._infoFromHash = this._infoFromHash.bind(this);
    this._progressChanged = this._progressChanged.bind(this);
    this._updateProgressInView = this._updateProgressInView.bind(this);
    this._alternativeMode = this._alternativeMode.bind(this);
    this._morePicturesReady = this._morePicturesReady.bind(this);
    this._firstBatchOfPicturesReady = this._firstBatchOfPicturesReady.bind(this);
    this._createPictureRetriever = this._createPictureRetriever.bind(this);
    this._updateModeIndicatorInView = this._updateModeIndicatorInView.bind(this);
    this._ensurePictureCache = this._ensurePictureCache.bind(this);
    this._onRetrieverFinished = this._onRetrieverFinished.bind(this);
    this._emptyGallery = this._emptyGallery.bind(this);
    this._reinitToGrid = this._reinitToGrid.bind(this);
    this._filterOpts = this._filterOpts.bind(this);
    this._addPictures = this._addPictures.bind(this);
    this._preloadOnLayoutChange = this._preloadOnLayoutChange.bind(this);
    this._unseenPictures = this._unseenPictures.bind(this);
    this._currentProgress = this._currentProgress.bind(this);
    this.readyPictures = this.readyPictures.bind(this);
    this.readyNewPictures = this.readyNewPictures.bind(this);
    this._registerScrollControl = this._registerScrollControl.bind(this);
    this.report = this.report.bind(this);
  }

  /**
   * Register touch events for mobile
   */
  registerTouch() {
    $(window).on("swipeleft", () => this.currentMode.navigateToNext());
    $(window).on("swiperight", () => this.currentMode.navigateToPrevious());
  }

  /**
   * Initialize the gallery
   */
  init() {
    const [_, __, requestedPicId] = this._infoFromHash();
    this._reset(requestedPicId);
    this.grid.init(this);
  }

  /**
   * Get the number of pictures in the gallery
   * @returns {number} - The picture count
   */
  size() {
    return this.pictures ? this.pictures.length : 0;
  }

  /**
   * Check if the gallery is empty
   * @returns {boolean} - True if empty
   */
  isEmpty() {
    return this.size() === 0;
  }

  /**
   * Get the current picture
   * @returns {Picture} - The current picture
   */
  currentPicture() {
    return this.pictures[this._currentProgress()];
  }

  /**
   * Get the current page number
   * @returns {number} - The page number
   */
  currentPage() {
    const cp = this.currentPicture();
    if (cp) {
      return this.pageOf(cp);
    } else {
      return 1;
    }
  }

  /**
   * Increase the cache size
   * @param {number} pages - Number of pages to add
   */
  increaseCacheSize(pages) {
    this.cacheSize += pages;
    this._ensurePictureCache();
  }

  /**
   * Get the advance offset
   * @returns {number} - The number of unseen pictures
   */
  advanceOffset() {
    return this._unseenPictures().length;
  }

  /**
   * Get the page number for a picture
   * @param {Picture} picture - The picture
   * @returns {number} - The page number
   */
  pageOf(picture) {
    return Math.floor(picture.index / this.pageSize());
  }

  /**
   * Check if in grid mode
   * @returns {boolean} - True if in grid mode
   */
  inGrid() {
    return this.currentMode === this.grid;
  }

  /**
   * Toggle between grid and slide modes
   */
  toggleMode() {
    this._alternativeMode().goToIndex(this._currentProgress());
  }

  /**
   * Get the page size
   * @returns {number} - The page size
   */
  pageSize() {
    return gridview.size;
  }

  /**
   * Check if the gallery is loading
   * @returns {boolean} - True if loading
   */
  isLoading() {
    return this.retriever && this.retriever.busy();
  }

  /**
   * Retrieve more pictures
   * @param {number} pages - Number of pages to retrieve (default: 1)
   * @private
   */
  _retrieveMorePictures(pages = 1) {
    this.retriever.retrieve(pages);
  }

  /**
   * Reset the gallery
   * @param {string} requestedPicId - ID of picture to show (optional)
   * @private
   */
  _reset(requestedPicId) {
    if (requestedPicId) this.currentMode = this.slide;
    
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
    if (requestedPicId) this.retriever.retrievePic(requestedPicId);
    this._ensurePictureCache();
  }

  /**
   * Reset the picture retriever
   * @private
   */
  _resetRetriever() {
    if (this.retriever) {
      this.retriever.reset();
      this.retriever.off('batch-retrieved');
      this.retriever.off('done-retrieving');
    }
    
    this.retriever = this._createPictureRetriever();
    this.retriever.on('batch-retrieved', this._addPictures);
    this.retriever.on('done-retrieving', this._onRetrieverFinished);
  }

  /**
   * Set up hash change listener
   * @private
   */
  _listenHashChange() {
    $(window).bind('hashchange', (e) => {
      const [mode, index] = this._infoFromHash();
      if (mode && index) this._updateModeAndLocation(mode, index);
    });
  }

  /**
   * Update mode and location based on hash
   * @param {string} mode - The mode name
   * @param {string} index - The index value
   * @private
   */
  _updateModeAndLocation(mode, index) {
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
   * Get information from URL hash
   * @returns {Array} - [mode, index, picId]
   * @private
   */
  _infoFromHash() {
    const hash = $.param.fragment();
    if (hash.length > 0) {
      return hash.split('-');
    } else {
      return [];
    }
  }

  /**
   * Handle progress change
   * @private
   */
  _progressChanged() {
    this._updateProgressInView();
    this.picturePreloader.rePrioritize();
  }

  /**
   * Update progress in view
   * @private
   */
  _updateProgressInView() {
    generalView.updateNavigation(
      this.currentMode.forwardable(),
      this.currentMode.backwardable()
    );
    if (this.scrollControl.reset) this.scrollControl.reset();
  }

  /**
   * Get the alternative mode
   * @returns {Object} - The alternative mode
   * @private
   */
  _alternativeMode() {
    return this.currentMode === this.grid ? this.slide : this.grid;
  }

  /**
   * Handle when more pictures are ready
   * @private
   */
  _morePicturesReady() {
    if (this.blank) {
      this._firstBatchOfPicturesReady();
    } else {
      this.trigger('gallery-pictures-changed');
    }
  }

  /**
   * Handle first batch of pictures ready
   * @private
   */
  _firstBatchOfPicturesReady() {
    this.currentMode.on();
    this.currentMode.goToIndex(0);
  }

  /**
   * Create a picture retriever
   * @returns {Object} - The picture retriever
   * @private
   */
  _createPictureRetriever() {
    if (this.advanceByProgress) {
      let offsetFn = null;
      if (!this.filters.filterSettings().viewed) {
        offsetFn = this.advanceOffset.bind(this);
      }
      return new PictureRetrieverByOffset(
        this._filterOpts(), 
        this.pageSize(), 
        __morePicturesPath__, 
        offsetFn
      );
    } else {
      return new PictureRetrieverByPage(
        this._filterOpts(), 
        this.pageSize(), 
        __morePicturesPath__
      );
    }
  }

  /**
   * Update mode indicator in view
   * @private
   */
  _updateModeIndicatorInView() {
    generalView.updateModeIndicator(this.inGrid());
  }

  /**
   * Ensure picture cache has enough pictures
   * @private
   */
  _ensurePictureCache() {
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
   * Handle when the retriever finishes
   * @param {number} numOfRetrieved - Number of pictures retrieved
   * @private
   */
  _onRetrieverFinished(numOfRetrieved) {
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
   * Handle empty gallery
   * @private
   */
  _emptyGallery() {
    if (this.currentMode.clear) this.currentMode.clear();
    if (!this.filters.hasActiveFilter()) {
      this.currentMode.off();
      generalView.showEmptyGalleryMessage();
    }
  }

  /**
   * Reinitialize to grid mode
   * @private
   */
  _reinitToGrid() {
    this.currentMode = this.grid;
    this._reset();
  }

  /**
   * Get filter options
   * @returns {Object} - The filter options
   * @private
   */
  _filterOpts() {
    const filterSettings = this.filters.filterSettings();
    const opts = {};
    
    if (filterSettings.rating) opts.min_rating = filterSettings.rating;
    if (filterSettings.faveDate) opts.faved_date = filterSettings.faveDate;
    if (filterSettings.faveDateAfter) opts.faved_date_after = filterSettings.faveDateAfter;
    if (filterSettings.type) opts.type = filterSettings.type;
    opts.viewed = filterSettings.viewed;
    
    return opts;
  }

  /**
   * Add pictures to the gallery
   * @param {Array} newPictures - The new pictures to add
   * @private
   */
  _addPictures(newPictures) {
    let nextIndex = this.pictures.length;
    const addedPictures = new klekr.PictureUtil().uniqConcat(this.pictures, newPictures);
    
    if (addedPictures.length > 0) {
      for (const newPic of addedPictures) {
        newPic.index = nextIndex++;
      }
      this.picturePreloader.preload(addedPictures);
      this.trigger('new-pictures-added', addedPictures);
      this._morePicturesReady();
    }
  }

  /**
   * Preload pictures on layout change
   * @private
   */
  _preloadOnLayoutChange() {
    const picturesToReload = this.pictures.filter(picture => 
      picture.sizeReady && !picture.data.viewed
    );
    this.picturePreloader.preload(picturesToReload);
  }

  /**
   * Get unseen pictures
   * @returns {Array} - The unseen pictures
   * @private
   */
  _unseenPictures() {
    return gallery.pictures.filter(p => !p.data.viewed);
  }

  /**
   * Get current progress
   * @returns {number} - The current progress
   * @private
   */
  _currentProgress() {
    return this.currentMode.currentProgress();
  }

  /**
   * Get ready pictures
   * @returns {Array} - The ready pictures
   */
  readyPictures() {
    return this.pictures.filter(p => p.ready);
  }

  /**
   * Get ready new pictures
   * @returns {Array} - The ready new pictures
   */
  readyNewPictures() {
    return this.pictures.filter(p => p.ready && !p.data.viewed);
  }

  /**
   * Register scroll control
   * @private
   */
  _registerScrollControl() {
    this.scrollControl = new klekr.ScrollControl(
      (towardsLeft) => this.currentMode.canScroll(towardsLeft)
    );
    
    this.scrollControl.on('jump', (towardsLeft) => {
      this.currentMode.scroll(towardsLeft);
    });
    
    this.scrollControl.on('move', generalView.inidicateScroll);
  }

  /**
   * Output debug information
   */
  report() {
    console.debug("cache size: " + this.cacheSize);
    console.debug("pictures in cache: " + this.pictures.length);
    console.debug("pictures preloaded: " + this.readyPictures().length);
    console.debug("current flickr page: " + this.pageToRetrieve);
    console.debug("page size: " + gridview.size);
    console.debug("pictures size: " + this.pictures.length);
    console.debug("current progress: " + this._currentProgress());
  }
}

// Initialize application when document is ready
$(document).ready(function() {
  window.keyShortcuts = new KeyShortcuts();
  window.generalView = new GeneralView();
  window.slideview = new Slideview();
  window.gridview = new Gridview();
  window.gallery = new Gallery();
  new StreamPanel();
});

// Configure mobile swipe settings
$(document).bind("mobileinit", function() {
  $.event.special.swipe.horizontalDistanceThreshold = 10;
  $.event.special.swipe.verticalDistanceThreshold = 300;
  $.event.special.swipe.durationThreshold = 2000;
});

// Initialize gallery when window loads
$(window).load(function() {
  gallery.init();
});

// Export to global namespace for compatibility
window.Gallery = Gallery;

export default Gallery;
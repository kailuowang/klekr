import { Events } from '../global/backboneHelper';
import { broadcaster } from '../global/broadcaster';
import { server } from '../global/server';
import { updater } from '../global/updater';

/**
 * Represents a picture in the slideshow
 * @extends Events
 */
class Picture extends Events {
  /**
   * Creates a new Picture
   * @param {Object} data - Picture data from the server
   */
  constructor(data) {
    super();
    this.data = data;
    this.id = this.data.id;
    _.defaults(this, this.data);
    this.width = 640;
    this.sizeReady = false || this.data.noLongerValid;
    this.canUseLargeVersion = false;
    this.largeVersionAvailable = true;
    this.canUseMediumVersion = false;
    this.ready = false;
    this.error = false;
    this.index = null;
  }

  /**
   * Gets the appropriate URL based on available sizes
   * @returns {string} The URL for the picture
   */
  url = () => {
    if (this.canUseLargeVersion) {
      return this.data.largeUrl;
    } else if (this.canUseMediumVersion) {
      return this.data.mediumUrl;
    } else {
      return this.data.mediumSmallUrl;
    }
  }

  /**
   * Gets the small URL for the picture
   * @returns {string} The small URL
   */
  smallUrl = () => {
    return this.data.smallUrl;
  }

  /**
   * Checks if the picture can be faved
   * @returns {boolean} Whether the picture can be faved
   */
  favable = () => {
    return this.data.ofCurrentCollector;
  }

  /**
   * Faves the picture
   * @param {number} rating - The rating to give
   */
  fave = (rating) => {
    this.data.rating = rating;
    updater.put(this.data.favePath, { rating: rating });
    this.favedDate = $.format.date(new Date(), 'MMMM d, yyyyy');
    this._broadCastChange();
    this.trigger('faved');
  }

  /**
   * Unfaves the picture
   */
  unfave = () => {
    this.data.rating = 0;
    updater.put(this.data.unfavePath);
    this._broadCastChange();
    this.trigger('unfaved');
  }

  /**
   * Marks the picture as viewed
   */
  getViewed = () => {
    if (this._viewedMarkable()) {
      updater.put(this.data.getViewedPath);
      this._setAsViewed();
    }
  }

  /**
   * Sets the picture as viewed
   * @private
   */
  _setAsViewed = () => {
    this.data.viewed = true;
    this.trigger('viewed');
  }

  /**
   * Checks if the picture can be marked as viewed
   * @returns {boolean} Whether the picture can be marked as viewed
   * @private
   */
  _viewedMarkable = () => {
    return !this.data.viewed && this._inKlekr() && this.data.ofCurrentCollector;
  }

  /**
   * Checks if the picture is faved
   * @returns {boolean} Whether the picture is faved
   */
  faved = () => {
    return this.data.rating > 0;
  }

  /**
   * Preloads the picture
   */
  preload = () => {
    this.preloadSmall(this.preloadFull);
  }

  /**
   * Preloads the small version of the picture
   * @param {Function} callback - Callback function
   */
  preloadSmall = (callback) => {
    this._preloadImage(this.data.smallUrl, (image) => {
      [this.smallWidth, this.smallHeight] = [image.width, image.height];
      if (this.error || this._smallVersionMightBeInvalid(image)) {
        this._updateData();
      }
      if (!this.error) {
        this.calculateFitVersion();
      }
      this.trigger('size-ready');
      if (callback) {
        callback();
      }
    });
  }

  /**
   * Reloads the picture data for the current collector
   */
  reloadForCurrentCollector = () => {
    this._updateData({ skip_flickr_resync: true });
  }

  /**
   * Calculates which version of the picture fits the display
   */
  calculateFitVersion = () => {
    const [largeWidth, largeHeight] = this.guessLargeSize();
    const [mediumWidth, mediumHeight] = this.guessMediumSize();
    this.canUseLargeVersion = this.largeVersionAvailable && this._isSizeFit(largeWidth, largeHeight);
    this.canUseMediumVersion = this._isSizeFit(mediumWidth, mediumHeight);
    this.sizeReady = true;
  }

  /**
   * Checks if a size fits the display
   * @param {number} width - Width to check
   * @param {number} height - Height to check
   * @returns {boolean} Whether the size fits
   * @private
   */
  _isSizeFit = (width, height) => {
    const captionHeight = 20;
    return width < window.generalView.displayWidth && 
           height < window.generalView.displayHeight - captionHeight;
  }

  /**
   * Updates the picture data from the server
   * @param {Object} opts - Options for the update
   * @private
   */
  _updateData = (opts = {}) => {
    if (this._updatable()) {
      this.alreadyUpdated = true;
      server.put(
        resync_picture_path({ id: this.id }), 
        opts, 
        (newData) => {
          if (newData) {
            this.data = newData;
            this.preloadSmall(this._broadCastChange);
          }
        }
      );
    }
  }

  /**
   * Broadcasts that the data has changed
   * @private
   */
  _broadCastChange = () => {
    this.trigger('data-updated');
  }

  /**
   * Checks if the small version might be invalid
   * @param {Image} image - The image to check
   * @returns {boolean} Whether the small version might be invalid
   * @private
   */
  _smallVersionMightBeInvalid = (image) => {
    return image.width === 240 && image.height === 180;
  }

  /**
   * Checks if the picture can be updated
   * @returns {boolean} Whether the picture can be updated
   * @private
   */
  _updatable = () => {
    return window.klekr?.Global?.currentCollector && 
           !this.alreadyUpdated && 
           this._inKlekr();
  }

  /**
   * Checks if the picture is in Klekr
   * @returns {boolean} Whether the picture is in Klekr
   * @private
   */
  _inKlekr = () => {
    return this.data.getViewedPath != null;
  }

  /**
   * Preloads the full version of the picture
   * @param {Function} callback - Callback function
   */
  preloadFull = (callback) => {
    if (!this.error) {
      this._preloadImage(this.url(), (image) => {
        if (!this.checkLargeVersionInvalid(image)) {
          this._updateSize(image);
        }
        if (callback) {
          callback();
        }
      });
    } else if (callback) {
      callback();
    }
  }

  /**
   * Preloads an image
   * @param {string} url - URL of the image to preload
   * @param {Function} onload - Callback function when loaded
   * @private
   */
  _preloadImage = (url, onload) => {
    const image = new Image();
    image.src = url;
    $(image).load(() => {
      this.error = false;
      if (onload) {
        onload(image);
      }
    });
    $(image).error(() => {
      this.error = true;
      if (onload) {
        onload(image);
      }
    });
  }

  /**
   * Updates the size information from a loaded image
   * @param {Image} image - The loaded image
   * @private
   */
  _updateSize = (image) => {
    this.width = image.width;
    this.ready = true;
    this.trigger('fully-ready');
  }

  /**
   * Checks if the large version is invalid
   * @param {Image} image - The loaded image
   * @returns {boolean} Whether the large version is invalid
   */
  checkLargeVersionInvalid = (image) => {
    if (image.src === this.data.largeUrl) {
      if (image.width < 650 && image.height < 650) {
        this.canUseLargeVersion = false;
        this.largeVersionAvailable = false;
        this._preloadImage(this.data.mediumUrl, this._updateSize);
        this.trigger('data-updated');
        return true;
      }
    }
    return false;
  }

  /**
   * Guesses the large size of the picture
   * @returns {Array<number>} Width and height of the large version
   */
  guessLargeSize = () => {
    return this._guessVersionSize(1024);
  }

  /**
   * Guesses the medium size of the picture
   * @returns {Array<number>} Width and height of the medium version
   */
  guessMediumSize = () => {
    return this._guessVersionSize(640);
  }

  /**
   * Guesses the size of a version based on the small version
   * @param {number} versionLongEdge - The long edge size of the version
   * @returns {Array<number>} Width and height of the version
   * @private
   */
  _guessVersionSize = (versionLongEdge) => {
    const longEdge = Math.max(this.smallWidth, this.smallHeight);
    const ratio = versionLongEdge / longEdge;
    return [this.smallWidth * ratio, this.smallHeight * ratio];
  }

  /**
   * Triggers an event
   * @param {string} event - The event name
   */
  trigger = (event) => {
    Events.prototype.trigger.call(this, event, this);
    broadcaster.trigger('picture:' + event, this);
  }
}

/**
 * Utilities for working with pictures
 */
class PictureUtil {
  /**
   * Concatenates new pictures to an array, avoiding duplicates
   * @param {Array<Picture>} original - Original pictures array
   * @param {Array<Picture>} newOnes - New pictures to add
   * @returns {Array<Picture>} Added pictures
   */
  uniqConcat = (original, newOnes) => {
    const h = {};
    original.forEach(p => {
      h[p.id] = 1;
    });
    
    const added = [];
    newOnes.forEach(newP => {
      if (h[newP.id] == null) {
        original.push(newP);
        added.push(newP);
      }
    });
    
    return added;
  }

  /**
   * Marks all pictures as viewed
   * @param {Array<Picture>} pictures - Pictures to mark as viewed
   */
  allGetViewed = (pictures) => {
    const toMarkPictures = pictures.filter(pic => pic._viewedMarkable());
    
    toMarkPictures.forEach(pic => {
      pic._setAsViewed();
    });
    
    if (toMarkPictures.length > 0) {
      const picIds = toMarkPictures.map(pic => pic.id);
      updater.post(all_viewed_pictures_path(), { ids: picIds });
    }
  }
}

// Add to namespace for compatibility with existing code
window.Picture = Picture;
window.klekr = window.klekr || {};
window.klekr.PictureUtil = PictureUtil;

export { Picture, PictureUtil };
export default Picture;
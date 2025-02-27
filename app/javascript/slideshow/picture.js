// Converted from CoffeeScript 
import Events from '../src/global/events';

class Picture extends Events {
  constructor(data) {
    super();
    this.data = data;
    this.id = this.data.id;
    Object.assign(this, this.data);
    this.width = 640;
    this.sizeReady = false || this.data.noLongerValid;
    this.canUseLargeVersion = false;
    this.largeVersionAvailable = true;
    this.canUseMediumVersion = false;
    this.ready = false;
    this.error = false;
    this.index = null;

    // Bind methods
    this.url = this.url.bind(this);
    this.smallUrl = this.smallUrl.bind(this);
    this.favable = this.favable.bind(this);
    this.fave = this.fave.bind(this);
    this.unfave = this.unfave.bind(this);
    this.getViewed = this.getViewed.bind(this);
    this._setAsViewed = this._setAsViewed.bind(this);
    this._viewedMarkable = this._viewedMarkable.bind(this);
    this.faved = this.faved.bind(this);
    this.preload = this.preload.bind(this);
    this.preloadSmall = this.preloadSmall.bind(this);
    this.reloadForCurrentCollector = this.reloadForCurrentCollector.bind(this);
    this.calculateFitVersion = this.calculateFitVersion.bind(this);
    this._isSizeFit = this._isSizeFit.bind(this);
    this._updateData = this._updateData.bind(this);
    this._broadCastChange = this._broadCastChange.bind(this);
    this._smallVersionMightBeInvalid = this._smallVersionMightBeInvalid.bind(this);
    this._updatable = this._updatable.bind(this);
    this._inKlekr = this._inKlekr.bind(this);
    this.preloadFull = this.preloadFull.bind(this);
    this._preloadImage = this._preloadImage.bind(this);
    this._updateSize = this._updateSize.bind(this);
    this.checkLargeVersionInvalid = this.checkLargeVersionInvalid.bind(this);
    this.guessLargeSize = this.guessLargeSize.bind(this);
    this.guessMediumSize = this.guessMediumSize.bind(this);
    this._guessVersionSize = this._guessVersionSize.bind(this);
    this.trigger = this.trigger.bind(this);
  }

  url() {
    if (this.canUseLargeVersion) {
      return this.data.largeUrl;
    } else if (this.canUseMediumVersion) {
      return this.data.mediumUrl;
    } else {
      return this.data.mediumSmallUrl;
    }
  }

  smallUrl() {
    return this.data.smallUrl;
  }

  favable() {
    return this.data.ofCurrentCollector;
  }

  fave(rating) {
    this.data.rating = rating;
    klekr.Global.updater.put(this.data.favePath, {rating: rating});
    this.favedDate = $.format.date(new Date(), 'MMMM d, yyyyy');
    this._broadCastChange();
    this.trigger('faved');
  }

  unfave() {
    this.data.rating = 0;
    klekr.Global.updater.put(this.data.unfavePath);
    this._broadCastChange();
    this.trigger('unfaved');
  }

  getViewed() {
    if (this._viewedMarkable()) {
      klekr.Global.updater.put(this.data.getViewedPath);
      this._setAsViewed();
    }
  }

  _setAsViewed() {
    this.data.viewed = true;
    this.trigger('viewed');
  }

  _viewedMarkable() {
    return !this.data.viewed && this._inKlekr() && this.data.ofCurrentCollector;
  }

  faved() {
    return this.data.rating > 0;
  }

  preload() {
    this.preloadSmall(this.preloadFull);
  }

  preloadSmall(callback) {
    this._preloadImage(this.data.smallUrl, (image) => {
      [this.smallWidth, this.smallHeight] = [image.width, image.height];
      if (this.error || this._smallVersionMightBeInvalid(image)) {
        this._updateData();
      }
      if (!this.error) {
        this.calculateFitVersion();
      }
      this.trigger('size-ready');
      if (callback) callback();
    });
  }

  reloadForCurrentCollector() {
    this._updateData({skip_flickr_resync: true});
  }

  calculateFitVersion() {
    const [largeWidth, largeHeight] = this.guessLargeSize();
    const [mediumWidth, mediumHeight] = this.guessMediumSize();
    this.canUseLargeVersion = this.largeVersionAvailable && this._isSizeFit(largeWidth, largeHeight);
    this.canUseMediumVersion = this._isSizeFit(mediumWidth, mediumHeight);
    this.sizeReady = true;
  }

  _isSizeFit(width, height) {
    const captionHeight = 20;
    return width < generalView.displayWidth && height < generalView.displayHeight - captionHeight;
  }

  _updateData(opts = {}) {
    if (this._updatable()) {
      this.alreadyUpdated = true;
      klekr.Global.server.put(resync_picture_path({id: this.id}), opts, (newData) => {
        if (newData != null) {
          this.data = newData;
          this.preloadSmall(this._broadCastChange);
        }
      });
    }
  }

  _broadCastChange() {
    this.trigger('data-updated');
  }

  _smallVersionMightBeInvalid(image) {
    return image.width === 240 && image.height === 180;
  }

  _updatable() {
    return klekr.Global.currentCollector != null && !this.alreadyUpdated && this._inKlekr();
  }

  _inKlekr() {
    return this.data.getViewedPath != null;
  }

  preloadFull(callback) {
    if (!this.error) {
      this._preloadImage(this.url(), (image) => {
        if (!this.checkLargeVersionInvalid(image)) {
          this._updateSize(image);
        }
        if (callback) callback();
      });
    } else {
      if (callback) callback();
    }
  }

  _preloadImage(url, onload) {
    const image = new Image();
    image.src = url;
    $(image).load(() => {
      this.error = false;
      if (onload) onload(image);
    });
    $(image).error(() => {
      this.error = true;
      if (onload) onload(image);
    });
  }

  _updateSize(image) {
    this.width = image.width;
    this.ready = true;
    this.trigger('fully-ready');
  }

  checkLargeVersionInvalid(image) {
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

  guessLargeSize() {
    return this._guessVersionSize(1024);
  }

  guessMediumSize() {
    return this._guessVersionSize(640);
  }

  _guessVersionSize(versionLongEdge) {
    const longEdge = Math.max(this.smallWidth, this.smallHeight);
    const ratio = versionLongEdge / longEdge;
    return [this.smallWidth * ratio, this.smallHeight * ratio];
  }

  trigger(event) {
    super.trigger(event, this);
    klekr.Global.broadcaster.trigger('picture:' + event, this);
  }
}

// Export to global namespace
window.Picture = Picture;

// Define PictureUtil class
class PictureUtil {
  constructor() {
    this.uniqConcat = this.uniqConcat.bind(this);
    this.allGetViewed = this.allGetViewed.bind(this);
  }

  uniqConcat(original, newOnes) {
    const h = {};
    for (const p of original) {
      h[p.id] = 1;
    }
    
    const added = [];
    for (const newP of newOnes) {
      if (h[newP.id] == null) {
        original.push(newP);
        added.push(newP);
      }
    }
    return added;
  }

  allGetViewed(pictures) {
    const toMarkPictures = pictures.filter(pic => pic._viewedMarkable());
    for (const pic of toMarkPictures) {
      pic._setAsViewed();
    }

    if (toMarkPictures.length > 0) {
      const picIds = toMarkPictures.map(pic => pic.id);
      klekr.Global.updater.post(all_viewed_pictures_path(), {ids: picIds});
    }
  }
}

// Export to namespace
window.klekr = window.klekr || {};
klekr.PictureUtil = PictureUtil;
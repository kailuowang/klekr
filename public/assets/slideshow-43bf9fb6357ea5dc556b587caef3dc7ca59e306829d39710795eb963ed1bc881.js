(function() {
  window.klekr = window.klekr || {};

  window.klekr.Global = window.klekr.Global || {};

  window.klekr.Slideshow = window.klekr.Slideshow || {};

  window.klekr.Sources = window.klekr.Sources || {};

  window.klekr.User = window.klekr.User || {};

  window.Events = window.Events || {
    trigger: function(eventName, data) {
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log("Event triggered: " + eventName) : void 0 : void 0;
    },
    bind: function(eventName, callback) {
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log("Event bound: " + eventName) : void 0 : void 0;
    }
  };

  (function() {
    var userAgent;
    if (typeof jQuery !== 'undefined' && !jQuery.browser) {
      jQuery.browser = {};
      userAgent = navigator.userAgent.toLowerCase();
      jQuery.browser.mozilla = /mozilla/.test(userAgent) && !/webkit/.test(userAgent);
      jQuery.browser.webkit = /webkit/.test(userAgent);
      jQuery.browser.opera = /opera/.test(userAgent);
      return jQuery.browser.msie = /msie/.test(userAgent) || /trident/.test(userAgent);
    }
  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.ModeBase = (function(superClass) {
    extend(ModeBase, superClass);

    function ModeBase(name) {
      this.name = name;
      this._extraHashInfo = bind(this._extraHashInfo, this);
      this._createShortcut = bind(this._createShortcut, this);
      this._createShortcuts = bind(this._createShortcuts, this);
      this.scroll = bind(this.scroll, this);
      this.backwardable = bind(this.backwardable, this);
      this.forwardable = bind(this.forwardable, this);
      this.canScroll = bind(this.canScroll, this);
      this.goToIndex = bind(this.goToIndex, this);
      this.off = bind(this.off, this);
      this.on = bind(this.on, this);
      this.shortcuts = bind(this.shortcuts, this);
      this.active = bind(this.active, this);
      keyShortcuts.addShortcuts(this.shortcuts());
    }

    ModeBase.prototype.active = function() {
      return gallery.currentMode === this && !gallery.isEmpty();
    };

    ModeBase.prototype.shortcuts = function() {
      return this._shortcuts != null ? this._shortcuts : this._shortcuts = this._createShortcuts();
    };

    ModeBase.prototype.on = function() {
      this.view().switchVisible(true);
      return this.trigger('on');
    };

    ModeBase.prototype.off = function() {
      this.view().switchVisible(false);
      return this.trigger('off');
    };

    ModeBase.prototype.goToIndex = function(index) {
      return window.location = '#' + (this.name + "-" + index + (this._extraHashInfo(index)));
    };

    ModeBase.prototype.canScroll = function(towardsLeft) {
      if (towardsLeft) {
        return this.backwardable();
      } else {
        return this.forwardable();
      }
    };

    ModeBase.prototype.forwardable = function() {
      var forward;
      forward = (!this.atTheLast() || gallery.isLoading() || !gallery.allPicturesRetrieved) && !gallery.isEmpty();
      console.log("ModeBase: forwardable check: " + forward + " - atTheLast: " + (this.atTheLast()) + ", isLoading: " + (gallery.isLoading()) + ", allPicturesRetrieved: " + gallery.allPicturesRetrieved);
      return forward;
    };

    ModeBase.prototype.backwardable = function() {
      return !this.atTheBegining();
    };

    ModeBase.prototype.scroll = function(towardsLeft) {
      if (towardsLeft) {
        return this.navigateToPrevious();
      } else {
        return this.navigateToNext();
      }
    };

    ModeBase.prototype._createShortcuts = function() {
      var i, len, ref, results, setting;
      ref = this.shortcutsSettings();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        setting = ref[i];
        results.push(this._createShortcut(setting));
      }
      return results;
    };

    ModeBase.prototype._createShortcut = function(setting) {
      return new KeyShortcut(setting[0], setting[1], setting[2], (function(_this) {
        return function() {
          return _this.active() && !ViewBase.showingPopup;
        };
      })(this));
    };

    ModeBase.prototype._extraHashInfo = function() {
      return '';
    };

    return ModeBase;

  })(Events);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PictureRetriever = (function(superClass) {
    extend(PictureRetriever, superClass);

    function PictureRetriever(_filterOptsFn, pageSize, _retrievePath) {
      this._filterOptsFn = _filterOptsFn;
      this.pageSize = pageSize;
      this._retrievePath = _retrievePath;
      this._onPicturesRetrieved = bind(this._onPicturesRetrieved, this);
      this._retrievePage = bind(this._retrievePage, this);
      this._retry = bind(this._retry, this);
      this._proceed = bind(this._proceed, this);
      this._retrieveOpts = bind(this._retrieveOpts, this);
      this._onWorkerDone = bind(this._onWorkerDone, this);
      this._createWork = bind(this._createWork, this);
      this._createWorks = bind(this._createWorks, this);
      this.retrievePic = bind(this.retrievePic, this);
      this.retrieve = bind(this.retrieve, this);
      this.busy = bind(this.busy, this);
      this.reset = bind(this.reset, this);
      this._retrievedCount = 0;
      this._currentPage = 0;
      this._q = new queffee.Q;
      this._worker = new queffee.Worker(this._q);
      this._worker.start();
      this._worker.onIdle = this._onWorkerDone;
      klekr.Global.server.bind('connection-status-changed', this._retry);
    }

    PictureRetriever.prototype.reset = function() {
      this._q.clear();
      return this._currentPage = 0;
    };

    PictureRetriever.prototype.busy = function() {
      return !this._worker.idle();
    };

    PictureRetriever.prototype.retrieve = function(numOfPages) {
      var j, len, ref, results, work;
      if (numOfPages == null) {
        numOfPages = 1;
      }
      ref = this._createWorks(numOfPages);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        work = ref[j];
        results.push(this._q.enQ(work));
      }
      return results;
    };

    PictureRetriever.prototype.retrievePic = function(picId) {
      return this._q.enQ((function(_this) {
        return function(callback) {
          return klekr.Global.server.get(picture_path({
            id: picId
          }), {}, function(data) {
            _this._onPicturesRetrieved([new Picture(data)]);
            return callback();
          });
        };
      })(this));
    };

    PictureRetriever.prototype._createWorks = function(numOfPages) {
      var i, works;
      console.log("Creating retrieval work for " + numOfPages + " pages, current page: " + this._currentPage);
      works = (function() {
        var j, ref, results;
        results = [];
        for (i = j = 0, ref = numOfPages; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          this._proceed();
          results.push(this._createWork());
        }
        return results;
      }).call(this);
      console.log("Created " + works.length + " work items for pages " + (this._currentPage - numOfPages + 1) + " to " + this._currentPage);
      return works;
    };

    PictureRetriever.prototype._createWork = function() {
      var pageOpts;
      pageOpts = this._pageOpts();
      return (function(_this) {
        return function(callback) {
          return _this._retrievePage(pageOpts, callback);
        };
      })(this);
    };

    PictureRetriever.prototype._onWorkerDone = function() {
      this.trigger('done-retrieving', this._retrievedCount);
      return this._retrievedCount = 0;
    };

    PictureRetriever.prototype._retrieveOpts = function(pageOpts) {
      return $.extend(pageOpts, this._filterOptsFn());
    };

    PictureRetriever.prototype._proceed = function() {
      return this._currentPage++;
    };

    PictureRetriever.prototype._retry = function() {
      if (klekr.Global.server.onLine()) {
        return this._worker.retry();
      }
    };

    PictureRetriever.prototype._retrievePage = function(pageOpts, callback) {
      var retrieveOpts;
      retrieveOpts = this._retrieveOpts(pageOpts);
      console.log("Retrieving page " + pageOpts.page + " with options:", retrieveOpts);
      return klekr.Global.server.get(this._retrievePath, retrieveOpts, (function(_this) {
        return function(data) {
          var picData, pictures;
          if (data != null) {
            pictures = (function() {
              var j, len, results;
              results = [];
              for (j = 0, len = data.length; j < len; j++) {
                picData = data[j];
                results.push(new Picture(picData));
              }
              return results;
            })();
          }
          if ((pictures != null) && pictures.length > 0) {
            console.log("Retrieved " + pictures.length + " pictures from page " + pageOpts.page);
            _this._onPicturesRetrieved(pictures);
          } else {
            console.log("No pictures found on page " + pageOpts.page + ", stopping retrieval");
            _this._q.clear();
            _this._onWorkerDone();
          }
          return callback();
        };
      })(this));
    };

    PictureRetriever.prototype._onPicturesRetrieved = function(pictures) {
      this.trigger('batch-retrieved', pictures);
      return this._retrievedCount += pictures.length;
    };

    return PictureRetriever;

  })(Events);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Picture = (function(superClass) {
    extend(Picture, superClass);

    function Picture(data) {
      this.data = data;
      this.trigger = bind(this.trigger, this);
      this._guessVersionSize = bind(this._guessVersionSize, this);
      this.guessMediumSize = bind(this.guessMediumSize, this);
      this.guessLargeSize = bind(this.guessLargeSize, this);
      this.checkLargeVersionInvalid = bind(this.checkLargeVersionInvalid, this);
      this._updateSize = bind(this._updateSize, this);
      this._preloadImage = bind(this._preloadImage, this);
      this.preloadFull = bind(this.preloadFull, this);
      this._inKlekr = bind(this._inKlekr, this);
      this._updatable = bind(this._updatable, this);
      this._smallVersionMightBeInvalid = bind(this._smallVersionMightBeInvalid, this);
      this._broadCastChange = bind(this._broadCastChange, this);
      this._updateData = bind(this._updateData, this);
      this._isSizeFit = bind(this._isSizeFit, this);
      this.calculateFitVersion = bind(this.calculateFitVersion, this);
      this.reloadForCurrentCollector = bind(this.reloadForCurrentCollector, this);
      this.preloadSmall = bind(this.preloadSmall, this);
      this.preload = bind(this.preload, this);
      this.faved = bind(this.faved, this);
      this._viewedMarkable = bind(this._viewedMarkable, this);
      this._setAsViewed = bind(this._setAsViewed, this);
      this.getViewed = bind(this.getViewed, this);
      this.unfave = bind(this.unfave, this);
      this.fave = bind(this.fave, this);
      this.favable = bind(this.favable, this);
      this.smallUrl = bind(this.smallUrl, this);
      this.url = bind(this.url, this);
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

    Picture.prototype.url = function() {
      if (this.canUseLargeVersion) {
        return this.data.largeUrl;
      } else if (this.canUseMediumVersion) {
        return this.data.mediumUrl;
      } else {
        return this.data.mediumSmallUrl;
      }
    };

    Picture.prototype.smallUrl = function() {
      return this.data.smallUrl;
    };

    Picture.prototype.favable = function() {
      return this.data.ofCurrentCollector;
    };

    Picture.prototype.fave = function(rating) {
      this.data.rating = rating;
      klekr.Global.updater.put(this.data.favePath, {
        rating: rating
      });
      this.favedDate = $.format.date(new Date(), 'MMMM d, yyyyy');
      this._broadCastChange();
      return this.trigger('faved');
    };

    Picture.prototype.unfave = function() {
      this.data.rating = 0;
      klekr.Global.updater.put(this.data.unfavePath);
      this._broadCastChange();
      return this.trigger('unfaved');
    };

    Picture.prototype.getViewed = function() {
      if (this._viewedMarkable()) {
        klekr.Global.updater.put(this.data.getViewedPath);
        return this._setAsViewed();
      }
    };

    Picture.prototype._setAsViewed = function() {
      this.data.viewed = true;
      return this.trigger('viewed');
    };

    Picture.prototype._viewedMarkable = function() {
      return !this.data.viewed && this._inKlekr() && this.data.ofCurrentCollector;
    };

    Picture.prototype.faved = function() {
      return this.data.rating > 0;
    };

    Picture.prototype.preload = function() {
      return this.preloadSmall(this.preloadFull);
    };

    Picture.prototype.preloadSmall = function(callback) {
      return this._preloadImage(this.data.smallUrl, (function(_this) {
        return function(image) {
          var ref;
          ref = [image.width, image.height], _this.smallWidth = ref[0], _this.smallHeight = ref[1];
          if (_this.error || _this._smallVersionMightBeInvalid(image)) {
            _this._updateData();
          }
          if (!_this.error) {
            _this.calculateFitVersion();
          }
          _this.trigger('size-ready');
          return typeof callback === "function" ? callback() : void 0;
        };
      })(this));
    };

    Picture.prototype.reloadForCurrentCollector = function() {
      return this._updateData({
        skip_flickr_resync: true
      });
    };

    Picture.prototype.calculateFitVersion = function() {
      var largeHeight, largeWidth, mediumHeight, mediumWidth, ref, ref1;
      ref = this.guessLargeSize(), largeWidth = ref[0], largeHeight = ref[1];
      ref1 = this.guessMediumSize(), mediumWidth = ref1[0], mediumHeight = ref1[1];
      this.canUseLargeVersion = this.largeVersionAvailable && this._isSizeFit(largeWidth, largeHeight);
      this.canUseMediumVersion = this._isSizeFit(mediumWidth, mediumHeight);
      return this.sizeReady = true;
    };

    Picture.prototype._isSizeFit = function(width, height) {
      var captionHeight;
      captionHeight = 20;
      return width < generalView.displayWidth && height < generalView.displayHeight - captionHeight;
    };

    Picture.prototype._updateData = function(opts) {
      if (opts == null) {
        opts = {};
      }
      if (this._updatable()) {
        this.alreadyUpdated = true;
        return klekr.Global.server.put(resync_picture_path({
          id: this.id
        }), opts, (function(_this) {
          return function(newData) {
            if (newData != null) {
              _this.data = newData;
              return _this.preloadSmall(_this._broadCastChange);
            }
          };
        })(this));
      }
    };

    Picture.prototype._broadCastChange = function() {
      return this.trigger('data-updated');
    };

    Picture.prototype._smallVersionMightBeInvalid = function(image) {
      return image.width === 240 && image.height === 180;
    };

    Picture.prototype._updatable = function() {
      return (klekr.Global.currentCollector != null) && !this.alreadyUpdated && this._inKlekr();
    };

    Picture.prototype._inKlekr = function() {
      return this.data.getViewedPath != null;
    };

    Picture.prototype.preloadFull = function(callback) {
      if (!this.error) {
        return this._preloadImage(this.url(), (function(_this) {
          return function(image) {
            if (!_this.checkLargeVersionInvalid(image)) {
              _this._updateSize(image);
            }
            return typeof callback === "function" ? callback() : void 0;
          };
        })(this));
      } else {
        return typeof callback === "function" ? callback() : void 0;
      }
    };

    Picture.prototype._preloadImage = function(url, onload) {
      var image;
      image = new Image();
      image.src = url;
      $(image).load((function(_this) {
        return function() {
          _this.error = false;
          if (onload != null) {
            return onload(image);
          }
        };
      })(this));
      return $(image).error((function(_this) {
        return function() {
          _this.error = true;
          if (onload != null) {
            return onload(image);
          }
        };
      })(this));
    };

    Picture.prototype._updateSize = function(image) {
      this.width = image.width;
      this.ready = true;
      return this.trigger('fully-ready');
    };

    Picture.prototype.checkLargeVersionInvalid = function(image) {
      if (image.src === this.data.largeUrl) {
        if (image.width < 650 && image.height < 650) {
          this.canUseLargeVersion = false;
          this.largeVersionAvailable = false;
          this._preloadImage(this.data.mediumUrl, this._updateSize);
          this.trigger('data-updated');
          return true;
        }
      }
    };

    Picture.prototype.guessLargeSize = function() {
      return this._guessVersionSize(1024);
    };

    Picture.prototype.guessMediumSize = function() {
      return this._guessVersionSize(640);
    };

    Picture.prototype._guessVersionSize = function(versionLongEdge) {
      var longEdge, ratio;
      longEdge = Math.max(this.smallWidth, this.smallHeight);
      ratio = versionLongEdge / longEdge;
      return [this.smallWidth * ratio, this.smallHeight * ratio];
    };

    Picture.prototype.trigger = function(event) {
      Picture.__super__.trigger.call(this, event, this);
      return klekr.Global.broadcaster.trigger('picture:' + event, this);
    };

    return Picture;

  })(Events);

  klekr.PictureUtil = (function() {
    function PictureUtil() {
      this.allGetViewed = bind(this.allGetViewed, this);
      this.uniqConcat = bind(this.uniqConcat, this);
    }

    PictureUtil.prototype.uniqConcat = function(original, newOnes) {
      var added, h, i, j, len, len1, newP, p;
      h = {};
      for (i = 0, len = original.length; i < len; i++) {
        p = original[i];
        h[p.id] = 1;
      }
      added = [];
      for (j = 0, len1 = newOnes.length; j < len1; j++) {
        newP = newOnes[j];
        if (!(h[newP.id] == null)) {
          continue;
        }
        original.push(newP);
        added.push(newP);
      }
      return added;
    };

    PictureUtil.prototype.allGetViewed = function(pictures) {
      var i, len, pic, picIds, toMarkPictures;
      toMarkPictures = _(pictures).select(function(pic) {
        return pic._viewedMarkable();
      });
      for (i = 0, len = toMarkPictures.length; i < len; i++) {
        pic = toMarkPictures[i];
        pic._setAsViewed();
      }
      if (toMarkPictures.length > 0) {
        picIds = (function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = toMarkPictures.length; j < len1; j++) {
            pic = toMarkPictures[j];
            results.push(pic.id);
          }
          return results;
        })();
        return klekr.Global.updater.post(all_viewed_pictures_path(), {
          ids: picIds
        });
      }
    };

    return PictureUtil;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.PicturePreloader = (function() {
    PicturePreloader.numOfWorkers = 3;

    function PicturePreloader(gallery) {
      this.gallery = gallery;
      this._retry = bind(this._retry, this);
      this._timeout = bind(this._timeout, this);
      this._createJob = bind(this._createJob, this);
      this._createJobs = bind(this._createJobs, this);
      this._createWorkers = bind(this._createWorkers, this);
      this.preload = bind(this.preload, this);
      this.rePrioritize = bind(this.rePrioritize, this);
      this.clear = bind(this.clear, this);
      this.start = bind(this.start, this);
      this.q = new queffee.Q;
      klekr.Global.server.bind('connection-status-changed', this._retry);
    }

    PicturePreloader.prototype.start = function() {
      var j, len, ref, results, worker;
      if (this.workers == null) {
        this.workers = this._createWorkers();
        ref = this.workers;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          worker = ref[j];
          results.push(worker.start());
        }
        return results;
      }
    };

    PicturePreloader.prototype.clear = function() {
      return this.q.clear();
    };

    PicturePreloader.prototype.rePrioritize = function() {
      return this.q.reorder();
    };

    PicturePreloader.prototype.preload = function(pictures) {
      var jobs, limited_pictures, pic, ref;
      limited_pictures = pictures.length > 50 ? pictures.slice(0, 50) : pictures;
      jobs = _((function() {
        var j, len, results;
        results = [];
        for (j = 0, len = limited_pictures.length; j < len; j++) {
          pic = limited_pictures[j];
          if (!pic.noLongerValid) {
            results.push(this._createJobs(pic));
          }
        }
        return results;
      }).call(this)).flatten();
      return (ref = this.q).enqueue.apply(ref, jobs);
    };

    PicturePreloader.prototype._createWorkers = function() {
      var i, j, ref, results;
      results = [];
      for (i = j = 0, ref = PicturePreloader.numOfWorkers; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        results.push(new queffee.Worker(this.q));
      }
      return results;
    };

    PicturePreloader.prototype._createJobs = function(picture) {
      var priority;
      priority = new PicturePreloadPriority(picture, this.gallery);
      return [this._createJob(picture, 'Small', priority), this._createJob(picture, 'Full', priority)];
    };

    PicturePreloader.prototype._createJob = function(picture, size, priority) {
      var preloadFn, priorityFn;
      priorityFn = priority[size.toLowerCase()];
      preloadFn = (function(_this) {
        return function(callback) {
          return picture['preload' + size](callback);
        };
      })(this);
      return new queffee.Job(preloadFn, priorityFn, this._timeout);
    };

    PicturePreloader.prototype._timeout = function() {
      if (klekr.Global.server.onLine()) {
        return 30000;
      } else {
        return null;
      }
    };

    PicturePreloader.prototype._retry = function() {
      var j, len, ref, results, worker;
      if (this.workers != null) {
        ref = this.workers;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          worker = ref[j];
          results.push(worker.retry());
        }
        return results;
      }
    };

    return PicturePreloader;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PictureLabel = (function(superClass) {
    extend(PictureLabel, superClass);

    function PictureLabel() {
      this._updateDescription = bind(this._updateDescription, this);
      this.expand = bind(this.expand, this);
      this._toggleSecondRow = bind(this._toggleSecondRow, this);
      this._updateDom = bind(this._updateDom, this);
      this.hide = bind(this.hide, this);
      this.show = bind(this.show, this);
      this.panel = $('#picture-label');
      this.expandLink = this.panel.find('#expand-link');
      this.expandLink.click(this._toggleSecondRow);
      new CollapsiblePanel(this.panel.find('#collapsible'), this.expandLink, ['[+]', '[-]']);
    }

    PictureLabel.prototype.show = function(picture) {
      if (picture != null) {
        this._updateDom(picture);
      }
      return this.panel.show();
    };

    PictureLabel.prototype.hide = function() {
      return this.panel.hide();
    };

    PictureLabel.prototype._updateDom = function(picture) {
      if (this.artistLink == null) {
        this.artistLink = this.panel.find('#artist-link');
      }
      this.artistLink.attr('href', picture.ownerPath);
      this.artistLink.text(picture.ownerName);
      if (this.titleLink == null) {
        this.titleLink = this.panel.find('#title-link');
      }
      this.titleLink.attr('href', picture.flickrPageUrl);
      this.titleLink.text(picture.data.title);
      if (this.flickrLink == null) {
        this.flickrLink = this.panel.find('#flickr-link');
      }
      this.flickrLink.attr('href', picture.flickrPageUrl);
      this._updateDescription(picture);
      if (this.date == null) {
        this.date = this.panel.find('#title #date');
      }
      this.date.text(picture.dateUpload.substr(0, 7).replace('-', '/'));
      if (this.artistCollectionLink == null) {
        this.artistCollectionLink = this.panel.find('#artist-collection');
      }
      this.setArtistCollectionLink(this.artistCollectionLink, picture);
      if (this.interestingess == null) {
        this.interestingess = this.panel.find('#interestingess-num');
      }
      this.interestingess.text(picture.interestingness);
      if (this.interestingessDisplay == null) {
        this.interestingessDisplay = this.panel.find('#interestingness');
      }
      this.setVisible(this.interestingessDisplay, picture.interestingness !== 0);
      this.setVisible($('#personalized-info'), klekr.Global.anonymous == null);
      this._updateSources(picture.fromStreams);
      if (this.relatedPanel == null) {
        this.relatedPanel = this.panel.find('#related-pictures');
      }
      this.setVisible(this.relatedPanel, !picture.noLongerValid);
      return this.setVisible(this.interestingess, !picture.noLongerValid);
    };

    PictureLabel.prototype._toggleSecondRow = function() {
      return $("#second-row").toggleClass("override-hidden");
    };

    PictureLabel.prototype.expand = function() {
      return this.expandLink.trigger('click');
    };

    PictureLabel.prototype._updateDescription = function(picture) {
      if (this.description == null) {
        this.description = this.panel.find('#description');
      }
      this.description.html(picture.description);
      return this.setVisible(this.description, (picture.description != null) && picture.description.length > 1);
    };

    PictureLabel.prototype._updateSources = function(streams) {
      var collectionStreams, i, len, link, stream;
      if (this.sources == null) {
        this.sources = this.panel.find('#sources');
      }
      if (this.sourcesLinks == null) {
        this.sourcesLinks = this.sources.find('#sources-links');
      }
      this.sourcesLinks.empty();
      collectionStreams = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = streams.length; i < len; i++) {
          stream = streams[i];
          if (stream.type !== 'Works') {
            results.push(stream);
          }
        }
        return results;
      })();
      for (i = 0, len = collectionStreams.length; i < len; i++) {
        stream = collectionStreams[i];
        if (this.sourcesLinks.children().length > 0) {
          this.sourcesLinks.append($('<span>').text(', '));
        }
        link = $('<a>').attr('href', stream.path).text(stream.username);
        this.sourcesLinks.append(link);
      }
      return this.setVisible(this.sources, collectionStreams.length > 0);
    };

    return PictureLabel;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Slide = (function(superClass) {
    extend(Slide, superClass);

    function Slide() {
      this._displayCurrentPicture = bind(this._displayCurrentPicture, this);
      this._extraHashInfo = bind(this._extraHashInfo, this);
      this._redisplayPicture = bind(this._redisplayPicture, this);
      this._monitorPictureReady = bind(this._monitorPictureReady, this);
      this.backToGrid = bind(this.backToGrid, this);
      this.updateProgress = bind(this.updateProgress, this);
      this.currentProgress = bind(this.currentProgress, this);
      this.atTheBegining = bind(this.atTheBegining, this);
      this.atTheLast = bind(this.atTheLast, this);
      this.navigateToPrevious = bind(this.navigateToPrevious, this);
      this.navigateToNext = bind(this.navigateToNext, this);
      this.currentPicture = bind(this.currentPicture, this);
      this.reset = bind(this.reset, this);
      this.reset();
      this.favePanel = new FavePanel;
      slideview.pictureClick(this.backToGrid);
      generalView.bind('layout-changed', this._redisplayPicture);
      Slide.__super__.constructor.call(this, 'slide');
    }

    Slide.prototype.reset = function() {
      return this.currentIndex = 0;
    };

    Slide.prototype.currentPicture = function() {
      return gallery.pictures[this.currentIndex];
    };

    Slide.prototype.navigateToNext = function(commander) {
      this.currentPicture().getViewed();
      if (!this.atTheLast()) {
        this.goToIndex(this.currentIndex + 1);
        this.trigger('progressed');
        return this.trigger('command-to-navigate', commander);
      }
    };

    Slide.prototype.navigateToPrevious = function(commander) {
      if (!this.atTheBegining()) {
        this.goToIndex(this.currentIndex - 1);
        return this.trigger('command-to-navigate', commander);
      }
    };

    Slide.prototype.atTheLast = function() {
      return this.currentIndex === gallery.size() - 1;
    };

    Slide.prototype.atTheBegining = function() {
      return this.currentIndex === 0;
    };

    Slide.prototype.currentProgress = function() {
      return this.currentIndex;
    };

    Slide.prototype.updateProgress = function(progress) {
      this.currentIndex = progress;
      return this._displayCurrentPicture();
    };

    Slide.prototype.backToGrid = function() {
      this.currentPicture().getViewed();
      return gallery.toggleMode();
    };

    Slide.prototype.view = function() {
      return slideview;
    };

    Slide.prototype.shortcutsSettings = function() {
      return [
        [['right', 'space'], this.navigateToNext, 'Next picture'], ['left', this.navigateToPrevious, 'Previous picture'], ['o', slideview.gotoOwner, "Go to photographer's page"], [
          'shift+o', ((function(_this) {
            return function() {
              return slideview.gotoOwner(true);
            };
          })(this)), "Open photographer's page in new tab"
        ], [['g', 'return', 'up'], this.backToGrid, "Go to grid mode"], ['l', slideview.label.expand, "Expand picture label"]
      ];
    };

    Slide.prototype._monitorPictureReady = function(picture) {
      return picture.bind('size-ready', (function(_this) {
        return function(pic) {
          if (pic.id === _this.currentPicture().id) {
            return slideview.display(pic);
          }
        };
      })(this));
    };

    Slide.prototype._redisplayPicture = function() {
      var picture;
      if (this.active()) {
        picture = this.currentPicture();
        if ((picture != null) && picture.sizeReady) {
          picture.calculateFitVersion();
          return slideview.update();
        }
      }
    };

    Slide.prototype._extraHashInfo = function(index) {
      return "-" + gallery.pictures[index].id;
    };

    Slide.prototype._displayCurrentPicture = function() {
      var picture;
      picture = this.currentPicture();
      if (picture.sizeReady) {
        picture.calculateFitVersion();
        slideview.display(picture);
      } else {
        slideview.displayLabel(picture);
        this._monitorPictureReady(picture);
      }
      this.favePanel.updateWith(picture);
      return this.trigger('progress-changed');
    };

    return Slide;

  })(ModeBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Slideview = (function(superClass) {
    extend(Slideview, superClass);

    function Slideview() {
      this.switchVisible = bind(this.switchVisible, this);
      this.gotoOwner = bind(this.gotoOwner, this);
      this.pictureClick = bind(this.pictureClick, this);
      this._updateLabel = bind(this._updateLabel, this);
      this.displayLabel = bind(this.displayLabel, this);
      this._checkImage = bind(this._checkImage, this);
      this.isShowing = bind(this.isShowing, this);
      this._fadeInto = bind(this._fadeInto, this);
      this._pictureUpdated = bind(this._pictureUpdated, this);
      this.display = bind(this.display, this);
      this.mainImg = $('#picture');
      this.pictureArea = $('#pictureArea');
      this.slide = $('#slide');
      this.bottomLeft = $('#bottomLeft');
      this.label = new PictureLabel;
      this._adjustImageFrame();
      generalView.bind('layout-changed', this._adjustImageFrame);
      klekr.Global.broadcaster.bind('picture:data-updated', this._pictureUpdated);
      this.mainImg.load(this._checkImage);
      this.mainImg.error(this._checkImage);
    }

    Slideview.prototype.display = function(picture) {
      this.picture = picture;
      if (this.showing(this.pictureArea)) {
        this.fadeInOut(this.pictureArea, false, (function(_this) {
          return function() {
            return _this._fadeInto();
          };
        })(this));
      } else {
        this._fadeInto();
      }
      return generalView.updateModeIndicator(false);
    };

    Slideview.prototype._pictureUpdated = function(picture) {
      if (this.picture && picture.id === this.picture.id) {
        return this.update();
      }
    };

    Slideview.prototype._fadeInto = function() {
      this.update();
      return this.fadeInOut(this.pictureArea, true);
    };

    Slideview.prototype.update = function() {
      if (this.mainImg.attr('src') !== this.picture.url()) {
        this.mainImg.attr('src', this.picture.url());
      }
      this.mainImg.attr('data-pic-id', this.picture.id);
      return this._updateLabel();
    };

    Slideview.prototype.isShowing = function() {
      return this.showing(this.mainImg);
    };

    Slideview.prototype._checkImage = function() {
      if (this.picture != null) {
        return this.picture.checkLargeVersionInvalid(this.mainImg[0]);
      }
    };

    Slideview.prototype.displayLabel = function() {
      if (this.showing(this.pictureArea)) {
        this.fadeInOut(this.pictureArea, false);
      }
      return this._updateLabel();
    };

    Slideview.prototype._updateLabel = function() {
      return this.label.show(this.picture);
    };

    Slideview.prototype.pictureClick = function(callback) {
      return this.mainImg.click(callback);
    };

    Slideview.prototype.gotoOwner = function(newTab) {
      var ownerUrl;
      ownerUrl = this.label.artistLink.attr('href');
      if (newTab) {
        return window.open(ownerUrl, '_blank');
      } else {
        return window.location = ownerUrl;
      }
    };

    Slideview.prototype._adjustImageFrame = function() {
      var displayHeight;
      displayHeight = generalView.displayHeight;
      return $('#imageFrameInner').css('height', (displayHeight - 40) + 'px');
    };

    Slideview.prototype.switchVisible = function(showing) {
      if (this.favePanel == null) {
        this.favePanel = $('#fave-panel');
      }
      this.setVisible(this.favePanel, showing);
      this.setVisible(this.slide, showing);
      if (!showing) {
        this.setVisible(this.pictureArea, false);
      }
      if (showing) {
        return this.label.show();
      } else {
        return this.label.hide();
      }
    };

    return Slideview;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Grid = (function(superClass) {
    extend(Grid, superClass);

    function Grid() {
      this._currentPageOfPictures = bind(this._currentPageOfPictures, this);
      this._onLayoutChange = bind(this._onLayoutChange, this);
      this._markCurrentPageAsViewed = bind(this._markCurrentPageAsViewed, this);
      this._pageIncomplete = bind(this._pageIncomplete, this);
      this._onPictureSelect = bind(this._onPictureSelect, this);
      this._isDifferentPage = bind(this._isDifferentPage, this);
      this._currentPageRange = bind(this._currentPageRange, this);
      this._updateHighlight = bind(this._updateHighlight, this);
      this._tryMoveTo = bind(this._tryMoveTo, this);
      this._changePage = bind(this._changePage, this);
      this._tryCompleteCurrentPage = bind(this._tryCompleteCurrentPage, this);
      this._navigateToNextPageWhenPicturesReady = bind(this._navigateToNextPageWhenPicturesReady, this);
      this._loadGridview = bind(this._loadGridview, this);
      this.moveRight = bind(this.moveRight, this);
      this.moveLeft = bind(this.moveLeft, this);
      this.moveDown = bind(this.moveDown, this);
      this.moveUp = bind(this.moveUp, this);
      this.switchToSlide = bind(this.switchToSlide, this);
      this.navigateToPrevious = bind(this.navigateToPrevious, this);
      this.navigateToNext = bind(this.navigateToNext, this);
      this.updateProgress = bind(this.updateProgress, this);
      this.currentProgress = bind(this.currentProgress, this);
      this.selectedPicture = bind(this.selectedPicture, this);
      this.atTheBegining = bind(this.atTheBegining, this);
      this.atTheLast = bind(this.atTheLast, this);
      this.clear = bind(this.clear, this);
      this.init = bind(this.init, this);
      this.reset = bind(this.reset, this);
      Grid.__super__.constructor.call(this, 'grid');
      this.reset();
      generalView.bind('layout-changed', this._onLayoutChange);
    }

    Grid.prototype.reset = function() {
      this.selectedIndex = 0;
      return this.picturesLoaded = false;
    };

    Grid.prototype.init = function(gallery) {
      gallery.bind('new-pictures-added', (function(_this) {
        return function(pictures) {
          var i, len, pic, results;
          results = [];
          for (i = 0, len = pictures.length; i < len; i++) {
            pic = pictures[i];
            results.push(pic.bind('clicked', _this._onPictureSelect));
          }
          return results;
        };
      })(this));
      gallery.bind('pre-reset', (function(_this) {
        return function() {
          return gridview.showLoading();
        };
      })(this));
      return gallery.bind('gallery-pictures-changed', this._tryCompleteCurrentPage);
    };

    Grid.prototype.clear = function() {
      this.reset();
      return this._loadGridview();
    };

    Grid.prototype.atTheLast = function() {
      var pageEnd, pageStart, ref, result;
      ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
      result = pageEnd === gallery.size() - 1;
      console.log("Grid: atTheLast check - pageEnd: " + pageEnd + ", gallery.size: " + (gallery.size()) + ", result: " + result);
      if (gallery.size() <= gridview.size) {
        console.log("Grid: Only one page or less loaded, pretending we're not at the last page");
        return false;
      } else {
        return result;
      }
    };

    Grid.prototype.atTheBegining = function() {
      var pageEnd, pageStart, ref;
      ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
      return pageStart === 0;
    };

    Grid.prototype.selectedPicture = function() {
      return gallery.pictures[this.selectedIndex];
    };

    Grid.prototype.view = function() {
      return gridview;
    };

    Grid.prototype.currentProgress = function() {
      return this.selectedIndex;
    };

    Grid.prototype.updateProgress = function(progress) {
      var reloadRequired;
      reloadRequired = !this.picturesLoaded || this._isDifferentPage(progress);
      this.selectedIndex = progress;
      if (reloadRequired) {
        this._loadGridview();
      } else {
        this._updateHighlight();
      }
      return this.trigger('progress-changed');
    };

    Grid.prototype.navigateToNext = function() {
      var newIndex, pageEnd, pageStart, ref;
      console.log("Grid: navigateToNext called");
      this._markCurrentPageAsViewed();
      if (!this._pageIncomplete()) {
        ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
        console.log("Grid: current page range is " + pageStart + " to " + pageEnd);
        newIndex = pageEnd + 1;
        console.log("Grid: trying to navigate to index " + newIndex + ", gallery size: " + (gallery.size()));
        if (newIndex < gallery.size()) {
          console.log("Grid: navigating to new page starting at index " + newIndex);
          this._changePage(newIndex);
          return this.trigger('progressed');
        } else {
          console.log("Grid: reached end of available pictures, requesting more");
          gridview.showLoading();
          gallery.increaseCacheSize(1);
          return gallery.bind('gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady);
        }
      }
    };

    Grid.prototype.navigateToPrevious = function() {
      var pageEnd, pageStart, ref;
      if (!this.atTheBegining()) {
        ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
        return this._changePage(pageStart - 1);
      }
    };

    Grid.prototype.switchToSlide = function() {
      this.goToIndex(this.selectedIndex);
      return gallery.toggleMode();
    };

    Grid.prototype.moveUp = function() {
      return this._tryMoveTo(this.selectedIndex - gridview.columns);
    };

    Grid.prototype.moveDown = function() {
      return this._tryMoveTo(this.selectedIndex + gridview.columns);
    };

    Grid.prototype.moveLeft = function() {
      return this._tryMoveTo(this.selectedIndex - 1, this.navigateToPrevious);
    };

    Grid.prototype.moveRight = function() {
      return this._tryMoveTo(this.selectedIndex + 1, this.navigateToNext);
    };

    Grid.prototype.shortcutsSettings = function() {
      return [['up', this.moveUp, 'Move up'], ['right', this.moveRight, 'Move right'], ['down', this.moveDown, 'Move down'], ['left', this.moveLeft, 'Move left'], [['pagedown', 'shift+right'], this.navigateToNext, 'Next page'], [['pageup', 'shift+left'], this.navigateToPrevious, 'Previous page'], [['return', 'space'], this.switchToSlide, "Go to the selected picture"]];
    };

    Grid.prototype._loadGridview = function() {
      var pictures;
      pictures = this._currentPageOfPictures();
      gridview.loadPictures(pictures);
      this.picturesLoaded = true;
      this._updateHighlight();
      return this.trigger('progress-changed');
    };

    Grid.prototype._navigateToNextPageWhenPicturesReady = function() {
      console.log("Grid: pictures are ready, checking if we can navigate to next page");
      gallery.unbind('gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady);
      if (this.atTheLast()) {
        console.log("Grid: Still at the last page, gallery size: " + (gallery.size()));
        this._loadGridview();
        if (gallery.pictures.length <= gridview.size) {
          console.log("Grid: Not enough pictures loaded yet, requesting more");
          return gallery.increaseCacheSize(1);
        }
      } else {
        console.log("Grid: More pictures available, navigating to next page");
        return this.navigateToNext();
      }
    };

    Grid.prototype._tryCompleteCurrentPage = function() {
      if (this._pageIncomplete()) {
        return this._loadGridview();
      }
    };

    Grid.prototype._changePage = function(newIndex) {
      if ((0 <= newIndex && newIndex < gallery.size())) {
        return this.goToIndex(newIndex);
      }
    };

    Grid.prototype._tryMoveTo = function(newIndex, alternative) {
      var pageEnd, pageStart, ref;
      ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
      if ((pageStart <= newIndex && newIndex < pageStart + gridview.currentSize())) {
        this.selectedIndex = newIndex;
        return this._updateHighlight();
      } else {
        return typeof alternative === "function" ? alternative() : void 0;
      }
    };

    Grid.prototype._updateHighlight = function() {
      if (this._currentPageOfPictures().length > 0) {
        return gridview.highlightPicture(this.selectedPicture());
      }
    };

    Grid.prototype._currentPageRange = function() {
      var pageEnd, pageStart, positionInPage;
      positionInPage = this.selectedIndex % gridview.size;
      pageStart = this.selectedIndex - positionInPage;
      pageEnd = Math.min(pageStart + gridview.size - 1, gallery.size() - 1);
      return [pageStart, pageEnd];
    };

    Grid.prototype._isDifferentPage = function(progress) {
      var pageEnd, pageStart, ref;
      ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
      return progress < pageStart || progress > pageEnd;
    };

    Grid.prototype._onPictureSelect = function(picture) {
      this.selectedIndex = picture.index;
      return this.switchToSlide();
    };

    Grid.prototype._pageIncomplete = function() {
      return gridview.currentSize() < gridview.size;
    };

    Grid.prototype._markCurrentPageAsViewed = function() {
      return new klekr.PictureUtil().allGetViewed(this._currentPageOfPictures());
    };

    Grid.prototype._onLayoutChange = function() {
      var original_columns, original_rows, ref;
      ref = [gridview.rows, gridview.columns], original_rows = ref[0], original_columns = ref[1];
      gridview.initLayout();
      if ((original_rows !== gridview.rows) || (original_columns !== gridview.columns)) {
        return this._loadGridview();
      }
    };

    Grid.prototype._currentPageOfPictures = function() {
      var pageEnd, pageStart, ref;
      ref = this._currentPageRange(), pageStart = ref[0], pageEnd = ref[1];
      return gallery.pictures.slice(pageStart, +pageEnd + 1 || 9e9);
    };

    return Grid;

  })(ModeBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Gridview = (function(superClass) {
    extend(Gridview, superClass);

    function Gridview() {
      this.switchVisible = bind(this.switchVisible, this);
      this._adjustFrame = bind(this._adjustFrame, this);
      this._boarderClasses = bind(this._boarderClasses, this);
      this._createPictureItem = bind(this._createPictureItem, this);
      this.initLayout = bind(this.initLayout, this);
      this._showGrid = bind(this._showGrid, this);
      this.loadPictures = bind(this.loadPictures, this);
      this.showLoading = bind(this.showLoading, this);
      this.currentSize = bind(this.currentSize, this);
      this.template = $('#template');
      this.grid = $('#gridPictures');
      this.gridview = $('#gridview');
      this.loading = this.gridview.find('#grid-loading');
      this.initLayout();
    }

    Gridview.prototype.currentSize = function() {
      return this.grid.children().size();
    };

    Gridview.prototype.highlightPicture = function(picture) {
      $('.grid-picture').removeClass('highlighted');
      this._showGrid();
      return picture.trigger('highlighted');
    };

    Gridview.prototype.showLoading = function() {
      this.loading.show();
      return this.grid.hide();
    };

    Gridview.prototype.loadPictures = function(pictures) {
      var i, index, len, picture, results;
      this.grid.empty();
      this._showGrid();
      index = 0;
      results = [];
      for (i = 0, len = pictures.length; i < len; i++) {
        picture = pictures[i];
        results.push(this._load(picture, index++));
      }
      return results;
    };

    Gridview.prototype._showGrid = function() {
      if (this.showing(this.loading)) {
        this.loading.hide();
        return this.grid.show();
      }
    };

    Gridview.prototype.initLayout = function() {
      this._calculateSize();
      return this._adjustFrame();
    };

    Gridview.prototype._load = function(picture, index) {
      var item;
      item = new PictureCellView(this.template.clone(), picture);
      item.setBoarderClasses(this._boarderClasses(index));
      this.grid.append(item.cellDiv);
      item.cellDiv.addClass('grid-index-' + index);
      return item.cellDiv.show();
    };

    Gridview.prototype._calculateSize = function() {
      var cellHeight, cellWidth, visibleHeight, visibleRows;
      cellWidth = 260;
      cellHeight = 270;
      this.columns = Math.floor(generalView.displayWidth / cellWidth);
      this.rows = Math.floor(generalView.displayHeight / cellHeight);
      this.columns = Math.max(this.columns, 1);
      this.rows = Math.max(this.rows, 1);
      visibleHeight = $(window).height() - $('.side-nav').offset().top;
      visibleRows = Math.floor(visibleHeight / cellHeight);
      console.log("Gridview: window dimensions - width: " + generalView.displayWidth + ", height: " + generalView.displayHeight);
      console.log("Gridview: calculated grid size as " + this.columns + " columns × " + this.rows + " rows");
      console.log("Gridview: visible height: " + visibleHeight + "px, visible rows: " + visibleRows);
      return this.size = this.columns * this.rows;
    };

    Gridview.prototype._createPictureItem = function(picture, index) {};

    Gridview.prototype._boarderClasses = function(index) {
      var isLeft, isTop;
      isTop = (function(_this) {
        return function(index) {
          return index < _this.columns;
        };
      })(this);
      isLeft = (function(_this) {
        return function(index) {
          return index % _this.columns === 0;
        };
      })(this);
      return _([]).tap((function(_this) {
        return function(classes) {
          if (isTop(index)) {
            classes.push('top');
          }
          if (isLeft(index)) {
            return classes.push('left');
          }
        };
      })(this));
    };

    Gridview.prototype._picId = function(picture) {
      return 'pic-' + picture.id;
    };

    Gridview.prototype._adjustFrame = function() {
      var cellHeight, cellWidth, gridHeight, gridWidth;
      cellWidth = 260;
      cellHeight = 270;
      gridWidth = this.columns * cellWidth + 2;
      gridHeight = this.rows * cellHeight + 2;
      console.log("Gridview: adjusting frame to width: " + gridWidth + "px, height: " + gridHeight + "px");
      this.grid.css('width', gridWidth + 'px');
      this.grid.css('height', gridHeight + 'px');
      return $('#gridInner').css('height', generalView.displayHeight + 'px');
    };

    Gridview.prototype.switchVisible = function(showing) {
      return this.setVisible(this.gridview, showing);
    };

    return Gridview;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Gallery = (function(superClass) {
    extend(Gallery, superClass);

    function Gallery() {
      this._registerScrollControl = bind(this._registerScrollControl, this);
      this.readyNewPictures = bind(this.readyNewPictures, this);
      this.readyPictures = bind(this.readyPictures, this);
      this._currentProgress = bind(this._currentProgress, this);
      this._unseenPictures = bind(this._unseenPictures, this);
      this._preloadOnLayoutChange = bind(this._preloadOnLayoutChange, this);
      this._addPictures = bind(this._addPictures, this);
      this._filterOpts = bind(this._filterOpts, this);
      this._reinitToGrid = bind(this._reinitToGrid, this);
      this._emptyGallery = bind(this._emptyGallery, this);
      this._onRetrieverFinished = bind(this._onRetrieverFinished, this);
      this._ensurePictureCache = bind(this._ensurePictureCache, this);
      this._updateModeIndicatorInView = bind(this._updateModeIndicatorInView, this);
      this._createPictureRetriever = bind(this._createPictureRetriever, this);
      this._firstBatchOfPicturesReady = bind(this._firstBatchOfPicturesReady, this);
      this._morePicturesReady = bind(this._morePicturesReady, this);
      this._alternativeMode = bind(this._alternativeMode, this);
      this._updateProgressInView = bind(this._updateProgressInView, this);
      this._progressChanged = bind(this._progressChanged, this);
      this._infoFromHash = bind(this._infoFromHash, this);
      this._updateModeAndLocation = bind(this._updateModeAndLocation, this);
      this._listenHashChange = bind(this._listenHashChange, this);
      this._resetRetriever = bind(this._resetRetriever, this);
      this._reset = bind(this._reset, this);
      this._retrieveMorePictures = bind(this._retrieveMorePictures, this);
      this.isLoading = bind(this.isLoading, this);
      this.pageSize = bind(this.pageSize, this);
      this.toggleMode = bind(this.toggleMode, this);
      this.inGrid = bind(this.inGrid, this);
      this.pageOf = bind(this.pageOf, this);
      this.advanceOffset = bind(this.advanceOffset, this);
      this.increaseCacheSize = bind(this.increaseCacheSize, this);
      this.currentPage = bind(this.currentPage, this);
      this.currentPicture = bind(this.currentPicture, this);
      this.isEmpty = bind(this.isEmpty, this);
      this.size = bind(this.size, this);
      this.init = bind(this.init, this);
      this.registerTouch = bind(this.registerTouch, this);
      var i, len, mode, ref, ref1;
      this.cacheSize = klekr.Global.defaultGalleryCacheSize || 20;
      ref = this.modes = [new Grid, new Slide], this.grid = ref[0], this.slide = ref[1];
      ref1 = this.modes;
      for (i = 0, len = ref1.length; i < len; i++) {
        mode = ref1[i];
        mode.bind('progressed', this._ensurePictureCache);
        mode.bind('progress-changed', this._progressChanged);
      }
      this.currentMode = typeof __gridMode__ !== "undefined" && __gridMode__ !== null ? this.grid : this.slide;
      this._updateModeIndicatorInView();
      this.advanceByProgress = __advance_by_progress__;
      this.picturePreloader = new PicturePreloader(this);
      generalView.nextClick((function(_this) {
        return function() {
          var base;
          return typeof (base = _this.currentMode).navigateToNext === "function" ? base.navigateToNext() : void 0;
        };
      })(this));
      generalView.previousClick((function(_this) {
        return function() {
          var base;
          return typeof (base = _this.currentMode).navigateToPrevious === "function" ? base.navigateToPrevious() : void 0;
        };
      })(this));
      generalView.toggleModeClick(this.toggleMode);
      this.filters = new GalleryFilters;
      generalView.updateShareLink(this.filters.filterSettings());
      this.filters.bind('changed', this._reinitToGrid);
      this.filters.bind('changed', generalView.updateShareLink);
      this.autoPlay = new AutoPlay(this.slide);
      this._registerScrollControl();
      new GalleryControlPanel(this);
      this._listenHashChange();
      generalView.bind('layout-changed', this._preloadOnLayoutChange);
      this.registerTouch();
    }

    Gallery.prototype.registerTouch = function() {
      $(window).on("swipeleft", (function(_this) {
        return function() {
          return _this.currentMode.navigateToNext();
        };
      })(this));
      return $(window).on("swiperight", (function(_this) {
        return function() {
          return _this.currentMode.navigateToPrevious();
        };
      })(this));
    };

    Gallery.prototype.init = function() {
      var _, ref, requestedPicId;
      ref = this._infoFromHash(), _ = ref[0], _ = ref[1], requestedPicId = ref[2];
      this._reset(requestedPicId);
      this.grid.init(this);
      console.log("Gallery: Initializing with increased cache size to enable navigation and fill the grid");
      return this.increaseCacheSize(5);
    };

    Gallery.prototype.size = function() {
      if (this.pictures != null) {
        return this.pictures.length;
      } else {
        return 0;
      }
    };

    Gallery.prototype.isEmpty = function() {
      return this.size() === 0;
    };

    Gallery.prototype.currentPicture = function() {
      return this.pictures[this._currentProgress()];
    };

    Gallery.prototype.currentPage = function() {
      var cp;
      cp = this.currentPicture();
      if ((cp != null)) {
        return this.pageOf(cp);
      } else {
        return 1;
      }
    };

    Gallery.prototype.increaseCacheSize = function(pages) {
      this.cacheSize += pages;
      return this._ensurePictureCache();
    };

    Gallery.prototype.advanceOffset = function() {
      return this._unseenPictures().length;
    };

    Gallery.prototype.pageOf = function(picture) {
      return Math.floor(picture.index / this.pageSize());
    };

    Gallery.prototype.inGrid = function() {
      return this.currentMode === this.grid;
    };

    Gallery.prototype.toggleMode = function() {
      return this._alternativeMode().goToIndex(this._currentProgress());
    };

    Gallery.prototype.pageSize = function() {
      return gridview.size;
    };

    Gallery.prototype.isLoading = function() {
      return this.retriever && this.retriever.busy();
    };

    Gallery.prototype._retrieveMorePictures = function(pages) {
      if (pages == null) {
        pages = 1;
      }
      console.log("Gallery: Retrieving " + pages + " more pages of pictures");
      return this.retriever.retrieve(pages);
    };

    Gallery.prototype._reset = function(requestedPicId) {
      var i, len, m, ref;
      if (requestedPicId != null) {
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
      ref = this.modes;
      for (i = 0, len = ref.length; i < len; i++) {
        m = ref[i];
        m.reset();
      }
      this.picturePreloader.start();
      if (requestedPicId != null) {
        this.retriever.retrievePic(requestedPicId);
      }
      return this._ensurePictureCache();
    };

    Gallery.prototype._resetRetriever = function() {
      if (this.retriever != null) {
        this.retriever.reset();
        this.retriever.unbind('batch-retrieved');
        this.retriever.unbind('done-retrieving');
      }
      this.retriever = this._createPictureRetriever();
      this.retriever.bind('batch-retrieved', this._addPictures);
      return this.retriever.bind('done-retrieving', this._onRetrieverFinished);
    };

    Gallery.prototype._listenHashChange = function() {
      return $(window).bind('hashchange', (function(_this) {
        return function(e) {
          var index, mode, ref;
          ref = _this._infoFromHash(), mode = ref[0], index = ref[1];
          if ((mode != null) && (index != null)) {
            return _this._updateModeAndLocation(mode, index);
          }
        };
      })(this));
    };

    Gallery.prototype._updateModeAndLocation = function(mode, index) {
      var modeChanged, newIndex, newMode;
      newIndex = Math.min(parseInt(index), this.size() - 1);
      newMode = this[mode];
      modeChanged = newMode !== this.currentMode;
      if (modeChanged) {
        this.currentMode.off();
        this.currentMode = newMode;
        this.currentMode.on();
        this._updateModeIndicatorInView();
        this._updateProgressInView();
      }
      if (newIndex !== this._currentProgress() || this.blank || modeChanged) {
        this.blank = false;
        return this.currentMode.updateProgress(newIndex);
      }
    };

    Gallery.prototype._infoFromHash = function() {
      var hash;
      hash = $.param.fragment();
      if (hash.length > 0) {
        return hash.split('-');
      } else {
        return [];
      }
    };

    Gallery.prototype._progressChanged = function() {
      this._updateProgressInView();
      return this.picturePreloader.rePrioritize();
    };

    Gallery.prototype._updateProgressInView = function() {
      var base;
      generalView.updateNavigation(this.currentMode.forwardable(), this.currentMode.backwardable());
      return typeof (base = this.scrollControl).reset === "function" ? base.reset() : void 0;
    };

    Gallery.prototype._alternativeMode = function() {
      if (this.currentMode === this.grid) {
        return this.slide;
      } else {
        return this.grid;
      }
    };

    Gallery.prototype._morePicturesReady = function() {
      if (this.blank) {
        return this._firstBatchOfPicturesReady();
      } else {
        return this.trigger('gallery-pictures-changed');
      }
    };

    Gallery.prototype._firstBatchOfPicturesReady = function() {
      this.currentMode.on();
      return this.currentMode.goToIndex(0);
    };

    Gallery.prototype._createPictureRetriever = function() {
      var offsetFn;
      if (this.advanceByProgress) {
        offsetFn = !this.filters.filterSettings().viewed ? this.advanceOffset : void 0;
        return new PictureRetrieverByOffset(this._filterOpts, this.pageSize(), __morePicturesPath__, offsetFn);
      } else {
        return new PictureRetrieverByPage(this._filterOpts, this.pageSize(), __morePicturesPath__);
      }
    };

    Gallery.prototype._updateModeIndicatorInView = function() {
      return generalView.updateModeIndicator(this.inGrid());
    };

    Gallery.prototype._ensurePictureCache = function() {
      var maxCacheSize, needMoreForCache, numPagesToLoad, picturesAhead;
      if (!this.isLoading()) {
        picturesAhead = this.pictures.length - this._currentProgress();
        maxCacheSize = Math.min(this.cacheSize * this.pageSize(), 500);
        needMoreForCache = picturesAhead < maxCacheSize;
        console.log("Picture cache status: ahead=" + picturesAhead + ", maxCache=" + maxCacheSize + ", needMore=" + needMoreForCache + ", allRetrieved=" + this.allPicturesRetrieved);
        if (needMoreForCache && !this.allPicturesRetrieved) {
          console.log("Retrieving more pictures...");
          numPagesToLoad = Math.ceil((maxCacheSize - picturesAhead) / this.pageSize());
          numPagesToLoad = Math.min(numPagesToLoad, 5);
          console.log("Loading " + numPagesToLoad + " pages at once");
          return this._retrieveMorePictures(numPagesToLoad);
        } else {
          return this.trigger('idle');
        }
      }
    };

    Gallery.prototype._onRetrieverFinished = function(numOfRetrieved) {
      if (this.isEmpty()) {
        this._emptyGallery();
      } else if (numOfRetrieved > 0) {
        this._ensurePictureCache();
      } else if (numOfRetrieved === 0) {
        this.allPicturesRetrieved = true;
        this.trigger('gallery-pictures-changed');
      }
      return this._updateProgressInView();
    };

    Gallery.prototype._emptyGallery = function() {
      var base;
      if (typeof (base = this.currentMode).clear === "function") {
        base.clear();
      }
      if (!this.filters.hasActiveFilter()) {
        this.currentMode.off();
        return generalView.showEmptyGalleryMessage();
      }
    };

    Gallery.prototype._reinitToGrid = function() {
      this.currentMode = this.grid;
      return this._reset();
    };

    Gallery.prototype._filterOpts = function() {
      var filterSettings;
      filterSettings = this.filters.filterSettings();
      return _.tap({}, (function(_this) {
        return function(opts) {
          if (filterSettings.rating) {
            opts.min_rating = filterSettings.rating;
          }
          if (filterSettings.faveDate) {
            opts.faved_date = filterSettings.faveDate;
          }
          if (filterSettings.faveDateAfter) {
            opts.faved_date_after = filterSettings.faveDateAfter;
          }
          if (filterSettings.type) {
            opts.type = filterSettings.type;
          }
          opts.viewed = filterSettings.viewed;
          return opts.real_time = true;
        };
      })(this));
    };

    Gallery.prototype._addPictures = function(newPictures) {
      var addedPictures, i, len, newPic, startPosition;
      startPosition = this.pictures.length;
      addedPictures = new klekr.PictureUtil().uniqConcat(this.pictures, newPictures);
      if (addedPictures.length > 0) {
        for (i = 0, len = addedPictures.length; i < len; i++) {
          newPic = addedPictures[i];
          newPic.index = startPosition++;
        }
        this.picturePreloader.preload(addedPictures);
        this.trigger('new-pictures-added', addedPictures);
        return this._morePicturesReady();
      }
    };

    Gallery.prototype._preloadOnLayoutChange = function() {
      var picturesToReload;
      picturesToReload = _(this.pictures).filter(function(picture) {
        return picture.sizeReady && !picture.data.viewed;
      });
      return this.picturePreloader.preload(picturesToReload);
    };

    Gallery.prototype._unseenPictures = function() {
      var i, len, p, ref, results;
      ref = gallery.pictures;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        p = ref[i];
        if (!p.data.viewed) {
          results.push(p);
        }
      }
      return results;
    };

    Gallery.prototype._currentProgress = function() {
      return this.currentMode.currentProgress();
    };

    Gallery.prototype.readyPictures = function() {
      return _(this.pictures).select(function(p) {
        return p.ready;
      });
    };

    Gallery.prototype.readyNewPictures = function() {
      return _(this.pictures).select(function(p) {
        return p.ready && !p.data.viewed;
      });
    };

    Gallery.prototype._registerScrollControl = function() {
      this.scrollControl = new klekr.ScrollControl((function(_this) {
        return function(towardsLeft) {
          return _this.currentMode.canScroll(towardsLeft);
        };
      })(this));
      this.scrollControl.bind('jump', (function(_this) {
        return function(towardsLeft) {
          return _this.currentMode.scroll(towardsLeft);
        };
      })(this));
      return this.scrollControl.bind('move', generalView.inidicateScroll);
    };

    Gallery.prototype.report = function() {
      console.debug("cache size: " + this.cacheSize);
      console.debug("pictures in cache: " + this.pictures.length);
      console.debug("pictures preloaded: " + this.readyPictures().length);
      console.debug("current flickr page: " + this.pageToRetrieve);
      console.debug("page size: " + gridview.size);
      console.debug("pictures size: " + this.pictures.length);
      return console.debug("current progress: " + this._currentProgress());
    };

    return Gallery;

  })(Events);

  $(document).ready(function() {
    window.keyShortcuts = new KeyShortcuts;
    window.generalView = new GeneralView;
    window.slideview = new Slideview;
    window.gridview = new Gridview;
    window.gallery = new Gallery;
    return new StreamPanel;
  });

  $(document).bind("mobileinit", function() {
    $.event.special.swipe.horizontalDistanceThreshold = 10;
    $.event.special.swipe.verticalDistanceThreshold = 300;
    return $.event.special.swipe.durationThreshold = 2000;
  });

  $(window).load(function() {
    return gallery.init();
  });

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.GalleryControlPanel = (function(superClass) {
    extend(GalleryControlPanel, superClass);

    function GalleryControlPanel(gallery) {
      this.gallery = gallery;
      this._updateConnectionStatus = bind(this._updateConnectionStatus, this);
      this._updateGalleryInfo = bind(this._updateGalleryInfo, this);
      this._showDownloadButton = bind(this._showDownloadButton, this);
      this._downloadPictures = bind(this._downloadPictures, this);
      this.optionButton = $('.gallery-option');
      this.panel = $('#slide-options');
      this.loadingIndicator = this.panel.find('#loading');
      this.optionButton.click((function(_this) {
        return function() {
          return _this.panel.toggle();
        };
      })(this));
      this.panel.find('.close-btn').click_((function(_this) {
        return function() {
          return _this.panel.hide();
        };
      })(this));
      this.downloadButton = $('#download-pictures');
      this.downloadButton.click_(this._downloadPictures);
      new CollapsiblePanel($('#under-the-hood-panel'), $('#under-the-hood'), ['Go Offline ▼', 'Hide ▲']);
      klekr.Global.broadcaster.bind('picture:fully-ready', this._updateGalleryInfo);
      klekr.Global.broadcaster.bind('picture:viewed', this._updateGalleryInfo);
      this.gallery.bind('idle', this._showDownloadButton);
      this._updateConnectionStatus();
      klekr.Global.server.bind('connection-status-changed', this._updateConnectionStatus);
    }

    GalleryControlPanel.prototype._downloadPictures = function() {
      this.gallery.increaseCacheSize(20);
      this.loadingIndicator.show();
      return this.downloadButton.hide();
    };

    GalleryControlPanel.prototype._showDownloadButton = function() {
      this._updateGalleryInfo();
      this.loadingIndicator.hide();
      return this.downloadButton.show();
    };

    GalleryControlPanel.prototype._updateGalleryInfo = function() {
      var downloading, numOfReadyPictures;
      if (this.numLabel == null) {
        this.numLabel = $('#num-of-pics-in-cache');
      }
      if (this.numNewLabel == null) {
        this.numNewLabel = $('#num-of-new-pics-in-cache');
      }
      if (this.numDownloadingLabel == null) {
        this.numDownloadingLabel = $('#num-of-downloading-pics');
      }
      numOfReadyPictures = this.gallery.readyPictures().length;
      this.numNewLabel.text(this.gallery.readyNewPictures().length);
      this.numLabel.text(numOfReadyPictures);
      downloading = this.gallery.size() - numOfReadyPictures;
      this.numDownloadingLabel.text(downloading);
      return this.setVisible(this.downloadingInfo != null ? this.downloadingInfo : this.downloadingInfo = $('#downloading-info'), downloading > 0);
    };

    GalleryControlPanel.prototype._updateConnectionStatus = function() {
      var online, status;
      if (this.statusLabel == null) {
        this.statusLabel = this.panel.find('#connection-status-label');
      }
      online = klekr.Global.server.onLine();
      status = online ? 'Online' : 'Offline';
      this.statusLabel.text(status);
      return this.setVisible(this.downloadButton, online);
    };

    return GalleryControlPanel;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.GalleryFilters = (function(superClass) {
    extend(GalleryFilters, superClass);

    function GalleryFilters() {
      this.hide = bind(this.hide, this);
      this.show = bind(this.show, this);
      this._filterChanged = bind(this._filterChanged, this);
      this._setFiltersVisibility = bind(this._setFiltersVisibility, this);
      this._applyDefaultFitlers = bind(this._applyDefaultFitlers, this);
      this._getDate = bind(this._getDate, this);
      this.hasActiveFilter = bind(this.hasActiveFilter, this);
      this.filterSettings = bind(this.filterSettings, this);
      var base, base1, base2;
      this.panel = $('#slide-options .filters');
      this.ratingFilter = $('#rating-filter-select');
      this.typeCheckBox = $('#type-filter-checkbox');
      this.viewedCheckBox = $('#viewed-filter-checkbox');
      this.faveDateBox = this.panel.find('#fave-at-date');
      this.faveDateAfterBox = this.panel.find('#fave-at-date-after');
      if (typeof (base = this.typeCheckBox).change === "function") {
        base.change(this._filterChanged);
      }
      if (typeof (base1 = this.viewedCheckBox).change === "function") {
        base1.change(this._filterChanged);
      }
      if (typeof (base2 = this.ratingFilter).change === "function") {
        base2.change(this._filterChanged);
      }
      this.faveDateBox.bind('change', this._filterChanged);
      this.faveDateAfterBox.bind('change', this._filterChanged);
      this._setFiltersVisibility(klekr.Global.filtersOpts || {});
      this.panel.find('.datepicker').simpleDatepicker();
      this._applyDefaultFitlers();
    }

    GalleryFilters.prototype.filterSettings = function() {
      var settings;
      settings = {};
      if (this.typeCheckBox.attr('checked')) {
        settings.type = 'UploadStream';
      }
      if (this.viewedCheckBox != null) {
        settings.viewed = this.viewedCheckBox.attr('checked');
      }
      if (this.ratingFilter.length > 0 && this.ratingFilter[0].selectedIndex > 0) {
        settings.rating = this.ratingFilter[0].selectedIndex + 1;
      }
      settings.faveDate = this._getDate(this.faveDateBox);
      settings.faveDateAfter = this._getDate(this.faveDateAfterBox);
      return settings;
    };

    GalleryFilters.prototype.hasActiveFilter = function() {
      var name, ref, value;
      ref = this.filterSettings();
      for (name in ref) {
        value = ref[name];
        if (value != null) {
          return true;
        }
      }
      return false;
    };

    GalleryFilters.prototype._getDate = function(input) {
      if (input.length > 0 && input.val().length > 0) {
        return input.val();
      }
    };

    GalleryFilters.prototype._applyDefaultFitlers = function() {
      if (klekr.Global.defaultFilters != null) {
        this.ratingFilter[0].selectedIndex = klekr.Global.defaultFilters.rating - 1;
        this.faveDateBox.val(klekr.Global.defaultFilters.faveDate);
        return this.faveDateAfterBox.val(klekr.Global.defaultFilters.faveDateAfter);
      }
    };

    GalleryFilters.prototype._setFiltersVisibility = function(opts) {
      this.setVisible(this.panel.find('#stream-type-filter-panel'), opts.streamTypeFilter);
      this.setVisible(this.panel.find('#rating-filter-panel'), opts.ratingFilter);
      return this.setVisible(this.panel.find('#faved-at-filter-panel'), opts.favedAtFilter);
    };

    GalleryFilters.prototype._filterChanged = function() {
      return this.trigger('changed', this.filterSettings());
    };

    GalleryFilters.prototype.show = function() {
      return this.fadeInOut(this.panel, true);
    };

    GalleryFilters.prototype.hide = function() {
      return this.fadeInOut(this.panel, false);
    };

    return GalleryFilters;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.KeyShortcuts = (function(superClass) {
    extend(KeyShortcuts, superClass);

    function KeyShortcuts() {
      this._clearLock = bind(this._clearLock, this);
      this._canShowHelp = bind(this._canShowHelp, this);
      this._popupHelp = bind(this._popupHelp, this);
      this._registerClearLock = bind(this._registerClearLock, this);
      this.addShortcuts = bind(this.addShortcuts, this);
      this.enable = bind(this.enable, this);
      this.disable = bind(this.disable, this);
      this.shortcuts = [];
      this._popup = $('#keyShortcuts');
      this._registerHelpPopup();
      this.helpList = $('#shortcuts');
      this.addShortcuts(new KeyShortcut('k', this._popupHelp, 'Show all keyboard shortcuts', this._canShowHelp));
      this.addShortcuts(new KeyShortcut('w', this.toggleFullScreen, 'Go to full screen mode', function() {
        return fullScreenApi.supportsFullScreen;
      }));
    }

    KeyShortcuts.prototype.disable = function() {
      $(document).unbind('keydown', this._clearLock);
      return this._updateKeys(this._unbindKey);
    };

    KeyShortcuts.prototype.enable = function() {
      var i, len, ref, results, shortcut;
      this._updateKeys(this._bindKey);
      ref = this.shortcuts;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        shortcut = ref[i];
        results.push(this._registerClearLock(shortcut));
      }
      return results;
    };

    KeyShortcuts.prototype.addShortcuts = function(shortcuts) {
      this.disable();
      this.shortcuts = this.shortcuts.concat(shortcuts);
      return this.enable();
    };

    KeyShortcuts.prototype._registerClearLock = function(shortcut) {
      return this._bindKey(shortcut, this._clearLock);
    };

    KeyShortcuts.prototype._updateKeys = function(action) {
      var i, len, ref, results, shortcut;
      ref = this.shortcuts;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        shortcut = ref[i];
        results.push(action(shortcut));
      }
      return results;
    };

    KeyShortcuts.prototype._bindKey = function(shortcut, toBind) {
      var i, key, len, ref, results;
      if (toBind == null) {
        toBind = shortcut.onKeydown;
      }
      ref = shortcut.keys;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        results.push($(document).bind('keydown', key, toBind));
      }
      return results;
    };

    KeyShortcuts.prototype._unbindKey = function(shortcut) {
      return $(document).unbind('keydown', shortcut.onKeydown);
    };

    KeyShortcuts.prototype._registerHelpPopup = function() {
      $('#keyShortcutsLink').click_(this._popupHelp);
      return this._popup.find('#close').click_((function(_this) {
        return function() {
          return _this.closePopup(_this._popup);
        };
      })(this));
    };

    KeyShortcuts.prototype._popupHelp = function() {
      this._updateHelp();
      return this.popup(this._popup);
    };

    KeyShortcuts.prototype._canShowHelp = function() {
      return !this.showing(this._popup);
    };

    KeyShortcuts.prototype._updateHelp = function() {
      var i, len, ref, results, shortcut;
      this.helpList.empty();
      ref = this.shortcuts;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        shortcut = ref[i];
        if (shortcut.enable()) {
          results.push(this.helpList.append($('<li>').html(shortcut.text())));
        }
      }
      return results;
    };

    KeyShortcuts.prototype._clearLock = function() {
      return this.locked = false;
    };

    return KeyShortcuts;

  })(ViewBase);

  window.KeyShortcut = (function() {
    function KeyShortcut(keys, _func, desc, enable) {
      this.keys = keys;
      this._func = _func;
      this.desc = desc;
      this.enable = enable != null ? enable : (function() {
        return true;
      });
      this.onKeydown = bind(this.onKeydown, this);
      this._keyDisplay = bind(this._keyDisplay, this);
      this.text = bind(this.text, this);
      if (!(this.keys instanceof Array)) {
        this.keys = [this.keys];
      }
    }

    KeyShortcut.prototype.text = function() {
      var key, keysStrings;
      keysStrings = (function() {
        var i, len, ref, results;
        ref = this.keys;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          key = ref[i];
          results.push(this._keyDisplay(key));
        }
        return results;
      }).call(this);
      return (keysStrings.join(', ')) + " <span class='key-desc'>" + this.desc + "</span>";
    };

    KeyShortcut.prototype._keyDisplay = function(stringKey) {
      var keyWithDirection;
      keyWithDirection = stringKey.replace('up', '↑').replace('down', '↓').replace('left', '←').replace('right', '→');
      return "<span class='key-name'>" + keyWithDirection + "</span>";
    };

    KeyShortcut.prototype.onKeydown = function(e) {
      if (!keyShortcuts.locked) {
        if (this.enable()) {
          this._func(e);
          return keyShortcuts.locked = true;
        }
      }
    };

    return KeyShortcut;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.PicturePreloadPriority = (function() {
    function PicturePreloadPriority(picture, gallery) {
      this.picture = picture;
      this.gallery = gallery;
      this._ahead = bind(this._ahead, this);
      this._positionAdjustmentFull = bind(this._positionAdjustmentFull, this);
      this._positionAdjustment = bind(this._positionAdjustment, this);
      this._pagesAhead = bind(this._pagesAhead, this);
      this._pageAdjustmentFull = bind(this._pageAdjustmentFull, this);
      this._pageAdjustmentSmall = bind(this._pageAdjustmentSmall, this);
      this.full = bind(this.full, this);
      this.small = bind(this.small, this);
    }

    PicturePreloadPriority.prototype.small = function() {
      return 100 + this._pageAdjustmentSmall() + this._positionAdjustment();
    };

    PicturePreloadPriority.prototype.full = function() {
      return 0 + this._pageAdjustmentFull() + this._positionAdjustment() + this._positionAdjustmentFull();
    };

    PicturePreloadPriority.prototype._pageAdjustmentSmall = function() {
      var pagesAhead;
      pagesAhead = this._pagesAhead();
      if (pagesAhead < 0) {
        return -500;
      } else if (pagesAhead <= 1) {
        return 200;
      } else {
        return 0;
      }
    };

    PicturePreloadPriority.prototype._pageAdjustmentFull = function() {
      var pagesAhead;
      pagesAhead = this._pagesAhead();
      if (pagesAhead < 0) {
        return -500;
      } else if (pagesAhead === 0) {
        return 200;
      } else {
        return 0;
      }
    };

    PicturePreloadPriority.prototype._pagesAhead = function() {
      return this.gallery.pageOf(this.picture) - this.gallery.currentPage();
    };

    PicturePreloadPriority.prototype._positionAdjustment = function() {
      var ref;
      if (!this.gallery.inGrid() && (0 <= (ref = this._ahead()) && ref <= 5)) {
        return 1000;
      } else {
        return 0;
      }
    };

    PicturePreloadPriority.prototype._positionAdjustmentFull = function() {
      if (0 <= this._ahead()) {
        return this.gallery.pageSize() - this._ahead();
      } else {
        return this._ahead();
      }
    };

    PicturePreloadPriority.prototype._ahead = function() {
      return this.picture.index - this.gallery.currentPicture().index;
    };

    return PicturePreloadPriority;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.AutoPlay = (function(superClass) {
    extend(AutoPlay, superClass);

    function AutoPlay(slide) {
      this.slide = slide;
      this._togglePlay = bind(this._togglePlay, this);
      this._animatePauseButton = bind(this._animatePauseButton, this);
      this._goNext = bind(this._goNext, this);
      this._schedule = bind(this._schedule, this);
      this._progressed = bind(this._progressed, this);
      this._updateStatus = bind(this._updateStatus, this);
      this.pause = bind(this.pause, this);
      this.show = bind(this.show, this);
      this.hide = bind(this.hide, this);
      this._bindToSlide = bind(this._bindToSlide, this);
      this._start = bind(this._start, this);
      if (klekr.Global.canAutoPlay) {
        this.started = false;
        this.panel = $('#auto-play');
        this.startButton = this.panel.find('#play-button');
        this.pauseButton = this.panel.find('#pause-button');
        this.startButton.click_(this._start);
        this.pauseButton.click_(this.pause);
        this._bindToSlide();
        keyShortcuts.addShortcuts(this._shortcuts());
        this.slide.bind('progress-changed', this._progressed);
      }
    }

    AutoPlay.prototype._start = function() {
      if (!this.started) {
        this.started = true;
        this._goNext();
        return this._updateStatus();
      }
    };

    AutoPlay.prototype._bindToSlide = function() {
      this.slide.bind('off', this.hide);
      this.slide.bind('on', this.show);
      return this.slide.bind('command-to-navigate', (function(_this) {
        return function(commander) {
          if (commander !== _this) {
            return _this.pause();
          }
        };
      })(this));
    };

    AutoPlay.prototype.hide = function() {
      this.pause();
      return this.panel.hide();
    };

    AutoPlay.prototype.show = function() {
      return this.panel.show();
    };

    AutoPlay.prototype.pause = function() {
      if (this.started) {
        this.started = false;
        return this._updateStatus();
      }
    };

    AutoPlay.prototype._updateStatus = function() {
      this.fadeInOut(this.startButton, !this.started);
      this.fadeInOut(this.pauseButton, this.started);
      return this._animatePauseButton();
    };

    AutoPlay.prototype._progressed = function() {
      var atLast;
      atLast = this.slide.atTheLast();
      this.panel.toggleClass('faded', atLast);
      if (atLast) {
        return this.pause();
      }
    };

    AutoPlay.prototype._schedule = function() {
      return setTimeout(this._goNext, 5000);
    };

    AutoPlay.prototype._goNext = function() {
      if (this.started && this.slide.active()) {
        this.slide.navigateToNext(this);
        return this._schedule();
      }
    };

    AutoPlay.prototype._animatePauseButton = function() {
      if (this.started) {
        this.pauseButton.toggleClass('faded');
        return setTimeout(this._animatePauseButton, 1500);
      }
    };

    AutoPlay.prototype._togglePlay = function() {
      if (this.started) {
        return this.pause();
      } else {
        return this._start();
      }
    };

    AutoPlay.prototype._shortcuts = function() {
      return [
        new KeyShortcut('p', this._togglePlay, 'Toggle auto play', (function(_this) {
          return function() {
            return _this.showing(_this.panel);
          };
        })(this))
      ];
    };

    return AutoPlay;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.FavePanel = (function(superClass) {
    extend(FavePanel, superClass);

    function FavePanel() {
      this._createRatingShortcut = bind(this._createRatingShortcut, this);
      this._ratingShortcutsEnabled = bind(this._ratingShortcutsEnabled, this);
      this._canFave = bind(this._canFave, this);
      this._showingPopup = bind(this._showingPopup, this);
      this._changeRating = bind(this._changeRating, this);
      this._initRaty = bind(this._initRaty, this);
      this._updateRating = bind(this._updateRating, this);
      this._registerEvents = bind(this._registerEvents, this);
      this._updateDom = bind(this._updateDom, this);
      this._pictureUpdated = bind(this._pictureUpdated, this);
      this._checkAccess = bind(this._checkAccess, this);
      this.updateWith = bind(this.updateWith, this);
      this.unfave = bind(this.unfave, this);
      this.fave = bind(this.fave, this);
      this.faveLink = $('#faveLink');
      this.removeFaveLink = $('#removeFaveLink');
      this.faved = $('#faved');
      this.faveArea = $('#faveArea');
      this.faveRating = $('#faveRating');
      this.faveRatingPanel = $('#faveRatingPanel');
      this.ratingDisplayPanel = $('#ratingDisplayPanel');
      this.ratingDisplay = $('#ratingDisplay');
      this.reloading = $('#reloading-picture');
      this.loginReminder = $('#login-reminder');
      this._registerEvents();
      this._initRaty(this.faveRating);
      this._initRaty(this.ratingDisplay);
      keyShortcuts.addShortcuts(this._shortcuts());
    }

    FavePanel.prototype.fave = function() {
      if (this.picture.favable() && !this.picture.faved()) {
        this.setArtistCollectionLink(this.faveRatingPanel.find('#artist-collection'), this.picture);
        return this.popup(this.faveRatingPanel);
      }
    };

    FavePanel.prototype.unfave = function() {
      if (this.picture.favable() && this.picture.faved()) {
        this.picture.unfave();
        return this._updateDom();
      }
    };

    FavePanel.prototype.updateWith = function(picture) {
      this.picture = picture;
      return this._checkAccess();
    };

    FavePanel.prototype._checkAccess = function() {
      if (!this.picture.favable() && (klekr.Global.currentCollector != null)) {
        this.picture.bind('data-updated', this._pictureUpdated);
        this.picture.reloadForCurrentCollector();
      }
      return this._updateDom();
    };

    FavePanel.prototype._pictureUpdated = function(picture) {
      if (picture === this.picture) {
        return this._updateDom();
      }
    };

    FavePanel.prototype._updateDom = function() {
      var faved;
      this.setVisible(this.faveArea, (klekr.Global.currentCollector != null) && this.picture.favable());
      this.setVisible(this.reloading, !this.picture.favable() && (klekr.Global.currentCollector != null));
      this.setVisible(this.loginReminder, klekr.Global.currentCollector == null);
      if (this.picture.favable()) {
        faved = this.picture.faved();
        this.setVisible(this.faveLink, !faved);
        this._updateRating(this.picture.data.rating);
        this.setVisible(this.ratingDisplayPanel, faved);
        this.setVisible(this.faved, faved);
        return this.removeFaveLink.attr('data-content', "This picture is added to my faves on " + this.picture.favedDate + ". Click to remove it.");
      }
    };

    FavePanel.prototype._registerEvents = function() {
      this.faveLink.click_(this.fave);
      this.removeFaveLink.click_(this.unfave);
      return $('#fave-login').click(this.login);
    };

    FavePanel.prototype._updateRating = function(rating) {
      $.fn.raty.start(rating, '#faveRating');
      return $.fn.raty.start(rating, '#ratingDisplay');
    };

    FavePanel.prototype._initRaty = function(div) {
      return div.raty({
        start: 1,
        path: '/assets/',
        size: 24,
        target: '#faveRatingPanel #hint-message',
        hintList: ['I like it.', 'I would recommend it to others.', "One of the most impresive pictures I've seen for quite a while.", 'I would hang it in my home.', "It's probably a masterpiece."],
        click: (function(_this) {
          return function(score, evt) {
            return _this._changeRating(score);
          };
        })(this)
      });
    };

    FavePanel.prototype._changeRating = function(rating) {
      if (this._showingPopup()) {
        this.closePopup(this.faveRatingPanel);
      }
      this.picture.fave(rating);
      return this._updateDom();
    };

    FavePanel.prototype._showingPopup = function() {
      return this.showing(this.faveRatingPanel);
    };

    FavePanel.prototype._shortcuts = function() {
      return this.mShortcuts != null ? this.mShortcuts : this.mShortcuts = [
        this._createRatingShortcut(), new KeyShortcut(['f', 'c'], this.fave, 'fave the picture', this._canFave), new KeyShortcut('u', this.unfave, 'unfave the picture', (function(_this) {
          return function() {
            return _this.showing(_this.removeFaveLink);
          };
        })(this))
      ];
    };

    FavePanel.prototype._canFave = function() {
      var ref;
      return (typeof gallery !== "undefined" && gallery !== null ? (ref = gallery.slide) != null ? ref.active() : void 0 : void 0) && this.picture.favable();
    };

    FavePanel.prototype._ratingShortcutsEnabled = function() {
      return this._showingPopup() || this.showing(this.ratingDisplayPanel);
    };

    FavePanel.prototype._createRatingShortcut = function() {
      return new KeyShortcut(['1', '2', '3', '4', '5'], ((function(_this) {
        return function(e) {
          var rating;
          rating = e.keyCode - 48;
          console.log(rating);
          return _this._changeRating(rating);
        };
      })(this)), 'set fave rating accordingly', this._canFave);
    };

    return FavePanel;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PictureCellView = (function(superClass) {
    extend(PictureCellView, superClass);

    function PictureCellView(cellDiv, picture) {
      this.cellDiv = cellDiv;
      this.picture = picture;
      this._highlight = bind(this._highlight, this);
      this._picId = bind(this._picId, this);
      this._initRating = bind(this._initRating, this);
      this._initDom = bind(this._initDom, this);
      this._registerEvents = bind(this._registerEvents, this);
      this.setBoarderClasses = bind(this.setBoarderClasses, this);
      this.ratingDiv = this.cellDiv.find('#ratingInGrid:first');
      this.loadingIndicator = this.cellDiv.find('#loading-indicator:first');
      this._registerEvents();
      this._initDom();
    }

    PictureCellView.prototype.setBoarderClasses = function(boundaryTypes) {
      var c, j, len, results;
      results = [];
      for (j = 0, len = boundaryTypes.length; j < len; j++) {
        c = boundaryTypes[j];
        results.push(this.cellDiv.addClass(c));
      }
      return results;
    };

    PictureCellView.prototype._registerEvents = function() {
      this.cellDiv.click((function(_this) {
        return function() {
          return _this.picture.trigger('clicked', _this.picture);
        };
      })(this));
      this.picture.bind('fully-ready', (function(_this) {
        return function() {
          return _this.loadingIndicator.hide();
        };
      })(this));
      this.picture.bind('highlighted', this._highlight);
      return this.picture.bind('data-updated', this._initDom);
    };

    PictureCellView.prototype._initDom = function() {
      var img;
      this.cellDiv.attr('id', this._picId());
      img = this.cellDiv.find('#imgItem');
      img.attr('src', this.picture.smallUrl());
      this.setVisible(this.loadingIndicator, !this.picture.ready);
      this.cellDiv.find('.hasTwipsy').twipsy();
      return this._initRating();
    };

    PictureCellView.prototype._initRating = function() {
      var i, ratingText;
      ratingText = this.picture.favable() ? ((function() {
        var j, ref, results;
        results = [];
        for (i = j = 0, ref = this.picture.data.rating; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          results.push('★');
        }
        return results;
      }).call(this)).join('') : '';
      return this.ratingDiv.text(ratingText);
    };

    PictureCellView.prototype._picId = function() {
      return 'pic-' + this.picture.id;
    };

    PictureCellView.prototype._highlight = function() {
      return this.cellDiv.addClass('highlighted');
    };

    return PictureCellView;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PictureRetrieverByOffset = (function(superClass) {
    extend(PictureRetrieverByOffset, superClass);

    function PictureRetrieverByOffset(_filterOptsFn, pageSize, _retrievePath, _offsetFn) {
      this._filterOptsFn = _filterOptsFn;
      this.pageSize = pageSize;
      this._retrievePath = _retrievePath;
      this._offsetFn = _offsetFn;
      this._offsetByPage = bind(this._offsetByPage, this);
      this._pageOpts = bind(this._pageOpts, this);
      if (this._offsetFn == null) {
        this._offsetFn = this._offsetByPage;
      }
      PictureRetrieverByOffset.__super__.constructor.call(this, this._filterOptsFn, this.pageSize, this._retrievePath);
    }

    PictureRetrieverByOffset.prototype._pageOpts = function() {
      return {
        limit: this.pageSize,
        offset: this._offsetFn()
      };
    };

    PictureRetrieverByOffset.prototype._offsetByPage = function() {
      return this.pageSize * (this._currentPage - 1);
    };

    return PictureRetrieverByOffset;

  })(PictureRetriever);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.PictureRetrieverByPage = (function(superClass) {
    extend(PictureRetrieverByPage, superClass);

    function PictureRetrieverByPage() {
      this._pageOpts = bind(this._pageOpts, this);
      return PictureRetrieverByPage.__super__.constructor.apply(this, arguments);
    }

    PictureRetrieverByPage.prototype._pageOpts = function() {
      return {
        num: this.pageSize,
        page: this._currentPage,
        real_time: true
      };
    };

    return PictureRetrieverByPage;

  })(PictureRetriever);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  klekr.Reporter = (function() {
    function Reporter() {
      this.pictureString = bind(this.pictureString, this);
      this.help = bind(this.help, this);
      this.exportPictures = bind(this.exportPictures, this);
    }

    Reporter.prototype.exportPictures = function(limit, start, favedOnly) {
      var index, picture, pictures, toPrint;
      if (limit == null) {
        limit = 20;
      }
      if (start == null) {
        start = 0;
      }
      if (favedOnly == null) {
        favedOnly = false;
      }
      pictures = (function() {
        var i, len, ref, results;
        ref = gallery.pictures;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          picture = ref[i];
          if ((!favedOnly || picture.faved()) && !picture.data.noLongerValid) {
            results.push(picture);
          }
        }
        return results;
      })();
      toPrint = (function() {
        var i, len, ref, results;
        ref = pictures.slice(start, limit);
        results = [];
        for (index = i = 0, len = ref.length; i < len; index = ++i) {
          picture = ref[index];
          results.push(this.pictureString(picture, index));
        }
        return results;
      }).call(this);
      return console.log(toPrint.join(' ') + "For more pictures go to \nhttp://klekr.com/editors_choice\n");
    };

    Reporter.prototype.help = function() {
      return "limit = 20, start = 0, faveOnly = false";
    };

    Reporter.prototype.pictureString = function(picture, index) {
      return ((index + 1) + "\n\n" + picture.largeUrl + "\n" + picture.ownerName + "\nhttp://klekr.com" + picture.ownerPath + "\n" + picture.title + "\n" + picture.description + "\n" + picture.flickrPageUrl + "\n\n\n").replace("https:", "http:");
    };

    return Reporter;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  klekr.ScrollControl = (function(superClass) {
    extend(ScrollControl, superClass);

    function ScrollControl(canScroll) {
      var onScroll;
      this.canScroll = canScroll;
      this._triggerJumpEvent = bind(this._triggerJumpEvent, this);
      this._jump = bind(this._jump, this);
      this._getDelta = bind(this._getDelta, this);
      this._overThreshod = bind(this._overThreshod, this);
      this._move = bind(this._move, this);
      this._onScroll = bind(this._onScroll, this);
      this.reset = bind(this.reset, this);
      this.reset();
      onScroll = _.throttle(this._onScroll, 50);
      if (window.addEventListener) {
        document.addEventListener("DOMMouseScroll", onScroll, false);
      }
      document.onmousewheel = onScroll;
    }

    ScrollControl.prototype.reset = function() {
      return this.position = 0;
    };

    ScrollControl.prototype._onScroll = function(e) {
      var delta, towardsLeft;
      delta = this._getDelta(e || window.event);
      if (this.canScroll(towardsLeft = delta < 0)) {
        return this._move(delta);
      }
    };

    ScrollControl.prototype._move = function(delta) {
      var oldPosition, overThreshod;
      if (this.position === (0/0)) {
        this.position = 0;
      }
      oldPosition = this.position;
      this.position += delta;
      overThreshod = this._overThreshod();
      if (overThreshod) {
        this.position = this.position > 0 ? 5 : -5;
      }
      if (this.position !== oldPosition) {
        this.trigger('move', this.position);
      }
      if (overThreshod) {
        return this._jump();
      }
    };

    ScrollControl.prototype._overThreshod = function() {
      return Math.abs(this.position) >= 5;
    };

    ScrollControl.prototype._getDelta = function(event) {
      if (event.wheelDelta) {
        return -event.wheelDelta / 60;
      } else if (event.detail) {
        return event.detail / 2;
      } else {

      }
    };

    ScrollControl.prototype._jump = function() {
      if (this.jumpFunc == null) {
        this.jumpFunc = _.throttle(this._triggerJumpEvent, 500);
      }
      return this.jumpFunc();
    };

    ScrollControl.prototype._triggerJumpEvent = function() {
      if (this._overThreshod()) {
        this.trigger('jump', this.position < 0);
        return this.reset();
      }
    };

    return ScrollControl;

  })(Events);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  klekr.SocialSharing = (function(superClass) {
    extend(SocialSharing, superClass);

    function SocialSharing(path, params) {
      this.path = path;
      this.params = params != null ? params : {};
      this._url = bind(this._url, this);
      this.update = bind(this.update, this);
      this.updatable = bind(this.updatable, this);
      if (this._shareLink == null) {
        this._shareLink = $('#top-banner-left .addthis_toolbox[data-dynamic-url="true" ]');
      }
      if (this.updatable()) {
        this.update();
        $(window).bind('hashchange', this.update);
      }
    }

    SocialSharing.prototype.updatable = function() {
      return this._shareLink.length > 0;
    };

    SocialSharing.prototype.update = function() {
      var url;
      if (this.updatable()) {
        url = this._url();
        this._shareLink.attr({
          'addthis:url': url
        });
        if (typeof addthis !== "undefined" && addthis !== null) {
          return addthis.update('share', 'url', url);
        }
      }
    };

    SocialSharing.prototype._url = function() {
      var search;
      search = _.isEmpty(this.params) ? '' : '?' + $.param(this.params);
      return window.location.hostname + ("" + this.path + search + "#" + ($.param.fragment()));
    };

    return SocialSharing;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.StreamPanel = (function(superClass) {
    extend(StreamPanel, superClass);

    function StreamPanel() {
      this._displayAlternativeLink = bind(this._displayAlternativeLink, this);
      this._bindAdjustmentLinks = bind(this._bindAdjustmentLinks, this);
      this._bindCollectingOperations = bind(this._bindCollectingOperations, this);
      this.startCollectingLink = $('#startCollecting');
      this.stopCollectingLink = $('#stopCollecting');
      this.noncollectingOperationDiv = $('#noncollectingStreamOperations');
      this.collectingOperationDiv = $('#collectingStreamOperations');
      this.rating = this.collectingOperationDiv.find('#rating');
      this.sourceAddedPopup = $('#source-added-popup');
      $('#source-added-popup #okay').click((function(_this) {
        return function() {
          return _this.closePopup(_this.sourceAddedPopup);
        };
      })(this));
      this._bindCollectingOperations();
      this._bindAdjustmentLinks();
      this._displayAlternativeLink();
    }

    StreamPanel.prototype._bindCollectingOperations = function() {
      this.startCollectingLink.bind('ajax:success', (function(_this) {
        return function() {
          _this.noncollectingOperationDiv.hide();
          _this.collectingOperationDiv.show();
          return _this.popup(_this.sourceAddedPopup);
        };
      })(this));
      return this.stopCollectingLink.bind('ajax:success', (function(_this) {
        return function() {
          _this.noncollectingOperationDiv.show();
          return _this.collectingOperationDiv.hide();
        };
      })(this));
    };

    StreamPanel.prototype._bindAdjustmentLinks = function() {
      var adjustmentLinks;
      adjustmentLinks = this.collectingOperationDiv.find('.rating-adjustment-link');
      adjustmentLinks.bind('ajax:success', (function(_this) {
        return function(e, newRating) {
          _this.rating.text(newRating);
          return adjustmentLinks.removeClass('disabled');
        };
      })(this));
      return adjustmentLinks.click((function(_this) {
        return function(e) {
          if ($(e.target).hasClass('disabled')) {
            return false;
          } else {
            adjustmentLinks.addClass('disabled');
            return true;
          }
        };
      })(this));
    };

    StreamPanel.prototype._displayAlternativeLink = function() {
      var alternativeLink, windowTooSmall;
      alternativeLink = $('#alternative-stream');
      windowTooSmall = alternativeLink.width() > ($(window).width() / 3.3);
      return this.setVisible(alternativeLink, !windowTooSmall);
    };

    return StreamPanel;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.GeneralView = (function(superClass) {
    extend(GeneralView, superClass);

    function GeneralView() {
      this._isFullScreenMobile = bind(this._isFullScreenMobile, this);
      this._updateFullScreenLayout = bind(this._updateFullScreenLayout, this);
      this._updateFullScreenButton = bind(this._updateFullScreenButton, this);
      this._initFullScreenButton = bind(this._initFullScreenButton, this);
      this._adjustFrames = bind(this._adjustFrames, this);
      this._resetScorllIndication = bind(this._resetScorllIndication, this);
      this.inidicateScroll = bind(this.inidicateScroll, this);
      this.updateShareLink = bind(this.updateShareLink, this);
      this.showEmptyGalleryMessage = bind(this.showEmptyGalleryMessage, this);
      this.updateModeIndicator = bind(this.updateModeIndicator, this);
      this.updateNavigation = bind(this.updateNavigation, this);
      this.initLayout = bind(this.initLayout, this);
      this._leftArrow = $('#leftArrow');
      this._rightArrow = $('#rightArrow');
      this._indicator = $('#indicator');
      this._indicatorPanel = $('#mode-indicator');
      this.bottomLeft = $('#bottomLeft');
      this.socialSharing = new klekr.SocialSharing(exhibit_slideshow_path());
      this._initFullScreenButton();
      $(window).resize(_.debounce(this.initLayout, 500));
      this.initLayout();
    }

    GeneralView.prototype.initLayout = function() {
      if (this._updateDimensions()) {
        this._adjustArrowsPosition();
        this._adjustFrames();
        this._updateFullScreenButton();
        this._updateFullScreenLayout();
        return this.trigger('layout-changed');
      }
    };

    GeneralView.prototype.updateNavigation = function(forwardable, backwardable) {
      $('.side-nav').show();
      this.fadeInOut(this._leftArrow, backwardable);
      this.fadeInOut(this._rightArrow, forwardable);
      return this._resetScorllIndication();
    };

    GeneralView.prototype.updateModeIndicator = function(toGrid) {
      var position;
      this._indicatorPanel.show();
      this._indicatorPanel.attr('title', toGrid ? 'Show Picture' : 'Show Grid');
      position = toGrid ? 26 : 0;
      return this._indicator.css('left', position + "px");
    };

    GeneralView.prototype.toggleModeClick = function(listener) {
      return this._indicatorPanel.click(listener);
    };

    GeneralView.prototype.nextClick = function(listener) {
      return $('#right').click(listener);
    };

    GeneralView.prototype.showEmptyGalleryMessage = function() {
      return $('#empty-gallery-message').show();
    };

    GeneralView.prototype.previousClick = function(listener) {
      return $('#left').click(listener);
    };

    GeneralView.prototype.updateShareLink = function(filterSettings) {
      if (filterSettings == null) {
        filterSettings = {};
      }
      if (this.socialSharing.updatable()) {
        this.socialSharing.path = exhibit_slideshow_path();
        this.socialSharing.params = _.extend({
          collector_id: klekr.Global.currentCollector.id
        }, filterSettings);
        return this.socialSharing.update();
      }
    };

    GeneralView.prototype.inidicateScroll = function(position) {
      var leftPadding, offset, rightPadding;
      leftPadding = rightPadding = 10;
      if ((offset = position * 2) < 0) {
        leftPadding = 10 + offset;
      } else {
        rightPadding = 10 - offset;
      }
      this._leftArrow.css('padding-left', leftPadding + 'px');
      return this._rightArrow.css('padding-right', rightPadding + 'px');
    };

    GeneralView.prototype._resetScorllIndication = function() {
      return this.inidicateScroll(0);
    };

    GeneralView.prototype._updateDimensions = function() {
      var heightReserve, newHeight, newWidth, ref, ref1, ref2;
      ref = this.windowDimension(), newWidth = ref[0], newHeight = ref[1];
      heightReserve = this._isFullScreenMobile() ? 0 : 93;
      if ([this.windowWidth, this.windowHeight] !== [newWidth, newHeight]) {
        ref1 = [newWidth, newHeight], this.windowWidth = ref1[0], this.windowHeight = ref1[1];
        ref2 = [this.windowWidth - 80, this.windowHeight - heightReserve], this.displayWidth = ref2[0], this.displayHeight = ref2[1];
        return true;
      } else {
        return false;
      }
    };

    GeneralView.prototype._adjustArrowsPosition = function() {
      var sideArrowHeight;
      sideArrowHeight = (this.displayHeight - 150) + "px";
      this._leftArrow.css('line-height', sideArrowHeight);
      return this._rightArrow.css('line-height', sideArrowHeight);
    };

    GeneralView.prototype._adjustFrames = function() {
      var bottomOffset, topLeftWidth;
      bottomOffset = this.displayHeight + 51;
      $('#bottom-banner').css('top', (bottomOffset + 10) + 'px');
      topLeftWidth = this.windowWidth / 2 + 40;
      return $('#top-banner-left').css('max-width', topLeftWidth + 'px');
    };

    GeneralView.prototype._initFullScreenButton = function() {
      if (this._fullScreenButton == null) {
        this._fullScreenButton = $('#full-screen-button');
      }
      if (fullScreenApi.supportsFullScreen) {
        this._fullScreenButton.show();
        return this._fullScreenButton.click(this.toggleFullScreen);
      }
    };

    GeneralView.prototype._updateFullScreenButton = function() {
      var newTitle;
      newTitle = fullScreenApi.isFullScreen() ? 'Exit full screen' : 'Full screen (recommended)';
      return this._fullScreenButton.attr('title', newTitle);
    };

    GeneralView.prototype._updateFullScreenLayout = function() {
      var bottomLeftBottom, isFullScreenMobile, pictureAreaTop;
      isFullScreenMobile = this._isFullScreenMobile();
      pictureAreaTop = isFullScreenMobile ? "0px" : "60px";
      bottomLeftBottom = isFullScreenMobile ? "5px" : "10px";
      $("#slide #pictureArea").css("top", pictureAreaTop);
      $(".fullscreen-hidden").toggleClass("fullscreen", isFullScreenMobile);
      return $("#bottomLeft").css("bottom", bottomLeftBottom);
    };

    GeneralView.prototype._isFullScreenMobile = function() {
      return fullScreenApi.isFullScreen() && this.isMobile();
    };

    return GeneralView;

  })(ViewBase);

}).call(this);


























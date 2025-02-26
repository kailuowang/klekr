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

  window.StreamImporterBase = (function(superClass) {
    extend(StreamImporterBase, superClass);

    function StreamImporterBase() {
      this._finish = bind(this._finish, this);
      this._import = bind(this._import, this);
      return StreamImporterBase.__super__.constructor.apply(this, arguments);
    }

    StreamImporterBase.prototype._import = function(streamInfo, callback) {
      return klekr.Global.server.post(flickr_streams_path(), streamInfo, (function(_this) {
        return function(newSources) {
          _this.trigger('sources-imported', newSources);
          return callback();
        };
      })(this));
    };

    StreamImporterBase.prototype._finish = function() {
      this.closePopup(this._popup);
      return this.trigger('import-finished');
    };

    return StreamImporterBase;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  klekr.FlexibleStreamsImporterBase = (function(superClass) {
    extend(FlexibleStreamsImporterBase, superClass);

    function FlexibleStreamsImporterBase(popupId, triggerLinkId) {
      this._showSourceAddedMessage = bind(this._showSourceAddedMessage, this);
      this._hasSource = bind(this._hasSource, this);
      this._sourceAdded = bind(this._sourceAdded, this);
      this._sync = bind(this._sync, this);
      this._syncAll = bind(this._syncAll, this);
      this._finish = bind(this._finish, this);
      this._reportProgress = bind(this._reportProgress, this);
      this._add = bind(this._add, this);
      this._startAdding = bind(this._startAdding, this);
      this._unsubscribedStreams = bind(this._unsubscribedStreams, this);
      this._doImport = bind(this._doImport, this);
      this._showStreams = bind(this._showStreams, this);
      this._close = bind(this._close, this);
      this._init = bind(this._init, this);
      var streams_grid;
      this._popup = $(popupId);
      streams_grid = this._popup.find('.sources-grid:first');
      this._streams_gridview = new SourcesGridview(streams_grid);
      this._loading = this._popup.find('#loading-streams');
      this._doImportLink = this._popup.find('#do-import-streams');
      this._importProgress = this._popup.find('#import-streams-progress');
      this._progressBar = this._popup.find('#streams-progress-bar');
      this._streamsDisplay = this._popup.find('#display-streams');
      this.sourceAddedMessage = this._popup.find('#source-added-message');
      $(triggerLinkId).click_(this._init);
      this._doImportLink.click_(this._doImport);
      this._popup.find('.close-btn').click_(this._close);
      klekr.Global.broadcaster.bind('source-added', this._sourceAdded);
    }

    FlexibleStreamsImporterBase.prototype._init = function() {
      this.popup(this._popup);
      this._loading.show();
      this._importProgress.hide();
      this._streamsDisplay.hide();
      this.sourceAddedMessage.hide();
      return klekr.Global.server.get(this._importSourcesUrl(), {}, (function(_this) {
        return function(data) {
          var d;
          _this.streams = (function() {
            var i, len, results;
            results = [];
            for (i = 0, len = data.length; i < len; i++) {
              d = data[i];
              results.push(new Source(d));
            }
            return results;
          })();
          return _this._showStreams(_this.streams);
        };
      })(this));
    };

    FlexibleStreamsImporterBase.prototype._close = function() {
      this.streams = [];
      return this._popup.close();
    };

    FlexibleStreamsImporterBase.prototype._showStreams = function(streams) {
      this._streams_gridview.load(streams);
      this._loading.hide();
      this._doImportLink.show();
      return this._streamsDisplay.fadeIn();
    };

    FlexibleStreamsImporterBase.prototype._doImport = function() {
      this._doImportLink.hide();
      this._importProgress.fadeIn();
      this._reportProgress(0, 1);
      return this._startAdding(this._unsubscribedStreams());
    };

    FlexibleStreamsImporterBase.prototype._unsubscribedStreams = function() {
      return _(this.streams).select(function(stream) {
        return !stream.subscribed;
      });
    };

    FlexibleStreamsImporterBase.prototype._startAdding = function(streams) {
      return new queffee.CollectionWorkQ({
        collection: streams,
        operation: this._add,
        onProgress: (function(_this) {
          return function(p) {
            return _this._reportProgress(p, streams.length);
          };
        })(this),
        onFinish: (function(_this) {
          return function() {
            return _this._finish(streams);
          };
        })(this)
      }).start();
    };

    FlexibleStreamsImporterBase.prototype._add = function(stream, callback) {
      return klekr.Global.server.put(subscribe_flickr_stream_path(stream), {}, (function(_this) {
        return function() {
          _this.trigger('sources-imported', [stream]);
          return callback();
        };
      })(this));
    };

    FlexibleStreamsImporterBase.prototype._reportProgress = function(progress, total) {
      return this._progressBar.reportprogress(progress * 100 / total);
    };

    FlexibleStreamsImporterBase.prototype._finish = function(streams) {
      this._syncAll(streams);
      this.closePopup(this._popup);
      return this.trigger('import-finished');
    };

    FlexibleStreamsImporterBase.prototype._syncAll = function(streams) {
      return klekr.Global.server.post(sync_many_flickr_streams_path(), {
        ids: _(streams).map(function(s) {
          return s.id;
        })
      });
    };

    FlexibleStreamsImporterBase.prototype._sync = function(source) {
      return klekr.Global.server.put(sync_flickr_stream_path(source));
    };

    FlexibleStreamsImporterBase.prototype._sourceAdded = function(source) {
      if (this._hasSource(source)) {
        this._showSourceAddedMessage();
        return this._sync(source);
      }
    };

    FlexibleStreamsImporterBase.prototype._hasSource = function(source) {
      return (this.streams != null) && _(this.streams).any((function(_this) {
        return function(stream) {
          return stream.id === source.id;
        };
      })(this));
    };

    FlexibleStreamsImporterBase.prototype._showSourceAddedMessage = function() {
      this.sourceAddedMessage.hide();
      return this.sourceAddedMessage.fadeIn();
    };

    return FlexibleStreamsImporterBase;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.AddByUserImporter = (function(superClass) {
    extend(AddByUserImporter, superClass);

    function AddByUserImporter() {
      this._add = bind(this._add, this);
      this._showSearchResult = bind(this._showSearchResult, this);
      this._doSearch = bind(this._doSearch, this);
      this._close = bind(this._close, this);
      this.show = bind(this.show, this);
      var streams_grid;
      this._popup = $('#import-by-user');
      this._notFound = this._popup.find('#not-found');
      this._form = this._popup.find('#search-user-form');
      this._addingUser = this._popup.find('#adding-user');
      streams_grid = this._popup.find('.sources-grid:first');
      this._streams_gridview = new SourcesGridview(streams_grid);
      this._loading = $('#searching-user');
      this._resultsGrid = this._popup.find('#search-result');
      $('#add-by-user-link').click_(this.show);
      this._addButton = this._popup.find('#do-add');
      this._addButton.click_(this._add);
      this._popup.find('.close-btn').click_(this._close);
      this._popup.find('#submit').click_(this._doSearch);
    }

    AddByUserImporter.prototype.show = function() {
      this._addButton.show();
      this._notFound.hide();
      return this.popup(this._popup);
    };

    AddByUserImporter.prototype._close = function() {
      return this._popup.close();
    };

    AddByUserImporter.prototype._doSearch = function() {
      var keyword;
      keyword = _.str.trim(this._popup.find('#keyword').val());
      if (keyword.length > 0) {
        this._loading.show();
        this._form.hide();
        this._resultsGrid.hide();
        return klekr.Global.server.post(search_users_path(), {
          keyword: keyword
        }, this._showSearchResult);
      }
    };

    AddByUserImporter.prototype._showSearchResult = function(data) {
      var hasResults;
      this._loading.hide();
      this._form.show();
      this._results = data;
      if ((hasResults = this._results.length > 0)) {
        this._streams_gridview.load(this._results);
        this._addingUser.hide();
        this._resultsGrid.slideDown();
      }
      return this.setVisible(this._notFound, !hasResults);
    };

    AddByUserImporter.prototype._add = function() {
      this._addingUser.show();
      this._addButton.hide();
      return new queffee.CollectionWorkQ({
        collection: this._results,
        operation: (function(_this) {
          return function(streamInfo, callback) {
            return _this._import(streamInfo, callback);
          };
        })(this),
        onFinish: (function(_this) {
          return function() {
            _this._addingUser.hide();
            return _this._finish();
          };
        })(this)
      }).start();
    };

    return AddByUserImporter;

  })(StreamImporterBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  klekr.ContactsImporter = (function(superClass) {
    extend(ContactsImporter, superClass);

    function ContactsImporter() {
      this._importSourcesUrl = bind(this._importSourcesUrl, this);
      ContactsImporter.__super__.constructor.call(this, '#import-contacts-popup', '#add-contacts-link');
    }

    ContactsImporter.prototype._importSourcesUrl = function() {
      return contacts_users_path();
    };

    return ContactsImporter;

  })(klekr.FlexibleStreamsImporterBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.EditorStreamsImporter = (function(superClass) {
    extend(EditorStreamsImporter, superClass);

    function EditorStreamsImporter() {
      this._importSourcesUrl = bind(this._importSourcesUrl, this);
      EditorStreamsImporter.__super__.constructor.call(this, '#import-editor-streams-popup', '#add-editor-streams-link');
    }

    EditorStreamsImporter.prototype._importSourcesUrl = function() {
      return editor_recommendations_path();
    };

    return EditorStreamsImporter;

  })(klekr.FlexibleStreamsImporterBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.GoogleReaderImporter = (function(superClass) {
    extend(GoogleReaderImporter, superClass);

    function GoogleReaderImporter() {
      this._reportProgress = bind(this._reportProgress, this);
      this._importSubscriptions = bind(this._importSubscriptions, this);
      this._getUserFromTitle = bind(this._getUserFromTitle, this);
      this._getType = bind(this._getType, this);
      this._createSubscription = bind(this._createSubscription, this);
      this._importText = bind(this._importText, this);
      this._registerEvents = bind(this._registerEvents, this);
      this._importAll = bind(this._importAll, this);
      this._init = bind(this._init, this);
      this._popup = $('#import-google-reader-popup');
      this.file = this._popup.find('#google-reader-file');
      this.doImportLink = this._popup.find('#do-import');
      this.progressPanel = this._popup.find('#import-progress');
      this.progressBar = this._popup.find('#progress-bar');
      this.startImportLink = $('#import-google-reader-link');
      this.hintPanel = this._popup.find('#hint');
      this._registerEvents();
    }

    GoogleReaderImporter.prototype._init = function() {
      this.progressPanel.hide();
      return this.popup(this._popup);
    };

    GoogleReaderImporter.prototype._importAll = function() {
      var f, reader;
      this.hintPanel.hide();
      f = this.file[0].files[0];
      if (f != null) {
        reader = new FileReader();
        reader.onload = (function(_this) {
          return function(e) {
            var subscriptions;
            subscriptions = _this._importText(e.target.result.toString());
            return _this._importSubscriptions(subscriptions);
          };
        })(this);
        return reader.readAsText(f);
      }
    };

    GoogleReaderImporter.prototype._registerEvents = function() {
      this.startImportLink.click_(this._init);
      this.doImportLink.click_(this._importAll);
      return this._popup.find('#hint-link').click_((function(_this) {
        return function() {
          return _this.hintPanel.slideToggle();
        };
      })(this));
    };

    GoogleReaderImporter.prototype._importText = function(text) {
      var match, reg, results;
      reg = /title="(.+)"\s.+\n.+photos\_(.+)\.gne\?.?.?id=(\d+@...)&amp/gm;
      results = [];
      while ((match = reg.exec(text)) !== null) {
        results.push(this._createSubscription(match));
      }
      return results;
    };

    GoogleReaderImporter.prototype._createSubscription = function(match) {
      return {
        username: this._getUserFromTitle(match[1]),
        user_id: match[3],
        type: this._getType(match[2])
      };
    };

    GoogleReaderImporter.prototype._getType = function(readerType) {
      switch (readerType) {
        case 'faves':
          return 'FaveStream';
        case 'public':
          return 'UploadStream';
      }
    };

    GoogleReaderImporter.prototype._getUserFromTitle = function(title) {
      return title.replace('Uploads from ', '').replace("s' favorites", '').replace("'s favorites", '');
    };

    GoogleReaderImporter.prototype._importSubscriptions = function(subs) {
      this.progressPanel.show();
      this._reportProgress(0, subs.length);
      return new queffee.CollectionWorkQ({
        collection: subs,
        operation: (function(_this) {
          return function(streamInfo, callback) {
            return _this._import(streamInfo, callback);
          };
        })(this),
        onFinish: (function(_this) {
          return function() {
            return _this._finish();
          };
        })(this),
        onProgress: (function(_this) {
          return function(progress) {
            return _this._reportProgress(progress, subs.length);
          };
        })(this)
      }).start();
    };

    GoogleReaderImporter.prototype._reportProgress = function(progress, total) {
      return this.progressBar.reportprogress(progress * 100 / total);
    };

    return GoogleReaderImporter;

  })(StreamImporterBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  klekr.GroupStreamsImporter = (function(superClass) {
    extend(GroupStreamsImporter, superClass);

    function GroupStreamsImporter() {
      this._importSourcesUrl = bind(this._importSourcesUrl, this);
      GroupStreamsImporter.__super__.constructor.call(this, '#import-group-streams-popup', '#add-group-streams-link');
    }

    GroupStreamsImporter.prototype._importSourcesUrl = function() {
      return collector_group_streams_path({
        collector_id: klekr.Global.currentCollector.id
      });
    };

    return GroupStreamsImporter;

  })(klekr.FlexibleStreamsImporterBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.MySources = (function() {
    function MySources() {
      this._bindImporterEvents = bind(this._bindImporterEvents, this);
      this._display = bind(this._display, this);
      this._sourcesImported = bind(this._sourcesImported, this);
      this._sourcesImportDone = bind(this._sourcesImportDone, this);
      this._loadSource = bind(this._loadSource, this);
      this.init = bind(this.init, this);
      this.contactImporter = new klekr.ContactsImporter;
      this.editorStreamsImporter = new EditorStreamsImporter;
      this.groupStreamsImporter = new klekr.GroupStreamsImporter;
      this.addByUserImporter = new AddByUserImporter;
      this.googleReaderImporter = new GoogleReaderImporter;
      this.view = new MySourcesView;
      this._bindImporterEvents([this.addByUserImporter, this.contactImporter, this.editorStreamsImporter, this.googleReaderImporter, this.groupStreamsImporter]);
    }

    MySources.prototype.init = function(onInit) {
      this.view.clear();
      return this._loadSource(1, (function(_this) {
        return function(hasSources) {
          _this.view.onAllSourcesLoaded(!hasSources);
          return typeof onInit === "function" ? onInit() : void 0;
        };
      })(this));
    };

    MySources.prototype._loadSource = function(page, onFinish) {
      return klekr.Global.server.get(my_sources_flickr_streams_path(), {
        page: page,
        per_page: 50
      }, (function(_this) {
        return function(data) {
          var d, sources;
          sources = (function() {
            var i, len, results;
            results = [];
            for (i = 0, len = data.length; i < len; i++) {
              d = data[i];
              results.push(new Source(d));
            }
            return results;
          })();
          _this._display(sources);
          if (sources.length > 0) {
            return _this._loadSource(page + 1, onFinish);
          } else {
            return typeof onFinish === "function" ? onFinish(page > 1) : void 0;
          }
        };
      })(this));
    };

    MySources.prototype._sourcesImportDone = function() {
      return this.init((function(_this) {
        return function() {
          return klekr.Global.server.get(info_collector_path({
            id: 'current'
          }), {}, function(data) {
            return _this.view.showNewSourcesAddedPanel(data);
          });
        };
      })(this));
    };

    MySources.prototype._sourcesImported = function(sources) {
      this.view.onAllSourcesLoaded(false);
      return this._display(sources);
    };

    MySources.prototype._display = function(sources) {
      var i, len, results, source;
      results = [];
      for (i = 0, len = sources.length; i < len; i++) {
        source = sources[i];
        results.push(this.view.addSource(source));
      }
      return results;
    };

    MySources.prototype._bindImporterEvents = function(importers) {
      var i, importer, len, results;
      results = [];
      for (i = 0, len = importers.length; i < len; i++) {
        importer = importers[i];
        results.push(importer.bind('import-finished', this._sourcesImportDone));
      }
      return results;
    };

    return MySources;

  })();

  $(function() {
    return new MySources().init();
  });

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.MySourcesView = (function(superClass) {
    extend(MySourcesView, superClass);

    function MySourcesView() {
      this._setExpandLinkText = bind(this._setExpandLinkText, this);
      this._toggleManagementPanel = bind(this._toggleManagementPanel, this);
      this._sourcesGridView = bind(this._sourcesGridView, this);
      this._sortCategories = bind(this._sortCategories, this);
      this._updateStar = bind(this._updateStar, this);
      this._ensureCategory = bind(this._ensureCategory, this);
      this._createCategoryDiv = bind(this._createCategoryDiv, this);
      this._registerCellEvents = bind(this._registerCellEvents, this);
      this.showNewSourcesAddedPanel = bind(this.showNewSourcesAddedPanel, this);
      this.showContacts = bind(this.showContacts, this);
      this.onAllSourcesLoaded = bind(this.onAllSourcesLoaded, this);
      this.addSource = bind(this.addSource, this);
      this.clear = bind(this.clear, this);
      this.template = $('#star-category-template');
      this.container = $('#sources-list');
      this.expandLink = $('#expand-management');
      this.importPanel = $('#sources-import-panel');
      this.indicator = $('#loading-sources-indicator');
      this.newSourcesAddedPanel = $('#new-sources-added');
      $('#close-new-sources-added').click_((function(_this) {
        return function() {
          return _this.newSourcesAddedPanel.slideUp();
        };
      })(this));
      this.expandLink.click_(this._toggleManagementPanel);
      $('#add-more-sources').click_(this._toggleManagementPanel);
      klekr.Global.broadcaster.bind('source-added', this.addSource);
    }

    MySourcesView.prototype.clear = function() {
      this.container.empty();
      this.indicator.show();
      return this.categories = {};
    };

    MySourcesView.prototype.addSource = function(source) {
      var base;
      return typeof (base = this._ensureCategory(source.rating).addSource(source)).registerEvents === "function" ? base.registerEvents() : void 0;
    };

    MySourcesView.prototype.onAllSourcesLoaded = function(empty) {
      this.setVisible($('#empty-sources'), empty);
      this.setVisible($('#add-more-sources'), !empty);
      this.setVisible(this.importPanel, empty);
      this._setExpandLinkText(empty);
      $('#sources-management').show();
      this.indicator.hide();
      if (!empty) {
        return this._registerCellEvents();
      }
    };

    MySourcesView.prototype.showContacts = function() {
      return contacts - list;
    };

    MySourcesView.prototype.showNewSourcesAddedPanel = function(collectorInfo) {
      this.newSourcesAddedPanel.find('#num-of-sources').text(collectorInfo.sources);
      $(window).scrollTop(0);
      return this.newSourcesAddedPanel.slideDown();
    };

    MySourcesView.prototype._registerCellEvents = function() {
      var category, j, len, ref, results;
      ref = _(this.categories).values();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        category = ref[j];
        results.push(category.registerEvents());
      }
      return results;
    };

    MySourcesView.prototype._createCategoryDiv = function(star) {
      var newStarCategory;
      newStarCategory = this.template.clone();
      newStarCategory.attr('id', 'star' + star);
      this._updateStar(newStarCategory, star);
      this.container.append(newStarCategory);
      this._sortCategories();
      return newStarCategory.show();
    };

    MySourcesView.prototype._ensureCategory = function(star) {
      var base;
      if (this.categories == null) {
        this.categories = {};
      }
      return (base = this.categories)[star] != null ? base[star] : base[star] = this._sourcesGridView(this._createCategoryDiv(star));
    };

    MySourcesView.prototype._updateStar = function(categoryDiv, star) {
      var i, label, starText;
      label = categoryDiv.find('.stars-label:first');
      starText = ((function() {
        var j, ref, results;
        results = [];
        for (i = j = 0, ref = star; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          results.push('★');
        }
        return results;
      })()).join('');
      return label.text(starText);
    };

    MySourcesView.prototype._sortCategories = function() {
      var categories, category, j, len, sorted_categories;
      categories = $('.star-category');
      sorted_categories = (_(categories).sortBy(function(c) {
        return c.id;
      })).reverse();
      this.container.empty();
      for (j = 0, len = sorted_categories.length; j < len; j++) {
        category = sorted_categories[j];
        this.container.append(category);
      }
      return $('.star-category .stars-label').popover_ext();
    };

    MySourcesView.prototype._sourcesGridView = function(categoryDiv) {
      var cellGrid;
      cellGrid = categoryDiv.find('.sources-grid:first');
      return new SourcesGridview(cellGrid);
    };

    MySourcesView.prototype._toggleManagementPanel = function() {
      this._setExpandLinkText(!this.showing(this.importPanel));
      return this.importPanel.slideToggle((function(_this) {
        return function() {
          if (_this.showing(_this.importPanel)) {
            return $(window).scrollTop(_this.importPanel.offset().top);
          }
        };
      })(this));
    };

    MySourcesView.prototype._setExpandLinkText = function(expanded) {
      var text;
      text = expanded ? "It's easy! 5 ways of adding sources:" : 'I want more sources!';
      return this.expandLink.text(text);
    };

    return MySourcesView;

  })(ViewBase);

}).call(this);
(function() {
  window.Source = (function() {
    function Source(data) {
      $.extend(this, data);
    }

    return Source;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.SourceCell = (function(superClass) {
    extend(SourceCell, superClass);

    function SourceCell(cell, source1) {
      this.cell = cell;
      this.source = source1;
      this._onSourceChange = bind(this._onSourceChange, this);
      this._toggleTopBar = bind(this._toggleTopBar, this);
      this._updateStatus = bind(this._updateStatus, this);
      this._broadcastNewSource = bind(this._broadcastNewSource, this);
      this._add = bind(this._add, this);
      this._remove = bind(this._remove, this);
      this.about = bind(this.about, this);
      this.registerEvents = bind(this.registerEvents, this);
      this.cell.find('.source-icon').attr('src', this.source.iconUrl);
      this.cell.find('.source-icon-link').attr('href', this.source.slideUrl);
      this.cell.find('.source-name').text(this.source.username);
      this.cell.find('.source-type').text(this.source.typeDisplay);
      this.cell.attr('id', 'source-cell-' + this.source.id);
      this.mainPart = this.cell.find('.main-part');
      this.removeBtn = this.cell.find('#remove');
      this.addBtn = this.cell.find('#add');
      this.server = klekr.Global.server;
      this._updateStatus();
      klekr.Global.broadcaster.bind('source-changed', this._onSourceChange);
    }

    SourceCell.prototype.registerEvents = function() {
      this.cell.hover(((function(_this) {
        return function() {
          return _this._toggleTopBar(true);
        };
      })(this)), ((function(_this) {
        return function() {
          return _this._toggleTopBar(false);
        };
      })(this)));
      this.removeBtn.click_(this._remove);
      return this.addBtn.click_(this._add);
    };

    SourceCell.prototype.about = function(source) {
      return this.source.id === source.id;
    };

    SourceCell.prototype._remove = function() {
      this.removeBtn.fadeOut();
      return this.server.put(unsubscribe_flickr_stream_path(this.source), {}, this._broadcastNewSource);
    };

    SourceCell.prototype._add = function() {
      this.addBtn.fadeOut();
      return this.server.put(subscribe_flickr_stream_path(this.source), {}, (function(_this) {
        return function(data) {
          _this._broadcastNewSource(data);
          return klekr.Global.broadcaster.trigger('source-added', _this.source);
        };
      })(this));
    };

    SourceCell.prototype._broadcastNewSource = function(data) {
      return klekr.Global.broadcaster.trigger('source-changed', new Source(data));
    };

    SourceCell.prototype._updateStatus = function() {
      this.setVisible(this.removeBtn, this.source.subscribed);
      this.setVisible(this.addBtn, !this.source.subscribed);
      return this.mainPart.toggleClass('removed', !this.source.subscribed);
    };

    SourceCell.prototype._toggleTopBar = function(visible) {
      if (this.topBar == null) {
        this.topBar = this.cell.find('.top-bar');
      }
      return this.topBar.toggleClass('invisible', !visible);
    };

    SourceCell.prototype._onSourceChange = function(source) {
      if (this.about(source)) {
        this.source = source;
        return this._updateStatus();
      }
    };

    return SourceCell;

  })(ViewBase);

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.SourcesGridview = (function(superClass) {
    extend(SourcesGridview, superClass);

    function SourcesGridview(grid) {
      this.grid = grid;
      this._has = bind(this._has, this);
      this.registerEvents = bind(this.registerEvents, this);
      this.addSource = bind(this.addSource, this);
      this.load = bind(this.load, this);
      this.cellTemplate = this.grid.find('.source-cell:first');
      this.cells = [];
    }

    SourcesGridview.prototype.load = function(sources) {
      var i, len, source;
      this.cells = [];
      this.grid.empty();
      for (i = 0, len = sources.length; i < len; i++) {
        source = sources[i];
        this.addSource(source);
      }
      this.cellTemplate.hide();
      return this.registerEvents();
    };

    SourcesGridview.prototype.addSource = function(source) {
      var cell, newCell;
      if (!this._has(source)) {
        newCell = this.cellTemplate.clone();
        this.grid.append(newCell);
        newCell.show();
        cell = new SourceCell(newCell, source);
        this.cells.push(cell);
        return cell;
      }
    };

    SourcesGridview.prototype.registerEvents = function() {
      var cell, i, len, ref, results;
      ref = this.cells;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        cell = ref[i];
        results.push(cell.registerEvents());
      }
      return results;
    };

    SourcesGridview.prototype._has = function(source) {
      return _(this.cells).any(function(cell) {
        return cell.about(source);
      });
    };

    return SourcesGridview;

  })(ViewBase);

}).call(this);













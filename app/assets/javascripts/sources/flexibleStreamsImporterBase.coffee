class klekr.FlexibleStreamsImporterBase extends ViewBase
  constructor: (popupId, triggerLinkId)->
    @_popup = $(popupId)
    streams_grid = @_popup.find('.sources-grid:first')
    @_streams_gridview = new SourcesGridview(streams_grid)
    @_loading = @_popup.find('#loading-streams')
    @_doImportLink = @_popup.find('#do-import-streams')
    @_importProgress = @_popup.find('#import-streams-progress')
    @_progressBar = @_popup.find('#streams-progress-bar')
    @_streamsDisplay = @_popup.find('#display-streams')
    @sourceAddedMessage = @_popup.find('#source-added-message')
    $(triggerLinkId).click_ this._init
    @_doImportLink.click_ this._doImport
    @_popup.find('.close-btn').click_ this._close
    klekr.Global.broadcaster.bind 'source-added', this._sourceAdded

  _init: =>
    this.popup @_popup
    @_loading.show()
    @_importProgress.hide()
    @_streamsDisplay.hide()
    @sourceAddedMessage.hide()
    klekr.Global.server.get this._importSourcesUrl(), {}, (data) =>
      @streams = (new Source(d) for d in data)
      this._showStreams(@streams)

  _close: =>
    @streams = []
    @_popup.close()

  _showStreams: (streams) =>
    @_streams_gridview.load(streams)
    @_loading.hide()
    @_doImportLink.show()
    @_streamsDisplay.fadeIn()

  _doImport: =>
    @_doImportLink.hide()
    @_importProgress.fadeIn()
    this._reportProgress(0, 1)
    this._startAdding(this._unsubscribedStreams())

  _unsubscribedStreams: =>
    _(@streams).select((stream) -> !stream.subscribed )

  _startAdding: (streams) =>
    new queffee.CollectionWorkQ(
      collection: streams
      operation: this._add
      onProgress: (p) => this._reportProgress(p, streams.length )
      onFinish: => this._finish(streams)
    ).start()

  _add: (stream, callback) =>
    klekr.Global.server.put subscribe_flickr_stream_path(stream), {}, =>
      this.trigger('sources-imported', [stream])
      callback()

  _reportProgress: (progress, total) =>
    @_progressBar.reportprogress(progress * 100 / total)

  _finish: (streams)=>
    this._syncAll(streams)
    this.closePopup(@_popup)
    this.trigger('import-finished')

  _syncAll: (streams)=>
    klekr.Global.server.post sync_many_flickr_streams_path(), {ids: _(streams).map( (s) -> s.id )}

  _sync: (source) =>
    klekr.Global.server.put sync_flickr_stream_path(source)

  _sourceAdded: (source) =>
    if this._hasSource(source)
      this._showSourceAddedMessage()
      this._sync(source)

  _hasSource: (source) =>
    @streams? and _(@streams).any((stream) => stream.id is source.id)

  _showSourceAddedMessage: =>
    @sourceAddedMessage.hide()
    @sourceAddedMessage.fadeIn()



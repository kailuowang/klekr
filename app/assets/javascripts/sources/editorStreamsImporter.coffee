class window.EditorStreamsImporter extends ViewBase
  constructor: (@editorStreamsPath, @createRecommendationStreamsPath, @syncStreamPath) ->
    @_popup = $('#import-editor-streams-popup')
    streams_grid = @_popup.find('.sources-grid:first')
    @_streams_gridview = new SourcesGridview(streams_grid)
    @_loading = $('#loading-streams')
    @_doImportLink = $('#do-import-streams')
    @_importProgress = $('#import-streams-progress')
    @_progressBar = @_popup.find('#streams-progress-bar')
    @_streamsDisplay = $('#display-streams')
    $('#add-editor-streams-link').click =>
      this._init()
      false
    @_doImportLink.click =>
      this._doImport()
      false

  _init: =>
    this.popup @_popup
    @_loading.show()
    @_importProgress.hide()
    @_streamsDisplay.hide()
    server.get @editorStreamsPath, {}, (data) =>
      streams = (new Source(d) for d in data)
      this._showEditorStreams(streams)

  _showEditorStreams: (streams) =>
    @_streams_gridview.load(streams)
    @_loading.hide()
    @_doImportLink.show()
    @_streamsDisplay.fadeIn()

  _doImport: =>
    @_doImportLink.hide()
    @_importProgress.fadeIn()
    this._reportProgress(0, 1)
    server.post @createRecommendationStreamsPath, {}, (data) =>
      createdStreams = (new Source(d) for d in data)
      this._startSync(createdStreams)

  _startSync: (streams) =>
    new quefee.CollectionWorkQ(
      collection: streams
      operation: this._sync
      onProgress: (p) => this._reportProgress(p, streams.length )
      onFinish: this._finish
    ).start()

  _sync: (stream, callback) =>
    server.put sync_flickr_stream_path(stream), {}, callback

  _reportProgress: (progress, total) =>
    @_progressBar.reportprogress(progress * 100 / total)

  _finish: =>
    this.closePopup(@_popup)
    this.trigger('imported')





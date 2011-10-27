class window.MySources
  constructor: ( @contactImporter, @editorStreamsImporter)->
    @view = new MySourcesView
    @addByUserImporter = new AddByUserImporter
    @googleReaderImporter = new GoogleReaderImporter
    @addByUserImporter.bind 'import-finished', this._sourcesImportDone
    @addByUserImporter.bind 'sources-imported', this._sourcesImported
    @contactImporter.bind 'import-finished', this._sourcesImportDone
    @contactImporter.bind 'sources-imported', this._sourcesImported
    @editorStreamsImporter.bind 'import-finished', this._sourcesImportDone
    @editorStreamsImporter.bind 'sources-imported', this._sourcesImported
    @googleReaderImporter.bind 'import-finished', this._sourcesImportDone
    @googleReaderImporter.bind 'sources-imported', this._sourcesImported

  init: (onInit)=>
    @view.clear()
    this._loadSource 1, (hasSources) =>
      @view.onAllSourcesLoaded(!hasSources)
      onInit?()

  _loadSource: (page, onFinish) =>
    klekr.Global.server.get my_sources_flickr_streams_path(), {page: page, per_page: 50}, (data) =>
      sources = (new Source(d) for d in data)
      this._display(sources)
      if sources.length > 0
        this._loadSource(page + 1, onFinish)
      else
        onFinish?(page > 1)

  _sourcesImportDone: =>
    klekr.Global.server.get info_collector_path({id: 'current'}), {}, (data)=>
      this.init =>
        @view.showNewSourcesAddedPanel(data)

  _sourcesImported: (sources) =>
    @view.onAllSourcesLoaded(false)
    this._display sources

  _display: (sources) =>
    @view.addSource(source) for source in sources

$ ->
  contactImporter = new ContactsImporter(__contactsPath__, __importContactPath__)
  editorStreamsImporter = new EditorStreamsImporter
  window.mySources = new MySources(contactImporter, editorStreamsImporter)

  mySources.init()
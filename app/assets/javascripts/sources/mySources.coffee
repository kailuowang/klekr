class window.MySources
  constructor: ()->
    @contactImporter = new klekr.ContactsImporter
    @editorStreamsImporter = new EditorStreamsImporter
    @groupStreamsImporter = new klekr.GroupStreamsImporter
    @addByUserImporter = new AddByUserImporter
    @googleReaderImporter = new GoogleReaderImporter
    @view = new MySourcesView
    this._bindImporterEvents([@addByUserImporter, @contactImporter, @editorStreamsImporter, @googleReaderImporter, @groupStreamsImporter])

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
    this.init =>
      klekr.Global.server.get info_collector_path({id: 'current'}), {}, (data)=>
        @view.showNewSourcesAddedPanel(data)

  _sourcesImported: (sources) =>
    @view.onAllSourcesLoaded(false)
    this._display sources

  _display: (sources) =>
    for source in sources
      @view.addSource(source)

  _bindImporterEvents: (importers)=>
    for importer in importers
      importer.bind 'import-finished', this._sourcesImportDone
#      importer.bind 'sources-imported', this._sourcesImported #temporarily disabled due to scroll bar bug

$ ->
  new MySources().init()
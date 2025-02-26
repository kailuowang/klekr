window.MySources = class MySources
  constructor: ()->
    console.log("MySources constructor called")
    @contactImporter = new klekr.ContactsImporter
    @editorStreamsImporter = new EditorStreamsImporter
    @groupStreamsImporter = new klekr.GroupStreamsImporter
    @addByUserImporter = new AddByUserImporter
    @googleReaderImporter = new GoogleReaderImporter
    @view = new MySourcesView
    this._bindImporterEvents([@addByUserImporter, @contactImporter, @editorStreamsImporter, @googleReaderImporter, @groupStreamsImporter])

  init: (onInit)=>
    console.log("MySources init")
    @view.clear()
    # Only load the first page on initial load
    klekr.Global.server.get my_sources_flickr_streams_path(), {page: 1, per_page: 50}, (data) =>
      console.log("First page loaded, items:", data.length)
      sources = (new Source(d) for d in data)
      hasSources = sources.length > 0
      
      this._display(sources)
      @view.onAllSourcesLoaded(!hasSources)
      onInit?()

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

# Initialize the application when document is ready
$ ->
  console.log("Document ready, initializing MySources")
  window.mySources = new MySources()
  window.mySources.init()
class window.MySources
  constructor: (@sourcesPath, @contactImporter, @editorStreamsImporter)->
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
    klekr.Global.server.get @sourcesPath, {}, (data) =>
      allSources = (new Source(d) for d in data)
      @view.clear()
      this._display(allSources)
      @view.setVisibleEmptySourceSection(allSources.length is 0)
      onInit?()

  _sourcesImportDone: =>
    klekr.Global.server.get info_collector_path({id: 'current'}), {}, (data)=>
      this.init =>
        @view.showNewSourcesAddedPanel(data)

  _sourcesImported: (sources) =>
    @view.setVisibleEmptySourceSection(false)
    this._display sources

  _display: (sources) =>
    @view.addSource(source) for source in sources

$ ->
  contactImporter = new ContactsImporter(__contactsPath__, __importContactPath__)
  editorStreamsImporter = new EditorStreamsImporter
  window.mySources = new MySources(__sourcesPath__, contactImporter, editorStreamsImporter)

  mySources.init()
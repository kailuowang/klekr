class window.MySources
  constructor: (@sourcesPath, @contactImporter, @editorStreamsImporter)->
    @view = new MySourcesView
    @contactImporter.bind 'imported', this.init
    @editorStreamsImporter.bind 'imported', this.init

  init: =>
    server.get @sourcesPath, {}, (data) =>
      allSources = (new Source(d) for d in data)
      this._display(allSources)

  _display: (sources) =>
    @view.clear()
    sourcesByGroup = _.groupBy sources, (s) -> s.rating
    keys = _.keys(sourcesByGroup)
    for star in (_.sortBy keys, (r) -> -r)
      @view.loadSources(star, sourcesByGroup[star])
    @view.setVisibleEmptySourceSection(sources.length is 0)
    @view.showManagementSection()


$ ->
  contactImporter = new ContactsImporter(__contactsPath__, __importContactPath__)
  editorStreamsImporter = new EditorStreamsImporter(__editorStreamsPath__, __createRecommendationStreamsPath__, __syncStreamPath__)
  window.mySources = new MySources(__sourcesPath__, contactImporter, editorStreamsImporter)

  mySources.init()
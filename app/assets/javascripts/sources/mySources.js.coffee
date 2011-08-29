class window.MySources
  constructor: (@sourcesPath, @contactImporter)->
    @view = new SourcesView
    @contactImporter.bind 'imported', this.init

  init: =>
    server.get @sourcesPath, {}, (data) =>
      allSources = (new Source(d) for d in data)
      this._display(allSources)

  _display: (sources) =>
    sourcesByGroup = _.groupBy sources, (s) -> s.rating
    keys = _.keys(sourcesByGroup)
    for star in (_.sortBy keys, (r) -> -r)
      @view.loadSources(star, sourcesByGroup[star])
    @view.setVisibleEmptySourceSection(sources.length is 0)
    @view.showManagementSection()


$ ->
  contactImporter = new ContactsImporter(__contactsPath__, __importContactPath__)
  window.mySources = new MySources(__sourcesPath__, contactImporter)

  mySources.init()
class window.MySources
  constructor: (@sourcesPath)->
    @view = new SourcesView

  init: =>
    server.get @sourcesPath, {}, (data) =>
      allSources = (new Source(d) for d in data)
      this._display(allSources)

  _display: (sources) =>
    sourcesByGroup = _.groupBy sources, (s) -> s.rating
    keys = _.keys(sourcesByGroup)
    for star in (_.sortBy keys, (r) -> -r)
      @view.loadSources(star, sourcesByGroup[star])

$ ->
  window.mySources = new MySources(__sourcesPath__)
  mySources.init()
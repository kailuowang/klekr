class window.SourcesGridview extends ViewBase
  constructor: (@grid) ->
    @cellTemplate = @grid.find('.source-cell:first')
    @cells = []

  load: (sources) =>
    @cells = []
    @grid.empty()
    this.addSource(source) for source in sources
    @cellTemplate.hide()
    this.registerEvents()

  addSource: (source) =>
    unless this._has(source)
      newCell = @cellTemplate.clone()
      @grid.append(newCell)
      newCell.show()
      cell = new SourceCell(newCell, source)
      @cells.push cell
      cell

  registerEvents: =>
    cell.registerEvents() for cell in @cells

  _has: (source) =>
    _(@cells).any( (cell) -> cell.about(source) )

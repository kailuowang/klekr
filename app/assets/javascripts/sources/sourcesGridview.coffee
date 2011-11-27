class window.SourcesGridview extends ViewBase
  constructor: (@grid) ->
    @cellTemplate = @grid.find('.source-cell:first')
    @cells = []

  load: (sources) =>
    @grid.empty()
    this.addSource(source) for source in sources
    @cellTemplate.hide()
    this.registerEvents()


  addSource: (source) =>
    newCell = @cellTemplate.clone()
    @grid.append(newCell)
    newCell.show()
    cell = new SourceCell(newCell, source)
    @cells.push cell
    cell

  registerEvents: =>
    cell.registerEvents() for cell in @cells

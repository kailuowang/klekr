class window.SourcesGridview extends ViewBase
  constructor: (@grid) ->
    @cellTemplate = @grid.find('.source-cell:first')

  load: (sources) =>
    @grid.empty()
    this.addSource(source) for source in sources
    @cellTemplate.hide()

  addSource: (source) =>
    newCell = @cellTemplate.clone()
    @grid.append(newCell)
    newCell.show()
    new SourceCell(newCell, source)

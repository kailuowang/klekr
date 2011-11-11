class window.SourcesGridview extends ViewBase
  constructor: (@grid) ->
    @cellTemplate = @grid.find('.source-cell:first')

  load: (sources) =>
    @grid.empty()
    this.addSource(source) for source in sources
    @cellTemplate.hide()

  addSource: (source) =>
    newCell = @cellTemplate.clone()
    new SourceCell(newCell, source)
    @grid.append(newCell)
    newCell.show()

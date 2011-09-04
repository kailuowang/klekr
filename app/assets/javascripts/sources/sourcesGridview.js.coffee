class window.SourcesGridview extends ViewBase
  constructor: (@grid) ->

  load: (sources) =>
    cellTemplate = @grid.find('.source-cell:first')
    @grid.empty()
    for source in sources
      newCell = cellTemplate.clone()
      this._loadSource(newCell, source)
      @grid.append(newCell)
      newCell.show()
    cellTemplate.hide()

  _loadSource: (cell, source)=>
    cell.find('.source-icon').attr('src', source.iconUrl)
    cell.find('.source-icon-link').attr('href', source.slideUrl)
    cell.find('.source-name').text(source.ownerName + "'s")
    cell.find('.source-type').text(source.type)
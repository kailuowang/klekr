class window.SourcesGridview extends ViewBase
  constructor: (@grid) ->
    @cellTemplate = @grid.find('.source-cell:first')

  load: (sources) =>
    @grid.empty()
    this.addSource(source) for source in sources
    @cellTemplate.hide()

  addSource: (source) =>
    newCell = @cellTemplate.clone()
    this._loadSource(newCell, source)
    @grid.append(newCell)
    newCell.show()

  _loadSource: (cell, source)=>
    cell.find('.source-icon').attr('src', source.iconUrl)
    cell.find('.source-icon-link').attr('href', source.slideUrl)
    cell.find('.source-name').text(source.username + "'s")
    cell.find('.source-type').text(source.typeDisplay)
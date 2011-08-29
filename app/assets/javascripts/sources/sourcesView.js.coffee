class window.SourcesView extends ViewBase
  constructor: ->
    @template = $('#star-category-template')
    @container = $('#sources-list')
    @expandLink = $('#expand-management')
    @importPanel = $('#sources-import-panel')

    @expandLink.click(=> this._toggleManagementPanel(); false)

  clear: =>
    @container.empty()

  loadSources: (star, sources)=>
    newStarCategory = @template.clone()
    this._updateStar(newStarCategory, star)
    this._loadCategory(newStarCategory, sources)
    @container.append(newStarCategory)
    newStarCategory.show()

  showManagementSection: =>
    @importPanel.hide()
    $('#sources-management').show()

  setVisibleEmptySourceSection: (visible)=>
    this.setVisible($('#empty-sources'), visible)

  showContacts: =>
    contacts-list

  _updateStar: (categoryDiv, star) =>
    label = categoryDiv.find('.stars-label').first()
    starText =('★' for i in [0...star]).join('')
    label.text(starText)

  _loadCategory: (category, sources) =>
    cellTemplate = category.find('.source-cell').first()
    cellGrid = category.find('.sources-grid').first()
    for source in sources
      newCell = cellTemplate.clone()
      this._loadSource(newCell, source)
      cellGrid.append(newCell)
      newCell.show()
    cellTemplate.hide()

  _loadSource: (cell, source)=>
    cell.find('.source-icon').attr('src', source.iconUrl)
    cell.find('.source-icon-link').attr('href', source.slideUrl)
    cell.find('.source-name').text(source.ownerName + "'s")
    cell.find('.source-type').text(source.type)

  _toggleManagementPanel: () =>
    if @importPanel.is(':visible')
      @importPanel.slideUp()
    else
      @importPanel.slideDown()



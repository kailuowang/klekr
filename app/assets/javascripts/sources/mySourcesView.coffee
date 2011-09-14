class window.MySourcesView extends ViewBase
  constructor: ->
    @template = $('#star-category-template')
    @container = $('#sources-list')
    @expandLink = $('#expand-management')
    @importPanel = $('#sources-import-panel')
    @newSourcesAddedPanel = $('#new-sources-added')
    $('#close-new-sources-added').click => @newSourcesAddedPanel.slideUp()
    @expandLink.click this._toggleManagementPanel

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

  showNewSourcesAddedPanel: (collectorInfo) =>
    @newSourcesAddedPanel.find('#num-of-pictures').text(collectorInfo.pictures)
    @newSourcesAddedPanel.find('#num-of-sources').text(collectorInfo.sources)
    $(window).scrollTop 0
    @newSourcesAddedPanel.show()
    @newSourcesAddedPanel.slideDown()

  _updateStar: (categoryDiv, star) =>
    label = categoryDiv.find('.stars-label:first')
    starText =('★' for i in [0...star]).join('')
    label.text(starText)

  _loadCategory: (category, sources) =>
    cellGrid = category.find('.sources-grid:first')
    new SourcesGridview(cellGrid).load(sources)

  _toggleManagementPanel: () =>
    @importPanel.slideToggle =>
      if this.showing(@importPanel)
        $(window).scrollTop @importPanel.offset().top



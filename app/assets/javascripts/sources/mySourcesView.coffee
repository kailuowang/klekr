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
    newStarCategory = this._createCategory(star)
    this._sourcesGridView(newStarCategory).load(sources)

  addSource: (source, star = 1) =>
    categoryDiv = this._ensureCategory(star)
    this._sourcesGridView(categoryDiv).addSource(source)

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
    @newSourcesAddedPanel.slideDown()

  _createCategory: (star) =>
    newStarCategory = @template.clone()
    newStarCategory.attr('id', 'star' + star)
    this._updateStar(newStarCategory, star)
    @container.append(newStarCategory)
    newStarCategory.show()

  _ensureCategory: (star) =>
    category = $('#star' + star)
    if(category.length > 0 )
      category
    else
      this._createCategory(star)

  _updateStar: (categoryDiv, star) =>
    label = categoryDiv.find('.stars-label:first')
    starText =('★' for i in [0...star]).join('')
    label.text(starText)

  _sourcesGridView: (categoryDiv) =>
    cellGrid = categoryDiv.find('.sources-grid:first')
    new SourcesGridview(cellGrid)

  _toggleManagementPanel: () =>
    @importPanel.slideToggle =>
      if this.showing(@importPanel)
        $(window).scrollTop @importPanel.offset().top



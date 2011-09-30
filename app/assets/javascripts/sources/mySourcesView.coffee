class window.MySourcesView extends ViewBase
  constructor: ->
    @template = $('#star-category-template')
    @container = $('#sources-list')
    @expandLink = $('#expand-management')
    @importPanel = $('#sources-import-panel')
    @newSourcesAddedPanel = $('#new-sources-added')
    $('#close-new-sources-added').click_ => @newSourcesAddedPanel.slideUp()
    @expandLink.click_ this._toggleManagementPanel

  clear: =>
    @container.empty()

  loadSources: (star, sources)=>
    newStarCategory = this._createCategory(star)
    this._sourcesGridView(newStarCategory).load(sources)

  addSource: (source, star = 1) =>
    categoryDiv = this._ensureCategory(star)
    this._sourcesGridView(categoryDiv).addSource(source)


  setVisibleEmptySourceSection: (empty)=>
    this.setVisible($('#empty-sources'), empty)
    this.setVisible(@importPanel, empty)
    this._setExpandLinkText(empty)
    $('#sources-management').show()

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
    this._setExpandLinkText(!this.showing(@importPanel))
    @importPanel.slideToggle =>
      if this.showing(@importPanel)
        $(window).scrollTop @importPanel.offset().top

  _setExpandLinkText: (expanded) =>
    text = if expanded then '4 ways of adding sources:' else 'I want more sources!'
    @expandLink.text(text)



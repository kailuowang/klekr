class window.MySourcesView extends ViewBase
  constructor: ->
    @template = $('#star-category-template')
    @container = $('#sources-list')
    @expandLink = $('#expand-management')
    @importPanel = $('#sources-import-panel')
    @indicator = $('#loading-sources-indicator')
    @newSourcesAddedPanel = $('#new-sources-added')
    $('#close-new-sources-added').click_ => @newSourcesAddedPanel.slideUp()
    @expandLink.click_ this._toggleManagementPanel
    $('#add-more-sources').click_ this._toggleManagementPanel
    klekr.Global.broadcaster.bind 'source-added', this.addSource

  clear: =>
    @container.empty()
    @indicator.show()
    @categories = {}

  addSource: (source) =>
    this._ensureCategory(source.rating).addSource(source).registerEvents?()

  onAllSourcesLoaded: (empty)=>
    this.setVisible($('#empty-sources'), empty)
    this.setVisible($('#add-more-sources'), !empty)
    this.setVisible(@importPanel, empty)
    this._setExpandLinkText(empty)
    $('#sources-management').show()
    @indicator.hide()
    unless empty
      this._registerCellEvents()

  showContacts: =>
    contacts-list

  showNewSourcesAddedPanel: (collectorInfo) =>
    @newSourcesAddedPanel.find('#num-of-sources').text(collectorInfo.sources)
    $(window).scrollTop 0
    @newSourcesAddedPanel.slideDown()

  _registerCellEvents: =>
    category.registerEvents() for category in _(@categories).values()

  _createCategoryDiv: (star) =>
    newStarCategory = @template.clone()
    newStarCategory.attr('id', 'star' + star)
    this._updateStar(newStarCategory, star)
    @container.append(newStarCategory)
    this._sortCategories()
    newStarCategory.show()

  _ensureCategory: (star) =>
    @categories ?= {}
    @categories[star] ?= this._sourcesGridView(this._createCategoryDiv(star))

  _updateStar: (categoryDiv, star) =>
    label = categoryDiv.find('.stars-label:first')
    starText =('★' for i in [0...star]).join('')
    label.text(starText)

  _sortCategories: =>
    categories = $('.star-category')
    sorted_categories = (_(categories).sortBy (c) -> c.id).reverse()
    @container.empty()
    @container.append(category) for category in sorted_categories
    $('.star-category .stars-label').popover_ext()

  _sourcesGridView: (categoryDiv) =>
    cellGrid = categoryDiv.find('.sources-grid:first')
    new SourcesGridview(cellGrid)

  _toggleManagementPanel: () =>
    this._setExpandLinkText(!this.showing(@importPanel))
    @importPanel.slideToggle =>
      if this.showing(@importPanel)
        $(window).scrollTop @importPanel.offset().top

  _setExpandLinkText: (expanded) =>
    text = if expanded then "It's easy! 5 ways of adding sources:" else 'I want more sources!'
    @expandLink.text(text)



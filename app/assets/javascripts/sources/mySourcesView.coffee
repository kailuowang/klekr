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
      this._setupInfiniteScroll()

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
    
  _setupInfiniteScroll: =>
    console.log("Setting up infinite scroll")
    @currentPage = 1
    @isLoading = false
    @hasMoreSources = true
    
    # Remove any existing scroll handlers to prevent duplicates
    $(window).off('scroll.mySources')
    
    # Add new scroll handler with namespace
    $(window).on 'scroll.mySources', =>
      this._checkIfMoreContentNeeded()
      
    # Check immediately after setup in case the initial content doesn't fill the page
    setTimeout =>
      this._checkIfMoreContentNeeded()
    , 500  # Short delay to ensure the DOM is fully rendered
    
  _checkIfMoreContentNeeded: =>
    scrollPosition = $(window).scrollTop() + $(window).height()
    documentHeight = $(document).height()
    
    # Check if we need to load more content
    if scrollPosition >= documentHeight - 200
      console.log("Near bottom, loading more if possible")
      this._loadMoreSources() unless @isLoading or !@hasMoreSources
      
    # If there's no scrollbar yet, check if we need to load more
    if documentHeight <= $(window).height() and @hasMoreSources and !@isLoading
      console.log("No scrollbar yet, loading more content")
      this._loadMoreSources()
  
  _loadMoreSources: =>
    @isLoading = true
    @currentPage += 1
    @indicator.show()
    
    console.log("Loading page", @currentPage)
    klekr.Global.server.get my_sources_flickr_streams_path(), {page: @currentPage, per_page: 50}, (data) =>
      console.log("Page", @currentPage, "loaded with", data.length, "items")
      sources = (new Source(d) for d in data)
      if sources.length > 0
        this._display(sources)
        this._registerCellEvents()
        
        # After displaying new content, check if we need more (for cases with tall browser windows)
        setTimeout =>
          this._checkIfMoreContentNeeded()
        , 100
      else
        @hasMoreSources = false
        console.log("No more sources to load")
      
      @isLoading = false
      @indicator.hide()
  
  _display: (sources) =>
    console.log("Displaying", sources.length, "sources")
    for source in sources
      this.addSource(source)



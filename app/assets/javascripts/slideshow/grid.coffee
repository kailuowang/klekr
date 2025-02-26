class window.Grid extends ModeBase

  constructor: ->
    super('grid')
    this.reset()
    generalView.bind('layout-changed', this._onLayoutChange)

  reset: =>
    @selectedIndex = 0
    @picturesLoaded = false

  init: (gallery) =>
    gallery.bind 'new-pictures-added', (pictures) =>
      for pic in pictures
        pic.bind 'clicked', this._onPictureSelect
    gallery.bind 'pre-reset', => gridview.showLoading()
    gallery.bind 'gallery-pictures-changed', this._tryCompleteCurrentPage

  clear: =>
    this.reset()
    this._loadGridview()

  atTheLast: =>
    [pageStart, pageEnd] = this._currentPageRange()
    result = pageEnd is gallery.size() - 1
    console.log("Grid: atTheLast check - pageEnd: #{pageEnd}, gallery.size: #{gallery.size()}, result: #{result}")
    # Always pretend we're not at the last page when gallery is empty or has only one page
    # This ensures navigation buttons appear even when we only have one page loaded so far
    if gallery.size() <= gridview.size
      console.log("Grid: Only one page or less loaded, pretending we're not at the last page")
      false
    else 
      result

  atTheBegining: =>
    [pageStart, pageEnd] = this._currentPageRange()
    pageStart is 0

  selectedPicture: =>
    gallery.pictures[@selectedIndex]

  view: -> gridview

  currentProgress: =>
    @selectedIndex

  updateProgress: (progress) =>
    reloadRequired = !@picturesLoaded or this._isDifferentPage(progress)
    @selectedIndex = progress
    if reloadRequired
      this._loadGridview()
    else
      this._updateHighlight()
    
    # After updating progress, always trigger progress-changed to update navigation
    this.trigger('progress-changed')

  navigateToNext: =>
    console.log("Grid: navigateToNext called")
    this._markCurrentPageAsViewed()
    unless this._pageIncomplete()
      [pageStart, pageEnd] = this._currentPageRange()
      console.log("Grid: current page range is #{pageStart} to #{pageEnd}")
      newIndex = pageEnd + 1
      console.log("Grid: trying to navigate to index #{newIndex}, gallery size: #{gallery.size()}")
      
      if newIndex < gallery.size()
        console.log("Grid: navigating to new page starting at index #{newIndex}")
        this._changePage(newIndex)
        this.trigger('progressed')
      else
        console.log("Grid: reached end of available pictures, requesting more")
        gridview.showLoading()
        # Always try to load more pictures when reaching the end
        gallery.increaseCacheSize(1)
        gallery.bind 'gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady

  navigateToPrevious: =>
    unless this.atTheBegining()
      [pageStart, pageEnd] = this._currentPageRange()
      this._changePage(pageStart - 1)

  switchToSlide: =>
    this.goToIndex(@selectedIndex) #simply to update history
    gallery.toggleMode()

  moveUp: => this._tryMoveTo(@selectedIndex - gridview.columns)
  moveDown: => this._tryMoveTo(@selectedIndex + gridview.columns)
  moveLeft: => this._tryMoveTo @selectedIndex - 1 , this.navigateToPrevious
  moveRight: => this._tryMoveTo @selectedIndex + 1,  this.navigateToNext

  shortcutsSettings: ->
    [
      [ 'up', this.moveUp, 'Move up' ]
      [ 'right', this.moveRight, 'Move right' ]
      [ 'down', this.moveDown, 'Move down' ]
      [ 'left', this.moveLeft, 'Move left' ]
      [ [ 'pagedown', 'shift+right' ], this.navigateToNext, 'Next page' ]
      [ [ 'pageup', 'shift+left' ], this.navigateToPrevious, 'Previous page' ]
      [ [ 'return', 'space' ], this.switchToSlide, "Go to the selected picture" ]
    ]

  _loadGridview: =>
    pictures = this._currentPageOfPictures()
    gridview.loadPictures(pictures)
    @picturesLoaded = true
    this._updateHighlight()
    this.trigger('progress-changed')

  _navigateToNextPageWhenPicturesReady: =>
      console.log("Grid: pictures are ready, checking if we can navigate to next page")
      gallery.unbind 'gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady
      
      # Check if we're still at the last page after pictures were loaded
      if this.atTheLast()
        console.log("Grid: Still at the last page, gallery size: #{gallery.size()}")
        this._loadGridview()
        
        # If we still don't have enough pictures, try loading more
        if gallery.pictures.length <= gridview.size
          console.log("Grid: Not enough pictures loaded yet, requesting more")
          gallery.increaseCacheSize(1)
      else
        console.log("Grid: More pictures available, navigating to next page")
        this.navigateToNext()

  _tryCompleteCurrentPage: =>
    if this._pageIncomplete()
      this._loadGridview()

  _changePage: (newIndex)=>
    if 0 <= newIndex < gallery.size()
      this.goToIndex(newIndex)

  _tryMoveTo: (newIndex, alternative) =>
    [pageStart, pageEnd] = this._currentPageRange()
    if pageStart <= newIndex < pageStart + gridview.currentSize()
      @selectedIndex = newIndex
      this._updateHighlight()
    else
      alternative?()

  _updateHighlight: =>
    if this._currentPageOfPictures().length > 0
      gridview.highlightPicture(this.selectedPicture())

  _currentPageRange: =>
    positionInPage = @selectedIndex % gridview.size
    pageStart = @selectedIndex - positionInPage
    pageEnd = Math.min(pageStart + gridview.size - 1, gallery.size() - 1)
    [pageStart, pageEnd]

  _isDifferentPage: (progress) =>
    [pageStart, pageEnd] = this._currentPageRange()
    progress < pageStart or progress > pageEnd

  _onPictureSelect: (picture) =>
    @selectedIndex = picture.index
    this.switchToSlide()

  _pageIncomplete: =>
    gridview.currentSize() < gridview.size

  _markCurrentPageAsViewed: =>
    new klekr.PictureUtil().allGetViewed(this._currentPageOfPictures())

  _onLayoutChange: =>
    [original_rows, original_columns] = [gridview.rows, gridview.columns]
    gridview.initLayout()
    if (original_rows isnt gridview.rows) or (original_columns isnt gridview.columns)
      this._loadGridview()

  _currentPageOfPictures:  =>
    [pageStart, pageEnd] = this._currentPageRange()
    gallery.pictures[pageStart..pageEnd]

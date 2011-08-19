class window.Grid extends ModeBase

  constructor: ->
    super()
    @selectedIndex = 0
    gridview.itemSelect this._onPictureSelect


  currentPageOfPictures:  =>
    [pageStart, pageEnd] = this._currentPageRange()
    gallery.pictures[pageStart..pageEnd]

  loadGridview: =>
    gridview.loadPictures(this.currentPageOfPictures())
    this._updateHighlight()

  selectedPicture: =>
    gallery.pictures[@selectedIndex]

  onFirstBatchOfPicturesLoaded: =>
    this.updateProgress(0)

  onMorePicturesLoaded: =>
    if this._pageIncomplete()
      this.loadGridview()

  currentProgress: =>
    @selectedIndex

  updateProgress: (progress) =>
    @selectedIndex = progress
    this.loadGridview()

  show: =>
    view.showHideGridview(true)

  navigateToNext: =>
    this._markCurrentPageAsViewed()
    unless this._pageIncomplete()
      [pageStart, pageEnd] = this._currentPageRange()
      this._changePage(pageEnd + 1)

  navigateToPrevious: =>
    [pageStart, pageEnd] = this._currentPageRange()
    this._changePage(pageStart - 1)

  switchToSlide: =>
    gallery.toggleMode()
    this.trigger('progress-changed')

  moveUp: => this._tryMoveTo(@selectedIndex - gridview.columns)
  moveDown: => this._tryMoveTo(@selectedIndex + gridview.columns)
  moveLeft: => this._tryMoveTo @selectedIndex - 1 , this.navigateToPrevious
  moveRight: => this._tryMoveTo @selectedIndex + 1,  this.navigateToNext

  shortcutsSettings: ->
    [
      [ 'up', this.moveUp, 'move up' ]
      [ 'right', this.moveRight, 'move right' ]
      [ 'down', this.moveDown, 'move down' ]
      [ 'left', this.moveLeft, 'move left' ]
      [ 'pagedown', this.navigateToNext, 'next page' ]
      [ 'pageup', this.navigateToPrevious, 'previous page' ]
      [ ['return','space'], this.switchToSlide, "go to the selected picture" ]
    ]

  _changePage: (newIndex)=>
    if 0 <= newIndex < gallery.size()
      @selectedIndex = newIndex
      this.loadGridview()
      this.trigger('progress-changed')

  _tryMoveTo: (newIndex, alternative) =>
    [pageStart, pageEnd] = this._currentPageRange()
    if pageStart <= newIndex < pageStart + gridview.currentSize()
      @selectedIndex = newIndex
      this._updateHighlight()
    else
      alternative?()

  _updateHighlight: =>
    gridview.highlightPicture(this.selectedPicture())

  _currentPageRange: =>
    positionInPage = @selectedIndex % gridview.size
    pageStart = @selectedIndex - positionInPage
    pageEnd = Math.min(pageStart + gridview.size - 1, gallery.size() - 1)
    [pageStart, pageEnd]

  _onPictureSelect: (picId) =>
    picIndex = gallery.findIndex(picId)
    @selectedIndex = picIndex
    this.switchToSlide()

  _pageIncomplete: =>
    gridview.currentSize() < gridview.size

  _markCurrentPageAsViewed: =>
    picture.getViewed() for picture in this.currentPageOfPictures()
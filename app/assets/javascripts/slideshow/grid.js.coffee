class window.Grid extends ModeBase

  constructor: ->
    super()
    @selectedIndex = 0
    gridview.itemSelect this._onPictureSelect

  currentPageOfPictures:  =>
    [pageStart, pageEnd] = this._currentPageRange()
    gallery.pictures[pageStart..pageEnd]

  _loadGridview: =>
    gridview.loadPictures(this.currentPageOfPictures())
    this._updateHighlight()
    this.trigger('progress-changed')

  atTheLast: => this._pageIncomplete()

  atTheBegining: =>
    [pageStart, pageEnd] = this._currentPageRange()
    pageStart is 0

  selectedPicture: =>
    gallery.pictures[@selectedIndex]

  onFirstBatchOfPicturesLoaded: =>
    this.updateProgress(0)

  onMorePicturesLoaded: =>
    if this._pageIncomplete()
      this._loadGridview()

  view: ->
    gridview

  currentProgress: =>
    @selectedIndex

  updateProgress: (progress) =>
    @selectedIndex = progress
    this._loadGridview()

  navigateToNext: =>
    this._markCurrentPageAsViewed()
    unless this._pageIncomplete()
      [pageStart, pageEnd] = this._currentPageRange()
      this._changePage(pageEnd + 1)
      this.trigger('progressed')

  navigateToPrevious: =>
    [pageStart, pageEnd] = this._currentPageRange()
    this._changePage(pageStart - 1)

  switchToSlide: =>
    gallery.toggleMode()

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
      this._loadGridview()


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
    Picture.allGetViewed(this.currentPageOfPictures())
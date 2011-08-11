class window.Grid

  constructor: ->
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
    this.loadGridview()

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

  nextPage: =>
    this._markCurrentPageAsViewed()
    unless this._pageIncomplete()
      [pageStart, pageEnd] = this._currentPageRange()
      this._changePage(pageEnd + 1)

  previousPage: =>
    [pageStart, pageEnd] = this._currentPageRange()
    this._changePage(pageStart - 1)

  moveUp: => this._tryMoveTo(@selectedIndex - gridview.columns)
  moveDown: => this._tryMoveTo(@selectedIndex + gridview.columns)
  moveLeft: => this._tryMoveTo @selectedIndex - 1 , this.previousPage
  moveRight: => this._tryMoveTo @selectedIndex + 1,  this.nextPage

  shortcuts: =>
    @_shortcuts ?= [
      new KeyShortcut 'up', this.moveUp, 'move up'
      new KeyShortcut 'right', this.moveRight, 'move right'
      new KeyShortcut 'down', this.moveDown, 'move down'
      new KeyShortcut 'left', this.moveLeft, 'move left'
      new KeyShortcut 'pagedown', this.nextPage, 'next page'
      new KeyShortcut 'pageup', this.previousPage, 'previous page'
      new KeyShortcut ['return','space'], gallery.toggleMode, "go to the selected picture"
    ]

  _changePage: (newIndex)=>
   if 0 <= newIndex < gallery.size()
      @selectedIndex = newIndex
      this.loadGridview()
      gallery.ensurePictureCache()

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
    gallery.toggleMode()

  _pageIncomplete: =>
    gridview.currentSize() < gridview.size

  _markCurrentPageAsViewed: =>
    picture.getViewed() for picture in this.currentPageOfPictures()
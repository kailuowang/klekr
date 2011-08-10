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
    this.loadGridView()

  currentProgress: =>
    @selectedIndex

  updateProgress: (progress) =>
    @selectedIndex = progress
    this.loadGridview()

  moveUp: =>
    this._tryMoveTo(@selectedIndex - gridview.columns)
  moveDown: =>
    this._tryMoveTo(@selectedIndex + gridview.columns)
  moveLeft: =>
    this._tryMoveTo(@selectedIndex - 1)
  moveRight: =>
    this._tryMoveTo(@selectedIndex + 1)

  _tryMoveTo: (newIndex) =>
    [pageStart, pageEnd] = this._currentPageRange()
    if pageStart <= newIndex and newIndex <= pageEnd
      @selectedIndex = newIndex
      this._updateHighlight()

  _updateHighlight: =>
    gridview.highlightPicture(this.selectedPicture())

  _currentPageRange: =>
    positionInPage = @selectedIndex % gridview.size
    pageStart = @selectedIndex - positionInPage
    pageEnd = pageStart + gridview.size - 1
    [pageStart, pageEnd]

  show: =>
    view.showHideGridview(true)

  _onPictureSelect: (picId) =>
      picIndex = gallery.findIndex(picId)
      if @selectedIndex is picIndex
        gallery.toggleMode()
      else
        @selectedIndex = picIndex

  shortcuts: =>
    @_shortcuts ?= [
      new KeyShortcut 'up', this.moveUp, 'move up'
      new KeyShortcut 'right', this.moveRight, 'move right'
      new KeyShortcut 'down', this.moveDown, 'move down'
      new KeyShortcut 'left', this.moveLeft, 'move left'
      new KeyShortcut ['g', 'return'], gallery.toggleMode, "go to the selected picture"
    ]
class window.Grid extends ModeBase

  constructor: ->
    super()
    this.reset()

  reset: =>
    @selectedIndex = 0

  init: (gallery) =>
    gallery.bind 'new-pictures-added', (pictures) =>
      for pic in pictures
        pic.bind 'clicked', this._onPictureSelect
    gallery.bind 'pre-reset', => gridview.showLoading()
    gallery.bind 'gallery-pictures-changed', this._tryCompleteCurrentPage

  currentPageOfPictures:  =>
    [pageStart, pageEnd] = this._currentPageRange()
    gallery.pictures[pageStart..pageEnd]

  clear: =>
    this.reset()
    this._loadGridview()

  atTheLast: =>
    [pageStart, pageEnd] = this._currentPageRange()
    pageEnd is gallery.size() - 1

  atTheBegining: =>
    [pageStart, pageEnd] = this._currentPageRange()
    pageStart is 0

  selectedPicture: =>
    gallery.pictures[@selectedIndex]

  onFirstBatchOfPicturesLoaded: =>
    this.updateProgress(0)

  view: -> gridview

  currentProgress: =>
    @selectedIndex

  updateProgress: (progress) =>
    @selectedIndex = progress
    this._loadGridview()

  navigateToNext: =>
    this._markCurrentPageAsViewed()
    unless this._pageIncomplete()
      [pageStart, pageEnd] = this._currentPageRange()
      newIndex = pageEnd + 1
      if picturesReady = newIndex < gallery.size()
        this._changePage(newIndex)
        this.trigger('progressed')
      else if gallery.isLoading()
        gridview.showLoading()
        gallery.bind 'gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady


  navigateToPrevious: =>
    unless this.atTheBegining()
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
      [ [ 'pagedown', 'shift+right' ], this.navigateToNext, 'next page' ]
      [ [ 'pageup', 'shift+left' ], this.navigateToPrevious, 'previous page' ]
      [ [ 'return', 'space' ], this.switchToSlide, "go to the selected picture" ]
    ]

  _loadGridview: =>
    pictures = this.currentPageOfPictures()
    gridview.loadPictures(pictures)
    this._updateHighlight() if pictures.length > 0
    this.trigger('progress-changed')

  _navigateToNextPageWhenPicturesReady: =>
      gallery.unbind 'gallery-pictures-changed', this._navigateToNextPageWhenPicturesReady
      unless this.atTheLast()
        this.navigateToNext()
      else
        this._loadGridview()

  _tryCompleteCurrentPage: =>
    if this._pageIncomplete()
      this._loadGridview()

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

  _onPictureSelect: (picture) =>
    @selectedIndex = picture.index
    this.switchToSlide()

  _pageIncomplete: =>
    gridview.currentSize() < gridview.size

  _markCurrentPageAsViewed: =>
    Picture.allGetViewed(this.currentPageOfPictures())
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
    pageEnd is gallery.size() - 1

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

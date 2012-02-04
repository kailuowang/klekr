class window.PicturePreloadPriority
  constructor: (@picture, @gallery) ->

  small: =>
    100 + this._pageAdjustmentSmall() + this._positionAdjustment()

  full:  =>
    0 + this._pageAdjustmentFull() + this._positionAdjustment() + this._positionAdjustmentFull()

  _pageAdjustmentSmall: =>
    pagesAhead = this._pagesAhead()
    if pagesAhead < 0
      -500
    else if pagesAhead <= 1
      200
    else
      0

  _pageAdjustmentFull: =>
    pagesAhead = this._pagesAhead()
    if pagesAhead < 0
      -500
    else if pagesAhead is 0
      200
    else
      0

  _pagesAhead:  =>
    @gallery.pageOf(@picture)  - @gallery.currentPage()

  _positionAdjustment: =>
    if !@gallery.inGrid() and 0 <= this._ahead() <= 5
      1000
    else
      0

  _positionAdjustmentFull: =>
    if 0 <= this._ahead()
      @gallery.pageSize() - this._ahead()
    else
      this._ahead()

  _ahead: =>
    @picture.index - @gallery.currentPicture().index
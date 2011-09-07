class window.PicturePreloadPriority
  constructor: (@picture, @gallery) ->

  small: =>
    100 + this._pageAdjustmentSmall() + this._positionAdjustment()

  large:  =>
    0 + this._pageAdjustmentLarge() + this._positionAdjustment() + this._positionAdjustmentLarge()

  _pageAdjustmentSmall: =>
    pagesAhead = this._pagesAhead()
    if pagesAhead < 0
      -500
    else if pagesAhead <= 1
      200
    else
      0

  _pageAdjustmentLarge: =>
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
    if !@gallery.inGrid() and 0 <= this._ahead() <= 2
      1000
    else
      0

  _positionAdjustmentLarge: =>
    if 0 <= this._ahead()
      @gallery.pageSize() - this._ahead()
    else
      this._ahead()

  _ahead: =>
    @picture.index - @gallery.currentPicture().index
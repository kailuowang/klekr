class window.FavePanel  extends ViewBase
  constructor: (@currentPicture) ->
    @faveLink = $('#faveLink')
    @faved = $('#faved')
    @faveWaiting = $('#faveWaiting')
    @faveArea = $('#faveArea')
    @faveRating = $('#faveRating')
    @faveRatingPanel = $('#faveRatingPanel')
    this._registerEvents()
    this._initRaty()

  fave: =>
    this.popup(@faveRatingPanel)

  _registerEvents: =>
    @faveLink.click =>
      this.fave()
      false


  updateFavedStatus: (picture) ->
    @faveWaiting.hide()
    this.setVisible(@faveLink, !picture.data.faved)
    this.setVisible(@faved, picture.data.faved)
    this.setVisible(@faveArea, picture.data.favePath?)
    this._updateRating(picture.data.rating)

  _changingFavedStatus: ->
    @faveWaiting.show()
    @faveLink.hide()

  _updateRating: (rating) =>
    $.fn.raty.start(rating, '#faveRating');

  _initRaty: =>
    @faveRating.raty({
      start: 1
      path: '/assets/'
      size: 24
      click: (score, evt) =>
        this._changeRating(score)
    })

  _changeRating: (rating)=>
    this._changingFavedStatus()
    this.currentPicture().fave rating, =>
      this.updateFavedStatus(this.currentPicture())

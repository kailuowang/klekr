class window.FavePanel  extends ViewBase
  constructor: (@currentPicture) ->
    @faveLink = $('#faveLink')
    @faved = $('#faved')
    @faveWaiting = $('#faveWaiting')
    @faveArea = $('#faveArea')
    @faveRating = $('#faveRating')
    @faveRatingPanel = $('#faveRatingPanel')
    @ratingDisplayPanel = $('#ratingDisplayPanel')
    @ratingDisplay = $('#ratingDisplay')
    @interestingessPanel = $('#interestingessPanel')
    this._registerEvents()
    this._initRaty(@faveRating)
    this._initRaty(@ratingDisplay)
    keyShortcuts.addShortcuts(this._ratingShortcuts())

  fave: =>
    unless this.currentPicture().faved()
      this.popup(@faveRatingPanel)

  _registerEvents: =>
    @faveLink.click =>
      this.fave()
      false

  updateFavedStatus: (picture) ->
    @faveWaiting.hide()
    faved = picture.faved()
    this.setVisible(@faveLink, !faved)
    this.setVisible(@faved, faved)
    this.setVisible(@faveArea, picture.data.favePath?)
    this._updateRating(picture.data.rating)
    this.setVisible(@ratingDisplayPanel, faved)
    this.setVisible(@interestingessPanel, !faved)

  _changingFavedStatus: ->
    @faveWaiting.show()
    @faveLink.hide()

  _updateRating: (rating) =>
    $.fn.raty.start(rating, '#faveRating');
    $.fn.raty.start(rating, '#ratingDisplay');

  _initRaty: (div)=>
    div.raty({
      start: 1
      path: '/assets/'
      size: 24
      click: (score, evt) =>
        this._changeRating(score)
    })

  _changeRating: (rating)=>
    this._changingFavedStatus()
    this.closePopup(@faveRatingPanel) if this._showingPopup()
    this.currentPicture().fave rating, =>
      this.updateFavedStatus(this.currentPicture())

  _showingPopup: =>
    this.showing(@faveRatingPanel)

  _ratingShortcuts: ->
    @mratingShortcuts ?=
      this._createRatingShortcut(i) for i in [1..5]

  _ratingShortcutsEnabled: =>
    this._showingPopup() or this.showing(@ratingDisplayPanel)

  _createRatingShortcut: (rating)=>
    new KeyShortcut( rating.toString(),
      ( => this._changeRating(rating)),
      'set rating to '+ rating,
      this._ratingShortcutsEnabled
    )



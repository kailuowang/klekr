class window.FavePanel  extends ViewBase
  constructor: (@currentPicture) ->
    @faveLink = $('#faveLink')
    @removeFaveLink = $('#removeFaveLink')
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
    keyShortcuts.addShortcuts(this._shortcuts())

  fave: =>
    unless this.currentPicture().faved()
      this.popup(@faveRatingPanel)

  unfave: =>
    if this.currentPicture().faved()
      this._changingFavedStatus()
      this.currentPicture().unfave(this.updateFavedStatus)

  updateFavedStatus: =>
    picture = this.currentPicture()
    @faveWaiting.hide()
    faved = picture.faved()
    this.setVisible(@faveArea, true)
    this.setVisible(@faveLink, !faved)
    this.setVisible(@faved, faved)
    this._updateRating(picture.data.rating)
    this.setVisible(@ratingDisplayPanel, faved)
    this.setVisible(@interestingessPanel, !faved and picture.data.collected )

  _registerEvents: =>
    @faveLink.click this.fave
    @removeFaveLink.click this.unfave

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
      this.updateFavedStatus()

  _showingPopup: =>
    this.showing(@faveRatingPanel)

  _shortcuts: ->
    @mShortcuts ?=
      (this._createRatingShortcut(i) for i in [1..5]).concat([
        new KeyShortcut(['f','c'], this.fave, 'collect the picture', => gallery.slide.active())
        new KeyShortcut('u', this.unfave, 'remove the picture from collection', => this.showing(@removeFaveLink))
      ])

  _ratingShortcutsEnabled: =>
    this._showingPopup() or this.showing(@ratingDisplayPanel)

  _createRatingShortcut: (rating)=>
    new KeyShortcut( rating.toString(),
      ( => this._changeRating(rating)),
      'set rating to '+ rating,
      this._ratingShortcutsEnabled
    )



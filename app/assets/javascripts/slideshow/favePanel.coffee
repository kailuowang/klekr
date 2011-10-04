class window.FavePanel  extends ViewBase
  constructor: (@currentPicture) ->
    @faveLink = $('#faveLink')
    @removeFaveLink = $('#removeFaveLink')
    @faved = $('#faved')
    @faveArea = $('#faveArea')
    @faveRating = $('#faveRating')
    @faveRatingPanel = $('#faveRatingPanel')
    @ratingDisplayPanel = $('#ratingDisplayPanel')
    @ratingDisplay = $('#ratingDisplay')
    this._registerEvents()
    this._initRaty(@faveRating)
    this._initRaty(@ratingDisplay)
    keyShortcuts.addShortcuts(this._shortcuts())

  fave: =>
    unless this.currentPicture().faved()
      this.popup(@faveRatingPanel)
      this.setArtistCollectionLink(@faveRatingPanel.find('#artist-collection'), this.currentPicture())

  unfave: =>
    if this.currentPicture().faved()
      this.currentPicture().unfave()
      this.updateFavedStatus()

  updateFavedStatus: =>
    picture = this.currentPicture()
    faved = picture.faved()
    this.setVisible(@faveArea, true)
    this.setVisible(@faveLink, !faved)
    this.setVisible(@faved, faved)
    this._updateRating(picture.data.rating)
    this.setVisible(@ratingDisplayPanel, faved)

  _registerEvents: =>
    @faveLink.click_ this.fave
    @removeFaveLink.click_ this.unfave

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
    this.closePopup(@faveRatingPanel) if this._showingPopup()
    this.currentPicture().fave rating
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



class window.FavePanel  extends ViewBase
  constructor:  ->
    @faveLink = $('#faveLink')
    @removeFaveLink = $('#removeFaveLink')
    @faved = $('#faved')
    @faveArea = $('#faveArea')
    @faveRating = $('#faveRating')
    @faveRatingPanel = $('#faveRatingPanel')
    @ratingDisplayPanel = $('#ratingDisplayPanel')
    @ratingDisplay = $('#ratingDisplay')
    @reloading = $('#reloading-picture')
    @loginReminder = $('#login-reminder')

    this._registerEvents()
    this._initRaty(@faveRating)
    this._initRaty(@ratingDisplay)
    keyShortcuts.addShortcuts(this._shortcuts())

  fave: =>
    if @picture.favable() and !@picture.faved()
      this.setArtistCollectionLink(@faveRatingPanel.find('#artist-collection'), @picture)
      this.popup(@faveRatingPanel)

  unfave: =>
    if @picture.favable() and @picture.faved()
      @picture.unfave()
      this._updateDom()
  
  updateWith: (picture) =>
    @picture = picture
    this._checkAccess()

  _checkAccess: =>
    if !@picture.favable() and klekr.Global.currentCollector?
      @picture.bind 'data-updated', this._pictureUpdated
      @picture.reloadForCurrentCollector()
    this._updateDom()

  _pictureUpdated: (picture)=>
    if(picture is @picture)
      this._checkAccess()

  _updateDom: =>
    this.setVisible @faveArea, @picture.favable()
    this.setVisible @reloading, (!@picture.favable() and klekr.Global.currentCollector?)
    this.setVisible @loginReminder, !klekr.Global.currentCollector?
    if @picture.favable()
      faved = @picture.faved()
      this.setVisible(@faveLink, !faved)
      this._updateRating(@picture.data.rating)
      this.setVisible(@ratingDisplayPanel, faved)
      this.setVisible(@faved, faved)
      @removeFaveLink.attr('data-content', "This picture is added to my collection on #{@picture.favedDate}. Click to remove it." )

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
    @picture.fave rating
    this._updateDom()

  _showingPopup: =>
    this.showing(@faveRatingPanel)

  _shortcuts: ->
    @mShortcuts ?=
      (this._createRatingShortcut(i) for i in [1..5]).concat([
        new KeyShortcut(['f','c'], this.fave, 'collect the picture', => gallery.slide.active() and @picture.favable())
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



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
    this._registerEvents()
    this._initRaty(@faveRating)
    this._initRaty(@ratingDisplay)
    keyShortcuts.addShortcuts(this._shortcuts())

  fave: =>
    unless @picture.faved()
      this.setArtistCollectionLink(@faveRatingPanel.find('#artist-collection'), @picture)
      this.popup(@faveRatingPanel)

  unfave: =>
    if @picture.faved()
      @picture.unfave()
      this._updateDom()
  
  updateWith: (picture) =>
    @picture = picture
    this._updateDom()
  
  _updateDom: =>
    faved = @picture.faved()
    this.setVisible(@faveArea, true)
    this.setVisible(@faveLink, !faved)
    this.setVisible(@faved, faved)
    this._updateRating(@picture.data.rating)
    this.setVisible(@ratingDisplayPanel, faved)
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
        new KeyShortcut(['f','c'], this.fave, 'collect the picture', => gallery.slide.active() and !klekr.Global.readonly)
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



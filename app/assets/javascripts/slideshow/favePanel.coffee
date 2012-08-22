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
      this._updateDom()

  _updateDom: =>
    this.setVisible @faveArea, klekr.Global.currentCollector? and @picture.favable()
    this.setVisible @reloading, (!@picture.favable() and klekr.Global.currentCollector?)
    this.setVisible @loginReminder, !klekr.Global.currentCollector?
    if @picture.favable()
      faved = @picture.faved()
      this.setVisible(@faveLink, !faved)
      this._updateRating(@picture.data.rating)
      this.setVisible(@ratingDisplayPanel, faved)
      this.setVisible(@faved, faved)
      @removeFaveLink.attr('data-content', "This picture is added to my faves on #{@picture.favedDate}. Click to remove it." )

  _registerEvents: =>
    @faveLink.click_ this.fave
    @removeFaveLink.click_ this.unfave
    $('#fave-login').click this.login

  _updateRating: (rating) =>
    $.fn.raty.start(rating, '#faveRating');
    $.fn.raty.start(rating, '#ratingDisplay');

  _initRaty: (div)=>
    div.raty({
      start: 1
      path: '/assets/'
      size: 24
      target: '#faveRatingPanel #hint-message'
      hintList: ['I like it.', 'I would recommend it to others.', "One of the most impresive pictures I've seen for quite a while.", 'I would hang it in my home.', "It's probably a masterpiece."]
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
      [
        this._createRatingShortcut()
        new KeyShortcut(['f','c'], this.fave, 'fave the picture', @_canFave)
        new KeyShortcut('u', this.unfave, 'unfave the picture', => this.showing(@removeFaveLink))
      ]

  _canFave: =>
    gallery?.slide?.active() and @picture.favable()

  _ratingShortcutsEnabled: =>
    this._showingPopup() or this.showing(@ratingDisplayPanel)

  _createRatingShortcut: =>
    new KeyShortcut( ['1','2','3','4','5'],
      ( (e) =>
        rating = e.keyCode - 48
        console.log(rating)
        @_changeRating(rating)),
      'set fave rating accordingly',
      @_canFave
    )



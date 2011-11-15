class window.Picture extends Events

  @uniqConcat: (original, newOnes) =>
    h = {}
    h[p.id] = 1 for p in original
    added = []
    for newP in newOnes when not h[newP.id]?
      original.push newP
      added.push newP
    added

  @allGetViewed: (pictures) =>
    toMarkPictures = _(pictures).select (pic) -> pic._viewedMarkable()
    pic._setAsViewed() for pic in toMarkPictures

    if toMarkPictures.length > 0
      updatePath = toMarkPictures[0].data.getAllViewedPath
      picIds = ( pic.id for pic in toMarkPictures )
      klekr.Global.updater.post(updatePath, {ids: picIds})

  constructor: (@data) ->
    @id = @data.id
    _.defaults(this, @data)
    @width = 640
    @sizeReady = false
    @canUseLargeVersion = false
    @largeVersionAvailable = true
    @canUseMediumVersion = false
    @ready = false
    @index = null

  displayTitle:  =>
    t = @data.title
    if t? and t isnt '-' and t isnt '.' and t isnt ''
      @data.title
    else
      'Untitled'

  url: =>
    if @canUseLargeVersion
      @data.largeUrl
    else if @canUseMediumVersion
      @data.mediumUrl
    else
      @data.mediumSmallUrl


  smallUrl: => @data.smallUrl

  favable: =>
    @data.ofCurrentCollector

  fave: (rating) =>
    @data.rating = rating
    klekr.Global.updater.put @data.favePath, {rating: rating}

  unfave:  =>
    @data.rating = 0
    klekr.Global.updater.put @data.unfavePath

  getViewed: =>
    if this._viewedMarkable()
      klekr.Global.updater.put(@data.getViewedPath)
      this._setAsViewed()

  _setAsViewed: =>
    @data.viewed = true
    this.trigger('viewed')

  _viewedMarkable: =>
    !@data.viewed and this._inKlekr() and @data.ofCurrentCollector

  faved: => @data.rating > 0

  preload: =>
    this.preloadSmall this.preloadLarge

  preloadSmall: (callback)=>
    this._preloadImage @data.smallUrl, (image) =>
      [@smallWidth, @smallHeight] = [image.width, image.height]
      this.calculateFitVersion()
      this._updateData() if this._smallVersionMightBeInvalid(image)
      this.trigger('size-ready', this)
      callback?()

  reloadForCurrentCollector: =>
    this._updateData(skip_flickr_resync: true)

  calculateFitVersion: =>
    [largeWidth, largeHeight] = this.guessLargeSize()
    [mediumWidth, mediumHeight] = this.guessMediumSize()
    @canUseLargeVersion = @largeVersionAvailable and this._isSizeFit(largeWidth, largeHeight)
    @canUseMediumVersion = this._isSizeFit(mediumWidth, mediumHeight)
    @sizeReady = true

  _isSizeFit: (width, height) =>
    captionHeight = 20
    width < generalView.displayWidth and height < generalView.displayHeight - captionHeight

  _updateData: (opts = {}) =>
    if this._updatable()
      @alreadyUpdated = true
      klekr.Global.server.put resync_picture_path(id: @id), opts, (newData) =>
        @data = newData
        this.trigger('data-updated', this)


  _smallVersionMightBeInvalid: (image) =>
    image.width is 240 and image.height is 180

  _updatable: =>
    !@alreadyUpdated and this._inKlekr()

  _inKlekr: =>
    @data.getViewedPath?

  preloadLarge: (callback)=>
    this._preloadImage this.url(), (image)=>
      this._updateSize(image)
      callback?()

  _preloadImage: (url, onload) =>
    image = new Image()
    image.src = url
    $(image).load => onload(image) if onload?

  _updateSize: (image) =>
    unless this._largeVersionInvalid(image)
      @width = image.width
      @ready = true
      this.trigger('fully-ready', this)

  _largeVersionInvalid: (image) =>
    if @canUseLargeVersion
      if(image.width is 500 and image.height is 375)
        @canUseLargeVersion = false
        @largeVersionAvailable = false
        this._preloadImage @data.mediumUrl, this._updateSize
        true


  guessLargeSize: =>
    this._guessVersionSize(1024)

  guessMediumSize: =>
    this._guessVersionSize(640)

  _guessVersionSize: (versionLongEdge) =>
    longEdge = Math.max(@smallWidth, @smallHeight)
    ratio = versionLongEdge / longEdge
    [@smallWidth * ratio, @smallHeight * ratio]


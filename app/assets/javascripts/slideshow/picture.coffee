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
    @canUseLargeVersion = false
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
    else
      @data.mediumUrl

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
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      this._updateData() if this._smallVersionMightBeInvalid(image)
      this.trigger('small-version-ready')
      callback?()

  reloadForCurrentCollector: =>
    this._updateData(skip_flickr_resync: true)

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
    imageUrl = if @canUseLargeVersion then @data.largeUrl else @data.mediumUrl
    this._preloadImage imageUrl, (image)=>
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
      this.trigger('fully-ready')

  _largeVersionInvalid: (image) =>
    if @canUseLargeVersion
      if(image.width is 500 and image.height is 375)
        @canUseLargeVersion = false
        this._preloadImage @data.mediumUrl, this._updateSize
        true

  largerVersionWithinWindow: (image) =>
    [largeWidth, largeHeight] = this.guessLargeSize(image.width, image.height)
    captionHeight = 20
    largeWidth < generalView.displayWidth and largeHeight < generalView.displayHeight - captionHeight

  guessLargeSize: (smallerWidth, smallerHeight) =>
    longEdge = Math.max(smallerWidth, smallerHeight)
    ratio = 1024 / longEdge
    [smallerWidth * ratio, smallerHeight * ratio]





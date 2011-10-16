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
    unviewedPictures = _(pictures).select (pic) -> !pic.data.viewed and pic.data.collected
    if unviewedPictures.length > 0
      updatePath = unviewedPictures[0].data.getAllViewedPath
      pic.data.viewed = true for pic in unviewedPictures
      picIds = ( pic.id for pic in unviewedPictures )
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

  fave: (rating) =>
    @data.rating = rating
    klekr.Global.updater.put @data.favePath, {rating: rating}

  unfave:  =>
    @data.rating = 0
    klekr.Global.updater.put @data.unfavePath

  getViewed: =>
    unless @data.viewed
      klekr.Global.updater.put(@data.getViewedPath) if this._inKlekr
      @data.viewed = true

  faved: => @data.rating > 0

  preload: =>
    this.preloadSmall this.preloadLarge

  preloadSmall: (callback)=>
    this._preloadImage @data.smallUrl, (image) =>
      if this._smallVersionInValid(image) and this._updatable()
        this._updateData =>
          this.preloadSmall callback
      else
        @canUseLargeVersion = this.largerVersionWithinWindow(image)
        this.trigger('small-version-ready')
        callback?()

  _smallVersionInValid: (image) =>
    image.width is 240 and image.height is 180

  _updatable: =>
    !@alreadyUpdated and this._inKlekr

  _inKlekr: =>
    @data.getViewedPath?

  _updateData: (callback) =>
    unless @alreadyUpdated
      @alreadyUpdated = true
      klekr.Global.server.put resync_picture_path(id: @id), {}, (newData) =>
        @data = newData
        this.trigger('data-updated')
        callback?

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





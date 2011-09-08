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
      server.post(updatePath, {ids: picIds})

  constructor: (@data) ->
    @id = @data.id
    @width = 640
    @canUseLargeVersion = slideview.largeWindow()
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

  smallUrl: =>
    @data.smallUrl

  fave: (rating, onSuccess) =>
    server.put @data.favePath, {rating: rating}, =>
      @data.rating = rating
      onSuccess()

  unfave: (onSuccess) =>
    server.put @data.unfavePath, {}, =>
      @data.rating = 0
      onSuccess()

  faved: =>
    @data.rating > 0

  preload: =>
    this.preloadSmall this.preloadLarge

  preloadSmall: (callback)=>
    this._preloadImage @data.smallUrl, (image) =>
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      this.trigger('small-version-ready')
      callback?()

  preloadLarge: (callback)=>
    imageUrl = if @canUseLargeVersion then @data.largeUrl else @data.mediumUrl
    this._preloadImage imageUrl, (image)=>
      this._updateSize(image)
      callback?()

  getViewed: =>
    unless @data.viewed
      server.put(@data.getViewedPath) if @data.getViewedPath
      @data.viewed = true

  _preloadImage: (url, onload) =>
    console.debug('preloading ' + this.index + ' ' + url)
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





class window.Picture extends Events

  @uniqConcat: (original, newOnes) ->
    h = {}
    h[p.id] = 1 for p in original
    original.push newP for newP in newOnes when not h[newP.id]?
    original

  constructor: (@data) ->
    @id = @data.id
    @width = 640
    @canUseLargeVersion = view.largeWindow()

  url: ->
    if @canUseLargeVersion
      @data.largeUrl
    else
      @data.mediumUrl

  smallUrl: ->
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

  preload: ->
    this.preloadSmall this.preloadLarge

  preloadSmall: (callback)=>
    this._preloadImage @data.smallUrl, (image) =>
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      this.trigger('small-version-ready')
      callback?()

  preloadLarge: ->
    if @canUseLargeVersion
      this._preloadImage @data.largeUrl, this._updateSize
    else
      this._preloadImage @data.mediumUrl, this._updateSize

  getViewed: ->
    unless @data.viewed
      server.put(@data.getViewedPath)
      @data.viewed = true

  _preloadImage: (url, onload) ->
    image = new Image()
    image.src = url
    $(image).load => onload(image) if onload?

  _updateSize: (image) =>
    unless this._largeVersionInvalid(image)
      @width = image.width
      this.trigger('fully-ready')

  _largeVersionInvalid: (image) =>
    if @canUseLargeVersion
      if(image.width is 500 and image.height is 375)
        @canUseLargeVersion = false
        this._preloadImage @data.mediumUrl, this._updateSize
        true

  largerVersionWithinWindow: (image) ->
    [largeWidth, largeHeight] = this.guessLargeSize(image.width, image.height)
    largeWidth < view.displayWidth and largeHeight < view.displayHeight - 41

  guessLargeSize: (smallerWidth, smallerHeight) ->
    longEdge = Math.max(smallerWidth, smallerHeight)
    ratio = 1024 / longEdge
    [smallerWidth * ratio, smallerHeight * ratio]





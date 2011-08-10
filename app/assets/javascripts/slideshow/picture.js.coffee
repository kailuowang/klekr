class window.Picture

  @uniqConcat: (original, newOnes) ->
    h = {}
    h[p.id] = 1 for p in original
    original.push newP for newP in newOnes when not h[newP.id]?
    original

  constructor: (@data) ->
    @id = @data.id
    @width = 640
    this.preload() if @data.mediumUrl?

  url: ->
    if @canUseLargeVersion
      @data.largeUrl
    else
      @data.mediumUrl

  smallUrl: ->
    @data.smallUrl

  fave: (onSuccess) ->
    server.put @data.favePath, {}, =>
      @data.faved = true
      onSuccess()

  preload: ->
    if view.largeWindow()
      @canUseLargeVersion = true
      this.preloadImage @data.smallUrl
      this.preloadImage @data.largeUrl, this.updateSize
    else
      this.preloadAdaptiveSize()

  preloadAdaptiveSize: ->
    this.preloadImage @data.smallUrl, (image) =>
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      if @canUseLargeVersion
        this.preloadImage @data.largeUrl, this.updateSize
      else
        this.preloadImage @data.mediumUrl, this.updateSize

  getViewed: ->
    unless @viewed
      server.put(@data.getViewedPath)
      @viewed = true

  preloadImage: (url, onload) ->
    image = new Image()
    image.src = url
    $(image).load => onload(image) if onload?

  updateSize: (image) =>
    unless this.largeVersionInvalid(image)
      @width = image.width

  largeVersionInvalid: (image) =>
    if @canUseLargeVersion
      if(image.width is 500 and image.height is 375)
        @canUseLargeVersion = false
        this.preloadImage @data.mediumUrl, this.updateSize
        true

  largerVersionWithinWindow: (image) ->
    [largeWidth, largeHeight] = this.guessLargeSize(image.width, image.height)
    largeWidth < view.displayWidth and largeHeight < view.displayHeight - 31


  guessLargeSize: (smallerWidth, smallerHeight) ->
    longEdge = Math.max(smallerWidth, smallerHeight)
    ratio = 1024 / longEdge
    [smallerWidth * ratio, smallerHeight * ratio]





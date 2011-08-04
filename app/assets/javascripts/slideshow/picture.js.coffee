class window.Picture
  @uniq: (pictures) ->
    h = {}
    h[p.id] = p for p in pictures
    p for id, p of h

  @uniqConcat: (original, newOnes) ->
    h = {}
    h[p.id] = 1 for p in original
    original.push newP for newP in newOnes when not h[newP.id]?
    original

  constructor: (@data) ->
    @id = @data.id
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
      this.preloadImage @data.largeUrl
    else
      this.preloadAdaptiveSize()

  preloadAdaptiveSize: ->
    this.preloadImage @data.smallUrl, (image) =>
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      if @canUseLargeVersion
        this.preloadImage @data.largeUrl
      else
        this.preloadImage @data.mediumUrl

  getViewed: ->
    unless @viewed
      server.put(@data.getViewedPath)
      @viewed = true

  preloadImage: (url, onload) ->
    image = new Image()
    image.src = url
    $(image).load -> onload(image) if onload?

  largerVersionWithinWindow: (image) ->
    [largeWidth, largeHeight] = this.guessLargeSize(image.width, image.height)
    largeWidth < view.displayWidth and largeHeight < view.displayHeight


  guessLargeSize: (smallerWidth, smallerHeight) ->
    longEdge = Math.max(smallerWidth, smallerHeight)
    ratio = 1024 / longEdge
    [smallerWidth * ratio, smallerHeight * ratio]





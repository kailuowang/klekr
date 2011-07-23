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

  @retrieveNew: (num, oldOnes, callback) ->
    excludeIds = (p.id for p in oldOnes)
    server.newPictures(num, excludeIds, (data) =>
      pictures = ( new Picture(picData) for picData in data )
      callback(pictures)
    )

  constructor: (@data) ->
    @id = @data.id
    this.preload() if @data.mediumUrl?

  url: ->
    if @canUseLargeVersion
      @data.largeUrl
    else
      @data.mediumUrl

  id: -> id

  preload: ->
    this.preloadImage @data.mediumUrl, (image) =>
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      if @canUseLargeVersion
        this.preloadImage @data.largeUrl

  getViewed: ->
    server.post(@data.getViewedPath)

  preloadImage: (url, onload) ->
    image = new Image()
    image.src = url
    $(image).load -> onload(image) if onload?

  largerVersionWithinWindow: (image) ->
    [largeWidth, largeHeight] = this.guessLargeSize(image.width, image.height)
    displayWidth = $(window).width() - 50
    displayHeight = $(window).height() - 200
    largeWidth < displayWidth and largeHeight < displayHeight

  guessLargeSize: (mediumWidth, mediumHeight) ->
    longEdge = Math.max(mediumWidth, mediumHeight)
    ratio = 1024 / longEdge
    [mediumWidth * ratio, mediumHeight * ratio]





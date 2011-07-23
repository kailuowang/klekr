class window.Picture
  constructor: (data) ->
    @largeUrl = data.large_url
    @mediumUrl = data.medium_url
    @nextPicturesPathTemplate = data.next_pictures_path
    @interestingess = data.interestingess

    this.preload()

  url: ->
    if @canUseLargeVersion
      @largeUrl
    else
      @mediumUrl

  retrieveNextPictures: (num, callback) ->
    server.get(this.nextPicturesPath(num), (data) =>
      pictures = ( new Picture(picData) for picData in data )
      callback(pictures)
    )

  preload: ->
    this.preloadImage @mediumUrl, (image) =>
      @canUseLargeVersion = this.largerVersionWithinWindow(image)
      if @canUseLargeVersion
        this.preloadImage @largeUrl, => @isReady = true
      else
        @isReady = true

  preloadImage: (url, onload) ->
    image = new Image()
    image.src = url
    $(image).load -> onload(image)

  largerVersionWithinWindow: (image) ->
    [largeWidth, largeHeight] = this.guessLargeSize(image.width, image.height)
    displayWidth = $(window).width() - 50
    displayHeight = $(window).height() - 200
    largeWidth < displayWidth and largeHeight < displayHeight

  guessLargeSize: (mediumWidth, mediumHeight) ->
    longEdge = Math.max(mediumWidth, mediumHeight)
    ratio = 1024 / longEdge
    [mediumWidth * ratio, mediumHeight * ratio]

  nextPicturesPath: (num) ->
    @nextPicturesPathTemplate + num


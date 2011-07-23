class window.Slideshow

  constructor: ->
    @currentIndex = 0
    @cacheSize = 50
    this.initPictures()
    view.nextClicked(() => this.navigateToNext())
    view.previousClicked(() => this.navigateToPrevious())

  initPictures: ->
    @pictures = []
    server.currentPicture((data) =>
      @pictures.push(new Picture(data))
      this.displayCurrentPicture()
      this.retrieveMorePictures()
    )

  displayCurrentPicture: ->
    view.display(this.currentPicture())

  retrieveMorePictures: ->
    targetPicture = this.lastPicture()
    if targetPicture?
      targetPicture.retrieveNextPictures(10, (newPictures) =>
        @pictures = @pictures.concat(newPictures)
      )

  ensurePictureCache: ->
    if @pictures.length - @currentIndex < @cacheSize
      this.retrieveMorePictures()

  lastPicture: ->
    @pictures[@pictures.length - 1] if @pictures.length > 0

  currentPicture: ->
    @pictures[@currentIndex]

  navigateToNext: ->
    if @currentIndex < @pictures.length - 1
      @currentIndex += 1
      this.displayCurrentPicture()
      this.ensurePictureCache()

  navigateToPrevious: ->
    if @currentIndex > 0
      @currentIndex -= 1
      this.displayCurrentPicture()

  report: ->
    readyPictures = (p for p in @pictures when p.isRead?)
    canUseLargePictures = (p for p in @pictures when p.canUseLargeVersion?)
    console.info """
      Total pictures in cache: #{@pictures.length}
      ready:  #{readyPictures.length}
      canUseLarge: #{canUseLargePictures.length}
    """

$(document).ready ->
  window.view = new View
  window.server = new Server
  window.slideshow = new Slideshow
  bindKeys()

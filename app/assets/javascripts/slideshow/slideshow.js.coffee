class window.Slideshow

  constructor: ->
    @currentIndex = 0
    @cacheSize = 50
    this.initPictures()
    view.nextClicked  => this.navigateToNext()
    view.previousClicked => this.navigateToPrevious()

  initPictures: ->
    @pictures = []
    server.currentPicture (data) =>
      @pictures.push(new Picture(data))
      this.displayCurrentPicture()
      this.retrieveMorePictures()

  displayCurrentPicture: ->
    view.display(this.currentPicture())

  retrieveMorePictures: ->
    Picture.retrieveNew(10, this.unseenPictures(), (newPictures) =>
      Picture.uniqConcat(@pictures, newPictures)
    )

  unseenPictures: ->
    @pictures[@currentIndex...@pictures.length]

  ensurePictureCache: ->
    if @pictures.length - @currentIndex < @cacheSize
      this.retrieveMorePictures()

  lastPicture: ->
    @pictures[@pictures.length - 1] if @pictures.length > 0

  currentPicture: ->
    @pictures[@currentIndex]

  navigateToNext: ->
    this.currentPicture().getViewed()
    unless this.atTheLast()
      @currentIndex += 1
      this.displayCurrentPicture()
      this.ensurePictureCache()

  navigateToPrevious: ->
    unless this.atTheBegining()
      @currentIndex -= 1
      this.displayCurrentPicture()

  atTheLast: ->
    @currentIndex == @pictures.length - 1

  atTheBegining: ->
    @currentIndex == 0


  report: ->
    readyPictures = (p for p in @pictures when p.isRead?)
    canUseLargePictures = (p for p in @pictures when p.canUseLargeVersion?)
    console.info """
      Total pictures in cache: #{@pictures.length}
      ready:  #{readyPictures.length}
      canUseLarge: #{canUseLargePictures.length}
      duplicates: #{@pictures.length - Picture.uniq(@pictures).length}
    """






$(document).ready ->
  window.view = new View
  window.server = new Server
  window.slideshow = new Slideshow
  bindKeys()

class window.Slideshow

  constructor: ->
    @currentIndex = 0
    @cacheSize = 50
    this.initPictures()
    view.nextClicked  => this.navigateToNext()
    view.previousClicked => this.navigateToPrevious()
    view.faveClicked => this.faveCurrentPicture()

  initPictures: ->
    @pictures = []
    server.firstPicture (data) =>
      @pictures.push(new Picture(data))
      this.displayCurrentPicture()
      this.retrieveMorePictures()

  displayCurrentPicture: ->
    view.display(this.currentPicture())

  retrieveMorePictures: ->
    Picture.retrieveNew(10, this.unseenPictures(), (newPictures) =>
      this.addPictures(newPictures)
    )

  addPictures: (newPictures) ->
    unless @addingPictures
      @addingPictures = true
      Picture.uniqConcat(@pictures, newPictures)
      @addingPictures = false

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

  faveCurrentPicture: ->
    view.changingFavedStatus()
    this.currentPicture().fave =>
      view.updateFavedStatus(this.currentPicture())

  atTheLast: ->
    @currentIndex == @pictures.length - 1

  atTheBegining: ->
    @currentIndex == 0


  report: ->
    canUseLargePictures = (p for p in @pictures when p.canUseLargeVersion?)
    console.info """
      Total pictures in cache: #{@pictures.length}
      canUseLarge: #{canUseLargePictures.length}
      duplicates: #{@pictures.length - Picture.uniq(@pictures).length}
    """




$(document).ready ->
  window.view = new View
  window.server = new Server
  window.slideshow = new Slideshow
  bindKeys()

class window.Slide
  constructor: ->
    @currentIndex = 0
    view.faveClicked this.faveCurrentPicture

  faveCurrentPicture: =>
    view.changingFavedStatus()
    this.currentPicture().fave =>
      view.updateFavedStatus(this.currentPicture())

  displayCurrentPicture: =>
    view.display(this.currentPicture())

  currentPicture: =>
    gallery.pictures[@currentIndex]

  navigateToNext: =>
    this.currentPicture().getViewed()
    unless this.atTheLast()
      @currentIndex += 1
      this.displayCurrentPicture()
      gallery.ensurePictureCache()

  navigateToPrevious: =>
    unless this.atTheBegining()
      @currentIndex -= 1
      this.displayCurrentPicture()

  atTheLast: =>
    @currentIndex == gallery.size() - 1

  atTheBegining: =>
    @currentIndex == 0

  onFirstPictureLoad: =>
    this.displayCurrentPicture()

  currentProgress: =>
    @currentIndex

  updateProgress: (progress) =>
    @currentIndex = progress
    this.displayCurrentPicture()

  show: =>
    view.showHideGridview(false)
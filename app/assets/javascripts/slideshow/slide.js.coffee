class window.Slide
  constructor: ->
    @currentIndex = 0
    @favePanel = new FavePanel(this.currentPicture)
    view.toGridLinkClick this.backToGrid

  displayCurrentPicture: =>
    view.display(this.currentPicture())
    @favePanel.updateFavedStatus(this.currentPicture())


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

  backToGrid: =>
    this.currentPicture().getViewed()
    gallery.toggleMode()

  shortcuts: =>
    @_shortcuts ?= [
      new KeyShortcut ['right', 'space'], this.navigateToNext, 'next picture'
      new KeyShortcut 'left', this.navigateToPrevious, 'previous picture'
      new KeyShortcut 'f', @favePanel.fave, 'fave picture'
      new KeyShortcut 'o', view.gotoOwner, "go to photographer's page"
      new KeyShortcut ['g', 'return'], this.backToGrid, "go to grid mode"
    ]
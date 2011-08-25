class window.Slide extends ModeBase
  constructor: ->
    @currentIndex = 0
    @favePanel = new FavePanel(this.currentPicture)
    view.toGridLinkClick this.backToGrid
    super()

  displayCurrentPicture: =>
    view.display(this.currentPicture())
    view.displayProgress(this.atTheLast(), this.atTheBegining())
    @favePanel.updateFavedStatus()

  currentPicture: =>
    gallery.pictures[@currentIndex]

  navigateToNext: =>
    this.currentPicture().getViewed()
    unless this.atTheLast()
      @currentIndex += 1
      this.displayCurrentPicture()
      this.trigger('progress-changed')

  navigateToPrevious: =>
    unless this.atTheBegining()
      @currentIndex -= 1
      this.displayCurrentPicture()

  atTheLast: =>
    @currentIndex == gallery.size() - 1

  atTheBegining: =>
    @currentIndex == 0

  onFirstBatchOfPicturesLoaded: =>
    this.displayCurrentPicture()

  currentProgress: =>
    @currentIndex

  updateProgress: (progress) =>
    @currentIndex = progress
    this.displayCurrentPicture()

  backToGrid: =>
    this.currentPicture().getViewed()
    gallery.toggleMode()

  view: ->
    view

  shortcutsSettings: ->
    [
      [ ['right', 'space'], this.navigateToNext, 'next picture' ]
      [ 'left', this.navigateToPrevious, 'previous picture' ]
      [ 'o', view.gotoOwner, "go to photographer's page" ]
      [ ['g', 'return'], this.backToGrid, "go to grid mode" ]
    ]
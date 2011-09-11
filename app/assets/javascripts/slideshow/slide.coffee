class window.Slide extends ModeBase
  constructor: ->
    this.reset()
    @favePanel = new FavePanel(this.currentPicture)
    super()

  reset: =>
    @currentIndex = 0

  displayCurrentPicture: =>
    slideview.display(this.currentPicture())
    @favePanel.updateFavedStatus()
    this.trigger('progress-changed')

  currentPicture: =>
    gallery.pictures[@currentIndex]

  navigateToNext: =>
    this.currentPicture().getViewed()
    unless this.atTheLast()
      @currentIndex += 1
      this.displayCurrentPicture()
      this.trigger('progressed')

  navigateToPrevious: =>
    unless this.atTheBegining()
      @currentIndex -= 1
      this.displayCurrentPicture()

  atTheLast: =>
    @currentIndex == gallery.size() - 1 and !gallery.isLoading()

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

  view: -> slideview

  shortcutsSettings: ->
    [
      [ ['right', 'space'], this.navigateToNext, 'next picture' ]
      [ 'left', this.navigateToPrevious, 'previous picture' ]
      [ 'up', this.backToGrid, 'go to grid mode' ]
      [ 'o', slideview.gotoOwner, "go to photographer's page" ]
      [ ['g', 'return'], this.backToGrid, "go to grid mode" ]
    ]
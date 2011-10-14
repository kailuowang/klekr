class window.Slide extends ModeBase
  constructor: ->
    this.reset()
    @favePanel = new FavePanel(this.currentPicture)
    slideview.pictureClick this.backToGrid
    super('slide')

  reset: =>
    @currentIndex = 0

  displayCurrentPicture: =>
    picture = this.currentPicture()
    slideview.display(picture)
    @favePanel.updateFavedStatus()
    this.trigger('progress-changed')

  currentPicture: =>
    gallery.pictures[@currentIndex]

  navigateToNext: =>
    this.currentPicture().getViewed()
    unless this.atTheLast()
      this.goToIndex((@currentIndex + 1))
      this.trigger('progressed')

  navigateToPrevious: =>
    unless this.atTheBegining()
      this.goToIndex((@currentIndex - 1))

  atTheLast: =>
     @currentIndex == gallery.size() - 1

  atTheBegining: =>
    @currentIndex == 0


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
      [ 'o', slideview.gotoOwner, "go to artist's page" ]
      [ 'shift+o', (=> slideview.gotoOwner(true)), "open artist's page in new tab" ]
      [ ['g', 'return', 'up'], this.backToGrid, "go to grid mode" ]
    ].concat(unless klekr.Global.readonly then [[ 'l', slideview.label.expand, "expand picture label" ]] else [])
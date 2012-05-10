class window.Slide extends ModeBase
  constructor: ->
    this.reset()
    @favePanel = new FavePanel
    slideview.pictureClick this.backToGrid
    generalView.bind('layout-changed', this._redisplayPicture)
    super('slide')

  reset: =>
    @currentIndex = 0

  currentPicture: =>
    gallery.pictures[@currentIndex]

  navigateToNext: (commander)=>
    this.currentPicture().getViewed()
    unless this.atTheLast()
      this.goToIndex((@currentIndex + 1))
      this.trigger('progressed')
      this.trigger('command-to-navigate', commander)

  navigateToPrevious: (commander)=>
    unless this.atTheBegining()
      this.goToIndex((@currentIndex - 1))
      this.trigger('command-to-navigate', commander)

  atTheLast: =>
     @currentIndex == gallery.size() - 1

  atTheBegining: =>
    @currentIndex == 0

  currentProgress: =>
    @currentIndex

  updateProgress: (progress) =>
    @currentIndex = progress
    this._displayCurrentPicture()

  backToGrid: =>
    this.currentPicture().getViewed()
    gallery.toggleMode()

  view: -> slideview

  shortcutsSettings: ->
    [
      [ ['right', 'space'], this.navigateToNext, 'Next picture' ]
      [ 'left', this.navigateToPrevious, 'Previous picture' ]
      [ 'o', slideview.gotoOwner, "Go to photographer's page" ]
      [ 'shift+o', (=> slideview.gotoOwner(true)), "Open photographer's page in new tab" ]
      [ ['g', 'return', 'up'], this.backToGrid, "Go to grid mode" ]
      [ 'l', slideview.label.expand, "Expand picture label" ]
    ]

  _monitorPictureReady: (picture) =>
    picture.bind 'size-ready', (pic) =>
      if pic.id is this.currentPicture().id
        slideview.display(pic)

  _redisplayPicture: =>
    if this.active()
      picture = this.currentPicture()
      if(picture? and picture.sizeReady)
        picture.calculateFitVersion()
        slideview.update()

  _extraHashInfo: (index)=>
    "-" + gallery.pictures[index].id

  _displayCurrentPicture: =>
    picture = this.currentPicture()
    if picture.sizeReady
      picture.calculateFitVersion()
      slideview.display(picture)
    else
      slideview.displayLabel(picture)
      this._monitorPictureReady(picture)
    @favePanel.updateWith(picture)
    this.trigger('progress-changed')

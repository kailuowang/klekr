class window.Slide extends ModeBase
  constructor: ->
    this.reset()
    @favePanel = new FavePanel
    slideview.pictureClick this.backToGrid
    generalView.bind('layout-changed', this._redisplayPicture)
    super('slide')

  reset: =>
    @currentIndex = 0

  displayCurrentPicture: =>
    picture = this.currentPicture()
    if picture.sizeReady
      picture.calculateFitVersion()
      slideview.display(picture)
    else
      slideview.displayLabel(picture)
      this._monitorPictureReady(picture)
    @favePanel.updateWith(picture)
    this.trigger('progress-changed')

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
    this.displayCurrentPicture()

  backToGrid: =>
    this.currentPicture().getViewed()
    gallery.toggleMode()

  view: -> slideview

  shortcutsSettings: ->
    [
      [ ['right', 'space'], this.navigateToNext, 'next picture' ]
      [ 'left', this.navigateToPrevious, 'previous picture' ]
      [ 'o', slideview.gotoOwner, "go to photographer's page" ]
      [ 'shift+o', (=> slideview.gotoOwner(true)), "open photographer's page in new tab" ]
      [ ['g', 'return', 'up'], this.backToGrid, "go to grid mode" ]
    ].concat(unless klekr.Global.readonly then [[ 'l', slideview.label.expand, "expand picture label" ]] else [])

  _monitorPictureReady: (picture) =>
    picture.bind 'size-ready', (pic) =>
      if pic.id is this.currentPicture().id
        slideview.display(pic)

  _redisplayPicture: =>
    if this.active()
      picture = this.currentPicture()
      if(picture? and picture.sizeReady)
        picture.calculateFitVersion()
        slideview.update(picture)

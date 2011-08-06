class window.Slideshow

  constructor: ->
    @currentIndex = 0
    @currentPage = 0
    @cacheSize = gridview.size() * 2

    this.initPictures()

    view.nextClicked this.navigateToNext
    view.previousClicked this.navigateToPrevious
    view.faveClicked this.faveCurrentPicture
    view.toggleGridview() if __gridMode__?

  initPictures: ->
    @pictures = []
    server.firstPicture (data) =>
      @pictures.push(new Picture(data))
      this.displayCurrentPicture()
      this.retrieveMorePictures this.loadGridview

  displayCurrentPicture: ->
    view.display(this.currentPicture())
    gridview.highlightPicture(this.currentPicture())

  retrieveMorePictures: (onRetrieve)->
    @currentPage += 1
    excludeIds = (p.id for p in this.unseenPictures())
    opts = { num: gridview.size(), exclude_ids: excludeIds, page: @currentPage }
    server.morePictures opts, (data) =>
      this.addPictures(
        new Picture(picData) for picData in data
      )
      onRetrieve() if onRetrieve?

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

  navigateToNext: =>
    this.currentPicture().getViewed()
    unless this.atTheLast()
      @currentIndex += 1
      this.checkPage(true)
      this.displayCurrentPicture()
      this.ensurePictureCache()

  navigateToPrevious: =>
    unless this.atTheBegining()
      @currentIndex -= 1
      this.checkPage(false)
      this.displayCurrentPicture()

  faveCurrentPicture: =>
    view.changingFavedStatus()
    this.currentPicture().fave =>
      view.updateFavedStatus(this.currentPicture())

  checkPage: (goingForward) ->
    if this.pageChanged(goingForward)
      this.loadGridview()

  pageChanged: (goingForward) ->
    changingPosition =  if(goingForward) then 0 else gridview.size() - 1
    (@currentIndex % gridview.size()) == changingPosition

  loadGridview: =>
    gridview.loadPictures(this.currentPageOfPictures())
    gridview.highlightPicture(this.currentPicture())

  currentPageOfPictures: () ->
    positionInPage = @currentIndex % gridview.size()
    pageStart = @currentIndex - positionInPage
    pageEnd = pageStart + gridview.size() - 1
    @pictures[pageStart..pageEnd]

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
  window.gridview = new Gridview
  window.slideshow = new Slideshow
  new StreamPanel
  new KeyShortcuts


class window.Gallery

  constructor: ->
    @currentPage = 0
    @cacheSize = gridview.size * 2
    [@grid, @slide] = [new Grid, new Slide]
    @currentMode = if __gridMode__? then @grid else @slide
    this.initPictures()
    view.nextClicked this.next
    view.previousClicked this.previous

  initPictures: =>
    @pictures = []
    server.firstPicture (data) =>
      @pictures.push(new Picture(data))
      @currentMode.onFirstPictureLoad?()
      this.retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded

  next: =>
    @currentMode.navigateToNext?()

  previous: =>
    @currentMode.navigateToPrevious?()

  retrieveMorePictures: (onRetrieve)->
    @currentPage += 1
    excludeIds = (p.id for p in this.unseenPictures())
    opts = { num: gridview.size, exclude_ids: excludeIds, page: @currentPage }
    server.morePictures opts, (data) =>
      this.addPictures(
        new Picture(picData) for picData in data
      )
      onRetrieve() if onRetrieve?

  size: =>
    @pictures.length

  addPictures: (newPictures) ->
    unless @addingPictures
      @addingPictures = true
      Picture.uniqConcat(@pictures, newPictures)
      @addingPictures = false

  toggleMode: =>
    progress = this.currentProgress()
    @currentMode = if @currentMode is @grid then @slide else @grid
    @currentMode.updateProgress(progress)
    @currentMode.show()


  unseenPictures: ->
    @pictures[this.currentProgress()...@pictures.length]

  ensurePictureCache: ()=>
    if @pictures.length - this.currentProgress() < @cacheSize
      this.retrieveMorePictures()

  currentProgress: =>
    @currentMode.currentProgress()



$(document).ready ->
  window.view = new View
  window.server = new Server
  window.gridview = new Gridview
  window.gallery = new Gallery
  new StreamPanel
  new KeyShortcuts


class window.Gallery

  constructor: ->
    @currentPage = 0
    @cacheSize = gridview.size * 2
    [@grid, @slide] = [new Grid, new Slide]
    @currentMode = if __gridMode__? then @grid else @slide
    view.nextClick =>
      @currentMode.navigateToNext?()
    view.previousClick =>
      @currentMode.navigateToPrevious?()

  init: =>
    @pictures = []
    if server.firstPicturePath
      server.firstPicture (data) =>
        @pictures.push(new Picture(data))
        @currentMode.onFirstPictureLoad?()
        this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded
    else
      this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded
    this._bindShortcuts()
    @currentMode.show()

  findIndex: (picId)=>
    (i for picture, i in @pictures when picture.id is picId)[0]

  _retrieveMorePictures: (onRetrieve)->
    @currentPage += 1
    excludeIds = (p.id for p in this.unseenPictures())
    opts = { num: @cacheSize, exclude_ids: excludeIds, page: @currentPage }
    server.morePictures opts, (data) =>
      this.addPictures(
        new Picture(picData) for picData in data
      )
      onRetrieve() if onRetrieve?

  _bindShortcuts: =>
    keyShortcuts.bind(@currentMode.shortcuts())

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
    this._bindShortcuts()
    @currentMode.show()

  unseenPictures: ->
    @pictures[this.currentProgress()...@pictures.length]

  ensurePictureCache: ()=>
    if @pictures.length - this.currentProgress() < @cacheSize
      this._retrieveMorePictures @currentMode.onMorePicturesLoaded

  currentProgress: =>
    @currentMode.currentProgress()

  report: ->
    console.debug "cache size: " + @cacheSize
    console.debug "current flickr page: " + @currentPage
    console.debug "gridview size: " + gridview.size
    console.debug "pictures size: " + @pictures.length
    console.debug "current progress: " + this.currentProgress()


$(document).ready ->
  window.keyShortcuts = new KeyShortcuts
  window.view = new View
  window.server = new Server
  window.gridview = new Gridview
  window.gallery = new Gallery
  new StreamPanel
  gallery.init()


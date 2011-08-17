class window.Gallery

  constructor: ->
    @ratingFilter = 1
    @cacheSize = gridview.size * 2
    [@grid, @slide] = [new Grid, new Slide]
    @currentMode = if __gridMode__? then @grid else @slide
    view.nextClick =>
      @currentMode.navigateToNext?()
    view.previousClick =>
      @currentMode.navigateToPrevious?()
    @filterView = new FilterView
    @filterView.ratingFilterChange this._applyRatingFilter

  init: =>
    @currentPage = 0
    @pictures = []
    if server.firstPicturePath
      server.firstPicture (data) =>
        @pictures.push(new Picture(data))
        @currentMode.onFirstPictureLoad?()
        this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded
    else
      this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded
    @currentMode.show()

  findIndex: (picId)=>
    (i for picture, i in @pictures when picture.id is picId)[0]

  _retrieveMorePictures: (onRetrieve)->
    @currentPage += 1
    retriever = new PictureRetriever(@currentPage, @cacheSize, this._filterOpts())
    retriever.retrieve(this._addPictures)
    retriever.retrieve(onRetrieve) if onRetrieve?
    retriever.retrieve()

  _applyRatingFilter: (rating) =>
    @ratingFilter = rating
    @currentMode = @grid
    this.init()

  _filterOpts: =>
    excludeIds = (p.id for p in this._unseenPictures())
    {exclude_ids: excludeIds, min_rating: @ratingFilter }

  size: =>
    @pictures.length

  _addPictures: (newPictures) =>
    unless @addingPictures
      @addingPictures = true
      Picture.uniqConcat(@pictures, newPictures)
      @addingPictures = false

  toggleMode: =>
    progress = this.currentProgress()
    @currentMode = if @currentMode is @grid then @slide else @grid
    @currentMode.updateProgress(progress)
    @currentMode.show()

  _unseenPictures: ->
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


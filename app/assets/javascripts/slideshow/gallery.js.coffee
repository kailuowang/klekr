class window.Gallery

  constructor: ->
    @ratingFilter = 1
    @cacheSize = gridview.size * 2
    [@grid, @slide] = modes = [new Grid, new Slide]
    mode.bind('progress-changed', this._ensurePictureCache) for mode in modes
    @currentMode = if __gridMode__? then @grid else @slide
    view.nextClick => @currentMode.navigateToNext?()
    view.previousClick => @currentMode.navigateToPrevious?()
    @filterView = new FilterView
    @filterView.ratingFilterChange this._applyRatingFilter

  init: =>
    @currentPage = 0
    @pictures = []
    this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded, @currentMode.onFirstPictureLoad
    @currentMode.show()

  findIndex: (picId)=>
    (i for picture, i in @pictures when picture.id is picId)[0]

  _retrieveMorePictures: (onRetrieve, onFirstPictureReady) ->
    unless @retriever?
      @currentPage += 1
      @retriever = new PictureRetriever(@currentPage, @cacheSize, this._filterOpts())
      @retriever.onRetrieve(this._addPictures)
      @retriever.onRetrieve(onRetrieve) if onRetrieve?
      @retriever.onRetrieve => @retriever = null
      @retriever.bind('first-picture-ready', onFirstPictureReady) if onFirstPictureReady?
      @retriever.retrieve()

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

  _ensurePictureCache: ()=>
    if @pictures.length - this.currentProgress() < @cacheSize
      unless @retriever?
        this._retrieveMorePictures @currentMode.onMorePicturesLoaded
      else
        @retriever.onRetrieve(this._ensurePictureCache)

  currentProgress: =>
    @currentMode.currentProgress()

  report: ->
    readyPictures = _(@pictures).select (p) -> p.ready
    console.debug "cache size: " + @cacheSize
    console.debug "pictures in cache: " + @pictures.length
    console.debug "pictures preloaded: " + readyPictures.length
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


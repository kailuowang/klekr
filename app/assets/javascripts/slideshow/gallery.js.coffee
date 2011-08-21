class window.Gallery

  constructor: ->
    @cacheSize = gridview.size * 2
    [@grid, @slide] = modes = [new Grid, new Slide]
    mode.bind('progress-changed', this._ensurePictureCache) for mode in modes
    @currentMode = if __gridMode__? then @grid else @slide
    view.nextClick => @currentMode.navigateToNext?()
    view.previousClick => @currentMode.navigateToPrevious?()
    @filterView = new FilterView(@grid)
    @filterView.ratingFilterChange this._applyRatingFilter

  init: =>
    @currentPage = 0
    @pictures = []
    this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded, @currentMode.onFirstPictureLoad
    this._alternativeView().off()
    @currentMode.on()

  findIndex: (picId)=>
    (i for picture, i in @pictures when picture.id is picId)[0]

  size: =>
    @pictures.length

  toggleMode: =>
    progress = this._currentProgress()
    @currentMode.off()
    @currentMode = this._alternativeView()
    @currentMode.on()
    @currentMode.updateProgress(progress)

  _alternativeView: =>
    if @currentMode is @grid then @slide else @grid

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
    @_ratingFilter = rating
    @currentMode = @grid
    this.init()

  _filterOpts: =>
    excludeIds = (p.id for p in this._unseenPictures())
    _.tap {}, (opts) =>
      opts.exclude_ids = excludeIds
      opts.min_rating = @_ratingFilter if @_ratingFilter?

  _addPictures: (newPictures) =>
    unless @addingPictures
      @addingPictures = true
      Picture.uniqConcat(@pictures, newPictures)
      @addingPictures = false

  _unseenPictures: ->
    @pictures[this._currentProgress()...@pictures.length]

  _ensurePictureCache: ()=>
    if @pictures.length - this._currentProgress() < @cacheSize
      unless @retriever?
        this._retrieveMorePictures @currentMode.onMorePicturesLoaded
      else
        @retriever.onRetrieve(this._ensurePictureCache)

  _currentProgress: =>
    @currentMode.currentProgress()

  report: ->
    readyPictures = _(@pictures).select (p) -> p.ready
    console.debug "cache size: " + @cacheSize
    console.debug "pictures in cache: " + @pictures.length
    console.debug "pictures preloaded: " + readyPictures.length
    console.debug "current flickr page: " + @currentPage
    console.debug "gridview size: " + gridview.size
    console.debug "pictures size: " + @pictures.length
    console.debug "current progress: " + this._currentProgress()


$(document).ready ->
  window.keyShortcuts = new KeyShortcuts
  window.view = new View
  window.server = new Server
  window.gridview = new Gridview
  window.gallery = new Gallery
  new StreamPanel
  gallery.init()


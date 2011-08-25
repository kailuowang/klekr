class window.Gallery

  constructor: ->

    @cacheSize = gridview.size * 2
    [@grid, @slide] = modes = [new Grid, new Slide]
    for mode in modes
      mode.bind('progressed', this._ensurePictureCache)
      mode.bind('progress-changed', this._updateProgressInView)
    @currentMode = if __gridMode__? then @grid else @slide
    @advanceByProgress = __advance_by_progress__ #vs progress by paging
    view.nextClick => @currentMode.navigateToNext?()
    view.previousClick => @currentMode.navigateToPrevious?()
    @ratingFilterView = new RatingFilterView(@grid)
    @typeFilterView = new TypeFilterView(@grid)
    @ratingFilterView.filterChange this._applyRatingFilter
    @typeFilterView.filterChange this._applyTypeFilter

  init: =>
    @currentPage = 0
    @pictures = []
    this._retrieveMorePictures @currentMode.onFirstBatchOfPicturesLoaded
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

  isLoading: =>
    @retriever?

  _updateProgressInView: =>
    generalView.displayProgress(this.currentMode.atTheLast(), this.currentMode.atTheBegining())

  _alternativeView: =>
    if @currentMode is @grid then @slide else @grid

  _retrieveMorePictures: (somePicturesReady) =>
    unless this.isLoading()
      @retriever = new PictureRetriever(@currentPage, @cacheSize, this._filterOpts())
      @retriever.bind('batch-retrieved', this._addPictures)
      @retriever.bind('first-batch-retrieved', somePicturesReady) if somePicturesReady?
      @retriever.bind('done-retrieving', => @retriever = null)
      @retriever.retrieve()
      @currentPage += 1 unless @advanceByProgress

  _applyRatingFilter: (rating) =>
    @_ratingFilter = rating
    this._reinitToGrid()

  _applyTypeFilter: (type) =>
    @_typeFilter = type
    this._reinitToGrid()

  _reinitToGrid: =>
    @currentMode = @grid
    this.init()

  _filterOpts: =>
    excludeIds = (p.id for p in this._unseenPictures())
    _.tap {}, (opts) =>
      opts.exclude_ids = excludeIds
      opts.min_rating = @_ratingFilter if @_ratingFilter?
      opts.type = @_typeFilter if @_typeFilter?

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
        @retriever.bind('done-retrieving', this._ensurePictureCache)

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
  window.generalView = new GeneralView
  window.server = new Server
  window.gridview = new Gridview
  window.gallery = new Gallery
  new StreamPanel
  gallery.init()


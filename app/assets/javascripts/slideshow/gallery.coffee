class window.Gallery extends Events

  constructor: ->
    @cacheSize = this.pageSize() * 2
    [@grid, @slide] = modes = [new Grid, new Slide]
    for mode in modes
      mode.bind('progressed', this._ensurePictureCache)
      mode.bind('progress-changed', this._progressChanged)
    @currentMode = if __gridMode__? then @grid else @slide
    @advanceByProgress = __advance_by_progress__ #vs progress by paging
    @picturePreloader = new PicturePreloader(this)
    generalView.nextClick => @currentMode.navigateToNext?()
    generalView.previousClick => @currentMode.navigateToPrevious?()
    generalView.toggleModeClick this.toggleMode
    @ratingFilterView = new RatingFilterView(@grid)
    @typeFilterView = new TypeFilterView(@grid)
    @ratingFilterView.filterChange this._applyRatingFilter
    @typeFilterView.filterChange this._applyTypeFilter

  init: =>
    @picturePreloader.clear()
    @picturePreloader.start()
    @pageToRetrieve = 0
    @pictures = []
    this._retrieveMorePictures this._firstBatchRetrieved
    this._alternativeView().off()
    @currentMode.off()
    @grid.init(this)

  size: => @pictures.length

  isEmpty: => this.size() is 0

  currentPicture: => @pictures[this._currentProgress()]

  currentPage: => this.pageOf(this.currentPicture())

  pageOf: (picture) => Math.floor( picture.index / this.pageSize() )

  inGrid: => @currentMode is @grid

  toggleMode: =>
    progress = this._currentProgress()
    @currentMode.off()
    @currentMode = this._alternativeView()
    @currentMode.on()
    @currentMode.updateProgress(progress)
    this._updateModeIndicatorInView()
    @picturePreloader.rePrioritize()


  pageSize: => gridview.size

  isLoading: => @retriever?

  _progressChanged: =>
    this._updateProgressInView()
    @picturePreloader.rePrioritize()

  _updateProgressInView: =>
    generalView.displayProgress(this.currentMode.atTheLast(), this.currentMode.atTheBegining())

  _alternativeView: =>
    if @currentMode is @grid then @slide else @grid

  _retrieveMorePictures: (somePicturesReady) =>
    unless this.isLoading()
      @retriever = new PictureRetriever(@pageToRetrieve, @cacheSize, this._filterOpts())
      @retriever.bind('batch-retrieved', this._addPictures)
      @retriever.bind('first-batch-retrieved', somePicturesReady) if somePicturesReady?
      @retriever.bind('done-retrieving', this._onRetrieverFinished)
      @retriever.retrieve()
      @pageToRetrieve += 1 unless @advanceByProgress

  _firstBatchRetrieved: =>
    @currentMode.on()
    @currentMode.onFirstBatchOfPicturesLoaded?()
    this._updateProgressInView()
    this._updateModeIndicatorInView()

  _updateModeIndicatorInView: =>
    generalView.updateModeIndicator(this.inGrid())

  _onRetrieverFinished: =>
    @retriever = null
    if this.isEmpty()
      generalView.showEmptyGalleryMessage()

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
    startPosition = @pictures.length
    addedPictures = Picture.uniqConcat(@pictures, newPictures)
    for newPic in addedPictures
      newPic.index = startPosition++
    @picturePreloader.preload(addedPictures)
    this.trigger('new-pictures-added', addedPictures) if addedPictures.length > 0

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
    console.debug "current flickr page: " + @pageToRetrieve
    console.debug "gridview size: " + gridview.size
    console.debug "pictures size: " + @pictures.length
    console.debug "current progress: " + this._currentProgress()

$(document).ready ->
  window.keyShortcuts = new KeyShortcuts
  window.generalView = new GeneralView
  window.slideview = new Slideview
  window.gridview = new Gridview
  window.gallery = new Gallery
  new StreamPanel
  gallery.init()


class window.Gallery extends Events

  constructor: ->
    @cacheSize = 5
    [@grid, @slide] = @modes = [new Grid, new Slide]
    for mode in @modes
      mode.bind('progressed', this._ensurePictureCache)
      mode.bind('progress-changed', this._progressChanged)
    @currentMode = if __gridMode__? then @grid else @slide
    @advanceByProgress = __advance_by_progress__ #vs progress by paging
    @picturePreloader = new PicturePreloader(this)
    generalView.nextClick => @currentMode.navigateToNext?()
    generalView.previousClick => @currentMode.navigateToPrevious?()
    generalView.toggleModeClick this.toggleMode
    @ratingFilterView = new RatingFilterView(@grid)
    @ratingFilterView.filterChange this._applyRatingFilter
    new GalleryControlPanel(this)

    @retriever = this._createPictureRetriever()
    @retriever.bind('batch-retrieved', this._addPictures)
    @retriever.bind('done-retrieving', this._onRetrieverFinished)

  init: =>
    this._reset()
    @grid.init(this)

  size: => @pictures.length

  isEmpty: => this.size() is 0

  currentPicture: => @pictures[this._currentProgress()]

  currentPage: =>
    cp = this.currentPicture()
    if(cp?)
      this.pageOf(cp)
    else
      1

  pageOf: (picture) => Math.floor( picture.index / this.pageSize() )

  inGrid: => @currentMode is @grid

  toggleMode: =>
    progress = this._currentProgress()
    @currentMode.off()
    @currentMode = this._alternativeMode()
    @currentMode.on()
    @currentMode.updateProgress(progress)
    this._updateModeIndicatorInView()
    @picturePreloader.rePrioritize()

  pageSize: => gridview.size

  isLoading: => @retriever and @retriever.busy()

  _reset: =>
    this.trigger('pre-reset')
    @allPicturesRetrieved = false
    @waitingForPictures = true
    @retriever.reset()
    @picturePreloader.clear()
    @pictures = []
    this._alternativeMode().off()
    m.reset() for m in @modes
    @picturePreloader.start()
    this.retrieveMorePictures(@cacheSize)

  _progressChanged: =>
    this._updateProgressInView()
    @picturePreloader.rePrioritize()

  _updateProgressInView: =>
    generalView.displayProgress(this.currentMode.atTheLast() and !gallery.isLoading(),
                                this.currentMode.atTheBegining())

  _alternativeMode: =>
    if @currentMode is @grid then @slide else @grid

  retrieveMorePictures: (pages = 1)=> @retriever.retrieve(pages)

  _morePicturesReady: =>
    if @waitingForPictures
      this._firstBatchOfPicturesReady()
    else
      this.trigger('gallery-pictures-changed')

  _firstBatchOfPicturesReady: =>
    @waitingForPictures = false
    @currentMode.on()
    @currentMode.onFirstBatchOfPicturesLoaded?()
    this._updateProgressInView()
    this._updateModeIndicatorInView()

  _createPictureRetriever: =>
    if @advanceByProgress
      new PictureRetrieverByOffset( this._filterOpts, this.pageSize(), __morePicturesPath__)
    else
      new PictureRetrieverByPage( this._filterOpts, this.pageSize(), __morePicturesPath__)

  _updateModeIndicatorInView: =>
    generalView.updateModeIndicator(this.inGrid())

  _ensurePictureCache: =>
    needMoreForCache = @pictures.length - this._currentProgress() < (@cacheSize * this.pageSize())
    if needMoreForCache and !@allPicturesRetrieved
      this.retrieveMorePictures()

  _onRetrieverFinished: (numOfRetrieved)=>
    if this.isEmpty()
      this._emptyGallery()
    else if numOfRetrieved > 0
     this._ensurePictureCache()
    else if numOfRetrieved == 0
      @allPicturesRetrieved = true
      this.trigger('gallery-pictures-changed')

  _emptyGallery: =>
    @currentMode.clear?()
    if this._noActiveFilter()
        generalView.showEmptyGalleryMessage()

  _applyRatingFilter: (rating) =>
    @_ratingFilter = rating
    this._reinitToGrid()

  applyTypeFilter: (type) =>
    @_typeFilter = type
    this._reinitToGrid()

  _noActiveFilter: =>
    !@_typeFilter? and !@_ratingFilter

  _reinitToGrid: =>
    @currentMode = @grid
    this._reset()

  _filterOpts: =>
    _.tap {}, (opts) =>
      opts.offset = this._unseenPictures().length if @advanceByProgress
      opts.min_rating = @_ratingFilter if @_ratingFilter?
      opts.type = @_typeFilter if @_typeFilter?

  _addPictures: (newPictures) =>
    startPosition = @pictures.length
    addedPictures = Picture.uniqConcat(@pictures, newPictures)
    if addedPictures.length > 0
      for newPic in addedPictures       #todo remove this hacky workaround
        newPic.index = startPosition++
      @picturePreloader.preload(addedPictures)
      this.trigger('new-pictures-added', addedPictures)
      this._morePicturesReady()

  _unseenPictures: =>
    p for p in gallery.pictures when !p.data.viewed

  _currentProgress: =>
    @currentMode.currentProgress()

  report: ->
    readyPictures = _(@pictures).select (p) -> p.ready
    console.debug "cache size: " + @cacheSize
    console.debug "pictures in cache: " + @pictures.length
    console.debug "pictures preloaded: " + readyPictures.length
    console.debug "current flickr page: " + @pageToRetrieve
    console.debug "page size: " + gridview.size
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


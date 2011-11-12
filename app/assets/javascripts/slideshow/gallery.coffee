class window.Gallery extends Events
  constructor: ->
    @cacheSize = 5
    [@grid, @slide] = @modes = [new Grid, new Slide]
    for mode in @modes
      mode.bind('progressed', this._ensurePictureCache)
      mode.bind('progress-changed', this._progressChanged)
    @currentMode = if __gridMode__? then @grid else @slide
    this._updateModeIndicatorInView()
    @advanceByProgress = __advance_by_progress__ #vs progress by paging
    @picturePreloader = new PicturePreloader(this)
    generalView.nextClick => @currentMode.navigateToNext?()
    generalView.previousClick => @currentMode.navigateToPrevious?()
    generalView.toggleModeClick this.toggleMode
    @filters = new GalleryFilters
    generalView.updateShareLink(@filters.filterSettings())
    @filters.bind('changed', this._reinitToGrid)
    @filters.bind('changed', generalView.updateShareLink)


    new GalleryControlPanel(this)


    this._listenHashChange()

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
    this._alternativeMode().goToIndex(this._currentProgress())

  pageSize: => gridview.size

  isLoading: => @retriever and @retriever.busy()

  retrieveMorePictures: (pages = 1)=> @retriever.retrieve(pages)

  _reset: =>
    @retriever = this._createPictureRetriever()
    @retriever.bind('batch-retrieved', this._addPictures)
    @retriever.bind('done-retrieving', this._onRetrieverFinished)

    this.trigger('pre-reset')
    window.location.hash = ''

    @allPicturesRetrieved = false
    @blank = true
    @retriever.reset()
    @picturePreloader.clear()
    @pictures = []
    this._alternativeMode().off()
    m.reset() for m in @modes
    @picturePreloader.start()
    this.retrieveMorePictures(@cacheSize)

  _listenHashChange: =>
    $(window).bind 'hashchange', (e) =>
      hash = $.param.fragment()
      return unless hash.length > 0
      [mode, index] = hash.split('-')
      index = Math.min(parseInt(index), this.size() - 1)
      newMode = this[mode]
      modeChanged = newMode isnt @currentMode
      if(modeChanged)
        @currentMode.off()
        @currentMode = newMode
        @currentMode.on()
        this._updateModeIndicatorInView()
      if(index != this._currentProgress() or @blank or modeChanged )
        @blank = false
        @currentMode.updateProgress(index)

  _progressChanged: =>
    this._updateProgressInView()
    @picturePreloader.rePrioritize()

  _updateProgressInView: =>
    generalView.displayProgress(this.currentMode.atTheLast() and !gallery.isLoading(),
                                this.currentMode.atTheBegining())

  _alternativeMode: =>
    if @currentMode is @grid then @slide else @grid

  _morePicturesReady: =>
    if @blank
      this._firstBatchOfPicturesReady()
    else
      this.trigger('gallery-pictures-changed')

  _firstBatchOfPicturesReady: =>
    @currentMode.on()
    @currentMode.goToIndex(0)


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
    this.trigger('idle')

  _emptyGallery: =>
    @currentMode.clear?()
    if this._noActiveFilter()
        generalView.showEmptyGalleryMessage()

  _noActiveFilter: =>
    filterSettings = @filters.filterSettings()
    _(filterSettings).size() is 0

  _reinitToGrid: =>
    @currentMode = @grid
    this._reset()

  _filterOpts: =>
    filterSettings = @filters.filterSettings()
    _.tap {}, (opts) =>
      opts.offset = this._unseenPictures().length if @advanceByProgress
      opts.min_rating = filterSettings.rating if filterSettings.rating
      opts.faved_date = filterSettings.faveDate if filterSettings.faveDate
      opts.faved_date_after = filterSettings.faveDateAfter if filterSettings.faveDateAfter
      opts.type = filterSettings.type if filterSettings.type

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

  readyPictures: =>
    _(@pictures).select (p) -> p.ready

  readyNewPictures: =>
    _(@pictures).select (p) -> p.ready and !p.data.viewed

  report: ->
    console.debug "cache size: " + @cacheSize
    console.debug "pictures in cache: " + @pictures.length
    console.debug "pictures preloaded: " + this.readyPictures().length
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
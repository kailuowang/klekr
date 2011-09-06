class window.PictureRetriever extends Events
  constructor: (@pageNumber, @pageSize, @filterOpts) ->
    @_numOfSubBatches = 2
    @morePicturesPath = __morePicturesPath__

  retrieve: =>
    this._retrieveBatch 1, (retrievedInFirst) =>
      if retrievedInFirst.length > 0
        this.trigger('first-batch-retrieved')
        this._retrieveBatch 2, (retrievedInSecond) =>
          this._preload(retrievedInFirst, retrievedInSecond)
          this.trigger('done-retrieving')
      else
        this.trigger('done-retrieving')

  _retrieveBatch: (batchNum, success) =>
    opts = this._batchOpts( @_numOfSubBatches * @pageNumber + batchNum )
    server.post @morePicturesPath, opts, (data) =>
      pictures = ( new Picture(picData) for picData in data )
      if pictures.length > 0
        this.trigger('batch-retrieved', pictures)
      success?(pictures)

  _batchOpts: (page)=>
    batchSize = @pageSize / @_numOfSubBatches
    $.extend({ num: batchSize , page: page }, @filterOpts)

  _preload: (pictureGroups...) =>
    veryFirst = pictureGroups[0][0]
    pictureGroups.unshift([veryFirst])
    batches = (new _PictureBatchRetreiver(group) for group in pictureGroups)
    this._preloadInBatches(batches)

  _preloadInBatches: (batches) =>
    batch = batches.shift()
    if batches.length > 0
      batch.bind('done', => this._preloadInBatches(batches))
    batch.preload()


class window._PictureBatchRetreiver extends Events
  constructor: (@pictures) ->
    for picture in @pictures
      picture.bind('small-version-ready', this._picSmallVersionLoaded)
      picture.bind('fully-ready', this._picFullyLoaded)

  preload: =>
    picture.preloadSmall() for picture in @pictures

  _picSmallVersionLoaded: =>
    @smallVersionDone ?= 0
    @smallVersionDone++
    if @smallVersionDone is @pictures.length
      picture.preloadLarge() for picture in @pictures

  _picFullyLoaded: =>
    @fullyDone ?= 0
    @fullyDone++
    if @fullyDone is @pictures.length
      this.trigger('done')




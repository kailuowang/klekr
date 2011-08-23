class window.PictureRetriever extends Events
  constructor: (@pageNumber, @pageSize, @filterOpts) ->

  retrieve: =>
    this._retrieveBatch 1, (retrieved) =>
      this.trigger('first-batch-retrieved')
      if retrieved.length > 0
        this._retrieveBatch 2, (retrievedInSecond) =>
          this._preload(retrieved.concat(retrievedInSecond))
          this.trigger('done-retrieving')
      else
        this.trigger('done-retrieving')

  _retrieveBatch: (batchNum, success) =>
    opts = this._batchOpts( 2 * @pageNumber + batchNum )
    server.morePictures opts, (data) =>
      pictures = ( new Picture(picData) for picData in data )
      this.trigger('batch-retrieved', pictures)
      success?(pictures)

  _batchOpts: (page)=>
    $.extend({ num: (@pageSize / 2) , page: page }, @filterOpts)

  _preload: (pictures) =>
    splitAt = @pageSize / 2
    batches =
      for pics in [[pictures[0]], pictures[0...splitAt], pictures[splitAt...@pageSize]]
        new _PictureBatchRetreiver(pics)
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




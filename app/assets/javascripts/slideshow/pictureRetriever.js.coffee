class window.PictureRetriever extends Events
  constructor: (@pageNumber, @pageSize, @filterOpts) ->

  retrieve: =>
    opts =  $.extend({ num: @pageSize, page: @pageNumber }, @filterOpts)
    server.morePictures opts, (data) =>
      pictures = ( new Picture(picData) for picData in data )
      this.trigger('retrieved', pictures)
      this._preload(pictures) if (pictures.length > 0)

  onRetrieve: (callback) => this.bind('retrieved', callback)

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




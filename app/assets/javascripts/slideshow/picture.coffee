class window.Picture extends Events

  constructor: (@data) ->
    @id = @data.id
    _.defaults(this, @data)
    @width = 640
    @sizeReady = false or @data.noLongerValid
    @canUseLargeVersion = false
    @largeVersionAvailable = true
    @canUseMediumVersion = false
    @ready = false
    @error = false
    @index = null

  url: =>
    if @canUseLargeVersion
      @data.largeUrl
    else if @canUseMediumVersion
      @data.mediumUrl
    else
      @data.mediumSmallUrl


  smallUrl: => @data.smallUrl

  favable: =>
    @data.ofCurrentCollector

  fave: (rating) =>
    @data.rating = rating
    klekr.Global.updater.put @data.favePath, {rating: rating}
    this.favedDate = $.format.date new Date(), 'MMMM d, yyyyy'
    this._broadCastChange()
    this.trigger('faved')

  unfave:  =>
    @data.rating = 0
    klekr.Global.updater.put @data.unfavePath
    this._broadCastChange()
    this.trigger('unfaved')

  getViewed: =>
    if this._viewedMarkable()
      klekr.Global.updater.put(@data.getViewedPath)
      this._setAsViewed()

  _setAsViewed: =>
    @data.viewed = true
    this.trigger('viewed')

  _viewedMarkable: =>
    !@data.viewed and this._inKlekr() and @data.ofCurrentCollector

  faved: => @data.rating > 0

  preload: =>
    this.preloadSmall this.preloadFull

  preloadSmall: (callback)=>
    this._preloadImage @data.smallUrl, (image) =>
      [@smallWidth, @smallHeight] = [image.width, image.height]
      this._updateData() if @error or this._smallVersionMightBeInvalid(image)
      this.calculateFitVersion() unless @error
      this.trigger('size-ready')
      callback?()

  reloadForCurrentCollector: =>
    this._updateData(skip_flickr_resync: true)

  calculateFitVersion: =>
    [largeWidth, largeHeight] = this.guessLargeSize()
    [mediumWidth, mediumHeight] = this.guessMediumSize()
    @canUseLargeVersion = @largeVersionAvailable and this._isSizeFit(largeWidth, largeHeight)
    @canUseMediumVersion = this._isSizeFit(mediumWidth, mediumHeight)
    @sizeReady = true

  _isSizeFit: (width, height) =>
    captionHeight = 20
    width < generalView.displayWidth and height < generalView.displayHeight - captionHeight

  _updateData: (opts = {}) =>
    if this._updatable()
      @alreadyUpdated = true
      klekr.Global.server.put resync_picture_path(id: @id), opts, (newData) =>
        if newData?
          @data = newData
          this.preloadSmall this._broadCastChange

  _broadCastChange: =>
    this.trigger('data-updated')

  _smallVersionMightBeInvalid: (image) =>
    image.width is 240 and image.height is 180

  _updatable: =>
    klekr.Global.currentCollector? and !@alreadyUpdated and this._inKlekr()

  _inKlekr: =>
    @data.getViewedPath?

  preloadFull: (callback)=>
    unless @error
      this._preloadImage this.url(), (image)=>
        this._updateSize(image) unless this.checkLargeVersionInvalid(image)
        callback?()
    else
      callback?()

  _preloadImage: (url, onload) =>
    image = new Image()
    image.src = url
    $(image).load =>
      @error = false
      onload(image) if onload?
    $(image).error =>
      @error = true
      onload(image) if onload?

  _updateSize: (image) =>
    @width = image.width
    @ready = true
    this.trigger('fully-ready')

  checkLargeVersionInvalid: (image) =>
    if image.src is this.data.largeUrl
      if(image.width < 650 and image.height < 650)
        @canUseLargeVersion = false
        @largeVersionAvailable = false
        this._preloadImage @data.mediumUrl, this._updateSize
        this.trigger('data-updated')
        true

  guessLargeSize: =>
    this._guessVersionSize(1024)

  guessMediumSize: =>
    this._guessVersionSize(640)

  _guessVersionSize: (versionLongEdge) =>
    longEdge = Math.max(@smallWidth, @smallHeight)
    ratio = versionLongEdge / longEdge
    [@smallWidth * ratio, @smallHeight * ratio]

  trigger: (event) =>
    super(event, this)
    klekr.Global.broadcaster.trigger('picture:' + event, this)


class klekr.PictureUtil

  uniqConcat: (original, newOnes) =>
    h = {}
    h[p.id] = 1 for p in original
    added = []
    for newP in newOnes when not h[newP.id]?
      original.push newP
      added.push newP
    added

  allGetViewed: (pictures) =>
    toMarkPictures = _(pictures).select (pic) -> pic._viewedMarkable()
    pic._setAsViewed() for pic in toMarkPictures

    if toMarkPictures.length > 0
      picIds = ( pic.id for pic in toMarkPictures )
      klekr.Global.updater.post(all_viewed_pictures_path(), {ids: picIds})

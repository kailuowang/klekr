class window.PictureRetriever extends Events

  constructor: (@_filterOptsFn, @pageSize, @_retrievePath) ->
    @_retrievedCount = 0
    @_currentPage = 0
    @_q = new queffee.Q
    @_worker = new queffee.Worker(@_q)
    @_worker.start()
    @_worker.onIdle = this._onWorkerDone
    klekr.Global.server.bind('connection-status-changed', this._retry)

  reset: =>
    @_q.clear()
    @_currentPage = 0

  busy: => !@_worker.idle()

  retrieve: (numOfPages = 3) =>
    for work in this._createWorks(numOfPages)
      @_q.enQ(work)

  retrievePic: (picId) =>
    @_q.enQ (callback) =>
      klekr.Global.server.get picture_path(id: picId), {}, (data) =>
        this._onPicturesRetrieved [new Picture(data)]
        callback()

  _createWorks: (numOfPages) =>
    for i in [0...numOfPages]
      this._proceed()
      this._createWork()

  _createWork: =>
    pageOpts = this._pageOpts()
    (callback) => this._retrievePage(pageOpts, callback)

  _onWorkerDone: =>
    this.trigger('done-retrieving', @_retrievedCount)
    @_retrievedCount = 0

  _retrieveOpts: (pageOpts) =>
    $.extend(pageOpts, @_filterOptsFn())

  _proceed: =>
    @_currentPage++

  _retry: =>
    @_worker.retry() if klekr.Global.server.onLine()

  _retrievePage: (pageOpts, callback) =>
    klekr.Global.server.get @_retrievePath, this._retrieveOpts(pageOpts), (data) =>
      pictures = ( new Picture(picData) for picData in data ) if data?
      if pictures? and pictures.length > 0
        this._onPicturesRetrieved(pictures)
      else
        @_q.clear()
        this._onWorkerDone()
      callback()

  _onPicturesRetrieved: (pictures)=>
    this.trigger('batch-retrieved', pictures)
    @_retrievedCount += pictures.length
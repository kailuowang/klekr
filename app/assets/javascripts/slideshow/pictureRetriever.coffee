class window.PictureRetriever extends Events

  constructor: (@_filterOptsFn, @pageSize, @_retrievePath) ->
    @_retrievedCount = 0
    @_currentPage = 0
    @_q = new queffee.Q
    @_worker = new queffee.Worker(@_q)
    @_worker.start()
    @_worker.onIdle = this._onWorkerDone

  reset: =>
    @_q.clear()
    @_currentPage = 0

  busy: => !@_worker.idle()

  retrieve: (numOfPages = 3) =>
    @_q.enqueue(this._createJobs(numOfPages)...)

  _createJobs: (numOfPages) =>
    for i in [0...numOfPages]
      this._proceed()
      this._createJob()

  _createJob: =>
    pageOpts = this._pageOpts()
    perform = (callback) => this._retrievePage(pageOpts, callback)
    priority = -@_currentPage
    new queffee.Job(perform, priority, 30000)

  _onWorkerDone: =>
    this.trigger('done-retrieving', @_retrievedCount)
    @_retrievedCount = 0

  _retrieveOpts: (pageOpts) =>
    $.extend(pageOpts, @_filterOptsFn())

  _retrievePage: (pageOpts, callback) =>
    server.post @_retrievePath, this._retrieveOpts(pageOpts), (data) =>
      pictures = ( new Picture(picData) for picData in data )
      if pictures.length > 0
        this.trigger('batch-retrieved', pictures)
        @_retrievedCount += pictures.length
      else
        @_q.clear()
        this._onWorkerDone()
      callback()
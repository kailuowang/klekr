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

  retrieve: (numOfPages = 1) =>
    for work in this._createWorks(numOfPages)
      @_q.enQ(work)

  retrievePic: (picId) =>
    @_q.enQ (callback) =>
      klekr.Global.server.get picture_path(id: picId), {}, (data) =>
        this._onPicturesRetrieved [new Picture(data)]
        callback()

  _createWorks: (numOfPages) =>
    console.log("Creating retrieval work for #{numOfPages} pages, current page: #{@_currentPage}")
    works = for i in [0...numOfPages]
      this._proceed()
      this._createWork()
    console.log("Created #{works.length} work items for pages #{@_currentPage-numOfPages+1} to #{@_currentPage}")
    works

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
    retrieveOpts = this._retrieveOpts(pageOpts)
    console.log("Retrieving page #{pageOpts.page} with options:", retrieveOpts)
    
    klekr.Global.server.get @_retrievePath, retrieveOpts, (data) =>
      pictures = ( new Picture(picData) for picData in data ) if data?
      if pictures? and pictures.length > 0
        console.log("Retrieved #{pictures.length} pictures from page #{pageOpts.page}")
        this._onPicturesRetrieved(pictures)
      else
        console.log("No pictures found on page #{pageOpts.page}, stopping retrieval")
        @_q.clear()
        this._onWorkerDone()
      callback()

  _onPicturesRetrieved: (pictures)=>
    this.trigger('batch-retrieved', pictures)
    @_retrievedCount += pictures.length
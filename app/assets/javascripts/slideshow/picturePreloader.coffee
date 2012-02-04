class window.PicturePreloader
  @numOfWorkers: 3

  constructor: (@gallery)->
    @q = new queffee.Q
    klekr.Global.server.bind('connection-status-changed', this._retry)

  start: =>
    unless @workers?
      @workers = this._createWorkers()
      worker.start() for worker in @workers

  clear: =>
    @q.clear()

  rePrioritize: => @q.reorder()

  preload: (pictures) =>
    jobs = _(this._createJobs(pic) for pic in pictures when !pic.noLongerValid).flatten()
    @q.enqueue(jobs...)

  _createWorkers: =>
    new queffee.Worker(@q) for i in [0...PicturePreloader.numOfWorkers]

  _createJobs: (picture) =>
    priority = new PicturePreloadPriority(picture, @gallery)
    [ this._createJob(picture, 'Small', priority), this._createJob(picture, 'Full', priority)]

  _createJob: (picture, size, priority) =>
    priorityFn =  priority[size.toLowerCase()]
    preloadFn = (callback) => picture['preload' + size](callback)
    new queffee.Job( preloadFn, priorityFn, this._timeout)

  _timeout: =>
    if klekr.Global.server.onLine() then 30000 else null

  _retry: =>
    if @workers?
      worker.retry() for worker in @workers
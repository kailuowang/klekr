class window.PicturePreloader
  @timeout: 10000
  @numOfWorkers: 3

  constructor: (@gallery)->
    @q = new queffee.Q

  start: =>
    unless @workers?
      @workers = this._createWorkers()
      worker.start() for worker in @workers

  clear: =>
    @q.clear()

  rePrioritize: => @q.reorder()

  preload: (pictures) =>
    jobs = _(this._createJobs(pic) for pic in pictures).flatten()
    @q.enqueue(jobs...)

  _createWorkers: =>
    new queffee.Worker(@q) for i in [0...PicturePreloader.numOfWorkers]

  _createJobs: (picture) =>
    priority = new PicturePreloadPriority(picture, @gallery)
    [ this._createJob(picture, 'Small', priority), this._createJob(picture, 'Large', priority)]

  _createJob: (picture, size, priority) =>
    priorityFn =  priority[size.toLowerCase()]
    preloadFn = (callback) => picture['preload' + size](callback)
    new queffee.Job( preloadFn, priorityFn, PicturePreloader.timeout)

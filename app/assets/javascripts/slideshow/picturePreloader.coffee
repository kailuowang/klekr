class window.PicturePreloader
  @timeout: 10000

  constructor: (@gallery)->
    @q = new queffee.Q

  start: =>
    unless @worker?
      @worker = new queffee.Worker(@q)
      @worker.start()

  clear: => @q.clear()

  rePrioritize: => @q.reorder()

  preload: (pictures) =>
    jobs = _(this._createJobs(pic) for pic in pictures).flatten()
    @q.enqueue(jobs...)

  _createJobs: (picture) =>
    priority = new PicturePreloadPriority(picture, @gallery)
    [ this._createJob(picture, 'Small', priority), this._createJob(picture, 'Large', priority)]


  _createJob: (picture, size, priority) =>
    priorityFn =  priority[size.toLowerCase()]
    preloadFn = (callback) =>
      console.debug("preloading #{size} # #{picture.index} priority: #{priorityFn()}"  )
      picture['preload' + size](callback)

    new queffee.Job( preloadFn, priorityFn, PicturePreloader.timeout)


  _log: (picture, size) =>


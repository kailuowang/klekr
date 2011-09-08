class window.PicturePreloader
  constructor: (@gallery)->
    @q = new quefee.Q

  start: =>
    unless @worker?
      @worker = new quefee.Worker(@q)
      @worker.start()

  clear: => @q.clear()

  rePrioritize: => @q.reorder()

  preload: (pictures) =>
    jobs = _(this._createJobs(pic) for pic in pictures).flatten()
    @q.enqueue(jobs...)

  _createJobs: (picture) =>
    priority = new PicturePreloadPriority(picture, @gallery)
    [ new quefee.Job(picture.preloadSmall, priority.small),
      new quefee.Job(picture.preloadLarge, priority.large)]



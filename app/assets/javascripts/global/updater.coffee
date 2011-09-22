class Updater
  constructor: ->
    @_q = new queffee.Q
    @_worker = new queffee.Worker(@_q)
    @_server = klekr.Global.server

  put: (url, data) => this._addJob('put', url, data)

  post: (url, data) => this._addJob('post', url, data)

  _addJob: (method, url, data) =>
    @_q.enQ (callback) =>
      @_server.ajax(url, data, method, callback)

namespace 'klekr.Global', (n) ->
  n.updater = new Updater
class Updater
  constructor: ->
    @_q = new queffee.Q
    @_worker = new queffee.Worker(@_q)
    @_server = klekr.Global.server
    @_server.bind 'connection-status-changed', this._connectionStatusChanged

  put: (url, data) => this._addJob('put', url, data)

  post: (url, data) => this._addJob('post', url, data)

  _addJob: (method, url, data) =>
    @_q.enQ (callback) =>
      @_server.ajax(url, data, method, callback)

  _connectionStatusChanged: =>
    if @_server.onLine()
      @_worker.retry()

namespace 'klekr.Global', (n) ->
  n.updater = new Updater
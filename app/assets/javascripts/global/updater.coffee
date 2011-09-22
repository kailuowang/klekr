class Updater
  constructor: ->
    @_q = new queffee.Q
    @_worker = new queffee.Worker(@_q)
    @_server = klekr.Global.server
    @_server.bind 'connection-status-changed', this._retry
    setTimeout this._checkConnection, 180000

  put: (url, data) => this._addJob('put', url, data)

  post: (url, data) => this._addJob('post', url, data)

  _addJob: (method, url, data) =>
    @_q.enQ (callback) =>
      @_server.ajax(url, data, method, callback)

  _retry: => @_worker.retry() if @_server.onLine()

  _checkConnection: => @_server.get(health_path()) unless @_server.onLine()


namespace 'klekr.Global', (n) ->
  n.updater = new Updater
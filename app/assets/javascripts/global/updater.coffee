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
      this._stopCheckConnection()
      @_worker.retry()
    else
      this._startCheckConnection()

  _checkConnection: => @_server.get(health_path()) unless @_server.onLine()

  _startCheckConnection: =>
    @_connectionCheckingPId ?= setInterval(this._checkConnection, 5000)

  _stopCheckConnection: =>
    if @_connectionCheckingPId?
      clearInterval(@_connectionCheckingPId)
      @_connectionCheckingPId = null

namespace 'klekr.Global', (n) ->
  n.updater = new Updater
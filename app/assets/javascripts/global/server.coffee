class Server extends Events
  constructor: ->
    @_offLine = false

  get: (url, data, callback) ->
    this.ajax(url, data, 'GET', callback)

  post: (url, data, callback) ->
    this.ajax(url, data, 'POST', callback)

  put: (url, data, callback) ->
    this.ajax(url, data, 'PUT', callback)

  ajax: (url, data, type, callback) ->
    $.ajax(
            url: url + '.js'
            dataType: 'json'
            data: data
            type: type
            success: (data) =>
              this._setOffLine false
              callback(data) if callback?
            error: (XMLHttpRequest, textStatus, errorThrown) =>
              this._setOffLine true
    )

  onLine: => !@_offLine

  _setOffLine: (value) =>
    if @_offLine isnt value
      @_offLine = value
      this.trigger('connection-status-changed')
      if @_offLine then this._startCheckConnection() else this._stopCheckConnection()

  _checkConnection: => this.get(health_path()) unless this.onLine()

  _startCheckConnection: =>
    @_connectionCheckingPId ?= setInterval(this._checkConnection, 5000)

  _stopCheckConnection: =>
    if @_connectionCheckingPId?
      clearInterval(@_connectionCheckingPId)
      @_connectionCheckingPId = null


namespace 'klekr.Global', (n) ->
  n.server = new Server
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
      url: this._jsUrl(url)
      dataType: 'json'
      data: data
      type: type
      success: (data) =>
        this._setOffLine false
        callback(data) if callback?
      error: (xhr, textStatus, errorThrown) =>
        this._handleError(xhr.responseText, callback)
    )

  onLine: => !@_offLine

  _handleError: (response, callback) =>
    if(response is '' or response.search(/under maintenance/i) > -1 )
      this._setOffLine true
    else if response.search(/Welcome to/i) > -1
      this._setOffLine false
      window.location.href = authentications_path()
    else
      callback?()

  _setOffLine: (value) =>
    if @_offLine isnt value
      @_offLine = value
      this.trigger('connection-status-changed', this.onLine())
      if @_offLine then this._startCheckConnection() else this._stopCheckConnection()

  _checkConnection: => this.get(health_path()) unless this.onLine()

  _startCheckConnection: =>
    @_connectionCheckingPId ?= setInterval(this._checkConnection, 10000)

  _stopCheckConnection: =>
    if @_connectionCheckingPId?
      clearInterval(@_connectionCheckingPId)
      @_connectionCheckingPId = null

  _jsUrl: (url) ->
    if url.indexOf('?') >= 0
      url.replace('?', '.json?')
    else
      url + '.json'


namespace 'klekr.Global', (n) ->
  n.server = new Server
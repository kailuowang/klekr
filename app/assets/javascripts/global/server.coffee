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
              this._setOffLine true if(textStatus == 'timeout')
    )

  onLine: => !@_offLine

  _setOffLine: (value) =>
    if @_offLine isnt value
      @_offLine = value
      this.trigger('connection-status-changed')

namespace 'klekr.Global', (n) ->
  n.server = new Server
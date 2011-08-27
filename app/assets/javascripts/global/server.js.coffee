class Server
  get: (url, data, callback) ->
    this.ajax(url, data, 'GET', callback)

  post: (url, data, callback) ->
    this.ajax(url, data, 'POST', callback)

  put: (url, data, callback) ->
    this.ajax(url, data, 'PUT', callback)

  ajax: (url, data, type, callback) ->
    $.ajax(
            url: url,
            dataType: 'json',
            data: data,
            type: type
            success: (data) ->
              callback(data) if callback?
    )

this.server = new Server
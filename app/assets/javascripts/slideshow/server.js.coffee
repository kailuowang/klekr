class window.Server
  constructor: ->
    @morePicturesPath = __morePicturesPath__

  morePictures: (opts, callback) ->
    this.post( @morePicturesPath, opts, callback )

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
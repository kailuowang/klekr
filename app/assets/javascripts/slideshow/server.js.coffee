class window.Server
  constructor: ->
    @firstPicturePath = __firstPicturePath__
    @newPicturesPath = __newPicturesPath__

  firstPicture: (callback) ->
    this.get(@firstPicturePath, null, callback)

  newPictures: (num, excludeIds, callback) ->
    this.post( @newPicturesPath,
              { num: num, exclude_ids: excludeIds},
              callback )

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
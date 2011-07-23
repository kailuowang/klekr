class window.Server
  constructor: ->
    @currentPicturePath = '/slideshow/current'
    @newPicturesPath = '/slideshow/new_pictures'


  currentPicture: (callback) ->
    this.get(@currentPicturePath, null, callback)

  newPictures: (num, excludeIds, callback) ->
    this.post( @newPicturesPath,
              { num: num, exclude_ids: excludeIds},
              callback )

  get: (url, data, callback) ->
    this.ajax(url, data, 'GET', callback)

  post: (url, data, callback) ->
    this.ajax(url, data, 'POST', callback)

  ajax: (url, data, type, callback) ->
    $.ajax(
            url: url,
            dataType: 'json',
            data: data,
            type: type
            success: (data) -> callback(data) if callback?
    )
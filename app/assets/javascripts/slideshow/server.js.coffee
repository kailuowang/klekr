class window.Server
  constructor: ->
    @currentPicturePath = '/slideshow/current'

  get: (url, callback) ->
    $.ajax(
            url: url,
            dataType: 'json',
            success: (data) -> callback(data)
    )

  currentPicture: (callback) ->
    this.get(@currentPicturePath, callback)
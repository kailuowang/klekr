class window.Server
  constructor: ->
    @currentPicturePath = '/pictures/current'

  get: (url, callback) ->
    $.ajax(
            url: url,
            dataType: 'json',
            success: (data) -> callback(data)
    )

  currentPicture: (callback) ->
    this.get(@currentPicturePath, callback)
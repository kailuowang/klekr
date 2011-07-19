class window.Picture
  constructor: (data) ->
    @largeUrl = data.large_url
    @nextPicturePath = data.next_picture_path

  url: -> @data.large_url

  retrieveNext: (onNextReady)->
    unless @next
      $.ajax( url: @nextPicturePath,
              success: (data) =>
                @next = new Picture(data)
                onNextReady?(@next)
      )
    else
      onNextReady?(@next)



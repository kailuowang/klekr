class window.Picture
  constructor: (data) ->
    @largeUrl = data.large_url
    @nextPicturePath = data.next_picture_path

  url: -> @largeUrl

  retrieveNext: (onNextReady) ->
    unless @next
      server.get( @nextPicturePath,
                  (data) =>
                    @next = new Picture(data)
                    onNextReady?(@next)
      )
    else
      onNextReady?(@next)



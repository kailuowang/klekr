class window.Slideshow

  constructor:  (@view, currentPictureUrl) ->
    getCurrentPicture(currentPictureUrl)
    @view.nextClicked(navigateToNext)

  getCurrentPicture: (currentPictureUrl) ->
    $.ajax( url: currentPictureUrl
            success: (data) =>
              @currentPicture = new Picture(data)
              displayCurrentPicture()
    )

  displayCurrentPicture: ->
    @view.display(@currentPicture) if @currentPicture?

  navigateToNext: ->
    if @currentPicture?
      @currentPicture.retrieveNext( (next) =>
        @currentPicture = next
        displayCurrentPicture()
      )



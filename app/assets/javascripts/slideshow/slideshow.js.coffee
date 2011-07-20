class window.Slideshow

  getCurrentPicture: ->
    @server.currentPicture((data) =>
      @currentPicture = new Picture(data)
      this.displayCurrentPicture()
    )

  constructor:  (@view, @server) ->
    this.getCurrentPicture()
    @view.nextClicked(this.navigateToNext)


  displayCurrentPicture: ->
    @view.display(@currentPicture) if @currentPicture?

  navigateToNext: ->
    if @currentPicture?
      @currentPicture.retrieveNext( (next) =>
        @currentPicture = next
        displayCurrentPicture()
      )

$(document).ready ->
  new Slideshow(new View, new Server)

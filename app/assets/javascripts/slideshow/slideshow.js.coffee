class window.Slideshow

  getCurrentPicture: ->
    server.currentPicture((data) =>
      @currentPicture = new Picture(data)
      this.displayCurrentPicture()
    )

  constructor: ->
    this.getCurrentPicture()
    view.nextClicked(this.navigateToNext)

  displayCurrentPicture: ->
    view.display(@currentPicture) if @currentPicture?

  navigateToNext: ->
    if @currentPicture?
      @currentPicture.retrieveNext( (next) =>
        @currentPicture = next
        displayCurrentPicture()
      )

$(document).ready ->
  window.view = new View
  window.server = new Server
  window.slideshow = new Slideshow

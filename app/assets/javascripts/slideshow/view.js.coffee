class window.View

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @interestingness = $('#interestingness')
    @titleLink = $('#title')
    @ownerLink = $('#owner')
    @fromStreamsDiv = $('#fromStreams')
    @faveLink = $('#faveLink')
    @faved = $('#faved')
    @faveWaiting = $('#faveWaiting')

  display: (picture) ->
    @pictureArea.fadeOut(100, =>
      this.updateDOM(picture)
    )
    @pictureArea.fadeIn(100)

  updateDOM: (picture) ->
    @mainImg.attr('src', picture.url())
    @interestingness.text(picture.data.interestingness)
    @titleLink.attr('href', picture.data.flickrPageUrl)
    @titleLink.text( this.pictureTitle(picture))
    @ownerLink.attr('href', picture.data.ownerPath)
    @ownerLink.text(picture.data.ownerName)
    this.updateFromStreams(picture.data.fromStreams)
    this.updateFavedStatus(picture)

  updateFavedStatus: (picture) ->
    @faveWaiting.hide()
    if picture.data.faved
      @faveLink.hide()
      @faved.show()
    else
      @faved.hide()
      @faveLink.show()

  gotoOwner: () ->
    window.location = @ownerLink.attr('href')

  changingFavedStatus: ->
    @faveWaiting.show()
    @faveLink.hide()

  updateFromStreams: (streams) ->
    @fromStreamsDiv.html('')
    for stream in streams
      link = $('<a>').attr('href', stream.path).text(stream.username + "'s " + stream.type)
      @fromStreamsDiv.append(link)
      @fromStreamsDiv.append($('<span>').text(' | '))

  pictureTitle: (picture) ->
    t = picture.data.title
    if t? and t isnt '-' and t isnt '.' and t isnt ''
      picture.data.title
    else
      'untitled'


  nextClicked: (listener) ->
    $('#right').click(listener)

  faveClicked: (listener) ->
    @faveLink.click(listener)

  previousClicked: (listener) ->
    $('#left').click(listener)

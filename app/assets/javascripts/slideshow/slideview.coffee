class window.Slideview extends ViewBase

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @slide = $('#slide')
    @interestingness = $('#interestingness')
    @titleLink = $('#title')
    @ownerLink = $('#owner')
    @fromStreamsDiv = $('#fromStreams')
    @fromTitle = $('#fromTitle')
    @imageCaption = $('#imageCaption')
    @bottomLeft = $('#bottomLeft')
    @bottomRight = $('#bottomRight')
    this._adjustImageFrame()

  display: (picture) ->
    if this.showing(@pictureArea)
      this.fadeInOut @pictureArea, false, =>
        this._fadeInto(picture)
    else
      this._fadeInto(picture)

  _fadeInto: (picture) =>
    this.updateDOM(picture)
    this.fadeInOut(@pictureArea, true)

  updateDOM: (picture) ->
    @interestingness.text(picture.data.interestingness)
    @mainImg.attr('src', picture.url())
    @titleLink.attr('href', picture.data.flickrPageUrl)
    @titleLink.text picture.displayTitle()
    @ownerLink.attr('href', picture.data.ownerPath)
    @ownerLink.text(picture.data.ownerName)
    this._updateSources(picture.data.fromStreams)

  gotoOwner: =>
    window.location = @ownerLink.attr('href')

  _updateSources: (streams) ->
    @fromStreamsDiv.empty()
    for stream in streams
      @fromStreamsDiv.append($('<span>').text(', ')) if @fromStreamsDiv.children().length > 0
      link = $('<a>').attr('href', stream.path).text(stream.username + "'s " + stream.type)
      @fromStreamsDiv.append(link)

    this.setVisible(@fromTitle, streams.length > 0 )

  largeWindow: ->
    generalView.displayWidth > 1024 and generalView.displayHeight > 1024

  _adjustImageFrame: ->
    displayHeight = generalView.displayHeight
    $('#imageFrameInner').css('height', (displayHeight - 40) + 'px')
    $('#bottomBanner').css('top',(displayHeight + 50) + 'px' )
    @bottomLeft.css('top', (displayHeight + 25 ) + 'px' )
    @bottomRight.css('top', (displayHeight + 36 ) + 'px' )

  switchVisible: (showing) =>
    this.setVisible @bottomLeft, showing
    this.setVisible @bottomRight, showing
    this.setVisible @slide, showing
    this.setVisible(@pictureArea, false) unless showing


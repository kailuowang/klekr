class window.View extends ViewBase

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @slide = $('#slide')
    @interestingness = $('#interestingness')
    @titleLink = $('#title')
    @ownerLink = $('#owner')
    @fromStreamsDiv = $('#fromStreams')

    @fromTitle = $('#fromTitle')
    @leftArrow = $('#leftArrow')
    @rightArrow = $('#rightArrow')
    @spacer = $('#spacer')
    @imageCaption = $('#imageCaption')
    @bottomLeft = $('#bottomLeft')
    @bottomRight = $('#bottomRight')
    this._calculateDimensions()
    this.adjustArrowsPosition()
    this.adjustImageFrame()
    this.adjustSpacerWidth()

  display: (picture) ->
    if @pictureArea.is(':visible')
      this.fadeInOut @pictureArea, false, =>
        this._fadeInto(picture)
    else
      this._fadeInto(picture)

  displayProgress: (atLast, atBegining) =>
    this.fadeInOut(@leftArrow, !atBegining)
    this.fadeInOut(@rightArrow, !atLast)

  _fadeInto: (picture) =>
    this.updateDOM(picture)
    this.fadeInOut(@pictureArea, true)

  updateDOM: (picture) ->
    @interestingness.text(picture.data.interestingness)
    @mainImg.attr('src', picture.url())
    @imageCaption.css('width', picture.width + 'px')
    @titleLink.attr('href', picture.data.flickrPageUrl)
    @titleLink.text picture.displayTitle()
    @ownerLink.attr('href', picture.data.ownerPath)
    @ownerLink.text(picture.data.ownerName)
    this.updateFromStreams(picture.data.fromStreams)

  gotoOwner: =>
    window.location = @ownerLink.attr('href')

  updateFromStreams: (streams) ->
    @fromStreamsDiv.empty()
    for stream in streams
      @fromStreamsDiv.append($('<span>').text(', ')) if @fromStreamsDiv.children().length > 0
      link = $('<a>').attr('href', stream.path).text(stream.username + "'s " + stream.type)
      @fromStreamsDiv.append(link)

    this.setVisible(@fromTitle, streams.length > 0 )

  _calculateDimensions: ->
    [@windowWidth, @windowHeight] = this.honeycombAdjustedDimension()
    [@displayWidth, @displayHeight] = [@windowWidth - 80, @windowHeight - 40]

  largeWindow: ->
    @displayWidth > 1024 and @displayHeight > 1024

  nextClick: (listener) ->
    $('#right').click(listener)

  previousClick: (listener) ->
    $('#left').click(listener)

  toGridLinkClick: (listener) ->
    $('#toGridLink').click ->
      listener()
      false

  adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @leftArrow.css('line-height', sideArrowHeight)
    @rightArrow.css('line-height', sideArrowHeight)

  adjustSpacerWidth: ->
    if this.isHoneycomb()
      @spacer.attr('width', @windowWidth + 'px')
    else
      @spacer.hide()

  adjustImageFrame: ->
    $('#imageFrameInner').css('height', (@displayHeight - 80) + 'px')
    $('#bottomBanner').css('top',(@displayHeight + 20) + 'px' )
    @bottomLeft.css('top', (@displayHeight - 5 ) + 'px' )
    @bottomRight.css('top', (@displayHeight - 5 ) + 'px' )

  switchVisible: (showing) =>
    this.setVisible @bottomLeft, showing
    this.setVisible @bottomRight, showing
    this.setVisible @slide, showing
    this.setVisible(@pictureArea, false) unless showing


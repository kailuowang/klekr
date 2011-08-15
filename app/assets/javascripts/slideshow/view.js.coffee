class window.View extends ViewBase

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @gridview = $('#gridview')
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
    @pictureArea.fadeOut 100, =>
      this.updateDOM(picture)
    @pictureArea.show() unless @pictureArea.is(":visible")
    @pictureArea.fadeIn(100)

  updateDOM: (picture) ->
    @interestingness.text(picture.data.interestingness)
    @mainImg.attr('src', picture.url())
    @imageCaption.css('width', picture.width + 'px')
    @titleLink.attr('href', picture.data.flickrPageUrl)
    @titleLink.text( this.pictureTitle(picture))
    @ownerLink.attr('href', picture.data.ownerPath)
    @ownerLink.text(picture.data.ownerName)
    this.updateFromStreams(picture.data.fromStreams)

  gotoOwner: =>
    window.location = @ownerLink.attr('href')

  updateFromStreams: (streams) ->
    @fromStreamsDiv.empty()
    for stream in streams
      link = $('<a>').attr('href', stream.path).text(stream.username + "'s " + stream.type)
      @fromStreamsDiv.append(link)
      @fromStreamsDiv.append($('<span>').text(' | '))
    this.setVisible(@fromTitle, streams.length > 0 )

  pictureTitle: (picture) ->
    t = picture.data.title
    if t? and t isnt '-' and t isnt '.' and t isnt ''
      picture.data.title
    else
      'untitled'

  _calculateDimensions: ->
    [@windowWidth, @windowHeight] = this.honeycombAdjustedDimension($(window).width(), $(window).height() )
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
    @spacer.attr('width', @windowWidth + 'px')

  adjustImageFrame: ->
    $('#imageFrameInner').css('height', (@displayHeight - 80) + 'px')
    $('#bottomBanner').css('top',(@displayHeight + 20) + 'px' )
    @bottomLeft.css('top', (@displayHeight ) + 'px' )
    @bottomRight.css('top', (@displayHeight) + 'px' )

  toggleGridview: =>
    showingGridview = this.inGridview()
    this.showHideGridview(!showingGridview)

  showHideGridview: (showGridview)=>
    this.fadeInOut(@slide, !showGridview)
    this.fadeInOut(@gridview, showGridview)
    this.setVisible @bottomLeft, !showGridview
    this.setVisible @bottomRight, !showGridview

  inGridview: ->
    @gridview.is(":visible")

  debug: (msg) ->
    $('#debugInfo').text(msg)

  honeycombAdjustedDimension: (originalWidth, originalHeight) ->
    if isHoneycombCheating = originalWidth is 980
      [1280, 750]
    else
      [originalWidth, originalHeight]

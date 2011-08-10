class window.View

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @gridview = $('#gridview')
    @slide = $('#slide')
    @interestingness = $('#interestingness')
    @titleLink = $('#title')
    @ownerLink = $('#owner')
    @fromStreamsDiv = $('#fromStreams')
    @faveLink = $('#faveLink')
    @faved = $('#faved')
    @faveWaiting = $('#faveWaiting')
    @fromTitle = $('#fromTitle')
    @faveArea = $('#faveArea')
    @leftArrow = $('#leftArrow')
    @rightArrow = $('#rightArrow')
    @spacer = $('#spacer')
    @imageCaption = $('#imageCaption')
    @bottomLeft = $('#bottomLeft')
    @bottomRight = $('#bottomRight')
    [@displayWidth, @displayHeight] = this.displayDimension()
    this.adjustArrowsPosition()
    this.adjustImageFrame()
    this.adjustSpacerWidth()

  display: (picture) ->
    @pictureArea.fadeOut 100, =>
      this.updateDOM(picture)
    @pictureArea.show() unless @pictureArea.is(":visible")
    @pictureArea.fadeIn(100)

  updateDOM: (picture) ->
    @mainImg.attr('src', picture.url())
    @imageCaption.css('width', picture.width + 'px')
    @interestingness.text(picture.data.interestingness)
    @titleLink.attr('href', picture.data.flickrPageUrl)
    @titleLink.text( this.pictureTitle(picture))
    @ownerLink.attr('href', picture.data.ownerPath)
    @ownerLink.text(picture.data.ownerName)
    this.updateFromStreams(picture.data.fromStreams)
    this.updateFavedStatus(picture)

  updateFavedStatus: (picture) ->
    @faveWaiting.hide()
    this.setVisible(@faveLink, !picture.data.faved)
    this.setVisible(@faved, picture.data.faved)
    this.setVisible(@faveArea, picture.data.favePath?)

  gotoOwner: =>
    window.location = @ownerLink.attr('href')

  changingFavedStatus: ->
    @faveWaiting.show()
    @faveLink.hide()

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

  displayDimension: ->
    [windowWidth, windowHeight] = this.honeycombAdjustedDimension($(window).width(), $(window).height() )
    [windowWidth - 80, windowHeight - 40]

  largeWindow: ->
    @displayWidth > 1024 and @displayHeight > 1024


  nextClicked: (listener) ->
    $('#right').click(listener)

  faveClicked: (listener) ->
    @faveLink.click ->
      listener()
      false

  faveOperationVisible: ->
    @faveLink.is(':visible')

  previousClicked: (listener) ->
    $('#left').click(listener)

  adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @leftArrow.css('line-height', sideArrowHeight)
    @rightArrow.css('line-height', sideArrowHeight)

  adjustSpacerWidth: ->
    @spacer.attr('width', @displayWidth + 'px')

  adjustImageFrame: ->
    $('#imageFrameInner').css('height', (@displayHeight - 80) + 'px')
    $('#bottomBanner').css('top',(@displayHeight + 20) + 'px' )
    @bottomLeft.css('top', (@displayHeight + 10) + 'px' )
    @bottomRight.css('top', (@displayHeight + 10) + 'px' )

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

  setVisible: (element, visible) ->
    if(visible)
       element.show()
    else
       element.hide()

  fadeInOut: (element, visible) ->
    if(visible)
      element.fadeIn(100)
    else
      element.fadeOut(100)


  debug: (msg) ->
    $('#debugInfo').text(msg)

  honeycombAdjustedDimension: (originalWidth, originalHeight) ->
    if isHoneycombCheating = originalWidth is 980
      [1280, 780]
    else
      [originalWidth, originalHeight]

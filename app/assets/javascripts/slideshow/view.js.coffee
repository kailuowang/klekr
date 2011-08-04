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
    [@displayWidth, @displayHeight] = this.displayDimension()
    this.adjustArrowsPosition()
    this.adjustSpacerWidth()

  display: (picture) ->
    @pictureArea.fadeOut 100, =>
      this.updateDOM(picture)
    @pictureArea.show() unless @pictureArea.is(":visible")
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
    this.setVisible(@faveLink, !picture.data.faved)
    this.setVisible(@faved, picture.data.faved)
    this.setVisible(@faveArea, picture.data.favePath?)

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
    this.setVisible(@fromTitle, streams.length > 0 )

  pictureTitle: (picture) ->
    t = picture.data.title
    if t? and t isnt '-' and t isnt '.' and t isnt ''
      picture.data.title
    else
      'untitled'

  displayDimension: ->
    [$(window).width() - 40, $(window).height()]

  largeWindow: ->
    @displayWidth > 1024 and @displayHeight > 1024


  nextClicked: (listener) ->
    $('#right').click(listener)

  faveClicked: (listener) ->
    @faveLink.click ->
      listener()
      false

  previousClicked: (listener) ->
    $('#left').click(listener)

  adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @leftArrow.css('line-height', sideArrowHeight)
    @rightArrow.css('line-height', sideArrowHeight)

  adjustSpacerWidth: ->
    @spacer.attr('width', @displayWidth + 'px')

  toggleGridview: ->
    showingGridview = @gridview.is(":visible")
    this.fadeInOut(@slide, showingGridview)
    this.fadeInOut(@gridview, !showingGridview)

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

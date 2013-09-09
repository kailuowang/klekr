class window.GeneralView extends ViewBase
  constructor: ->
    @_leftArrow = $('#leftArrow')
    @_rightArrow = $('#rightArrow')
    @_indicator = $('#indicator')
    @_indicatorPanel = $('#mode-indicator')
    @bottomLeft = $('#bottomLeft')
    @socialSharing = new klekr.SocialSharing exhibit_slideshow_path()

    this._initFullScreenButton()
    $(window).resize(_.debounce(this.initLayout, 500))
    this.initLayout()

  initLayout: =>
    if this._updateDimensions()
      this._adjustArrowsPosition()
      this._adjustFrames()
      this._updateFullScreenButton()
      this._updateFullScreenLayout()
      this.trigger('layout-changed' )

  updateNavigation: (forwardable, backwardable) =>
    $('.side-nav').show()
    this.fadeInOut(@_leftArrow, backwardable)
    this.fadeInOut(@_rightArrow, forwardable)
    this._resetScorllIndication()

  updateModeIndicator: (toGrid) =>
    @_indicatorPanel.show()
    @_indicatorPanel.attr('title', if toGrid then 'Show Picture' else 'Show Grid')
    position = if toGrid then 26 else 0
    @_indicator.css('left', "#{position}px" )

  toggleModeClick: (listener) ->
    @_indicatorPanel.click listener

  nextClick: (listener) ->
    $('#right').click(listener)

  showEmptyGalleryMessage: =>
    $('#empty-gallery-message').show()

  previousClick: (listener) ->
    $('#left').click(listener)

  updateShareLink: (filterSettings = {}) =>
    if @socialSharing.updatable()
      @socialSharing.path = exhibit_slideshow_path()
      @socialSharing.params = _.extend({collector_id: klekr.Global.currentCollector.id}, filterSettings)
      @socialSharing.update()

  inidicateScroll: (position) =>
    leftPadding = rightPadding = 10
    if ( offset = position * 2 ) < 0
      leftPadding = 10 + offset
    else
      rightPadding = 10 - offset

    @_leftArrow.css('padding-left', leftPadding + 'px')
    @_rightArrow.css('padding-right', rightPadding + 'px')

  _resetScorllIndication: => this.inidicateScroll(0)

  _updateDimensions: ->
    [newWidth, newHeight] = this.windowDimension()
    heightReserve = if @_isFullScreenMobile() then 0 else 93

    if([@windowWidth, @windowHeight] isnt [newWidth, newHeight])
      [@windowWidth, @windowHeight] = [newWidth, newHeight]
      [@displayWidth, @displayHeight] = [@windowWidth - 80, @windowHeight - heightReserve]
      true
    else
      false

  _adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @_leftArrow.css('line-height', sideArrowHeight)
    @_rightArrow.css('line-height', sideArrowHeight)

  _adjustFrames: =>
    bottomOffset = @displayHeight + 51
    $('#bottom-banner').css('top',(bottomOffset + 10) + 'px' )
    topLeftWidth = @windowWidth / 2 + 40
    $('#top-banner-left').css('max-width', topLeftWidth + 'px')

  _initFullScreenButton: =>
    @_fullScreenButton ?= $('#full-screen-button')

    if fullScreenApi.supportsFullScreen
      @_fullScreenButton.show()
      @_fullScreenButton.click this.toggleFullScreen

  _updateFullScreenButton: =>
    newTitle = if fullScreenApi.isFullScreen() then 'Exit full screen' else 'Full screen (recommended)'
    @_fullScreenButton.attr('title', newTitle)

  _updateFullScreenLayout: =>
    isFullScreenMobile = @_isFullScreenMobile()
    pictureAreaTop = if isFullScreenMobile then "0px" else "60px"
    bottomLeftBottom = if isFullScreenMobile then "5px" else "10px"
    $("#slide #pictureArea").css("top", pictureAreaTop)
    $(".fullscreen-hidden").toggleClass("fullscreen",  isFullScreenMobile)
    $("#bottomLeft").css("bottom", bottomLeftBottom)


  _isFullScreenMobile: =>
    fullScreenApi.isFullScreen() and @isMobile()
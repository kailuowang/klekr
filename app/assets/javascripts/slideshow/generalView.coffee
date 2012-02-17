class window.GeneralView extends ViewBase
  constructor: ->
    @_leftArrow = $('#leftArrow')
    @_rightArrow = $('#rightArrow')
    @_indicator = $('#indicator')
    @_indicatorPanel = $('#mode-indicator')
    @bottomLeft = $('#bottomLeft')
    @bottomRight = $('#bottomRight')
    @socialSharing = new klekr.SocialSharing exhibit_slideshow_path()

    this._initFullScreenButton()
    $(window).resize(this.initLayout)
    this.initLayout()

  initLayout: =>
    this._calculateDimensions()
    this._adjustArrowsPosition()
    this._adjustFrames()
    this._updateFullScreenButton()
    this.trigger('layout-changed' )

  displayProgress: (atLast, atBegining) =>
    $('.side-nav').show()
    this.fadeInOut(@_leftArrow, !atBegining)
    this.fadeInOut(@_rightArrow, !atLast)

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

  _calculateDimensions: ->
    [@windowWidth, @windowHeight] = this.windowDimension()
    [@displayWidth, @displayHeight] = [@windowWidth - 80, @windowHeight - 93]


  _adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @_leftArrow.css('line-height', sideArrowHeight)
    @_rightArrow.css('line-height', sideArrowHeight)

  _adjustFrames: =>
    bottomOffset = @displayHeight + 51
    $('#bottomBanner').css('top',(bottomOffset + 10) + 'px' )
    topLeftWidth = @windowWidth / 2 + 40
    $('#top-banner-left').css('max-width', topLeftWidth + 'px')

  _initFullScreenButton: =>
    @_fullScreenButton ?= $('#full-screen-button')

    if fullScreenApi.supportsFullScreen
      @_fullScreenButton.show()
      @_fullScreenButton.click this.toggleFullScreen

  _updateFullScreenButton: =>
    newTitle = if fullScreenApi.isFullScreen() then 'Exit full screen' else 'Go full screen!'
    @_fullScreenButton.attr('title', newTitle)
class window.GeneralView extends ViewBase
  constructor: ->
    @_leftArrow = $('#leftArrow')
    @_rightArrow = $('#rightArrow')
    @_indicator = $('#indicator')
    @_indicatorPanel = $('#mode-indicator')
    @bottomLeft = $('#bottomLeft')
    @bottomRight = $('#bottomRight')
    $(window).resize(this.initLayout)
    this.initLayout()
    this.updateShareLink()

  initLayout: =>
    this._calculateDimensions()
    this._adjustArrowsPosition()
    this._adjustFrames()
    this.trigger('layout-changed' )

  displayProgress: (atLast, atBegining) =>
    $('.side-nav').show()
    this.fadeInOut(@_leftArrow, !atBegining)
    this.fadeInOut(@_rightArrow, !atLast)

  updateModeIndicator: (isGrid) =>
    @_indicatorPanel.show()
    offset = 26
    left = if isGrid then offset else 0
    unless alreadyInPosition = "#{left}px" is @_indicator.css('left')
      animation = if (left is offset) then '+=' else '-='
      @_indicator.animate {left: animation + offset}, ViewBase.duration

  toggleModeClick: (listener) ->
    @_indicatorPanel.click listener

  nextClick: (listener) ->
    $('#right').click(listener)

  showEmptyGalleryMessage: =>
    $('#empty-gallery-message').show()

  previousClick: (listener) ->
    $('#left').click(listener)

  updateShareLink: (filterSettings = {}) =>
    @_shareLink ?= $('#top-banner-left #share-link')
    if @_shareLink.length > 0
      params = _.extend({collector_id: klekr.Global.currentCollector.id}, filterSettings)
      url = exhibit_slideshow_path() + '?' + $.param(params)
      @_shareLink.attr href: url

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



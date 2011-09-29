class window.GeneralView extends ViewBase
  constructor: ->
    @_leftArrow = $('#leftArrow')
    @_rightArrow = $('#rightArrow')
    @_spacer = $('#spacer')
    @_indicator = $('#indicator')
    @_indicatorPanel = $('#mode-indicator')
    @bottomLeft = $('#bottomLeft')
    @bottomRight = $('#bottomRight')

    this._calculateDimensions()
    this._adjustSpacerWidth()
    this._adjustArrowsPosition()
    this._adjustFrames()

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

  _calculateDimensions: ->
    [@windowWidth, @windowHeight] = this.honeycombAdjustedDimension()
    [@displayWidth, @displayHeight] = [@windowWidth - 80, @windowHeight - 93]

  _adjustSpacerWidth: ->
    if this.isHoneycomb()
      @_spacer.attr('width', @windowWidth + 'px')
    else
      @_spacer.hide()

  _adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @_leftArrow.css('line-height', sideArrowHeight)
    @_rightArrow.css('line-height', sideArrowHeight)

  _adjustFrames: =>
    bottomOffset = @displayHeight + 51
    $('#bottomBanner').css('top',(bottomOffset + 10) + 'px' )



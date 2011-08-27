class window.GeneralView extends ViewBase
  constructor: ->
    @_leftArrow = $('#leftArrow')
    @_rightArrow = $('#rightArrow')
    @_spacer = $('#spacer')
    this._calculateDimensions()
    this._adjustSpacerWidth()
    this._adjustArrowsPosition()

  displayProgress: (atLast, atBegining) =>
    this.fadeInOut(@_leftArrow, !atBegining)
    this.fadeInOut(@_rightArrow, !atLast)

  nextClick: (listener) ->
    $('#right').click(listener)

  previousClick: (listener) ->
    $('#left').click(listener)

  _calculateDimensions: ->
    [@windowWidth, @windowHeight] = this.honeycombAdjustedDimension()
    [@displayWidth, @displayHeight] = [@windowWidth - 80, @windowHeight - 40]


  _adjustSpacerWidth: ->
    if this.isHoneycomb()
      @_spacer.attr('width', @windowWidth + 'px')
    else
      @_spacer.hide()

  _adjustArrowsPosition: ->
    sideArrowHeight = ( @displayHeight - 150 )+ "px"
    @_leftArrow.css('line-height', sideArrowHeight)
    @_rightArrow.css('line-height', sideArrowHeight)


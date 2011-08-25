class window.GeneralView extends ViewBase
  constructor: ->
    @leftArrow = $('#leftArrow')
    @rightArrow = $('#rightArrow')
    @spacer = $('#spacer')

  displayProgress: (atLast, atBegining) =>
    this.fadeInOut(@leftArrow, !atBegining)
    this.fadeInOut(@rightArrow, !atLast)
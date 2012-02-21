class klekr.ScrollControl extends Events
  constructor: (@canScroll) ->
    this.reset()
    document.addEventListener "DOMMouseScroll", this._onScroll, false  if window.addEventListener
    document.onmousewheel = this._onScroll

  reset: =>
    @position = 0

  _onScroll: (e) =>
    delta = this._getDelta( e or window.event)
    this._move(delta) if @canScroll(towardsLeft = delta < 0)

  _move: (delta) =>
    @position += delta
    if Math.abs(@position) > 5
      this.trigger 'jump', @position < 0
      this.reset()
    else
      this.trigger 'move', @position

  _getDelta: (event) =>
    if event.wheelDelta
      - event.wheelDelta / 60
    else if event.detail
      event.detail / 2
    else
      0


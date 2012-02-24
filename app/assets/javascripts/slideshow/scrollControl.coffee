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
    oldPosition = @position
    @position += delta
    needToJump = Math.abs(@position) > 5

    if needToJump
      @position = @position * 5 / Math.abs(@position)

    if @position isnt oldPosition
      this.trigger 'move', @position

    this._jump() if needToJump


  _getDelta: (event) =>
    if event.wheelDelta
      - event.wheelDelta / 60
    else if event.detail
      event.detail / 2
    else

  _jump: =>
    @jumpFunc ?= _.throttle(this._triggerJumpEvent, 500)
    @jumpFunc()

  _triggerJumpEvent: =>
    this.reset()
    this.trigger 'jump', @position < 0

class klekr.ScrollControl extends Events
  constructor: (@canScroll) ->
    this.reset()
    onScroll = _.throttle(this._onScroll, 50)
    document.addEventListener "DOMMouseScroll", onScroll, false  if window.addEventListener
    document.onmousewheel = onScroll

  reset: =>
    @position = 0

  _onScroll: (e) =>
    delta = this._getDelta( e or window.event)
    this._move(delta) if @canScroll(towardsLeft = delta < 0)

  _move: (delta) =>
    if @position is NaN #todo figure out why in some rare case this becomes true
      @position = 0
    oldPosition = @position
    @position += delta
    overThreshod = this._overThreshod()

    if overThreshod
      @position = if @position > 0 then 5 else -5

    if @position isnt oldPosition
      this.trigger 'move', @position

    this._jump() if overThreshod

  _overThreshod: =>
    Math.abs(@position) >= 5

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
    if this._overThreshod()
      this.trigger 'jump', @position < 0
      this.reset()

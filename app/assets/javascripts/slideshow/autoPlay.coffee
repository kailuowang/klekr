class window.AutoPlay extends ViewBase
  constructor: (@slide)->
    if(klekr.Global.canAutoPlay)
      @started = false
      @panel = $('#auto-play')
      @startButton = @panel.find('#play-button')
      @pauseButton = @panel.find('#pause-button')
      @startButton.click_ this._start
      @pauseButton.click_ this.pause
      @slide.bind 'off', this.hide
      @slide.bind 'on', this.show

  _start: =>
    unless @started
      @started = true
      this._schedule()
      this._updateStatus()

  hide: =>
    this.pause()
    @panel.hide()

  show: =>
    @panel.show()


  pause: =>
    if @started
      @started = false
      this._updateStatus()

  _updateStatus: =>
    this.fadeInOut(@startButton, !@started)
    this.fadeInOut(@pauseButton, @started)

  _schedule: =>
    setTimeout this._goNext, 3000

  _goNext: =>
    if @started and @slide.active()
     @started = true
     this._schedule()

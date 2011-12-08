class window.AutoPlay extends ViewBase
  constructor: (@slide)->
    if(klekr.Global.canAutoPlay)
      @started = false
      @panel = $('#auto-play')
      @startButton = @panel.find('#play-button')
      @pauseButton = @panel.find('#pause-button')
      @startButton.click_ this._start
      @pauseButton.click_ this.pause
      this._bindToSlide()
      keyShortcuts.addShortcuts(this._shortcuts())

  _start: =>
    unless @started
      @started = true
      this._schedule()
      this._updateStatus()

  _bindToSlide: =>
    @slide.bind 'off', this.hide
    @slide.bind 'on', this.show
    @slide.bind 'command-to-navigate', (commander)=>
      unless commander is this
        this.pause()

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
    this._animatePauseButton()

  _schedule: =>
    unless @slide.atTheLast()
      setTimeout this._goNext, 5000
    else
      this.pause()

  _goNext: =>
    if @started and @slide.active()
     @slide.navigateToNext(this)
     this._schedule()

  _animatePauseButton: =>
    if @started
      @pauseButton.toggleClass('faded')
      setTimeout this._animatePauseButton, 1500

  _togglePlay: =>
    if @started
      this.pause()
    else
      this._start()

  _shortcuts: ->
    [ new KeyShortcut('p', this._togglePlay, 'play/pause', => this.showing(@panel)) ]

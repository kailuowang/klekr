class window.Login
  constructor: (@authUrl) ->
    new CollapsiblePanel($('#about-klekr-panel'), $('#help-title'))
    @helpTitle = $('#help-title')
    @helpTitle.click_ =>
      this._stopCountdown()
      $('#about-klekr-title').show()

  redirectCountdown: (seconds)=>
    unless @stopCountdown
      if seconds > 0
        $("#countdown").text seconds
        setTimeout this._nextCountdown(seconds), 1000
      else
        window.location = @authUrl

  _nextCountdown: (seconds) =>
    => this.redirectCountdown(seconds - 1)

  _stopCountdown: =>
    this._switchToStoppedView()
    @stopCountdown = true

  _switchToStoppedView: =>
    $('#countDownRedirect').hide()
    $('#stoppedRedirect').show()

$ ->
  new Login(__authUrl__).redirectCountdown(5)


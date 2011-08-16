class window.Login
  constructor: (@authUrl) ->
    this._registerBodyClick()

  redirectCountdown: (seconds)=>
    unless @stopCountdown
      if seconds > 0
        $("#countdown").text seconds
        setTimeout this._nextCountdown(seconds), 1000
      else
        window.location = @authUrl

  _nextCountdown: (seconds) =>
    => this.redirectCountdown(seconds - 1)

  _registerBodyClick: =>
    $(window).click =>
      this._switchToStoppedView()
      @stopCountdown = true

  _switchToStoppedView: =>
    $('#countDownRedirect').hide()
    $('#stoppedRedirect').show()

$ ->
  new Login(__authUrl__).redirectCountdown(5)


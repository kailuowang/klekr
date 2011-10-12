class window.Login
  constructor: (@authUrl) ->
    @helpTitle = $('#help-title')
    @helpTitle.click_ =>
      this._stopCountdown()
      $('#welcome-message #detail-info').slideDown()
    new CollapsiblePanel($('#more-reasons-expand'), $('#more-reason-link'), ['Not convinced? Here is more reasons to use klekr.', 'Reasons to use klekr: '])

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
    $('#countDownRedirect').hide()
    @stopCountdown = true


$ ->
  new Login(__authUrl__).redirectCountdown(5)


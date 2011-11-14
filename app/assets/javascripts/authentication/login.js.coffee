class window.Login extends ViewBase
  constructor: (@authUrl) ->
    @helpTitle = $('.help-title')
    @helpTitle.click_ this._displayHelp

    $('.learn-more').click_ this._toggleMoreAbout
    $('.back-to-about').click_ this._toggleMoreAbout
    if klekr.Global.redirectedToLogin and !klekr.Global.showDetail
      $('#countDownRedirect').show()
      this.redirectCountdown(9)
    if klekr.Global.showDetail
      $('#want-more-link').hide()
      $('#welcome-message #detail-info').show()
    this._loadAnnouncement()

  _toggleMoreAbout: =>
    $('#about').slideToggle()
    $('#more').slideToggle()


  redirectCountdown: (seconds)=>
    @countdownText ?= $("#countdown")
    unless @stopCountdown
      if seconds > 0
        @countdownText.text seconds
        this._flashStopLink() if seconds < 5
        setTimeout this._nextCountdown(seconds), 1000
      else
        window.location = @authUrl

  _flashStopLink: =>
    @stopCountdownLink ?= $('.stop-countdown')
    @stopCountdownLink.fadeOut 70, =>
      @stopCountdownLink.fadeIn(250)

  _displayHelp: =>
    this._stopCountdown()
    $('#want-more-link').slideUp()
    $('#welcome-message #detail-info').slideDown()

  _nextCountdown: (seconds) =>
    => this.redirectCountdown(seconds - 1)

  _stopCountdown: =>
    @stopCountdown = true
    if this.showing($('#countDownRedirect'))
      $('#redirect-link').show()
      $('#countDownRedirect').hide()

  _loadAnnouncement: =>
    @tweetPanel ?= $(".tweet")
    @tweetPanel.tweet(
      join_text: "auto",
      username: "klekrNews",
      count: 1,
      auto_join_text_default: "from klekr news: ",
      loading_text: "loading announcements...",
      fetch: 20,
      filter: ((t) -> ! /^@\w+/.test(t["tweet_raw_text"])),
      template: "<b>{user}</b>: {text} <span class='time'>{time}</span>  <a class='more' href='{user_url}'>MORE</a>"
    )
    @tweetPanel.click(this._stopCountdown)

$ ->
  new Login(__authUrl__)


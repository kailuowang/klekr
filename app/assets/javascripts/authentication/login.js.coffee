class window.Login
  constructor: (@authUrl) ->
    @helpTitle = $('.help-title')
    @helpTitle.click_ this._displayHelp
    this._loadAnnouncement()
    $('.site-subtitle').addClass('fadeInRight')
    $('.learn-more').click_ this._toggleMoreAbout
    $('.back-to-about').click_ this._toggleMoreAbout

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
    $('#stop-countdown-link').slideUp()
    $('#welcome-message #detail-info').slideDown()

  _nextCountdown: (seconds) =>
    => this.redirectCountdown(seconds - 1)

  _stopCountdown: =>
    @stopCountdown = true
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
      template: '{time}, {user}: {text}'
    )
    @tweetPanel.click(this._stopCountdown)

$ ->
  new Login(__authUrl__)


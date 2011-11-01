class window.Login
  constructor: (@authUrl) ->
    @helpTitle = $('.help-title')
    @helpTitle.click_ this._displayHelp
    new CollapsiblePanel($('#more-reasons-expand'), $('#more-reason-link'), ['Not convinced? Here is more reasons to use klekr.', 'Reasons to use klekr: '])
    this._loadAnnouncement()
    $('.site-subtitle').addClass('fadeInRight')


  redirectCountdown: (seconds)=>
    @countdownText ?= $("#countdown")
    unless @stopCountdown
      if seconds > 0
        @countdownText.text seconds
        this._flashStopLink()
        setTimeout this._nextCountdown(seconds), 1000
      else
        window.location = @authUrl

  _flashStopLink: =>
    @stopCountdownLink ?= $('#stop-coundown')
    @stopCountdownLink.fadeOut 70, =>
      @stopCountdownLink.fadeIn(250)

  _displayHelp: =>
    this._stopCountdown()
    $('#basic-info').hide()
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
  new Login(__authUrl__).redirectCountdown(9)


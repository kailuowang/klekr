class window.Login extends ViewBase
  constructor: (@authUrl) ->
    @helpTitle = $('.help-title')
    @moreAbout = $('#welcome-message #about')
    @faqPanel = $('#welcome-message #faq')

    @helpTitle.click_ this._displayHelp
    this._registerEvents()
    this._displayLoginLinks()

    $('.login-auth-link').click_ @_login
    this._loadAnnouncement()

  _showingDetail: =>
    fragment = $.param.fragment()
    if fragment is 'about' or fragment is 'faq'
      fragment
    else
      null

  _displayLoginLinks: =>
    if klekr.Global.redirectedToLogin and !this._showingDetail()
      $('#countDownRedirect').show()
      this.redirectCountdown(5)

    if this._showingDetail()
      $('#want-more-link').hide()
      $('#welcome-message #' + this._showingDetail()).show()

  _registerEvents: =>
    $('.learn-more').click_ this._toggleMoreAbout
    $('.back-to-about').click_ this._toggleMoreAbout
    $('#faq-link').click_ this._toggleFaq
    $('#back-to-more-about-link').click_ this._toggleFaq
    $('#back-to-more-about-link-bottom').click this._toggleFaq


  _toggleMoreAbout: =>
    $('#about-main').slideToggle()
    $('#more').slideToggle()

  _login: =>
    rememberMe = $('#remember-me')[0].checked
    url = $('.login-auth-link').attr('href')  + "?remember_me=#{rememberMe}#" + $.param.fragment()
    window.location = url

  _toggleFaq: =>
    @moreAbout.slideToggle()
    @faqPanel.slideToggle()

  redirectCountdown: (seconds)=>
    @countdownText ?= $("#countdown")
    unless @stopCountdown
      if seconds > 0
        @countdownText.text seconds
        this._flashStopLink() if seconds < 5
        setTimeout this._nextCountdown(seconds), 1000
      else
        @_login()

  _flashStopLink: =>
    @stopCountdownLink ?= $('.stop-countdown')
    @stopCountdownLink.fadeOut 70, =>
      @stopCountdownLink.fadeIn(250)

  _displayHelp: =>
    this._stopCountdown()
    $('#want-more-link').slideUp()
    @moreAbout.slideDown()

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
            filter: ((t) -> !/^@\w+/.test(t["tweet_raw_text"])),
            template: "<b>{user}</b>: {text} <span class='time'>{time}</span>  <a class='more' href='{user_url}'>MORE</a>"
    )
    @tweetPanel.click(this._stopCountdown)

$ ->
  new Login(__authUrl__)


import ViewBase from '../global/viewBase';

/**
 * Login page controller
 * @extends ViewBase
 */
class Login extends ViewBase {
  /**
   * Creates a new Login controller
   * @param {string} authUrl - Authentication URL
   */
  constructor(authUrl) {
    super();
    this.authUrl = authUrl;
    this.helpTitle = $('.help-title');
    this.moreAbout = $('#welcome-message #about');
    this.faqPanel = $('#welcome-message #faq');
    
    this.helpTitle.click_(this._displayHelp);
    this._registerEvents();
    this._displayLoginLinks();
    
    $('.login-auth-link').click_(this._login);
    this._loadAnnouncement();
  }

  /**
   * Checks if a detail panel is showing based on URL fragment
   * @returns {string|null} The detail panel name or null
   * @private
   */
  _showingDetail = () => {
    const fragment = $.param.fragment();
    if (fragment === 'about' || fragment === 'faq') {
      return fragment;
    }
    return null;
  }

  /**
   * Displays login links and handles auto-redirect
   * @private
   */
  _displayLoginLinks = () => {
    if (window.klekr?.Global?.redirectedToLogin && !this._showingDetail()) {
      $('#countDownRedirect').show();
      this.redirectCountdown(5);
    }

    if (this._showingDetail()) {
      $('#want-more-link').hide();
      $(`#welcome-message #${this._showingDetail()}`).show();
    }
  }

  /**
   * Registers event handlers
   * @private
   */
  _registerEvents = () => {
    $('.learn-more').click_(this._toggleMoreAbout);
    $('.back-to-about').click_(this._toggleMoreAbout);
    $('#faq-link').click_(this._toggleFaq);
    $('#back-to-more-about-link').click_(this._toggleFaq);
    $('#back-to-more-about-link-bottom').click(this._toggleFaq);
  }

  /**
   * Toggles the "more about" section
   * @private
   */
  _toggleMoreAbout = () => {
    $('#about-main').slideToggle();
    $('#more').slideToggle();
  }

  /**
   * Handles login button click
   * @private
   */
  _login = () => {
    const rememberMe = $('#remember-me')[0].checked;
    const url = `${$('.login-auth-link').attr('href')}?remember_me=${rememberMe}#${$.param.fragment()}`;
    window.location = url;
  }

  /**
   * Toggles the FAQ panel
   * @private
   */
  _toggleFaq = () => {
    this.moreAbout.slideToggle();
    this.faqPanel.slideToggle();
  }

  /**
   * Countdown to auto-redirect
   * @param {number} seconds - Seconds remaining
   */
  redirectCountdown = (seconds) => {
    if (!this.countdownText) {
      this.countdownText = $("#countdown");
    }
    
    if (!this.stopCountdown) {
      if (seconds > 0) {
        this.countdownText.text(seconds);
        if (seconds < 5) {
          this._flashStopLink();
        }
        setTimeout(this._nextCountdown(seconds), 1000);
      } else {
        this._login();
      }
    }
  }

  /**
   * Flashes the stop countdown link
   * @private
   */
  _flashStopLink = () => {
    if (!this.stopCountdownLink) {
      this.stopCountdownLink = $('.stop-countdown');
    }
    
    this.stopCountdownLink.fadeOut(70, () => {
      this.stopCountdownLink.fadeIn(250);
    });
  }

  /**
   * Displays the help panel
   * @private
   */
  _displayHelp = () => {
    this._stopCountdown();
    $('#want-more-link').slideUp();
    this.moreAbout.slideDown();
  }

  /**
   * Creates a function for the next countdown step
   * @param {number} seconds - Current seconds
   * @returns {Function} Function for the next countdown step
   * @private
   */
  _nextCountdown = (seconds) => {
    return () => this.redirectCountdown(seconds - 1);
  }

  /**
   * Stops the countdown
   * @private
   */
  _stopCountdown = () => {
    this.stopCountdown = true;
    if (this.showing($('#countDownRedirect'))) {
      $('#redirect-link').show();
      $('#countDownRedirect').hide();
    }
  }

  /**
   * Loads announcements from Twitter
   * @private
   */
  _loadAnnouncement = () => {
    if (!this.tweetPanel) {
      this.tweetPanel = $(".tweet");
    }
    
    this.tweetPanel.tweet({
      join_text: "auto",
      username: "klekrNews",
      count: 1,
      auto_join_text_default: "from klekr news: ",
      loading_text: "loading announcements...",
      fetch: 20,
      filter: (t) => !/^@\w+/.test(t["tweet_raw_text"]),
      template: "<b>{user}</b>: {text} <span class='time'>{time}</span>  <a class='more' href='{user_url}'>MORE</a>"
    });
    
    this.tweetPanel.click(this._stopCountdown);
  }
}

// Initialize on document ready
$(() => {
  new Login(__authUrl__);
});

// Export for global access (compatibility with existing code)
window.Login = Login;

export default Login;
(function() {
  window.klekr = window.klekr || {};

  window.klekr.Global = window.klekr.Global || {};

  window.klekr.Slideshow = window.klekr.Slideshow || {};

  window.klekr.Sources = window.klekr.Sources || {};

  window.klekr.User = window.klekr.User || {};

  window.Events = window.Events || {
    trigger: function(eventName, data) {
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log("Event triggered: " + eventName) : void 0 : void 0;
    },
    bind: function(eventName, callback) {
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log("Event bound: " + eventName) : void 0 : void 0;
    }
  };

  (function() {
    var userAgent;
    if (typeof jQuery !== 'undefined' && !jQuery.browser) {
      jQuery.browser = {};
      userAgent = navigator.userAgent.toLowerCase();
      jQuery.browser.mozilla = /mozilla/.test(userAgent) && !/webkit/.test(userAgent);
      jQuery.browser.webkit = /webkit/.test(userAgent);
      jQuery.browser.opera = /opera/.test(userAgent);
      return jQuery.browser.msie = /msie/.test(userAgent) || /trident/.test(userAgent);
    }
  })();

}).call(this);
// jquery.tweet.js - See http://tweet.seaofclouds.com/ or https://github.com/seaofclouds/tweet for more info
// Copyright (c) 2008-2011 Todd Matthews & Steve Purcell
(function($) {
  $.fn.tweet = function(o){
    var s = $.extend({
      username: null,                           // [string or array] required unless using the 'query' option; one or more twitter screen names (use 'list' option for multiple names, where possible)
      list: null,                               // [string]   optional name of list belonging to username
      favorites: false,                         // [boolean]  display the user's favorites instead of his tweets
      query: null,                              // [string]   optional search query (see also: http://search.twitter.com/operators)
      avatar_size: null,                        // [integer]  height and width of avatar if displayed (48px max)
      count: 3,                                 // [integer]  how many tweets to display?
      fetch: null,                              // [integer]  how many tweets to fetch via the API (set this higher than 'count' if using the 'filter' option)
      page: 1,                                  // [integer]  which page of results to fetch (if count != fetch, you'll get unexpected results)
      retweets: true,                           // [boolean]  whether to fetch (official) retweets (not supported in all display modes)
      intro_text: null,                         // [string]   do you want text BEFORE your your tweets?
      outro_text: null,                         // [string]   do you want text AFTER your tweets?
      join_text:  null,                         // [string]   optional text in between date and tweet, try setting to "auto"
      auto_join_text_default: "i said,",        // [string]   auto text for non verb: "i said" bullocks
      auto_join_text_ed: "i",                   // [string]   auto text for past tense: "i" surfed
      auto_join_text_ing: "i am",               // [string]   auto tense for present tense: "i was" surfing
      auto_join_text_reply: "i replied to",     // [string]   auto tense for replies: "i replied to" @someone "with"
      auto_join_text_url: "i was looking at",   // [string]   auto tense for urls: "i was looking at" http:...
      loading_text: null,                       // [string]   optional loading text, displayed while tweets load
      refresh_interval: null ,                  // [integer]  optional number of seconds after which to reload tweets
      twitter_url: "twitter.com",               // [string]   custom twitter url, if any (apigee, etc.)
      twitter_api_url: "api.twitter.com",       // [string]   custom twitter api url, if any (apigee, etc.)
      twitter_search_url: "search.twitter.com", // [string]   custom twitter search url, if any (apigee, etc.)
      template: "{avatar}{time}{join}{text}",   // [string or function] template used to construct each tweet <li> - see code for available vars
      comparator: function(tweet1, tweet2) {    // [function] comparator used to sort tweets (see Array.sort)
        return tweet2["tweet_time"] - tweet1["tweet_time"];
      },
      filter: function(tweet) {                 // [function] whether or not to include a particular tweet (be sure to also set 'fetch')
        return true;
      }
    }, o);

    // See http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    var url_regexp = /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/gi;

    // Expand values inside simple string templates with {placeholders}
    function t(template, info) {
      if (typeof template === "string") {
        var result = template;
        for(var key in info) {
          var val = info[key];
          result = result.replace(new RegExp('{'+key+'}','g'), val === null ? '' : val);
        }
        return result;
      } else return template(info);
    }
    // Export the t function for use when passing a function as the 'template' option
    $.extend({tweet: {t: t}});

    function replacer (regex, replacement) {
      return function() {
        var returning = [];
        this.each(function() {
          returning.push(this.replace(regex, replacement));
        });
        return $(returning);
      };
    }

    function escapeHTML(s) {
      return s.replace(/</g,"&lt;").replace(/>/g,"^&gt;");
    }

    $.fn.extend({
      linkUser: replacer(/(^|[\W])@(\w+)/gi, "$1@<a href=\"http://"+s.twitter_url+"/$2\">$2</a>"),
      // Support various latin1 (\u00**) and arabic (\u06**) alphanumeric chars
      linkHash: replacer(/(?:^| )[\#]+([\w\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u00ff\u0600-\u06ff]+)/gi,
                         ' <a href="http://'+s.twitter_search_url+'/search?q=&tag=$1&lang=all'+((s.username && s.username.length == 1 && !s.list) ? '&from='+s.username.join("%2BOR%2B") : '')+'">#$1</a>'),
      capAwesome: replacer(/\b(awesome)\b/gi, '<span class="awesome">$1</span>'),
      capEpic: replacer(/\b(epic)\b/gi, '<span class="epic">$1</span>'),
      makeHeart: replacer(/(&lt;)+[3]/gi, "<tt class='heart'>&#x2665;</tt>")
    });

    function linkURLs(text, entities) {
      return text.replace(url_regexp, function(match) {
        var url = (/^[a-z]+:/i).test(match) ? match : "http://"+match;
        var text = match;
        for(var i = 0; i < entities.length; ++i) {
          var entity = entities[i];
          if (entity.url == url && entity.expanded_url) {
            url = entity.expanded_url;
            text = entity.display_url;
            break;
          }
        }
        return "<a href=\""+escapeHTML(url)+"\">"+escapeHTML(text)+"</a>";
      });
    }

    function parse_date(date_str) {
      // The non-search twitter APIs return inconsistently-formatted dates, which Date.parse
      // cannot handle in IE. We therefore perform the following transformation:
      // "Wed Apr 29 08:53:31 +0000 2009" => "Wed, Apr 29 2009 08:53:31 +0000"
      return Date.parse(date_str.replace(/^([a-z]{3})( [a-z]{3} \d\d?)(.*)( \d{4})$/i, '$1,$2$4$3'));
    }

    function relative_time(date) {
      var relative_to = (arguments.length > 1) ? arguments[1] : new Date();
      var delta = parseInt((relative_to.getTime() - date) / 1000, 10);
      var r = '';
      if (delta < 60) {
        r = delta + ' seconds ago';
      } else if(delta < 120) {
        r = 'a minute ago';
      } else if(delta < (45*60)) {
        r = (parseInt(delta / 60, 10)).toString() + ' minutes ago';
      } else if(delta < (2*60*60)) {
        r = 'an hour ago';
      } else if(delta < (24*60*60)) {
        r = '' + (parseInt(delta / 3600, 10)).toString() + ' hours ago';
      } else if(delta < (48*60*60)) {
        r = 'a day ago';
      } else {
        r = (parseInt(delta / 86400, 10)).toString() + ' days ago';
      }
      return 'about ' + r;
    }

    function build_auto_join_text(text) {
      if (text.match(/^(@([A-Za-z0-9-_]+)) .*/i)) {
        return s.auto_join_text_reply;
      } else if (text.match(url_regexp)) {
        return s.auto_join_text_url;
      } else if (text.match(/^((\w+ed)|just) .*/im)) {
        return s.auto_join_text_ed;
      } else if (text.match(/^(\w*ing) .*/i)) {
        return s.auto_join_text_ing;
      } else {
        return s.auto_join_text_default;
      }
    }

    function build_api_url() {
      var proto = ('https:' == document.location.protocol ? 'https:' : 'http:');
      var count = (s.fetch === null) ? s.count : s.fetch;
      var common_params = '&include_entities=1&callback=?';
      if (s.list) {
        return proto+"//"+s.twitter_api_url+"/1/"+s.username[0]+"/lists/"+s.list+"/statuses.json?page="+s.page+"&per_page="+count+common_params;
      } else if (s.favorites) {
        return proto+"//"+s.twitter_api_url+"/favorites/"+s.username[0]+".json?page="+s.page+"&count="+count+common_params;
      } else if (s.query === null && s.username.length == 1) {
        return proto+'//'+s.twitter_api_url+'/1/statuses/user_timeline.json?screen_name='+s.username[0]+'&count='+count+(s.retweets ? '&include_rts=1' : '')+'&page='+s.page+common_params;
      } else {
        var query = (s.query || 'from:'+s.username.join(' OR from:'));
        return proto+'//'+s.twitter_search_url+'/search.json?&q='+encodeURIComponent(query)+'&rpp='+count+'&page='+s.page+common_params;
      }
    }

    function extract_avatar_url(item, secure) {
      if (secure) {
        return ('user' in item) ?
          item.user.profile_image_url_https :
          extract_avatar_url(item, false);
      } else {
        return item.profile_image_url || item.user.profile_image_url;
      }
    }

    // Convert twitter API objects into data available for
    // constructing each tweet <li> using a template
    function extract_template_data(item){
      var o = {};
      o.item = item;
      o.source = item.source;
      o.screen_name = item.from_user || item.user.screen_name;
      o.avatar_size = s.avatar_size;
      o.avatar_url = extract_avatar_url(item, (document.location.protocol === 'https:'));
      o.retweet = typeof(item.retweeted_status) != 'undefined';
      o.tweet_time = parse_date(item.created_at);
      o.join_text = s.join_text == "auto" ? build_auto_join_text(item.text) : s.join_text;
      o.tweet_id = item.id_str;
      o.twitter_base = "http://"+s.twitter_url+"/";
      o.user_url = o.twitter_base+o.screen_name;
      o.tweet_url = o.user_url+"/status/"+o.tweet_id;
      o.reply_url = o.twitter_base+"intent/tweet?in_reply_to="+o.tweet_id;
      o.retweet_url = o.twitter_base+"intent/retweet?tweet_id="+o.tweet_id;
      o.favorite_url = o.twitter_base+"intent/favorite?tweet_id="+o.tweet_id;
      o.retweeted_screen_name = o.retweet && item.retweeted_status.user.screen_name;
      o.tweet_relative_time = relative_time(o.tweet_time);
      o.entities = item.entities ? (item.entities.urls || []).concat(item.entities.media || []) : [];
      o.tweet_raw_text = o.retweet ? ('RT @'+o.retweeted_screen_name+' '+item.retweeted_status.text) : item.text; // avoid '...' in long retweets
      o.tweet_text = $([linkURLs(o.tweet_raw_text, o.entities)]).linkUser().linkHash()[0];
      o.tweet_text_fancy = $([o.tweet_text]).makeHeart().capAwesome().capEpic()[0];

      // Default spans, and pre-formatted blocks for common layouts
      o.user = t('<a class="tweet_user" href="{user_url}">@{screen_name}</a>', o);
      o.join = s.join_text ? t(' <span class="tweet_join">{join_text}</span> ', o) : ' ';
      o.avatar = o.avatar_size ?
        t('<a class="tweet_avatar" href="{user_url}"><img src="{avatar_url}" height="{avatar_size}" width="{avatar_size}" alt="{screen_name}\'s avatar" title="{screen_name}\'s avatar" border="0"/></a>', o) : '';
      o.time = t('<span class="tweet_time"><a href="{tweet_url}" title="view tweet on twitter">{tweet_relative_time}</a></span>', o);
      o.text = t('<span class="tweet_text">{tweet_text_fancy}</span>', o);
      o.reply_action = t('<a class="tweet_action tweet_reply" href="{reply_url}">reply</a>', o);
      o.retweet_action = t('<a class="tweet_action tweet_retweet" href="{retweet_url}">retweet</a>', o);
      o.favorite_action = t('<a class="tweet_action tweet_favorite" href="{favorite_url}">favorite</a>', o);
      return o;
    }

    return this.each(function(i, widget){
      var list = $('<ul class="tweet_list">');
      var intro = '<p class="tweet_intro">'+s.intro_text+'</p>';
      var outro = '<p class="tweet_outro">'+s.outro_text+'</p>';
      var loading = $('<span class="loading">'+s.loading_text+'</span>');

      if(s.username && typeof(s.username) == "string"){
        s.username = [s.username];
      }

      $(widget).bind("tweet:load", function(){
        if (s.loading_text) $(widget).empty().append(loading);
        $.getJSON(build_api_url(), function(data){
          $(widget).empty().append(list);
          if (s.intro_text) list.before(intro);
          list.empty();

          var tweets = $.map(data.results || data, extract_template_data);
          tweets = $.grep(tweets, s.filter).sort(s.comparator).slice(0, s.count);
          list.append($.map(tweets, function(o) { return "<li>" + t(s.template, o) + "</li>"; }).join('')).
              children('li:first').addClass('tweet_first').end().
              children('li:odd').addClass('tweet_even').end().
              children('li:even').addClass('tweet_odd');

          if (s.outro_text) list.after(outro);
          $(widget).trigger("loaded").trigger((tweets.length === 0 ? "empty" : "full"));
          if (s.refresh_interval) {
            window.setTimeout(function() { $(widget).trigger("tweet:load"); }, 1000 * s.refresh_interval);
          }
          list.fadeIn();
        });
      }).trigger("tweet:load");
    });
  };
})(jQuery);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.Login = (function(superClass) {
    extend(Login, superClass);

    function Login(authUrl) {
      this.authUrl = authUrl;
      this._loadAnnouncement = bind(this._loadAnnouncement, this);
      this._stopCountdown = bind(this._stopCountdown, this);
      this._nextCountdown = bind(this._nextCountdown, this);
      this._displayHelp = bind(this._displayHelp, this);
      this._flashStopLink = bind(this._flashStopLink, this);
      this.redirectCountdown = bind(this.redirectCountdown, this);
      this._toggleFaq = bind(this._toggleFaq, this);
      this._login = bind(this._login, this);
      this._toggleMoreAbout = bind(this._toggleMoreAbout, this);
      this._registerEvents = bind(this._registerEvents, this);
      this._displayLoginLinks = bind(this._displayLoginLinks, this);
      this._showingDetail = bind(this._showingDetail, this);
      this.helpTitle = $('.help-title');
      this.moreAbout = $('#welcome-message #about');
      this.faqPanel = $('#welcome-message #faq');
      this.helpTitle.click_(this._displayHelp);
      this._registerEvents();
      this._displayLoginLinks();
      $('.login-auth-link').click_(this._login);
      this._loadAnnouncement();
    }

    Login.prototype._showingDetail = function() {
      var fragment;
      fragment = $.param.fragment();
      if (fragment === 'about' || fragment === 'faq') {
        return fragment;
      } else {
        return null;
      }
    };

    Login.prototype._displayLoginLinks = function() {
      if (klekr.Global.redirectedToLogin && !this._showingDetail()) {
        $('#countDownRedirect').show();
        this.redirectCountdown(5);
      }
      if (this._showingDetail()) {
        $('#want-more-link').hide();
        return $('#welcome-message #' + this._showingDetail()).show();
      }
    };

    Login.prototype._registerEvents = function() {
      $('.learn-more').click_(this._toggleMoreAbout);
      $('.back-to-about').click_(this._toggleMoreAbout);
      $('#faq-link').click_(this._toggleFaq);
      $('#back-to-more-about-link').click_(this._toggleFaq);
      return $('#back-to-more-about-link-bottom').click(this._toggleFaq);
    };

    Login.prototype._toggleMoreAbout = function() {
      $('#about-main').slideToggle();
      return $('#more').slideToggle();
    };

    Login.prototype._login = function() {
      var rememberMe, url;
      rememberMe = $('#remember-me')[0].checked;
      url = $('.login-auth-link').attr('href') + ("?remember_me=" + rememberMe + "#") + $.param.fragment();
      return window.location = url;
    };

    Login.prototype._toggleFaq = function() {
      this.moreAbout.slideToggle();
      return this.faqPanel.slideToggle();
    };

    Login.prototype.redirectCountdown = function(seconds) {
      if (this.countdownText == null) {
        this.countdownText = $("#countdown");
      }
      if (!this.stopCountdown) {
        if (seconds > 0) {
          this.countdownText.text(seconds);
          if (seconds < 5) {
            this._flashStopLink();
          }
          return setTimeout(this._nextCountdown(seconds), 1000);
        } else {
          return this._login();
        }
      }
    };

    Login.prototype._flashStopLink = function() {
      if (this.stopCountdownLink == null) {
        this.stopCountdownLink = $('.stop-countdown');
      }
      return this.stopCountdownLink.fadeOut(70, (function(_this) {
        return function() {
          return _this.stopCountdownLink.fadeIn(250);
        };
      })(this));
    };

    Login.prototype._displayHelp = function() {
      this._stopCountdown();
      $('#want-more-link').slideUp();
      return this.moreAbout.slideDown();
    };

    Login.prototype._nextCountdown = function(seconds) {
      return (function(_this) {
        return function() {
          return _this.redirectCountdown(seconds - 1);
        };
      })(this);
    };

    Login.prototype._stopCountdown = function() {
      this.stopCountdown = true;
      if (this.showing($('#countDownRedirect'))) {
        $('#redirect-link').show();
        return $('#countDownRedirect').hide();
      }
    };

    Login.prototype._loadAnnouncement = function() {
      if (this.tweetPanel == null) {
        this.tweetPanel = $(".tweet");
      }
      this.tweetPanel.tweet({
        join_text: "auto",
        username: "klekrNews",
        count: 1,
        auto_join_text_default: "from klekr news: ",
        loading_text: "loading announcements...",
        fetch: 20,
        filter: (function(t) {
          return !/^@\w+/.test(t["tweet_raw_text"]);
        }),
        template: "<b>{user}</b>: {text} <span class='time'>{time}</span>  <a class='more' href='{user_url}'>MORE</a>"
      });
      return this.tweetPanel.click(this._stopCountdown);
    };

    return Login;

  })(ViewBase);

  $(function() {
    return new Login(__authUrl__);
  });

}).call(this);



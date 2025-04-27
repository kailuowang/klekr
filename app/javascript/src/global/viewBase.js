/**
 * ViewBase Class
 * Base class for view components with common UI functionality
 */
import Events from './events.js';

class ViewBase extends Events {
  constructor() {
    super();
    
    // Bind methods
    this.toggleFullScreen = this.toggleFullScreen.bind(this);
    this.setArtistCollectionLink = this.setArtistCollectionLink.bind(this);
    this.windowDimension = this.windowDimension.bind(this);
    this.login = this.login.bind(this);
  }

  static showingPopup = false;
  static duration = $.fx.interval * 6;

  static isMobile() {
    // 'safari/533.16' is the pretend userAgent from honeycomb when set as using desktop user agent
    return /iphone|ipad|ipod|safari\/533\.16|android|blackberry|mini|windows\sce|palm/i.test(navigator.userAgent.toLowerCase());
  }

  isMobile() { 
    return ViewBase.isMobile(); 
  }

  setVisible(element, visible) {
    if (visible) {
      element.show();
    } else {
      element.hide();
    }
  }

  toggleFullScreen() {
    if (fullScreenApi.supportsFullScreen) {
      if (fullScreenApi.isFullScreen()) {
        fullScreenApi.cancelFullScreen();
      } else {
        $('body').requestFullScreen();
      }
    }
  }

  fadeInOut(element, visible, callback) {
    this._animateVisible(element, visible, callback);
  }

  popup(div, opts = {}) {
    div.bPopup({
      onOpen: () => {
        ViewBase.showingPopup = true;
        if (opts.onOpen) opts.onOpen();
      },
      onClose: () => {
        ViewBase.showingPopup = false;
        if (opts.onClose) opts.onClose();
      }
    });
  }

  closePopup(div) {
    div.bPopup().close();
  }

  showing(elem) {
    return elem.is(':visible');
  }

  setArtistCollectionLink(link, picture) {
    link.attr({ href: `${picture.ownerPath}?type=FaveStream` });
    link.text(`${picture.ownerName}'s faves.`);
  }

  windowDimension() {
    return [$(window).width(), $(window).height()];
  }

  _animateVisible(element, visible, callback) {
    if (visible) {
      element.fadeIn(ViewBase.duration, callback);
    } else {
      element.fadeOut(ViewBase.duration, callback);
    }
  }

  login() {
    location.href = $.param.querystring(window.location.href, 'do_login=true');
  }
}

// Set static properties
$.fx.interval = 20;

// Initialize when DOM is ready
$(function() {
  $.fx.off = ViewBase.isMobile();
  if ($.browser && $.browser.msie) {
    alert("Ooopz, we are still working on supporting Internet Explorer. For now, we highly recommend using Firefox or Chrome to browse klekr.");
  }
});

// Export to window
window.ViewBase = ViewBase;

export default ViewBase;
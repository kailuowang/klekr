/**
 * Base class for all views in the application
 * @extends Events
 */
class ViewBase extends Events {
  static showingPopup = false;
  static duration = $.fx.interval * 6;

  /**
   * Checks if the current device is mobile
   * @returns {boolean} Whether the current device is mobile
   */
  static isMobile() {
    // 'safari/533.16' is the pretend userAgent from honeycomb when set as using desktop user agent
    return /iphone|ipad|ipod|safari\/533\.16|android|blackberry|mini|windows\sce|palm/i.test(
      navigator.userAgent.toLowerCase()
    );
  }

  /**
   * Instance method to check if device is mobile
   * @returns {boolean} Whether the current device is mobile
   */
  isMobile() {
    return ViewBase.isMobile();
  }

  /**
   * Shows or hides an element
   * @param {jQuery} element - The element to show or hide
   * @param {boolean} visible - Whether the element should be visible
   */
  setVisible(element, visible) {
    if (visible) {
      element.show();
    } else {
      element.hide();
    }
  }

  /**
   * Toggles full screen mode
   */
  toggleFullScreen = () => {
    if (fullScreenApi.supportsFullScreen) {
      if (fullScreenApi.isFullScreen()) {
        fullScreenApi.cancelFullScreen();
      } else {
        $('body').requestFullScreen();
      }
    }
  }

  /**
   * Fades an element in or out
   * @param {jQuery} element - The element to fade
   * @param {boolean} visible - Whether the element should be visible
   * @param {Function} callback - Callback function after animation
   */
  fadeInOut(element, visible, callback) {
    this._animateVisible(element, visible, callback);
  }

  /**
   * Shows a popup
   * @param {jQuery} div - The popup element
   * @param {Object} opts - Options for the popup
   */
  popup(div, opts = {}) {
    div.bPopup({
      onOpen: () => {
        ViewBase.showingPopup = true;
        if (opts.onOpen) {
          opts.onOpen();
        }
      },
      onClose: () => {
        ViewBase.showingPopup = false;
        if (opts.onClose) {
          opts.onClose();
        }
      }
    });
  }

  /**
   * Closes a popup
   * @param {jQuery} div - The popup element
   */
  closePopup(div) {
    div.bPopup().close();
  }

  /**
   * Checks if an element is visible
   * @param {jQuery} elem - The element to check
   * @returns {boolean} Whether the element is visible
   */
  showing(elem) {
    return elem.is(':visible');
  }

  /**
   * Sets an artist collection link
   * @param {jQuery} link - The link element
   * @param {Object} picture - The picture object
   */
  setArtistCollectionLink = (link, picture) => {
    link.attr({ href: `${picture.ownerPath}?type=FaveStream` });
    link.text(`${picture.ownerName}'s faves.`);
  }

  /**
   * Gets the window dimensions
   * @returns {Array<number>} Window width and height
   */
  windowDimension = () => {
    return [$(window).width(), $(window).height()];
  }

  /**
   * Animates visibility of an element
   * @param {jQuery} element - The element to animate
   * @param {boolean} visible - Whether the element should be visible
   * @param {Function} callback - Callback function after animation
   * @private
   */
  _animateVisible(element, visible, callback) {
    if (visible) {
      element.fadeIn(ViewBase.duration, callback);
    } else {
      element.fadeOut(ViewBase.duration, callback);
    }
  }

  /**
   * Redirects to login page
   */
  login = () => {
    location.href = $.param.querystring(window.location.href, 'do_login=true');
  }
}

// Initialize animations
$(() => {
  $.fx.interval = 20;
  $.fx.off = ViewBase.isMobile();
  
  if ($.browser.msie) {
    alert("Ooopz, we are still working on supporting Internet Explorer. For now, we highly recommend using Firefox or Chrome to browse klekr.");
  }
});

// Export for global access (compatibility with existing code)
window.ViewBase = ViewBase;

export default ViewBase;
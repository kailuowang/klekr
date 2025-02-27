import { broadcaster } from './broadcaster';

/**
 * Analytics handler for tracking events and page views
 */
class Analytics {
  /**
   * Reports collector info to Google Analytics
   */
  reportCollectorInfo = () => {
    if (window.klekr?.Global?.currentCollector) {
      const { name, flickrId } = window.klekr.Global.currentCollector;
      const flickrInfo = `${name} - ${flickrId}`;
      _gaq.push(['_setCustomVar', 1, 'user info', flickrInfo, 1]);
    }
  }

  /**
   * Binds to global events for tracking
   */
  bindToGlobalEvents = () => {
    broadcaster.bind('picture:viewed', this.trackPageView);
    broadcaster.bind('javascript:error', this.trackJSError);
  }

  /**
   * Tracks a page view
   */
  trackPageView = () => {
    _gaq.push(['_trackPageview']);
  }

  /**
   * Tracks a JavaScript error
   * @param {Array} error - Error details [message, file, line]
   */
  trackJSError = (error) => {
    const [message, file, line] = error;
    const formattedMessage = `[${file} (${line})] ${message}`;
    _gaq.push(['_trackEvent', 'Exceptions', 'Application', formattedMessage, null, true]);
  }
}

// Initialize analytics on document ready
$(() => {
  if (typeof _gaq !== 'undefined') {
    const ka = new Analytics();
    ka.reportCollectorInfo();
    ka.bindToGlobalEvents();
  }
});

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.Analytics = Analytics;

export default Analytics;
// Create namespace if it doesn't exist
window.klekr = window.klekr || {};

class Analytics {
  constructor() {
    // Bind methods to this
    this.reportCollectorInfo = this.reportCollectorInfo.bind(this);
    this.bindToGlobalEvents = this.bindToGlobalEvents.bind(this);
    this.trackPageView = this.trackPageView.bind(this);
    this.trackJSError = this.trackJSError.bind(this);
  }

  reportCollectorInfo() {
    if (klekr.Global && klekr.Global.currentCollector) {
      const flickrInfo = klekr.Global.currentCollector.name + ' - ' + klekr.Global.currentCollector.flickrId;
      if (window._gaq) {
        _gaq.push(['_setCustomVar', 1, 'user info', flickrInfo, 1]);
      }
    }
  }

  bindToGlobalEvents() {
    if (klekr.Global && klekr.Global.broadcaster) {
      klekr.Global.broadcaster.bind('picture:viewed', this.trackPageView);
      klekr.Global.broadcaster.bind('javascript:error', this.trackJSError);
    }
  }

  trackPageView() {
    if (window._gaq) {
      _gaq.push(['_trackPageview']);
    }
  }

  trackJSError(error) {
    if (window._gaq) {
      const [message, file, line] = error;
      const formattedMessage = '[' + file + ' (' + line + ')] ' + message;
      _gaq.push(['_trackEvent', 'Exceptions', 'Application', formattedMessage, null, true]);
    }
  }
}

// Assign to namespace
klekr.Analytics = Analytics;

// Initialize when DOM is ready
$(function() {
  if (window._gaq) {
    const ka = new klekr.Analytics();
    ka.reportCollectorInfo();
    ka.bindToGlobalEvents();
  }
});
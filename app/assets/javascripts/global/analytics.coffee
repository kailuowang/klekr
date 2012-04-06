class klekr.Analytics
  reportCollectorInfo: =>
    if klekr.Global.currentCollector?
      flickrInfo = klekr.Global.currentCollector.name + ' - ' + klekr.Global.currentCollector.flickrId
      _gaq.push(['_setCustomVar', 1, 'user info', flickrInfo, 1 ])

  bindToGlobalEvents: =>
    klekr.Global.broadcaster.bind 'picture:viewed', this.trackPageView
    klekr.Global.broadcaster.bind 'javascript:error', this.trackJSError

  trackPageView: =>
    _gaq.push(['_trackPageview']);

  trackJSError: (error) =>
    [message, file, line] = error
    sFormattedMessage = '[' + file + ' (' + line + ')] ' + message
    _gaq.push(['_trackEvent', 'Exceptions', 'Application', sFormattedMessage, null, true])

$ ->
  if  _gaq?
    ka = new klekr.Analytics()
    ka.reportCollectorInfo()
    ka.bindToGlobalEvents()
class klekr.Analytics
  reportCollectorInfo: =>
    if klekr.Global.currentCollector?
      flickrInfo = klekr.Global.currentCollector.name + ' - ' + klekr.Global.currentCollector.flickrId
      _gaq.push(['_setCustomVar', 1, 'user info', flickrInfo, 1 ])

  trackJSPageViewes: =>
    klekr.Global.broadcaster.bind 'picture:viewed', this.trackPageView

  trackPageView: =>
    _gaq.push(['_trackPageview']);

$ ->
  if  _gaq?
    ka = new klekr.Analytics()
    ka.reportCollectorInfo()
    ka.trackJSPageViewes()
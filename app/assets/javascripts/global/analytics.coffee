class klekr.Analytics
  reportCollectorInfo: =>
    if  _gaq? and klekr.Global.currentCollector?
      flickrInfo = klekr.Global.currentCollector.name + ' - ' + klekr.Global.currentCollector.flickrId
      _gaq.push(['_setCustomVar',
        1,
        'user info',
        flickrInfo,
        1
      ])

$ ->
  new klekr.Analytics().reportCollectorInfo()
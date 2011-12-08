class klekr.Analytics
  reportCollectorInfo: =>
    if  _gaq? and klekr.Global.currentCollector?
      _gaq.push(['_setCustomVar',
        1,
        klekr.Global.currentCollector.name,
        klekr.Global.currentCollector.flickrId,
        1
      ])

$ ->
  new klekr.Analytics().reportCollectorInfo()
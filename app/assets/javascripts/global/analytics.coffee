class klekr.Analytics
  reportCollectorInfo: =>
    if  _gaq? and klekr.Global.currentCollector?
      _gaq.push(['_setCustomVar',
        1,
        'collector flickr id',
        klekr.Global.currentCollector.flickrId,
        1
      ])
      _gaq.push(['_setCustomVar',
        2,
        'collector name',
        klekr.Global.currentCollector.name,
        1
      ])

$ ->
  new klekr.Analytics().reportCollectorInfo()
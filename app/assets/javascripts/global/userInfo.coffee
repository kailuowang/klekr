class klekr.UserInfo extends ViewBase
  constructor: ->
    klekr.Global.broadcaster.bind('picture:faved', => this._updateFave(1))
    klekr.Global.broadcaster.bind('picture:unfaved', => this._updateFave(-1))
    klekr.Global.broadcaster.bind('picture:viewed', this._updateNewPictures)
    @favedCountLink = $('#user-dropdown #faved-count-link')
    @newPicturesCountLink = $('#user-dropdown #new-pictures-count-link')
    @sourcesLink = $('#user-dropdown #sources-link')

  init: =>
    klekr.Global.server.get info_collector_path({id: 'current'}), {}, (data)=>
      @favedCountLink.text(data.collection)
      @newPicturesCountLink.text(data.pictures)
      @sourcesLink.text(data.sources)
      $('#user-dropdown #detail').show()

  _updateFave: (num) =>
    if @favedCountLink?
      favedCount = parseInt @favedCountLink.text()
      @favedCountLink.text(favedCount + num)

  _updateNewPictures: =>
    count = parseInt @newPicturesCountLink.text()
    @newPicturesCountLink.text(count - 1)

$(window).load ->
  if klekr.Global.currentCollector?
    setTimeout 'new klekr.UserInfo().init()', 2000
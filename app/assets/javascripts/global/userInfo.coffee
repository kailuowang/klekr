class klekr.UserInfo extends ViewBase
  constructor: ->
    klekr.Global.broadcaster.bind('picture:faved', => this._updateFave(1))
    klekr.Global.broadcaster.bind('picture:unfaved', => this._updateFave(-1))
    klekr.Global.broadcaster.bind('picture:viewed', this._updateNewPictures)
    @favedCountLink = $('#user-dropdown #faved-count-link')
    @newPicturesCountLink = $('#user-dropdown #new-pictures-count-link')

  _updateFave: (num) =>
    if @favedCountLink?
      favedCount = parseInt @favedCountLink.text()
      @favedCountLink.text(favedCount + num)

  _updateNewPictures: =>
    count = parseInt @newPicturesCountLink.text()
    @newPicturesCountLink.text(count - 1)

$ ->
  new klekr.UserInfo
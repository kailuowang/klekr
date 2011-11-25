class window.SourceCell extends ViewBase
  constructor: (@cell, @source) ->
    @cell.find('.source-icon').attr('src', @source.iconUrl)
    @cell.find('.source-icon-link').attr('href', @source.slideUrl)
    @cell.find('.source-name').text(@source.username)
    @cell.find('.source-type').text(@source.typeDisplay)
    @mainPart = @cell.find('.main-part')
    @removeBtn = @cell.find('#remove')
    @addBtn = @cell.find('#add')
    @server = klekr.Global.server
    this._updateStatus()

  registerEvents: =>
    @cell.hover  (() => this._toggleTopBar(true)), (() => this._toggleTopBar(false))
    @removeBtn.click_ this._remove
    @addBtn.click_ this._add


  _remove: =>
    @removeBtn.fadeOut()
    @server.put unsubscribe_flickr_stream_path(@source), {}, this._refreshFromData

  _add: =>
    @addBtn.fadeOut()
    @server.put subscribe_flickr_stream_path(@source), {}, this._refreshFromData

  _refreshFromData: (data)=>
    @source = new Source(data)
    this._updateStatus()

  _updateStatus: =>
    this.setVisible @removeBtn, @source.subscribed
    this.setVisible @addBtn, !@source.subscribed
    @mainPart.toggleClass('removed', !@source.subscribed)

  _toggleTopBar: (visible)=>
    @topBar ?= @cell.find('.top-bar')
    @topBar.toggleClass('invisible', !visible)

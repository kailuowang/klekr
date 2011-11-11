class window.SourceCell extends ViewBase
  constructor: (@cell, @source) ->
    @cell.find('.source-icon').attr('src', @source.iconUrl)
    @cell.find('.source-icon-link').attr('href', @source.slideUrl)
    @cell.find('.source-name').text(@source.username + "'s")
    @cell.find('.source-type').text(@source.typeDisplay)
    @mainPart = @cell.find('.main-part')
    @removeBtn = @cell.find('#remove')
    @addBtn = @cell.find('#add')
    @removeBtn.click_ this._remove
    @addBtn.click_ this._add
    @server = klekr.Global.server
    @cell.hover  (() => this._toggleTopBar(true)), (() => this._toggleTopBar(false))

  _remove: =>
    @removeBtn.fadeOut()
    @server.put unsubscribe_flickr_stream_path(@source), {}, this._updateStatus

  _add: =>
    @addBtn.fadeOut()
    @server.put subscribe_flickr_stream_path(@source), {}, this._updateStatus

  _updateStatus: (data)=>
    @source = new Source(data)
    this.setVisible @removeBtn, @source.subscribed
    this.setVisible @addBtn, !@source.subscribed
    @mainPart.toggleClass('removed', !@source.subscribed)

  _toggleTopBar: (visible)=>
    @topBar ?= @cell.find('.top-bar')
    @topBar.toggleClass('invisible', !visible)

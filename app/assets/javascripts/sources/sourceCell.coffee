class window.SourceCell extends ViewBase
  constructor: (@cell, @source) ->
    @cell.find('.source-icon').attr('src', @source.iconUrl)
    @cell.find('.source-icon-link').attr('href', @source.slideUrl)
    @cell.find('.source-name').text(@source.username)
    @cell.find('.source-type').text(@source.typeDisplay)
    @cell.attr('id', 'source-cell-' + @source.id)
    @mainPart = @cell.find('.main-part')
    @removeBtn = @cell.find('#remove')
    @addBtn = @cell.find('#add')
    @server = klekr.Global.server
    this._updateStatus()
    klekr.Global.broadcaster.bind 'source-changed', this._onSourceChange

  registerEvents: =>
    @cell.hover  (() => this._toggleTopBar(true)), (() => this._toggleTopBar(false))
    @removeBtn.click_ this._remove
    @addBtn.click_ this._add

  about: (source) =>
    @source.id is source.id

  _remove: =>
    @removeBtn.fadeOut()
    @server.put unsubscribe_flickr_stream_path(@source), {}, this._broadcastNewSource

  _add: =>
    @addBtn.fadeOut()
    @server.put subscribe_flickr_stream_path(@source), {}, (data) =>
      this._broadcastNewSource(data)
      klekr.Global.broadcaster.trigger('source-added', @source)

  _broadcastNewSource: (data)=>
    klekr.Global.broadcaster.trigger 'source-changed', new Source(data)

  _updateStatus: =>
    this.setVisible @removeBtn, @source.subscribed
    this.setVisible @addBtn, !@source.subscribed
    @mainPart.toggleClass('removed', !@source.subscribed)

  _toggleTopBar: (visible)=>
    @topBar ?= @cell.find('.top-bar')
    @topBar.toggleClass('invisible', !visible)

  _onSourceChange: (source) =>
    if this.about source
      @source = source
      this._updateStatus()

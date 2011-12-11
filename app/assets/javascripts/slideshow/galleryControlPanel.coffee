class window.GalleryControlPanel extends ViewBase
  constructor: (@gallery)->
    @optionButton = $('.gallery-option')
    @panel = $('#slide-options')

    @loadingIndicator = @panel.find('#loading')
    @optionButton.click => @panel.toggle()
    @panel.find('.close-btn').click_ => @panel.hide()
    @downloadButton = $('#download-pictures')
    @downloadButton.click_ this._downloadPictures
    new CollapsiblePanel($('#under-the-hood-panel'), $('#under-the-hood'), ['Go Offline ▼', 'Hide ▲'])

    klekr.Global.broadcaster.bind('picture:fully-ready', this._updateGalleryInfo)
    klekr.Global.broadcaster.bind('picture:viewed', this._updateGalleryInfo)

    @gallery.bind 'idle', this._showDownloadButton
    this._updateConnectionStatus()
    klekr.Global.server.bind 'connection-status-changed', this._updateConnectionStatus

  _downloadPictures: =>
    @gallery.increaseCacheSize(20)
    @loadingIndicator.show()
    @downloadButton.hide()

  _showDownloadButton: =>
    this._updateGalleryInfo()
    @loadingIndicator.hide()
    @downloadButton.show()

  _updateGalleryInfo: =>
    @numLabel ?= $('#num-of-pics-in-cache')
    @numNewLabel ?= $('#num-of-new-pics-in-cache')
    @numDownloadingLabel ?= $('#num-of-downloading-pics')
    numOfReadyPictures = @gallery.readyPictures().length
    @numNewLabel.text(@gallery.readyNewPictures().length)
    @numLabel.text(numOfReadyPictures)
    downloading = @gallery.size() - numOfReadyPictures
    @numDownloadingLabel.text(downloading)
    this.setVisible(@downloadingInfo ?= $('#downloading-info'), downloading > 0)

  _updateConnectionStatus: =>
    @statusLabel ?= @panel.find('#connection-status-label')
    online = klekr.Global.server.onLine()
    status = if online then 'Online' else 'Offline'
    @statusLabel.text(status)
    this.setVisible(@downloadButton, online)
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
    @gallery.bind 'new-pictures-added', this._registerPictureEvents
    @gallery.bind 'idle', this._showDownloadButton
    this._updateConnectionStatus()
    klekr.Global.server.bind 'connection-status-changed', this._updateConnectionStatus

  _downloadPictures: =>
    @gallery.retrieveMorePictures(20)
    @loadingIndicator.show()
    @downloadButton.hide()

  _showDownloadButton: =>
    this._updateGalleryInfo()
    @loadingIndicator.hide()
    @downloadButton.show()

  _updateGalleryInfo: =>
    @numLabel ?= $('#num-of-pics-in-cache')
    @numDownloadingLabel ?= $('#num-of-downloading-pics')
    @numLabel.text(@gallery.readyNewPictures().length)
    downloading = @gallery.size() - @gallery.readyPictures().length
    @numDownloadingLabel.text(downloading)
    this.setVisible(@downloadingInfo ?= $('#downloading-info'), downloading > 0)

  _registerPictureEvents: (pictures) =>
    for pic in pictures
      pic.bind 'fully-ready', this._updateGalleryInfo
      pic.bind 'viewed', this._updateGalleryInfo

  _updateConnectionStatus: =>
    @statusLabel ?= @panel.find('#connection-status-label')
    online = klekr.Global.server.onLine()
    status = if online then 'Online' else 'Offline'
    @statusLabel.text(status)
    this.setVisible(@downloadButton, online)
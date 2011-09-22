class window.GalleryControlPanel
  constructor: (@gallery)->
    @optionButton = $('#option-button')
    @panel = $('#slide-options')
    @optionButton.click => @panel.toggle()
    @typeCheckBox = $('#type-filter-checkbox')
    @typeCheckBox.change? this._typeFilterChange
    $('#download-pictures').click_ this._downloadPictures
    new CollapsiblePanel($('#under-the-hood-panel'), $('#under-the-hood'))
    @gallery.bind 'new-pictures-added', this._registerPictureEvents
    this._updateConnectionStatus()
    klekr.Global.server.bind 'connection-status-changed', this._updateConnectionStatus

  _typeFilterChange: (e) =>
    type = if e.currentTarget.checked then 'UploadStream' else null
    @gallery.applyTypeFilter(type)

  _downloadPictures: =>
    @gallery.retrieveMorePictures(20)

  _updateGalleryInfo: =>
    @numLable ?= $('#num-of-pics-in-cache')
    @numLable.text(@gallery.readyPictures().length)

  _registerPictureEvents: (pictures) =>
    pic.bind('fully-ready', this._updateGalleryInfo) for pic in pictures

  _updateConnectionStatus: =>
    @statusLabel ?= @panel.find('#connection-status-label')
    status = if klekr.Global.server.onLine() then 'Online' else 'Offline'
    @statusLabel.text(status)
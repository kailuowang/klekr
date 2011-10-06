class window.GalleryControlPanel extends ViewBase
  constructor: (@gallery)->
    @optionButton = $('#option-button')
    @panel = $('#slide-options')

    @loadingIndicator = @panel.find('#loading')
    @optionButton.click => @panel.toggle()
    @panel.find('.close-btn').click_ => @panel.hide()
    @typeCheckBox = $('#type-filter-checkbox')
    @typeCheckBox.change? this._typeFilterChange
    @downloadButton = $('#download-pictures')
    @downloadButton.click_ this._downloadPictures
    new CollapsiblePanel($('#under-the-hood-panel'), $('#under-the-hood'))
    @gallery.bind 'new-pictures-added', this._registerPictureEvents
    @gallery.bind 'idle', this._showDownloadButton
    this._updateConnectionStatus()
    klekr.Global.server.bind 'connection-status-changed', this._updateConnectionStatus
    this._setFiltersVisibility(klekr.Global.filtersOpts || {})
    @panel.find('.datepicker').simpleDatepicker()

  _typeFilterChange: (e) =>
    type = if e.currentTarget.checked then 'UploadStream' else null
    @gallery.applyTypeFilter(type)

  _downloadPictures: =>
    @gallery.retrieveMorePictures(20)
    @loadingIndicator.show()
    @downloadButton.hide()

  _setFiltersVisibility: (opts)=>
    this.setVisible($('#stream-type-filter-panel', opts.streamTypeFilter))
    this.setVisible($('#rating-filter-panel', opts.ratingFilter))
    this.setVisible($('#faved-at-filter-panel', opts.favedAtFilter))

  _showDownloadButton: =>
    this._updateGalleryInfo()
    @loadingIndicator.hide()
    @downloadButton.show()

  _updateGalleryInfo: =>
    @numLabel ?= $('#num-of-pics-in-cache')
    @numDownloadingLabel ?= $('#num-of-downloading-pics')
    @numLabel.text(@gallery.readyPictures().length)
    downloading = @gallery.size() - @gallery.readyPictures().length
    @numDownloadingLabel.text(downloading)
    this.setVisible(@downloadingInfo ?= $('#downloading-info'), downloading > 0)

  _registerPictureEvents: (pictures) =>
    pic.bind('fully-ready', this._updateGalleryInfo) for pic in pictures

  _updateConnectionStatus: =>
    @statusLabel ?= @panel.find('#connection-status-label')
    online = klekr.Global.server.onLine()
    status = if online then 'Online' else 'Offline'
    @statusLabel.text(status)
    this.setVisible(@downloadButton, online)
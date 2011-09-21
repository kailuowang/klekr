class window.GalleryControlPanel
  constructor: (@gallery)->
    @optionButton = $('#option-button')
    @panel = $('#slide-options')
    @optionButton.click => @panel.toggle()
    @typeCheckBox = $('#type-filter-checkbox')
    @typeCheckBox.change? this._typeFilterChange


  _typeFilterChange: (e) =>
    type = if e.currentTarget.checked then 'UploadStream' else null
    @gallery.applyTypeFilter(type)
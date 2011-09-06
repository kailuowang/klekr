class window.TypeFilterView extends ViewBase
  constructor: (attachedMode)->
    @typeCheckBox = $('#type-filter-checkbox')
    @filtersPanel = $('#type-filter-panel')
    attachedMode.bind 'on', this.show
    attachedMode.bind 'off', this.hide

  filterChange: (handler) =>
    @typeCheckBox.click? (e)=>
      type = if e.currentTarget.checked then 'UploadStream' else null
      handler(type)

  show: => this.fadeInOut(@filtersPanel, true)
  hide: => this.fadeInOut(@filtersPanel, false)



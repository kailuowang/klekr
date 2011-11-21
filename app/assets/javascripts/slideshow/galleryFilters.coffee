class window.GalleryFilters extends ViewBase
  constructor: ->
    @panel = $('#slide-options .filters')
    @ratingFilter = $('#rating-filter-select')
    @typeCheckBox = $('#type-filter-checkbox')
    @viewedCheckBox = $('#viewed-filter-checkbox')
    @faveDateBox = @panel.find('#fave-at-date')
    @faveDateAfterBox = @panel.find('#fave-at-date-after')

    @typeCheckBox.change? this._filterChanged
    @viewedCheckBox.change? this._filterChanged
    @ratingFilter.change? this._filterChanged
    @faveDateBox.bind('change', this._filterChanged)
    @faveDateAfterBox.bind('change', this._filterChanged)
    this._setFiltersVisibility(klekr.Global.filtersOpts || {})
    @panel.find('.datepicker').simpleDatepicker()
    this._applyDefaultFitlers()

  filterSettings: =>
    settings = {}
    settings.type = 'UploadStream' if @typeCheckBox.attr('checked')
    settings.viewed = @viewedCheckBox.attr('checked') if @viewedCheckBox?
    settings.rating = @ratingFilter[0].selectedIndex + 1 if @ratingFilter.length > 0 and @ratingFilter[0].selectedIndex > 0
    settings.faveDate = this._getDate(@faveDateBox)
    settings.faveDateAfter = this._getDate(@faveDateAfterBox)
    settings

  hasActiveFilter: =>
    for name, value of this.filterSettings()
      return true if value?
    false

  _getDate: (input) =>
    input.val() if input.length > 0 and input.val().length > 0

  _applyDefaultFitlers: =>
    if klekr.Global.defaultFilters?
      @ratingFilter[0].selectedIndex = klekr.Global.defaultFilters.rating - 1
      @faveDateBox.val klekr.Global.defaultFilters.faveDate
      @faveDateAfterBox.val klekr.Global.defaultFilters.faveDateAfter

  _setFiltersVisibility: (opts)=>
    this.setVisible(@panel.find('#stream-type-filter-panel'), opts.streamTypeFilter)
    this.setVisible(@panel.find('#rating-filter-panel'), opts.ratingFilter)
    this.setVisible(@panel.find('#faved-at-filter-panel'), opts.favedAtFilter)

  _filterChanged: =>
    this.trigger('changed', this.filterSettings())


  show: => this.fadeInOut(@panel, true)
  hide: => this.fadeInOut(@panel, false)

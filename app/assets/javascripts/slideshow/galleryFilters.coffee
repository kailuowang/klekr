class window.GalleryFilters extends ViewBase
  constructor: ->
    @panel = $('#slide-options .filters')
    @ratingFilter = $('#rating-filter-select')
    @typeCheckBox = $('#type-filter-checkbox')
    @faveDateBox = @panel.find('#fave-at-date')
    @typeCheckBox.change? this._filterChanged
    @ratingFilter.change? this._filterChanged
    @faveDateBox.bind('change', this._filterChanged)
    this._setFiltersVisibility(klekr.Global.filtersOpts || {})
    @panel.find('.datepicker').simpleDatepicker()
    this._applyDefaultFitlers()

  filterSettings: =>
    settings = {}
    settings.type = 'UploadStream' if @typeCheckBox.attr('checked')
    settings.rating = @ratingFilter[0].selectedIndex + 1 if @ratingFilter.length > 0 and @ratingFilter[0].selectedIndex > 0
    settings.faveDate = @faveDateBox.val() if @faveDateBox.length > 0 and @faveDateBox.val().length > 0
    settings

  _applyDefaultFitlers: =>
    if klekr.Global.defaultFilters?
       @ratingFilter[0].selectedIndex = klekr.Global.defaultFilters.rating - 1


  _setFiltersVisibility: (opts)=>
    this.setVisible(@panel.find('#stream-type-filter-panel'), opts.streamTypeFilter)
    this.setVisible(@panel.find('#rating-filter-panel'), opts.ratingFilter)
    this.setVisible(@panel.find('#faved-at-filter-panel'), opts.favedAtFilter)

  _filterChanged: =>
    this.trigger('changed', this.filterSettings())


  show: => this.fadeInOut(@panel, true)
  hide: => this.fadeInOut(@panel, false)



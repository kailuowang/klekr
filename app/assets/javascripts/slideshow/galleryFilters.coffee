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

  _setFiltersVisibility: (opts)=>
    this.setVisible(@panel.find('#stream-type-filter-panel'), opts.streamTypeFilter)
    this.setVisible(@panel.find('#rating-filter-panel'), opts.ratingFilter)
    this.setVisible(@panel.find('#faved-at-filter-panel'), opts.favedAtFilter)


  _filterChanged: =>
    this.trigger('changed', this.filterSettings())

  filterSettings: =>
    {
      type: if @typeCheckBox.attr('checked') then 'UploadStream' else null
      rating: if @ratingFilter[0].selectedIndex > 0 then @ratingFilter[0].selectedIndex + 1 else null
      faveDate: @faveDateBox.val()
    }

  show: => this.fadeInOut(@panel, true)
  hide: => this.fadeInOut(@panel, false)



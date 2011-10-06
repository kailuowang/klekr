class window.RatingFilterView extends ViewBase
  constructor: (attachedMode)->
    @ratingFilter = $('#rating_filter')
    @filtersPanel = $('#rating-filter-panel')
    attachedMode.bind 'on', this.show
    attachedMode.bind 'off', this.hide

  filterChange: (handler) =>
    @ratingFilter.change? (e)=>
      newRatingFilter = e.currentTarget.selectedIndex + 1
      handler(newRatingFilter)

  show: => this.fadeInOut(@filtersPanel, true)
  hide: => this.fadeInOut(@filtersPanel, false)



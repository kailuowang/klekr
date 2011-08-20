class window.FilterView extends ViewBase
  constructor: (attachedMode)->
    @ratingFilter = $('#rating_filter')
    @filtersPanel = $('#filtersPanel')
    attachedMode.bind 'on', this.show
    attachedMode.bind 'off', this.hide

  ratingFilterChange: (handler) =>
    @ratingFilter.change? (evt)=>
      newRatingFilter = evt.currentTarget.selectedIndex + 1
      handler(newRatingFilter)

  show: => this.fadeInOut(@filtersPanel, true)
  hide: => this.fadeInOut(@filtersPanel, false)



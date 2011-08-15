class window.FilterView
  constructor: ->
    @ratingFilter = $('#rating_filter')

  ratingFilterChange: (handler) =>
    @ratingFilter.change? (evt)=>
      newRatingFilter = evt.currentTarget.selectedIndex + 1
      handler(newRatingFilter)

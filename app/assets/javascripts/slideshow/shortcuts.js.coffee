window.bindKeys = ->
  next = () -> slideshow.navigateToNext()
  previous = () -> slideshow.navigateToPrevious()

  $(document).bind('keydown', 'space', next)
  $(document).bind('keydown', 'n', next)
  $(document).bind('keydown', 'right', next)
  $(document).bind('keydown', 'left', previous)
#  $(document).bind('keydown', 'f', -> $('#fave').click())
#  $(document).bind('keydown', 'o', -> go_link($('#owner')))


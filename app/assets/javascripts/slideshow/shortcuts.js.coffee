window.bindKeys = ->
  next = () -> slideshow.navigateToNext()
  previous = () -> slideshow.navigateToPrevious()
  bindKey = (key, func) -> $(document).bind('keydown', key, func)

  bindKey('space', next)
  bindKey('n', next)
  bindKey('right', next)
  bindKey('left', previous)
  bindKey('b', previous)
  bindKey('f', -> slideshow.faveCurrentPicture())
  bindKey('o', -> view.gotoOwner())


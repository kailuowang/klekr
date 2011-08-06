class window.KeyShortcuts
  constructor: ->
    this.bindKeys()
    this.registerPopup()

  bindKeys: ->
    next =  slideshow.navigateToNext
    previous =  slideshow.navigateToPrevious
    bindKey = (key, func) -> $(document).bind('keydown', key, func)

    bindKey 'right', next
    bindKey 'left', previous

    bindKey 'f', ->
      if view.faveOperationVisible()
        slideshow.faveCurrentPicture()

    bindKey 'o', view.gotoOwner
    bindKey 'g', view.toggleGridview

    bindKey 'space', ->
      if view.inGridview()
        view.toggleGridview()
      else
        next()

    bindKey 'return', view.toggleGridview

  registerPopup: ->
    $('#keyShortcutsLink').click ->
      $('#keyShortcuts').bPopup()
      false

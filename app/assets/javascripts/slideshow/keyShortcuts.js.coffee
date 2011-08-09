class window.KeyShortcuts
  constructor: ->
    this.bindKeys()
    this.registerPopup()

  bindKeys: ->
    bindKey = (key, func) -> $(document).bind('keydown', key, func)

    bindKey 'right', gallery.next
    bindKey 'left', gallery.previous

    bindKey 'f', gallery.currentMode.faveCurrentPicture

    bindKey 'o', view.gotoOwner

    bindKey 'g', gallery.toggleMode
    bindKey 'return', gallery.toggleMode

#
#    bindKey 'space', ->
#      if view.inGridview()
#        view.toggleGridview()
#      else
#        next()


  registerPopup: ->
    $('#keyShortcutsLink').click ->
      $('#keyShortcuts').bPopup()
      false

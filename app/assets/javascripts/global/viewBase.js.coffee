class window.ViewBase
  setVisible: (element, visible) ->
    if(visible)
       element.show()
    else
       element.hide()

  fadeInOut: (element, visible) ->
    if(visible)
      element.fadeIn(100)
    else
      element.fadeOut(100)

  popup: (div)->
    div.bPopup({
      onOpen: keyShortcuts.disable
      onClose: keyShortcuts.enable
    })


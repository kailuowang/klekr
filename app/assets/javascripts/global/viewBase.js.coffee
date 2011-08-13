class window.ViewBase
  @showingPopup: false

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

  popup: (div, opts = {})->
    div.bPopup({
      onOpen: =>
        ViewBase.showingPopup = true
        opts.onOpen?()
      onClose: =>
        ViewBase.showingPopup = false
        opts.onClose?()
    })

  closePopup: (div) ->
    div.bPopup().close()

  showing: (elem) ->
    elem.is(':visible')



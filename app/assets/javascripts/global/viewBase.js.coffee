class window.ViewBase extends Events
  @showingPopup: false
  $.fx.interval = 50;
  @isHoneycomb: $(window).width() is 980

  isHoneycomb: -> ViewBase.isHoneycomb

  setVisible: (element, visible) ->
    if(visible)
       element.show()
    else
       element.hide()

  fadeInOut: (element, visible, callback) ->
    if this.isHoneycomb()
      this.setVisible(element, visible)
      callback?()
    else
      this._animateVisible(element, visible, callback)

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

  honeycombAdjustedDimension:  =>
    if this.isHoneycomb()
      [1280, 756]
    else
      [$(window).width(), $(window).height()]

  _animateVisible: (element, visible, callback) ->
    if(visible)
      element.fadeIn(100, callback)
    else
      element.fadeOut(100, callback)

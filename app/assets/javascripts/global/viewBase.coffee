class window.ViewBase extends Events
  @showingPopup: false
  $.fx.interval = 40
  @duration = $.fx.interval * 3

  @isMobile: ->
    /iphone|ipad|ipod|android|blackberry|mini|windows\sce|palm/i.test(navigator.userAgent.toLowerCase())

  @adjustBottom: ->

  isMobile: -> ViewBase.isMobile()

  setVisible: (element, visible) ->
    if(visible)
       element.show()
    else
       element.hide()

  fadeInOut: (element, visible, callback) ->
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

  setArtistCollectionLink: (link, picture) =>
    link.attr href: "#{picture.ownerPath}?type=FaveStream"
    link.text "#{picture.ownerName}'s collection."

  windowDimension:  =>
    [$(window).width(), $(window).height()]

  _animateVisible: (element, visible, callback) ->
    if(visible)
      element.fadeIn(ViewBase.duration, callback)
    else
      element.fadeOut(ViewBase.duration, callback)

$ ->
  $.fx.off = ViewBase.isMobile()
  ViewBase.adjustBottom()
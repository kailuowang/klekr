class window.Slideview extends ViewBase

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @slide = $('#slide')
    @bottomLeft = $('#bottomLeft')
    @label = new PictureLabel

    this._adjustImageFrame()

  display: (picture) ->
    if this.showing(@pictureArea)
      this.fadeInOut @pictureArea, false, =>
        this._fadeInto(picture)
    else
      this._fadeInto(picture)

  _fadeInto: (picture) =>
    this.updateDOM(picture)
    this.fadeInOut(@pictureArea, true)

  updateDOM: (picture) ->
    @mainImg.attr('src', picture.url())
    @label.show(picture)

  pictureClick: (callback) =>
    @mainImg.click(callback)

  gotoOwner: (newTab)=>
    ownerUrl = @label.artistLink.attr('href')
    if newTab
      window.open(ownerUrl, '_blank')
    else
      window.location = ownerUrl

  largeWindow: ->
    generalView.displayWidth > 1024 and generalView.displayHeight > 1024

  _adjustImageFrame: ->
    displayHeight = generalView.displayHeight
    $('#imageFrameInner').css('height', (displayHeight - 40) + 'px')

  switchVisible: (showing) =>
    @favePanel ?= $('#fave-panel')

    this.setVisible @favePanel, showing and !klekr.Global.readonly
    this.setVisible @slide, showing
    this.setVisible(@pictureArea, false) unless showing
    if showing then @label.show() else @label.hide()


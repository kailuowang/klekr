class window.Slideview extends ViewBase

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @slide = $('#slide')
    @bottomLeft = $('#bottomLeft')
    @label = new PictureLabel
    this._adjustImageFrame()
    generalView.bind('layout-changed', this._adjustImageFrame)

  display: (picture) =>
    if this.showing(@pictureArea)
      this.fadeInOut @pictureArea, false, =>
        this._fadeInto(picture)
    else
      this._fadeInto(picture)

  _fadeInto: (picture) =>
    this.update(picture)
    this.fadeInOut(@pictureArea, true)
  
  update: (picture) ->
    @mainImg.attr('src', picture.url())
    @mainImg.attr('data-pic-id', picture.id)
    this._updateLabel(picture)

  displayLabel: (picture) =>
    if this.showing(@pictureArea)
       this.fadeInOut @pictureArea, false
    this._updateLabel(picture)

  _updateLabel: (picture) =>
    @label.show(picture)

  pictureClick: (callback) =>
    @mainImg.click(callback)

  gotoOwner: (newTab)=>
    ownerUrl = @label.artistLink.attr('href')
    if newTab
      window.open(ownerUrl, '_blank')
    else
      window.location = ownerUrl

  _adjustImageFrame: ->
    displayHeight = generalView.displayHeight
    $('#imageFrameInner').css('height', (displayHeight - 40) + 'px')

  switchVisible: (showing) =>
    @favePanel ?= $('#fave-panel')

    this.setVisible @favePanel, showing
    this.setVisible @slide, showing
    this.setVisible(@pictureArea, false) unless showing
    if showing then @label.show() else @label.hide()


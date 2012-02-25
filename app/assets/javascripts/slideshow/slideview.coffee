class window.Slideview extends ViewBase

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')
    @slide = $('#slide')
    @bottomLeft = $('#bottomLeft')
    @label = new PictureLabel
    this._adjustImageFrame()
    generalView.bind('layout-changed', this._adjustImageFrame)
    klekr.Global.broadcaster.bind 'picture:data-updated', this._pictureUpdated
    @mainImg.load this._checkImage
    @mainImg.error this._checkImage

  display: (picture) =>
    @picture = picture
    if this.showing(@pictureArea)
      this.fadeInOut @pictureArea, false, =>
        this._fadeInto()
    else
      this._fadeInto()
    generalView.updateModeIndicator(false)

  _pictureUpdated: (picture) =>
    if @picture and picture.id is @picture.id
      this.update()

  _fadeInto:  =>
    this.update()
    this.fadeInOut(@pictureArea, true)
  
  update: () ->
    @mainImg.attr('src', @picture.url()) if @mainImg.attr('src') isnt @picture.url()
    @mainImg.attr('data-pic-id', @picture.id)
    this._updateLabel()

  isShowing: =>
    this.showing(@mainImg)

  _checkImage: =>
    @picture.checkLargeVersionInvalid(@mainImg[0]) if @picture?

  displayLabel:  =>
    if this.showing(@pictureArea)
       this.fadeInOut @pictureArea, false
    this._updateLabel()

  _updateLabel: () =>
    @label.show(@picture)

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


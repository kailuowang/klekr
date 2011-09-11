class window.PictureCellView extends ViewBase
  constructor: (@cellDiv, @picture) ->
    @ratingDiv = @cellDiv.find('#ratingInGrid:first')
    @picture.bind 'highlighted', this._highlight
    @loadingIndicator = @cellDiv.find('#loading-indicator:first')
    this._initDom()
    this._registerEvents()

  setBoarderClasses: (boundaryTypes) =>
    @cellDiv.addClass(c) for c in boundaryTypes

  _registerEvents: =>
    @cellDiv.click => @picture.trigger('clicked', @picture)
    @picture.bind 'fully-ready', =>
      @loadingIndicator.hide()


  _initDom: =>
    @cellDiv.attr('id', this._picId())
    img = @cellDiv.find('#imgItem')
    img.attr('src', @picture.smallUrl())
    this.setVisible(@loadingIndicator, !@picture.ready)
    this._initRating()

  _initRating:  =>
    ratingText = ('★' for i in [0...@picture.data.rating]).join('')
    @ratingDiv.text(ratingText)

  _picId: =>
    'pic-' + @picture.id

  _highlight: =>
    @cellDiv.addClass('highlighted')


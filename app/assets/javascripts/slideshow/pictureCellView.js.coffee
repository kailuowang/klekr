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
    if @picture.faved()
      template = @cellDiv.find('#ratingStarTemplate:first')
      @ratingDiv.append(template.clone()) for i in [1..@picture.data.rating]
      template.remove()
    else
      @ratingDiv.empty()

  _picId: =>
    'pic-' + @picture.id

  _highlight: =>
    @cellDiv.css('background', '#606060')


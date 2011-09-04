class window.PictureCellView extends ViewBase
  constructor: (@cellDiv, @picture) ->
    @ratingDiv = @cellDiv.find('#ratingInGrid:first')
    @picture.bind 'highlighted', this._highlight
    this._initDom()
    @cellDiv.click => @picture.trigger('clicked', @picture)

  setBoarderClasses: (boundaryTypes) =>
    @cellDiv.addClass(c) for c in boundaryTypes

  _initDom: =>
    @cellDiv.attr('id', this._picId())
    @cellDiv.attr('data', @picture.id)
    img = @cellDiv.find('#imgItem')
    img.attr('src', @picture.smallUrl())
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


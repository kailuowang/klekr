class window.PictureCellView extends ViewBase
  constructor: (@cellDiv, @picture) ->
    @ratingDiv = @cellDiv.find('#ratingInGrid:first')
    @loadingIndicator = @cellDiv.find('#loading-indicator:first')
    this._registerEvents()
    this._initDom()

  setBoarderClasses: (boundaryTypes) =>
    @cellDiv.addClass(c) for c in boundaryTypes

  _registerEvents: =>
    @cellDiv.click => @picture.trigger('clicked', @picture)
    @picture.bind 'fully-ready', => @loadingIndicator.hide()
    @picture.bind 'highlighted', this._highlight
    @picture.bind 'data-updated', this._initDom


  _initDom: =>
    @cellDiv.attr('id', this._picId())
    img = @cellDiv.find('#imgItem')
    img.attr('src', @picture.smallUrl())
    this.setVisible(@loadingIndicator, !@picture.ready)
    @cellDiv.find('.hasTwipsy').twipsy();
    this._initRating()

  _initRating:  =>
    ratingText = if @picture.favable()
        ('★' for i in [0...@picture.data.rating]).join('')
      else
        ''
    @ratingDiv.text(ratingText)

  _picId: =>
    'pic-' + @picture.id

  _highlight: =>
    @cellDiv.addClass('highlighted')


class window.Gridview
  constructor: ->
    @template = $('#template')
    @grid = $('#gridPictures')
    this._calculateSize()
    this._adjustWidth()

  itemSelect: (handler)=>
    @itemSelectHandler = handler

  currentSize: =>
    @grid.children().size()

  highlightPicture: (picture) ->
    $('.gridPicture').css('background', '')
    this._highlightPictureDiv $('#' + this._picId(picture)) if picture?

  loadPictures: (pictures) ->
    @grid.empty()
    this.load picture for picture in pictures

  load: (picture) ->
    newItem = this._createPictureItem(picture)
    @grid.append(newItem)
    newItem.show()

  _highlightPictureDiv: (div) ->
    div.css('background', '#606060')

  _calculateSize: ->
    @columns ?= Math.floor( view.displayWidth / 260 )
    @rows ?= Math.floor( view.displayHeight /  270 )
    @size = @columns * @rows

  _createPictureItem: (picture)=>
    item = @template.clone()
    item.attr('id', this._picId(picture))
    img = item.find('#imgItem')
    img.attr('src', picture.smallUrl())
    this._updateRating(picture, item)
    item.click this._itemClickHandler
    item

  _itemClickHandler: (clickEvent) =>
    clickedDiv = $(clickEvent.currentTarget)
    divId = clickedDiv.attr('id')
    picId = parseInt(divId.split('-')[1])
    this._highlightPictureDiv(clickedDiv)
    @itemSelectHandler(picId)

  _updateRating: (picture, itemDiv) =>
    ratingDiv = itemDiv.find('#ratingInGrid').first()
    if picture.faved()
      template = itemDiv.find('#ratingStarTemplate').first()
      ratingDiv.append(template.clone()) for i in [1..picture.data.rating]
      template.remove()
    else
      ratingDiv.empty()

  _picId: (picture) ->
    'pic-' + picture.id

  _adjustWidth: =>
    $('#gridPictures').css('width', @columns * 260 + 'px')
    $('#gridPictures').css('height', @rows * 270 + 'px')


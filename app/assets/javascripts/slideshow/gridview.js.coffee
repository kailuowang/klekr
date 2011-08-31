class window.Gridview extends ViewBase
  constructor: ->
    @template = $('#template')
    @grid = $('#gridPictures')
    @gridview = $('#gridview')
    this._calculateSize()
    this._adjustWidth()

  itemSelect: (handler)=>
    @itemSelectHandler = handler

  currentSize: =>
    @grid.children().size()

  highlightPicture: (picture) ->
    $('.grid-picture').css('background', '')
    this._highlightPictureDiv $('#' + this._picId(picture)) if picture?

  loadPictures: (pictures) ->
    @grid.empty()
    index = 0
    for picture in pictures
      this._load picture, index++

  _load: (picture, index) ->
    newItem = this._createPictureItem(picture, index)
    @grid.append(newItem)
    newItem.show()

  _highlightPictureDiv: (div) ->
    div.css('background', '#606060')

  _calculateSize: ->
    @columns ?= Math.floor( generalView.displayWidth / 260 )
    @rows ?= Math.floor( generalView.displayHeight /  270 )
    @size = @columns * @rows

  _createPictureItem: (picture, index)=>
    item = @template.clone()
    item.addClass(c) for c in this._boarderClasses(index)
    item.attr('id', this._picId(picture))
    item.attr('data', picture.id)
    img = item.find('#imgItem')
    img.attr('src', picture.smallUrl())
    this._updateRating(picture, item)
    item.click this._itemClickHandler
    item

  _boarderClasses: (index) =>
    isTop =  (index) => index < @columns
    isLeft =  (index) => index % @columns is 0

    _([]).tap (classes) =>
      classes.push('top') if isTop(index)
      classes.push('left') if isLeft(index)

  _itemClickHandler: (e) =>
    clickedDiv = $(e.currentTarget)
    picId = clickedDiv.attr('data')
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
    $('#gridPictures').css('width', (@columns * 260 + 1) + 'px')
    $('#gridPictures').css('height',(@rows * 270 + 1) + 'px')
    $('#gridInner').css('height', (generalView.displayHeight - 80) + 'px')

  switchVisible: (showing)=>
    this.setVisible(@gridview, showing)

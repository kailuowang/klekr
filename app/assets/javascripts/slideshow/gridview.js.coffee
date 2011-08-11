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
    this._highlightPictureDiv $('#' + this._picId(picture))

  loadPictures: (pictures) ->
    @grid.empty()
    this.load picture for picture in pictures

  load: (picture) ->
    newItem = this._createPictureItem(picture)
    @grid.append(newItem)
    newItem.show()

  _highlightPictureDiv: (div) ->
    $('.gridPicture').css('background', '')
    div.css('background', '#606060')

  _calculateSize: ->
    @columns ?= Math.floor( view.displayWidth / 260 )
    @rows ?= Math.floor( view.displayHeight / 260 )
    @size = @columns * @rows

  _createPictureItem: (picture)=>
    item = @template.clone()
    item.attr('id', this._picId(picture))
    img = item.find('#imgItem')
    img.attr('src', picture.smallUrl())
    item.click this._itemClickHandler
    item

  _itemClickHandler: (clickEvent) =>
    clickedDiv = $(clickEvent.currentTarget)
    divId = clickedDiv.attr('id')
    picId = parseInt(divId.split('-')[1])
    this._highlightPictureDiv(clickedDiv)
    @itemSelectHandler(picId)

  _picId: (picture) ->
    'pic-' + picture.id

  _adjustWidth: =>
    $('#gridPictures').css('width', @columns * 260 + 'px')


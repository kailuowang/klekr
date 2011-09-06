class window.Gridview extends ViewBase
  constructor: ->
    @template = $('#template')
    @grid = $('#gridPictures')
    @gridview = $('#gridview')
    this._calculateSize()
    this._adjustWidth()

  currentSize: =>
    @grid.children().size()

  highlightPicture: (picture) ->
    $('.grid-picture').css('background', '')
    picture.trigger('highlighted')

  loadPictures: (pictures) ->
    @grid.empty()
    index = 0
    for picture in pictures
      this._load picture, index++

  _load: (picture, index) ->
    item = new PictureCellView(@template.clone(), picture)
    item.setBoarderClasses this._boarderClasses(index)
    @grid.append(item.cellDiv)
    item.cellDiv.show()

  _calculateSize: ->
    @columns ?= Math.floor( generalView.displayWidth / 260 )
    @rows ?= Math.floor( generalView.displayHeight /  270 )
    @size = @columns * @rows

  _createPictureItem: (picture, index)=>

  _boarderClasses: (index) =>
    isTop =  (index) => index < @columns
    isLeft =  (index) => index % @columns is 0

    _([]).tap (classes) =>
      classes.push('top') if isTop(index)
      classes.push('left') if isLeft(index)

  _picId: (picture) ->
    'pic-' + picture.id

  _adjustWidth: =>
    $('#gridPictures').css('width', (@columns * 260 + 1) + 'px')
    $('#gridPictures').css('height',(@rows * 270 + 1) + 'px')
    $('#gridInner').css('height', (generalView.displayHeight - 80) + 'px')

  switchVisible: (showing)=>
    this.setVisible(@gridview, showing)

class window.Gridview extends ViewBase
  constructor: ->
    @template = $('#template')
    @grid = $('#gridPictures')
    @gridview = $('#gridview')
    @loading = @gridview.find('#grid-loading')
    this.initLayout()

  currentSize: =>
    @grid.children().size()

  highlightPicture: (picture) ->
    $('.grid-picture').removeClass('highlighted')
    this._showGrid()
    picture.trigger('highlighted')

  showLoading: =>
    @loading.show()
    @grid.hide()

  loadPictures: (pictures) =>
    @grid.empty()
    this._showGrid()
    index = 0
    for picture in pictures
      this._load picture, index++

  _showGrid: =>
    if this.showing(@loading)
      @loading.hide()
      @grid.show()

  initLayout: =>
    this._calculateSize()
    this._adjustFrame()

  _load: (picture, index) ->
    item = new PictureCellView(@template.clone(), picture)
    item.setBoarderClasses this._boarderClasses(index)
    @grid.append(item.cellDiv)
    item.cellDiv.addClass('grid-index-' + index)
    item.cellDiv.show()

  _calculateSize: ->
    @columns = Math.floor( generalView.displayWidth / 260 )
    @rows = Math.floor( generalView.displayHeight /  270 )
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


  _adjustFrame: =>
    @grid.css('width', (@columns * 260 + 2) + 'px')
    @grid.css('height',(@rows * 270 + 2) + 'px')
    $('#gridInner').css('height', generalView.displayHeight + 'px')

  switchVisible: (showing)=>
    this.setVisible(@gridview, showing)

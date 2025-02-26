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
    # Calculate grid dimensions based on available space
    # Each cell is 260px wide and 270px tall
    cellWidth = 260
    cellHeight = 270
    
    @columns = Math.floor(generalView.displayWidth / cellWidth)
    @rows = Math.floor(generalView.displayHeight / cellHeight)
    
    # Ensure we have at least one row and column
    @columns = Math.max(@columns, 1)
    @rows = Math.max(@rows, 1)
    
    # Calculate the visible height without scrolling
    visibleHeight = $(window).height() - $('.side-nav').offset().top
    visibleRows = Math.floor(visibleHeight / cellHeight)
    
    console.log("Gridview: window dimensions - width: #{generalView.displayWidth}, height: #{generalView.displayHeight}")
    console.log("Gridview: calculated grid size as #{@columns} columns × #{@rows} rows")
    console.log("Gridview: visible height: #{visibleHeight}px, visible rows: #{visibleRows}")
    
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
    cellWidth = 260
    cellHeight = 270
    
    # Calculate the exact width and height needed for the grid
    gridWidth = @columns * cellWidth + 2
    gridHeight = @rows * cellHeight + 2
    
    console.log("Gridview: adjusting frame to width: #{gridWidth}px, height: #{gridHeight}px")
    
    @grid.css('width', gridWidth + 'px')
    @grid.css('height', gridHeight + 'px')
    
    # Set the gridInner height to match the window height
    $('#gridInner').css('height', generalView.displayHeight + 'px')

  switchVisible: (showing)=>
    this.setVisible(@gridview, showing)

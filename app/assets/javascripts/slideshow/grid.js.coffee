class window.Grid

  constructor: ->
    @selectedIndex = 0

  currentPageOfPictures:  =>
    positionInPage = @selectedIndex % gridview.size
    pageStart = @selectedIndex - positionInPage
    pageEnd = pageStart + gridview.size - 1
    gallery.pictures[pageStart..pageEnd]

  loadGridview: =>
    gridview.loadPictures(this.currentPageOfPictures())
    gridview.highlightPicture(this.selectedPicture())

  selectedPicture: =>
    gallery.pictures[@selectedIndex]

  onFirstBatchOfPicturesLoaded: =>
    this.loadGridView()

  currentProgress: =>
    @selectedIndex

  updateProgress: (progress) =>
    @selectedIndex = progress
    this.loadGridview()

  show: =>
    view.showHideGridview(true)
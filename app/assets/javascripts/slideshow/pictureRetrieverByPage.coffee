class window.PictureRetrieverByPage extends PictureRetriever
  _pageOpts: =>
    { num: @pageSize , page: @_currentPage }

  _proceed: =>
    @_currentPage++
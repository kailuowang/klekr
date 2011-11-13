class window.PictureRetrieverByOffset extends PictureRetriever
  constructor: (@_filterOptsFn, @pageSize, @_retrievePath, @_offsetFn) ->
    @_offsetFn ?= this._offsetByPage
    super(@_filterOptsFn, @pageSize, @_retrievePath)

  _pageOpts: =>
    { limit: @pageSize, offset: @_offsetFn() }

  _offsetByPage: =>
    @pageSize * ( @_currentPage - 1 )

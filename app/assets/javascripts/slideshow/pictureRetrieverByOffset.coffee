class window.PictureRetrieverByOffset extends PictureRetriever
  constructor: (@_filterOptsFn, @pageSize, @_retrievePath, @_offsetFn) ->
    super(@_filterOptsFn, @pageSize, @_retrievePath)


  _pageOpts: =>
    { limit: @pageSize, offset: @_offsetFn() }

  _proceed: =>
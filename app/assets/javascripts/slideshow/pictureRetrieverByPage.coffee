class window.PictureRetrieverByPage extends PictureRetriever
  constructor: (@_filterOptsFn, @pageSize, @_retrievePath) ->
    super(@_filterOptsFn, @pageSize, @_retrievePath)
    
  _pageOpts: =>
    # Add real_time: true to force retrieving from Flickr API rather than database
    { num: @pageSize, page: @_currentPage, real_time: true }

class window.PictureRetriever extends Events
  constructor: (@pageNumber, @pageSize, @filterOpts) ->

  retrieve: (callback) =>
    if callback?
      this.bind('retrieved', callback)
    else
      opts =  $.extend({ num: @pageSize, page: @pageNumber }, @filterOpts)
      server.morePictures opts, (data) =>
        pictures = ( new Picture(picData) for picData in data )
        this.trigger('retrieved', pictures)
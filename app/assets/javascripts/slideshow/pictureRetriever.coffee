class window.PictureRetriever extends Events
  constructor: (@pageNumber, @pageSize, @filterOpts) ->
    @_numOfSubBatches = 2
    @morePicturesPath = __morePicturesPath__

  retrieve: =>
    this._retrieveBatch 1, (retrievedInFirst) =>
      if retrievedInFirst.length > 0
        this.trigger('first-batch-retrieved')
        this._retrieveBatch 2, (retrievedInSecond) =>
          this.trigger('done-retrieving')
      else
        this.trigger('done-retrieving')

  _retrieveBatch: (batchNum, success) =>
    opts = this._batchOpts( @_numOfSubBatches * @pageNumber + batchNum )
    server.post @morePicturesPath, opts, (data) =>
      pictures = ( new Picture(picData) for picData in data )
      if pictures.length > 0
        this.trigger('batch-retrieved', pictures)
      success?(pictures)

  _batchOpts: (page)=>
    batchSize = @pageSize / @_numOfSubBatches
    $.extend({ num: batchSize , page: page }, @filterOpts)




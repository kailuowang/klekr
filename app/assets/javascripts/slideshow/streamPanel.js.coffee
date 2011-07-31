class window.StreamPanel
  constructor: ->
    @startCollectingLink = $('#startCollecting')
    @stopCollectingLink = $('#stopCollecting')
    @noncollectingOperationDiv = $('#noncollectingStreamOperations')
    @collectingOperationDiv = $('#collectingStreamOperations')

    @startCollectingLink.bind 'ajax:success', =>
      @noncollectingOperationDiv.hide()
      @collectingOperationDiv.show()


    @stopCollectingLink.bind 'ajax:success', =>
      @noncollectingOperationDiv.show()
      @collectingOperationDiv.hide()
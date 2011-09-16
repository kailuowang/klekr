class window.StreamPanel
  constructor: ->
    @startCollectingLink = $('#startCollecting')
    @stopCollectingLink = $('#stopCollecting')
    @noncollectingOperationDiv = $('#noncollectingStreamOperations')
    @collectingOperationDiv = $('#collectingStreamOperations')
    @rating = @collectingOperationDiv.find('#rating')

    @startCollectingLink.bind 'ajax:success', =>
      @noncollectingOperationDiv.hide()
      @collectingOperationDiv.show()

    @stopCollectingLink.bind 'ajax:success', =>
      @noncollectingOperationDiv.show()
      @collectingOperationDiv.hide()

    @collectingOperationDiv.find('.rating-adjustment-link').bind 'ajax:success', (e, newRating) =>
      @rating.text(newRating)
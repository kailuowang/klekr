class window.StreamPanel extends ViewBase
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

    @alternativeLink ?= $('#alternative-stream')
    windowTooSmall =  @alternativeLink.width() >  ($(window).width() / 3.3)
    this.setVisible(@alternativeLink, !windowTooSmall)

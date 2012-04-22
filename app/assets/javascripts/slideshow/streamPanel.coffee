class window.StreamPanel extends ViewBase
  constructor: ->
    @startCollectingLink = $('#startCollecting')
    @stopCollectingLink = $('#stopCollecting')
    @noncollectingOperationDiv = $('#noncollectingStreamOperations')
    @collectingOperationDiv = $('#collectingStreamOperations')
    @rating = @collectingOperationDiv.find('#rating')
    @sourceAddedPopup = $('#source-added-popup')

    $('#source-added-popup #okay').click =>
      this.closePopup @sourceAddedPopup

    this._bindCollectingOperations()
    this._bindAdjustmentLinks()
    this._displayAlternativeLink()

  _bindCollectingOperations: =>
    @startCollectingLink.bind 'ajax:success', =>
      @noncollectingOperationDiv.hide()
      @collectingOperationDiv.show()
      this.popup(@sourceAddedPopup)

    @stopCollectingLink.bind 'ajax:success', =>
      @noncollectingOperationDiv.show()
      @collectingOperationDiv.hide()

  _bindAdjustmentLinks: =>
    adjustmentLinks = @collectingOperationDiv.find('.rating-adjustment-link')

    adjustmentLinks.bind 'ajax:success', (e, newRating) =>
      @rating.text(newRating)
      adjustmentLinks.removeClass('disabled')

    adjustmentLinks.click (e) =>
      if $(e.target).hasClass('disabled')
        false
      else
        adjustmentLinks.addClass('disabled')
        true


  _displayAlternativeLink: =>
    alternativeLink = $('#alternative-stream')
    windowTooSmall =  alternativeLink.width() > ($(window).width() / 3.3)
    this.setVisible(alternativeLink, !windowTooSmall)

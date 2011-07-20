class window.View

  constructor: () ->
    @mainImg = $('#picture')

  display: (picture) ->
    $('#loading').hide()
    @mainImg.attr('src', picture.url())
    @mainImg.fadeIn('slow')

  nextClicked: (listener) ->
    $('#right').click(listener)

class window.View

  constructor () ->
    @mainImg = $('#picture')

  display: (picture) ->
    @mainImg.attr('src', picture.url())

  nextClicked: (listener) ->
    $('$right').click(listener)

class window.View

  constructor: () ->
    @mainImg = $('#picture')
    @pictureArea = $('#pictureArea')

  display: (picture) ->
    @pictureArea.fadeOut(100, =>
      @mainImg.attr('src', picture.url())
    )
    @pictureArea.fadeIn(100)

  updateNavigation: () ->


  nextClicked: (listener) ->
    $('#right').click(listener)

  previousClicked: (listener) ->
    $('#left').click(listener)

class window.Gridview
  constructor: ->
    @template = $('#template')
    @grid = $('#gridPictures')
    @size = 10

  loadPictures: (pictures) ->
    @grid.html('')
    this.load picture for picture in pictures

  load: (picture) ->
    newItem = @template.clone()
    newItem.attr('id', this.picId(picture))
    img = $(newItem.find('#imgItem').first())
    img.attr('src', picture.smallUrl())
    @grid.append(newItem)
    newItem.show()

  highlightPicture: (picture) ->
    $('.gridPicture').css('background', '')
    $('#' + this.picId(picture)).css('background', '#606060')

  picId: (picture) ->
    'pic' + picture.id

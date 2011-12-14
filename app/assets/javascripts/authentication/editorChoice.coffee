class klekr.EditorChoice extends ViewBase
  constructor: ->
    @div = $('#editor-choice')
    @template = @div.find('#picture-template .picture-cell')
    @grid = @div.find('#picture-grid')
    @cellStyles = ['left', 'center', 'right']

  load: =>
    klekr.Global.server.get editor_choice_pictures_slideshow_path(), {page: 1, num: 6}, this._render

  _render: (pictures)=>
    index = 0
    for picture in pictures
      newCell = @template.clone()
      img = newCell.find('#picture-link img')
      img.attr('src', picture.thumbUrl)
#      newCell.addClass(@cellStyles[index % 3])
      index += 1
      @grid.append(newCell)
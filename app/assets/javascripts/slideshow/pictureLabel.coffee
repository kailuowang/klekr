class window.PictureLabel extends ViewBase
  constructor: ->
    @panel = $('#picture-label')
    new CollapsiblePanel(@panel.find('#collapsible'), @panel.find('#expand-link'), ['[+]', '[-]'])

  show: (picture)=>
    this._updateDom(picture) if picture?
    @panel.show()

  hide: => @panel.hide()

  _updateDom: (picture)=>
    @artistLink ?= @panel.find('#artist-link')
    @artistLink.attr('href', picture.ownerPath)
    @artistLink.text(picture.ownerName)
    @titleLink ?= @panel.find('#title-link')
    @titleLink.attr('href', picture.flickrPageUrl)
    @titleLink.text picture.displayTitle()
    @date ?= @panel.find('#title #date')
    @date.text(picture.dateUpload.substr(0,7).replace('-','/') )

    @interestingess ?= @panel.find('#interestingess-num')
    @interestingess.text picture.interestingness
    this._updateSources(picture.fromStreams)

  _updateSources: (streams) ->
    @sources ?= @panel.find('#sources')
    @sourcesLinks ?= @sources.find('#sources-links')
    @sourcesLinks.empty()
    for stream in streams
      @sourcesLinks.append($('<span>').text(', ')) if @sourcesLinks.children().length > 0
      link = $('<a>').attr('href', stream.path).text(stream.username + "'s " + stream.type)
      @sourcesLinks.append(link)
    this.setVisible(@sources, streams.length > 0 )




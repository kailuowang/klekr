class window.PictureLabel extends ViewBase
  constructor: ->
    @panel = $('#picture-label')
    @expandLink =  @panel.find('#expand-link')
    @expandLink.click @_toggleSecondRow
    new CollapsiblePanel(@panel.find('#collapsible'), @expandLink, ['[+]', '[-]'])

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
    @titleLink.text picture.data.title
    @flickrLink ?= @panel.find('#flickr-link')
    @flickrLink.attr('href', picture.flickrPageUrl)

    this._updateDescription(picture)

    @date ?= @panel.find('#title #date')
    @date.text(picture.dateUpload.substr(0,7).replace('-','/') )
    @artistCollectionLink ?= @panel.find('#artist-collection')
    this.setArtistCollectionLink(@artistCollectionLink, picture)
    @interestingess ?= @panel.find('#interestingess-num')
    @interestingess.text picture.interestingness
    @interestingessDisplay ?= @panel.find('#interestingness')
    this.setVisible @interestingessDisplay, (picture.interestingness isnt 0)
    this.setVisible $('#personalized-info'), !klekr.Global.anonymous?

    this._updateSources(picture.fromStreams)
    @relatedPanel ?= @panel.find('#related-pictures')

    this.setVisible(@relatedPanel, !picture.noLongerValid)
    this.setVisible(@interestingess, !picture.noLongerValid)


  _toggleSecondRow: =>
    $("#second-row").toggleClass("override-hidden")

  expand: =>
    @expandLink.trigger('click')

  _updateDescription: (picture) =>
    @description ?= @panel.find('#description')
    @description.html(picture.description)
    this.setVisible(@description, picture.description? and picture.description.length > 1)

  _updateSources: (streams) ->
    @sources ?= @panel.find('#sources')
    @sourcesLinks ?= @sources.find('#sources-links')
    @sourcesLinks.empty()
    collectionStreams = (stream for stream in streams when stream.type isnt 'Works')

    for stream in collectionStreams
      @sourcesLinks.append($('<span>').text(', ')) if @sourcesLinks.children().length > 0
      link = $('<a>').attr('href', stream.path).text(stream.username)
      @sourcesLinks.append(link)
    this.setVisible(@sources, collectionStreams.length > 0 )




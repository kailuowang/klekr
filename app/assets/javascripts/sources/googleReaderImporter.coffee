class window.GoogleReaderImporter extends ViewBase
  constructor: ->
    @_popup = $('#import-google-reader-popup')
    @file = @_popup.find('#google-reader-file')
    @doImportLink = @_popup.find('#do-import')
    @progressPanel = @_popup.find('#import-progress')
    @progressBar = @_popup.find('#progress-bar')
    @startImportLink = $('#import-google-reader-link')
    @hintPanel = @_popup.find('#hint')
    this._registerEvents()

  _init: =>
    @progressPanel.hide()
    this.popup @_popup

  _import: =>
    @hintPanel.hide()
    f = @file[0].files[0];
    if f?
      reader = new FileReader()
      reader.onload = (e) =>
        subscriptions = this._importText(e.target.result.toString())
        this._importSubscriptions(subscriptions)
      reader.readAsText(f)

  _registerEvents: =>
    @startImportLink.click this._init
    @doImportLink.click this._import
    @_popup.find('#hint-link').click => @hintPanel.slideToggle()

  _importText: (text) =>
    reg = /title="(.+)"\s.+\n.+photos\_(.+)\.gne\?.?.?id=(\d+@...)&amp/gm;
    while ((match = reg.exec(text)) != null )
      this._createSubscription(match)

  _createSubscription: (match) =>
    {
      username: this._getUserFromTitle(match[1])
      user_id: match[3]
      type: this._getType(match[2])
    }

  _getType: (readerType) =>
    switch readerType
      when 'faves' then 'FaveStream'
      when 'public' then 'UploadStream'

  _getUserFromTitle: (title) =>
    title.replace('Uploads from ', '').replace("s' favorites", '').replace("'s favorites", '')

  _importSubscriptions: (subs) =>

    @progressPanel.show()
    this._reportProgress(0, subs.length)
    new queffee.CollectionWorkQ(
      collection: subs
      operation: this._importSubscription
      onProgress: (progress) =>
        this._reportProgress(progress, subs.length)
      onFinish: this._finish
    ).start()

  _reportProgress: (progress, total)=>
    @progressBar.reportprogress(progress * 100 / total)

  _importSubscription: (subscription, callback) =>
    server.post flickr_streams_path(), subscription, callback

  _finish: =>
    this.closePopup(@_popup)
    this.trigger('imported')
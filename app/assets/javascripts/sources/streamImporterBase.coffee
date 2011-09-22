class window.StreamImporterBase extends ViewBase
  _import: (streamInfo, callback) =>
    klekr.Global.server.post flickr_streams_path(), streamInfo, (newSources) =>
      this.trigger('sources-imported', newSources)
      callback()

  _finish: =>
    this.closePopup(@_popup)
    this.trigger('import-finished')



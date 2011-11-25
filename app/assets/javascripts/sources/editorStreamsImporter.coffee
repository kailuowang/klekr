class window.EditorStreamsImporter extends  klekr.FlexibleStreamsImporterBase
  constructor: ->
    super('#import-editor-streams-popup', '#add-editor-streams-link')

  _importSourcesUrl: =>
    editor_recommendations_path()




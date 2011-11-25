class klekr.GroupStreamsImporter  extends  klekr.FlexibleStreamsImporterBase
  constructor: ->
    super('#import-group-streams-popup', '#add-group-streams-link')

  _importSourcesUrl: =>
    collector_group_streams_path({collector_id: klekr.Global.currentCollector.id})
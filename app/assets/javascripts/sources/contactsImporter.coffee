class klekr.ContactsImporter extends klekr.FlexibleStreamsImporterBase
  constructor: ->
     super('#import-contacts-popup', '#add-contacts-link')

  _importSourcesUrl: =>
    contacts_users_path()

class window.ContactsImporter extends StreamImporterBase
  constructor: (@contactsPath, @importContactPath)->
    @contactsList = $('#contacts-list')
    @displayContacts = $('#display-contacts')
    @loading = $('#loading-contacts')
    @_popup = $('#import-popup')
    @progressBar = $('#import-popup #progress-bar')
    @importProgress = $('#import-popup #import-progress')
    @importLink = $('#do-import-contacts')
    @importLink.click_ this._startImport
    @noContacts = $('#no-contact')

    $('#add-contracts-link').click_ this._start

  _start: =>
    @importLink.show()
    @importProgress.hide()
    @noContacts.hide()
    @displayContacts.hide()
    @loading.show()
    this.popup @_popup
    this._getContacts()

  _getContacts: =>
    server.get @contactsPath, {}, (data) =>
      @contacts = data
      @total = @contacts.length
      @loading.fadeOut this._displayContacts

  _displayContacts: =>
    if @contacts.length > 0
      names = (contact.username for contact in @contacts)
      @contactsList.text(names.join(', '))
      $('#num-of-contacts').text(names.length)
      @displayContacts.fadeIn()
    else
      @noContacts.fadeIn()

  _startImport: =>
    @importLink.hide()
    @importProgress.fadeIn()
    this._importContacts();

  _importContacts: =>
    this._reportProgress(0)
    new queffee.CollectionWorkQ(
      collection: @contacts
      operation: (streamInfo, callback) => this._import(streamInfo, callback)
      onProgress: this._reportProgress
      onFinish: => this._finish()
    ).start()

  _reportProgress: (progress)=>
    @progressBar.reportprogress(progress * 100 / @contacts.length)


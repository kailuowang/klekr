class window.ContactsImporter extends ViewBase
  constructor: (@contactsPath, @importContactPath)->
    @contactsList = $('#contacts-list')
    @displayContacts = $('#display-contacts')
    @loading = $('#loading-contacts')
    @importPopup = $('#import-popup')
    @progressBar = $('#import-popup #progress-bar')
    @importProgress = $('#import-popup #import-progress')
    @importLink = $('#do-import-contacts')
    @importLink.click this._startImport

    $('#add-contracts-link').click =>
      @importLink.show()
      @importProgress.hide()
      this.popup @importPopup
      this._getContacts()

  _getContacts: =>
    server.get @contactsPath, {}, (data) =>
      @contacts = data
      @total = @contacts.length
      @loading.fadeOut this._displayContacts

  _displayContacts: =>
    names = (contact.username for contact in @contacts)
    @contactsList.text(names.join(', '))
    $('#num-of-contacts').text(names.length)
    @displayContacts.fadeIn()

  _startImport: =>
    @importLink.hide()
    @importProgress.fadeIn()
    this._importContacts();

  _importContacts: =>
    this._reportProgress(0)
    new queffee.CollectionWorkQ(
      collection: @contacts
      operation: this._import
      onProgress: this._reportProgress
      onFinish: this._finish
    ).start()

  _reportProgress: (progress)=>
    @progressBar.reportprogress(progress * 100 / @contacts.length)

  _import: (contact, callback) =>
    server.post @importContactPath, contact, callback

  _finish: =>
    this.closePopup(@importPopup)
    this.trigger('imported')
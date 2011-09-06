class window.ContactsImporter extends ViewBase
  constructor: (@contactsPath, @importContactPath)->
    @contactsList = $('#contacts-list')
    @displayContacts = $('#display-contacts')
    @loading = $('#loading-contacts')
    @importPopup = $('#import-popup')
    @progressBar = $('#progress-bar')
    @importLink = $('#do-import-contacts')
    @importLink.click => this._startImport(); false

    $('#add-contracts-link').click =>
      @importLink.show()
      $('#import-progress').hide()
      this.popup @importPopup
      this._getContacts()
      false

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
    $('#import-progress').fadeIn()
    this._importContacts();

  _importContacts: =>
    this._reportProgress(0)
    new quefee.CollectionWorkQ(
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
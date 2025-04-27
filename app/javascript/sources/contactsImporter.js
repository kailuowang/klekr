import FlexibleStreamsImporterBase from './flexibleStreamsImporterBase';

/**
 * Importer for contacts' streams
 * @extends FlexibleStreamsImporterBase
 */
class ContactsImporter extends FlexibleStreamsImporterBase {
  /**
   * Creates a new ContactsImporter
   */
  constructor() {
    super('#import-contacts-popup', '#add-contacts-link');
  }

  /**
   * Returns the URL for importing contacts
   * @returns {string} URL for contacts import
   * @private
   */
  _importSourcesUrl = () => {
    return contacts_users_path();
  }
}

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.ContactsImporter = ContactsImporter;

export default ContactsImporter;
import StreamImporterBase from './streamImporterBase';

/**
 * Importer for Google Reader subscriptions
 * @extends StreamImporterBase
 */
class GoogleReaderImporter extends StreamImporterBase {
  /**
   * Creates a new GoogleReaderImporter
   */
  constructor() {
    super();
    this._popup = $('#import-google-reader-popup');
    this.file = this._popup.find('#google-reader-file');
    this.doImportLink = this._popup.find('#do-import');
    this.progressPanel = this._popup.find('#import-progress');
    this.progressBar = this._popup.find('#progress-bar');
    this.startImportLink = $('#import-google-reader-link');
    this.hintPanel = this._popup.find('#hint');
    this._registerEvents();
  }

  /**
   * Initializes the importer
   * @private
   */
  _init = () => {
    this.progressPanel.hide();
    this.popup(this._popup);
  }

  /**
   * Imports all subscriptions from the uploaded file
   * @private
   */
  _importAll = () => {
    this.hintPanel.hide();
    const f = this.file[0].files[0];
    
    if (f) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const subscriptions = this._importText(e.target.result.toString());
        this._importSubscriptions(subscriptions);
      };
      reader.readAsText(f);
    }
  }

  /**
   * Registers event handlers
   * @private
   */
  _registerEvents = () => {
    this.startImportLink.click_(this._init);
    this.doImportLink.click_(this._importAll);
    this._popup.find('#hint-link').click_(() => this.hintPanel.slideToggle());
  }

  /**
   * Extracts subscriptions from the imported text
   * @param {string} text - The text to parse
   * @returns {Array<Object>} Extracted subscriptions
   * @private
   */
  _importText = (text) => {
    const subscriptions = [];
    const reg = /title="(.+)"\s.+\n.+photos\_(.+)\.gne\?.?.?id=(\d+@...)&amp/gm;
    let match;
    
    while ((match = reg.exec(text)) !== null) {
      subscriptions.push(this._createSubscription(match));
    }
    
    return subscriptions;
  }

  /**
   * Creates a subscription object from a regex match
   * @param {Array<string>} match - The regex match result
   * @returns {Object} Subscription information
   * @private
   */
  _createSubscription = (match) => {
    return {
      username: this._getUserFromTitle(match[1]),
      user_id: match[3],
      type: this._getType(match[2])
    };
  }

  /**
   * Maps reader type to stream type
   * @param {string} readerType - The reader type
   * @returns {string} Stream type
   * @private
   */
  _getType = (readerType) => {
    switch (readerType) {
      case 'faves': return 'FaveStream';
      case 'public': return 'UploadStream';
      default: return null;
    }
  }

  /**
   * Extracts username from the title
   * @param {string} title - The subscription title
   * @returns {string} Extracted username
   * @private
   */
  _getUserFromTitle = (title) => {
    return title
      .replace('Uploads from ', '')
      .replace("s' favorites", '')
      .replace("'s favorites", '');
  }

  /**
   * Imports all subscriptions
   * @param {Array<Object>} subs - Subscriptions to import
   * @private
   */
  _importSubscriptions = (subs) => {
    this.progressPanel.show();
    this._reportProgress(0, subs.length);
    
    new queffee.CollectionWorkQ({
      collection: subs,
      operation: (streamInfo, callback) => this._import(streamInfo, callback),
      onFinish: () => this._finish(),
      onProgress: (progress) => {
        this._reportProgress(progress, subs.length);
      }
    }).start();
  }

  /**
   * Reports import progress
   * @param {number} progress - Current progress
   * @param {number} total - Total items to import
   * @private
   */
  _reportProgress = (progress, total) => {
    this.progressBar.reportprogress(progress * 100 / total);
  }
}

// Export for global access (compatibility with existing code)
window.GoogleReaderImporter = GoogleReaderImporter;

export default GoogleReaderImporter;
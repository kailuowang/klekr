import { server } from '../src/global/server';
import Source from './source';
import MySourcesView from './mySourcesView';
import ContactsImporter from './contactsImporter';
import EditorStreamsImporter from './editorStreamsImporter';
import GroupStreamsImporter from './groupStreamsImporter';
import AddByUserImporter from './addByUserImporter';
import GoogleReaderImporter from './googleReaderImporter';

/**
 * Main controller for managing user's sources
 */
class MySources {
  /**
   * Creates a new MySources controller
   */
  constructor() {
    this.contactImporter = new ContactsImporter();
    this.editorStreamsImporter = new EditorStreamsImporter();
    this.groupStreamsImporter = new GroupStreamsImporter();
    this.addByUserImporter = new AddByUserImporter();
    this.googleReaderImporter = new GoogleReaderImporter();
    this.view = new MySourcesView();
    
    this._bindImporterEvents([
      this.addByUserImporter, 
      this.contactImporter, 
      this.editorStreamsImporter, 
      this.googleReaderImporter, 
      this.groupStreamsImporter
    ]);
  }

  /**
   * Initializes the sources view
   * @param {Function} onInit - Callback after initialization
   */
  init = (onInit) => {
    this.view.clear();
    this._loadSource(1, (hasSources) => {
      this.view.onAllSourcesLoaded(!hasSources);
      if (onInit) {
        onInit();
      }
    });
  }

  /**
   * Loads sources from the server
   * @param {number} page - Page number to load
   * @param {Function} onFinish - Callback when loading is complete
   * @private
   */
  _loadSource = (page, onFinish) => {
    server.get(
      my_sources_flickr_streams_path(), 
      { page: page, per_page: 50 }, 
      (data) => {
        const sources = data.map(d => new Source(d));
        this._display(sources);
        
        if (sources.length > 0) {
          this._loadSource(page + 1, onFinish);
        } else {
          if (onFinish) {
            onFinish(page > 1);
          }
        }
      }
    );
  }

  /**
   * Handles source import completion
   * @private
   */
  _sourcesImportDone = () => {
    this.init(() => {
      server.get(
        info_collector_path({ id: 'current' }), 
        {}, 
        (data) => {
          this.view.showNewSourcesAddedPanel(data);
        }
      );
    });
  }

  /**
   * Handles sources being imported
   * @param {Array<Source>} sources - The imported sources
   * @private
   */
  _sourcesImported = (sources) => {
    this.view.onAllSourcesLoaded(false);
    this._display(sources);
  }

  /**
   * Displays sources in the view
   * @param {Array<Source>} sources - Sources to display
   * @private
   */
  _display = (sources) => {
    sources.forEach(source => {
      this.view.addSource(source);
    });
  }

  /**
   * Binds event handlers to importers
   * @param {Array<Object>} importers - Importers to bind events to
   * @private
   */
  _bindImporterEvents = (importers) => {
    importers.forEach(importer => {
      importer.bind('import-finished', this._sourcesImportDone);
      // Temporarily disabled due to scroll bar bug
      // importer.bind('sources-imported', this._sourcesImported);
    });
  }
}

// Initialize on document ready
$(() => {
  new MySources().init();
});

// Export for global access (compatibility with existing code)
window.MySources = MySources;

export default MySources;
import ViewBase from '../src/global/viewBase';
import { server } from '../src/global/server';

/**
 * Base class for stream importers
 * @extends ViewBase 
 */
class StreamImporterBase extends ViewBase {
  /**
   * Imports streams based on provided information
   * @param {Object} streamInfo - Information about the stream to import
   * @param {Function} callback - Callback function after import
   * @private
   */
  _import = (streamInfo, callback) => {
    server.post(flickr_streams_path(), streamInfo, (newSources) => {
      this.trigger('sources-imported', newSources);
      callback();
    });
  }

  /**
   * Finishes the import process
   * @private 
   */
  _finish = () => {
    this.closePopup(this._popup);
    this.trigger('import-finished');
  }
}

// Export for global access (compatibility with existing code)
window.StreamImporterBase = StreamImporterBase;

export default StreamImporterBase;
import FlexibleStreamsImporterBase from './flexibleStreamsImporterBase';
import { currentCollector } from '../global/userInfo';

/**
 * Importer for group streams
 * @extends FlexibleStreamsImporterBase
 */
class GroupStreamsImporter extends FlexibleStreamsImporterBase {
  /**
   * Creates a new GroupStreamsImporter
   */
  constructor() {
    super('#import-group-streams-popup', '#add-group-streams-link');
  }

  /**
   * Returns the URL for importing group streams
   * @returns {string} URL for group streams import
   * @private
   */
  _importSourcesUrl = () => {
    return collector_group_streams_path({collector_id: currentCollector.id});
  }
}

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.GroupStreamsImporter = GroupStreamsImporter;

export default GroupStreamsImporter;
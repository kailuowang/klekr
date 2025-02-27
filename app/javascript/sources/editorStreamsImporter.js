import FlexibleStreamsImporterBase from './flexibleStreamsImporterBase';

/**
 * Importer for editor recommended streams
 * @extends FlexibleStreamsImporterBase
 */
class EditorStreamsImporter extends FlexibleStreamsImporterBase {
  /**
   * Creates a new EditorStreamsImporter
   */
  constructor() {
    super('#import-editor-streams-popup', '#add-editor-streams-link');
  }

  /**
   * Returns the URL for importing editor streams
   * @returns {string} URL for editor streams import
   * @private
   */
  _importSourcesUrl = () => {
    return editor_recommendations_path();
  }
}

// Export for global access (compatibility with existing code)
window.EditorStreamsImporter = EditorStreamsImporter;

export default EditorStreamsImporter;
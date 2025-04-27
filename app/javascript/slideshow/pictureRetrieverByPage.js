/**
 * PictureRetrieverByPage
 * Retrieves pictures using page-based pagination
 */
import PictureRetriever from './pictureRetriever.js';

class PictureRetrieverByPage extends PictureRetriever {
  /**
   * Get page options
   * @returns {Object} - Page options
   * @private
   */
  _pageOpts() {
    return { 
      num: this.pageSize, 
      page: this._currentPage 
    };
  }
}

// Export to global namespace
window.PictureRetrieverByPage = PictureRetrieverByPage;

export default PictureRetrieverByPage;
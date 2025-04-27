import PictureRetriever from './pictureRetriever';

/**
 * Retrieves pictures by page number
 * @extends PictureRetriever
 */
class PictureRetrieverByPage extends PictureRetriever {
  /**
   * Gets page options for retrieval
   * @returns {Object} Page options
   * @private
   */
  _pageOpts = () => {
    return { 
      num: this.pageSize, 
      page: this._currentPage 
    };
  }
}

// Export for global access (compatibility with existing code)
window.PictureRetrieverByPage = PictureRetrieverByPage;

export default PictureRetrieverByPage;
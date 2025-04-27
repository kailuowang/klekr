/**
 * PictureRetrieverByOffset
 * Retrieves pictures using offset-based pagination
 */
import PictureRetriever from './pictureRetriever.js';

class PictureRetrieverByOffset extends PictureRetriever {
  /**
   * Create a PictureRetrieverByOffset
   * @param {Function} filterOptsFn - Function that returns filter options
   * @param {number} pageSize - Number of pictures per page
   * @param {string} retrievePath - Path to retrieve pictures from
   * @param {Function} offsetFn - Function that returns the offset
   */
  constructor(filterOptsFn, pageSize, retrievePath, offsetFn) {
    super(filterOptsFn, pageSize, retrievePath);
    
    // If no offset function is provided, use default
    this._offsetFn = offsetFn || this._offsetByPage.bind(this);
  }

  /**
   * Get page options
   * @returns {Object} - Page options
   * @private
   */
  _pageOpts() {
    return { 
      limit: this.pageSize, 
      offset: this._offsetFn() 
    };
  }

  /**
   * Get offset based on page number
   * @returns {number} - The offset
   * @private
   */
  _offsetByPage() {
    return this.pageSize * (this._currentPage - 1);
  }
}

// Export to global namespace
window.PictureRetrieverByOffset = PictureRetrieverByOffset;

export default PictureRetrieverByOffset;
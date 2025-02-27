import PictureRetriever from './pictureRetriever';

/**
 * Retrieves pictures by offset
 * @extends PictureRetriever
 */
class PictureRetrieverByOffset extends PictureRetriever {
  /**
   * Creates a new PictureRetrieverByOffset
   * @param {Function} filterOptsFn - Function that returns filter options
   * @param {number} pageSize - Number of pictures per page
   * @param {string} retrievePath - Path for retrieving pictures
   * @param {Function} offsetFn - Function that calculates offset
   */
  constructor(filterOptsFn, pageSize, retrievePath, offsetFn) {
    super(filterOptsFn, pageSize, retrievePath);
    this._offsetFn = offsetFn || this._offsetByPage;
  }

  /**
   * Gets page options for retrieval
   * @returns {Object} Page options
   * @private
   */
  _pageOpts = () => {
    return { 
      limit: this.pageSize, 
      offset: this._offsetFn() 
    };
  }

  /**
   * Calculates offset based on page number
   * @returns {number} Calculated offset
   * @private
   */
  _offsetByPage = () => {
    return this.pageSize * (this._currentPage - 1);
  }
}

// Export for global access (compatibility with existing code)
window.PictureRetrieverByOffset = PictureRetrieverByOffset;

export default PictureRetrieverByOffset;
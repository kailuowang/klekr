/**
 * Calculates priorities for picture preloading
 */
class PicturePreloadPriority {
  /**
   * Creates a new PicturePreloadPriority
   * @param {Picture} picture - The picture
   * @param {Gallery} gallery - The gallery
   */
  constructor(picture, gallery) {
    this.picture = picture;
    this.gallery = gallery;
  }

  /**
   * Calculates priority for small version preloading
   * @returns {number} Priority score
   */
  small = () => {
    return 100 + this._pageAdjustmentSmall() + this._positionAdjustment();
  }

  /**
   * Calculates priority for full version preloading
   * @returns {number} Priority score
   */
  full = () => {
    return 0 + this._pageAdjustmentFull() + this._positionAdjustment() + this._positionAdjustmentFull();
  }

  /**
   * Calculates page-based adjustment for small version
   * @returns {number} Adjustment value
   * @private
   */
  _pageAdjustmentSmall = () => {
    const pagesAhead = this._pagesAhead();
    if (pagesAhead < 0) {
      return -500;
    } else if (pagesAhead <= 1) {
      return 200;
    } else {
      return 0;
    }
  }

  /**
   * Calculates page-based adjustment for full version
   * @returns {number} Adjustment value
   * @private
   */
  _pageAdjustmentFull = () => {
    const pagesAhead = this._pagesAhead();
    if (pagesAhead < 0) {
      return -500;
    } else if (pagesAhead === 0) {
      return 200;
    } else {
      return 0;
    }
  }

  /**
   * Calculates how many pages ahead this picture is
   * @returns {number} Pages ahead
   * @private
   */
  _pagesAhead = () => {
    return this.gallery.pageOf(this.picture) - this.gallery.currentPage();
  }

  /**
   * Adjusts priority based on position in view
   * @returns {number} Adjustment value
   * @private
   */
  _positionAdjustment = () => {
    const ahead = this._ahead();
    if (!this.gallery.inGrid() && ahead >= 0 && ahead <= 5) {
      return 1000;
    } else {
      return 0;
    }
  }

  /**
   * Adjusts full version priority based on position
   * @returns {number} Adjustment value
   * @private
   */
  _positionAdjustmentFull = () => {
    const ahead = this._ahead();
    if (ahead >= 0) {
      return this.gallery.pageSize() - ahead;
    } else {
      return ahead;
    }
  }

  /**
   * Calculates how many positions ahead this picture is
   * @returns {number} Positions ahead
   * @private
   */
  _ahead = () => {
    return this.picture.index - this.gallery.currentPicture().index;
  }
}

// Export for global access (compatibility with existing code)
window.PicturePreloadPriority = PicturePreloadPriority;

export default PicturePreloadPriority;
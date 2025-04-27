/**
 * PictureCellView Component
 * Handles the rendering of a single picture in the grid view
 */
import ViewBase from '../src/global/viewBase.js';

class PictureCellView extends ViewBase {
  constructor(cellDiv, picture) {
    super();
    this.cellDiv = cellDiv;
    this.picture = picture;
    this.ratingDiv = this.cellDiv.find('#ratingInGrid:first');
    this.loadingIndicator = this.cellDiv.find('#loading-indicator:first');
    
    // Set up the view
    this._registerEvents();
    this._initDom();
    
    // Bind methods
    this.setBoarderClasses = this.setBoarderClasses.bind(this);
    this._registerEvents = this._registerEvents.bind(this);
    this._initDom = this._initDom.bind(this);
    this._initRating = this._initRating.bind(this);
    this._picId = this._picId.bind(this);
    this._highlight = this._highlight.bind(this);
  }

  /**
   * Set border classes for the cell
   * @param {Array} boundaryTypes - Types of boundaries to set
   */
  setBoarderClasses(boundaryTypes) {
    for (const c of boundaryTypes) {
      this.cellDiv.addClass(c);
    }
  }

  /**
   * Register event handlers
   * @private
   */
  _registerEvents() {
    this.cellDiv.click(() => this.picture.trigger('clicked', this.picture));
    this.picture.on('fully-ready', () => this.loadingIndicator.hide());
    this.picture.on('highlighted', this._highlight);
    this.picture.on('data-updated', this._initDom);
  }

  /**
   * Initialize the DOM elements
   * @private
   */
  _initDom() {
    this.cellDiv.attr('id', this._picId());
    const img = this.cellDiv.find('#imgItem');
    img.attr('src', this.picture.smallUrl());
    this.setVisible(this.loadingIndicator, !this.picture.ready);
    this.cellDiv.find('.hasTwipsy').twipsy();
    this._initRating();
  }

  /**
   * Initialize the rating display
   * @private
   */
  _initRating() {
    let ratingText = '';
    
    if (this.picture.favable()) {
      // Create a string of stars based on rating
      ratingText = '★'.repeat(this.picture.data.rating);
    }
    
    this.ratingDiv.text(ratingText);
  }

  /**
   * Get the picture ID
   * @returns {string} - The picture ID
   * @private
   */
  _picId() {
    return 'pic-' + this.picture.id;
  }

  /**
   * Highlight the cell
   * @private
   */
  _highlight() {
    this.cellDiv.addClass('highlighted');
  }
}

// Export to global namespace
window.PictureCellView = PictureCellView;

export default PictureCellView;
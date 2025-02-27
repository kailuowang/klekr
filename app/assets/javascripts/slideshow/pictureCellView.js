import ViewBase from '../global/viewBase';

/**
 * View for a picture cell in the grid
 * @extends ViewBase
 */
class PictureCellView extends ViewBase {
  /**
   * Creates a new PictureCellView
   * @param {jQuery} cellDiv - The cell element
   * @param {Picture} picture - The picture to display
   */
  constructor(cellDiv, picture) {
    super();
    this.cellDiv = cellDiv;
    this.picture = picture;
    this.ratingDiv = this.cellDiv.find('#ratingInGrid:first');
    this.loadingIndicator = this.cellDiv.find('#loading-indicator:first');
    
    this._registerEvents();
    this._initDom();
  }

  /**
   * Sets border classes for the cell
   * @param {Array<string>} boundaryTypes - Border classes to add
   */
  setBoarderClasses = (boundaryTypes) => {
    boundaryTypes.forEach(c => {
      this.cellDiv.addClass(c);
    });
  }

  /**
   * Registers event handlers
   * @private
   */
  _registerEvents = () => {
    this.cellDiv.click(() => {
      this.picture.trigger('clicked', this.picture);
    });
    
    this.picture.bind('fully-ready', () => {
      this.loadingIndicator.hide();
    });
    
    this.picture.bind('highlighted', this._highlight);
    this.picture.bind('data-updated', this._initDom);
  }

  /**
   * Initializes the DOM elements
   * @private
   */
  _initDom = () => {
    this.cellDiv.attr('id', this._picId());
    
    const img = this.cellDiv.find('#imgItem');
    img.attr('src', this.picture.smallUrl());
    
    this.setVisible(this.loadingIndicator, !this.picture.ready);
    this.cellDiv.find('.hasTwipsy').twipsy();
    
    this._initRating();
  }

  /**
   * Initializes the rating display
   * @private
   */
  _initRating = () => {
    let ratingText = '';
    
    if (this.picture.favable()) {
      ratingText = Array(this.picture.data.rating).fill('★').join('');
    }
    
    this.ratingDiv.text(ratingText);
  }

  /**
   * Gets the picture ID
   * @returns {string} Picture ID
   * @private
   */
  _picId = () => {
    return 'pic-' + this.picture.id;
  }

  /**
   * Highlights the cell
   * @private
   */
  _highlight = () => {
    this.cellDiv.addClass('highlighted');
  }
}

// Export for global access (compatibility with existing code)
window.PictureCellView = PictureCellView;

export default PictureCellView;
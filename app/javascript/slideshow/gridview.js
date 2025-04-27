/**
 * Gridview Component
 * Handles the grid view display of pictures
 */
import ViewBase from '../src/global/viewBase.js';
import PictureCellView from './pictureCellView.js';

class Gridview extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
    this.template = $('#template');
    this.grid = $('#gridPictures');
    this.gridview = $('#gridview');
    this.loading = this.gridview.find('#grid-loading');
    
    // Initialize layout
    this.initLayout();
    
    // Bind methods
    this.currentSize = this.currentSize.bind(this);
    this.highlightPicture = this.highlightPicture.bind(this);
    this.showLoading = this.showLoading.bind(this);
    this.loadPictures = this.loadPictures.bind(this);
    this._showGrid = this._showGrid.bind(this);
    this.initLayout = this.initLayout.bind(this);
    this._load = this._load.bind(this);
    this._calculateSize = this._calculateSize.bind(this);
    this._createPictureItem = this._createPictureItem.bind(this);
    this._boarderClasses = this._boarderClasses.bind(this);
    this._picId = this._picId.bind(this);
    this._adjustFrame = this._adjustFrame.bind(this);
    this.switchVisible = this.switchVisible.bind(this);
  }

  /**
   * Get the current number of pictures in the grid
   * @returns {number} - The number of pictures
   */
  currentSize() {
    return this.grid.children().size();
  }

  /**
   * Highlight a picture in the grid
   * @param {Picture} picture - The picture to highlight
   */
  highlightPicture(picture) {
    $('.grid-picture').removeClass('highlighted');
    this._showGrid();
    picture.trigger('highlighted');
  }

  /**
   * Show the loading indicator
   */
  showLoading() {
    this.loading.show();
    this.grid.hide();
  }

  /**
   * Load pictures into the grid
   * @param {Array} pictures - The pictures to load
   */
  loadPictures(pictures) {
    this.grid.empty();
    this._showGrid();
    
    let index = 0;
    for (const picture of pictures) {
      this._load(picture, index++);
    }
  }

  /**
   * Show the grid and hide loading indicator
   * @private
   */
  _showGrid() {
    if (this.showing(this.loading)) {
      this.loading.hide();
      this.grid.show();
    }
  }

  /**
   * Initialize the layout
   */
  initLayout() {
    this._calculateSize();
    this._adjustFrame();
  }

  /**
   * Load a picture into the grid
   * @param {Picture} picture - The picture to load
   * @param {number} index - The index position
   * @private
   */
  _load(picture, index) {
    const item = new PictureCellView(this.template.clone(), picture);
    item.setBoarderClasses(this._boarderClasses(index));
    this.grid.append(item.cellDiv);
    item.cellDiv.addClass('grid-index-' + index);
    item.cellDiv.show();
  }

  /**
   * Calculate grid dimensions
   * @private
   */
  _calculateSize() {
    this.columns = Math.floor(generalView.displayWidth / 260);
    this.rows = Math.floor(generalView.displayHeight / 270);
    this.size = this.columns * this.rows;
  }

  /**
   * Create a picture item
   * @param {Picture} picture - The picture
   * @param {number} index - The index
   * @private
   */
  _createPictureItem(picture, index) {
    // Placeholder for future implementation
  }

  /**
   * Get border classes for a cell
   * @param {number} index - The cell index
   * @returns {Array} - Border class names
   * @private
   */
  _boarderClasses(index) {
    const isTop = (idx) => idx < this.columns;
    const isLeft = (idx) => idx % this.columns === 0;
    
    const classes = [];
    if (isTop(index)) classes.push('top');
    if (isLeft(index)) classes.push('left');
    
    return classes;
  }

  /**
   * Get a picture ID
   * @param {Picture} picture - The picture
   * @returns {string} - The picture ID
   * @private
   */
  _picId(picture) {
    return 'pic-' + picture.id;
  }

  /**
   * Adjust the frame dimensions
   * @private
   */
  _adjustFrame() {
    this.grid.css('width', (this.columns * 260 + 2) + 'px');
    this.grid.css('height', (this.rows * 270 + 2) + 'px');
    $('#gridInner').css('height', generalView.displayHeight + 'px');
  }

  /**
   * Switch visibility
   * @param {boolean} showing - True to show
   */
  switchVisible(showing) {
    this.setVisible(this.gridview, showing);
  }
}

// Export to global namespace
window.Gridview = Gridview;

export default Gridview;
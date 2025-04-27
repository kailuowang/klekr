import ViewBase from '../global/viewBase';
import PictureCellView from './pictureCellView';

/**
 * Grid view for displaying pictures in a grid layout
 * @extends ViewBase
 */
class Gridview extends ViewBase {
  /**
   * Creates a new Gridview
   */
  constructor() {
    super();
    this.template = $('#template');
    this.grid = $('#gridPictures');
    this.gridview = $('#gridview');
    this.loading = this.gridview.find('#grid-loading');
    this.initLayout();
  }

  /**
   * Gets the current number of pictures in the grid
   * @returns {number} Number of pictures
   */
  currentSize = () => {
    return this.grid.children().size();
  }

  /**
   * Highlights a picture in the grid
   * @param {Picture} picture - Picture to highlight
   */
  highlightPicture(picture) {
    $('.grid-picture').removeClass('highlighted');
    this._showGrid();
    picture.trigger('highlighted');
  }

  /**
   * Shows the loading indicator
   */
  showLoading = () => {
    this.loading.show();
    this.grid.hide();
  }

  /**
   * Loads pictures into the grid
   * @param {Array<Picture>} pictures - Pictures to load
   */
  loadPictures = (pictures) => {
    this.grid.empty();
    this._showGrid();
    
    pictures.forEach((picture, index) => {
      this._load(picture, index);
    });
  }

  /**
   * Shows the grid
   * @private
   */
  _showGrid = () => {
    if (this.showing(this.loading)) {
      this.loading.hide();
      this.grid.show();
    }
  }

  /**
   * Initializes the grid layout
   */
  initLayout = () => {
    this._calculateSize();
    this._adjustFrame();
  }

  /**
   * Loads a picture into the grid
   * @param {Picture} picture - Picture to load
   * @param {number} index - Index in the grid
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
   * Calculates the grid size based on display dimensions
   * @private
   */
  _calculateSize() {
    this.columns = Math.floor(window.generalView.displayWidth / 260);
    this.rows = Math.floor(window.generalView.displayHeight / 270);
    this.size = this.columns * this.rows;
  }

  /**
   * Determines border classes for a grid cell
   * @param {number} index - Cell index
   * @returns {Array<string>} Border classes
   * @private
   */
  _boarderClasses = (index) => {
    const isTop = (idx) => idx < this.columns;
    const isLeft = (idx) => idx % this.columns === 0;
    
    const classes = [];
    if (isTop(index)) classes.push('top');
    if (isLeft(index)) classes.push('left');
    
    return classes;
  }

  /**
   * Gets a unique ID for a picture
   * @param {Picture} picture - The picture
   * @returns {string} Unique ID
   * @private
   */
  _picId(picture) {
    return 'pic-' + picture.id;
  }

  /**
   * Adjusts the grid frame to fit the layout
   * @private
   */
  _adjustFrame = () => {
    this.grid.css('width', (this.columns * 260 + 2) + 'px');
    this.grid.css('height', (this.rows * 270 + 2) + 'px');
    $('#gridInner').css('height', window.generalView.displayHeight + 'px');
  }

  /**
   * Switches visibility of the grid
   * @param {boolean} showing - Whether to show the grid
   */
  switchVisible = (showing) => {
    this.setVisible(this.gridview, showing);
  }
}

// Export for global access (compatibility with existing code)
window.Gridview = Gridview;

export default Gridview;
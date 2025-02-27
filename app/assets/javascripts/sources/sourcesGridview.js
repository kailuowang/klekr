import ViewBase from '../global/viewBase';
import SourceCell from './sourceCell';

/**
 * Grid view for displaying sources
 * @extends ViewBase
 */
class SourcesGridview extends ViewBase {
  /**
   * @param {jQuery} grid - The grid container element
   */
  constructor(grid) {
    super();
    this.grid = grid;
    this.cellTemplate = this.grid.find('.source-cell:first');
    this.cells = [];
  }

  /**
   * Loads sources into the grid
   * @param {Array<Source>} sources - The sources to display
   */
  load = (sources) => {
    this.cells = [];
    this.grid.empty();
    
    sources.forEach(source => {
      this.addSource(source);
    });
    
    this.cellTemplate.hide();
    this.registerEvents();
  }

  /**
   * Adds a source to the grid
   * @param {Source} source - The source to add
   * @returns {SourceCell|undefined} The created source cell, or undefined if already exists
   */
  addSource = (source) => {
    if (!this._has(source)) {
      const newCell = this.cellTemplate.clone();
      this.grid.append(newCell);
      newCell.show();
      
      const cell = new SourceCell(newCell, source);
      this.cells.push(cell);
      return cell;
    }
    return undefined;
  }

  /**
   * Registers event handlers for all cells
   */
  registerEvents = () => {
    this.cells.forEach(cell => {
      cell.registerEvents();
    });
  }

  /**
   * Checks if a source already exists in the grid
   * @param {Source} source - The source to check
   * @returns {boolean} Whether the source exists in the grid
   * @private
   */
  _has = (source) => {
    return this.cells.some(cell => cell.about(source));
  }
}

// Export for global access (compatibility with existing code)
window.SourcesGridview = SourcesGridview;

export default SourcesGridview;
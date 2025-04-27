import ViewBase from '../global/viewBase';
import { server } from '../global/server';
import { broadcaster } from '../global/broadcaster';
import Source from './source';

/**
 * Represents a UI cell that displays a source
 * @extends ViewBase
 */
class SourceCell extends ViewBase {
  /**
   * @param {jQuery} cell - jQuery element representing the cell
   * @param {Source} source - The source to display
   */
  constructor(cell, source) {
    super();
    this.cell = cell;
    this.source = source;
    
    this.cell.find('.source-icon').attr('src', this.source.iconUrl);
    this.cell.find('.source-icon-link').attr('href', this.source.slideUrl);
    this.cell.find('.source-name').text(this.source.username);
    this.cell.find('.source-type').text(this.source.typeDisplay);
    this.cell.attr('id', 'source-cell-' + this.source.id);
    
    this.mainPart = this.cell.find('.main-part');
    this.removeBtn = this.cell.find('#remove');
    this.addBtn = this.cell.find('#add');
    
    this._updateStatus();
    broadcaster.bind('source-changed', this._onSourceChange);
  }

  /**
   * Registers event handlers for the cell
   */
  registerEvents = () => {
    this.cell.hover(
      () => this._toggleTopBar(true), 
      () => this._toggleTopBar(false)
    );
    this.removeBtn.click_(this._remove);
    this.addBtn.click_(this._add);
  }

  /**
   * Checks if the cell represents a specific source
   * @param {Source} source - Source to check
   * @returns {boolean} Whether this cell represents the source
   */
  about = (source) => {
    return this.source.id === source.id;
  }

  /**
   * Handles removing a source
   * @private
   */
  _remove = () => {
    this.removeBtn.fadeOut();
    server.put(
      unsubscribe_flickr_stream_path(this.source), 
      {}, 
      this._broadcastNewSource
    );
  }

  /**
   * Handles adding a source
   * @private
   */
  _add = () => {
    this.addBtn.fadeOut();
    server.put(
      subscribe_flickr_stream_path(this.source), 
      {}, 
      (data) => {
        this._broadcastNewSource(data);
        broadcaster.trigger('source-added', this.source);
      }
    );
  }

  /**
   * Broadcasts when a source has changed
   * @param {Object} data - Updated source data
   * @private
   */
  _broadcastNewSource = (data) => {
    broadcaster.trigger('source-changed', new Source(data));
  }

  /**
   * Updates the visual status of the cell
   * @private
   */
  _updateStatus = () => {
    this.setVisible(this.removeBtn, this.source.subscribed);
    this.setVisible(this.addBtn, !this.source.subscribed);
    this.mainPart.toggleClass('removed', !this.source.subscribed);
  }

  /**
   * Toggles visibility of the top bar
   * @param {boolean} visible - Whether the top bar should be visible
   * @private
   */
  _toggleTopBar = (visible) => {
    if (!this.topBar) {
      this.topBar = this.cell.find('.top-bar');
    }
    this.topBar.toggleClass('invisible', !visible);
  }

  /**
   * Handles source change events
   * @param {Source} source - The changed source
   * @private
   */
  _onSourceChange = (source) => {
    if (this.about(source)) {
      this.source = source;
      this._updateStatus();
    }
  }
}

// Export for global access (compatibility with existing code)
window.SourceCell = SourceCell;

export default SourceCell;
import ViewBase from '../global/viewBase';
import { server } from '../global/server';
import { broadcaster } from '../global/broadcaster';
import Source from './source';
import SourcesGridview from './sourcesGridview';

/**
 * Base class for importers that handle flexible stream types
 * @extends ViewBase
 */
class FlexibleStreamsImporterBase extends ViewBase {
  /**
   * @param {string} popupId - The ID of the popup element
   * @param {string} triggerLinkId - The ID of the element that triggers the popup
   */
  constructor(popupId, triggerLinkId) {
    super();
    this._popup = $(popupId);
    const streams_grid = this._popup.find('.sources-grid:first');
    this._streams_gridview = new SourcesGridview(streams_grid);
    this._loading = this._popup.find('#loading-streams');
    this._doImportLink = this._popup.find('#do-import-streams');
    this._importProgress = this._popup.find('#import-streams-progress');
    this._progressBar = this._popup.find('#streams-progress-bar');
    this._streamsDisplay = this._popup.find('#display-streams');
    this.sourceAddedMessage = this._popup.find('#source-added-message');
    
    $(triggerLinkId).click_(this._init);
    this._doImportLink.click_(this._doImport);
    this._popup.find('.close-btn').click_(this._close);
    broadcaster.bind('source-added', this._sourceAdded);
  }

  /**
   * Initializes the importer
   * @private
   */
  _init = () => {
    this.popup(this._popup);
    this._loading.show();
    this._importProgress.hide();
    this._streamsDisplay.hide();
    this.sourceAddedMessage.hide();
    server.get(this._importSourcesUrl(), {}, (data) => {
      this.streams = data.map(d => new Source(d));
      this._showStreams(this.streams);
    });
  }

  /**
   * Closes the popup
   * @private
   */
  _close = () => {
    this.streams = [];
    this._popup.close();
  }

  /**
   * Shows streams in the grid
   * @param {Array<Source>} streams - The streams to show
   * @private
   */
  _showStreams = (streams) => {
    this._streams_gridview.load(streams);
    this._loading.hide();
    this._doImportLink.show();
    this._streamsDisplay.fadeIn();
  }

  /**
   * Starts the import process
   * @private
   */
  _doImport = () => {
    this._doImportLink.hide();
    this._importProgress.fadeIn();
    this._reportProgress(0, 1);
    this._startAdding(this._unsubscribedStreams());
  }

  /**
   * Gets unsubscribed streams
   * @returns {Array<Source>} Unsubscribed streams
   * @private
   */
  _unsubscribedStreams = () => {
    return this.streams.filter(stream => !stream.subscribed);
  }

  /**
   * Starts adding streams
   * @param {Array<Source>} streams - Streams to add
   * @private
   */
  _startAdding = (streams) => {
    new queffee.CollectionWorkQ({
      collection: streams,
      operation: this._add,
      onProgress: (p) => this._reportProgress(p, streams.length),
      onFinish: () => this._finish(streams)
    }).start();
  }

  /**
   * Adds a stream to user's sources
   * @param {Source} stream - The stream to add
   * @param {Function} callback - Callback function
   * @private
   */
  _add = (stream, callback) => {
    server.put(subscribe_flickr_stream_path(stream), {}, () => {
      this.trigger('sources-imported', [stream]);
      callback();
    });
  }

  /**
   * Reports import progress
   * @param {number} progress - Current progress
   * @param {number} total - Total items
   * @private
   */
  _reportProgress = (progress, total) => {
    this._progressBar.reportprogress(progress * 100 / total);
  }

  /**
   * Finishes the import process
   * @param {Array<Source>} streams - Imported streams
   * @private
   */
  _finish = (streams) => {
    this._syncAll(streams);
    this.closePopup(this._popup);
    this.trigger('import-finished');
  }

  /**
   * Syncs all streams
   * @param {Array<Source>} streams - Streams to sync
   * @private
   */
  _syncAll = (streams) => {
    server.post(
      sync_many_flickr_streams_path(), 
      { ids: streams.map(s => s.id) }
    );
  }

  /**
   * Syncs a single source
   * @param {Source} source - Source to sync
   * @private
   */
  _sync = (source) => {
    server.put(sync_flickr_stream_path(source));
  }

  /**
   * Handles a source being added
   * @param {Source} source - The source that was added
   * @private
   */
  _sourceAdded = (source) => {
    if (this._hasSource(source)) {
      this._showSourceAddedMessage();
      this._sync(source);
    }
  }

  /**
   * Checks if the stream list contains a source
   * @param {Source} source - Source to check
   * @returns {boolean} Whether the source exists in streams
   * @private
   */
  _hasSource = (source) => {
    return this.streams && this.streams.some(stream => stream.id === source.id);
  }

  /**
   * Shows a message when a source is added
   * @private
   */
  _showSourceAddedMessage = () => {
    this.sourceAddedMessage.hide();
    this.sourceAddedMessage.fadeIn();
  }
}

// Add to namespace for compatibility with existing code
window.klekr = window.klekr || {};
window.klekr.FlexibleStreamsImporterBase = FlexibleStreamsImporterBase;

export default FlexibleStreamsImporterBase;
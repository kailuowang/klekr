import StreamImporterBase from './streamImporterBase';
import { server } from '../global/server';
import SourcesGridview from './sourcesGridview';

/**
 * Importer for adding sources by user search
 * @extends StreamImporterBase
 */
class AddByUserImporter extends StreamImporterBase {
  /**
   * Creates a new AddByUserImporter
   */
  constructor() {
    super();
    this._popup = $('#import-by-user');
    this._notFound = this._popup.find('#not-found');
    this._form = this._popup.find('#search-user-form');
    this._addingUser = this._popup.find('#adding-user');
    
    const streams_grid = this._popup.find('.sources-grid:first');
    this._streams_gridview = new SourcesGridview(streams_grid);
    this._loading = $('#searching-user');
    this._resultsGrid = this._popup.find('#search-result');
    
    $('#add-by-user-link').click_(this.show);
    this._addButton = this._popup.find('#do-add');
    this._addButton.click_(this._add);
    this._popup.find('.close-btn').click_(this._close);
    this._popup.find('#submit').click_(this._doSearch);
  }

  /**
   * Shows the importer popup
   */
  show = () => {
    this._addButton.show();
    this._notFound.hide();
    this.popup(this._popup);
  }

  /**
   * Closes the popup
   * @private
   */
  _close = () => {
    this._popup.close();
  }

  /**
   * Handles the search action
   * @private
   */
  _doSearch = () => {
    const keyword = _.str.trim(this._popup.find('#keyword').val());
    if (keyword.length > 0) {
      this._loading.show();
      this._form.hide();
      this._resultsGrid.hide();
      server.post(
        search_users_path(), 
        { keyword: keyword }, 
        this._showSearchResult
      );
    }
  }

  /**
   * Shows search results
   * @param {Array<Object>} data - Search result data
   * @private
   */
  _showSearchResult = (data) => {
    this._loading.hide();
    this._form.show();
    this._results = data;
    
    const hasResults = this._results.length > 0;
    if (hasResults) {
      this._streams_gridview.load(this._results);
      this._addingUser.hide();
      this._resultsGrid.slideDown();
    }
    
    this.setVisible(this._notFound, !hasResults);
  }

  /**
   * Adds selected sources
   * @private
   */
  _add = () => {
    this._addingUser.show();
    this._addButton.hide();
    
    new queffee.CollectionWorkQ({
      collection: this._results,
      operation: (streamInfo, callback) => this._import(streamInfo, callback),
      onFinish: () => {
        this._addingUser.hide();
        this._finish();
      }
    }).start();
  }
}

// Export for global access (compatibility with existing code)
window.AddByUserImporter = AddByUserImporter;

export default AddByUserImporter;
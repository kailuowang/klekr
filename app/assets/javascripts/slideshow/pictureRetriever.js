import { Events } from '../global/backboneHelper';
import { server } from '../global/server';
import Picture from './picture';

/**
 * Base class for retrieving pictures from the server
 * @extends Events
 */
class PictureRetriever extends Events {
  /**
   * Creates a new PictureRetriever
   * @param {Function} filterOptsFn - Function that returns filter options
   * @param {number} pageSize - Number of pictures per page
   * @param {string} retrievePath - Path for retrieving pictures
   */
  constructor(filterOptsFn, pageSize, retrievePath) {
    super();
    this._filterOptsFn = filterOptsFn;
    this.pageSize = pageSize;
    this._retrievePath = retrievePath;
    this._retrievedCount = 0;
    this._currentPage = 0;
    
    this._q = new queffee.Q();
    this._worker = new queffee.Worker(this._q);
    this._worker.start();
    this._worker.onIdle = this._onWorkerDone;
    
    server.bind('connection-status-changed', this._retry);
  }

  /**
   * Resets the retriever
   */
  reset = () => {
    this._q.clear();
    this._currentPage = 0;
  }

  /**
   * Checks if the retriever is busy
   * @returns {boolean} Whether the retriever is busy
   */
  busy = () => {
    return !this._worker.idle();
  }

  /**
   * Retrieves pictures
   * @param {number} numOfPages - Number of pages to retrieve
   */
  retrieve = (numOfPages = 3) => {
    const works = this._createWorks(numOfPages);
    works.forEach(work => {
      this._q.enQ(work);
    });
  }

  /**
   * Retrieves a specific picture by ID
   * @param {number|string} picId - ID of the picture to retrieve
   */
  retrievePic = (picId) => {
    this._q.enQ((callback) => {
      server.get(
        picture_path({ id: picId }), 
        {}, 
        (data) => {
          this._onPicturesRetrieved([new Picture(data)]);
          callback();
        }
      );
    });
  }

  /**
   * Creates work functions for retrieving pages
   * @param {number} numOfPages - Number of pages to retrieve
   * @returns {Array<Function>} Work functions
   * @private
   */
  _createWorks = (numOfPages) => {
    const works = [];
    for (let i = 0; i < numOfPages; i++) {
      this._proceed();
      works.push(this._createWork());
    }
    return works;
  }

  /**
   * Creates a work function for retrieving a page
   * @returns {Function} Work function
   * @private
   */
  _createWork = () => {
    const pageOpts = this._pageOpts();
    return (callback) => this._retrievePage(pageOpts, callback);
  }

  /**
   * Handles worker completion
   * @private
   */
  _onWorkerDone = () => {
    this.trigger('done-retrieving', this._retrievedCount);
    this._retrievedCount = 0;
  }

  /**
   * Combines page options with filter options
   * @param {Object} pageOpts - Page options
   * @returns {Object} Combined options
   * @private
   */
  _retrieveOpts = (pageOpts) => {
    return $.extend(pageOpts, this._filterOptsFn());
  }

  /**
   * Advances to the next page
   * @private
   */
  _proceed = () => {
    this._currentPage++;
  }

  /**
   * Retries failed retrievals when the connection is restored
   * @private
   */
  _retry = () => {
    if (server.onLine()) {
      this._worker.retry();
    }
  }

  /**
   * Retrieves a page of pictures
   * @param {Object} pageOpts - Page options
   * @param {Function} callback - Callback function
   * @private
   */
  _retrievePage = (pageOpts, callback) => {
    server.get(
      this._retrievePath,
      this._retrieveOpts(pageOpts),
      (data) => {
        let pictures = null;
        if (data) {
          pictures = data.map(picData => new Picture(picData));
        }
        
        if (pictures && pictures.length > 0) {
          this._onPicturesRetrieved(pictures);
        } else {
          this._q.clear();
          this._onWorkerDone();
        }
        
        callback();
      }
    );
  }

  /**
   * Handles retrieved pictures
   * @param {Array<Picture>} pictures - Retrieved pictures
   * @private
   */
  _onPicturesRetrieved = (pictures) => {
    this.trigger('batch-retrieved', pictures);
    this._retrievedCount += pictures.length;
  }

  /**
   * Page options method to be implemented by subclasses
   * @abstract
   * @returns {Object} Page options
   * @private
   */
  _pageOpts() {
    throw new Error('Subclass must implement _pageOpts method');
  }
}

// Export for global access (compatibility with existing code)
window.PictureRetriever = PictureRetriever;

export default PictureRetriever;
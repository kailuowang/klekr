/**
 * Picture Retriever
 * Base class for retrieving pictures from the server
 */
import Events from '../src/global/events.js';

class PictureRetriever extends Events {
  /**
   * Create a picture retriever
   * @param {Function} filterOptsFn - Function that returns filter options
   * @param {number} pageSize - Number of pictures per page
   * @param {string} retrievePath - Path to retrieve pictures from
   */
  constructor(filterOptsFn, pageSize, retrievePath) {
    super();
    this._filterOptsFn = filterOptsFn;
    this.pageSize = pageSize;
    this._retrievePath = retrievePath;
    
    // Initialize state
    this._retrievedCount = 0;
    this._currentPage = 0;
    
    // Set up queue
    this._q = new queffee.Q();
    this._worker = new queffee.Worker(this._q);
    this._worker.start();
    this._worker.onIdle = this._onWorkerDone.bind(this);
    
    // Set up server event handler
    klekr.Global.server.on('connection-status-changed', this._retry.bind(this));
    
    // Bind methods
    this.reset = this.reset.bind(this);
    this.busy = this.busy.bind(this);
    this.retrieve = this.retrieve.bind(this);
    this.retrievePic = this.retrievePic.bind(this);
    this._createWorks = this._createWorks.bind(this);
    this._createWork = this._createWork.bind(this);
    this._onWorkerDone = this._onWorkerDone.bind(this);
    this._retrieveOpts = this._retrieveOpts.bind(this);
    this._proceed = this._proceed.bind(this);
    this._retry = this._retry.bind(this);
    this._retrievePage = this._retrievePage.bind(this);
    this._onPicturesRetrieved = this._onPicturesRetrieved.bind(this);
  }

  /**
   * Reset the retriever
   */
  reset() {
    this._q.clear();
    this._currentPage = 0;
  }

  /**
   * Check if the retriever is busy
   * @returns {boolean} - True if busy
   */
  busy() {
    return !this._worker.idle();
  }

  /**
   * Retrieve pictures
   * @param {number} numOfPages - Number of pages to retrieve (default: 3)
   */
  retrieve(numOfPages = 3) {
    const works = this._createWorks(numOfPages);
    for (const work of works) {
      this._q.enQ(work);
    }
  }

  /**
   * Retrieve a specific picture by ID
   * @param {string} picId - The picture ID to retrieve
   */
  retrievePic(picId) {
    this._q.enQ((callback) => {
      klekr.Global.server.get(picture_path({id: picId}), {}, (data) => {
        this._onPicturesRetrieved([new Picture(data)]);
        callback();
      });
    });
  }

  /**
   * Create work functions for pages to retrieve
   * @param {number} numOfPages - Number of pages to retrieve
   * @returns {Array} - Array of work functions
   * @private
   */
  _createWorks(numOfPages) {
    const works = [];
    for (let i = 0; i < numOfPages; i++) {
      this._proceed();
      works.push(this._createWork());
    }
    return works;
  }

  /**
   * Create a work function for the current page
   * @returns {Function} - The work function
   * @private
   */
  _createWork() {
    const pageOpts = this._pageOpts();
    return (callback) => this._retrievePage(pageOpts, callback);
  }

  /**
   * Handle worker completion
   * @private
   */
  _onWorkerDone() {
    this.trigger('done-retrieving', this._retrievedCount);
    this._retrievedCount = 0;
  }

  /**
   * Get retrieval options
   * @param {Object} pageOpts - Page options
   * @returns {Object} - Combined options
   * @private
   */
  _retrieveOpts(pageOpts) {
    return $.extend(pageOpts, this._filterOptsFn());
  }

  /**
   * Increment the current page
   * @private
   */
  _proceed() {
    this._currentPage++;
  }

  /**
   * Retry retrieval when connection is restored
   * @private
   */
  _retry() {
    if (klekr.Global.server.onLine()) {
      this._worker.retry();
    }
  }

  /**
   * Retrieve a page of pictures
   * @param {Object} pageOpts - Page options
   * @param {Function} callback - Callback function
   * @private
   */
  _retrievePage(pageOpts, callback) {
    klekr.Global.server.get(this._retrievePath, this._retrieveOpts(pageOpts), (data) => {
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
    });
  }

  /**
   * Handle retrieved pictures
   * @param {Array} pictures - The retrieved pictures
   * @private
   */
  _onPicturesRetrieved(pictures) {
    this.trigger('batch-retrieved', pictures);
    this._retrievedCount += pictures.length;
  }

  /**
   * Get page options (to be implemented by subclasses)
   * @private
   */
  _pageOpts() {
    // To be implemented by subclasses
  }
}

// Export to global namespace
window.PictureRetriever = PictureRetriever;

export default PictureRetriever;
import { server } from './server';
import namespace from './lib/namespace';

/**
 * Background updater for asynchronous server operations
 */
class Updater {
  /**
   * Creates a new Updater
   */
  constructor() {
    this._q = new queffee.Q();
    this._worker = new queffee.Worker(this._q);
    this._server = server;
    this._server.bind('connection-status-changed', this._connectionStatusChanged);
  }

  /**
   * Queues a PUT request
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   */
  put = (url, data) => {
    this._addJob('put', url, data);
  }

  /**
   * Queues a POST request
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   */
  post = (url, data) => {
    this._addJob('post', url, data);
  }

  /**
   * Adds a job to the queue
   * @param {string} method - The HTTP method
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   * @private
   */
  _addJob = (method, url, data) => {
    this._q.enQ((callback) => {
      this._server.ajax(url, data, method, callback);
    });
  }

  /**
   * Handles connection status changes
   * @private
   */
  _connectionStatusChanged = () => {
    if (this._server.onLine()) {
      this._worker.retry();
    }
  }
}

// Create the global updater instance
const updater = new Updater();

// Add to namespace for compatibility with existing code
namespace('klekr.Global', (n) => {
  n.updater = updater;
});

export { updater, Updater };
export default updater;
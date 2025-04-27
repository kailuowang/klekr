import { server } from '../global/server';
import PicturePreloadPriority from './picturePreloadPriority';

/**
 * Manages preloading of pictures
 */
class PicturePreloader {
  /**
   * Number of concurrent workers
   * @type {number}
   */
  static numOfWorkers = 3;

  /**
   * Creates a new PicturePreloader
   * @param {Gallery} gallery - The gallery instance
   */
  constructor(gallery) {
    this.gallery = gallery;
    this.q = new queffee.Q();
    this.workers = null;
    server.bind('connection-status-changed', this._retry);
  }

  /**
   * Starts the preloader
   */
  start = () => {
    if (!this.workers) {
      this.workers = this._createWorkers();
      this.workers.forEach(worker => {
        worker.start();
      });
    }
  }

  /**
   * Clears the preload queue
   */
  clear = () => {
    this.q.clear();
  }

  /**
   * Reprioritizes the queue
   */
  rePrioritize = () => {
    this.q.reorder();
  }

  /**
   * Preloads an array of pictures
   * @param {Array<Picture>} pictures - Pictures to preload
   */
  preload = (pictures) => {
    const jobs = pictures
      .filter(pic => !pic.noLongerValid)
      .map(pic => this._createJobs(pic))
      .flat();
    
    this.q.enqueue(...jobs);
  }

  /**
   * Creates worker instances
   * @returns {Array<queffee.Worker>} Created workers
   * @private
   */
  _createWorkers = () => {
    return Array.from({ length: PicturePreloader.numOfWorkers }, 
      () => new queffee.Worker(this.q));
  }

  /**
   * Creates preload jobs for a picture
   * @param {Picture} picture - Picture to create jobs for
   * @returns {Array<queffee.Job>} Created jobs
   * @private
   */
  _createJobs = (picture) => {
    const priority = new PicturePreloadPriority(picture, this.gallery);
    return [
      this._createJob(picture, 'Small', priority),
      this._createJob(picture, 'Full', priority)
    ];
  }

  /**
   * Creates a single preload job
   * @param {Picture} picture - Picture to preload
   * @param {string} size - Size to preload ('Small' or 'Full')
   * @param {PicturePreloadPriority} priority - Priority calculator
   * @returns {queffee.Job} Created job
   * @private
   */
  _createJob = (picture, size, priority) => {
    const priorityFn = priority[size.toLowerCase()];
    const preloadFn = (callback) => picture['preload' + size](callback);
    return new queffee.Job(preloadFn, priorityFn, this._timeout);
  }

  /**
   * Determines timeout for preload operations
   * @returns {number|null} Timeout in milliseconds or null for no timeout
   * @private
   */
  _timeout = () => {
    return server.onLine() ? 30000 : null;
  }

  /**
   * Retries failed preload operations
   * @private
   */
  _retry = () => {
    if (this.workers) {
      this.workers.forEach(worker => {
        worker.retry();
      });
    }
  }
}

// Export for global access (compatibility with existing code)
window.PicturePreloader = PicturePreloader;

export default PicturePreloader;
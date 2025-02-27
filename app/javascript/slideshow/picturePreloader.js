/**
 * Picture Preloader
 * Handles preloading of images with priority and workers
 */
import './picturePreloadPriority.js';

class PicturePreloader {
  static numOfWorkers = 3;

  constructor(gallery) {
    this.gallery = gallery;
    this.q = new queffee.Q();
    
    // Bind methods
    this.start = this.start.bind(this);
    this.clear = this.clear.bind(this);
    this.rePrioritize = this.rePrioritize.bind(this);
    this.preload = this.preload.bind(this);
    this._createWorkers = this._createWorkers.bind(this);
    this._createJobs = this._createJobs.bind(this);
    this._createJob = this._createJob.bind(this);
    this._timeout = this._timeout.bind(this);
    this._retry = this._retry.bind(this);

    // Set up event listener
    klekr.Global.server.on('connection-status-changed', this._retry);
  }

  start() {
    if (!this.workers) {
      this.workers = this._createWorkers();
      for (const worker of this.workers) {
        worker.start();
      }
    }
  }

  clear() {
    this.q.clear();
  }

  rePrioritize() {
    this.q.reorder();
  }

  preload(pictures) {
    const jobs = [];
    for (const pic of pictures) {
      if (!pic.noLongerValid) {
        jobs.push(...this._createJobs(pic));
      }
    }
    this.q.enqueue(...jobs);
  }

  _createWorkers() {
    const workers = [];
    for (let i = 0; i < PicturePreloader.numOfWorkers; i++) {
      workers.push(new queffee.Worker(this.q));
    }
    return workers;
  }

  _createJobs(picture) {
    const priority = new PicturePreloadPriority(picture, this.gallery);
    return [
      this._createJob(picture, 'Small', priority), 
      this._createJob(picture, 'Full', priority)
    ];
  }

  _createJob(picture, size, priority) {
    const priorityFn = priority[size.toLowerCase()].bind(priority);
    const preloadFn = (callback) => picture['preload' + size](callback);
    return new queffee.Job(preloadFn, priorityFn, this._timeout);
  }

  _timeout() {
    return klekr.Global.server.onLine() ? 30000 : null;
  }

  _retry() {
    if (this.workers) {
      for (const worker of this.workers) {
        worker.retry();
      }
    }
  }
}

// Export to global namespace
window.PicturePreloader = PicturePreloader;
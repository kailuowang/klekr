/**
 * Updater class
 * Handles server updates via a queue system
 */

// Import the queffee library (globally available)
import './lib/queffee.js';

class Updater {
  constructor() {
    // Bind methods
    this.put = this.put.bind(this);
    this.post = this.post.bind(this);
    this._addJob = this._addJob.bind(this);
    this._connectionStatusChanged = this._connectionStatusChanged.bind(this);
    
    // Initialize queue and worker
    this._q = new queffee.Q();
    this._worker = new queffee.Worker(this._q);
    this._server = klekr.Global.server;
    
    // Set up connection status listener
    this._server.on('connection-status-changed', this._connectionStatusChanged);
  }

  put(url, data) {
    return this._addJob('put', url, data);
  }

  post(url, data) {
    return this._addJob('post', url, data);
  }

  _addJob(method, url, data) {
    this._q.enQ((callback) => {
      this._server.ajax(url, data, method, callback);
    });
  }

  _connectionStatusChanged() {
    if (this._server.onLine()) {
      this._worker.retry();
    }
  }
}

// Create namespace and export instance
window.klekr = window.klekr || {};
window.klekr.Global = window.klekr.Global || {};
window.klekr.Global.updater = new Updater();
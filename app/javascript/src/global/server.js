/**
 * Server class for handling AJAX requests
 * @extends Events
 */
import Events from './events.js';

class Server extends Events {
  /**
   * Creates a new Server instance
   */
  constructor() {
    super();
    this._offLine = false;
    
    // Bind methods
    this._handleError = this._handleError.bind(this);
    this._setOffLine = this._setOffLine.bind(this);
    this._checkConnection = this._checkConnection.bind(this);
    this.onLine = this.onLine.bind(this);
  }

  get(url, data, callback) {
    this.ajax(url, data, 'GET', callback);
  }

  post(url, data, callback) {
    this.ajax(url, data, 'POST', callback);
  }

  put(url, data, callback) {
    this.ajax(url, data, 'PUT', callback);
  }

  ajax(url, data, type, callback) {
    $.ajax({
      url: this._jsUrl(url),
      dataType: 'json',
      data: data,
      type: type,
      success: (data) => {
        this._setOffLine(false);
        if (callback) callback(data);
      },
      error: (xhr, textStatus, errorThrown) => {
        this._handleError(xhr.responseText, callback);
      }
    });
  }

  onLine() {
    return !this._offLine;
  }

  _handleError(response, callback) {
    if (response === '' || (response && response.search(/under maintenance/i) > -1)) {
      this._setOffLine(true);
    } else if (response && response.search(/Welcome to/i) > -1) {
      this._setOffLine(false);
      window.location.href = authentications_path();
    } else {
      if (callback) callback();
    }
  }

  _setOffLine(value) {
    if (this._offLine !== value) {
      this._offLine = value;
      this.trigger('connection-status-changed', this.onLine());
      if (this._offLine) this._startCheckConnection();
      else this._stopCheckConnection();
    }
  }

  _checkConnection() {
    if (!this.onLine()) this.get(health_path());
  }

  _startCheckConnection() {
    if (!this._connectionCheckingPId) {
      this._connectionCheckingPId = setInterval(this._checkConnection, 10000);
    }
  }

  _stopCheckConnection() {
    if (this._connectionCheckingPId) {
      clearInterval(this._connectionCheckingPId);
      this._connectionCheckingPId = null;
    }
  }

  _jsUrl(url) {
    if (url.indexOf('?') >= 0) {
      return url.replace('?', '.json?');
    } else {
      return url + '.json';
    }
  }
}

// Create the namespace if it doesn't exist
window.klekr = window.klekr || {};
window.klekr.Global = window.klekr.Global || {};

// Create a singleton instance
const server = new Server();

// Export the server instance to global namespace
window.klekr.Global.server = server;

// Export for ES modules
export { server, Server };
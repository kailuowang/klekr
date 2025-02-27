/**
 * Server communication handler
 * @extends Events
 */
class Server extends Events {
  /**
   * Creates a new Server instance
   */
  constructor() {
    super();
    this._offLine = false;
    this._connectionCheckingPId = null;
  }

  /**
   * Performs a GET request
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   * @param {Function} callback - Callback for successful response
   */
  get(url, data, callback) {
    this.ajax(url, data, 'GET', callback);
  }

  /**
   * Performs a POST request
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   * @param {Function} callback - Callback for successful response
   */
  post(url, data, callback) {
    this.ajax(url, data, 'POST', callback);
  }

  /**
   * Performs a PUT request
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   * @param {Function} callback - Callback for successful response
   */
  put(url, data, callback) {
    this.ajax(url, data, 'PUT', callback);
  }

  /**
   * Performs an AJAX request
   * @param {string} url - The URL to request
   * @param {Object} data - The data to send
   * @param {string} type - The HTTP method type
   * @param {Function} callback - Callback for successful response
   */
  ajax(url, data, type, callback) {
    $.ajax({
      url: this._jsUrl(url),
      dataType: 'json',
      data,
      type,
      success: (data) => {
        this._setOffLine(false);
        if (callback) {
          callback(data);
        }
      },
      error: (xhr, textStatus, errorThrown) => {
        this._handleError(xhr.responseText, callback);
      }
    });
  }

  /**
   * Checks if the connection is online
   * @returns {boolean} Whether the connection is online
   */
  onLine = () => {
    return !this._offLine;
  }

  /**
   * Handles error responses
   * @param {string} response - The error response
   * @param {Function} callback - Callback function
   * @private
   */
  _handleError = (response, callback) => {
    if (response === '' || response.search(/under maintenance/i) > -1) {
      this._setOffLine(true);
    } else if (response.search(/Welcome to/i) > -1) {
      this._setOffLine(false);
      window.location.href = authentications_path();
    } else {
      if (callback) {
        callback();
      }
    }
  }

  /**
   * Sets the offline state
   * @param {boolean} value - Whether the connection is offline
   * @private
   */
  _setOffLine = (value) => {
    if (this._offLine !== value) {
      this._offLine = value;
      this.trigger('connection-status-changed', this.onLine());
      
      if (this._offLine) {
        this._startCheckConnection();
      } else {
        this._stopCheckConnection();
      }
    }
  }

  /**
   * Checks the connection status
   * @private
   */
  _checkConnection = () => {
    if (!this.onLine()) {
      this.get(health_path());
    }
  }

  /**
   * Starts checking the connection periodically
   * @private
   */
  _startCheckConnection = () => {
    if (!this._connectionCheckingPId) {
      this._connectionCheckingPId = setInterval(this._checkConnection, 10000);
    }
  }

  /**
   * Stops checking the connection
   * @private
   */
  _stopCheckConnection = () => {
    if (this._connectionCheckingPId) {
      clearInterval(this._connectionCheckingPId);
      this._connectionCheckingPId = null;
    }
  }

  /**
   * Converts a URL to a JSON API URL
   * @param {string} url - The URL to convert
   * @returns {string} The JSON API URL
   * @private
   */
  _jsUrl(url) {
    if (url.indexOf('?') >= 0) {
      return url.replace('?', '.json?');
    } else {
      return url + '.json';
    }
  }
}

// Create the global server instance
const server = new Server();

// Add to namespace for compatibility with existing code
window.Server = Server;
window.klekr = window.klekr || {};
window.klekr.Global = window.klekr.Global || {};
window.klekr.Global.server = server;

export { server, Server };
export default server;
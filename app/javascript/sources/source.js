/**
 * Represents a source for image streams
 */
class Source {
  /**
   * @param {Object} data - The source data from the server
   */
  constructor(data) {
    Object.assign(this, data);
  }
}

// Export for global access (compatibility with existing code)
window.Source = Source;

export default Source;
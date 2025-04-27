/**
 * Reporter Class
 * Utility for reporting and exporting picture information
 */
class Reporter {
  constructor() {
    // Bind methods
    this.exportPictures = this.exportPictures.bind(this);
    this.help = this.help.bind(this);
    this.pictureString = this.pictureString.bind(this);
  }

  /**
   * Export pictures to console
   * @param {number} limit - Maximum number of pictures to export (default: 20)
   * @param {number} start - Starting index (default: 0)
   * @param {boolean} favedOnly - Whether to only export favorites (default: false)
   */
  exportPictures(limit = 20, start = 0, favedOnly = false) {
    // Filter pictures
    const pictures = gallery.pictures.filter(
      picture => (!favedOnly || picture.faved()) && !picture.data.noLongerValid
    );
    
    // Format pictures
    const toPrint = pictures
      .slice(start, start + limit)
      .map((picture, index) => this.pictureString(picture, index));
    
    // Output to console
    console.log(toPrint.join(' ') + 
      "For more pictures go to \nhttp://klekr.com/editors_choice\n");
  }

  /**
   * Show help information
   * @returns {string} - Help text
   */
  help() {
    return "limit = 20, start = 0, faveOnly = false";
  }

  /**
   * Format a picture as a string
   * @param {Picture} picture - The picture to format
   * @param {number} index - The index
   * @returns {string} - Formatted picture string
   */
  pictureString(picture, index) {
    return `
    ${index + 1}

    ${picture.largeUrl}
    ${picture.ownerName}
    http://klekr.com${picture.ownerPath}
    ${picture.title}
    ${picture.description}
    ${picture.flickrPageUrl}


    `.replace("https:", "http:");
  }
}

// Export to namespace
window.klekr = window.klekr || {};
window.klekr.Reporter = Reporter;

export default Reporter;
import ViewBase from '../global/viewBase';
import CollapsiblePanel from '../global/collapsiblePanel';

/**
 * Label for displaying picture information
 * @extends ViewBase
 */
class PictureLabel extends ViewBase {
  /**
   * Creates a new PictureLabel instance
   */
  constructor() {
    super();
    this.panel = $('#picture-label');
    this.expandLink = this.panel.find('#expand-link');
    this.expandLink.click(this._toggleSecondRow);
    new CollapsiblePanel(this.panel.find('#collapsible'), this.expandLink, ['[+]', '[-]']);
  }

  /**
   * Shows the label for a picture
   * @param {Object} picture - The picture to show the label for
   */
  show = (picture) => {
    if (picture) {
      this._updateDom(picture);
    }
    this.panel.show();
  }

  /**
   * Hides the label
   */
  hide = () => {
    this.panel.hide();
  }

  /**
   * Updates the DOM elements with picture information
   * @param {Object} picture - The picture to display information for
   * @private
   */
  _updateDom = (picture) => {
    if (!this.artistLink) {
      this.artistLink = this.panel.find('#artist-link');
    }
    this.artistLink.attr('href', picture.ownerPath);
    this.artistLink.text(picture.ownerName);
    
    if (!this.titleLink) {
      this.titleLink = this.panel.find('#title-link');
    }
    this.titleLink.attr('href', picture.flickrPageUrl);
    this.titleLink.text(picture.data.title);
    
    if (!this.flickrLink) {
      this.flickrLink = this.panel.find('#flickr-link');
    }
    this.flickrLink.attr('href', picture.flickrPageUrl);

    this._updateDescription(picture);

    if (!this.date) {
      this.date = this.panel.find('#title #date');
    }
    this.date.text(picture.dateUpload.substr(0, 7).replace('-', '/'));
    
    if (!this.artistCollectionLink) {
      this.artistCollectionLink = this.panel.find('#artist-collection');
    }
    this.setArtistCollectionLink(this.artistCollectionLink, picture);
    
    if (!this.interestingess) {
      this.interestingess = this.panel.find('#interestingess-num');
    }
    this.interestingess.text(picture.interestingness);
    
    if (!this.interestingessDisplay) {
      this.interestingessDisplay = this.panel.find('#interestingness');
    }
    this.setVisible(this.interestingessDisplay, (picture.interestingness !== 0));
    this.setVisible($('#personalized-info'), klekr.Global.anonymous === undefined);

    this._updateSources(picture.fromStreams);
    
    if (!this.relatedPanel) {
      this.relatedPanel = this.panel.find('#related-pictures');
    }

    this.setVisible(this.relatedPanel, !picture.noLongerValid);
    this.setVisible(this.interestingess, !picture.noLongerValid);
  }

  /**
   * Toggles visibility of the second row
   * @private
   */
  _toggleSecondRow = () => {
    $("#second-row").toggleClass("override-hidden");
  }

  /**
   * Expands the label
   */
  expand = () => {
    this.expandLink.trigger('click');
  }

  /**
   * Updates the description section
   * @param {Object} picture - The picture
   * @private
   */
  _updateDescription = (picture) => {
    if (!this.description) {
      this.description = this.panel.find('#description');
    }
    this.description.html(picture.description);
    this.setVisible(this.description, picture.description && picture.description.length > 1);
  }

  /**
   * Updates the sources section
   * @param {Array} streams - The streams
   * @private
   */
  _updateSources = (streams) => {
    if (!this.sources) {
      this.sources = this.panel.find('#sources');
    }
    if (!this.sourcesLinks) {
      this.sourcesLinks = this.sources.find('#sources-links');
    }
    this.sourcesLinks.empty();
    
    const collectionStreams = streams.filter(stream => stream.type !== 'Works');

    collectionStreams.forEach(stream => {
      if (this.sourcesLinks.children().length > 0) {
        this.sourcesLinks.append($('<span>').text(', '));
      }
      const link = $('<a>').attr('href', stream.path).text(stream.username);
      this.sourcesLinks.append(link);
    });
    
    this.setVisible(this.sources, collectionStreams.length > 0);
  }
}

// Export for global access (compatibility with existing code)
window.PictureLabel = PictureLabel;

export default PictureLabel;
/**
 * Picture Label Component
 * Handles the display of picture metadata and information
 */
import ViewBase from '../src/global/viewBase.js';

class PictureLabel extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
    this.panel = $('#picture-label');
    this.expandLink = this.panel.find('#expand-link');
    
    // Set up event handlers
    this.expandLink.click(this._toggleSecondRow.bind(this));
    new CollapsiblePanel(this.panel.find('#collapsible'), this.expandLink, ['[+]', '[-]']);
    
    // Bind methods
    this.show = this.show.bind(this);
    this.hide = this.hide.bind(this);
    this._updateDom = this._updateDom.bind(this);
    this._toggleSecondRow = this._toggleSecondRow.bind(this);
    this.expand = this.expand.bind(this);
    this._updateDescription = this._updateDescription.bind(this);
    this._updateSources = this._updateSources.bind(this);
  }

  /**
   * Show the picture label
   * @param {Picture} picture - The picture to show information for
   */
  show(picture) {
    if (picture) {
      this._updateDom(picture);
    }
    this.panel.show();
  }

  /**
   * Hide the label
   */
  hide() {
    this.panel.hide();
  }

  /**
   * Update DOM elements with picture data
   * @param {Picture} picture - The picture
   * @private
   */
  _updateDom(picture) {
    // Artist link
    if (!this.artistLink) {
      this.artistLink = this.panel.find('#artist-link');
    }
    this.artistLink.attr('href', picture.ownerPath);
    this.artistLink.text(picture.ownerName);
    
    // Title link
    if (!this.titleLink) {
      this.titleLink = this.panel.find('#title-link');
    }
    this.titleLink.attr('href', picture.flickrPageUrl);
    this.titleLink.text(picture.data.title);
    
    // Flickr link
    if (!this.flickrLink) {
      this.flickrLink = this.panel.find('#flickr-link');
    }
    this.flickrLink.attr('href', picture.flickrPageUrl);
    
    // Description
    this._updateDescription(picture);
    
    // Date
    if (!this.date) {
      this.date = this.panel.find('#title #date');
    }
    this.date.text(picture.dateUpload.substr(0, 7).replace('-', '/'));
    
    // Artist collection link
    if (!this.artistCollectionLink) {
      this.artistCollectionLink = this.panel.find('#artist-collection');
    }
    this.setArtistCollectionLink(this.artistCollectionLink, picture);
    
    // Interestingness
    if (!this.interestingess) {
      this.interestingess = this.panel.find('#interestingess-num');
    }
    this.interestingess.text(picture.interestingness);
    
    if (!this.interestingessDisplay) {
      this.interestingessDisplay = this.panel.find('#interestingness');
    }
    this.setVisible(this.interestingessDisplay, picture.interestingness !== 0);
    
    // Personalized info
    this.setVisible($('#personalized-info'), !klekr.Global.anonymous);
    
    // Sources
    this._updateSources(picture.fromStreams);
    
    // Related pictures
    if (!this.relatedPanel) {
      this.relatedPanel = this.panel.find('#related-pictures');
    }
    
    this.setVisible(this.relatedPanel, !picture.noLongerValid);
    this.setVisible(this.interestingess, !picture.noLongerValid);
  }

  /**
   * Toggle the second row
   * @private
   */
  _toggleSecondRow() {
    $("#second-row").toggleClass("override-hidden");
  }

  /**
   * Expand the label
   */
  expand() {
    this.expandLink.trigger('click');
  }

  /**
   * Update the description
   * @param {Picture} picture - The picture
   * @private
   */
  _updateDescription(picture) {
    if (!this.description) {
      this.description = this.panel.find('#description');
    }
    this.description.html(picture.description);
    this.setVisible(
      this.description, 
      picture.description && picture.description.length > 1
    );
  }

  /**
   * Update the sources list
   * @param {Array} streams - The streams
   * @private
   */
  _updateSources(streams) {
    if (!this.sources) {
      this.sources = this.panel.find('#sources');
    }
    
    if (!this.sourcesLinks) {
      this.sourcesLinks = this.sources.find('#sources-links');
    }
    
    this.sourcesLinks.empty();
    
    // Filter collection streams
    const collectionStreams = streams.filter(stream => stream.type !== 'Works');
    
    // Add stream links
    for (const stream of collectionStreams) {
      if (this.sourcesLinks.children().length > 0) {
        this.sourcesLinks.append($('<span>').text(', '));
      }
      
      const link = $('<a>')
        .attr('href', stream.path)
        .text(stream.username);
      
      this.sourcesLinks.append(link);
    }
    
    this.setVisible(this.sources, collectionStreams.length > 0);
  }
}

// Export to global namespace
window.PictureLabel = PictureLabel;

export default PictureLabel;
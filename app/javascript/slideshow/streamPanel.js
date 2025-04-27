/**
 * StreamPanel Component
 * Handles the stream control panel for managing sources
 */
import ViewBase from '../src/global/viewBase.js';

class StreamPanel extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
    this.startCollectingLink = $('#startCollecting');
    this.stopCollectingLink = $('#stopCollecting');
    this.noncollectingOperationDiv = $('#noncollectingStreamOperations');
    this.collectingOperationDiv = $('#collectingStreamOperations');
    this.rating = this.collectingOperationDiv.find('#rating');
    this.sourceAddedPopup = $('#source-added-popup');
    
    // Set up OK button handler
    $('#source-added-popup #okay').click(() => {
      this.closePopup(this.sourceAddedPopup);
    });
    
    // Bind methods
    this._bindCollectingOperations = this._bindCollectingOperations.bind(this);
    this._bindAdjustmentLinks = this._bindAdjustmentLinks.bind(this);
    this._displayAlternativeLink = this._displayAlternativeLink.bind(this);
    
    // Initialize components
    this._bindCollectingOperations();
    this._bindAdjustmentLinks();
    this._displayAlternativeLink();
  }

  /**
   * Bind collecting operations
   * @private
   */
  _bindCollectingOperations() {
    this.startCollectingLink.bind('ajax:success', () => {
      this.noncollectingOperationDiv.hide();
      this.collectingOperationDiv.show();
      this.popup(this.sourceAddedPopup);
    });
    
    this.stopCollectingLink.bind('ajax:success', () => {
      this.noncollectingOperationDiv.show();
      this.collectingOperationDiv.hide();
    });
  }

  /**
   * Bind adjustment links
   * @private
   */
  _bindAdjustmentLinks() {
    const adjustmentLinks = this.collectingOperationDiv.find('.rating-adjustment-link');
    
    adjustmentLinks.bind('ajax:success', (e, newRating) => {
      this.rating.text(newRating);
      adjustmentLinks.removeClass('disabled');
    });
    
    adjustmentLinks.click((e) => {
      if ($(e.target).hasClass('disabled')) {
        return false;
      } else {
        adjustmentLinks.addClass('disabled');
        return true;
      }
    });
  }

  /**
   * Display alternative link if window is large enough
   * @private
   */
  _displayAlternativeLink() {
    const alternativeLink = $('#alternative-stream');
    const windowTooSmall = alternativeLink.width() > ($(window).width() / 3.3);
    this.setVisible(alternativeLink, !windowTooSmall);
  }
}

// Export to global namespace
window.StreamPanel = StreamPanel;

export default StreamPanel;
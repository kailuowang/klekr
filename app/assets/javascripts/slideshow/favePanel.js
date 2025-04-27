import ViewBase from '../global/viewBase';
import KeyShortcut from './keyShortcuts';

/**
 * Panel for managing favorite pictures
 * @extends ViewBase
 */
class FavePanel extends ViewBase {
  /**
   * Creates a new FavePanel instance
   */
  constructor() {
    super();
    this.faveLink = $('#faveLink');
    this.removeFaveLink = $('#removeFaveLink');
    this.faved = $('#faved');
    this.faveArea = $('#faveArea');
    this.faveRating = $('#faveRating');
    this.faveRatingPanel = $('#faveRatingPanel');
    this.ratingDisplayPanel = $('#ratingDisplayPanel');
    this.ratingDisplay = $('#ratingDisplay');
    this.reloading = $('#reloading-picture');
    this.loginReminder = $('#login-reminder');
    this._registerEvents();
    this._initRaty(this.faveRating);
    this._initRaty(this.ratingDisplay);
    window.keyShortcuts.addShortcuts(this._shortcuts());
  }

  /**
   * Marks the current picture as a favorite
   */
  fave = () => {
    if (this.picture.favable() && !this.picture.faved()) {
      this.setArtistCollectionLink(this.faveRatingPanel.find('#artist-collection'), this.picture);
      this.popup(this.faveRatingPanel);
    }
  }

  /**
   * Removes the current picture from favorites
   */
  unfave = () => {
    if (this.picture.favable() && this.picture.faved()) {
      this.picture.unfave();
      this._updateDom();
    }
  }

  /**
   * Updates the panel with a new picture
   * @param {Object} picture - The picture to update with
   */
  updateWith = (picture) => {
    this.picture = picture;
    this._checkAccess();
  }

  /**
   * Checks if the current user has access to the picture
   * @private
   */
  _checkAccess = () => {
    if (!this.picture.favable() && klekr.Global.currentCollector) {
      this.picture.bind('data-updated', this._pictureUpdated);
      this.picture.reloadForCurrentCollector();
    }
    this._updateDom();
  }

  /**
   * Handles picture data updates
   * @param {Object} picture - The updated picture
   * @private
   */
  _pictureUpdated = (picture) => {
    if (picture === this.picture) {
      this._updateDom();
    }
  }

  /**
   * Updates the DOM based on current picture state
   * @private
   */
  _updateDom = () => {
    this.setVisible(this.faveArea, klekr.Global.currentCollector && this.picture.favable());
    this.setVisible(this.reloading, (!this.picture.favable() && klekr.Global.currentCollector));
    this.setVisible(this.loginReminder, !klekr.Global.currentCollector);
    
    if (this.picture.favable()) {
      const faved = this.picture.faved();
      this.setVisible(this.faveLink, !faved);
      this._updateRating(this.picture.data.rating);
      this.setVisible(this.ratingDisplayPanel, faved);
      this.setVisible(this.faved, faved);
      this.removeFaveLink.attr('data-content', `This picture is added to my faves on ${this.picture.favedDate}. Click to remove it.`);
    }
  }

  /**
   * Registers event handlers
   * @private
   */
  _registerEvents = () => {
    this.faveLink.click_(this.fave);
    this.removeFaveLink.click_(this.unfave);
    $('#fave-login').click(this.login);
  }

  /**
   * Updates the rating display
   * @param {number} rating - The rating value
   * @private
   */
  _updateRating = (rating) => {
    $.fn.raty.start(rating, '#faveRating');
    $.fn.raty.start(rating, '#ratingDisplay');
  }

  /**
   * Initializes the Raty rating plugin
   * @param {jQuery} div - The div to initialize
   * @private
   */
  _initRaty = (div) => {
    div.raty({
      start: 1,
      path: '/assets/',
      size: 24,
      target: '#faveRatingPanel #hint-message',
      hintList: [
        'I like it.', 
        'I would recommend it to others.', 
        "One of the most impresive pictures I've seen for quite a while.", 
        'I would hang it in my home.', 
        "It's probably a masterpiece."
      ],
      click: (score) => {
        this._changeRating(score);
      }
    });
  }

  /**
   * Changes the rating of the current picture
   * @param {number} rating - The new rating
   * @private
   */
  _changeRating = (rating) => {
    if (this._showingPopup()) {
      this.closePopup(this.faveRatingPanel);
    }
    this.picture.fave(rating);
    this._updateDom();
  }

  /**
   * Checks if the rating popup is currently showing
   * @returns {boolean} Whether the popup is showing
   * @private
   */
  _showingPopup = () => {
    return this.showing(this.faveRatingPanel);
  }

  /**
   * Gets the keyboard shortcuts for this panel
   * @returns {Array<KeyShortcut>} The shortcuts
   * @private
   */
  _shortcuts = () => {
    if (!this.mShortcuts) {
      this.mShortcuts = [
        this._createRatingShortcut(),
        new KeyShortcut(['f','c'], this.fave, 'fave the picture', this._canFave),
        new KeyShortcut('u', this.unfave, 'unfave the picture', () => this.showing(this.removeFaveLink))
      ];
    }
    return this.mShortcuts;
  }

  /**
   * Checks if the current picture can be marked as favorite
   * @returns {boolean} Whether the picture can be faved
   * @private
   */
  _canFave = () => {
    return window.gallery?.slide?.active() && this.picture.favable();
  }

  /**
   * Checks if rating shortcuts are enabled
   * @returns {boolean} Whether rating shortcuts are enabled
   * @private
   */
  _ratingShortcutsEnabled = () => {
    return this._showingPopup() || this.showing(this.ratingDisplayPanel);
  }

  /**
   * Creates a rating shortcut
   * @returns {KeyShortcut} The created shortcut
   * @private
   */
  _createRatingShortcut = () => {
    return new KeyShortcut(
      ['1','2','3','4','5'],
      ((e) => {
        const rating = e.keyCode - 48;
        console.log(rating);
        this._changeRating(rating);
      }),
      'set fave rating accordingly',
      this._canFave
    );
  }
}

// Export for global access (compatibility with existing code)
window.FavePanel = FavePanel;

export default FavePanel;
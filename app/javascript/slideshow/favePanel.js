/**
 * Fave Panel Component
 * Handles the favoriting functionality
 */
import ViewBase from '../src/global/viewBase.js';

class FavePanel extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
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
    
    // Set up handlers and initialize components
    this._registerEvents();
    this._initRaty(this.faveRating);
    this._initRaty(this.ratingDisplay);
    keyShortcuts.addShortcuts(this._shortcuts());
    
    // Bind methods
    this.fave = this.fave.bind(this);
    this.unfave = this.unfave.bind(this);
    this.updateWith = this.updateWith.bind(this);
    this._checkAccess = this._checkAccess.bind(this);
    this._pictureUpdated = this._pictureUpdated.bind(this);
    this._updateDom = this._updateDom.bind(this);
    this._registerEvents = this._registerEvents.bind(this);
    this._updateRating = this._updateRating.bind(this);
    this._initRaty = this._initRaty.bind(this);
    this._changeRating = this._changeRating.bind(this);
    this._showingPopup = this._showingPopup.bind(this);
    this._shortcuts = this._shortcuts.bind(this);
    this._canFave = this._canFave.bind(this);
    this._ratingShortcutsEnabled = this._ratingShortcutsEnabled.bind(this);
    this._createRatingShortcut = this._createRatingShortcut.bind(this);
  }

  /**
   * Mark a picture as favorite
   */
  fave() {
    if (this.picture.favable() && !this.picture.faved()) {
      this.setArtistCollectionLink(this.faveRatingPanel.find('#artist-collection'), this.picture);
      this.popup(this.faveRatingPanel);
    }
  }

  /**
   * Remove a picture from favorites
   */
  unfave() {
    if (this.picture.favable() && this.picture.faved()) {
      this.picture.unfave();
      this._updateDom();
    }
  }

  /**
   * Update the panel with a picture
   * @param {Picture} picture - The picture
   */
  updateWith(picture) {
    this.picture = picture;
    this._checkAccess();
  }

  /**
   * Check access to the picture
   * @private
   */
  _checkAccess() {
    if (!this.picture.favable() && klekr.Global.currentCollector) {
      this.picture.on('data-updated', this._pictureUpdated);
      this.picture.reloadForCurrentCollector();
    }
    this._updateDom();
  }

  /**
   * Handle picture updates
   * @param {Picture} picture - The updated picture
   * @private
   */
  _pictureUpdated(picture) {
    if (picture === this.picture) {
      this._updateDom();
    }
  }

  /**
   * Update the DOM elements
   * @private
   */
  _updateDom() {
    this.setVisible(this.faveArea, klekr.Global.currentCollector && this.picture.favable());
    this.setVisible(this.reloading, !this.picture.favable() && klekr.Global.currentCollector);
    this.setVisible(this.loginReminder, !klekr.Global.currentCollector);
    
    if (this.picture.favable()) {
      const faved = this.picture.faved();
      this.setVisible(this.faveLink, !faved);
      this._updateRating(this.picture.data.rating);
      this.setVisible(this.ratingDisplayPanel, faved);
      this.setVisible(this.faved, faved);
      this.removeFaveLink.attr(
        'data-content', 
        `This picture is added to my faves on ${this.picture.favedDate}. Click to remove it.`
      );
    }
  }

  /**
   * Register event handlers
   * @private
   */
  _registerEvents() {
    this.faveLink.click_(this.fave);
    this.removeFaveLink.click_(this.unfave);
    $('#fave-login').click(this.login);
  }

  /**
   * Update the rating display
   * @param {number} rating - The rating value
   * @private
   */
  _updateRating(rating) {
    $.fn.raty.start(rating, '#faveRating');
    $.fn.raty.start(rating, '#ratingDisplay');
  }

  /**
   * Initialize the rating component
   * @param {jQuery} div - The rating container
   * @private
   */
  _initRaty(div) {
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
      click: (score, evt) => {
        this._changeRating(score);
      }
    });
  }

  /**
   * Change the rating
   * @param {number} rating - The new rating
   * @private
   */
  _changeRating(rating) {
    if (this._showingPopup()) {
      this.closePopup(this.faveRatingPanel);
    }
    this.picture.fave(rating);
    this._updateDom();
  }

  /**
   * Check if showing popup
   * @returns {boolean} - True if showing
   * @private
   */
  _showingPopup() {
    return this.showing(this.faveRatingPanel);
  }

  /**
   * Get keyboard shortcuts
   * @returns {Array} - The shortcuts
   * @private
   */
  _shortcuts() {
    if (!this._mShortcuts) {
      this._mShortcuts = [
        this._createRatingShortcut(),
        new KeyShortcut(['f', 'c'], this.fave, 'fave the picture', this._canFave),
        new KeyShortcut('u', this.unfave, 'unfave the picture', () => this.showing(this.removeFaveLink))
      ];
    }
    return this._mShortcuts;
  }

  /**
   * Check if can fave
   * @returns {boolean} - True if can fave
   * @private
   */
  _canFave() {
    return gallery?.slide?.active() && this.picture.favable();
  }

  /**
   * Check if rating shortcuts enabled
   * @returns {boolean} - True if enabled
   * @private
   */
  _ratingShortcutsEnabled() {
    return this._showingPopup() || this.showing(this.ratingDisplayPanel);
  }

  /**
   * Create rating shortcuts
   * @returns {KeyShortcut} - The shortcut
   * @private
   */
  _createRatingShortcut() {
    return new KeyShortcut(
      ['1', '2', '3', '4', '5'],
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

// Export to global namespace
window.FavePanel = FavePanel;

export default FavePanel;
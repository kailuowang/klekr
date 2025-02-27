/**
 * Gallery Filters Component
 * Handles UI for filtering gallery images
 */
import ViewBase from '../src/global/viewBase.js';

class GalleryFilters extends ViewBase {
  constructor() {
    super();
    
    // Initialize DOM elements
    this.panel = $('#slide-options .filters');
    this.ratingFilter = $('#rating-filter-select');
    this.typeCheckBox = $('#type-filter-checkbox');
    this.viewedCheckBox = $('#viewed-filter-checkbox');
    this.faveDateBox = this.panel.find('#fave-at-date');
    this.faveDateAfterBox = this.panel.find('#fave-at-date-after');
    
    // Bind methods
    this.filterSettings = this.filterSettings.bind(this);
    this.hasActiveFilter = this.hasActiveFilter.bind(this);
    this._getDate = this._getDate.bind(this);
    this._applyDefaultFitlers = this._applyDefaultFitlers.bind(this);
    this._setFiltersVisibility = this._setFiltersVisibility.bind(this);
    this._filterChanged = this._filterChanged.bind(this);
    this.show = this.show.bind(this);
    this.hide = this.hide.bind(this);
    
    // Set up event handlers
    if (this.typeCheckBox.change) this.typeCheckBox.change(this._filterChanged);
    if (this.viewedCheckBox.change) this.viewedCheckBox.change(this._filterChanged);
    if (this.ratingFilter.change) this.ratingFilter.change(this._filterChanged);
    this.faveDateBox.bind('change', this._filterChanged);
    this.faveDateAfterBox.bind('change', this._filterChanged);
    
    // Initialize state
    this._setFiltersVisibility(klekr.Global.filtersOpts || {});
    this.panel.find('.datepicker').simpleDatepicker();
    this._applyDefaultFitlers();
  }

  /**
   * Get the current filter settings
   * @returns {Object} - The filter settings object
   */
  filterSettings() {
    const settings = {};
    
    if (this.typeCheckBox.attr('checked')) {
      settings.type = 'UploadStream';
    }
    
    if (this.viewedCheckBox && this.viewedCheckBox.attr('checked')) {
      settings.viewed = this.viewedCheckBox.attr('checked');
    }
    
    if (this.ratingFilter.length > 0 && this.ratingFilter[0].selectedIndex > 0) {
      settings.rating = this.ratingFilter[0].selectedIndex + 1;
    }
    
    settings.faveDate = this._getDate(this.faveDateBox);
    settings.faveDateAfter = this._getDate(this.faveDateAfterBox);
    
    return settings;
  }

  /**
   * Check if any filter is active
   * @returns {boolean} - True if at least one filter is active
   */
  hasActiveFilter() {
    const settings = this.filterSettings();
    for (const name in settings) {
      if (settings[name] != null) {
        return true;
      }
    }
    return false;
  }

  /**
   * Get a date from an input field
   * @private
   * @param {jQuery} input - The date input element
   * @returns {string|null} - The date string or null
   */
  _getDate(input) {
    if (input.length > 0 && input.val().length > 0) {
      return input.val();
    }
    return null;
  }

  /**
   * Apply default filters
   * @private
   */
  _applyDefaultFitlers() {
    if (klekr.Global.defaultFilters) {
      this.ratingFilter[0].selectedIndex = klekr.Global.defaultFilters.rating - 1;
      this.faveDateBox.val(klekr.Global.defaultFilters.faveDate);
      this.faveDateAfterBox.val(klekr.Global.defaultFilters.faveDateAfter);
    }
  }

  /**
   * Set visibility of filter panels
   * @private
   * @param {Object} opts - Visibility options
   */
  _setFiltersVisibility(opts) {
    this.setVisible(this.panel.find('#stream-type-filter-panel'), opts.streamTypeFilter);
    this.setVisible(this.panel.find('#rating-filter-panel'), opts.ratingFilter);
    this.setVisible(this.panel.find('#faved-at-filter-panel'), opts.favedAtFilter);
  }

  /**
   * Handle filter change events
   * @private
   */
  _filterChanged() {
    this.trigger('changed', this.filterSettings());
  }

  /**
   * Show the filters panel
   */
  show() {
    this.fadeInOut(this.panel, true);
  }

  /**
   * Hide the filters panel
   */
  hide() {
    this.fadeInOut(this.panel, false);
  }
}

// Export to global namespace for compatibility
window.GalleryFilters = GalleryFilters;

export default GalleryFilters;
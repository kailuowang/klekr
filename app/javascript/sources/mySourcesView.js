import ViewBase from '../src/global/viewBase';
import { broadcaster } from '../src/global/broadcaster';
import SourcesGridview from './sourcesGridview';

/**
 * View for managing user's sources
 * @extends ViewBase
 */
class MySourcesView extends ViewBase {
  /**
   * Creates a new MySourcesView
   */
  constructor() {
    super();
    this.template = $('#star-category-template');
    this.container = $('#sources-list');
    this.expandLink = $('#expand-management');
    this.importPanel = $('#sources-import-panel');
    this.indicator = $('#loading-sources-indicator');
    this.newSourcesAddedPanel = $('#new-sources-added');
    
    $('#close-new-sources-added').click_(() => this.newSourcesAddedPanel.slideUp());
    this.expandLink.click_(this._toggleManagementPanel);
    $('#add-more-sources').click_(this._toggleManagementPanel);
    broadcaster.bind('source-added', this.addSource);
    
    this.categories = {};
  }

  /**
   * Clears all sources from the view
   */
  clear = () => {
    this.container.empty();
    this.indicator.show();
    this.categories = {};
  }

  /**
   * Adds a source to the view
   * @param {Source} source - The source to add
   */
  addSource = (source) => {
    const category = this._ensureCategory(source.rating);
    const cell = category.addSource(source);
    if (cell && category.registerEvents) {
      category.registerEvents();
    }
    return category;
  }

  /**
   * Updates the UI when all sources are loaded
   * @param {boolean} empty - Whether there are no sources
   */
  onAllSourcesLoaded = (empty) => {
    this.setVisible($('#empty-sources'), empty);
    this.setVisible($('#add-more-sources'), !empty);
    this.setVisible(this.importPanel, empty);
    this._setExpandLinkText(empty);
    $('#sources-management').show();
    this.indicator.hide();
    
    if (!empty) {
      this._registerCellEvents();
    }
  }

  /**
   * Shows a panel with information about newly added sources
   * @param {Object} collectorInfo - Information about the collector
   */
  showNewSourcesAddedPanel = (collectorInfo) => {
    this.newSourcesAddedPanel.find('#num-of-sources').text(collectorInfo.sources);
    $(window).scrollTop(0);
    this.newSourcesAddedPanel.slideDown();
  }

  /**
   * Registers events for all category cells
   * @private
   */
  _registerCellEvents = () => {
    Object.values(this.categories).forEach(category => {
      category.registerEvents();
    });
  }

  /**
   * Creates a category div for a specific rating
   * @param {number} star - The star rating
   * @returns {jQuery} The created category element
   * @private
   */
  _createCategoryDiv = (star) => {
    const newStarCategory = this.template.clone();
    newStarCategory.attr('id', 'star' + star);
    this._updateStar(newStarCategory, star);
    this.container.append(newStarCategory);
    this._sortCategories();
    newStarCategory.show();
    return newStarCategory;
  }

  /**
   * Gets or creates a category for a specific rating
   * @param {number} star - The star rating
   * @returns {SourcesGridview} The grid view for the category
   * @private
   */
  _ensureCategory = (star) => {
    if (!this.categories) {
      this.categories = {};
    }
    
    if (!this.categories[star]) {
      this.categories[star] = this._sourcesGridView(this._createCategoryDiv(star));
    }
    
    return this.categories[star];
  }

  /**
   * Updates the star display for a category
   * @param {jQuery} categoryDiv - The category div
   * @param {number} star - The star rating
   * @private
   */
  _updateStar = (categoryDiv, star) => {
    const label = categoryDiv.find('.stars-label:first');
    const starText = Array(star).fill('★').join('');
    label.text(starText);
  }

  /**
   * Sorts categories by star rating
   * @private
   */
  _sortCategories = () => {
    const categories = $('.star-category');
    const sorted_categories = [...categories].sort((a, b) => b.id.localeCompare(a.id));
    
    this.container.empty();
    sorted_categories.forEach(category => {
      this.container.append(category);
    });
    
    $('.star-category .stars-label').popover_ext();
  }

  /**
   * Creates a sources grid view for a category
   * @param {jQuery} categoryDiv - The category div
   * @returns {SourcesGridview} The created grid view
   * @private
   */
  _sourcesGridView = (categoryDiv) => {
    const cellGrid = categoryDiv.find('.sources-grid:first');
    return new SourcesGridview(cellGrid);
  }

  /**
   * Toggles the management panel
   * @private
   */
  _toggleManagementPanel = () => {
    const expanded = !this.showing(this.importPanel);
    this._setExpandLinkText(expanded);
    
    this.importPanel.slideToggle(() => {
      if (this.showing(this.importPanel)) {
        $(window).scrollTop(this.importPanel.offset().top);
      }
    });
  }

  /**
   * Updates the expand link text based on state
   * @param {boolean} expanded - Whether the panel is expanded
   * @private
   */
  _setExpandLinkText = (expanded) => {
    const text = expanded 
      ? "It's easy! 5 ways of adding sources:" 
      : 'I want more sources!';
    this.expandLink.text(text);
  }
}

// Export for global access (compatibility with existing code)
window.MySourcesView = MySourcesView;

export default MySourcesView;
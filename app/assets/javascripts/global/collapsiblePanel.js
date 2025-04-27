import ViewBase from './viewBase';

/**
 * Collapsible panel with togglable header
 * @extends ViewBase
 */
class CollapsiblePanel extends ViewBase {
  /**
   * Creates a new CollapsiblePanel
   * @param {jQuery} panel - The panel element to collapse/expand
   * @param {jQuery} header - The header element that toggles the panel
   * @param {Array<string>} alternativeTexts - Alternate texts for collapsed/expanded states
   */
  constructor(panel, header, alternativeTexts) {
    super();
    this.panel = panel;
    this.header = header;
    this.alternativeTexts = alternativeTexts;
    
    if (this.alternativeTexts) {
      this.header.text(this.alternativeTexts[0]);
    }
    
    this.header.click_(() => {
      if (this.alternativeTexts) {
        // Convert boolean to integer (0 or 1) to get the appropriate text
        const textIndex = +(!this.showing(this.panel));
        this.header.text(this.alternativeTexts[textIndex]);
      }
      this.panel.slideToggle();
    });
  }
}

// Export for global access (compatibility with existing code)
window.CollapsiblePanel = CollapsiblePanel;

export default CollapsiblePanel;
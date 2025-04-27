/**
 * Collapsible panel component for toggling UI sections
 */
class CollapsiblePanel extends ViewBase {
  /**
   * Creates a new collapsible panel
   * 
   * @param {jQuery} panel - The panel element to toggle
   * @param {jQuery} header - The header/trigger element to click
   * @param {Array<string>} alternativeTexts - Array of two text values for expanded/collapsed states
   */
  constructor(panel, header, alternativeTexts) {
    super();
    
    this.panel = panel;
    this.header = header;
    this.alternativeTexts = alternativeTexts;
    
    // Set initial text if available
    if (this.alternativeTexts) {
      this.header.text(this.alternativeTexts[0]);
    }
    
    // Set up click handler
    this.header.click_(() => {
      if (this.alternativeTexts) {
        // Toggle text between the two options based on current visibility
        this.header.text(this.alternativeTexts[+(!this.showing(this.panel))]);
      }
      this.panel.slideToggle();
    });
  }
}

// Export to window
window.CollapsiblePanel = CollapsiblePanel;
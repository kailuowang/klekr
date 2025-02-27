/**
 * Global Module
 * Provides core utilities and functionality used throughout the application
 */

// Import base classes
import Events from './events.js';
import ViewBase from './viewBase.js';

// Import utilities
import './analytics.js';
import './backboneHelper.js';
import './bootstrapExt.js';
import './broadcaster.js';
import './collapsiblePanel.js';
import './jsErrorMonitor.js';
import './rails_routes.js';
import './server.js';
import './updater.js';
import './userInfo.js';

// Define global namespace
window.klekr = window.klekr || {};
window.klekr.Global = window.klekr.Global || {};

// Export components to global namespace
window.klekr.Global.Events = Events;
window.klekr.Global.ViewBase = ViewBase;

// Export named components
export { Events, ViewBase };
// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Include jQuery for compatibility with existing code
import jquery from "jquery"
window.jQuery = jquery;
window.$ = jquery;

// Set up namespace structure
window.klekr = window.klekr || {};
window.klekr.Global = window.klekr.Global || {};

// Import core libraries
import _ from "underscore"
window._ = _;

// Import Backbone
import Backbone from "backbone"
window.Backbone = Backbone;

// Import jQuery plugins
import "jquery-ui"

// Set up namespace function
window.namespace = function(target, name, block) {
  var i, len, ref, item, current;
  if (arguments.length < 3) {
    block = name;
    name = target;
    target = window;
  }
  
  current = target;
  ref = name.split('.');
  
  for (i = 0, len = ref.length; i < len; i++) {
    item = ref[i];
    current[item] = current[item] || {};
    current = current[item];
  }
  
  if (block) {
    block(current);
  }
  
  return current;
};

// Import global module
import "./src/global"

// Import application-specific modules
import "./slideshow"
import "./sources"
import "./authentication"
import "./user"
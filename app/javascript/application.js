// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Include jQuery for compatibility with existing code
import jquery from "jquery"
window.jQuery = jquery;
window.$ = jquery;
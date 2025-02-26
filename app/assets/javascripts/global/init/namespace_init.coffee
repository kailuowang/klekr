# Initialize the klekr namespace and ensure it's available globally
# This file must be loaded before other JavaScript files that use the klekr namespace

window.klekr = window.klekr || {}
window.klekr.Global = window.klekr.Global || {}
window.klekr.Slideshow = window.klekr.Slideshow || {}
window.klekr.Sources = window.klekr.Sources || {}
window.klekr.User = window.klekr.User || {}

# Setup Events system as a global object
window.Events = window.Events || 
  trigger: (eventName, data) -> 
    # Empty implementation if Backbone isn't loaded yet
    console?.log?("Event triggered: #{eventName}")
  bind: (eventName, callback) ->
    # Empty implementation if Backbone isn't loaded yet
    console?.log?("Event bound: #{eventName}")

# Add browser detection for older libraries that depend on $.browser
do ->
  if typeof jQuery isnt 'undefined' and not jQuery.browser
    jQuery.browser = {}
    userAgent = navigator.userAgent.toLowerCase()
    jQuery.browser.mozilla = /mozilla/.test(userAgent) and not /webkit/.test(userAgent)
    jQuery.browser.webkit = /webkit/.test(userAgent)
    jQuery.browser.opera = /opera/.test(userAgent)
    jQuery.browser.msie = /msie/.test(userAgent) or /trident/.test(userAgent)
/**
 * Jasmine test suite for klekr
 * This file serves as the main entry point for all tests
 */

// First load application code
//=require application

// Then load all test support libraries
//=require helpers/test_helpers

// Finally load all specs
//=require_tree ./slideshow

// Set up Jasmine environment
window.jasmine = window.jasmine || {};
window.jasmine.klekr = window.jasmine.klekr || {};

// Signal when tests have loaded
console.log('Jasmine specs loaded');
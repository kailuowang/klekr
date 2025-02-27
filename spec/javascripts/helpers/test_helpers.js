/**
 * Test helper methods for Jasmine tests
 * This file provides common functionality needed across test files
 */

// Global setup for klekr namespace if not defined
window.klekr = window.klekr || {};

/**
 * Function to create test doubles
 * @param {string} name - Name of the double
 * @param {Object} methods - Methods to add to the double
 * @returns {Object} - The created test double
 */
window.createTestDouble = function(name, methods = {}) {
  const double = {};
  for (const [methodName, implementation] of Object.entries(methods)) {
    double[methodName] = implementation;
  }
  return double;
};

/**
 * Utility function to create an array of test objects
 * @param {number} count - Number of objects to create
 * @param {Function} createFn - Function to create each object
 * @returns {Array} - Array of created objects
 */
window.createTestArray = function(count, createFn) {
  const result = [];
  for (let i = 0; i < count; i++) {
    result.push(createFn(i));
  }
  return result;
};

// Add any custom matchers needed for tests
beforeEach(function() {
  jasmine.addMatchers({
    toBeInstanceOf: function(util, customEqualityTesters) {
      return {
        compare: function(actual, expected) {
          const result = {};
          result.pass = actual instanceof expected;
          if (result.pass) {
            result.message = `Expected ${actual} not to be an instance of ${expected}`;
          } else {
            result.message = `Expected ${actual} to be an instance of ${expected}`;
          }
          return result;
        }
      };
    }
  });
});
# Test helper methods for Jasmine tests
# This file provides common functionality needed across test files

# Global setup for klekr namespace if not defined
window.klekr = window.klekr || {}

# Function to create test doubles
window.createTestDouble = (name, methods = {}) ->
  double = {}
  for methodName, implementation of methods
    double[methodName] = implementation
  double

# Utility function to create an array of test objects
window.createTestArray = (count, createFn) ->
  result = []
  for i in [0...count]
    result.push(createFn(i))
  result

# Add any custom matchers needed for tests
beforeEach ->
  jasmine.addMatchers
    toBeInstanceOf: (util, customEqualityTesters) ->
      compare: (actual, expected) ->
        result = {}
        result.pass = actual instanceof expected
        if result.pass
          result.message = "Expected #{actual} not to be an instance of #{expected}"
        else
          result.message = "Expected #{actual} to be an instance of #{expected}"
        result
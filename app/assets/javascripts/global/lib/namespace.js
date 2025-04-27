/**
 * Creates or accesses a namespace
 * @param {Object} target - The root object to create the namespace on (defaults to window)
 * @param {string} name - The namespace string using dot notation
 * @param {Function} block - A function to execute with the namespace as its parameter
 */
function namespace(target, name, block) {
  let top;
  
  // Handle optional target parameter
  if (arguments.length < 3) {
    block = name;
    name = target;
    target = typeof exports !== 'undefined' ? exports : window;
  }
  
  // Store the top level object
  top = target;
  
  // Create or access each level of the namespace
  name.split('.').forEach(item => {
    target = target[item] = target[item] || {};
  });
  
  // Execute the block function with the namespace and top level object
  block(target, top);
}

// Export for global access (compatibility with existing code)
window.namespace = namespace;

export default namespace;
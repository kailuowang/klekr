/**
 * Namespace utility
 * Creates a nested namespace on the specified target object
 * 
 * @param {Object} target - The target object to create the namespace on
 * @param {string} name - The namespace path (e.g. 'klekr.slideshow')
 * @param {Function} block - Function to execute with the namespace
 */
this.namespace = function(target, name, block) {
  // Handle case where target is omitted (use window as default)
  if (arguments.length < 3) {
    [target, name, block] = [typeof exports !== 'undefined' ? exports : window, ...arguments];
  }
  
  // Store reference to the top-level object
  const top = target;
  
  // Create each component of the namespace path
  name.split('.').forEach(item => {
    target = target[item] = target[item] || {};
  });
  
  // Execute the provided function with the namespace and top object
  block(target, top);
};
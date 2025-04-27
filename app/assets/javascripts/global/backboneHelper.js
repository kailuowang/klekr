/**
 * Backbone CoffeeScript Helpers by M@ McCray.
 * Source: http://gist.github.com/625893
 *
 * Provides ES6 class wrappers for Backbone classes to make them
 * easier to extend in CoffeeScript/ES6:
 *
 * class TaskController extends Events {
 *   // ...
 * }
 *
 * class TaskView extends View {
 *   constructor() {
 *     super();
 *     // ...
 *   }
 * }
 */

/**
 * Base class for event handling
 */
class Events {}

// Extend with Backbone.Events
_.extend(Events.prototype, Backbone.Events);

/**
 * Base model class extending Backbone.Model
 */
class Model {
  /**
   * @param {...*} args - Arguments to pass to Backbone.Model constructor
   */
  constructor(...args) {
    Backbone.Model.apply(this, args);
  }
}

// Extend with Backbone.Model prototype
_.extend(Model.prototype, Backbone.Model.prototype);

/**
 * Base collection class extending Backbone.Collection
 */
class Collection {
  /**
   * @param {...*} args - Arguments to pass to Backbone.Collection constructor
   */
  constructor(...args) {
    Backbone.Collection.apply(this, args);
  }
}

// Extend with Backbone.Collection prototype
_.extend(Collection.prototype, Backbone.Collection.prototype);

// View class is commented out in the original
// /**
//  * Base view class extending Backbone.View
//  */
// class View {
//   /**
//    * @param {...*} args - Arguments to pass to Backbone.View constructor
//    */
//   constructor(...args) {
//     Backbone.View.apply(this, args);
//   }
// }
//
// // Extend with Backbone.View prototype
// _.extend(View.prototype, Backbone.View.prototype);

// Export for global access (compatibility with existing code)
window.Events = Events;
window.Model = Model;
window.Collection = Collection;
// window.View = View;

export { Events, Model, Collection };
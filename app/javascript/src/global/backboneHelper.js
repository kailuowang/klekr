// Backbone JavaScript Helpers by M@ McCray.
// Source: http://gist.github.com/625893
//
// Use Backbone classes as native classes:
//
// class TaskController extends Events { ... }
//
// class TaskView extends View {
//   constructor() {
//     super();
//     this.template = _.template(TaskView.SRC);
//     if (this.model) this.render();
//   }
//
//   render() {
//     $(this.el).html(this.template(this.model.toJSON()));
//   }
// }
//
// Etc...

class Events {}

_.extend(Events.prototype, Backbone.Events);

window.Events = Events;

class Model {
  constructor() {
    Backbone.Model.apply(this, arguments);
  }
}

_.extend(Model.prototype, Backbone.Model.prototype);

window.Model = Model;

class Collection {
  constructor() {
    Backbone.Collection.apply(this, arguments);
  }
}

_.extend(Collection.prototype, Backbone.Collection.prototype);

window.Collection = Collection;

// class View {
//   constructor() {
//     Backbone.View.apply(this, arguments);
//   }
// }
//
// _.extend(View.prototype, Backbone.View.prototype);
//
// window.View = View;
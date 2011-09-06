# Backbone CoffeeScript Helpers by M@ McCray.
# Source: http://gist.github.com/625893
#
# Use Backbone classes as native CoffeeScript classes:
#
#  class TaskController extends Events
#
#  class TaskView extends View
#    tagName: 'li'
#    @SRC: '<div class="icon">!</div><div class="name"><%= name %></div>'
#
#    constructor: ->
#      super
#      @template= _.template(TaskView.SRC)
#      @render() if @model?
#
#    render: ->
#      $(@el).html @template( @model.toJSON() )
#
# Etc...
#

class Events

_.extend(Events::, Backbone.Events)

this.Events = Events


class Model
  constructor: ->
    Backbone.Model.apply(this, arguments)

_.extend(Model::, Backbone.Model.prototype)

this.Model = Model


class Collection
  constructor: ->
    Backbone.Collection.apply(this, arguments)

_.extend(Collection::, Backbone.Collection.prototype)

this.Collection = Collection


#class View
#  constructor: ->
#    Backbone.View.apply(this, arguments)
#
#_.extend(View::, Backbone.View.prototype)
#
#this.View = View
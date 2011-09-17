class window.CollapsiblePanel extends ViewBase
  constructor: (@panel, @header) ->
    @header.click_ => @panel.slideToggle()


$.fn.popover_ext = ->
  this.each ->
    element = $(this)
    element.popover
      offset: 5
      placement: element.attr("data-popover")
      topOffset: element.attr("data-popover-top-offset")
      leftOffset: element.attr("data-popover-left-offset")

$ ->
  $(".has-popover[data-popover]").popover_ext()


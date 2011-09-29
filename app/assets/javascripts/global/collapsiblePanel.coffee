class window.CollapsiblePanel extends ViewBase
  constructor: (@panel, @header, @alternativeTexts) ->
    @header.click_ =>
      if(@alternativeTexts?)
        @header.text(@alternativeTexts[+(!this.showing(@panel))])
      @panel.slideToggle()

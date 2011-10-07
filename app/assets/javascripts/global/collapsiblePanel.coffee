class window.CollapsiblePanel extends ViewBase
  constructor: (@panel, @header, @alternativeTexts) ->
    @header.text(@alternativeTexts[0])
    @header.click_ =>
      if(@alternativeTexts?)
        @header.text(@alternativeTexts[+(!this.showing(@panel))])
      @panel.slideToggle()

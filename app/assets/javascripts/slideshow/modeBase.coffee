class window.ModeBase extends Events
  constructor: (@name)->
    keyShortcuts.addShortcuts(this.shortcuts())

  active: =>
    gallery.currentMode is this and !gallery.isEmpty()

  shortcuts: =>
    @_shortcuts ?= this._createShortcuts()

  on: =>
    this.view().switchVisible(true)
    this.trigger('on')

  off: =>
    this.view().switchVisible(false)
    this.trigger('off')

  goToIndex: (index) =>
    window.location = '#' + "#{this.name}-#{index}#{this._extraHashInfo(index)}"

  canScroll: (towardsLeft) =>
    if towardsLeft
      !this.atTheBegining()
    else
      !this.atTheLast() and !gallery.isLoading()

  scroll: (towardsLeft) =>
    if towardsLeft
      this.navigateToPrevious()
    else
      this.navigateToNext()

  _createShortcuts: =>
    this._createShortcut(setting) for setting in this.shortcutsSettings()

  _createShortcut: (setting)=>
    new KeyShortcut setting[0], setting[1], setting[2], =>
      this.active() and !ViewBase.showingPopup

  _extraHashInfo: =>
    ''

class window.ModeBase
  constructor: ->
    keyShortcuts.addShortcuts(this.shortcuts())

  active: =>
    gallery.currentMode is this

  shortcuts: =>
    @_shortcuts ?= this._createShortcuts()

  _createShortcuts: =>
    this._createShortcut(setting) for setting in this.shortcutsSettings()

  _createShortcut: (setting)=>
    new KeyShortcut setting[0], setting[1], setting[2], =>
      this.active() and !ViewBase.showingPopup

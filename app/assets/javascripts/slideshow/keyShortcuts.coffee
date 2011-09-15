class window.KeyShortcuts extends ViewBase
  constructor: ->
    @shortcuts = []
    @_popup =  $('#keyShortcuts')
    this._registerHelpPopup()
    @helpList = $('#shortcuts')
    this.addShortcuts new KeyShortcut('k', this._popupHelp, 'Show all keyboard shortcuts', this._canShowHelp )

  disable: =>
    $(document).unbind('keydown', this._clearLock)
    this._updateKeys(this._unbindKey)

  enable: =>
    this._updateKeys(this._bindKey)
    this._registerClearLock(shortcut) for shortcut in @shortcuts

  addShortcuts: (shortcuts) =>
    this.disable()
    @shortcuts = @shortcuts.concat(shortcuts)
    this.enable()

  _registerClearLock: (shortcut) =>
   this._bindKey(shortcut, this._clearLock)

  _updateKeys: (action)->
    action(shortcut) for shortcut in @shortcuts

  _bindKey: (shortcut, toBind = shortcut.onKeydown) ->
    for key in shortcut.keys
      $(document).bind('keydown', key, toBind)

  _unbindKey: (shortcut) ->
    $(document).unbind('keydown', shortcut.onKeydown)

  _registerHelpPopup: ->
    $('#keyShortcutsLink').click this._popupHelp

  _popupHelp: =>
    this._updateHelp()
    this.popup(@_popup)

  _canShowHelp: =>
    !this.showing(@_popup)

  _updateHelp: ->
    @helpList.empty()
    for shortcut in @shortcuts when shortcut.enable()
      @helpList.append(
        $('<li>').text(shortcut.text())
      )

  _clearLock: =>
    @locked = false

class window.KeyShortcut
  constructor: (@keys, @_func, @desc, @enable = (-> true)) ->
    unless @keys instanceof Array
      @keys = [@keys]

  text: =>
    keysStrings = (this._keyDisplay(key) for key in @keys)
    "#{keysStrings.join(', ')} : #{@desc}"

  _keyDisplay: (stringKey) =>
    (
      switch stringKey
        when 'up' then '↑'
        when 'down' then '↓'
        else
          stringKey
    ).replace('left', '←').replace('right', '→')

  onKeydown: =>
    unless keyShortcuts.locked #this ensures that for one key stroke only one action is fired (needed to prevent chain reaction)
      if this.enable()
        this._func()
        keyShortcuts.locked = true


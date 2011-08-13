class window.KeyShortcuts extends ViewBase
  constructor: ->
    @shortcuts = []
    this._registerHelpPopup()
    @helpList = $('#shortcuts')

  disable: =>
    $(document).unbind('keydown', this._clearLock)
    this._updateKeys(this._unbindKey)

  enable: =>
    this._updateKeys(this._bindKey)
    for shortcut in @shortcuts
      do (shortcut) =>
        $(document).bind('keydown', shortcut.key, this._clearLock)

  addShortcuts: (shortcuts) =>
    this.disable()
    @shortcuts = @shortcuts.concat(shortcuts)
    this.enable()

  _updateKeys: (action)->
    action(shortcut) for shortcut in @shortcuts

  _bindKey: (shortcut) ->
    for key in shortcut.keys
      $(document).bind('keydown', key, shortcut.onKeydown)

  _unbindKey: (shortcut) ->
    $(document).unbind('keydown', shortcut.onKeydown)

  _registerHelpPopup: ->
    $('#keyShortcutsLink').click =>
      this._popupHelp()
      false

  _popupHelp: =>
    this._updateHelp()
    this.popup($('#keyShortcuts'))

  _updateHelp: ->
    @helpList.empty()
    for shortcut in @shortcuts when shortcut.enable()
      do (shortcut) =>
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
    keysStrings = ("'#{key}'" for key in @keys)
    "#{keysStrings.join(', ')}: #{@desc}"

  onKeydown: =>
    unless keyShortcuts.locked #this ensures that for one key stroke only one action is fired (needed to prevent chain reaction)
      if this.enable()
        this._func()
        keyShortcuts.locked = true


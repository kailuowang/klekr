class window.KeyShortcuts extends ViewBase
  constructor: ->
    @shortcuts = []
    this._registerHelpPopup()
    @helpList = $('#shortcuts')

  bind: (shortcuts)->
    this.disable()
    @shortcuts = shortcuts
    this.enable()
    this._updateHelp()

  disable: =>
    this._updateKeys(this._unbindKey)

  enable: =>
    this._updateKeys(this._bindKey)

  _updateKeys: (action)->
    action(shortcut) for shortcut in @shortcuts

  _bindKey: (shortcut) ->
    $(document).bind('keydown', key, shortcut.func) for key in shortcut.keys

  _unbindKey: (shortcut) ->
    $(document).unbind('keydown', shortcut.func)

  _registerHelpPopup: ->
    $('#keyShortcutsLink').click =>
      this.popup($('#keyShortcuts'))
      false

  _updateHelp: ->
    @helpList.empty()
    for shortcut in @shortcuts
      do (shortcut) =>
        @helpList.append(
          $('<li>').text(shortcut.text())
        )


class window.KeyShortcut
  constructor: (@keys, @func, @desc) ->
    unless @keys instanceof Array
      @keys = [@keys]

  text: ->
    keysStrings = ("'#{key}'" for key in @keys)
    "#{keysStrings.join(', ')}: #{@desc}"


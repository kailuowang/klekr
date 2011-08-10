class window.KeyShortcuts
  constructor: ->
    @shortcuts = []
    this._registerHelpPopup()
    @helpList = $('#shortcuts')

  bind: (shortcuts)->
    this._updateKeys(this._unbindKey)
    @shortcuts = shortcuts
    this._updateKeys(this._bindKey)
    this._updateHelp()

  _updateKeys: (action)->
    action(shortcut) for shortcut in @shortcuts

  _bindKey: (shortcut) ->
    $(document).bind('keydown', key, shortcut.func) for key in shortcut.keys

  _unbindKey: (shortcut) ->
    $(document).unbind('keydown', shortcut.func)

  _registerHelpPopup: ->
    $('#keyShortcutsLink').click ->
      $('#keyShortcuts').bPopup()
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


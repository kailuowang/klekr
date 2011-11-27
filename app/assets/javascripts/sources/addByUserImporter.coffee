class window.AddByUserImporter extends StreamImporterBase
  constructor: ->
    @_popup = $('#import-by-user')
    @_notFound = @_popup.find('#not-found')
    @_form = @_popup.find('#search-user-form')
    @_addingUser = @_popup.find('#adding-user')
    streams_grid = @_popup.find('.sources-grid:first')
    @_streams_gridview = new SourcesGridview(streams_grid)
    @_loading = $('#searching-user')
    @_resultsGrid = @_popup.find('#search-result')
    $('#add-by-user-link').click_ this.show
    @_addButton = @_popup.find('#do-add')
    @_addButton.click_ this._add
    @_popup.find('.close-btn').click_ this._close
    @_popup.find('#submit').click_ this._doSearch

  show: =>
    @_addButton.show()
    @_notFound.hide()
    this.popup(@_popup)

  _close: =>
    @_popup.close()

  _doSearch: =>
    keyword = _.str.trim @_popup.find('#keyword').val()
    if keyword.length > 0
      @_loading.show()
      @_form.hide()
      @_resultsGrid.hide()
      klekr.Global.server.post(search_users_path(), {keyword: keyword}, this._showSearchResult)

  _showSearchResult: (data)=>
    @_loading.hide()
    @_form.show()
    @_results = data
    if( hasResults = @_results.length > 0 )
      @_streams_gridview.load(@_results)

      @_addingUser.hide()
      @_resultsGrid.slideDown()

    this.setVisible(@_notFound, !hasResults)


  _add: =>
    @_addingUser.show()
    @_addButton.hide()
    new queffee.CollectionWorkQ(
          collection: @_results
          operation: (streamInfo, callback) => this._import(streamInfo, callback)
          onFinish: =>
            @_addingUser.hide()
            this._finish()
        ).start()


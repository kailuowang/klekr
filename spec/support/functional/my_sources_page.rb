module Functional
  class MySourcesPage < PageBase
    def open
      super('flickr_streams')
      wait_until do
       !@d['loading-sources-indicator'].displayed?
      end
    end

    def displaying_sources_ids(rating = nil)
      rating_locator = rating ? "#star#{rating}" : ""
      cells = ss "#sources-list #{rating_locator} .source-cell"
      cells.map { |cell| cell["id"].split('-')[2] }
    end

    def sources_import_panel
      @d['sources-import-panel']
    end

    def empty_message
      @d['empty-sources']
    end

    def popup_recommendations_import_button
      @d['add-editor-streams-link']
    end

    def sources_in_recommendations
      ss '#import-editor-streams-popup .source-cell'
    end

    def add_all_recommendations_button
      s '#import-editor-streams-popup #do-import-streams'
    end

    def wait_until_new_sources_added_message_appears
      wait_until do
        @d['new-sources-added'].displayed?
      end
    end

    def find_cell_for(stream)
      s cell_locator(stream)
    end

    def cell_disabled_for(stream)
      s(cell_locator(stream) + " .main-part.removed").present?
    end

    def hove_on_stream(stream)
      hove_on( find_cell_for(stream) )
    end

    def add_source_by_cell(cell)
      hove_on(cell)
      cell.find_element(id: 'add').click
    end

    def add_button_for(stream)
      s cell_locator(stream) + ' #add'
    end

    def remove_button_for(stream)
      s(cell_locator(stream) + ' #remove')
    end

    def cell_locator(stream)
      "#sources-list #source-cell-#{stream.id}"
    end
  end
end
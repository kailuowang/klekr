module Functional
  class MySourcesPage < PageBase
    def open opts = {}
      super('flickr_streams', opts)
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

    def popup_groups_import_button
      @d['add-group-streams-link']
    end

    def popup_contacts_import_button
      @d['add-contacts-link']
    end

    def sources_in_recommendations
      ss '#import-editor-streams-popup .source-cell'
    end

     def sources_in_user_search
      ss '#import-by-user .source-cell'
    end

    def add_all_recommendations_button
      s '#import-editor-streams-popup #do-import-streams'
    end

    def add_all_groups_button
      s '#import-group-streams-popup #do-import-streams'
    end

    def add_all_contacts_button
      s '#import-contacts-popup #do-import-streams'
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

    def popup_google_reader_button
      s '#import-google-reader-link'
    end

    def import_google_reader_button
      s '#import-google-reader-popup #do-import'
    end

    def import_google_reader_file
      s '#import-google-reader-popup #google-reader-file'
    end

    def popup_add_by_user
      s '#add-by-user-link'
    end

    def add_by_user_button
      s '#import-by-user #do-add'
    end

    def search_for_user_to_add(username)
      add_by_user_search_box.send_keys username
      s('#search-user-form #submit').click
      wait_until do
        user_search_results_ready? and add_by_user_button.displayed?
      end
    end

    def user_search_results_ready?
      s('#import-by-user #search-result').size.height.to_i > 210
    end

    def add_by_user_search_box
      s '#search-user-form #keyword'
    end

  end
end
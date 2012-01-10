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

    def find_cell_for(stream)
      s cell_locator(stream)
    end

    def cell_disabled_for(stream)
      s(cell_locator(stream) + " .main-part.removed").present?
    end

    def hove_on(stream)
      cell = find_cell_for(stream)
      @d.action.move_to(cell).perform
      pause
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
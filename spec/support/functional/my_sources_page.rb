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
  end
end
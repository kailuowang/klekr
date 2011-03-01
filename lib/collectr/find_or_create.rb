module Collectr
  module FindOrCreate
    def find_or_create(params)
      if (found = where(params).first)
        found.update_attributes!(params)
        found
      else
        create(params)
      end
    end
  end
end
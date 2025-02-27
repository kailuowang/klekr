module Collectr
  module FindOrCreate
    def find_or_create(params)
      if (found = where(params).first)
        # Rails 7 uses update! instead of update_attributes!
        found.update!(params)
        found
      else
        create(params)
      end
    end
  end
end
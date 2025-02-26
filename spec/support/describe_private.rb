# Helper module to test private methods
# This adds a before and after hook to make private methods public during tests
module PrivateMethodHelper
  def self.included(base)
    base.class_eval do
      # Hook into RSpec's example_group creation
      RSpec.configure do |config|
        config.before(:each) do
          # Only run this if we're testing a class
          if described_class.is_a?(Class)
            @saved_private_methods = described_class.private_instance_methods
            described_class.class_eval { public *@saved_private_methods }
          end
        end

        config.after(:each) do
          # Only run this if we have saved private methods
          if defined?(@saved_private_methods) && described_class.is_a?(Class)
            described_class.class_eval { private *@saved_private_methods }
          end
        end
      end
    end
  end
end

# Include this helper in all spec files
RSpec.configure do |config|
  config.include PrivateMethodHelper
end

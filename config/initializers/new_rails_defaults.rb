# Be sure to restart your server when you modify this file.

# These settings change the behavior of Rails 6 features
# For more information on these settings, see the Rails 6 guides

# Enable parameter wrapping for JSON
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Set default class for serialize in ActiveRecord
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
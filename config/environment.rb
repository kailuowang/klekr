# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Collectr::Application.initialize!


Time::DATE_FORMATS[:short] = "%Y/%m/%d %H:%M %Z"
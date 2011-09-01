desc "Generate a JavaScript file that contains your Rails routes"
namespace :js do
  task :routes => :environment do
    save_path = "#{Rails.root}/app/assets/javascripts/global/rails_routes.js"
    routes = generate_routes_for_rails_3

    javascript = ""
    routes.each do |route|
        javascript << generate_method(route[:name], route[:path]) + "\n"
    end

    File.open(save_path, "w") { |f| f.write(javascript) }
    puts "Routes saved to #{save_path}."
  end
end

def generate_method(name, path)
  compare = /:(.*?)(\/|$)/
  path.sub!(compare, "' + params.#{$1} + '#{$2}") while path =~ compare
  return "function #{name}(params){ return '#{path}'}"
end

def generate_routes_for_rails_3
  Rails.application.reload_routes!
  processed_routes = []
  Rails.application.routes.routes.each do |route|
    processed_routes << {:name => route.name + "_path", :path => route.path.split("(")[0]} unless route.name.nil?
  end
  return processed_routes
end

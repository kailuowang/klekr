desc "run funcational suites"
task :functional do
  ENV['RAILS_ENV'] = 'development'
  sh 'rspec ./functional'
  puts "functional suites passed!"
end


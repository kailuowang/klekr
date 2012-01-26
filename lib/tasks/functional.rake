desc "run funcational suites"
task :functional do
  ENV['RAILS_ENV'] = 'development'
  sh 'rspec -c -fdocumentation ./functional'
  puts "functional suites passed!"
end


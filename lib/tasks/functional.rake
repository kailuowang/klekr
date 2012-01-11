desc "run funcational suites"
task :functional do
  sh 'cd . && RAILS_ENV=development rspec -c -fdocumentation functional/'
end

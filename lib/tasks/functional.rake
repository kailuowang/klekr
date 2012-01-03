desc "run funcational suites"
task :functional do
  sh 'cd functional && RAILS_ENV=development rspec .'
end

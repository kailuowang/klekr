desc "run funcational suites"
task :functional do
  sh 'rspec functional'
end

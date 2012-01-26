desc "run funcational suites"
task :functional do
  ENV['RAILS_ENV'] = 'development'
  sh 'rspec ./functional' do |ok, _|
    unless ok
      raise 'functioal suites failed!!'
    end
  end
  puts "functional suites passed!"
end


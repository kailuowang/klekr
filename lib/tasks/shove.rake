desc "push to git server"
task :shove do
  sh 'git pull --rebase'
  #Rake::Task["spec"].invoke
  Rake::Task["functional:run"].invoke
  sh 'git push'
end
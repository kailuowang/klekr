desc "push to git server"
task :shove do
  sh 'git pull --rebase'
  sh 'rake'
  sh 'git push'
end
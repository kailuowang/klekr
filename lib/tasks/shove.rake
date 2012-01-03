desc "push to git server"
task :shove do
  sh 'git pull --rebase'
  sh 'rake'
  sh 'rake functional'
  sh 'git push'
end
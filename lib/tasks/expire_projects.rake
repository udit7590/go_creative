namespace :projects do
  desc 'Close expired projects'
  task expire: :environment do
    Project.expire_old
  end
end

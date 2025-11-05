# lib/tasks/custom_db.rake

namespace :db do
  desc "Loads the seed data from db/seeds.rb (without transaction)"
  task :seed_no_tx => :environment do
    load(Rails.root.join('db', 'seeds.rb'))
  end
end

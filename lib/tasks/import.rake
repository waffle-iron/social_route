require Rails.root.join('lib/modules/importer')

namespace :db do
  desc 'import'
  task import: :environment do
    Importer.import
    next
  end
end

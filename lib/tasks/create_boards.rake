desc "Creates the default boards"
task :create_boards => :environment do
  %w(science chat help).each do |name|
    Board.create(:title => name)
  end
end

# A dynamic collection of Asset built by tag and created by a User
class LiveCollection
  include MongoMapper::Document
  include Focus
  include ZooniverseId
  
  zoo_id :prefix => "C", :sub_id => "S"
  key :name, String, :required => true
  key :description, String
  include Taggable
  
  # tag filters to build this collection
  key :tags, Array, :required => true
  timestamps!
  
  key :user_id, ObjectId, :required => true
  belongs_to :user
  
  # Finds assets that match the tags in the LiveCollection
  #   e.g. live_collection.assets(:page => 1, :per_page => 5)
  #--
  # Major performance hit here
  #++
  def assets(*args)
    options = { :page => 0, :per_page => 10 }
    options = options.update(args.first) unless args.first.nil?
    
    Asset.where(:tags.all => self.tags).skip(options[:page] * options[:per_page]).limit(options[:per_page]).all
  end
  
  # Bypasses the Focus#tags aggregation
  def tags
    self[:tags]
  end
  
  def self.most_recent (no=10)
     LiveCollection.limit(no).sort(['created_at', -1]).all
   end
  
   def self.trending (no=10)
    result= Discussion.collection.group( [:focus_id], {:focus_type=>"LiveCollection"}, {:count=>0},"function(obj, prev){ prev.count += obj.no_of_comments*obj.no_of_users; }")
    result[0..no-1].collect{|r| LiveCollection.find(r['focus_id'])}

   end
end

# A Comment on a Discussion by a User
class Comment
  include MongoMapper::Document
  
  key :discussion_id, ObjectId, :required => true
  key :upvotes, Array
  key :body, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, whether these make their way up to the discussion level is TBD
  timestamps!
  
  belongs_to :discussion
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  one :response_to, :class_name => "Comment", :foreign_key => "response_to_id"
  
  # Atomic operation to let a User vote for a Comment
  def cast_vote_by(user)
    return if author.id == user.id
    Comment.collection.update({ '_id' => self.id }, {'$addToSet' => { 'upvotes' => user.id } })
  end
end

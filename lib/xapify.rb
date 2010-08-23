module Xapify
  include XapianFu
  
  module ClassMethods
    def xapify_fields(*args)
      opts = args.extract_options!
      
      class << self
        attr_accessor :xap_db, :xap_fields
      end
      
      @xap_fields = {}
      args.each do |arg|
        @xap_fields[arg.to_sym] = { :store => true, :type => keys[arg.to_s].type }
      end
      
      @xap_db = Xapify::XapianDb.new(:dir => "#{Rails.root}/index/#{name}.db", :create => true, :fields => @xap_fields)
    end
    
    def search(*args)
      opts = args.extract_options!
      opts = { :from_mongo => false }.update(opts)
      string = args.first
      
      db = @xap_db
      docs = db.search(string)
      
      docs.collect do |doc|
        hash = {}
        @xap_fields.each_key do |key|
          hash[key] = @xap_fields[key][:type] == Array ? JSON.load(doc.values[key]) : doc.values[key]
        end
        
        opts[:from_mongo] ? find(hash[:_id]) : hash
      end
    end
  end

  module InstanceMethods
    def update_xapian
      db = self.class.xap_db
      inserted = nil
      
      doc_hash = {}
      doc_hash[:id] = self.xap_id
      doc_hash[:bid]= self._id.to_s
      self.class.xap_fields.each do |field|
        doc_hash[field.first.to_sym] = self.send(field.first.to_sym)
      end
      
      inserted = db.add_doc doc_hash
      self.xap_id = inserted.id
    end
  end
  
  def self.configure(base)
    base.before_save :update_xapian
    base.key :xap_id, Fixnum
  end
end

MongoMapper::Plugins.send :include, Xapify

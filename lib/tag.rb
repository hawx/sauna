module Models
  class Tag
  
    include DataMapper::Resource
    
    property :id,   Serial
    property :name, String, :required => true
    
    has n, :taggings
    has n, :posts,    :through => :taggings
    
  end
  
  class Tagging
    
    include DataMapper::Resource
    
    property :id, Serial
    
    belongs_to :post
    belongs_to :tag
    
  end
  
end
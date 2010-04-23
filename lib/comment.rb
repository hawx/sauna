module Models  
  
  class Comment
    
    include DataMapper::Resource
    
    property :id,          Serial
    property :post_id,     Integer
    property :raw_content, Text, :required => true
    
    property :created_at,  DateTime
    property :updated_at,  DateTime
    
    property :created_by,  Integer
    
    belongs_to :post    
    
    
    before(:save) do 
      self.updated_at = DateTime.now 
    end
    
    def initialize( attributes={} )
      self.created_at = Time.now
      self.updated_at = self.created_at
    end
    
    def url
      "#{self.parent.url}/#{self.id}"
    end
    
    def parent
      Post.get( self.post_id )
    end
    
    def content=(value)
      self.raw_content = value
    end
    
    def content
      self.raw_content.markup
    end
    
    def creator
      Member.first( :id => self.created_by )
    end
    
    def creatable_by(user)
      true
    end
    def updatable_by?(user)
      creator == user || user.admin?
    end
    def editable_by?(user)
      updatable_by?(user)
    end
    def destroyable_by?(user)
      updatable_by(user)
    end
    
  end
end
module Models  
  
  class Comment
    
    include DataMapper::Resource
    
    property :id,         Serial
    property :post_id,    Integer
    property :author,     Integer
    
    property :content,    Text,     :lazy => false
    property :created_at, DateTime
    property :updated_at, DateTime
    
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
    
    def created_at_string
      self.created_at.strftime("%B %d, %Y at %H:%M")
    end
    def created_at_short_string
      self.created_at.strftime("%B %d %Y")
    end
    def updated_at_string
      self.updated_at.strftime("%B %d, %Y at %H:%M")
    end
    def updated_at_short_string
      self.updated_at.strftime("%B %d %Y")
    end
    
    def parent
      Post.get( self.post_id )
    end
    
    def m_content
      self.content.markup
    end
    
    def creator
      Member.first( :id => self.author )
    end
    
  end
end
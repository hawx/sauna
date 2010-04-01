module Models
  class Sauna
    
    include DataMapper::Resource
    
    property :id,              Serial
    property :name,            String
    property :created_at,      DateTime
    
    has n, :discussions
    has n, :members
    
    
    def initialize( attributes={} )
      self.created_at = Time.now
    end
  
    protected
    
    def method_missing(m, *args)
      return false
    end
    
  end
end
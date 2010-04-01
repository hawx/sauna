=begin
module Models
  class Topic
  
    include DataMapper::Resource
    
    property :id,   Serial
    property :name, String, :required => true
    
    belongs_to :post
    
    before(:save) do 
      self.updated_at = DateTime.now 
      self.updated_by = 1
    end
    
    def initialize( attributes={} )
      self.created_at = Time.now
      self.updated_at = self.created_at
    end
    
  end
end
=end
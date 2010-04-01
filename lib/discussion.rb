module Models

  class Discussion
    
    include DataMapper::Resource
    
    property :id,          Serial
    property :name,        String, :required => true
    property :slug,        String
    property :description, String,  :default => "A forum to discuss things"
    property :public,      Boolean, :default => true
    
    property :created_at,  DateTime
    property :updated_at,  DateTime
    
    property :created_by,  String
    property :updated_by,  String
    
    belongs_to :sauna
    has n, :posts
    
    
    before(:save) do 
      self.updated_at = DateTime.now
      self.slug = slugify(self.name)
    end
    
    def initialize( attributes={} )
      self.created_at = Time.now
      self.updated_at = self.created_at
    end
    
    def slugify( string )
      string = string.clone
      string.gsub!(/[']+/, '')
      string.gsub!(/\W+/, ' ')
      string.strip!
      string.downcase!
      string.gsub!(' ', '-')
      string
    end
    
    def url
      "/#{self.slug}"
    end
    
    def created_at_string
      self.created_at.strftime("%B %d, %Y at %H:%M")
    end
    def updated_at_string
      self.updated_at.strftime("%B %d, %Y at %H:%M")
    end
    
    def creator
      Member.first( :id => self.created_by )
    end
    def updater
      Member.first( :id => self.updated_by )
    end
    
  end  
end
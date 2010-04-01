module Models
  
  class Post
  
    include DataMapper::Resource
    
    property :id,             Serial
    property :discussion_id,  Integer
    property :title,          String, :required => true
    property :slug,           String
    
    property :content,        Text
    
    property :created_at,     DateTime
    property :updated_at,     DateTime
    
    property :created_by,     Integer
    property :updated_by,     Integer
    
    belongs_to :discussion
    has n, :comments
    
    has n, :taggings
    has n, :tags, :through => :taggings
    
    before(:save) do 
      self.updated_at = DateTime.now
      self.slug = slugify(self.title)
    end
     
    def initialize( attributes={} )
      self.created_at = Time.now
      self.updated_at = self.created_at
    end
    
    def updated=( user )
      self.updated_by = user
      self.updated_at = Time.now
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
      "#{self.parent.url}/#{self.slug}"
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
      Discussion.get( self.discussion_id )
    end
    
    def tags=( list )
      unless list.nil?
        list.gsub!(/\s/, '')
        list.split(',').each do |t|
          tag(t)
        end
      end
    end
    
    def tag( name )
      unless @tag = Tag.first(:name => name)
        @tag = Tag.new( :name => name )
        @tag.save
      end
      @tagging = Tagging.new(:tag => @tag)
      taggings << @tagging
      @tagging
    end
    
    def m_content
      self.content.markup
    end
    
    def creator
      Member.first( :id => self.created_by )
    end
    def updater
      member = Member.first( :id => self.updated_by )
      if member.nil?
        Member.first( :id => self.created_by )
      else
        member
      end
    end
    
  end
end
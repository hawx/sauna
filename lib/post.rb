module Models
  
  class Post
  
    include DataMapper::Resource
    
    property :id,             Serial
    property :discussion_id,  Integer
    property :name,           String, :required => true, :unique => true
    property :slug,           String, :unique => true
    property :raw_content,    Text,   :required => true
    
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
      self.slug = self.name.slugify
    end
     
    def initialize( attributes={} )
      self.created_at = Time.now
      self.updated_at = self.created_at
    end
    
    def updated=( user )
      self.updated_by = user
      self.updated_at = Time.now
      p "'Post.updated = ' will be deprecated"
    end

    
    def url
      "#{self.parent.url}/#{self.slug}"
    end
    
    def parent
      Discussion.get( self.discussion_id )
    end
    
    def tags=( list )
      unless list.nil?
        list.gsub!(/\s/, '')
        list.split(',').each do |t|
          unless tag = Tag.first(:name => t)
            tag = Tag.new( :name => t )
            tag.save
          end
          @tagging = Tagging.new(:tag => tag)
          taggings << @tagging
        end
      end
    end
    
    def tags
      @tags = self.taggings
      t = []
      @tags.each do |tag|
        t << Tag.get(tag.tag_id)
      end
      t
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
module Models
  
  class Member
    
    include DataMapper::Resource
    
    property :id,               Serial
    property :email,            String,  :unique   => true
    property :fname,            String
    property :sname,            String
    property :age,              Integer
    
    property :bio,              Text
    
    property :username,         String,  :required => true, :unique => true
    property :hashed_password,  String
    property :salt,             String
    
    property :join_date,        DateTime
    property :access_level,     Integer, :default  => 0
    
    property :banned,           Boolean, :default => false
    property :ban_end,          DateTime
    
    property :avatar,           Boolean, :default => false
    property :avatar_type,      String
    property :avatar_size,      Integer
    
    belongs_to :sauna
    
    attr_accessor :password, :password_confirmation
    
    
    def initialize( attributes={} )
      self.join_date = Time.now
      self.access_level = 3 if self.id == 1
    end
    
    def password=(pass)
      @password = pass
      self.salt = Member.random_string(10) if !self.salt
      self.hashed_password = Member.encrypt(@password, self.salt)
    end
    
    def bandate=(date)
      # should make this a little bit more flexible
      # or just add a datepicker from jQuery UI
      date = Time.strptime(date, "%d/%m/%y")
      
      if self.banned?
        self.ban_end = date
      else
        self.banned = true
        self.ban_end = date
      end
    end
    
    def self.authenticate(username, password)
      
      current_user = Member.first(:username => username)
      return nil if current_user.nil?
      return nil if current_user.banned?
      
      if Member.encrypt(password, current_user.salt) == current_user.hashed_password
        return current_user
      end
      nil
    end
    
    def self.banned?
      if self.banned
        if self.ban_end < Time.now
          # ban has ended so remove ban
          self.banned = false
          return false
        else
          return true
        end
      else
        return false
      end
    end
    
    def bandate
      self.ban_end.strftime("%d/%m/%y")
    end
    
    def url
      "/member/#{self.username}"
    end
    
    def admin?
      self.access_level == 3 || self.id == 1
    end
    
    def senior?
      self.access_level == 1
    end
    
    def moderator?
      self.access_level == 2
    end
  
    def site_admin?
      self.id == 1
    end
    
    def join_date_string
      self.join_date.strftime("%B %d, %Y at %H:%M")
    end
    
    def rank
      case self.access_level
        when 0 then "Member"
        when 1 then "Senior Member"
        when 2 then "Moderator"
        when 3 then "Admin"
        else "Guest"
      end
    end
    
    def upload_avatar( file )
      self.avatar = true
      self.avatar_type = file[:type]
      self.avatar_size = File.size(file[:tempfile])
      path = File.join(Dir.pwd, "/public/images/avatars", image_name(self.username, file[:type]))
      
      File.open(path, "wb") do |f|
        f.write(file[:tempfile].read)
      end
    end
    
    def avatar_url
      if self.avatar
        "/images/avatars/#{image_name(self.username, self.avatar_type)}"
      else
        nil
      end
    end
    
    def biography
      if self.bio
        marked = RedCloth.new( self.bio ).to_html
        marked.gsub!(/@([a-zA-Z0-9_-]+)/) do |u|
          if user = Member.first(:username => u[1..u.size])
            "<a href='/member/#{user.id}'><span class='at'>@</span>#{user.username}</a>"
          else
            u
          end
        end
        marked.gsub!(/#([a-zA-Z0-9_-]+)/) do |t|
          if tag = Tag.first(:name => t[1..t.size])
            "<a href='/tag/#{tag.id}'><span class='hash'>#</span>#{tag.name}</a>"
          else
            t
          end
        end
        marked
      else
        ''
      end
    end
    
    protected
    
    def self.encrypt( password, salt )
      Digest::SHA1.hexdigest( password + salt )
    end
    
    def self.random_string( length )
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      new_password = ""
      1.upto( length ) do |i|
        new_password << chars[rand(chars.size-1)]
      end
      return new_password
    end
    
    def image_name( name, type )
      case type
        when 'image/jpeg' then name += '.jpg'
        when 'image/gif' then name += '.gif'
        when 'image/png' then name += '.png'
        when 'image/tiff' then name += '.tif'
      end
    end
    
    def method_missing(m, *args)
      return false
    end
    
  end
end
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
    
    property :ban_end,          DateTime
    property :logged_in,        Boolean
    
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
    
    def ban=(date)
      # should make this a little bit more flexible
      # or just add a datepicker from jQuery UI
      unless date == ""
        date = Time.strptime(date, "%d/%m/%y")
        
        if self.banned?
          self.ban_end = date
        else
          self.ban_end = date
        end
      end
    end
    
    def self.authenticate(username, password)
      
      current_user = Member.first(:username => username)
      return nil if current_user.nil?
      return nil if current_user.banned?
      
      if Member.encrypt(password, current_user.salt) == current_user.hashed_password
        current_user.logged_in = true
        current_user.save
        return current_user
      end
      nil
    end
    
    def self.banned?
      return false unless self.ban_end
      if self.ban_end < Time.now
        return false
      else
        return true
      end
    end
    
    def ban_end?
      if self.ban_end
        self.ban_end.strftime("%d/%m/%y")
      else
        ""
      end
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
        when -1 then "Guest"
        when 0  then "Member"
        when 1  then "Senior Member"
        when 2  then "Moderator"
        when 3  then "Admin"
        else "Guest"
      end
    end
    
    def upload_avatar( file )
      if Sauna.first.s3
        p "hi"
      else
        self.avatar = true
        self.avatar_type = file[:type]
        self.avatar_size = File.size(file[:tempfile])
        path = File.join(Dir.pwd, 
                         "/public/images/avatars", 
                         image_name(self.username, 
                         file[:type]))
        
        File.open(path, "wb") do |f|
          f.write(file[:tempfile].read)
        end
      end
    end
    
    def avatar_url
      if self.avatar
        "/images/avatars/#{image_name(self.username, self.avatar_type)}"
      else
        "/images/avatar-missing.png"
      end
    end
    
    def biography
      if self.bio
        self.bio.markup 
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
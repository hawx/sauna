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
    
    def posts
      Post.all(:created_by => self.id)
    end
    
    def comments
      Comment.all(:created_by => self.id)
    end
    
    def activity
      @posts = self.posts
      @comments = self.comments
      
      @activity = []
      @posts.each do |post|
        @activity << {:type    => :post,
                      :title   => post.name,
                      :content => post.content,
                      :url     => post.url,
                      :date    => post.created_at}
      end
      @comments.each do |comment|
        @activity << {:type    => :comment,
                      :title   => comment.parent.title,
                      :content => comment.content,
                      :url     => comment.url,
                      :date    => comment.updated_at}
      end
                      
# [#<Models::Comment @id=1 @post_id=2 @created_by=1 @content="*Damn right!*" @created_at=Wed, 31 Mar 2010 18:50:26 +0100 @updated_at=Wed, 31 Mar 2010 18:53:54 +0100>, 
#<Models::Post @id=1 @discussion_id=1 @title="First Post" @slug="first-post" @content=<not loaded> @created_at=Wed, 31 Mar 2010 17:29:43 +0100 @updated_at=Wed, 07 Apr 2010 12:10:46 +0100 @created_by=1 @updated_by=1>, 

      @activity.sort_by { |i| i[:date] }.reverse
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
      @sauna = Sauna.first
      
      self.avatar = true
      self.avatar_type = file[:type]
      self.avatar_size = File.size(file[:tempfile])
      
      if @sauna.s3
        AWS::S3::Base.establish_connection!(
          :access_key_id     => @sauna.s3_key_id,
          :secret_access_key => @sauna.s3_secret
        )
        AWS::S3::S3Object.store(image_name(self.username, file[:type]), open(file[:tempfile]), @sauna.s3_bucket)
      else 
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
        @sauna = Sauna.first
        if @sauna.s3
          AWS::S3::Base.establish_connection!(
            :access_key_id     => @sauna.s3_key_id,
            :secret_access_key => @sauna.s3_secret
          )
          AWS::S3::S3Object.url_for(image_name(self.username, self.avatar_type), @sauna.s3_bucket, :use_ssl => true)
        else
          "/images/avatars/#{image_name(self.username, self.avatar_type)}"
        end
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
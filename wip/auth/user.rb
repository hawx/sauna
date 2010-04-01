module Models
  class User
    
    include DataMapper::Resource
    
    property :id,               Serial
    property :username,         String
    property :hashed_password,  String
    property :salt,             String
    
    attr_accessor :password, :password_confirmation
  
    def initialize
    
    end
    
    def password=( pass )
      @password = pass
      self.salt ||= User.random_string(10)
      self.hashed_password = User.encrypt( @password, self.salt )
    end
    
    def self.authenticate(username, password)
      p username
      p password
      current_user = User.first(:username => username)
      return nil if current_user.nil?
      
      if User.encrypt(password, current_user.salt) == current_user.hashed_password
        return current_user
      end
      nil
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
  end
  
  class GuestUser
    def guest?
      true
    end
    
    def permission_level
      0
    end
    
    def method_missing(m, *args)
      return false
    end
  end
  
  def login_required
    if current_user.class != GuestUser
      return true
    else
      session[:return_to] = request.fullpath
      redirect '/login'
      return false
    end
  end
  
  def current_user
    if session[:user]
      User.first(:id => session[:user])
    else
      GuestUser.new
    end
  end
  
  def logged_in?
    !!session[:user]
  end
end
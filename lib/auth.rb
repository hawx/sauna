module Models

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
      Member.first(:id => session[:user])
    else
      GuestUser.new
    end
  end
  
  def logged_in?
    !!session[:user]
  end
  
end
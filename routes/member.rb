module Sauna  
  class App
  
    # list members
    get '/member/?' do
      @sauna = Sauna.first
      @members = Member.all
      erb :member_list
    end
    
    # create members
    get '/member/new/?' do
      @sauna = Sauna.first
      erb :member_new, :layout => :form
    end
    post '/member/create/?' do
      @sauna = Sauna.first
    
      @member = @sauna.members.new
      @member.attributes = params[:member]
      @member.upload_avatar(params[:avatar]) if params[:avatar]     
      @member.save
      
      session[:notice] = "New member created"
      redirect "/member"
    end
    
    # view member
    get '/member/:m/?' do
      pass unless @member = Member.first(:username => params[:m])
      @sauna = Sauna.first
      erb :member_view
    end
    
    get '/member/:m/activity/?' do
      pass unless @member = Member.first(:username => params[:m])
      @sauna = Sauna.first
      erb :member_activity
    end
  
    get '/member/:m/mail/?' do 
      pass unless @member = Member.first(:username => params[:m])
      @sauna = Sauna.first
      erb :member_mail, :layout => :form
    end
    post '/member/:m/mail/?' do
      @member = Member.first(:username => params[:m])
      
      if RUBY_VERSION > "1.9"
        mail = Mail.new
        mail.from = params[:from]
        mail.to = @member.email
        mail.subject = params[:subject]
        mail.body = params[:content]
        
        mail.delivery_method :sendmail
        mail.deliver!
      else
        Pony.mail(:to => @member.email, :from => params[:from], :subject => params[:subject], :body => params[:content])
      end
      session[:notice] = "Email sent"
      redirect "/member/#{params[:m]}"
    end
  
    # edit members
    get '/member/:m/edit?' do
      login_required
      
      pass unless @member = Member.first(:username => params[:m])
      redirect "/member/#{params[:m]}" unless current_user.admin? || current_user.username == params[:m]
      
      @sauna = Sauna.first
  
      erb :member_edit, :layout => :form
    end
    post '/member/:m/edit?' do
      @member = Member.first(:username => params[:m])
      user_attributes = params[:member]
      if params[:member][:password] == ""
          user_attributes.delete("password")
          user_attributes.delete("password_confirmation")
      end
      @member.attributes = user_attributes
      @member.upload_avatar(params[:avatar]) if params[:avatar]
      if @member.save
        session[:notice] = "You edited a member"
        redirect "/member/#{params[:id]}"
      else
        session[:notice] = 'Edit failed'
        redirect "/member/edit/#{params[:id]}/"
      end
    end
    
    # delete members
    get '/member/:m/delete?' do
      login_required
      
      pass unless @member = Member.first(:username => params[:m])
      redirect "/member/#{params[:m]}" unless current_user.admin? || current_user.username == params[:m]
      redirect "/member/#{params[:m]}" if @member.site_admin?
      
      if @member.destroy!
        session[:notice] = "You deleted a member"
      else
        session[:notice] = "Deletion of a member failed"
      end
      redirect '/'
    end
  
  end
end
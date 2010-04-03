class Sauna

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
    
    redirect "/member"
  end
  
  # view member
  get '/member/:m/?' do
    pass unless @member = Member.first(:username => params[:m])
    @sauna = Sauna.first
    erb :member_view
  end
  
  # edit members
  get '/member/:m/edit?' do
    login_required
    
    pass unless @member = Member.first(:username => params[:m])
    edirect "/member/#{params[:m]}" unless current_user.admin? || current_user.username == params[:m]
    
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
      redirect "/member/#{params[:id]}"
    else
      session[:notice] = 'whoops, looks like there were some problems with your updates'
      redirect "/member/edit/#{params[:id]}/"
    end
  end
  
  # delete members
  get '/member/:m/delete?' do
    login_required
    
    pass unless @member = Member.first(:username => params[:m])
    redirect "/member/#{params[:m]}" unless current_user.admin? || current_user.username == params[:m]
    
    if @member.destroy!
      session[:flash] = "way to go, you deleted a user"
    else
      session[:flash] = "deletion failed, for whatever reason"
    end
    redirect '/'
  end

end
class Sauna < Sinatra::Base

  # start
  get '/' do
    if Sauna.first.nil?
      @sauna = Sauna.new
      @sauna.name = "Setup"
      erb :setup
    else
      @sauna = Sauna.first
      erb :index
    end
  end
  
  post '/setup' do
    @sauna = Sauna.new
    @sauna.attributes = params[:sauna]
    @sauna.save
    
    puts "New Sauna created..."
    p Sauna.first
  
    @sauna = Sauna.first
    @member = @sauna.members.new
    @member.attributes = params[:member]
    @member.access_level = 3
                         
    @member.save
    p @member
    @sauna.members << @member
    @sauna.save
    puts "Admin created..."
    
    redirect '/'
    
  end
  
  # discussion list
  get '/discussion/?' do
    @sauna = Sauna.first
    @discussions = Discussion.all
    
    erb :discussion_list
  end
  
  # create new discussions
  get '/discussion/new/?' do
    login_required
    @sauna = Sauna.first
    
    erb :discussion_new
  end
  post '/discussion/create/?' do  
    @sauna = Sauna.first
    
    @discussion = @sauna.discussions.new
    @discussion.attributes = params[:discussion]
    @discussion.created_by = session[:user]
    
    @discussion.save
    @sauna.discussions << @discussion
    @sauna.save
    
    redirect "/discussion/"
  end
  
  # view certain discussion
  get '/:d/?' do
    @sauna = Sauna.first
    pass unless @discussion = Discussion.get( params[:d] )
    
    erb :discussion_view
  end
  
  # create new post for discussion
  get '/:d/post/new/?' do
    login_required
    @sauna = Sauna.first
    erb :post_new
  end
  post '/:d/post/create/?' do
    @discussion = Discussion.get( params[:d] )
    
    @post = @discussion.posts.new
    @post.attributes = params[:post]
    @post.created_by = session[:user]
  
    @post.save
    @discussion.posts << @post
    @discussion.save
    
    redirect "/#{params[:id]}"
  end
  
  # view post
  get '/:d/post/:p/?' do
    @sauna = Sauna.first
    @discussion = @sauna.discussions.get(params[:d])
    @post = @discussion.posts.get(params[:p])
    erb :post_view
  end
  
  # edit posts
  get '/:d/post/:p/edit/?' do
    login_required
    
    @sauna = Sauna.first
    @discussion = @sauna.discussions.get(params[:d])
    @post = @discussion.posts.get(params[:p])
    
    redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @post.creator.id.to_s
    erb :post_edit
  end
  post '/:d/post/:p/edit/?' do
    @post = Discussion.get(params[:d]).posts.get(params[:p])
    @post.attributes = params[:post]
    @post.updated = session[:user]
    if @post.save
      redirect "/#{params[:d]}/post/#{params[:p]}"
    else
      session[:notice] = 'whoops, looks like there were some problems with your updates'
      redirect "/#{params[:d]}/post/#{params[:p]}/edit"
    end
  end
  
  get '/:d/post/:p/delete/?' do
    login_required
    @post = Discussion.get(params[:d]).posts.get(params[:p])
    redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @post.creator.id.to_s
    
    if @post.destroy!
      session[:flash] = "way to go, you deleted a post"
    else
      session[:flash] = "deletion failed, for whatever reason"
    end
    redirect '/'
  end
  
  # new comments
  get '/:d/post/:p/new/?' do
    login_required
    @sauna = Sauna.first
    erb :comment_new
  end
  post '/:d/post/:p/create/?' do
    @post = Discussion.get(params[:d]).posts.get(params[:p])
    
    @comment = @post.comments.new
    @comment.attributes = params[:comment]
    @comment.author = session[:user]
    
    @post.updated = session[:user]
    
    @comment.save
    @post.comments << @comment
    @post.save
    
    redirect "/#{params[:d]}/post/#{params[:p]}"
  end
  
  # edit comment
  get '/:d/post/:p/:c/edit/?' do
    login_required
    
    @sauna = Sauna.first
    @discussion = @sauna.discussions.get(params[:d])
    @post = @discussion.posts.get(params[:p])
    @comment = @post.comments.get(params[:c])
    
    redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @comment.creator.id.to_s
    erb :comment_edit
  end
  post '/:d/post/:p/:c/edit/?' do
    @comment = Discussion.get(params[:d]).posts.get(params[:p]).comments.get(params[:c])
    comment_attributes = params[:comment]
    @comment.attributes = comment_attributes
    if @comment.save
      redirect "/#{params[:d]}/post/#{params[:p]}"
    else
      session[:notice] = 'whoops, looks like there were some problems with your updates'
      redirect "/#{params[:d]}/post/#{params[:p]}/#{params[:c]}/edit"
    end
  end
  
  get '/:d/post/:p/:c/delete/?' do
    login_required
    @comment = Discussion.get(params[:d]).posts.get(params[:p]).comments.get(params[:c])
    redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @comment.creator.id.to_s
    
    if @comment.destroy!
      session[:flash] = "way to go, you deleted a comment"
    else
      session[:flash] = "deletion failed, for whatever reason"
    end
    redirect "/#{params[:d]}/post/#{params[:p]}"
  end
  
  
  # list members
  get '/member/?' do
    @sauna = Sauna.first
    @members = Member.all
    erb :member_list
  end
  
  # create members
  get '/member/new/?' do
    @sauna = Sauna.first
    erb :member_new
  end
  post '/member/create/?' do
    @sauna = Sauna.first
  
    @member = @sauna.members.new
    @member.attributes = params[:member]
    @member.upload_avatar(params[:avatar])
                  
    @member.save
    @sauna.members << @member
    @sauna.save
    
    redirect "/member"
  end
  
  # view member
  get '/member/:id/?' do
    @sauna = Sauna.first
    @member = Member.get( params[:id] )
    erb :member_view
  end
  
  # edit members
  get '/member/:id/edit?' do
    login_required
    @sauna = Sauna.first
    redirect "/member/#{params[:id]}" unless current_user.admin? || current_user.id.to_s == params[:id]
    @user = User.get(:id => params[:id])
    erb :member_edit
  end
  post '/member/:id/edit?' do
    @user = User.get(:id => params[:id])
    user_attributes = params[:member]
    if params[:member][:password] == ""
        user_attributes.delete("password")
        user_attributes.delete("password_confirmation")
    end
    @user.attributes = user_attributes
    if params[:avatar]
      @user.upload_avatar(params[:avatar])
    end
    if @user.save
      redirect "/member/view/#{params[:id]}"
    else
      session[:notice] = 'whoops, looks like there were some problems with your updates'
      redirect "/member/edit/#{params[:id]}/"
    end
  end
  
  # delete members
  get '/member/:id/delete?' do
    login_required
    @sauna = Sauna.first
    redirect "/member/" unless current_user.admin? || current_user.id.to_s == params[:id]
    
    if User.delete(params[:id])
      session[:flash] = "way to go, you deleted a user"
    else
      session[:flash] = "deletion failed, for whatever reason"
    end
    redirect '/'
  end
  
  # sass stuff [todo: add mobile stylesheet stuff]
  get '/css/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass ("sass/" + params[:name]).to_sym
  end
  
  # catch errors and redirect accordingly
  get '/discussion/*/?' do
    redirect '/topic/'
  end
  get '/member/*/?' do
    redirect '/member/'
  end
  get '/*/?' do
    redirect '/'
  end
  
end
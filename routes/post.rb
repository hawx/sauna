module Sauna
  class App
  
    # create new post for discussion
    get '/:d/post/new/?' do
      login_required
      @sauna = Sauna.first
      @title = "New Post"
      
      erb :post_new, :layout => :form
    end
    post '/:d/post/create/?' do
      @discussion = Discussion.first(:slug => params[:d])
      
      @post = @discussion.posts.new
      @post.attributes = params[:post]
      @post.created_by = session[:user]
      @post.discussion_id = @discussion.id
      @post.tags = params[:tags]
      @post.save
      
      session[:notice] = "You created a new post"
      redirect "/#{params[:id]}"
    end
    
    # view post
    get '/:d/:p/?' do
      pass unless @discussion = Discussion.first(:slug => params[:d])
      pass unless @post = Post.first(:slug => params[:p])
      @sauna = Sauna.first
      @title = "#{@sauna.name} > #{@post.name}"
      erb :post_view
    end
    
    # edit posts
    get '/:d/:p/edit/?' do
      login_required
      
      pass unless @discussion = Discussion.first(:slug => params[:d])
      pass unless @post = Post.first(:slug => params[:p])
      @sauna = Sauna.first
      @title = "Edit: #{@post.name}"
      
      #redirect "/#{params[:d]}/#{params[:p]}" unless @post.editable_by(current_user)
      redirect "/#{params[:d]}/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @post.creator.id.to_s
      erb :post_edit, :layout => :form
    end
    post '/:d/:p/edit/?' do
      pass unless @post = Post.first(:slug => params[:p])
      @post.attributes = params[:post]
      @post.updated_by = session[:user]
      if @post.save
        session[:notice] = "You edited a post"
        redirect "/#{params[:d]}/#{params[:p]}"
      else
        session[:notice] = 'Edit of post failed'
        redirect "/#{params[:d]}/#{params[:p]}/edit"
      end
    end
    
    get '/:d/:p/delete/?' do
      login_required
      pass unless @post = Post.first(:slug => params[:p])
      redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @post.creator.id.to_s
      
      if @post.destroy!
        session[:flash] = "You deleted a post"
      else
        session[:flash] = "Deletion of post failed"
      end
      redirect '/'
    end
    
    # new comments
    get '/:d/:p/new/?' do
      login_required
      @sauna = Sauna.first
      @title = "New Comment"
      erb :comment_new, :layout => :form
    end
    post '/:d/:p/create/?' do
      @post = Discussion.first(:slug => params[:d]).posts.first(:slug => params[:p])
      
      @comment = @post.comments.new
      @comment.attributes = params[:comment]
      @comment.created_by = session[:user]
      @comment.post_id = params[:p]

      @post.updated_by = session[:user]
      @comment.save
      @post.save
      
      redirect "/#{params[:d]}/#{params[:p]}"
    end
    
    # edit comment
    get '/:d/:p/:c/edit/?' do
      login_required
      
      pass unless @discussion = Discussion.first(:slug => params[:d])
      pass unless @post = Post.first(:slug => params[:p])
      pass unless @comment = Comment.first(:id => params[:c])
      
      @sauna = Sauna.first
      @title = "Edit Comment for #{@post.name}"
      
      redirect "/#{params[:d]}/#{params[:p]}" unless @comment.editable_by?(current_user)
      #redirect "/#{params[:d]}/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @comment.creator.id.to_s
      erb :comment_edit, :layout => :form
    end
    post '/:d/:p/:c/edit/?' do
      @comment = Comment.first(:id => params[:c])
      @comment.attributes = params[:comment]
      if @comment.save
        redirect "/#{params[:d]}/#{params[:p]}"
      else
        session[:notice] = 'whoops, looks like there were some problems with your updates'
        redirect "/#{params[:d]}/#{params[:p]}/#{params[:c]}/edit"
      end
    end
    
    get '/:d/:p/:c/delete/?' do
      login_required
      @comment = Discussion.get(params[:d]).posts.get(params[:p]).comments.get(params[:c])
      redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @comment.creator.id.to_s
      
      if @comment.destroy!
        session[:notice] = "way to go, you deleted a comment"
      else
        session[:notice] = "deletion failed, for whatever reason"
      end
      redirect "/#{params[:d]}/post/#{params[:p]}"
    end
  
  end
end
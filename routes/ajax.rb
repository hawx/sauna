module Sauna
  class App
  
    get '/ajax/:d/:p/?' do
      pass unless @discussion = Discussion.first(:slug => params[:d])
      pass unless @post = Post.first(:slug => params[:p])
      @sauna = Sauna.first
      @title = "#{@sauna.name} > #{@post.name} (avec ajax)"
      erb :ajax_comments
    end
    
    post '/ajax/:d/:p/create/?' do
      @post = Discussion.first(:slug => params[:d]).posts.first(:slug => params[:p])
      
      @comment = @post.comments.new
      @comment.content = params[:comment][:content]
      @comment.created_by = session[:user]
      @comment.post_id = params[:p]

      @post.updated_by = session[:user]
      @comment.save
      @post.save
      
      %{<li>
        <div class="meta">
          <img class="avatar" src="#{ @comment.creator.avatar_url }"/>
          <a href="#{ @comment.creator.url }" class="username">#{ @comment.creator.username }</a><br/>
          <span class="rank">#{ @comment.creator.rank }</span><br/>
          
          <time>#{ @comment.created_at.to_short }</time>
          
          <a href="#{ @comment.url }/edit" class="edit">edit</a>
          <a href="#{ @comment.url }/delete" class="delete">delete</a>
        </div>
        <div class="content">#{ @comment.content }</div>
      </li>}
      
    end
    
    get '/ajax/:d/:p/:c/edit/?' do
      login_required
      
      pass unless @discussion = Discussion.first(:slug => params[:d])
      pass unless @post = Post.first(:slug => params[:p])
      pass unless @comment = Comment.first(:id => params[:c])
      
      @sauna = Sauna.first
      @title = "Edit Comment for #{@post.name}"
      
      redirect "/ajax/#{params[:d]}/#{params[:p]}" unless @comment.editable_by?(current_user)
      erb :comment_edit, :layout => :form
    end
    
    post '/ajax/:d/:p/:c/edit/?' do
      @comment = Comment.first(:id => params[:c])
      @comment.attributes = params[:comment]
      if @comment.save
        redirect "/#{params[:d]}/#{params[:p]}"
      else
        session[:notice] = 'whoops, looks like there were some problems with your updates'
        redirect "/ajax/#{params[:d]}/#{params[:p]}/#{params[:c]}/edit"
      end
    end
    
    get '/ajax/:d/:p/:c/delete/?' do
      login_required
      @comment = Comment.get(params[:c])
      redirect "/#{params[:d]}/post/#{params[:p]}" unless current_user.admin? || current_user.id.to_s == @comment.creator.id.to_s
      
      if @comment.destroy!
        session[:notice] = "way to go, you deleted a comment"
      else
        session[:notice] = "deletion failed, for whatever reason"
      end
      redirect "/ajax/#{params[:d]}/#{params[:p]}"
    end
    
  end  
end
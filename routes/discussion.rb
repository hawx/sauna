module Sauna
  class App
    
    get '/discussion/?' do
      @sauna = Sauna.first
      @discussions = Discussion.all
      @title = "#{@sauna.name}: Discussions"
      
      erb :discussion_list
    end
    
    get '/discussion/new/?' do
      login_required
      @sauna = Sauna.first
      @title = "New Discussion"
      
      erb :discussion_new, :layout => :form
    end
    
    post '/discussion/create/?' do  
      @sauna = Sauna.first
      
      @discussion = @sauna.discussions.new
      @discussion.attributes = params[:discussion]
      @discussion.created_by = session[:user]
      
      @discussion.save
      
      session[:notice] = "New discussion created"
      redirect "/discussion/"
    end
    
    get '/:d/?' do
      pass unless @discussion = Discussion.first(:slug => params[:d])
      @sauna = Sauna.first
      @title = "#{@sauna.name} > #{@discussion.name}"
      erb :discussion_view
    end
    
    get '/:d/edit/?' do
    
    end
    
    post '/:d/edit/?' do
    
    end
    
    get '/:d/delete/?' do
      login_required
      pass unless @discussion = Discussion.first(:slug => params[:d])
      redirect "/#{params[:d]}" unless current_user.admin? || current_user.id.to_s == @discussion.creator.id.to_s
      
      if @discussion.destroy!
        session[:notice] = "You deleted a discussion"
      else
        session[:notice] = "Deletion of discussion failed"
      end
      redirect '/'
    end
    
    get '/discussion/*/?' do redirect '/discussion/' end
  
  end
end
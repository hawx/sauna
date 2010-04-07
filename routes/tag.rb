class Sauna

  get '/tag/?' do
    @sauna = Sauna.first
    @tags = Tag.all
    
    erb :tag_list
  end
  
  get '/tag/:t/?' do
    # display list of posts for tag
    @sauna = Sauna.first
    @tag = Tag.first(:name => params[:t])
    @tagging = Tagging.all.tag.all(:name => params[:t])
    @posts = @tagging.posts.all
    
    erb :tag_view
  end

end
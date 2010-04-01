class Sauna

  get '/tag/?' do
    @sauna = Sauna.first
    @tags = Tag.all
    
    erb :tag_list
  end
  
  get '/tag/:id/?' do
    # display list of posts for tag
    @sauna = Sauna.first
    @tag = Tag.first(:id => params[:id])
    @tagging = Tagging.all.tag.all(:id => params[:id])
    @posts = @tagging.posts.all
    
    erb :tag_view
  end

end
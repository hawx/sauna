class String
  def markup
    marked = RedCloth.new( self ).to_html
    marked.gsub!(/@([a-zA-Z0-9_-]+)/) do |u|
      if user = Member.first(:username => u[1..u.size])
        "<a href='/member/#{user.id}'><span class='at'>@</span>#{user.username}</a>"
      else
        u
      end
    end
    marked
  end
  
end
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
  
  def truncate!( length )
    self.split[0...length].join(" ")
  end
  
  #  Need to make this a lot more robust, it should truncate the slug if
  #  it gets too long, + other stuff. Another time maybe?
  #
  #  Also requiring the whole of active record seems like overkill?
  def slugify
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.truncate!(7)
    slug.gsub!(' ', '-')
    slug
  end
  
end
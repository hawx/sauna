class String
  def markup
    marked = RDiscount.new( self ).to_html
    marked.gsub!(/@([a-zA-Z0-9_-]+)/) do |u|
      if user = Models::Member.first(:username => $1)
        "<a href='#{user.url}'><span class='at'>@</span>#{user.username}</a>"
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
  def slugify
    slug = self
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.truncate!(7)
    slug.gsub!(' ', '-')
    slug
  end
  
end
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
  
  # need to make this a lot more robust, it should truncate the slug if
  #  it gets too long, +other stuff.
  def slugify
    self = self.clone
    self.gsub!(/[']+/, '')
    self.gsub!(/\W+/, ' ')
    self.strip!
    self.downcase!
    self.gsub!(' ', '-')
    self
  end
  
end
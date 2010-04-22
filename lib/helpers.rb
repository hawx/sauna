class String

  def markup
    marked = RDiscount.new( self, :smart ).to_html
    marked.gsub!(/@([a-zA-Z0-9_-]+)/) do |u|
      if user = Models::Member.first(:username => $1)
        "<a href='#{user.url}'><span class='at'>@</span>#{user.username}</a>"
      else
        u
      end
    end
    marked.gsub!(/&amp;/) { |a| "<abbr title='and'>&amp;</abbr>" }
    marked
  end
  
  def truncate( length )
    t = self.clone
    t.truncate!( length )
  end
  
  def truncate!( length )
    self.split[0...length].join(" ")
  end
  
  def slugify
    slug = self.clone
    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.truncate!(7)
    slug.gsub!(' ', '-')
    slug
  end
  
end

class DateTime
  
  # http://stackoverflow.com/questions/195740/how-do-you-do-relative-time-in-rails
  def to_pretty
    a = (Time.now-self).to_i
    case a
      when 0 then return 'just now'
      when 1 then return 'a second ago'
      when 2..59 then return a.to_s+' seconds ago' 
      when 60..119 then return 'a minute ago'
      when 120..3540 then return (a / 60).to_i.to_s+' minutes ago'
      when 3541..7100 then return 'an hour ago'
      when 7101..82800 then return ((a + 99) / 3600).to_i.to_s+' hours ago' 
      when 82801..172000 then return 'a day ago'
      when 172001..518400 then return ((a + 800) / (60*60*24)).to_i.to_s+' days ago'
      when 518400..1036800 then return 'a week ago'
    end
    return ((a+180000) / (60*60*24*7)).to_i.to_s+' weeks ago'
  end
  
  def to_long
    self.strftime("%B %d, %Y at %H:%M")
  end
  
  def to_short
    self.strftime("%B %d %Y")
  end

end
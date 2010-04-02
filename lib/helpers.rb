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
  
  #  Need to make this a lot more robust, it should truncate the slug if
  #  it gets too long, + other stuff. Another time maybe?
  def slugify
    slug = self.clone
    
    # @ref: http://snippets.dzone.com/posts/show/2384
    accents = { ['á','à','â','ä','ã'] => 'a',
          		  ['Ã','Ä','Â','À','�?'] => 'A',
          		  ['é','è','ê','ë'] => 'e',
          		  ['Ë','É','È','Ê'] => 'E',
          		  ['í','ì','î','ï'] => 'i',
          		  ['�?','Î','Ì','�?'] => 'I',
          		  ['ó','ò','ô','ö','õ'] => 'o',
          		  ['Õ','Ö','Ô','Ò','Ó'] => 'O',
          		  ['ú','ù','û','ü'] => 'u',
          		  ['Ú','Û','Ù','Ü'] => 'U',
          		  ['ç'] => 'c', ['Ç'] => 'C',
          		  ['ñ'] => 'n', ['Ñ'] => 'N' }
		accents.each do |ac,rep|
		  ac.each do |s|
			str = str.gsub(s, rep)
		  end
		end

    slug.gsub!(/[']+/, '')
    slug.gsub!(/\W+/, ' ')
    slug.strip!
    slug.downcase!
    slug.gsub!(' ', '-')
    slug
  end
  
end
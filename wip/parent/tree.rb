require 'sinatra'
require 'dm-core'

class Discussion
  include DataMapper::Resource
  
  property :id,        Serial
  property :parent_id, Integer
  property :name,      String
  
  is :tree, :order => :id
  
end

class Post
  include DataMapper::Resource
  
  property :id,        Serial
  property :parent_id, Integer
  property :name,      String
  
  is :tree, :order => :id
  
end

get '/' do
  d1 = Discussion.create(:name => 'first')
  d2 = Discussion.create(:name => 'second')
  
  p1 = d1.posts
end
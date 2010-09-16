require 'rubygems'
require 'sinatra'
require 'active_record'

# alphanumeric characters, case insensitive, stringified
AVAILABLE_CHARACTERS = ( ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a ).map {|char| char.to_s }


## Configure of Database
configure :development, :test, :production do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'rvturls.sqlite3'
  )
  begin
    ActiveRecord::Schema.define do
      create_table :urls do |t|
        t.string :url
        t.string :slug
        t.timestamps
      end
      
      create_table :clicks do |t|
        t.integer :url_id
        t.string :remote_ip
        t.string :referrer
        t.timestamps
      end
    end
  rescue ActiveRecord::StatementInvalid
    # Do nothing when error
  end
  
end

## ActiveRecord Models
class Url < ActiveRecord::Base
  has_many :clicks
  before_validation :slug_generate
  validates :url, :presence => true, :uniqueness => true
  validates :slug, :presence => true, :uniqueness => true
  

  private
  
  def slug_generate
    minimum_length ||= 4
    if Url.find_by_slug(unique_slug(minimum_length))
      minimum_length += 1
      self.slug = unique_slug(minimum_length)
    else
      self.slug = unique_slug(minimum_length)
    end
  end 
  
  def unique_slug(leng)
    length = AVAILABLE_CHARACTERS.size
    slug = ""
    1.upto(leng) do |i|
      slug << AVAILABLE_CHARACTERS[rand(length-1)]
    end
    return slug
  end
end

class Click < ActiveRecord::Base
  belongs_to :url
end





## Routes
get "/" do
  "Redirect to Revently.com"
  # redirect "http://revently.com"
end

post "/shorten" do
  @url = Url.find_or_initialize_by_url(params[:url])
  if @url.new_record?
    if @url.save
      status(201) 
      @url.to_json
      "Shorten url generated"
    else
      "An error occurs"
    end
  else
    @url.to_json
  end
end

get "/:slug" do
  @url = Url.find_by_slug(params[:slug])
  redirect @url.url
end
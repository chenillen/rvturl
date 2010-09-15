require 'rubygems'
require 'sinatra'
require 'active_record'


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
  validates :url, :presence => true, :uniqueness => true
  # validates :slug, :presence => true, :uniqueness => true
  
  def self.slug_generate
    # TODO
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
  @url = Url.new(:url => params[:url])
  if @url.save
    status(201) 
    @url.to_json
    "Shorten url generated"
  else
    "An error occurs"
  end
end

get "/:slug" do
  
end